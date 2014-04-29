From: Christoph Lameter <cl@linux.com>
Subject: net: Replace get_cpu_var through this_cpu_ptr
Date: Tue, 29 Apr 2014 14:21:19 -0500 (CDT)
Message-ID: <alpine.DEB.2.10.1404291420020.18476@gentwo.org>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:48518 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964887AbaD2T11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 15:27:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace uses of get_cpu_var for address calculation through this_cpu_ptr.

Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/net/core/dev.c
===================================================================
--- linux.orig/net/core/dev.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/core/dev.c	2014-04-28 13:19:34.748738409 -0500
@@ -2135,7 +2135,7 @@
 	unsigned long flags;

 	local_irq_save(flags);
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 	q->next_sched = NULL;
 	*sd->output_queue_tailp = q;
 	sd->output_queue_tailp = &q->next_sched;
@@ -3135,7 +3135,7 @@
 static int rps_ipi_queued(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	struct softnet_data *mysd = &__get_cpu_var(softnet_data);
+	struct softnet_data *mysd = this_cpu_ptr(&softnet_data);

 	if (sd != mysd) {
 		sd->rps_ipi_next = mysd->rps_ipi_list;
@@ -3162,7 +3162,7 @@
 	if (qlen < (netdev_max_backlog >> 1))
 		return false;

-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);

 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
@@ -3309,7 +3309,7 @@

 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);

 	if (sd->completion_queue) {
 		struct sk_buff *clist;
@@ -3734,7 +3734,7 @@
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	struct sk_buff *skb, *tmp;

 	rps_lock(sd);
@@ -4239,7 +4239,7 @@
 	unsigned long flags;

 	local_irq_save(flags);
-	____napi_schedule(&__get_cpu_var(softnet_data), n);
+	____napi_schedule(this_cpu_ptr(&softnet_data), n);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(__napi_schedule);
@@ -4360,7 +4360,7 @@

 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
Index: linux/net/core/drop_monitor.c
===================================================================
--- linux.orig/net/core/drop_monitor.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/core/drop_monitor.c	2014-04-28 13:19:34.748738409 -0500
@@ -146,7 +146,7 @@
 	unsigned long flags;

 	local_irq_save(flags);
-	data = &__get_cpu_var(dm_cpu_data);
+	data = this_cpu_ptr(&dm_cpu_data);
 	spin_lock(&data->lock);
 	dskb = data->skb;

Index: linux/net/core/skbuff.c
===================================================================
--- linux.orig/net/core/skbuff.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/core/skbuff.c	2014-04-28 13:19:34.748738409 -0500
@@ -344,7 +344,7 @@
 	unsigned long flags;

 	local_irq_save(flags);
-	nc = &__get_cpu_var(netdev_alloc_cache);
+	nc = this_cpu_ptr(&netdev_alloc_cache);
 	if (unlikely(!nc->frag.page)) {
 refill:
 		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
Index: linux/net/ipv4/tcp_output.c
===================================================================
--- linux.orig/net/ipv4/tcp_output.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/ipv4/tcp_output.c	2014-04-28 13:19:34.748738409 -0500
@@ -842,7 +842,7 @@

 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
-		tsq = &__get_cpu_var(tsq_tasklet);
+		tsq = this_cpu_ptr(&tsq_tasklet);
 		list_add(&tp->tsq_node, &tsq->head);
 		tasklet_schedule(&tsq->tasklet);
 		local_irq_restore(flags);
Index: linux/net/ipv6/syncookies.c
===================================================================
--- linux.orig/net/ipv6/syncookies.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/ipv6/syncookies.c	2014-04-28 13:19:34.748738409 -0500
@@ -67,7 +67,7 @@

 	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));

-	tmp  = __get_cpu_var(ipv6_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv6_cookie_scratch);

 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
Index: linux/net/rds/ib_rdma.c
===================================================================
--- linux.orig/net/rds/ib_rdma.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/rds/ib_rdma.c	2014-04-28 13:19:34.752738331 -0500
@@ -267,7 +267,7 @@
 	unsigned long *flag;

 	preempt_disable();
-	flag = &__get_cpu_var(clean_list_grace);
+	flag = this_cpu_ptr(&clean_list_grace);
 	set_bit(CLEAN_LIST_BUSY_BIT, flag);
 	ret = llist_del_first(&pool->clean_list);
 	if (ret)
Index: linux/include/net/netfilter/nf_conntrack.h
===================================================================
--- linux.orig/include/net/netfilter/nf_conntrack.h	2014-04-28 13:19:34.756738256 -0500
+++ linux/include/net/netfilter/nf_conntrack.h	2014-04-28 13:19:34.752738331 -0500
@@ -242,7 +242,7 @@
 DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	return &__raw_get_cpu_var(nf_conntrack_untracked);
+	return raw_cpu_ptr(&nf_conntrack_untracked);
 }
 void nf_ct_untracked_status_or(unsigned long bits);

Index: linux/include/net/snmp.h
===================================================================
--- linux.orig/include/net/snmp.h	2014-04-28 13:19:34.756738256 -0500
+++ linux/include/net/snmp.h	2014-04-28 13:19:34.752738331 -0500
@@ -170,7 +170,7 @@

 #define SNMP_ADD_STATS64_BH(mib, field, addend) 			\
 	do {								\
-		__typeof__(*mib[0]) *ptr = __this_cpu_ptr((mib)[0]);	\
+		__typeof__(*mib[0]) *ptr = raw_cpu_ptr((mib)[0]);	\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[field] += addend;				\
 		u64_stats_update_end(&ptr->syncp);			\
@@ -192,7 +192,7 @@
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
 	do {								\
 		__typeof__(*mib[0]) *ptr;				\
-		ptr = __this_cpu_ptr((mib)[0]);				\
+		ptr = raw_cpu_ptr((mib)[0]);				\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[basefield##PKTS]++;				\
 		ptr->mibs[basefield##OCTETS] += addend;			\
Index: linux/net/ipv4/route.c
===================================================================
--- linux.orig/net/ipv4/route.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/ipv4/route.c	2014-04-28 13:19:34.756738256 -0500
@@ -1296,7 +1296,7 @@
 	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
 	} else {
-		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
+		p = (struct rtable **)raw_cpu_ptr(nh->nh_pcpu_rth_output);
 	}
 	orig = *p;

@@ -1926,7 +1926,7 @@
 				do_cache = false;
 				goto add;
 			}
-			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
+			prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
 		}
 		rth = rcu_dereference(*prth);
 		if (rt_cache_valid(rth)) {
Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/ipv4/tcp.c	2014-04-28 13:19:34.756738256 -0500
@@ -3039,7 +3039,7 @@
 	local_bh_disable();
 	p = ACCESS_ONCE(tcp_md5sig_pool);
 	if (p)
-		return __this_cpu_ptr(p);
+		return raw_cpu_ptr(p);

 	local_bh_enable();
 	return NULL;
Index: linux/net/ipv4/syncookies.c
===================================================================
--- linux.orig/net/ipv4/syncookies.c	2014-04-28 13:19:34.756738256 -0500
+++ linux/net/ipv4/syncookies.c	2014-04-28 13:19:34.756738256 -0500
@@ -40,7 +40,7 @@

 	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));

-	tmp  = __get_cpu_var(ipv4_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv4_cookie_scratch);
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
