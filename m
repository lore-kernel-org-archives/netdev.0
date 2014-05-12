From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv4: make ip_local_reserved_ports per netns
Date: Mon, 12 May 2014 16:04:53 -0700
Message-ID: <1399935893-15874-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35165 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751712AbaELXFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 19:05:05 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb1so9470482pad.9
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 16:05:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_local_port_range is already per netns, so should ip_local_reserved_ports
be. And since it is none by default we don't actually need it when we don't
enable CONFIG_SYSCTL.

By the way, rename inet_is_reserved_local_port() to inet_is_local_reserved_port()

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/ip.h                | 14 +++++++++++---
 include/net/netns/ipv4.h        |  4 ++++
 kernel/sysctl.c                 |  4 ++--
 net/ipv4/af_inet.c              |  8 +-------
 net/ipv4/inet_connection_sock.c |  5 +----
 net/ipv4/inet_hashtables.c      |  2 +-
 net/ipv4/sysctl_net_ipv4.c      | 31 ++++++++++++++-----------------
 net/ipv4/udp.c                  |  2 +-
 net/sctp/socket.c               |  5 +++--
 9 files changed, 38 insertions(+), 37 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 5575298..cc352c5 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -208,11 +208,19 @@ static inline u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_o
 
 void inet_get_local_port_range(struct net *net, int *low, int *high);
 
-extern unsigned long *sysctl_local_reserved_ports;
-static inline int inet_is_reserved_local_port(int port)
+#if CONFIG_SYSCTL
+static inline int inet_is_local_reserved_port(struct net *net, int port)
 {
-	return test_bit(port, sysctl_local_reserved_ports);
+	if (!net->ipv4.sysctl_local_reserved_ports)
+		return 0;
+	return test_bit(port, net->ipv4.sysctl_local_reserved_ports);
 }
