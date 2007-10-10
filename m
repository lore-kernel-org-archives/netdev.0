From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] more robust inet range checking
Date: Wed, 10 Oct 2007 10:09:39 -0700
Message-ID: <20071010100939.0783febb@freepuppy.rosehill>
References: <20071010141530.GA10661@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: aarapov@redhat.com, netdev@vger.kernel.org, den@openvz.org
To: "Denis V. Lunev" <den@openvz.org>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52625 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751036AbXJJRKE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 13:10:04 -0400
In-Reply-To: <20071010141530.GA10661@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

More complete version of local port range checking.

1. Enforce that low < high when setting.
2. Use seqlock to ensure atomic update.
3. Add port randomization to SCTP. This is a new feature but
   easier than maintaining old code that was broken if range
   changed.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/infiniband/core/cma.c   |   24 ++++++------
 include/net/ip.h                |    3 +
 net/ipv4/inet_connection_sock.c |   26 ++++++++++---
 net/ipv4/inet_hashtables.c      |   13 +++---
 net/ipv4/sysctl_net_ipv4.c      |   77 ++++++++++++++++++++++++++++++++++++----
 net/ipv4/tcp_ipv4.c             |    1 
 net/ipv4/udp.c                  |   18 ++++-----
 net/ipv6/inet6_hashtables.c     |   13 +++---
 net/sctp/protocol.c             |    1 
 net/sctp/socket.c               |   26 ++++---------
 security/selinux/hooks.c        |   37 ++++++++++---------
 11 files changed, 157 insertions(+), 82 deletions(-)

