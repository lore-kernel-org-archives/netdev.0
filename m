From: Vasiliy Kulikov <segoon@openwall.com>
Subject: [PATCH v3] net: ipv4: add IPPROTO_ICMP socket kind
Date: Sat, 14 May 2011 00:01:00 +0400
Message-ID: <20110513200100.GA3875@albatros>
References: <20110510.121550.112583080.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: solar@openwall.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, peak@argo.troja.mff.cuni.cz,
	kees.cook@canonical.com, dan.j.rosenberg@gmail.com,
	eugene@redhat.com, nelhage@ksplice.com, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110510.121550.112583080.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds IPPROTO_ICMP socket kind.  It makes it possible to send
ICMP_ECHO messages and receive the corresponding ICMP_ECHOREPLY messages
without any special privileges.  In other words, the patch makes it
possible to implement setuid-less and CAP_NET_RAW-less /bin/ping.  In
order not to increase the kernel's attack surface, the new functionality
is disabled by default, but is enabled at bootup by supporting Linux
distributions, optionally with restriction to a group or a group range
(see below).

Similar functionality is implemented in Mac OS X:
http://www.manpagez.com/man/4/icmp/

A new ping socket is created with

    socket(PF_INET, SOCK_DGRAM, PROT_ICMP)

Message identifiers (octets 4-5 of ICMP header) are interpreted as local
ports. Addresses are stored in struct sockaddr_in. No port numbers are
reserved for privileged processes, port 0 is reserved for API ("let the
kernel pick a free number"). There is no notion of remote ports, remote
port numbers provided by the user (e.g. in connect()) are ignored.

Data sent and received include ICMP headers. This is deliberate to:
1) Avoid the need to transport headers values like sequence numbers by
other means.
2) Make it easier to port existing programs using raw sockets.

ICMP headers given to send() are checked and sanitized. The type must be
ICMP_ECHO and the code must be zero (future extensions might relax this,
see below). The id is set to the number (local port) of the socket, the
checksum is always recomputed.

ICMP reply packets received from the network are demultiplexed according
to their id's, and are returned by recv() without any modifications.
IP header information and ICMP errors of those packets may be obtained
via ancillary data (IP_RECVTTL, IP_RETOPTS, and IP_RECVERR). ICMP source
quenches and redirects are reported as fake errors via the error queue
(IP_RECVERR); the next hop address for redirects is saved to ee_info (in
network order).

socket(2) is restricted to the group range specified in
"/proc/sys/net/ipv4/ping_group_range".  It is "1 0" by default, meaning
that nobody (not even root) may create ping sockets.  Setting it to "100
100" would grant permissions to the single group (to either make
/sbin/ping g+s and owned by this group or to grant permissions to the
"netadmins" group), "0 4294967295" would enable it for the world, "100
4294967295" would enable it for the users, but not daemons.

The existing code might be (in the unlikely case anyone needs it)
extended rather easily to handle other similar pairs of ICMP messages
(Timestamp/Reply, Information Request/Reply, Address Mask Request/Reply
etc.).

Userspace ping util & patch for it:
http://openwall.info/wiki/people/segoon/ping

For Openwall GNU/*/Linux it was the last step on the road to the
setuid-less distro.  A revision of this patch (for RHEL5/OpenVZ kernels)
is in use in Owl-current, such as in the 2011/03/12 LiveCD ISOs:
http://mirrors.kernel.org/openwall/Owl/current/iso/

Initially this functionality was written by Pavel Kankovsky for
Linux 2.4.32, but unfortunately it was never made public.

All ping options (-b, -p, -Q, -R, -s, -t, -T, -M, -I), are tested with
the patch.

PATCH v3:
    - switched to flowi4.
    - minor changes to be consistent with raw sockets code.

PATCH v2:
    - changed ping_debug() to pr_debug().
    - removed CONFIG_IP_PING.
    - removed ping_seq_fops.owner field (unused for procfs).
    - switched to proc_net_fops_create().
    - switched to %pK in seq_printf().

PATCH v1:
    - fixed checksumming bug.
    - CAP_NET_RAW may not create icmp sockets anymore.

RFC v2:
    - minor cleanups.
    - introduced sysctl'able group range to restrict socket(2).

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
---
 include/net/netns/ipv4.h   |    2 +
 include/net/ping.h         |   57 +++
 net/ipv4/Makefile          |    2 +-
 net/ipv4/af_inet.c         |   22 +
 net/ipv4/icmp.c            |   12 +-
 net/ipv4/ping.c            |  937 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/sysctl_net_ipv4.c |   80 ++++
 7 files changed, 1110 insertions(+), 2 deletions(-)
 create mode 100644 include/net/ping.h
 create mode 100644 net/ipv4/ping.c

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 542195d..d786b4f 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -54,6 +54,8 @@ struct netns_ipv4 {
 	int sysctl_rt_cache_rebuild_count;
 	int current_rt_cache_rebuild_count;
 
+	unsigned int sysctl_ping_group_range[2];
+
 	atomic_t rt_genid;
 	atomic_t dev_addr_genid;
 
diff --git a/include/net/ping.h b/include/net/ping.h
new file mode 100644
index 0000000..23062c3
--- /dev/null
+++ b/include/net/ping.h
@@ -0,0 +1,57 @@
+/*
+ * INET		An implementation of the TCP/IP protocol suite for the LINUX
+ *		operating system.  INET is implemented using the  BSD Socket
+ *		interface as the means of communication with the user level.
+ *
+ *		Definitions for the "ping" module.
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+#ifndef _PING_H
+#define _PING_H
+
+#include <net/netns/hash.h>
+
+/* PING_HTABLE_SIZE must be power of 2 */
+#define PING_HTABLE_SIZE 	64
+#define PING_HTABLE_MASK 	(PING_HTABLE_SIZE-1)
+
+#define ping_portaddr_for_each_entry(__sk, node, list) \
+	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_node)
+
+/*
+ * gid_t is either uint or ushort.  We want to pass it to
+ * proc_dointvec_minmax(), so it must not be larger than MAX_INT
+ */
+#define GID_T_MAX (((gid_t)~0U) >> 1)
+
+struct ping_table {
+	struct hlist_nulls_head	hash[PING_HTABLE_SIZE];
+	rwlock_t		lock;
+};
+
+struct ping_iter_state {
+	struct seq_net_private  p;
+	int			bucket;
+};
+
+extern struct proto ping_prot;
+
+
+extern void ping_rcv(struct sk_buff *);
+extern void ping_err(struct sk_buff *, u32 info);
+
+extern void inet_get_ping_group_range_net(struct net *net, unsigned int *low, unsigned int *high);
+
+#ifdef CONFIG_PROC_FS
+extern int __init ping_proc_init(void);
+extern void ping_proc_exit(void);
+#endif
+
+void __init ping_init(void);
+
+
+#endif /* _PING_H */
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 0dc772d..f2dc69c 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     datagram.o raw.o udp.o udplite.o \
 	     arp.o icmp.o devinet.o af_inet.o  igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
