From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [RFC] ipv4: add ICMP socket kind
Date: Tue, 21 Dec 2010 21:18:00 +0300
Message-ID: <20101221181800.GA8166@albatros>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>,
	Solar Designer <solar@openwall.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patch adds IPPROTO_ICMP socket kind.  It makes it possible to send
ICMP_ECHO messages and receive corresponding ICMP_ECHOREPLY messages
without any special privileges.  In other words, the patch makes it
possible to implement setuid-less /bin/ping.

A new ping socket is created with

    socket(PF_INET, SOCK_DGRAM, IPPROTO_ICMP)

Message identifiers (octets 4-5 of ICMP header) are interpreted as local
ports. Addresses are stored in struct sockaddr_in. No port numbers are
reserved for privileged processes, port 0 is reserved for API ("let the
kernel pick a free number"). There is no notion of remote ports, remote
port numbers provided by the user (e.g. in connect()) are ignored.

Data sent and received include ICMP headers. This is deliberate to:
1) Avoid the need to transport headers values like sequence numbers by other means
2) Make it easier to port existing programs using raw sockets.

ICMP headers given to send() are checked and sanitized. The type
must be ICMP_ECHO and the code must be zero (future extensions might relax
this, see below). The id is set to the number (local port) of the socket,
the checksum is always recomputed.

ICMP reply packets received from the network are demultiplexed according
to their id's and returned by recv() without any modifications.
IP header information and ICMP errors of those packets may be obtained
via ancillary data (IP_RECVTTL, IP_RETOPTS, and IP_RECVERR). ICMP source
quenches and redirects are reported as fake errors via the error queue
(IP_RECVERR); the next hop address for redirects is saved to ee_info (in
network order).

The existing code might be (in the unlikely case anyone needs it)
extended rather easily to handle other similar pairs of ICMP messages
(Timestamp/Reply, Information Request/Reply, Address Mask Request/Reply
etc.).


Userspace ping util & patch for it:
ftp://mirrors.kernel.org/openwall/Owl/current/sources/Owl/packages/iputils/iputils-ss020927.tar.gz
ftp://ftp.intelib.org/pub/segoon/iputils-ss020927-pingsock.diff


Similar functionality is implemented in Mac OS X: 
http://www.manpagez.com/man/4/icmp/


TODO: implement ICMPv6 sockets.


All ping options (-b, -p, -Q, -R, -s, -t, -T, -M, -I), are tested with
the patch.

Tested with 2K "ping -i0.2" running on Core i7 (8 cores), Load average = 80,
and with 20 simultanious "ping -c1", each for half an hour.


Initially this functionality was written by Pavel Kankovsky for linux
2.4.32, but unfortunately it was never made public.


All comments are appreciated, especially about:

1) locking (get_port, lookup, unhash) - IMO ping sockets are too rarely
  used to optimise it.
2) necessity of ICMP_TIMESTAMP, ICMP_INFO_REQUEST, ICMP_ADDRESS - does
  anybody use it nowadays?
3) whether it's better to stay in net/ipv4/ping.c or move to net/ipv4/icmp.c