--- a/include/net/ip.h	2007-10-10 08:26:57.000000000 -0700
+++ b/include/net/ip.h	2007-10-10 09:35:26.000000000 -0700
@@ -171,7 +171,8 @@ extern unsigned long snmp_fold_field(voi
 extern int snmp_mib_init(void *ptr[2], size_t mibsize, size_t mibalign);
 extern void snmp_mib_free(void *ptr[2]);
 
-extern int sysctl_local_port_range[2];
+extern void inet_get_local_port_range(int range[2]);
+
 extern int sysctl_ip_default_ttl;
 extern int sysctl_ip_nonlocal_bind;
 
--- a/net/ipv4/inet_connection_sock.c	2007-10-10 09:29:03.000000000 -0700
+++ b/net/ipv4/inet_connection_sock.c	2007-10-10 09:52:49.000000000 -0700
@@ -33,6 +33,19 @@ EXPORT_SYMBOL(inet_csk_timer_bug_msg);
  * This array holds the first and last local port number.
  */
 int sysctl_local_port_range[2] = { 32768, 61000 };
+DEFINE_SEQLOCK(sysctl_port_range_lock);
+
+void inet_get_local_port_range(int range[2])
+{
+	unsigned seq;
+	do {
+		seq = read_seqbegin(&sysctl_port_range_lock);
+
+		range[0] = sysctl_local_port_range[0];
+		range[1] = sysctl_local_port_range[1];
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
+		int remaining, range[2], rover;
+
+		inet_get_local_port_range(range);
+		remaining = range[1] - range[0];
+		rover = net_random() % (range[1] - range[0]) + range[0];
 
 		do {
 			head = &hashinfo->bhash[inet_bhashfn(rover, hashinfo->bhash_size)];
@@ -91,8 +105,8 @@ int inet_csk_get_port(struct inet_hashin
 			break;
 		next:
 			spin_unlock(&head->lock);
-			if (++rover > high)
-				rover = low;
+			if (++rover > range[1])
+				rover = range[0];
 		} while (--remaining > 0);
 
 		/* Exhausted local port range during search?  It is not
--- a/net/ipv4/inet_hashtables.c	2007-10-10 09:27:02.000000000 -0700
+++ b/net/ipv4/inet_hashtables.c	2007-10-10 09:40:39.000000000 -0700
@@ -279,19 +279,18 @@ int inet_hash_connect(struct inet_timewa
 	int ret;
 
 	if (!snum) {
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int range = high - low;
-		int i;
-		int port;
+		int i, count, range[2], port;
 		static u32 hint;
 		u32 offset = hint + inet_sk_port_offset(sk);
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw = NULL;
 
+		inet_get_local_port_range(range);
+		count = range[1] - range[0];
+
 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
+		for (i = 1; i <= count; i++) {
+			port = range[0] + (i + offset) % count;
 			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
 			spin_lock(&head->lock);
 
--- a/net/ipv4/sysctl_net_ipv4.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/ipv4/sysctl_net_ipv4.c	2007-10-10 09:46:12.000000000 -0700
@@ -12,6 +12,7 @@
 #include <linux/sysctl.h>
 #include <linux/igmp.h>
 #include <linux/inetdevice.h>
+#include <linux/seqlock.h>
 #include <net/snmp.h>
 #include <net/icmp.h>
 #include <net/ip.h>
@@ -25,8 +26,6 @@ extern int sysctl_ip_nonlocal_bind;
 #ifdef CONFIG_SYSCTL
 static int zero;
 static int tcp_retr1_max = 255;
-static int ip_local_port_range_min[] = { 1, 1 };
-static int ip_local_port_range_max[] = { 65535, 65535 };
 #endif
 
 struct ipv4_config ipv4_config;
@@ -89,6 +88,74 @@ static int ipv4_sysctl_forward_strategy(
 	return 1;
 }
 
+extern seqlock_t sysctl_port_range_lock;
+extern int sysctl_local_port_range[2];
+
+static int local_min_port[2] = { 1, 1 };
+static int local_max_port[2] = { 65535, 65535 };
+
+static void set_local_port_range(const int range[2])
+{
+	write_seqlock(&sysctl_port_range_lock);
+	sysctl_local_port_range[0] = range[0];
+	sysctl_local_port_range[1] = range[1];
+	write_sequnlock(&sysctl_port_range_lock);
+}
+
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
+		.extra1 = &local_min_port,
+		.extra2 = &local_max_port,
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
+		.extra1 = &local_min_port,
+		.extra2 = &local_max_port,
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
@@ -427,10 +494,8 @@ ctl_table ipv4_table[] = {
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
--- a/net/ipv4/tcp_ipv4.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/ipv4/tcp_ipv4.c	2007-10-10 09:41:16.000000000 -0700
@@ -2470,6 +2470,5 @@ EXPORT_SYMBOL(tcp_v4_syn_recv_sock);
 EXPORT_SYMBOL(tcp_proc_register);
 EXPORT_SYMBOL(tcp_proc_unregister);
 #endif
-EXPORT_SYMBOL(sysctl_local_port_range);
 EXPORT_SYMBOL(sysctl_tcp_low_latency);
 
--- a/net/ipv4/udp.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/ipv4/udp.c	2007-10-10 09:44:35.000000000 -0700
@@ -147,13 +147,13 @@ int __udp_lib_get_port(struct sock *sk, 
 	write_lock_bh(&udp_hash_lock);
 
 	if (!snum) {
-		int i;
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
+		int i, range[2];
 		unsigned rover, best, best_size_so_far;
 
+		inet_get_local_port_range(range);
+
 		best_size_so_far = UINT_MAX;
-		best = rover = net_random() % (high - low) + low;
+		best = rover = net_random() % (range[1] - range[0]) + range[0];
 
 		/* 1st pass: look for empty (or shortest) hash chain */
 		for (i = 0; i < UDP_HTABLE_SIZE; i++) {
@@ -171,11 +171,9 @@ int __udp_lib_get_port(struct sock *sk, 
 			best = rover;
 		next:
 			/* fold back if end of range */
-			if (++rover > high)
-				rover = low + ((rover - low)
+			if (++rover > range[1])
+				rover = range[0] + ((rover - range[0])
 					       & (UDP_HTABLE_SIZE - 1));
-
-
 		}
 
 		/* 2nd pass: find hole in shortest hash chain */
@@ -184,8 +182,8 @@ int __udp_lib_get_port(struct sock *sk, 
 			if (! __udp_lib_lport_inuse(rover, udptable))
 				goto gotit;
 			rover += UDP_HTABLE_SIZE;
-			if (rover > high)
-				rover = low + ((rover - low)
+			if (rover > range[1])
+				rover = range[0] + ((rover - range[0])
 					       & (UDP_HTABLE_SIZE - 1));
 		}
 
--- a/net/ipv6/inet6_hashtables.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/ipv6/inet6_hashtables.c	2007-10-10 09:39:48.000000000 -0700
@@ -254,18 +254,19 @@ int inet6_hash_connect(struct inet_timew
 	int ret;
 
 	if (snum == 0) {
-		const int low = sysctl_local_port_range[0];
-		const int high = sysctl_local_port_range[1];
-		const int range = high - low;
-		int i, port;
+		int range[2];
+		int i, port, count;
 		static u32 hint;
 		const u32 offset = hint + inet6_sk_port_offset(sk);
 		struct hlist_node *node;
 		struct inet_timewait_sock *tw = NULL;
 
+		inet_get_local_port_range(range);
+		count = range[1] - range[0];
+
 		local_bh_disable();
-		for (i = 1; i <= range; i++) {
-			port = low + (i + offset) % range;
+		for (i = 1; i <= count; i++) {
+			port = range[0] + (i + offset) % count;
 			head = &hinfo->bhash[inet_bhashfn(port, hinfo->bhash_size)];
 			spin_lock(&head->lock);
 
--- a/security/selinux/hooks.c	2007-10-10 08:27:01.000000000 -0700
+++ b/security/selinux/hooks.c	2007-10-10 09:50:09.000000000 -0700
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
+			int range[2];
+
+			inet_get_local_port_range(range);
+
+			if (snum < max(PROT_SOCK, range[0]) || snum > range[1]) {
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
--- a/drivers/infiniband/core/cma.c	2007-10-10 08:26:39.000000000 -0700
+++ b/drivers/infiniband/core/cma.c	2007-10-10 10:01:10.000000000 -0700
@@ -1866,13 +1866,14 @@ err1:
 static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list;
-	int port, ret;
+	int port, ret, range[2];
 
 	bind_list = kzalloc(sizeof *bind_list, GFP_KERNEL);
 	if (!bind_list)
 		return -ENOMEM;
 
 retry:
+	/* FIXME: add proper port randomization */
 	do {
 		ret = idr_get_new_above(ps, bind_list, next_port, &port);
 	} while ((ret == -EAGAIN) && idr_pre_get(ps, GFP_KERNEL));
@@ -1880,18 +1881,20 @@ retry:
 	if (ret)
 		goto err1;
 
-	if (port > sysctl_local_port_range[1]) {
-		if (next_port != sysctl_local_port_range[0]) {
+	inet_get_local_port_range(range);
+
+	if (port > range[1]) {
+		if (next_port != range[0]) {
 			idr_remove(ps, port);
-			next_port = sysctl_local_port_range[0];
+			next_port = range[0];
 			goto retry;
 		}
 		ret = -EADDRNOTAVAIL;
 		goto err2;
 	}
 
-	if (port == sysctl_local_port_range[1])
-		next_port = sysctl_local_port_range[0];
+	if (port == range[1])
+		next_port = range[0];
 	else
 		next_port = port + 1;
 
@@ -2769,12 +2772,11 @@ static void cma_remove_one(struct ib_dev
 
 static int cma_init(void)
 {
-	int ret;
+	int ret, range[2];
+
+	inet_get_local_port_range(range);
+	next_port = net_random() % (range[1] - range[0]) + range[0];
 
-	get_random_bytes(&next_port, sizeof next_port);
-	next_port = ((unsigned int) next_port %
-		    (sysctl_local_port_range[1] - sysctl_local_port_range[0])) +
-		    sysctl_local_port_range[0];
 	cma_wq = create_singlethread_workqueue("rdma_cm");
 	if (!cma_wq)
 		return -ENOMEM;
--- a/net/sctp/protocol.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/sctp/protocol.c	2007-10-10 09:58:21.000000000 -0700
@@ -1173,7 +1173,6 @@ SCTP_STATIC __init int sctp_init(void)
 	}
 
 	spin_lock_init(&sctp_port_alloc_lock);
-	sctp_port_rover = sysctl_local_port_range[0] - 1;
 
 	printk(KERN_INFO "SCTP: Hash tables configured "
 			 "(established %d bind %d)\n",
--- a/net/sctp/socket.c	2007-10-10 08:27:00.000000000 -0700
+++ b/net/sctp/socket.c	2007-10-10 10:01:42.000000000 -0700
@@ -5314,26 +5314,19 @@ static long sctp_get_port_local(struct s
 	sctp_local_bh_disable();
 
 	if (snum == 0) {
-		/* Search for an available port.
-		 *
-		 * 'sctp_port_rover' was the last port assigned, so
-		 * we start to search from 'sctp_port_rover +
-		 * 1'. What we do is first check if port 'rover' is
-		 * already in the hash table; if not, we use that; if
-		 * it is, we try next.
-		 */
-		int low = sysctl_local_port_range[0];
-		int high = sysctl_local_port_range[1];
-		int remaining = (high - low) + 1;
-		int rover;
-		int index;
+		/* Search for an available port. */
+		int index, rover, remaining, range[2];
+
+		inet_get_local_port_range(range);
+		remaining = range[1] - range[0];
+		rover = net_random() % remaining + range[0];
 
 		sctp_spin_lock(&sctp_port_alloc_lock);
-		rover = sctp_port_rover;
 		do {
 			rover++;
-			if ((rover < low) || (rover > high))
-				rover = low;
+			if ((rover < range[0]) || (rover > range[1]))
+				rover = range[0];
+
 			index = sctp_phashfn(rover);
 			head = &sctp_port_hashtable[index];
 			sctp_spin_lock(&head->lock);
@@ -5344,7 +5337,6 @@ static long sctp_get_port_local(struct s
 		next:
 			sctp_spin_unlock(&head->lock);
 		} while (--remaining > 0);
-		sctp_port_rover = rover;
 		sctp_spin_unlock(&sctp_port_alloc_lock);
 
 		/* Exhausted local port range during search? */
