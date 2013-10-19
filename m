From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: [PATCH 3/6] tcp_memcontrol: Remove the per netns control.
Date: Sat, 19 Oct 2013 16:25:36 -0700
Message-ID: <878uxohmhb.fsf@xmission.com>
References: <87r4bghml4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87r4bghml4.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Sat, 19 Oct 2013 16:23:19 -0700")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


The code that is implemented is per memory cgroup not per netns, and
having per netns bits is just confusing.  Remove the per netns bits to
make it easier to see what is really going on.

Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
---
 include/net/netns/ipv4.h   |    1 -
 include/net/tcp.h          |    3 +--
 net/ipv4/af_inet.c         |    2 --
 net/ipv4/sysctl_net_ipv4.c |   23 +++++++----------------
 net/ipv4/tcp.c             |   12 +++++++-----
 net/ipv4/tcp_ipv4.c        |    1 +
 net/ipv4/tcp_memcontrol.c  |   10 ++++------
 net/ipv6/af_inet6.c        |    2 --
 net/ipv6/tcp_ipv6.c        |    1 +
 9 files changed, 21 insertions(+), 34 deletions(-)

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 5dbd232e12ff..ee520cba2ec2 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -71,7 +71,6 @@ struct netns_ipv4 {
 	int sysctl_tcp_ecn;
 
 	kgid_t sysctl_ping_group_range[2];
-	long sysctl_tcp_mem[3];
 
 	atomic_t dev_addr_genid;
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 372dcccfeed0..81242e04c1b3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -259,6 +259,7 @@ extern int sysctl_tcp_max_orphans;
 extern int sysctl_tcp_fack;
 extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_dsack;
+extern long sysctl_tcp_mem[3];
 extern int sysctl_tcp_wmem[3];
 extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
@@ -348,8 +349,6 @@ extern struct proto tcp_prot;
 #define TCP_ADD_STATS_USER(net, field, val) SNMP_ADD_STATS_USER((net)->mib.tcp_statistics, field, val)
 #define TCP_ADD_STATS(net, field, val)	SNMP_ADD_STATS((net)->mib.tcp_statistics, field, val)
 
-void tcp_init_mem(struct net *net);
-
 void tcp_tasklet_init(void);
 
 void tcp_v4_err(struct sk_buff *skb, u32);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 35913fb77dc8..aa16213adbd0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1706,8 +1706,6 @@ static int __init inet_init(void)
 	ip_static_sysctl_init();
 #endif
 
-	tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
-
 	/*
 	 *	Add all the base protocols.
 	 */
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 5f0bb8786929..635dd4d5edcf 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -200,14 +200,6 @@ static int proc_allowed_congestion_control(struct ctl_table *ctl,
 	return ret;
 }
 
-static int ipv4_tcp_mem(struct ctl_table *ctl, int write,
-			   void __user *buffer, size_t *lenp,
-			   loff_t *ppos)
-{
-	ctl->data = &current->nsproxy->net_ns->ipv4.sysctl_tcp_mem;
-	return proc_doulongvec_minmax(ctl, write, buffer, lenp, ppos);
-}
-
 static int proc_tcp_fastopen_key(struct ctl_table *ctl, int write,
 				 void __user *buffer, size_t *lenp,
 				 loff_t *ppos)
@@ -517,6 +509,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec
 	},
 	{
+		.procname	= "tcp_mem",
+		.maxlen		= sizeof(sysctl_tcp_mem),
+		.data		= &sysctl_tcp_mem,
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
+	{
 		.procname	= "tcp_wmem",
 		.data		= &sysctl_tcp_wmem,
 		.maxlen		= sizeof(sysctl_tcp_wmem),
@@ -825,12 +824,6 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= ipv4_local_port_range,
 	},
-	{
-		.procname	= "tcp_mem",
-		.maxlen		= sizeof(init_net.ipv4.sysctl_tcp_mem),
-		.mode		= 0644,
-		.proc_handler	= ipv4_tcp_mem,
-	},
 	{ }
 };
 
@@ -882,8 +875,6 @@ static __net_init int ipv4_sysctl_init_net(struct net *net)
 	net->ipv4.sysctl_local_ports.range[0] =  32768;
 	net->ipv4.sysctl_local_ports.range[1] =  61000;
 
-	tcp_init_mem(net);
-
 	net->ipv4.ipv4_hdr = register_net_sysctl(net, "net/ipv4", table);
 	if (net->ipv4.ipv4_hdr == NULL)
 		goto err_reg;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index be4b161802e8..8e8529d3c8c9 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -288,9 +288,11 @@ int sysctl_tcp_min_tso_segs __read_mostly = 2;
 struct percpu_counter tcp_orphan_count;
 EXPORT_SYMBOL_GPL(tcp_orphan_count);
 
+long sysctl_tcp_mem[3] __read_mostly;
 int sysctl_tcp_wmem[3] __read_mostly;
 int sysctl_tcp_rmem[3] __read_mostly;
 
