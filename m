From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net-next 1/2] ipv4: move local_port_range out of CONFIG_SYSCTL
Date: Tue,  6 May 2014 11:02:49 -0700
Message-ID: <1399399370-7849-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:37353 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886AbaEFSDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 14:03:02 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so11665901pab.27
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 11:03:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

When CONFIG_SYSCTL is not set, ip_local_port_range should still work,
just that no one can change it. Therefore we should move it out of sysctl_inet.c.
Also, rename it to ->ip_local_ports instead.

Cc: David S. Miller <davem@davemloft.net>
Cc: Francois Romieu <romieu@fr.zoreil.com>
Reported-by: Stefan de Konink <stefan@konink.de>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/netns/ipv4.h        |  2 +-
 net/ipv4/af_inet.c              | 28 ++++++++++++++++++++++++++++
 net/ipv4/inet_connection_sock.c |  8 ++++----
 net/ipv4/ping.c                 |  4 ++--
 net/ipv4/sysctl_net_ipv4.c      | 29 +++++++++++------------------
 5 files changed, 46 insertions(+), 25 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 80f500a..3d95cd4 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -66,7 +66,7 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
 
-	struct local_ports sysctl_local_ports;
+	struct local_ports ip_local_ports;
 
 	int sysctl_tcp_ecn;
 	int sysctl_ip_no_pmtu_disc;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8c54870..cccc8e4 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1650,6 +1650,31 @@ static int __init init_ipv4_mibs(void)
 	return register_pernet_subsys(&ipv4_mib_ops);
 }
 
+static __net_init int inet_init_net(struct net *net)
+{
+	/*
+	 * Set defaults for local port range
+	 */
+	seqlock_init(&net->ipv4.ip_local_ports.lock);
+	net->ipv4.ip_local_ports.range[0] =  32768;
+	net->ipv4.ip_local_ports.range[1] =  61000;
+	return 0;
+}
+
+static __net_exit void inet_exit_net(struct net *net)
+{
+}
+
+static __net_initdata struct pernet_operations af_inet_ops = {
+	.init = inet_init_net,
+	.exit = inet_exit_net,
+};
+
+static int __init init_inet_pernet_ops(void)
+{
+	return register_pernet_subsys(&af_inet_ops);
+}
+
 static int ipv4_proc_init(void);
 
 /*
@@ -1794,6 +1819,9 @@ static int __init inet_init(void)
 	if (ip_mr_init())
 		pr_crit("%s: Cannot init ipv4 mroute\n", __func__);
 #endif
+
+	if (init_inet_pernet_ops())
+		pr_crit("%s: Cannot init ipv4 inet pernet ops\n", __func__);
 	/*
 	 *	Initialise per-cpu ipv4 mibs
 	 */
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0d1e2cb..a56b8e6 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -37,11 +37,11 @@ void inet_get_local_port_range(struct net *net, int *low, int *high)
 	unsigned int seq;
 
 	do {
-		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
 
-		*low = net->ipv4.sysctl_local_ports.range[0];
-		*high = net->ipv4.sysctl_local_ports.range[1];
-	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
+		*low = net->ipv4.ip_local_ports.range[0];
+		*high = net->ipv4.ip_local_ports.range[1];
+	} while (read_seqretry(&net->ipv4.ip_local_ports.lock, seq));
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 8210964..347bdde 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -240,11 +240,11 @@ static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
 	unsigned int seq;
 
 	do {
-		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.ip_local_ports.lock, seq));
 }
 
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44eba05..a116c41 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -45,10 +45,10 @@ static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
 {
-	write_seqlock(&net->ipv4.sysctl_local_ports.lock);
-	net->ipv4.sysctl_local_ports.range[0] = range[0];
-	net->ipv4.sysctl_local_ports.range[1] = range[1];
-	write_sequnlock(&net->ipv4.sysctl_local_ports.lock);
+	write_seqlock(&net->ipv4.ip_local_ports.lock);
+	net->ipv4.ip_local_ports.range[0] = range[0];
+	net->ipv4.ip_local_ports.range[1] = range[1];
+	write_sequnlock(&net->ipv4.ip_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
@@ -57,7 +57,7 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 				 size_t *lenp, loff_t *ppos)
 {
 	struct net *net =
-		container_of(table->data, struct net, ipv4.sysctl_local_ports.range);
+		container_of(table->data, struct net, ipv4.ip_local_ports.range);
 	int ret;
 	int range[2];
 	struct ctl_table tmp = {
@@ -90,11 +90,11 @@ static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low
 		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
 	unsigned int seq;
 	do {
-		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.ip_local_ports.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.ip_local_ports.lock, seq));
 }
 
 /* Update system visible IP port range */
@@ -103,10 +103,10 @@ static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t hig
 	kgid_t *data = table->data;
 	struct net *net =
 		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
-	write_seqlock(&net->ipv4.sysctl_local_ports.lock);
+	write_seqlock(&net->ipv4.ip_local_ports.lock);
 	data[0] = low;
 	data[1] = high;
-	write_sequnlock(&net->ipv4.sysctl_local_ports.lock);
+	write_sequnlock(&net->ipv4.ip_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
@@ -819,8 +819,8 @@ static struct ctl_table ipv4_net_table[] = {
 	},
 	{
 		.procname	= "ip_local_port_range",
-		.maxlen		= sizeof(init_net.ipv4.sysctl_local_ports.range),
-		.data		= &init_net.ipv4.sysctl_local_ports.range,
+		.maxlen		= sizeof(init_net.ipv4.ip_local_ports.range),
+		.data		= &init_net.ipv4.ip_local_ports.range,
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
@@ -865,13 +865,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
 	net->ipv4.sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
 
-	/*
-	 * Set defaults for local port range
-	 */
-	seqlock_init(&net->ipv4.sysctl_local_ports.lock);
-	net->ipv4.sysctl_local_ports.range[0] =  32768;
-	net->ipv4.sysctl_local_ports.range[1] =  61000;
-
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
-- 
1.8.3.1
