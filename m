From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 12/35] [PATCH 12/36] net: Replace get_cpu_var through this_cpu_ptr
Date: Sun, 17 Aug 2014 12:30:35 -0500
Message-ID: <20140817173034.793528138@linux.com>
References: <20140817173023.439660246@linux.com>
Content-Type: text/plain; charset=UTF-8
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=0012-net-Replace-get_cpu_var-through-this_cpu_ptr.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace uses of get_cpu_var for address calculation through this_cpu_ptr.

Cc: netdev@vger.kernel.org
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <cl@linux.com>
---
 include/net/netfilter/nf_conntrack.h |  2 +-
 include/net/snmp.h                   |  6 +++---
 net/core/dev.c                       | 14 +++++++-------
 net/core/drop_monitor.c              |  2 +-
 net/core/skbuff.c                    |  2 +-
 net/ipv4/route.c                     |  4 ++--
 net/ipv4/syncookies.c                |  2 +-
 net/ipv4/tcp.c                       |  2 +-
 net/ipv4/tcp_output.c                |  2 +-
 net/ipv6/syncookies.c                |  2 +-
 net/rds/ib_rdma.c                    |  2 +-
 11 files changed, 20 insertions(+), 20 deletions(-)

Index: linux/include/net/netfilter/nf_conntrack.h
===================================================================
--- linux.orig/include/net/netfilter/nf_conntrack.h
+++ linux/include/net/netfilter/nf_conntrack.h
@@ -242,7 +242,7 @@ extern s32 (*nf_ct_nat_offset)(const str
 DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	return &__raw_get_cpu_var(nf_conntrack_untracked);
+	return raw_cpu_ptr(&nf_conntrack_untracked);
 }
 void nf_ct_untracked_status_or(unsigned long bits);
 
