From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/2] ip: local port range robustness
Date: Wed, 10 Oct 2007 17:00:22 -0700
Message-ID: <20071011000042.692751658@linux-foundation.org>
References: <20071011000020.907277335@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:39084 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755286AbXJKAEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 20:04:22 -0400
Content-Disposition: inline; filename=port-validate.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Expansion of original idea from Denis V. Lunev <den@openvz.org>

Add robustness and locking to the local_port_range sysctl.
1. Enforce that low < high when setting.
2. Use seqlock to ensure atomic update.

The locking might seem like overkill, but there are
cases where sysadmin might want to change value in the
middle of a DoS attack.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/infiniband/core/cma.c   |   22 ++++++-----
 include/net/ip.h                |    3 +
 net/ipv4/inet_connection_sock.c |   22 +++++++++--
 net/ipv4/inet_hashtables.c      |   13 +++---
 net/ipv4/sysctl_net_ipv4.c      |   75 +++++++++++++++++++++++++++++++++++++---
 net/ipv4/tcp_ipv4.c             |    1 
 net/ipv4/udp.c                  |    6 +--
 net/ipv6/inet6_hashtables.c     |   12 +++---
 net/sctp/socket.c               |   11 +++--
 security/selinux/hooks.c        |   39 +++++++++++---------
 10 files changed, 146 insertions(+), 58 deletions(-)