Signed-off-by: Vasiliy Kulikov <segoon@openwall.com>
Signed-off-by: Pavel Kankovsky <peak@argo.troja.mff.cuni.cz>
--
diff --git a/include/net/ping.h b/include/net/ping.h
new file mode 100644
index 0000000..96ba9e8
--- /dev/null
+++ b/include/net/ping.h
@@ -0,0 +1,68 @@
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
+#ifdef CONFIG_IP_PING_DEBUG
+#define ping_debug(fmt, x...) printk(KERN_INFO fmt, ## x)
+#else
+#define ping_debug(fmt, x...) do {} while (0)
+#endif
+
+/* PING_HTABLE_SIZE must be power of 2 */
+#define PING_HTABLE_SIZE 	64
+#define PING_HTABLE_MASK 	(PING_HTABLE_SIZE-1)
+
+#define ping_portaddr_for_each_entry(__sk, node, list) \
+	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_node)
+
+#define MAX_PING_IDENT 	65536
+
+
+struct ping_hslot {
+	struct hlist_nulls_head	head;
+} __attribute__((aligned(2 * sizeof(long))));
+
+struct ping_table {
+	struct ping_hslot	hash[PING_HTABLE_SIZE];
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
+#ifdef CONFIG_IP_PING
+#define icmp_echoreply ping_rcv
+#else
+#define icmp_echoreply icmp_discard
+#endif
+
+extern void ping_rcv(struct sk_buff *);
+extern void ping_err(struct sk_buff *, u32 info);
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
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 9e95d7f..5cb13a3 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -14,6 +14,27 @@ config IP_MULTICAST
 	  <file:Documentation/networking/multicast.txt>. For most people, it's
 	  safe to say N.
 
+config IP_PING
+	bool "IP: ping socket"
+	depends on EXPERIMENTAL
+	help
+	  This option introduces a new kind of sockets - "ping sockets".
+
+	  A ping socket makes it possible to send ICMP Echo messages and receive
+	  corresponding ICMP Echo Reply messages without any special privileges.
+	  In other words, it makes is possible to implement setuid-less /bin/ping.
+
+	  A new ping socket is created with socket(PF_INET, SOCK_DGRAM, PROT_ICMP).
+
+config IP_PING_DEBUG
+	bool "IP: ping socket debug output"
+	depends on IP_PING
+	default n
+	help
+	  Enable the inclusion of debug code in the ICMP ping sockets.
+	  Be aware that doing this will impact performance.
+	  If unsure say N.
+
 config IP_ADVANCED_ROUTER
 	bool "IP: advanced router"
 	---help---
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 4978d22..3a37479 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_IP_FIB_TRIE) += fib_trie.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
 obj-$(CONFIG_IP_MROUTE) += ipmr.o
+obj-$(CONFIG_IP_PING) += ping.o
 obj-$(CONFIG_NET_IPIP) += ipip.o
 obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
 obj-$(CONFIG_NET_IPGRE) += ip_gre.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f581f77..bbe5eb3 100644
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
@@ -992,6 +993,16 @@ static struct inet_protosw inetsw_array[] =
 		.flags =      INET_PROTOSW_PERMANENT,
        },
 
+#ifdef CONFIG_IP_PING
+       {
+		.type =       SOCK_DGRAM,
+		.protocol =   IPPROTO_ICMP,
+		.prot =       &ping_prot,
+		.ops =        &inet_dgram_ops,
+		.no_check =   UDP_CSUM_DEFAULT,
+		.flags =      INET_PROTOSW_REUSE,
+       },
+#endif
 
        {
 	       .type =       SOCK_RAW,
@@ -1520,6 +1531,9 @@ static const struct net_protocol udp_protocol = {
 
 static const struct net_protocol icmp_protocol = {
 	.handler =	icmp_rcv,
+#ifdef CONFIG_IP_PING
+	.err_handler =	ping_err,
+#endif
 	.no_policy =	1,
 	.netns_ok =	1,
 };
@@ -1635,6 +1649,12 @@ static int __init inet_init(void)
 	if (rc)
 		goto out_unregister_udp_proto;
 
+#ifdef CONFIG_IP_PING
+	rc = proto_register(&ping_prot, 1);
+	if (rc)
+		goto out_unregister_raw_proto;
+#endif
+
 	/*
 	 *	Tell SOCKET that we are alive...
 	 */
@@ -1690,6 +1710,10 @@ static int __init inet_init(void)
 	/* Add UDP-Lite (RFC 3828) */
 	udplite4_register();
 
+#ifdef CONFIG_IP_PING
+	ping_init();
+#endif
+
 	/*
 	 *	Set the ICMP layer up
 	 */
@@ -1720,6 +1744,10 @@ static int __init inet_init(void)
 	rc = 0;
 out:
 	return rc;
+#ifdef CONFIG_IP_PING
+out_unregister_raw_proto:
+	proto_unregister(&raw_prot);
+#endif
 out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
@@ -1744,11 +1772,19 @@ static int __init ipv4_proc_init(void)
 		goto out_tcp;
 	if (udp4_proc_init())
 		goto out_udp;
+#ifdef CONFIG_IP_PING
+	if (ping_proc_init())
+		goto out_ping;
+#endif
 	if (ip_misc_proc_init())
 		goto out_misc;
 out:
 	return rc;
 out_misc:
+#ifdef CONFIG_IP_PING
+	ping_proc_exit();
+out_ping:
+#endif
 	udp4_proc_exit();
 out_udp:
 	tcp4_proc_exit();
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index e5d1a44..83232e2 100644
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
@@ -808,6 +809,17 @@ static void icmp_redirect(struct sk_buff *skb)
 			       iph->saddr, skb->dev);
 		break;
 	}