Index: linux/include/net/snmp.h
===================================================================
--- linux.orig/include/net/snmp.h
+++ linux/include/net/snmp.h
@@ -168,7 +168,7 @@ struct linux_xfrm_mib {
 
 #define SNMP_ADD_STATS64_BH(mib, field, addend) 			\
 	do {								\
-		__typeof__(*mib) *ptr = __this_cpu_ptr(mib);		\
+		__typeof__(*mib) *ptr = raw_cpu_ptr(mib);		\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[field] += addend;				\
 		u64_stats_update_end(&ptr->syncp);			\
@@ -189,8 +189,8 @@ struct linux_xfrm_mib {
 #define SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
 	do {								\
-		__typeof__(*mib) *ptr;					\
-		ptr = __this_cpu_ptr(mib);				\
+		__typeof__(*mib) *ptr;				\
+		ptr = raw_cpu_ptr((mib));				\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[basefield##PKTS]++;				\
 		ptr->mibs[basefield##OCTETS] += addend;			\
Index: linux/net/core/dev.c
===================================================================
--- linux.orig/net/core/dev.c
+++ linux/net/core/dev.c
@@ -2153,7 +2153,7 @@ static inline void __netif_reschedule(st
 	unsigned long flags;
 
 	local_irq_save(flags);
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 	q->next_sched = NULL;
 	*sd->output_queue_tailp = q;
 	sd->output_queue_tailp = &q->next_sched;
@@ -3195,7 +3195,7 @@ static void rps_trigger_softirq(void *da
 static int rps_ipi_queued(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	struct softnet_data *mysd = &__get_cpu_var(softnet_data);
+	struct softnet_data *mysd = this_cpu_ptr(&softnet_data);
 
 	if (sd != mysd) {
 		sd->rps_ipi_next = mysd->rps_ipi_list;
@@ -3222,7 +3222,7 @@ static bool skb_flow_limit(struct sk_buf
 	if (qlen < (netdev_max_backlog >> 1))
 		return false;
 
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 
 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
@@ -3369,7 +3369,7 @@ EXPORT_SYMBOL(netif_rx_ni);
 
 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 
 	if (sd->completion_queue) {
 		struct sk_buff *clist;
@@ -3794,7 +3794,7 @@ EXPORT_SYMBOL(netif_receive_skb);
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	struct sk_buff *skb, *tmp;
 
 	rps_lock(sd);
@@ -4301,7 +4301,7 @@ void __napi_schedule(struct napi_struct
 	unsigned long flags;
 
 	local_irq_save(flags);
-	____napi_schedule(&__get_cpu_var(softnet_data), n);
+	____napi_schedule(this_cpu_ptr(&softnet_data), n);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(__napi_schedule);
@@ -4422,7 +4422,7 @@ EXPORT_SYMBOL(netif_napi_del);
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
Index: linux/net/core/drop_monitor.c
===================================================================
--- linux.orig/net/core/drop_monitor.c
+++ linux/net/core/drop_monitor.c
@@ -146,7 +146,7 @@ static void trace_drop_common(struct sk_
 	unsigned long flags;
 
 	local_irq_save(flags);
-	data = &__get_cpu_var(dm_cpu_data);
+	data = this_cpu_ptr(&dm_cpu_data);
 	spin_lock(&data->lock);
 	dskb = data->skb;
 
Index: linux/net/core/skbuff.c
===================================================================
--- linux.orig/net/core/skbuff.c
+++ linux/net/core/skbuff.c
@@ -345,7 +345,7 @@ static void *__netdev_alloc_frag(unsigne
 	unsigned long flags;
 
 	local_irq_save(flags);
-	nc = &__get_cpu_var(netdev_alloc_cache);
+	nc = this_cpu_ptr(&netdev_alloc_cache);
 	if (unlikely(!nc->frag.page)) {
 refill:
 		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
Index: linux/net/ipv4/route.c
===================================================================
--- linux.orig/net/ipv4/route.c
+++ linux/net/ipv4/route.c
@@ -1311,7 +1311,7 @@ static bool rt_cache_route(struct fib_nh
 	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
 	} else {
-		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
+		p = (struct rtable **)raw_cpu_ptr(nh->nh_pcpu_rth_output);
 	}
 	orig = *p;
 
@@ -1939,7 +1939,7 @@ static struct rtable *__mkroute_output(c
 				do_cache = false;
 				goto add;
 			}
-			prth = __this_cpu_ptr(nh->nh_pcpu_rth_output);
+			prth = raw_cpu_ptr(nh->nh_pcpu_rth_output);
 		}
 		rth = rcu_dereference(*prth);
 		if (rt_cache_valid(rth)) {
Index: linux/net/ipv4/syncookies.c
===================================================================
--- linux.orig/net/ipv4/syncookies.c
+++ linux/net/ipv4/syncookies.c
@@ -40,7 +40,7 @@ static u32 cookie_hash(__be32 saddr, __b
 
 	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));
 
-	tmp  = __get_cpu_var(ipv4_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv4_cookie_scratch);
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
Index: linux/net/ipv4/tcp.c
===================================================================
--- linux.orig/net/ipv4/tcp.c
+++ linux/net/ipv4/tcp.c
@@ -3058,7 +3058,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_p
 	local_bh_disable();
 	p = ACCESS_ONCE(tcp_md5sig_pool);
 	if (p)
-		return __this_cpu_ptr(p);
+		return raw_cpu_ptr(p);
 
 	local_bh_enable();
 	return NULL;
Index: linux/net/ipv4/tcp_output.c
===================================================================
--- linux.orig/net/ipv4/tcp_output.c
+++ linux/net/ipv4/tcp_output.c
@@ -842,7 +842,7 @@ void tcp_wfree(struct sk_buff *skb)
 
 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
-		tsq = &__get_cpu_var(tsq_tasklet);
+		tsq = this_cpu_ptr(&tsq_tasklet);
 		list_add(&tp->tsq_node, &tsq->head);
 		tasklet_schedule(&tsq->tasklet);
 		local_irq_restore(flags);
Index: linux/net/ipv6/syncookies.c
===================================================================
--- linux.orig/net/ipv6/syncookies.c
+++ linux/net/ipv6/syncookies.c
@@ -67,7 +67,7 @@ static u32 cookie_hash(const struct in6_
 
 	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));
 
-	tmp  = __get_cpu_var(ipv6_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
Index: linux/net/rds/ib_rdma.c
===================================================================
--- linux.orig/net/rds/ib_rdma.c
+++ linux/net/rds/ib_rdma.c
@@ -267,7 +267,7 @@ static inline struct rds_ib_mr *rds_ib_r
 	unsigned long *flag;
 
 	preempt_disable();
-	flag = &__get_cpu_var(clean_list_grace);
+	flag = this_cpu_ptr(&clean_list_grace);
 	set_bit(CLEAN_LIST_BUSY_BIT, flag);
 	ret = llist_del_first(&pool->clean_list);
 	if (ret)