-	     inet_fragment.o
+	     inet_fragment.o ping.o
 
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
 obj-$(CONFIG_PROC_FS) += proc.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 851aa05..cc14631 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -105,6 +105,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/udplite.h>
+#include <net/ping.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <net/raw.h>
@@ -1008,6 +1009,14 @@ static struct inet_protosw inetsw_array[] =
 		.flags =      INET_PROTOSW_PERMANENT,
        },
 
+       {
+		.type =       SOCK_DGRAM,
+		.protocol =   IPPROTO_ICMP,
+		.prot =       &ping_prot,
+		.ops =        &inet_dgram_ops,
+		.no_check =   UDP_CSUM_DEFAULT,
+		.flags =      INET_PROTOSW_REUSE,
+       },
 
        {
 	       .type =       SOCK_RAW,
@@ -1527,6 +1536,7 @@ static const struct net_protocol udp_protocol = {
 
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
+	.err_handler =	ping_err,
 	.no_policy =	1,
 	.netns_ok =	1,
 };
@@ -1642,6 +1652,10 @@ static int __init inet_init(void)
 	if (rc)
 		goto out_unregister_udp_proto;
 
+	rc = proto_register(&ping_prot, 1);
+	if (rc)
+		goto out_unregister_raw_proto;
+
 	/*
 	 *	Tell SOCKET that we are alive...
 	 */
@@ -1697,6 +1711,8 @@ static int __init inet_init(void)
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();
 
+	ping_init();
+
 	/*
 	 *	Set the ICMP layer up
 	 */
@@ -1727,6 +1743,8 @@ static int __init inet_init(void)
 	rc = 0;
 out:
 	return rc;
+out_unregister_raw_proto:
+	proto_unregister(&raw_prot);
 out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
@@ -1751,11 +1769,15 @@ static int __init ipv4_proc_init(void)
 		goto out_tcp;
 	if (udp4_proc_init())
 		goto out_udp;
+	if (ping_proc_init())
+		goto out_ping;
 	if (ip_misc_proc_init())
 		goto out_misc;
 out:
 	return rc;
 out_misc:
+	ping_proc_exit();
+out_ping:
 	udp4_proc_exit();
 out_udp:
 	tcp4_proc_exit();
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 853a670..7c47eca 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -83,6 +83,7 @@
 #include <net/tcp.h>
 #include <net/udp.h>
 #include <net/raw.h>
+#include <net/ping.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
 #include <linux/errno.h>
@@ -781,6 +782,15 @@ static void icmp_redirect(struct sk_buff *skb)
 			       iph->saddr, skb->dev);
 		break;
 	}
+
+	/* Ping wants to see redirects.
+         * Let's pretend they are errors of sorts... */
+	if (iph->protocol == IPPROTO_ICMP &&
+	    iph->ihl >= 5 &&
+	    pskb_may_pull(skb, (iph->ihl<<2)+8)) {
+		ping_err(skb, icmp_hdr(skb)->un.gateway);
+	}
+
 out:
 	return;
 out_err:
@@ -1041,7 +1051,7 @@ error:
  */
 static const struct icmp_control icmp_pointers[NR_ICMP_TYPES + 1] = {
 	[ICMP_ECHOREPLY] = {
-		.handler = icmp_discard,
+		.handler = ping_rcv,
 	},
 	[1] = {
 		.handler = icmp_discard,
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
new file mode 100644
index 0000000..a77e2d7
--- /dev/null
+++ b/net/ipv4/ping.c
@@ -0,0 +1,937 @@
+/*
+ * INET		An implementation of the TCP/IP protocol suite for the LINUX
+ *		operating system.  INET is implemented using the  BSD Socket
+ *		interface as the means of communication with the user level.
+ *
+ *		"Ping" sockets
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Based on ipv4/udp.c code.
+ *
+ * Authors:	Vasiliy Kulikov / Openwall (for Linux 2.6),
+ *		Pavel Kankovsky (for Linux 2.4.32)
+ *
+ * Pavel gave all rights to bugs to Vasiliy,
+ * none of the bugs are Pavel's now.
+ *
+ */
+
+#include <asm/system.h>
+#include <linux/uaccess.h>
+#include <asm/ioctls.h>
+#include <linux/types.h>
+#include <linux/fcntl.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/in.h>
+#include <linux/errno.h>
+#include <linux/timer.h>
+#include <linux/mm.h>
+#include <linux/inet.h>
+#include <linux/netdevice.h>
+#include <net/snmp.h>
+#include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/icmp.h>
+#include <net/protocol.h>
+#include <linux/skbuff.h>
+#include <linux/proc_fs.h>
+#include <net/sock.h>
+#include <net/ping.h>
+#include <net/icmp.h>
+#include <net/udp.h>
+#include <net/route.h>
+#include <net/inet_common.h>
+#include <net/checksum.h>
+
+
+struct ping_table ping_table __read_mostly;
+
+u16 ping_port_rover;
+
+static inline int ping_hashfn(struct net *net, unsigned num, unsigned mask)
+{
+	int res = (num + net_hash_mix(net)) & mask;
+	pr_debug("hash(%d) = %d\n", num, res);
+	return res;
+}
+
+static inline struct hlist_nulls_head *ping_hashslot(struct ping_table *table,
+					     struct net *net, unsigned num)
+{
+	return &table->hash[ping_hashfn(net, num, PING_HTABLE_MASK)];
+}
+
+static int ping_v4_get_port(struct sock *sk, unsigned short ident)
+{
+	struct hlist_nulls_node *node;
+	struct hlist_nulls_head *hlist;
+	struct inet_sock *isk, *isk2;
+	struct sock *sk2 = NULL;
+
+	isk = inet_sk(sk);
+	write_lock_bh(&ping_table.lock);
+	if (ident == 0) {
+		u32 i;
+		u16 result = ping_port_rover + 1;
+
+		for (i = 0; i < (1L << 16); i++, result++) {
+			if (!result)
+				result++; /* avoid zero */
+			hlist = ping_hashslot(&ping_table, sock_net(sk),
+					    result);
+			ping_portaddr_for_each_entry(sk2, node, hlist) {
+				isk2 = inet_sk(sk2);
+
+				if (isk2->inet_num == result)
+					goto next_port;
+			}
+
+			/* found */
+			ping_port_rover = ident = result;
+			break;
+next_port:
+			;
+		}
+		if (i >= (1L << 16))
+			goto fail;
+	} else {
+		hlist = ping_hashslot(&ping_table, sock_net(sk), ident);
+		ping_portaddr_for_each_entry(sk2, node, hlist) {
+			isk2 = inet_sk(sk2);
+
+			if ((isk2->inet_num == ident) &&
+			    (sk2 != sk) &&
+			    (!sk2->sk_reuse || !sk->sk_reuse))
+				goto fail;
+		}
+	}
+
+	pr_debug("found port/ident = %d\n", ident);
+	isk->inet_num = ident;
+	if (sk_unhashed(sk)) {
+		pr_debug("was not hashed\n");
+		sock_hold(sk);
+		hlist_nulls_add_head(&sk->sk_nulls_node, hlist);
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	}
+	write_unlock_bh(&ping_table.lock);
+	return 0;
+
+fail:
+	write_unlock_bh(&ping_table.lock);
+	return 1;
+}
+
+static void ping_v4_hash(struct sock *sk)
+{
+	pr_debug("ping_v4_hash(sk->port=%u)\n", inet_sk(sk)->inet_num);
+	BUG(); /* "Please do not press this button again." */
+}
+
+static void ping_v4_unhash(struct sock *sk)
+{
+	struct inet_sock *isk = inet_sk(sk);
+	pr_debug("ping_v4_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
+	if (sk_hashed(sk)) {
+		struct hlist_nulls_head *hslot;
+
+		hslot = ping_hashslot(&ping_table, sock_net(sk), isk->inet_num);
+		write_lock_bh(&ping_table.lock);
+		hlist_nulls_del(&sk->sk_nulls_node);
+		sock_put(sk);
+		isk->inet_num = isk->inet_sport = 0;
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+		write_unlock_bh(&ping_table.lock);
+	}
+}
+
+struct sock *ping_v4_lookup(struct net *net, u32 saddr, u32 daddr,
+	 u16 ident, int dif)
+{
+	struct hlist_nulls_head *hslot = ping_hashslot(&ping_table, net, ident);
+	struct sock *sk = NULL;
+	struct inet_sock *isk;
+	struct hlist_nulls_node *hnode;
+
+	pr_debug("try to find: num = %d, daddr = %ld, dif = %d\n",
+			 (int)ident, (unsigned long)daddr, dif);
+	read_lock_bh(&ping_table.lock);
+
+	ping_portaddr_for_each_entry(sk, hnode, hslot) {
+		isk = inet_sk(sk);
+
+		pr_debug("found: %p: num = %d, daddr = %ld, dif = %d\n", sk,
+			 (int)isk->inet_num, (unsigned long)isk->inet_rcv_saddr,
+			 sk->sk_bound_dev_if);
+
+		pr_debug("iterate\n");
+		if (isk->inet_num != ident)
+			continue;
+		if (isk->inet_rcv_saddr && isk->inet_rcv_saddr != daddr)
+			continue;
+		if (sk->sk_bound_dev_if && sk->sk_bound_dev_if != dif)
+			continue;
+
+		sock_hold(sk);
+		goto exit;
+	}
+
+	sk = NULL;
+exit:
+	read_unlock_bh(&ping_table.lock);
+
+	return sk;
+}
+
+static int ping_init_sock(struct sock *sk)
+{
+	struct net *net = sock_net(sk);
+	gid_t group = current_egid();
+	gid_t range[2];
+	struct group_info *group_info = get_current_groups();
+	int i, j, count = group_info->ngroups;
+
+	inet_get_ping_group_range_net(net, range, range+1);
+	if (range[0] <= group && group <= range[1])
+		return 0;
+
+	for (i = 0; i < group_info->nblocks; i++) {
+		int cp_count = min_t(int, NGROUPS_PER_BLOCK, count);
+
+		for (j = 0; j < cp_count; j++) {
+			group = group_info->blocks[i][j];
+			if (range[0] <= group && group <= range[1])
+				return 0;
+		}
+
+		count -= cp_count;
+	}
+
+	return -EACCES;
+}
+
+static void ping_close(struct sock *sk, long timeout)
+{
+	pr_debug("ping_close(sk=%p,sk->num=%u)\n",
+		inet_sk(sk), inet_sk(sk)->inet_num);
+	pr_debug("isk->refcnt = %d\n", sk->sk_refcnt.counter);
+
+	sk_common_release(sk);
+}
+
+/*
+ * We need our own bind because there are no privileged id's == local ports.
+ * Moreover, we don't allow binding to multi- and broadcast addresses.
+ */
+
+static int ping_bind(struct sock *sk, struct sockaddr *uaddr, int addr_len)
+{
+	struct sockaddr_in *addr = (struct sockaddr_in *)uaddr;
+	struct inet_sock *isk = inet_sk(sk);
+	unsigned short snum;
+	int chk_addr_ret;
+	int err;
+
+	if (addr_len < sizeof(struct sockaddr_in))
+		return -EINVAL;
+
+	pr_debug("ping_v4_bind(sk=%p,sa_addr=%08x,sa_port=%d)\n",
+		sk, addr->sin_addr.s_addr, ntohs(addr->sin_port));
+
+	chk_addr_ret = inet_addr_type(sock_net(sk), addr->sin_addr.s_addr);
+	if (addr->sin_addr.s_addr == INADDR_ANY)
+		chk_addr_ret = RTN_LOCAL;
+
+	if ((sysctl_ip_nonlocal_bind == 0 &&
+	    isk->freebind == 0 && isk->transparent == 0 &&
+	     chk_addr_ret != RTN_LOCAL) ||
+	    chk_addr_ret == RTN_MULTICAST ||
+	    chk_addr_ret == RTN_BROADCAST)
+		return -EADDRNOTAVAIL;
+
+	lock_sock(sk);
+
+	err = -EINVAL;
+	if (isk->inet_num != 0)
+		goto out;
+
+	err = -EADDRINUSE;
+	isk->inet_rcv_saddr = isk->inet_saddr = addr->sin_addr.s_addr;
+	snum = ntohs(addr->sin_port);
+	if (ping_v4_get_port(sk, snum) != 0) {
+		isk->inet_saddr = isk->inet_rcv_saddr = 0;
+		goto out;
+	}
+
+	pr_debug("after bind(): num = %d, daddr = %ld, dif = %d\n",
+		(int)isk->inet_num,
+		(unsigned long) isk->inet_rcv_saddr,
+		(int)sk->sk_bound_dev_if);
+
+	err = 0;
+	if (isk->inet_rcv_saddr)
+		sk->sk_userlocks |= SOCK_BINDADDR_LOCK;
+	if (snum)
+		sk->sk_userlocks |= SOCK_BINDPORT_LOCK;
+	isk->inet_sport = htons(isk->inet_num);
+	isk->inet_daddr = 0;
+	isk->inet_dport = 0;
+	sk_dst_reset(sk);
+out:
+	release_sock(sk);
+	pr_debug("ping_v4_bind -> %d\n", err);
+	return err;
+}
+
+/*
+ * Is this a supported type of ICMP message?
+ */
+
+static inline int ping_supported(int type, int code)
+{
+	if (type == ICMP_ECHO && code == 0)
+		return 1;
+	return 0;
+}
+
+/*
+ * This routine is called by the ICMP module when it gets some
+ * sort of error condition.
+ */
+
+static int ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb);
+
+void ping_err(struct sk_buff *skb, u32 info)
+{
+	struct iphdr *iph = (struct iphdr *)skb->data;
+	struct icmphdr *icmph = (struct icmphdr *)(skb->data+(iph->ihl<<2));
+	struct inet_sock *inet_sock;
+	int type = icmph->type;
+	int code = icmph->code;
+	struct net *net = dev_net(skb->dev);
+	struct sock *sk;
+	int harderr;
+	int err;
+
+	/* We assume the packet has already been checked by icmp_unreach */
+
+	if (!ping_supported(icmph->type, icmph->code))
+		return;
+
+	pr_debug("ping_err(type=%04x,code=%04x,id=%04x,seq=%04x)\n", type,
+		code, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+
+	sk = ping_v4_lookup(net, iph->daddr, iph->saddr,
+			    ntohs(icmph->un.echo.id), skb->dev->ifindex);
+	if (sk == NULL) {
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		pr_debug("no socket, dropping\n");
+		return;	/* No socket for error */
+	}
+	pr_debug("err on socket %p\n", sk);
+
+	err = 0;
+	harderr = 0;
+	inet_sock = inet_sk(sk);
+
+	switch (type) {
+	default:
+	case ICMP_TIME_EXCEEDED:
+		err = EHOSTUNREACH;
+		break;
+	case ICMP_SOURCE_QUENCH:
+		/* This is not a real error but ping wants to see it.
+		 * Report it with some fake errno. */
+		err = EREMOTEIO;
+		break;
+	case ICMP_PARAMETERPROB:
+		err = EPROTO;
+		harderr = 1;
+		break;
+	case ICMP_DEST_UNREACH:
+		if (code == ICMP_FRAG_NEEDED) { /* Path MTU discovery */
+			if (inet_sock->pmtudisc != IP_PMTUDISC_DONT) {
+				err = EMSGSIZE;
+				harderr = 1;
+				break;
+			}
+			goto out;
+		}
+		err = EHOSTUNREACH;
+		if (code <= NR_ICMP_UNREACH) {
+			harderr = icmp_err_convert[code].fatal;
+			err = icmp_err_convert[code].errno;
+		}
+		break;
+	case ICMP_REDIRECT:
+		/* See ICMP_SOURCE_QUENCH */
+		err = EREMOTEIO;
+		break;
+	}
+
+	/*
+	 *      RFC1122: OK.  Passes ICMP errors back to application, as per
+	 *	4.1.3.3.
+	 */
+	if (!inet_sock->recverr) {
+		if (!harderr || sk->sk_state != TCP_ESTABLISHED)
+			goto out;
+	} else {
+		ip_icmp_error(sk, skb, err, 0 /* no remote port */,
+			 info, (u8 *)icmph);
+	}
+	sk->sk_err = err;
+	sk->sk_error_report(sk);
+out:
+	sock_put(sk);
+}
+
+/*
+ *	Copy and checksum an ICMP Echo packet from user space into a buffer.
+ */
+
+struct pingfakehdr {
+	struct icmphdr icmph;
+	struct iovec *iov;
+	u32 wcheck;
+};
+
+static int ping_getfrag(void *from, char * to,
+			int offset, int fraglen, int odd, struct sk_buff *skb)
+{
+	struct pingfakehdr *pfh = (struct pingfakehdr *)from;
+
+	if (offset == 0) {
+		if (fraglen < sizeof(struct icmphdr))
+			BUG();
+		if (csum_partial_copy_fromiovecend(to + sizeof(struct icmphdr),
+			    pfh->iov, 0, fraglen - sizeof(struct icmphdr),
+			    &pfh->wcheck))
+			return -EFAULT;
+
+		return 0;
+	}
+	if (offset < sizeof(struct icmphdr))
+		BUG();
+	if (csum_partial_copy_fromiovecend
+			(to, pfh->iov, offset - sizeof(struct icmphdr),
+			 fraglen, &pfh->wcheck))
+		return -EFAULT;
+	return 0;
+}
+
+static int ping_push_pending_frames(struct sock *sk, struct pingfakehdr *pfh, struct flowi4 *fl4)
+{
+	struct sk_buff *skb = skb_peek(&sk->sk_write_queue);
+
+	pfh->wcheck = csum_partial((char *)&pfh->icmph,
+		sizeof(struct icmphdr), pfh->wcheck);
+	pfh->icmph.checksum = csum_fold(pfh->wcheck);
+	memcpy(icmp_hdr(skb), &pfh->icmph, sizeof(struct icmphdr));
+	skb->ip_summed = CHECKSUM_NONE;
+	return ip_push_pending_frames(sk, fl4);
+}
+
+int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		 size_t len)
+{
+	struct net *net = sock_net(sk);
+	struct flowi4 fl4;
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipcm_cookie ipc;
+	struct icmphdr user_icmph;
+	struct pingfakehdr pfh;
+	struct rtable *rt = NULL;
+	struct ip_options_data opt_copy;
+	int free = 0;
+	u32 saddr, daddr, faddr;
+	u8  tos;
+	int err;
+
+	pr_debug("ping_sendmsg(sk=%p,sk->num=%u)\n", inet, inet->inet_num);
+
+
+	if (len > 0xFFFF)
+		return -EMSGSIZE;
+
+	/*
+	 *	Check the flags.
+	 */
+
+	/* Mirror BSD error message compatibility */
+	if (msg->msg_flags & MSG_OOB)
+		return -EOPNOTSUPP;
+
+	/*
+	 *	Fetch the ICMP header provided by the userland.
+	 *	iovec is modified!
+	 */
+
+	if (memcpy_fromiovec((u8 *)&user_icmph, msg->msg_iov,
+			     sizeof(struct icmphdr)))
+		return -EFAULT;
+	if (!ping_supported(user_icmph.type, user_icmph.code))
+		return -EINVAL;
+
+	/*
+	 *	Get and verify the address.
+	 */
+
+	if (msg->msg_name) {
+		struct sockaddr_in *usin = (struct sockaddr_in *)msg->msg_name;
+		if (msg->msg_namelen < sizeof(*usin))
+			return -EINVAL;
+		if (usin->sin_family != AF_INET)
+			return -EINVAL;
+		daddr = usin->sin_addr.s_addr;
+		/* no remote port */
+	} else {
+		if (sk->sk_state != TCP_ESTABLISHED)
+			return -EDESTADDRREQ;
+		daddr = inet->inet_daddr;
+		/* no remote port */
+	}
+
+	ipc.addr = inet->inet_saddr;
+	ipc.opt = NULL;
+	ipc.oif = sk->sk_bound_dev_if;
+	ipc.tx_flags = 0;
+	err = sock_tx_timestamp(sk, &ipc.tx_flags);
+	if (err)
+		return err;
+
+	if (msg->msg_controllen) {
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		if (err)
+			return err;
+		if (ipc.opt)
+			free = 1;
+	}
+	if (!ipc.opt) {
+		struct ip_options_rcu *inet_opt;
+
+		rcu_read_lock();
+		inet_opt = rcu_dereference(inet->inet_opt);
+		if (inet_opt) {
+			memcpy(&opt_copy, inet_opt,
+			       sizeof(*inet_opt) + inet_opt->opt.optlen);
+			ipc.opt = &opt_copy.opt;
+		}
+		rcu_read_unlock();
+	}
+
+	saddr = ipc.addr;
+	ipc.addr = faddr = daddr;
+
+	if (ipc.opt && ipc.opt->opt.srr) {
+		if (!daddr)
+			return -EINVAL;
+		faddr = ipc.opt->opt.faddr;
+	}
+	tos = RT_TOS(inet->tos);
+	if (sock_flag(sk, SOCK_LOCALROUTE) ||
+	    (msg->msg_flags & MSG_DONTROUTE) ||
+	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
+		tos |= RTO_ONLINK;
+	}
+
+	if (ipv4_is_multicast(daddr)) {
+		if (!ipc.oif)
+			ipc.oif = inet->mc_index;
+		if (!saddr)
+			saddr = inet->mc_addr;
+	}
+
+	flowi4_init_output(&fl4, ipc.oif, sk->sk_mark, tos,
+			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
+			   inet_sk_flowi_flags(sk), faddr, saddr, 0, 0);
+
+	security_sk_classify_flow(sk, flowi4_to_flowi(&fl4));
+	rt = ip_route_output_flow(net, &fl4, sk);
+	if (IS_ERR(rt)) {
+		err = PTR_ERR(rt);
+		rt = NULL;
+		if (err == -ENETUNREACH)
+			IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+		goto out;
+	}
+
+	err = -EACCES;
+	if ((rt->rt_flags & RTCF_BROADCAST) &&
+	    !sock_flag(sk, SOCK_BROADCAST))
+		goto out;
+
+	if (msg->msg_flags & MSG_CONFIRM)
+		goto do_confirm;
+back_from_confirm:
+
+	if (!ipc.addr)
+		ipc.addr = fl4.daddr;
+
+	lock_sock(sk);
+
+	pfh.icmph.type = user_icmph.type; /* already checked */
+	pfh.icmph.code = user_icmph.code; /* ditto */
+	pfh.icmph.checksum = 0;
+	pfh.icmph.un.echo.id = inet->inet_sport;
+	pfh.icmph.un.echo.sequence = user_icmph.un.echo.sequence;
+	pfh.iov = msg->msg_iov;
+	pfh.wcheck = 0;
+
+	err = ip_append_data(sk, &fl4, ping_getfrag, &pfh, len,
+			0, &ipc, &rt, msg->msg_flags);
+	if (err)
+		ip_flush_pending_frames(sk);
+	else
+		err = ping_push_pending_frames(sk, &pfh, &fl4);
+	release_sock(sk);
+
+out:
+	ip_rt_put(rt);
+	if (free)
+		kfree(ipc.opt);
+	if (!err) {
+		icmp_out_count(sock_net(sk), user_icmph.type);
+		return len;
+	}
+	return err;
+
+do_confirm:
+	dst_confirm(&rt->dst);
+	if (!(msg->msg_flags & MSG_PROBE) || len)
+		goto back_from_confirm;
+	err = 0;
+	goto out;
+}
+
+/*
+ *	IOCTL requests applicable to the UDP^H^H^HICMP protocol
+ */
+
+int ping_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	pr_debug("ping_ioctl(sk=%p,sk->num=%u,cmd=%d,arg=%lu)\n",
+		inet_sk(sk), inet_sk(sk)->inet_num, cmd, arg);
+	switch (cmd) {
+	case SIOCOUTQ:
+	case SIOCINQ:
+		return udp_ioctl(sk, cmd, arg);
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+
+int ping_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		 size_t len, int noblock, int flags, int *addr_len)
+{
+	struct inet_sock *isk = inet_sk(sk);
+	struct sockaddr_in *sin = (struct sockaddr_in *)msg->msg_name;
+	struct sk_buff *skb;
+	int copied, err;
+
+	pr_debug("ping_recvmsg(sk=%p,sk->num=%u)\n", isk, isk->inet_num);
+
+	if (flags & MSG_OOB)
+		goto out;
+
+	if (addr_len)
+		*addr_len = sizeof(*sin);
+
+	if (flags & MSG_ERRQUEUE)
+		return ip_recv_error(sk, msg, len);
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (copied > len) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	/* Don't bother checking the checksum */
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	/* Copy the address. */
+	if (sin) {
+		sin->sin_family = AF_INET;
+		sin->sin_port = 0 /* skb->h.uh->source */;
+		sin->sin_addr.s_addr = ip_hdr(skb)->saddr;
+		memset(sin->sin_zero, 0, sizeof(sin->sin_zero));
+	}
+	if (isk->cmsg_flags)
+		ip_cmsg_recv(msg, skb);
+	err = copied;
+
+done:
+	skb_free_datagram(sk, skb);
+out:
+	pr_debug("ping_recvmsg -> %d\n", err);
+	return err;
+}
+
+static int ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	pr_debug("ping_queue_rcv_skb(sk=%p,sk->num=%d,skb=%p)\n",
+		inet_sk(sk), inet_sk(sk)->inet_num, skb);
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_INERRORS);
+		kfree_skb(skb);
+		pr_debug("ping_queue_rcv_skb -> failed\n");
+		return -1;
+	}
+	return 0;
+}
+
+
+/*
+ *	All we need to do is get the socket.
+ */
+
+void ping_rcv(struct sk_buff *skb)
+{
+	struct sock *sk;
+	struct net *net = dev_net(skb->dev);
+	struct iphdr *iph = ip_hdr(skb);
+	struct icmphdr *icmph = icmp_hdr(skb);
+	u32 saddr = iph->saddr;
+	u32 daddr = iph->daddr;
+
+	/* We assume the packet has already been checked by icmp_rcv */
+
+	pr_debug("ping_rcv(skb=%p,id=%04x,seq=%04x)\n",
+		skb, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+
+	/* Push ICMP header back */
+	skb_push(skb, skb->data - (u8 *)icmph);
+
+	sk = ping_v4_lookup(net, saddr, daddr, ntohs(icmph->un.echo.id),
+			    skb->dev->ifindex);
+	if (sk != NULL) {
+		pr_debug("rcv on socket %p\n", sk);
+		ping_queue_rcv_skb(sk, skb_get(skb));
+		sock_put(sk);
+		return;
+	}
+	pr_debug("no socket, dropping\n");
+
+	/* We're called from icmp_rcv(). kfree_skb() is done there. */
+}
+
+struct proto ping_prot = {
+	.name =		"PING",
+	.owner =	THIS_MODULE,
+	.init =		ping_init_sock,
+	.close =	ping_close,
+	.connect =	ip4_datagram_connect,
+	.disconnect =	udp_disconnect,
+	.ioctl =	ping_ioctl,
+	.setsockopt =	ip_setsockopt,
+	.getsockopt =	ip_getsockopt,
+	.sendmsg =	ping_sendmsg,
+	.recvmsg =	ping_recvmsg,
+	.bind =		ping_bind,
+	.backlog_rcv =	ping_queue_rcv_skb,
+	.hash =		ping_v4_hash,
+	.unhash =	ping_v4_unhash,
+	.get_port =	ping_v4_get_port,
+	.obj_size =	sizeof(struct inet_sock),
+};
+EXPORT_SYMBOL(ping_prot);
+
+#ifdef CONFIG_PROC_FS
+
+static struct sock *ping_get_first(struct seq_file *seq, int start)
+{
+	struct sock *sk;
+	struct ping_iter_state *state = seq->private;
+	struct net *net = seq_file_net(seq);
+
+	for (state->bucket = start; state->bucket < PING_HTABLE_SIZE;
+	     ++state->bucket) {
+		struct hlist_nulls_node *node;
+		struct hlist_nulls_head *hslot = &ping_table.hash[state->bucket];
+
+		if (hlist_nulls_empty(hslot))
+			continue;
+
+		sk_nulls_for_each(sk, node, hslot) {
+			if (net_eq(sock_net(sk), net))
+				goto found;
+		}
+	}
+	sk = NULL;
+found:
+	return sk;
+}
+
+static struct sock *ping_get_next(struct seq_file *seq, struct sock *sk)
+{
+	struct ping_iter_state *state = seq->private;
+	struct net *net = seq_file_net(seq);
+
+	do {
+		sk = sk_nulls_next(sk);
+	} while (sk && (!net_eq(sock_net(sk), net)));
+
+	if (!sk)
+		return ping_get_first(seq, state->bucket + 1);
+	return sk;
+}
+
+static struct sock *ping_get_idx(struct seq_file *seq, loff_t pos)
+{
+	struct sock *sk = ping_get_first(seq, 0);
+
+	if (sk)
+		while (pos && (sk = ping_get_next(seq, sk)) != NULL)
+			--pos;
+	return pos ? NULL : sk;
+}
+
+static void *ping_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	struct ping_iter_state *state = seq->private;
+	state->bucket = 0;
+
+	read_lock_bh(&ping_table.lock);
+
+	return *pos ? ping_get_idx(seq, *pos-1) : SEQ_START_TOKEN;
+}
+
+static void *ping_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct sock *sk;
+
+	if (v == SEQ_START_TOKEN)
+		sk = ping_get_idx(seq, 0);
+	else
+		sk = ping_get_next(seq, v);
+
+	++*pos;
+	return sk;
+}
+
+static void ping_seq_stop(struct seq_file *seq, void *v)
+{
+	read_unlock_bh(&ping_table.lock);
+}
+
+static void ping_format_sock(struct sock *sp, struct seq_file *f,
+		int bucket, int *len)
+{
+	struct inet_sock *inet = inet_sk(sp);
+	__be32 dest = inet->inet_daddr;
+	__be32 src = inet->inet_rcv_saddr;
+	__u16 destp = ntohs(inet->inet_dport);
+	__u16 srcp = ntohs(inet->inet_sport);
+
+	seq_printf(f, "%5d: %08X:%04X %08X:%04X"
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %pK %d%n",
+		bucket, src, srcp, dest, destp, sp->sk_state,
+		sk_wmem_alloc_get(sp),
+		sk_rmem_alloc_get(sp),
+		0, 0L, 0, sock_i_uid(sp), 0, sock_i_ino(sp),
+		atomic_read(&sp->sk_refcnt), sp,
+		atomic_read(&sp->sk_drops), len);
+}
+
+static int ping_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_printf(seq, "%-127s\n",
+			   "  sl  local_address rem_address   st tx_queue "
+			   "rx_queue tr tm->when retrnsmt   uid  timeout "
+			   "inode ref pointer drops");
+	else {
+		struct ping_iter_state *state = seq->private;
+		int len;
+
+		ping_format_sock(v, seq, state->bucket, &len);
+		seq_printf(seq, "%*s\n", 127 - len, "");
+	}
+	return 0;
+}
+
+static const struct seq_operations ping_seq_ops = {
+	.show		= ping_seq_show,
+	.start		= ping_seq_start,
+	.next		= ping_seq_next,
+	.stop		= ping_seq_stop,
+};
+
+static int ping_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &ping_seq_ops,
+			   sizeof(struct ping_iter_state));
+}
+
+static const struct file_operations ping_seq_fops = {
+	.open		= ping_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_net,
+};
+
+static int ping_proc_register(struct net *net)
+{
+	struct proc_dir_entry *p;
+	int rc = 0;
+
+	p = proc_net_fops_create(net, "icmp", S_IRUGO, &ping_seq_fops);
+	if (!p)
+		rc = -ENOMEM;
+	return rc;
+}
+
+static void ping_proc_unregister(struct net *net)
+{
+	proc_net_remove(net, "icmp");
+}
+
+
+static int __net_init ping_proc_init_net(struct net *net)
+{
+	return ping_proc_register(net);
+}
+
+static void __net_exit ping_proc_exit_net(struct net *net)
+{
+	ping_proc_unregister(net);
+}
+
+static struct pernet_operations ping_net_ops = {
+	.init = ping_proc_init_net,
+	.exit = ping_proc_exit_net,
+};
+
+int __init ping_proc_init(void)
+{
+	return register_pernet_subsys(&ping_net_ops);
+}
+
+void ping_proc_exit(void)
+{
+	unregister_pernet_subsys(&ping_net_ops);
+}
+
+#endif
+
+void __init ping_init(void)
+{
+	int i;
+
+	for (i = 0; i < PING_HTABLE_SIZE; i++)
+		INIT_HLIST_NULLS_HEAD(&ping_table.hash[i], i);
+	rwlock_init(&ping_table.lock);
+}
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 321e6e8..28e8273 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -13,6 +13,7 @@
 #include <linux/seqlock.h>
 #include <linux/init.h>
 #include <linux/slab.h>
