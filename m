From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next ] net ipv4: Convert ipv4.ip_local_port_range to be per netns v3
Date: Sat, 28 Sep 2013 14:10:59 -0700
Message-ID: <87bo3c1wkc.fsf_-_@tw-ebiederman.twitter.com>
References: <87fvswt5m5.fsf@tw-ebiederman.twitter.com>
	<5240457D.2050101@6wind.com>
	<8738ovtea9.fsf_-_@tw-ebiederman.twitter.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:50523 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733Ab3I1VNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 17:13:48 -0400
In-Reply-To: <8738ovtea9.fsf_-_@tw-ebiederman.twitter.com> (Eric
	W. Biederman's message of "Mon, 23 Sep 2013 14:32:30 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Move sysctl_local_ports from a global variable into struct netns_ipv4.
- Modify inet_get_local_port_range to take a struct net, and update all
  of the callers.
- Move the initialization of sysctl_local_ports into
   sysctl_net_ipv4.c:ipv4_sysctl_init_net from inet_connection_sock.c

v2:
- Ensure indentation used tabs
- Fixed ip.h so it applies cleanly to todays net-next

v3:
- Compile fixes of strange callers of inet_get_local_port_range.
  This patch now successfully passes an allmodconfig build.
  Removed manual inlining of inet_get_local_port_range in ipv4_local_port_range

Originally-by: Samya <samya@twitter.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/infiniband/core/cma.c   |    2 +-
 drivers/net/vxlan.c             |    2 +-
 include/net/ip.h                |    6 +----
 include/net/netns/ipv4.h        |    6 +++++
 net/ipv4/inet_connection_sock.c |   20 +++++----------
 net/ipv4/inet_hashtables.c      |    2 +-
 net/ipv4/ping.c                 |    4 +--
 net/ipv4/sysctl_net_ipv4.c      |   52 +++++++++++++++++++++++++--------------
 net/ipv4/udp.c                  |    2 +-
 net/openvswitch/vport-vxlan.c   |    2 +-
 net/sctp/socket.c               |    2 +-
 security/selinux/hooks.c        |    2 +-
 12 files changed, 56 insertions(+), 46 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index dab4b41..a082fd9 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2294,7 +2294,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 	int low, high, remaining;
 	unsigned int rover;
 
-	inet_get_local_port_range(&low, &high);
+	inet_get_local_port_range(&init_net, &low, &high);
 	remaining = (high - low) + 1;
 	rover = net_random() % remaining + low;
 retry:
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d1292fe..c376be7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2089,7 +2089,7 @@ static void vxlan_setup(struct net_device *dev)
 	vxlan->age_timer.function = vxlan_cleanup;
 	vxlan->age_timer.data = (unsigned long) vxlan;
 
-	inet_get_local_port_range(&low, &high);
+	inet_get_local_port_range(dev_net(dev), &low, &high);
 	vxlan->port_min = low;
 	vxlan->port_max = high;
 	vxlan->dst_port = htons(vxlan_port);
diff --git a/include/net/ip.h b/include/net/ip.h
index c1f192b..c82e6ec 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -203,11 +203,7 @@ static inline void snmp_mib_free(void __percpu *ptr[SNMP_ARRAY_SZ])
 	}
 }
 
-extern struct local_ports {
-	seqlock_t	lock;
-	int		range[2];
-} sysctl_local_ports;
-void inet_get_local_port_range(int *low, int *high);
+void inet_get_local_port_range(struct net *net, int *low, int *high);
 
 extern unsigned long *sysctl_local_reserved_ports;
 static inline int inet_is_reserved_local_port(int port)
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index bf2ec22..5dbd232 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -15,6 +15,10 @@ struct fib_rules_ops;
 struct hlist_head;
 struct fib_table;
 struct sock;
