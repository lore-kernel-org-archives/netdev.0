From: Christoph Lameter <cl@linux.com>
Subject: [PATCH 26/48] net: Replace get_cpu_var through this_cpu_ptr
Date: Fri, 14 Feb 2014 14:19:07 -0600
Message-ID: <20140214201906.712135690@linux.com>
References: <20140214201841.826179349@linux.com>
Content-Type: text/plain; charset=UTF-8
Cc: akpm@linuxfoundation.org, rostedt@goodmis.org,
	linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline; filename=this_net
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Patch depends on another patch in this series that introduces raw_cpu_ops]

Replace uses of get_cpu_var for address calculation through this_cpu_ptr.

Cc: netdev@vger.kernel.org
Cc: Eric Dumazet <edumazet@google.com>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/net/core/dev.c
===================================================================
--- linux.orig/net/core/dev.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/core/dev.c	2014-02-03 13:25:26.382485504 -0600
@@ -2134,7 +2134,7 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 	q->next_sched = NULL;
 	*sd->output_queue_tailp = q;
 	sd->output_queue_tailp = &q->next_sched;
@@ -3125,7 +3125,7 @@
 static int rps_ipi_queued(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	struct softnet_data *mysd = &__get_cpu_var(softnet_data);
+	struct softnet_data *mysd = this_cpu_ptr(&softnet_data);
 
 	if (sd != mysd) {
 		sd->rps_ipi_next = mysd->rps_ipi_list;
@@ -3152,7 +3152,7 @@
 	if (qlen < (netdev_max_backlog >> 1))
 		return false;
 
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 
 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
@@ -3303,7 +3303,7 @@
 
 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 
 	if (sd->completion_queue) {
 		struct sk_buff *clist;
@@ -3733,7 +3733,7 @@
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	struct sk_buff *skb, *tmp;
 
 	rps_lock(sd);
@@ -4205,7 +4205,7 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	____napi_schedule(&__get_cpu_var(softnet_data), n);
+	____napi_schedule(this_cpu_ptr(&softnet_data), n);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(__napi_schedule);
@@ -4326,7 +4326,7 @@
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
Index: linux/net/core/drop_monitor.c
===================================================================
--- linux.orig/net/core/drop_monitor.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/core/drop_monitor.c	2014-02-03 13:23:33.314834063 -0600
@@ -146,7 +146,7 @@
 	unsigned long flags;
 
 	local_irq_save(flags);
-	data = &__get_cpu_var(dm_cpu_data);
+	data = this_cpu_ptr(&dm_cpu_data);
 	spin_lock(&data->lock);
 	dskb = data->skb;
 
Index: linux/net/core/skbuff.c
===================================================================
--- linux.orig/net/core/skbuff.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/core/skbuff.c	2014-02-03 13:23:33.314834063 -0600
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
--- linux.orig/net/ipv4/tcp_output.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/ipv4/tcp_output.c	2014-02-03 13:23:33.314834063 -0600
@@ -817,7 +817,7 @@
 
 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
-		tsq = &__get_cpu_var(tsq_tasklet);
+		tsq = this_cpu_ptr(&tsq_tasklet);
 		list_add(&tp->tsq_node, &tsq->head);
 		tasklet_schedule(&tsq->tasklet);
 		local_irq_restore(flags);
Index: linux/net/ipv6/syncookies.c
===================================================================
--- linux.orig/net/ipv6/syncookies.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/ipv6/syncookies.c	2014-02-03 13:23:33.314834063 -0600
@@ -67,7 +67,7 @@
 
 	net_get_random_once(syncookie6_secret, sizeof(syncookie6_secret));
 
-	tmp  = __get_cpu_var(ipv6_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
Index: linux/net/rds/ib_rdma.c
===================================================================
--- linux.orig/net/rds/ib_rdma.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/rds/ib_rdma.c	2014-02-03 13:23:33.314834063 -0600
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
--- linux.orig/include/net/netfilter/nf_conntrack.h	2014-02-03 13:23:33.324833855 -0600
+++ linux/include/net/netfilter/nf_conntrack.h	2014-02-03 13:23:33.314834063 -0600
@@ -235,7 +235,7 @@
 DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	return &__raw_get_cpu_var(nf_conntrack_untracked);
+	return raw_cpu_ptr(&nf_conntrack_untracked);
 }
 void nf_ct_untracked_status_or(unsigned long bits);
 
Index: linux/include/net/snmp.h
===================================================================
--- linux.orig/include/net/snmp.h	2014-02-03 13:23:33.324833855 -0600
+++ linux/include/net/snmp.h	2014-02-03 13:23:33.314834063 -0600
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
--- linux.orig/net/ipv4/route.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/ipv4/route.c	2014-02-03 13:23:33.314834063 -0600
@@ -1303,7 +1303,7 @@
 	if (rt_is_input_route(rt)) {
 		p = (struct rtable **)&nh->nh_rth_input;
 	} else {
-		p = (struct rtable **)__this_cpu_ptr(nh->nh_pcpu_rth_output);
+		p = (struct rtable **)raw_cpu_ptr(nh->nh_pcpu_rth_output);
 	}
 	orig = *p;
 
@@ -1929,7 +1929,7 @@
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
--- linux.orig/net/ipv4/tcp.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/ipv4/tcp.c	2014-02-03 13:23:33.314834063 -0600
@@ -3024,7 +3024,7 @@
 	local_bh_disable();
 	p = ACCESS_ONCE(tcp_md5sig_pool);
 	if (p)
-		return __this_cpu_ptr(p);
+		return raw_cpu_ptr(p);
 
 	local_bh_enable();
 	return NULL;
Index: linux/net/ipv4/syncookies.c
===================================================================
--- linux.orig/net/ipv4/syncookies.c	2014-02-03 13:23:33.324833855 -0600
+++ linux/net/ipv4/syncookies.c	2014-02-03 13:23:33.324833855 -0600
@@ -40,7 +40,7 @@
 
 	net_get_random_once(syncookie_secret, sizeof(syncookie_secret));
 
-	tmp  = __get_cpu_var(ipv4_cookie_scratch);
+	tmp  = this_cpu_ptr(ipv4_cookie_scratch);
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
 	tmp[1] = (__force u32)daddr;