+
+#ifdef CONFIG_IP_PING
+	/* Ping wants to see redirects.
+         * Let's pretend they are errors of sorts... */
+	if (iph->protocol == IPPROTO_ICMP &&
+	    iph->ihl >= 5 &&
+	    pskb_may_pull(skb, (iph->ihl<<2)+8)) {
+		ping_err(skb, icmp_hdr(skb)->un.gateway);
+	}
+#endif
+
 out:
 	return;
 out_err:
@@ -1068,7 +1080,7 @@ error:
  */
 static const struct icmp_control icmp_pointers[NR_ICMP_TYPES + 1] = {
 	[ICMP_ECHOREPLY] = {
-		.handler = icmp_discard,
+		.handler = icmp_echoreply,
 	},
 	[1] = {
 		.handler = icmp_discard,
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
new file mode 100644
index 0000000..8a769ce
--- /dev/null
+++ b/net/ipv4/ping.c
@@ -0,0 +1,894 @@
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
+ * Authors:	Vasiliy Kulikov,
+ *		Pavel Kankovsky (for 2.4.32)
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
+	ping_debug("hash(%d) = %d\n", num, res);
+	return res;
+}
+
+static inline struct ping_hslot *ping_hashslot(struct ping_table *table,
+					     struct net *net, unsigned num)
+{
+	return &table->hash[ping_hashfn(net, num, PING_HTABLE_MASK)];
+}
+
+static int ping_v4_get_port(struct sock *sk, unsigned short ident)
+{
+	struct hlist_nulls_node *node;
+	struct ping_hslot *hlist;
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
+			ping_portaddr_for_each_entry(sk2, node, &hlist->head) {
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
+		ping_portaddr_for_each_entry(sk2, node, &hlist->head) {
+			isk2 = inet_sk(sk2);
+
+			if ((isk2->inet_num == ident) &&
+			    (sk2 != sk) &&
+			    (!sk2->sk_reuse || !sk->sk_reuse))
+				goto fail;
+		}
+	}
+
+	ping_debug("found port/ident = %d\n", ident);
+	isk->inet_num = ident;
+	if (sk_unhashed(sk)) {
+		ping_debug("was not hashed\n");
+		sock_hold(sk);
+		hlist_nulls_add_head(&sk->sk_nulls_node, &hlist->head);
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
+	ping_debug("ping_v4_hash(sk->port=%u)\n", inet_sk(sk)->inet_num);
+	BUG(); /* "Please do not press this button again." */
+}
+
+static void ping_v4_unhash(struct sock *sk)
+{
+	struct inet_sock *isk = inet_sk(sk);
+	ping_debug("ping_v4_unhash(isk=%p,isk->num=%u)\n", isk, isk->inet_num);
+	if (sk_hashed(sk)) {
+		struct ping_hslot *hslot;
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
+	struct ping_hslot *hslot = ping_hashslot(&ping_table, net, ident);
+	struct sock *sk = NULL;
+	struct inet_sock *isk;
+	struct hlist_nulls_node *hnode;
+
+	ping_debug("try to find: num = %d, daddr = %ld, dif = %d\n",
+			 (int)ident, (unsigned long)daddr, dif);
+	read_lock_bh(&ping_table.lock);
+
+	ping_portaddr_for_each_entry(sk, hnode, &hslot->head) {
+		isk = inet_sk(sk);
+
+		ping_debug("found: %p: num = %d, daddr = %ld, dif = %d\n", sk,
+			 (int)isk->inet_num, (unsigned long)isk->inet_rcv_saddr,
+			 sk->sk_bound_dev_if);
+
+		ping_debug("iterate\n");
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
+static void ping_close(struct sock *sk, long timeout)
+{
+	ping_debug("ping_close(sk=%p,sk->num=%u)\n",
+		inet_sk(sk), inet_sk(sk)->inet_num);
+	ping_debug("isk->refcnt = %d\n", sk->sk_refcnt.counter);
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
+	ping_debug("ping_v4_bind(sk=%p,sa_addr=%08x,sa_port=%d)\n",
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
+	ping_debug("after bind(): num = %d, daddr = %ld, dif = %d\n",
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
+	ping_debug("ping_v4_bind -> %d\n", err);
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
+	ping_debug("ping_err(type=%04x,code=%04x,id=%04x,seq=%04x)\n", type,
+		code, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+
+	sk = ping_v4_lookup(net, iph->daddr, iph->saddr,
+			    ntohs(icmph->un.echo.id), skb->dev->ifindex);
+	if (sk == NULL) {
+		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
+		ping_debug("no socket, dropping\n");
+		return;	/* No socket for error */
+	}
+	ping_debug("err on socket %p\n", sk);
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
+		pfh->wcheck = csum_partial((char *)&pfh->icmph,
+			sizeof(struct icmphdr), pfh->wcheck);
+		pfh->icmph.checksum = csum_fold(pfh->wcheck);
+		memcpy(to, &pfh->icmph, sizeof(struct icmphdr));
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
+int ping_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		 size_t len)
+{
+	struct inet_sock *isk = inet_sk(sk);
+	struct ipcm_cookie ipc;
+	struct icmphdr user_icmph;
+	struct pingfakehdr pfh;
+	struct rtable *rt = NULL;
+	int free = 0;
+	u32 saddr, daddr;
+	u8  tos;
+	int err;
+
+	ping_debug("ping_sendmsg(sk=%p,sk->num=%u)\n", isk, isk->inet_num);
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
+		daddr = isk->inet_daddr;
+		/* no remote port */
+	}
+
+	ipc.addr = isk->inet_saddr;
+	ipc.opt = NULL;
+	ipc.oif = sk->sk_bound_dev_if;
+
+	if (msg->msg_controllen) {
+		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
+		if (err)
+			return err;
+		if (ipc.opt)
+			free = 1;
+	}
+	if (!ipc.opt)
+		ipc.opt = isk->opt;
+
+	saddr = ipc.addr;
+	ipc.addr = daddr;
+
+	if (ipc.opt && ipc.opt->srr) {
+		if (!daddr)
+			return -EINVAL;
+		daddr = ipc.opt->faddr;
+	}
+	tos = RT_TOS(isk->tos);
+	if (sock_flag(sk, SOCK_LOCALROUTE) ||
+	    (msg->msg_flags&MSG_DONTROUTE) ||
+	    (ipc.opt && ipc.opt->is_strictroute)) {
+		tos |= RTO_ONLINK;
+	}
+
+	if (ipv4_is_multicast(daddr)) {
+		if (!ipc.oif)
+			ipc.oif = isk->mc_index;
+		if (!saddr)
+			saddr = isk->mc_addr;
+	}
+
+	{
+		struct flowi fl = { .oif = ipc.oif,
+				    .mark = sk->sk_mark,
+				    .nl_u = { .ip4_u = {
+						.daddr = daddr,
+						.saddr = saddr,
+						.tos = tos } },
+				    .proto = IPPROTO_ICMP,
+				    .flags = inet_sk_flowi_flags(sk),
+		};
+
+		struct net *net = sock_net(sk);
+
+		security_sk_classify_flow(sk, &fl);
+		err = ip_route_output_flow(net, &rt, &fl, sk, 1);
+		if (err) {
+			if (err == -ENETUNREACH)
+				IP_INC_STATS_BH(net, IPSTATS_MIB_OUTNOROUTES);
+			goto out;
+		}
+
+		err = -EACCES;
+		if ((rt->rt_flags & RTCF_BROADCAST) &&
+		    !sock_flag(sk, SOCK_BROADCAST))
+			goto out;
+	}
+
+	if (msg->msg_flags & MSG_CONFIRM)
+		goto do_confirm;
+back_from_confirm:
+
+	if (!ipc.addr)
+		ipc.addr = rt->rt_dst;
+
+	lock_sock(sk);
+
+	pfh.icmph.type = user_icmph.type; /* already checked */
+	pfh.icmph.code = user_icmph.code; /* dtto */
+	pfh.icmph.checksum = 0;
+	pfh.icmph.un.echo.id = isk->inet_sport;
+	pfh.icmph.un.echo.sequence = user_icmph.un.echo.sequence;
+	pfh.iov = msg->msg_iov;
+	pfh.wcheck = 0;
+
+	err = ip_append_data(sk, ping_getfrag, &pfh, len,
+			0, &ipc, &rt,
+			msg->msg_flags);
+	if (err)
+		ip_flush_pending_frames(sk);
+	else
+		err = ip_push_pending_frames(sk);
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
+	ping_debug("ping_ioctl(sk=%p,sk->num=%u,cmd=%d,arg=%lu)\n",
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
+	ping_debug("ping_recvmsg(sk=%p,sk->num=%u)\n", isk, isk->inet_num);
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
+	ping_debug("ping_recvmsg -> %d\n", err);
+	return err;
+}
+
+static int ping_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	ping_debug("ping_queue_rcv_skb(sk=%p,sk->num=%d,skb=%p)\n",
+		inet_sk(sk), inet_sk(sk)->inet_num, skb);
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		ICMP_INC_STATS_BH(sock_net(sk), ICMP_MIB_INERRORS);
+		kfree_skb(skb);
+		ping_debug("ping_queue_rcv_skb -> failed\n");
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
+	ping_debug("ping_rcv(skb=%p,id=%04x,seq=%04x)\n",
+		skb, ntohs(icmph->un.echo.id), ntohs(icmph->un.echo.sequence));
+
+	/* Push ICMP header back */
+	skb_push(skb, skb->data - (u8 *)icmph);
+
+	sk = ping_v4_lookup(net, saddr, daddr, ntohs(icmph->un.echo.id),
+			    skb->dev->ifindex);
+	if (sk != NULL) {
+		ping_debug("rcv on socket %p\n", sk);
+		ping_queue_rcv_skb(sk, skb_get(skb));
+		sock_put(sk);
+		return;
+	}
+	ping_debug("no socket, dropping\n");
+
+	/* We're called from icmp_rcv(). kfree_skb() is done there. */
+}
+
+struct proto ping_prot = {
+	.name =		"PING",
+	.owner =	THIS_MODULE,
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
+		struct ping_hslot *hslot = &ping_table.hash[state->bucket];
+
+		if (hlist_nulls_empty(&hslot->head))
+			continue;
+
+		sk_nulls_for_each(sk, node, &hslot->head) {
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
+		" %02X %08X:%08X %02X:%08lX %08X %5d %8d %lu %d %p %d%n",
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
+static struct seq_operations ping_seq_ops = {
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
+static struct file_operations ping_seq_fops = {
+	.owner		= THIS_MODULE,
+	.open		= ping_seq_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= seq_release_net,
+};
+
+static const char ping_proc_name[] = "icmp";
+
+static int ping_proc_register(struct net *net)
+{
+	struct proc_dir_entry *p;
+	int rc = 0;
+
+	p = proc_create_data(ping_proc_name, S_IRUGO, net->proc_net,
+			     &ping_seq_fops, NULL);
+	if (!p)
+		rc = -ENOMEM;
+	return rc;
+}
+
+static void ping_proc_unregister(struct net *net)
+{
+	proc_net_remove(net, ping_proc_name);
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
+		INIT_HLIST_NULLS_HEAD(&ping_table.hash[i].head, i);
+	rwlock_init(&ping_table.lock);
+}
-- 
Vasiliy