+struct local_ports {
+	seqlock_t	lock;
+	int		range[2];
+};
 
 struct netns_ipv4 {
 #ifdef CONFIG_SYSCTL
@@ -62,6 +66,8 @@ struct netns_ipv4 {
 	int sysctl_icmp_ratemask;
 	int sysctl_icmp_errors_use_inbound_ifaddr;
 
+	struct local_ports sysctl_local_ports;
+
 	int sysctl_tcp_ecn;
 
 	kgid_t sysctl_ping_group_range[2];
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 6acb541..7ac7aa1 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -29,27 +29,19 @@ const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
 EXPORT_SYMBOL(inet_csk_timer_bug_msg);
 #endif
 
-/*
- * This struct holds the first and last local port number.
- */
-struct local_ports sysctl_local_ports __read_mostly = {
-	.lock = __SEQLOCK_UNLOCKED(sysctl_local_ports.lock),
-	.range = { 32768, 61000 },
-};
-
 unsigned long *sysctl_local_reserved_ports;
 EXPORT_SYMBOL(sysctl_local_reserved_ports);
 
-void inet_get_local_port_range(int *low, int *high)
+void inet_get_local_port_range(struct net *net, int *low, int *high)
 {
 	unsigned int seq;
 
 	do {
-		seq = read_seqbegin(&sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
 
-		*low = sysctl_local_ports.range[0];
-		*high = sysctl_local_ports.range[1];
-	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+		*low = net->ipv4.sysctl_local_ports.range[0];
+		*high = net->ipv4.sysctl_local_ports.range[1];
+	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
 }
 EXPORT_SYMBOL(inet_get_local_port_range);
 
@@ -116,7 +108,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 		int remaining, rover, low, high;
 
 again:
-		inet_get_local_port_range(&low, &high);
+		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 		smallest_rover = rover = net_random() % remaining + low;
 
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7bd8983..2779037 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -494,7 +494,7 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
 		u32 offset = hint + port_offset;
 		struct inet_timewait_sock *tw = NULL;
 
-		inet_get_local_port_range(&low, &high);
+		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 
 		local_bh_disable();
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index d7d9882..fc8c95d 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -237,11 +237,11 @@ static void inet_get_ping_group_range_net(struct net *net, kgid_t *low,
 	unsigned int seq;
 
 	do {
-		seq = read_seqbegin(&sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
 }
 
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 540279f..c08f096 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -43,12 +43,12 @@ static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 
 /* Update system visible IP port range */
-static void set_local_port_range(int range[2])
+static void set_local_port_range(struct net *net, int range[2])
 {
-	write_seqlock(&sysctl_local_ports.lock);
-	sysctl_local_ports.range[0] = range[0];
-	sysctl_local_ports.range[1] = range[1];
-	write_sequnlock(&sysctl_local_ports.lock);
+	write_seqlock(&net->ipv4.sysctl_local_ports.lock);
+	net->ipv4.sysctl_local_ports.range[0] = range[0];
+	net->ipv4.sysctl_local_ports.range[1] = range[1];
+	write_sequnlock(&net->ipv4.sysctl_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
@@ -56,6 +56,8 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 				 void __user *buffer,
 				 size_t *lenp, loff_t *ppos)
 {
+	struct net *net =
+		container_of(table->data, struct net, ipv4.sysctl_local_ports.range);
 	int ret;
 	int range[2];
 	struct ctl_table tmp = {
@@ -66,14 +68,15 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 		.extra2 = &ip_local_port_range_max,
 	};
 
-	inet_get_local_port_range(range, range + 1);
+	inet_get_local_port_range(net, &range[0], &range[1]);
+
 	ret = proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
 
 	if (write && ret == 0) {
 		if (range[1] < range[0])
 			ret = -EINVAL;
 		else
-			set_local_port_range(range);
+			set_local_port_range(net, range);
 	}
 
 	return ret;
@@ -83,23 +86,27 @@ static int ipv4_local_port_range(struct ctl_table *table, int write,
 static void inet_get_ping_group_range_table(struct ctl_table *table, kgid_t *low, kgid_t *high)
 {
 	kgid_t *data = table->data;
+	struct net *net =
+		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
 	unsigned int seq;
 	do {
-		seq = read_seqbegin(&sysctl_local_ports.lock);
+		seq = read_seqbegin(&net->ipv4.sysctl_local_ports.lock);
 
 		*low = data[0];
 		*high = data[1];
-	} while (read_seqretry(&sysctl_local_ports.lock, seq));
+	} while (read_seqretry(&net->ipv4.sysctl_local_ports.lock, seq));
 }
 
 /* Update system visible IP port range */
 static void set_ping_group_range(struct ctl_table *table, kgid_t low, kgid_t high)
 {
 	kgid_t *data = table->data;
-	write_seqlock(&sysctl_local_ports.lock);
+	struct net *net =
+		container_of(table->data, struct net, ipv4.sysctl_ping_group_range);
+	write_seqlock(&net->ipv4.sysctl_local_ports.lock);
 	data[0] = low;
 	data[1] = high;
-	write_sequnlock(&sysctl_local_ports.lock);
+	write_sequnlock(&net->ipv4.sysctl_local_ports.lock);
 }
 
 /* Validate changes from /proc interface. */
@@ -475,13 +482,6 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
-		.procname	= "ip_local_port_range",
-		.data		= &sysctl_local_ports.range,
-		.maxlen		= sizeof(sysctl_local_ports.range),
-		.mode		= 0644,
-		.proc_handler	= ipv4_local_port_range,
-	},
-	{
 		.procname	= "ip_local_reserved_ports",
 		.data		= NULL, /* initialized in sysctl_ipv4_init */
 		.maxlen		= 65536,
@@ -854,6 +854,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "ip_local_port_range",
+		.maxlen		= sizeof(init_net.ipv4.sysctl_local_ports.range),
+		.data		= &init_net.ipv4.sysctl_local_ports.range,
+		.mode		= 0644,
+		.proc_handler	= ipv4_local_port_range,
+	},
+	{
 		.procname	= "tcp_mem",
 		.maxlen		= sizeof(init_net.ipv4.sysctl_tcp_mem),
 		.mode		= 0644,
@@ -888,6 +895,8 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 			&net->ipv4.sysctl_ping_group_range;
 		table[7].data =
 			&net->ipv4.sysctl_tcp_ecn;
+		table[8].data =
+			&net->ipv4.sysctl_local_ports.range;
 
 		/* Don't export sysctls to unprivileged users */
 		if (net->user_ns != &init_user_ns)
@@ -901,6 +910,13 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_ping_group_range[0] = make_kgid(&init_user_ns, 1);
 	net->ipv4.sysctl_ping_group_range[1] = make_kgid(&init_user_ns, 0);
 
+	/*
+	 * Set defaults for local port range
+	 */
+	seqlock_init(&net->ipv4.sysctl_local_ports.lock);
+	net->ipv4.sysctl_local_ports.range[0] =  32768;
+	net->ipv4.sysctl_local_ports.range[1] =  61000;
+
 	tcp_init_mem(net);
 
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74d2c95..460a4c1 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -219,7 +219,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		unsigned short first, last;
 		DECLARE_BITMAP(bitmap, PORTS_PER_CHAIN);
 
-		inet_get_local_port_range(&low, &high);
+		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 
 		rand = net_random();
diff --git a/net/openvswitch/vport-vxlan.c b/net/openvswitch/vport-vxlan.c
index a481c03..56e22b7 100644
--- a/net/openvswitch/vport-vxlan.c
+++ b/net/openvswitch/vport-vxlan.c
@@ -173,7 +173,7 @@ static int vxlan_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	skb->local_df = 1;
 
-	inet_get_local_port_range(&port_min, &port_max);
+	inet_get_local_port_range(net, &port_min, &port_max);
 	src_port = vxlan_src_port(port_min, port_max, skb);
 
 	err = vxlan_xmit_skb(vxlan_port->vs, rt, skb,
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 911b71b..72046b9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5890,7 +5890,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 		int low, high, remaining, index;
 		unsigned int rover;
 
-		inet_get_local_port_range(&low, &high);
+		inet_get_local_port_range(sock_net(sk), &low, &high);
 		remaining = (high - low) + 1;
 		rover = net_random() % remaining + low;
 
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index a5091ec..568c769 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3929,7 +3929,7 @@ static int selinux_socket_bind(struct socket *sock, struct sockaddr *address, in
 		if (snum) {
 			int low, high;
 
-			inet_get_local_port_range(&low, &high);
+			inet_get_local_port_range(sock_net(sk), &low, &high);
 
 			if (snum < max(PROT_SOCK, low) || snum > high) {
 				err = sel_netport_sid(sk->sk_protocol,
-- 
1.7.10.4
