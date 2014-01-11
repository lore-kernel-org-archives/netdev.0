From: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
Subject: [PATCH net-next] net: replace macros net_random and net_srandom with direct calls to prandom
Date: Sat, 11 Jan 2014 07:15:59 -0500
Message-ID: <1389442559-13097-1-git-send-email-aruna.hewapathirane@gmail.com>
Cc: hannes@stressinduktion.org,
	Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:63222 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751900AbaAKMQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jan 2014 07:16:17 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so6125289iec.23
        for <netdev@vger.kernel.org>; Sat, 11 Jan 2014 04:16:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the net_random and net_srandom macros and replaces
them with direct calls to the prandom ones. As new commits only seem to
use prandom_u32 there is no use to keep them around.
This change makes it easier to grep for users of prandom_u32.

Signed-off-by: Aruna-Hewapathirane <aruna.hewapathirane@gmail.com>
Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/infiniband/core/cma.c   |    2 +-
 include/linux/net.h             |    3 ---
 include/net/red.h               |    2 +-
 net/802/garp.c                  |    2 +-
 net/802/mrp.c                   |    2 +-
 net/core/neighbour.c            |    5 +++--
 net/core/stream.c               |    2 +-
 net/ipv4/devinet.c              |    2 +-
 net/ipv4/igmp.c                 |    6 +++---
 net/ipv4/inet_connection_sock.c |    2 +-
 net/ipv4/udp.c                  |    2 +-
 net/ipv6/addrconf.c             |    4 ++--
 net/ipv6/ip6_flowlabel.c        |    2 +-
 net/ipv6/mcast.c                |   10 +++++-----
 net/netfilter/ipvs/ip_vs_conn.c |    2 +-
 net/netfilter/xt_statistic.c    |    2 +-
 net/openvswitch/actions.c       |    2 +-
 net/rds/bind.c                  |    2 +-
 net/sched/act_gact.c            |    2 +-
 net/sched/sch_fq_codel.c        |    2 +-
 net/sched/sch_hhf.c             |    2 +-
 net/sched/sch_netem.c           |   19 ++++++++++---------
 net/sched/sch_pie.c             |    2 +-
 net/sched/sch_sfb.c             |    4 ++--
 net/sched/sch_sfq.c             |    6 +++---
 net/sctp/socket.c               |    2 +-
 net/sunrpc/cache.c              |    2 +-
 net/sunrpc/xprt.c               |    2 +-
 net/sunrpc/xprtsock.c           |    2 +-
 net/xfrm/xfrm_state.c           |    2 +-
 30 files changed, 50 insertions(+), 51 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 8e49db6..6c17f2d 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -2310,7 +2310,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 
 	inet_get_local_port_range(&init_net, &low, &high);
 	remaining = (high - low) + 1;