+#else
+static inline int inet_is_local_reserved_port(struct net *net, int port)
+{
+	return 0;
+}
+#endif
 
 extern int sysctl_ip_nonlocal_bind;
 
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b2704fd0..c854c08 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -81,6 +81,10 @@ struct netns_ipv4 {
 
 	atomic_t dev_addr_genid;
 
+#ifdef CONFIG_SYSCTL
+	unsigned long *sysctl_local_reserved_ports;
+#endif
+
 #ifdef CONFIG_IP_MROUTE
 #ifndef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	struct mr_table		*mrt;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 74f5b58..e36ae4b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2501,11 +2501,11 @@ int proc_do_large_bitmap(struct ctl_table *table, int write,
 	bool first = 1;
 	size_t left = *lenp;
 	unsigned long bitmap_len = table->maxlen;
-	unsigned long *bitmap = (unsigned long *) table->data;
+	unsigned long *bitmap = *(unsigned long **) table->data;
 	unsigned long *tmp_bitmap = NULL;
 	char tr_a[] = { '-', ',', '\n' }, tr_b[] = { ',', '\n', 0 }, c;
 
-	if (!bitmap_len || !left || (*ppos && !write)) {
+	if (!bitmap || !bitmap_len || !left || (*ppos && !write)) {
 		*lenp = 0;
 		return 0;
 	}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 211c0cc..279132b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1705,13 +1705,9 @@ static int __init inet_init(void)
 
 	BUILD_BUG_ON(sizeof(struct inet_skb_parm) > FIELD_SIZEOF(struct sk_buff, cb));
 
-	sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
-	if (!sysctl_local_reserved_ports)
-		goto out;
-
 	rc = proto_register(&tcp_prot, 1);
 	if (rc)
-		goto out_free_reserved_ports;
+		goto out;
 
 	rc = proto_register(&udp_prot, 1);
 	if (rc)
@@ -1821,8 +1817,6 @@ out_unregister_udp_proto:
 	proto_unregister(&udp_prot);
 out_unregister_tcp_proto:
 	proto_unregister(&tcp_prot);
-out_free_reserved_ports:
-	kfree(sysctl_local_reserved_ports);
 	goto out;
 }
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index a56b8e6..216fd6a 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -29,9 +29,6 @@ const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
 EXPORT_SYMBOL(inet_csk_timer_bug_msg);
 #endif
 
-unsigned long *sysctl_local_reserved_ports;
-EXPORT_SYMBOL(sysctl_local_reserved_ports);
-
 void inet_get_local_port_range(struct net *net, int *low, int *high)
 {
 	unsigned int seq;
@@ -113,7 +110,7 @@ again:
 
 		smallest_size = -1;
 		do {
-			if (inet_is_reserved_local_port(rover))
+			if (inet_is_local_reserved_port(net, rover))
 				goto next_nolock;
 			head = &hashinfo->bhash[inet_bhashfn(net, rover,
 					hashinfo->bhash_size)];
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8b9cf27..83331f1 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -500,7 +500,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		local_bh_disable();
 		for (i = 1; i <= remaining; i++) {
 			port = low + (i + offset) % remaining;
-			if (inet_is_reserved_local_port(port))
+			if (inet_is_local_reserved_port(net, port))
 				continue;
 			head = &hinfo->bhash[inet_bhashfn(net, port,
 					hinfo->bhash_size)];
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 5cde8f2..e8cfe31 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -437,13 +437,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "ip_local_reserved_ports",
-		.data		= NULL, /* initialized in sysctl_ipv4_init */
-		.maxlen		= 65536,
-		.mode		= 0644,
-		.proc_handler	= proc_do_large_bitmap,
-	},
-	{
 		.procname	= "igmp_max_memberships",
 		.data		= &sysctl_igmp_max_memberships,
 		.maxlen		= sizeof(int),
@@ -825,6 +818,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= ipv4_local_port_range,
 	},
 	{
+		.procname	= "ip_local_reserved_ports",
+		.data		= &init_net.ipv4.sysctl_local_reserved_ports,
+		.maxlen		= 65536,
+		.mode		= 0644,
+		.proc_handler	= proc_do_large_bitmap,
+	},
+	{
 		.procname	= "ip_no_pmtu_disc",
 		.data		= &init_net.ipv4.sysctl_ip_no_pmtu_disc,
 		.maxlen		= sizeof(int),
@@ -862,8 +862,14 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
 
+	net->ipv4.sysctl_local_reserved_ports = kzalloc(65536 / 8, GFP_KERNEL);
+	if (!net->ipv4.sysctl_local_reserved_ports)
+		goto err_ports;
+
 	return 0;
 
+err_ports:
+	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
 err_reg:
 	if (!net_eq(net, &init_net))
 		kfree(table);
@@ -875,6 +881,7 @@ static __net_exit void ipv4_sysctl_exit_net(struct net *net)
 {
 	struct ctl_table *table;
 
+	kfree(net->ipv4.sysctl_local_reserved_ports);
 	table = net->ipv4.ipv4_hdr->ctl_table_arg;
 	unregister_net_sysctl_table(net->ipv4.ipv4_hdr);
 	kfree(table);
@@ -888,16 +895,6 @@ static __net_initdata struct pernet_operations ipv4_sysctl_ops = {
 static __init int sysctl_ipv4_init(void)
 {
 	struct ctl_table_header *hdr;
-	struct ctl_table *i;
-
-	for (i = ipv4_table; i->procname; i++) {
-		if (strcmp(i->procname, "ip_local_reserved_ports") == 0) {
-			i->data = sysctl_local_reserved_ports;
-			break;
-		}
-	}
-	if (!i->procname)
-		return -EINVAL;
 
 	hdr = register_net_sysctl(&init_net, "net/ipv4", ipv4_table);
 	if (hdr == NULL)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 54ea0a3..6729ea9 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -246,7 +246,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 			do {
 				if (low <= snum && snum <= high &&
 				    !test_bit(snum >> udptable->log, bitmap) &&
-				    !inet_is_reserved_local_port(snum))
+				    !inet_is_local_reserved_port(net, snum))
 					goto found;
 				snum += rand;
 			} while (snum != first);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index e37b2cb..2af76ea 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5946,8 +5946,9 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		/* Search for an available port. */
 		int low, high, remaining, index;
 		unsigned int rover;
+		struct net *net = sock_net(sk);
 
-		inet_get_local_port_range(sock_net(sk), &low, &high);
+		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 		rover = prandom_u32() % remaining + low;
 
@@ -5955,7 +5956,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 			rover++;
 			if ((rover < low) || (rover > high))
 				rover = low;
-			if (inet_is_reserved_local_port(rover))
+			if (inet_is_local_reserved_port(net, rover))
 				continue;
 			index = sctp_phashfn(sock_net(sk), rover);
 			head = &sctp_port_hashtable[index];
-- 
1.8.3.1