+EXPORT_SYMBOL(sysctl_tcp_mem);
 EXPORT_SYMBOL(sysctl_tcp_rmem);
 EXPORT_SYMBOL(sysctl_tcp_wmem);
 
@@ -3097,13 +3099,13 @@ static int __init set_thash_entries(char *str)
 }
 __setup("thash_entries=", set_thash_entries);
 
-void tcp_init_mem(struct net *net)
+static void tcp_init_mem(void)
 {
 	unsigned long limit = nr_free_buffer_pages() / 8;
 	limit = max(limit, 128UL);
-	net->ipv4.sysctl_tcp_mem[0] = limit / 4 * 3;
-	net->ipv4.sysctl_tcp_mem[1] = limit;
-	net->ipv4.sysctl_tcp_mem[2] = net->ipv4.sysctl_tcp_mem[0] * 2;
+	sysctl_tcp_mem[0] = limit / 4 * 3;
+	sysctl_tcp_mem[1] = limit;
+	sysctl_tcp_mem[2] = sysctl_tcp_mem[0] * 2;
 }
 
 void __init tcp_init(void)
@@ -3165,7 +3167,7 @@ void __init tcp_init(void)
 	sysctl_tcp_max_orphans = cnt / 2;
 	sysctl_max_syn_backlog = max(128, cnt / 256);
 
-	tcp_init_mem(&init_net);
+	tcp_init_mem();
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
 	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 7);
 	max_wshare = min(4UL*1024*1024, limit);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 114d1b748cbb..300ab2c93f29 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2749,6 +2749,7 @@ struct proto tcp_prot = {
 	.orphan_count		= &tcp_orphan_count,
 	.memory_allocated	= &tcp_memory_allocated,
 	.memory_pressure	= &tcp_memory_pressure,
+	.sysctl_mem		= sysctl_tcp_mem,
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index e7c01fcf5716..86feaa0d6d70 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -29,7 +29,6 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	struct cg_proto *cg_proto, *parent_cg;
 	struct tcp_memcontrol *tcp;
 	struct mem_cgroup *parent = parent_mem_cgroup(memcg);
-	struct net *net = current->nsproxy->net_ns;
 
 	cg_proto = tcp_prot.proto_cgroup(memcg);
 	if (!cg_proto)
@@ -37,9 +36,9 @@ int tcp_init_cgroup(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 
 	tcp = tcp_from_cgproto(cg_proto);
 
-	tcp->tcp_prot_mem[0] = net->ipv4.sysctl_tcp_mem[0];
-	tcp->tcp_prot_mem[1] = net->ipv4.sysctl_tcp_mem[1];
-	tcp->tcp_prot_mem[2] = net->ipv4.sysctl_tcp_mem[2];
+	tcp->tcp_prot_mem[0] = sysctl_tcp_mem[0];
+	tcp->tcp_prot_mem[1] = sysctl_tcp_mem[1];
+	tcp->tcp_prot_mem[2] = sysctl_tcp_mem[2];
 	tcp->tcp_memory_pressure = 0;
 
 	parent_cg = tcp_prot.proto_cgroup(parent);
@@ -76,7 +75,6 @@ EXPORT_SYMBOL(tcp_destroy_cgroup);
 
 static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 {
-	struct net *net = current->nsproxy->net_ns;
 	struct tcp_memcontrol *tcp;
 	struct cg_proto *cg_proto;
 	u64 old_lim;
@@ -99,7 +97,7 @@ static int tcp_update_limit(struct mem_cgroup *memcg, u64 val)
 
 	for (i = 0; i < 3; i++)
 		tcp->tcp_prot_mem[i] = min_t(long, val >> PAGE_SHIFT,
-					     net->ipv4.sysctl_tcp_mem[i]);
+					     sysctl_tcp_mem[i]);
 
 	if (val == RES_COUNTER_MAX)
 		clear_bit(MEMCG_SOCK_ACTIVE, &cg_proto->flags);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a2cb07cd3850..25aa367efc4f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -870,8 +870,6 @@ static int __init inet6_init(void)
 	if (err)
 		goto out_sock_register_fail;
 
-	tcpv6_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
-
 	/*
 	 *	ipngwg API draft makes clear that the correct semantics
 	 *	for TCP and UDP is to consider one TCP and UDP instance
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b996ee2005a9..0740f93a114a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1929,6 +1929,7 @@ struct proto tcpv6_prot = {
 	.memory_allocated	= &tcp_memory_allocated,
 	.memory_pressure	= &tcp_memory_pressure,
 	.orphan_count		= &tcp_orphan_count,
+	.sysctl_mem		= sysctl_tcp_mem,
 	.sysctl_wmem		= sysctl_tcp_wmem,
 	.sysctl_rmem		= sysctl_tcp_rmem,
 	.max_header		= MAX_TCP_HEADER,
-- 
1.7.5.4