--- a/include/net/ip.h	2007-10-10 15:27:44.000000000 -0700
+++ b/include/net/ip.h	2007-10-10 15:27:48.000000000 -0700
@@ -171,7 +171,8 @@ extern unsigned long snmp_fold_field(voi
 extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
 extern void snmp_mib_free(void *ptr[2]);
 
-extern int sysctl_local_port_range[2];
+extern void inet_get_local_port_range(int *low, int *high);
+
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
--- a/net/ipv4/inet_connection_sock.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv4/inet_connection_sock.c	2007-10-10 15:27:48.000000000 -0700
@@ -33,6 +33,19 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  * This array holds the first and last local port number.
  */
 int sysctl_local_port_range[2] = { 32768, 61000 };
+DEFINE_SEQLOCK(sysctl_port_range_lock);
+
+void inet_get_local_port_range(int *low, int *high)
+{
+	unsigned seq;
+	do {
+		seq = read_seqbegin(&sysctl_port_range_lock);
+
+		*low = sysctl_local_port_range[0];
+		*high = sysctl_local_port_range[1];
+	} while (read_seqretry(&sysctl_port_range_lock, seq));
+}
+EXPORT_SYMBOL(inet_get_local_port_range);
 
 int inet_csk_bind_conflict(const struct sock *sk,
 			   const struct inet_bind_bucket *tb)
@@ -77,10 +90,11 @@ int inet_csk_get_port(struct inet_hashin
 
 	local_bh_disable();
 	if (!snum) {
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int remaining = (high - low) + 1;
-		int rover = net_random() % (high - low) + low;
+		int remaining, rover, low, high;
+
+		inet_get_local_port_range(&low, &high);
+		remaining = high - low;
+		rover = net_random() % remaining + low;
 
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
--- a/net/ipv4/inet_hashtables.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv4/inet_hashtables.c	2007-10-10 15:27:48.000000000 -0700
@@ -279,19 +279,18 @@ int inet_hash_connect(struct inet_timewa
 	int ret;
 
 	if (!snum) {
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int range = high - low;
-		int i;
-		int port;
+		int i, remaining, low, high, port;
 		static u32 hint;
 		u32 offset = hint + inet_sk_port_offset(sk);
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw = NULL;
 
+		inet_get_local_port_range(&low, &high);
+		remaining = high - low;
+
 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
+		for (i = 1; i <= remaining; i++) {
+			port = low + (i + offset) % remaining;
 			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
 			spin_lock(&head->lock);
 
--- a/net/ipv4/sysctl_net_ipv4.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv4/sysctl_net_ipv4.c	2007-10-10 16:53:16.000000000 -0700
@@ -12,6 +12,7 @@
 #include <linux/sysctl.h>
 #include <linux/igmp.h>
 #include <linux/inetdevice.h>
+#include <linux/seqlock.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -89,6 +90,74 @@ static int ipv4_sysctl_forward_strategy(
 	return 1;
 }
 
+extern seqlock_t sysctl_port_range_lock;
+extern int sysctl_local_port_range[2];
+
+/* Update system visible IP port range */
+static void set_local_port_range(int range[2])
+{
+	write_seqlock(&sysctl_port_range_lock);
+	sysctl_local_port_range[0] = range[0];
+	sysctl_local_port_range[1] = range[1];
+	write_sequnlock(&sysctl_port_range_lock);
+}
+
+/* Validate changes from /proc interface. */
+static int ipv4_local_port_range(ctl_table *table, int write, struct file *filp,
+				 void __user *buffer,
+				 size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int range[2] = { sysctl_local_port_range[0],
+			 sysctl_local_port_range[1] };
+	ctl_table tmp = {
+		.data = &range,
+		.maxlen = sizeof(range),
+		.mode = table->mode,
+		.extra1 = &ip_local_port_range_min,
+		.extra2 = &ip_local_port_range_max,
+	};
+
+	ret = proc_dointvec_minmax(&tmp, write, filp, buffer, lenp, ppos);
+
+	if (write && ret == 0) {
+		if (range[1] <= range[0])
+			ret = -EINVAL;
+		else
+			set_local_port_range(range);
+	}
+
+	return ret;
+}
+
+/* Validate changes from sysctl interface. */
+static int ipv4_sysctl_local_port_range(ctl_table *table, int __user *name,
+					 int nlen, void __user *oldval,
+					 size_t __user *oldlenp,
+					void __user *newval, size_t newlen)
+{
+	int ret;
+	int range[2] = { sysctl_local_port_range[0],
+			 sysctl_local_port_range[1] };
+	ctl_table tmp = {
+		.data = &range,
+		.maxlen = sizeof(range),
+		.mode = table->mode,
+		.extra1 = &ip_local_port_range_min,
+		.extra2 = &ip_local_port_range_max,
+	};
+
+	ret = sysctl_intvec(&tmp, name, nlen, oldval, oldlenp, newval, newlen);
+	if (ret == 0 && newval && newlen) {
+		if (range[1] <= range[0])
+			ret = -EINVAL;
+		else
+			set_local_port_range(range);
+	}
+	return ret;
+}
+
+
 static int proc_tcp_congestion_control(ctl_table *ctl, int write, struct file * filp,
 				       void __user *buffer, size_t *lenp, loff_t *ppos)
 {
@@ -427,10 +496,8 @@ ctl_table ipv4_table[] = {
 		.data		= &sysctl_local_port_range,
 		.maxlen		= sizeof(sysctl_local_port_range),
 		.mode		= 0644,
-		.proc_handler	= &proc_dointvec_minmax,
-		.strategy	= &sysctl_intvec,
-		.extra1		= ip_local_port_range_min,
-		.extra2		= ip_local_port_range_max
+		.proc_handler	= &ipv4_local_port_range,
+		.strategy	= &ipv4_sysctl_local_port_range,
 	},
 	{
 		.ctl_name	= NET_IPV4_ICMP_ECHO_IGNORE_ALL,
--- a/net/ipv4/tcp_ipv4.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2007-10-10 15:27:48.000000000 -0700
@@ -2470,6 +2470,5 @@ EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 EXPORT_SYMBOL(tcp_proc_register);
 EXPORT_SYMBOL(tcp_proc_unregister);
 #endif
-EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
--- a/net/ipv4/udp.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv4/udp.c	2007-10-10 16:56:16.000000000 -0700
@@ -147,11 +147,11 @@ int __udp_lib_get_port(struct sock *sk, 
 	write_lock_bh(&udp_hash_lock);
 
 	if (!snum) {
-		int i;
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
+		int i, low, high;
 		unsigned rover, best, best_size_so_far;
 
+		inet_get_local_port_range(&low, &high);
+
 		best_size_so_far = UINT_MAX;
 		best = rover = net_random() % (high - low) + low;
 
--- a/net/ipv6/inet6_hashtables.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/ipv6/inet6_hashtables.c	2007-10-10 15:27:48.000000000 -0700
@@ -254,18 +254,18 @@ int inet6_hash_connect(struct inet_timew
 	int ret;
 
 	if (snum == 0) {
-		const int low = sysctl_local_port_range[0];
-		const int high = sysctl_local_port_range[1];
-		const int range = high - low;
-		int i, port;
+		int i, port, low, high, remaining;
 		static u32 hint;
 		const u32 offset = hint + inet6_sk_port_offset(sk);
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw = NULL;
 
+		inet_get_local_port_range(&low, &high);
+		remaining = high - low;
+
 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
+		for (i = 1; i <= remaining; i++) {
+			port = low + (i + offset) % remaining;
 			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
 			spin_lock(&head->lock);
 
--- a/security/selinux/hooks.c	2007-10-10 15:27:44.000000000 -0700
+++ b/security/selinux/hooks.c	2007-10-10 15:27:48.000000000 -0700
@@ -47,7 +47,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/tty.h>
 #include <net/icmp.h>
-#include <net/ip.h>		/* for sysctl_local_port_range[] */
+#include <net/ip.h>		/* for local_port_range[] */
 #include <net/tcp.h>		/* struct or_callable used in sock_rcv_skb */
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
@@ -3232,8 +3232,6 @@ static int selinux_socket_post_create(st
 /* Range of port numbers used to automatically bind.
    Need to determine whether we should perform a name_bind
    permission check between the socket and the port number. */
-#define ip_local_port_range_0 sysctl_local_port_range[0]
-#define ip_local_port_range_1 sysctl_local_port_range[1]
 
 static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, int addrlen)
 {
@@ -3276,20 +3274,27 @@ static int selinux_socket_bind(struct so
 			addrp = (char *)&addr6->sin6_addr.s6_addr;
 		}
 
-		if (snum&&(snum < max(PROT_SOCK,ip_local_port_range_0) ||
-			   snum > ip_local_port_range_1)) {
-			err = security_port_sid(sk->sk_family, sk->sk_type,
-						sk->sk_protocol, snum, &sid);
-			if (err)
-				goto out;
-			AVC_AUDIT_DATA_INIT(&ad,NET);
-			ad.u.net.sport = htons(snum);
-			ad.u.net.family = family;
-			err = avc_has_perm(isec->sid, sid,
-					   isec->sclass,
-					   SOCKET__NAME_BIND, &ad);
-			if (err)
-				goto out;
+		if (snum) {
+			int low, high;
+
+			inet_get_local_port_range(&low, &high);
+
+			if (snum < max(PROT_SOCK, low) || snum > high) {
+				err = security_port_sid(sk->sk_family,
+							sk->sk_type,
+							sk->sk_protocol, snum,
+							&sid);
+				if (err)
+					goto out;
+				AVC_AUDIT_DATA_INIT(&ad,NET);
+				ad.u.net.sport = htons(snum);
+				ad.u.net.family = family;
+				err = avc_has_perm(isec->sid, sid,
+						   isec->sclass,
+						   SOCKET__NAME_BIND, &ad);
+				if (err)
+					goto out;
+			}
 		}
 		
 		switch(isec->sclass) {
--- a/drivers/infiniband/core/cma.c	2007-10-10 15:27:44.000000000 -0700
+++ b/drivers/infiniband/core/cma.c	2007-10-10 15:27:48.000000000 -0700
@@ -1866,13 +1866,14 @@ err1:
 static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list;
-	int port, ret;
+	int port, ret, low, high;
 
 	bind_list = kzalloc(sizeof *bind_list, GFP_KERNEL);
 	if (!bind_list)
 		return -ENOMEM;
 
 retry:
+	/* FIXME: add proper port randomization per like inet_csk_get_port */
 	do {
 		ret = idr_get_new_above(ps, bind_list, next_port, &port);
 	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
@@ -1880,18 +1881,19 @@ retry:
 	if (ret)
 		goto err1;
 
-	if (port > sysctl_local_port_range[1]) {
-		if (next_port != sysctl_local_port_range[0]) {
+	inet_get_local_port_range(&low, &high);
+	if (port > high) {
+		if (next_port != low) {
 			idr_remove(ps, port);
-			next_port = sysctl_local_port_range[0];
+			next_port = low;
 			goto retry;
 		}
 		ret = -EADDRNOTAVAIL;
 		goto err2;
 	}
 
-	if (port == sysctl_local_port_range[1])
-		next_port = sysctl_local_port_range[0];
+	if (port == high)
+		next_port = low;
 	else
 		next_port = port + 1;
 
@@ -2769,12 +2771,12 @@ static void cma_remove_one(struct ib_dev
 
 static int cma_init(void)
 {
-	int ret;
+	int ret, low, high;
 
 	get_random_bytes(&next_port, sizeof next_port);
-	next_port = ((unsigned int) next_port %
-		    (sysctl_local_port_range[1] - sysctl_local_port_range[0])) +
-		    sysctl_local_port_range[0];
+	inet_get_local_port_range(&low, &high);
+	next_port = ((unsigned int) next_port % (high - low)) + low;
+
 	cma_wq = create_singlethread_workqueue("rdma_cm");
 	if (!cma_wq)
 		return -ENOMEM;
--- a/net/sctp/socket.c	2007-10-10 15:27:44.000000000 -0700
+++ b/net/sctp/socket.c	2007-10-10 15:27:48.000000000 -0700
@@ -5315,11 +5315,12 @@ static long sctp_get_port_local(struct s
 
 	if (snum == 0) {
 		/* Search for an available port. */
-		unsigned int low = sysctl_local_port_range[0];
-		unsigned int high = sysctl_local_port_range[1];
-		unsigned int remaining = (high - low) + 1;
-		unsigned int rover = net_random() % remaining + low;
-		int index;
+		int low, high, remaining, index;
+		unsigned int rover;
+
+		inet_get_local_port_range(&low, &high);
+		remaining = (high - low) + 1;
+		rover = net_random() % remaining + low;
 
 		do {
 			rover++;

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