-	rover = net_random() % remaining + low;
+	rover = prandom_u32() % remaining + low;
 retry:
 	if (last_used_port != rover &&
 	    !idr_find(ps, (unsigned short) rover)) {
diff --git a/include/linux/net.h b/include/linux/net.h
index 69be3e6..94734a6 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -245,9 +245,6 @@ do {								\
 #define net_dbg_ratelimited(fmt, ...)				\
 	net_ratelimited_function(pr_debug, fmt, ##__VA_ARGS__)
 
-#define net_random()		prandom_u32()
-#define net_srandom(seed)	prandom_seed((__force u32)(seed))
-
 bool __net_get_random_once(void *buf, int nbytes, bool *done,
 			   struct static_key *done_key);
 
diff --git a/include/net/red.h b/include/net/red.h
index ef46058..168bb2f 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -303,7 +303,7 @@ static inline unsigned long red_calc_qavg(const struct red_parms *p,
 
 static inline u32 red_random(const struct red_parms *p)
 {
-	return reciprocal_divide(net_random(), p->max_P_reciprocal);
+	return reciprocal_divide(prandom_u32(), p->max_P_reciprocal);
 }
 
 static inline int red_mark_probability(const struct red_parms *p,
diff --git a/net/802/garp.c b/net/802/garp.c
index 5d9630a..b38ee6d 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -397,7 +397,7 @@ static void garp_join_timer_arm(struct garp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(garp_join_time) * net_random() >> 32;
+	delay = (u64)msecs_to_jiffies(garp_join_time) * prandom_u32() >> 32;
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/802/mrp.c b/net/802/mrp.c
index 3ed6162..72db278 100644
--- a/net/802/mrp.c
+++ b/net/802/mrp.c
@@ -583,7 +583,7 @@ static void mrp_join_timer_arm(struct mrp_applicant *app)
 {
 	unsigned long delay;
 
-	delay = (u64)msecs_to_jiffies(mrp_join_time) * net_random() >> 32;
+	delay = (u64)msecs_to_jiffies(mrp_join_time) * prandom_u32() >> 32;
 	mod_timer(&app->join_timer, jiffies + delay);
 }
 
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ea97361..e360d9e 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -117,7 +117,7 @@ static void neigh_cleanup_and_release(struct neighbour *neigh)
 
 unsigned long neigh_rand_reach_time(unsigned long base)
 {
-	return base ? (net_random() % base) + (base >> 1) : 0;
+	return base ? (prandom_u32() % base) + (base >> 1) : 0;
 }
 EXPORT_SYMBOL(neigh_rand_reach_time);
 
@@ -1415,7 +1415,8 @@ void pneigh_enqueue(struct neigh_table *tbl, struct neigh_parms *p,
 		    struct sk_buff *skb)
 {
 	unsigned long now = jiffies;
-	unsigned long sched_next = now + (net_random() %
+
+	unsigned long sched_next = now + (prandom_u32() %
 					  NEIGH_VAR(p, PROXY_DELAY));
 
 	if (tbl->proxy_queue.qlen > NEIGH_VAR(p, PROXY_QLEN)) {
diff --git a/net/core/stream.c b/net/core/stream.c
index 512f0a2..301c05f 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -122,7 +122,7 @@ int sk_stream_wait_memory(struct sock *sk, long *timeo_p)
 	DEFINE_WAIT(wait);
 
 	if (sk_stream_memory_free(sk))
-		current_timeo = vm_wait = (net_random() % (HZ / 5)) + 2;
+		current_timeo = vm_wait = (prandom_u32() % (HZ / 5)) + 2;
 
 	while (1) {
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 9809f7b..646023b 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -464,7 +464,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	}
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY)) {
-		net_srandom(ifa->ifa_local);
+		prandom_seed((__force u32) ifa->ifa_local);
 		ifap = last_primary;
 	}
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 84c4329..8535777 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -211,7 +211,7 @@ static void igmp_stop_timer(struct ip_mc_list *im)
 /* It must be called with locked im->lock */
 static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 {
-	int tv = net_random() % max_delay;
+	int tv = prandom_u32() % max_delay;
 
 	im->tm_running = 1;
 	if (!mod_timer(&im->timer, jiffies+tv+2))
@@ -220,7 +220,7 @@ static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 
 static void igmp_gq_start_timer(struct in_device *in_dev)
 {
-	int tv = net_random() % in_dev->mr_maxdelay;
+	int tv = prandom_u32() % in_dev->mr_maxdelay;
 
 	in_dev->mr_gq_running = 1;
 	if (!mod_timer(&in_dev->mr_gq_timer, jiffies+tv+2))
@@ -229,7 +229,7 @@ static void igmp_gq_start_timer(struct in_device *in_dev)
 
 static void igmp_ifc_start_timer(struct in_device *in_dev, int delay)
 {
-	int tv = net_random() % delay;
+	int tv = prandom_u32() % delay;
 
 	if (!mod_timer(&in_dev->mr_ifc_timer, jiffies+tv+2))
 		in_dev_hold(in_dev);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index fc0e649..0d1e2cb 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -109,7 +109,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 again:
 		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
-		smallest_rover = rover = net_random() % remaining + low;
+		smallest_rover = rover = prandom_u32() % remaining + low;
 
 		smallest_size = -1;
 		do {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 80f649f..3d3141f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -223,7 +223,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		inet_get_local_port_range(net, &low, &high);
 		remaining = (high - low) + 1;
 
-		rand = net_random();
+		rand = prandom_u32();
 		first = (((u64)rand * remaining) >> 32) + low;
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a9fa6c1..d2b3e04 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3102,7 +3102,7 @@ static void addrconf_dad_kick(struct inet6_ifaddr *ifp)
 	if (ifp->flags & IFA_F_OPTIMISTIC)
 		rand_num = 0;
 	else
-		rand_num = net_random() % (idev->cnf.rtr_solicit_delay ? : 1);
+		rand_num = prandom_u32() % (idev->cnf.rtr_solicit_delay ? : 1);
 
 	ifp->dad_probes = idev->cnf.dad_transmits;
 	addrconf_mod_dad_timer(ifp, rand_num);
@@ -3115,7 +3115,7 @@ static void addrconf_dad_start(struct inet6_ifaddr *ifp)
 
 	addrconf_join_solict(dev, &ifp->addr);
 
-	net_srandom(ifp->addr.s6_addr32[3]);
+	prandom_seed((__force u32) ifp->addr.s6_addr32[3]);
 
 	read_lock_bh(&idev->lock);
 	spin_lock(&ifp->lock);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index e7fb710..cbc9351 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -210,7 +210,7 @@ static struct ip6_flowlabel *fl_intern(struct net *net,
 	spin_lock_bh(&ip6_fl_lock);
 	if (label == 0) {
 		for (;;) {
-			fl->label = htonl(net_random())&IPV6_FLOWLABEL_MASK;
+			fl->label = htonl(prandom_u32())&IPV6_FLOWLABEL_MASK;
 			if (fl->label) {
 				lfl = __fl_lookup(net, fl->label);
 				if (lfl == NULL)
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index d18f9f9..7ff82b3 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -999,7 +999,7 @@ bool ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 
 static void mld_gq_start_timer(struct inet6_dev *idev)
 {
-	unsigned long tv = net_random() % idev->mc_maxdelay;
+	unsigned long tv = prandom_u32() % idev->mc_maxdelay;
 
 	idev->mc_gq_running = 1;
 	if (!mod_timer(&idev->mc_gq_timer, jiffies+tv+2))
@@ -1015,7 +1015,7 @@ static void mld_gq_stop_timer(struct inet6_dev *idev)
 
 static void mld_ifc_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
-	unsigned long tv = net_random() % delay;
+	unsigned long tv = prandom_u32() % delay;
 
 	if (!mod_timer(&idev->mc_ifc_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
@@ -1030,7 +1030,7 @@ static void mld_ifc_stop_timer(struct inet6_dev *idev)
 
 static void mld_dad_start_timer(struct inet6_dev *idev, unsigned long delay)
 {
-	unsigned long tv = net_random() % delay;
+	unsigned long tv = prandom_u32() % delay;
 
 	if (!mod_timer(&idev->mc_dad_timer, jiffies+tv+2))
 		in6_dev_hold(idev);
@@ -1061,7 +1061,7 @@ static void igmp6_group_queried(struct ifmcaddr6 *ma, unsigned long resptime)
 	}
 
 	if (delay >= resptime)
-		delay = net_random() % resptime;
+		delay = prandom_u32() % resptime;
 
 	ma->mca_timer.expires = jiffies + delay;
 	if (!mod_timer(&ma->mca_timer, jiffies + delay))
@@ -2328,7 +2328,7 @@ static void igmp6_join_group(struct ifmcaddr6 *ma)
 
 	igmp6_send(&ma->mca_addr, ma->idev->dev, ICMPV6_MGM_REPORT);
 
-	delay = net_random() % unsolicited_report_interval(ma->idev);
+	delay = prandom_u32() % unsolicited_report_interval(ma->idev);
 
 	spin_lock_bh(&ma->mca_lock);
 	if (del_timer(&ma->mca_timer)) {
diff --git a/net/netfilter/ipvs/ip_vs_conn.c b/net/netfilter/ipvs/ip_vs_conn.c
index 4c8e5c0..59a1a85 100644
--- a/net/netfilter/ipvs/ip_vs_conn.c
+++ b/net/netfilter/ipvs/ip_vs_conn.c
@@ -1209,7 +1209,7 @@ void ip_vs_random_dropentry(struct net *net)
 	 * Randomly scan 1/32 of the whole table every second
 	 */
 	for (idx = 0; idx < (ip_vs_conn_tab_size>>5); idx++) {
-		unsigned int hash = net_random() & ip_vs_conn_tab_mask;
+		unsigned int hash = prandom_u32() & ip_vs_conn_tab_mask;
 
 		hlist_for_each_entry_rcu(cp, &ip_vs_conn_tab[hash], c_list) {
 			if (cp->flags & IP_VS_CONN_F_TEMPLATE)
diff --git a/net/netfilter/xt_statistic.c b/net/netfilter/xt_statistic.c
index 4fe4fb4..11de55e 100644
--- a/net/netfilter/xt_statistic.c
+++ b/net/netfilter/xt_statistic.c
@@ -37,7 +37,7 @@ statistic_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	switch (info->mode) {
 	case XT_STATISTIC_MODE_RANDOM:
-		if ((net_random() & 0x7FFFFFFF) < info->u.random.probability)
+		if ((prandom_u32() & 0x7FFFFFFF) < info->u.random.probability)
 			ret = !ret;
 		break;
 	case XT_STATISTIC_MODE_NTH:
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 716b7ee..2c77e7b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -445,7 +445,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		 a = nla_next(a, &rem)) {
 		switch (nla_type(a)) {
 		case OVS_SAMPLE_ATTR_PROBABILITY:
-			if (net_random() >= nla_get_u32(a))
+			if (prandom_u32() >= nla_get_u32(a))
 				return 0;
 			break;
 
diff --git a/net/rds/bind.c b/net/rds/bind.c
index b5ad65a..a2e6562 100644
--- a/net/rds/bind.c
+++ b/net/rds/bind.c
@@ -117,7 +117,7 @@ static int rds_add_bound(struct rds_sock *rs, __be32 addr, __be16 *port)
 		rover = be16_to_cpu(*port);
 		last = rover;
 	} else {
-		rover = max_t(u16, net_random(), 2);
+		rover = max_t(u16, prandom_u32(), 2);
 		last = rover - 1;
 	}
 
diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
index af5641c..bef943e 100644
--- a/net/sched/act_gact.c
+++ b/net/sched/act_gact.c
@@ -30,7 +30,7 @@ static struct tcf_hashinfo gact_hash_info;
 #ifdef CONFIG_GACT_PROB
 static int gact_net_rand(struct tcf_gact *gact)
 {
-	if (!gact->tcfg_pval || net_random() % gact->tcfg_pval)
+	if (!gact->tcfg_pval || prandom_u32() % gact->tcfg_pval)
 		return gact->tcf_action;
 	return gact->tcfg_paction;
 }
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 5578628..ba5bc92 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -390,7 +390,7 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 	sch->limit = 10*1024;
 	q->flows_cnt = 1024;
 	q->quantum = psched_mtu(qdisc_dev(sch));
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 	INIT_LIST_HEAD(&q->new_flows);
 	INIT_LIST_HEAD(&q->old_flows);
 	codel_params_init(&q->cparams);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index cf7f614..f412a79 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -607,7 +607,7 @@ static int hhf_init(struct Qdisc *sch, struct nlattr *opt)
 
 	sch->limit = 1000;
 	q->quantum = psched_mtu(qdisc_dev(sch));
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 	INIT_LIST_HEAD(&q->new_buckets);
 	INIT_LIST_HEAD(&q->old_buckets);
 
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 090a4e3..3019c10 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -169,7 +169,7 @@ static inline struct netem_skb_cb *netem_skb_cb(struct sk_buff *skb)
 static void init_crandom(struct crndstate *state, unsigned long rho)
 {
 	state->rho = rho;
-	state->last = net_random();
+	state->last = prandom_u32();
 }
 
 /* get_crandom - correlated random number generator
@@ -182,9 +182,9 @@ static u32 get_crandom(struct crndstate *state)
 	unsigned long answer;
 
 	if (state->rho == 0)	/* no correlation */
-		return net_random();
+		return prandom_u32();
 
-	value = net_random();
+	value = prandom_u32();
 	rho = (u64)state->rho + 1;
 	answer = (value * ((1ull<<32) - rho) + state->last * rho) >> 32;
 	state->last = answer;
@@ -198,7 +198,7 @@ static u32 get_crandom(struct crndstate *state)
 static bool loss_4state(struct netem_sched_data *q)
 {
 	struct clgstate *clg = &q->clg;
-	u32 rnd = net_random();
+	u32 rnd = prandom_u32();
 
 	/*
 	 * Makes a comparison between rnd and the transition
@@ -264,15 +264,15 @@ static bool loss_gilb_ell(struct netem_sched_data *q)
 
 	switch (clg->state) {
 	case 1:
-		if (net_random() < clg->a1)
+		if (prandom_u32() < clg->a1)
 			clg->state = 2;
-		if (net_random() < clg->a4)
+		if (prandom_u32() < clg->a4)
 			return true;
 		break;
 	case 2:
-		if (net_random() < clg->a2)
+		if (prandom_u32() < clg->a2)
 			clg->state = 1;
-		if (net_random() > clg->a3)
+		if (prandom_u32() > clg->a3)
 			return true;
 	}
 
@@ -457,7 +457,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		     skb_checksum_help(skb)))
 			return qdisc_drop(skb, sch);
 
-		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
+		skb->data[prandom_u32() % skb_headlen(skb)] ^=
+			1<<(prandom_u32() % 8);
 	}
 
 	if (unlikely(skb_queue_len(&sch->q) >= sch->limit))
diff --git a/net/sched/sch_pie.c b/net/sched/sch_pie.c
index fe65340..a255d02 100644
--- a/net/sched/sch_pie.c
+++ b/net/sched/sch_pie.c
@@ -122,7 +122,7 @@ static bool drop_early(struct Qdisc *sch, u32 packet_size)
 	else
 		local_prob = q->vars.prob;
 
-	rnd = net_random();
+	rnd = prandom_u32();
 	if (rnd < local_prob)
 		return true;
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 30ea467..9b0f709 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -220,7 +220,7 @@ static u32 sfb_compute_qlen(u32 *prob_r, u32 *avgpm_r, const struct sfb_sched_da
 
 static void sfb_init_perturbation(u32 slot, struct sfb_sched_data *q)
 {
-	q->bins[slot].perturbation = net_random();
+	q->bins[slot].perturbation = prandom_u32();
 }
 
 static void sfb_swap_slot(struct sfb_sched_data *q)
@@ -381,7 +381,7 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		goto enqueue;
 	}
 
-	r = net_random() & SFB_MAX_PROB;
+	r = prandom_u32() & SFB_MAX_PROB;
 
 	if (unlikely(r < p_min)) {
 		if (unlikely(p_min > SFB_MAX_PROB / 2)) {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 76f01e0..87317ff 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -629,7 +629,7 @@ static void sfq_perturbation(unsigned long arg)
 	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
 
 	spin_lock(root_lock);
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 	if (!q->filter_list && q->tail)
 		sfq_rehash(sch);
 	spin_unlock(root_lock);
@@ -698,7 +698,7 @@ static int sfq_change(struct Qdisc *sch, struct nlattr *opt)
 	del_timer(&q->perturb_timer);
 	if (q->perturb_period) {
 		mod_timer(&q->perturb_timer, jiffies + q->perturb_period);
-		q->perturbation = net_random();
+		q->perturbation = prandom_u32();
 	}
 	sch_tree_unlock(sch);
 	kfree(p);
@@ -759,7 +759,7 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->quantum = psched_mtu(qdisc_dev(sch));
 	q->scaled_quantum = SFQ_ALLOT_SIZE(q->quantum);
 	q->perturb_period = 0;
-	q->perturbation = net_random();
+	q->perturbation = prandom_u32();
 
 	if (opt) {
 		int err = sfq_change(sch, opt);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index d32dae7..7cc62b9 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5926,7 +5926,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 
 		inet_get_local_port_range(sock_net(sk), &low, &high);
 		remaining = (high - low) + 1;
-		rover = net_random() % remaining + low;
+		rover = prandom_u32() % remaining + low;
 
 		do {
 			rover++;
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index a72de07..e521d20 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -619,7 +619,7 @@ static void cache_limit_defers(void)
 
 	/* Consider removing either the first or the last */
 	if (cache_defer_cnt > DFR_MAX) {
-		if (net_random() & 1)
+		if (prandom_u32() & 1)
 			discard = list_entry(cache_defer_list.next,
 					     struct cache_deferred_req, recent);
 		else
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 04199bc..1750048 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -1188,7 +1188,7 @@ static inline __be32 xprt_alloc_xid(struct rpc_xprt *xprt)
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
 {
-	xprt->xid = net_random();
+	xprt->xid = prandom_u32();
 }
 
 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dd9d295..75b045e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1674,7 +1674,7 @@ static void xs_udp_timer(struct rpc_xprt *xprt, struct rpc_task *task)
 static unsigned short xs_get_random_port(void)
 {
 	unsigned short range = xprt_max_resvport - xprt_min_resvport;
-	unsigned short rand = (unsigned short) net_random() % range;
+	unsigned short rand = (unsigned short) prandom_u32() % range;
 	return rand + xprt_min_resvport;
 }
 
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index a62c25e..b3c9774 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1543,7 +1543,7 @@ int xfrm_alloc_spi(struct xfrm_state *x, u32 low, u32 high)
 	} else {
 		u32 spi = 0;
 		for (h=0; h<high-low+1; h++) {
-			spi = low + net_random()%(high-low+1);
+			spi = low + prandom_u32()%(high-low+1);
 			x0 = xfrm_state_lookup(net, mark, &x->id.daddr, htonl(spi), x->id.proto, x->props.family);
 			if (x0 == NULL) {
 				x->id.spi = htonl(spi);
-- 
1.7.0.4