+#include <linux/nsproxy.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -21,6 +22,7 @@
 #include <net/udp.h>
 #include <net/cipso_ipv4.h>
 #include <net/inet_frag.h>
+#include <net/ping.h>
 
 static int zero;
 static int tcp_retr1_max = 255;
@@ -30,6 +32,8 @@ static int tcp_adv_win_scale_min = -31;
 static int tcp_adv_win_scale_max = 31;
 static int ip_ttl_min = 1;
 static int ip_ttl_max = 255;
+static int ip_ping_group_range_min[] = { 0, 0 };
+static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 
 /* Update system visible IP port range */
 static void set_local_port_range(int range[2])
@@ -68,6 +72,65 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 	return ret;
 }
 
+
+void inet_get_ping_group_range_net(struct net *net, gid_t *low, gid_t *high)
+{
+	gid_t *data = net->ipv4.sysctl_ping_group_range;
+	unsigned seq;
+	do {
+		seq = read_seqbegin(&sysctl_local_ports.lock);
+
+		*low = data[0];
+		*high = data[1];
+	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+}
+
+void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
+{
+	gid_t *data = table->data;
+	unsigned seq;
+	do {
+		seq = read_seqbegin(&sysctl_local_ports.lock);
+
+		*low = data[0];
+		*high = data[1];
+	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+}
+
+/* Update system visible IP port range */
+static void set_ping_group_range(struct ctl_table *table, int range[2])
+{
+	gid_t *data = table->data;
+	write_seqlock(&sysctl_local_ports.lock);
+	data[0] = range[0];
+	data[1] = range[1];
+	write_sequnlock(&sysctl_local_ports.lock);
+}
+
+/* Validate changes from /proc interface. */
+static int ipv4_ping_group_range(ctl_table *table, int write,
+				 void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	gid_t range[2];
+	ctl_table tmp = {
+		.data = &range,
+		.maxlen = sizeof(range),
+		.mode = table->mode,
+		.extra1 = &ip_ping_group_range_min,
+		.extra2 = &ip_ping_group_range_max,
+	};
+
+	inet_get_ping_group_range_table(table, range, range + 1);
+	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
+	if (write && ret == 0)
+		set_ping_group_range(table, range);
+
+	return ret;
+}
+
 static int proc_tcp_congestion_control(ctl_table *ctl, int write,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -677,6 +740,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "ping_group_range",
+		.data		= &init_net.ipv4.sysctl_ping_group_range,
+		.maxlen		= sizeof(init_net.ipv4.sysctl_ping_group_range),
+		.mode		= 0644,
+		.proc_handler	= ipv4_ping_group_range,
+	},
 	{ }
 };
 
@@ -711,8 +781,18 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_icmp_ratemask;
 		table[6].data =
 			&net->ipv4.sysctl_rt_cache_rebuild_count;
+		table[7].data =
+			&net->ipv4.sysctl_ping_group_range;
+
 	}
 
+	/*
+	 * Sane defaults - nobody may create ping sockets.
+	 * Boot scripts should set this to distro-specific group.
+	 */
+	net->ipv4.sysctl_ping_group_range[0] = 1;
+	net->ipv4.sysctl_ping_group_range[1] = 0;
+
 	net->ipv4.sysctl_rt_cache_rebuild_count = 4;
 
 	net->ipv4.ipv4_hdr = register_net_sysctl_table(net,
-- 
1.7.0.4
