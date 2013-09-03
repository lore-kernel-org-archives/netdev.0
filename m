From: Christoph Lameter <cl@linux.com>
Subject: [gcv v4 07/38] net: Replace __get_cpu_var uses
Date: Tue, 3 Sep 2013 19:12:19 +0000
Message-ID: <00000140e53d5efc-9761359b-da40-4ee1-91ae-44cc3e3e6a80-000000@email.amazonses.com>
References: <20130903190014.794420260@linux.com>
Cc: akpm@linuxfoundation.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: linux-arch@vger.kernel.org
Cc: Steven Rostedt <srostedt@redhat.com>
Cc: linux-kernel@vger.kernel.org
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__get_cpu_var() is used for multiple purposes in the kernel source. One of them is
address calculation via the form &__get_cpu_var(x). This calculates the address for
the instance of the percpu variable of the current processor based on an offset.

Other use cases are for storing and retrieving data from the current processors percpu area.
__get_cpu_var() can be used as an lvalue when writing data or on the right side of an assignment.

__get_cpu_var() is defined as :


#define __get_cpu_var(var) (*this_cpu_ptr(&(var)))



__get_cpu_var() always only does an address determination. However, store and retrieve operations
could use a segment prefix (or global register on other platforms) to avoid the address calculation.

this_cpu_write() and this_cpu_read() can directly take an offset into a percpu area and use
optimized assembly code to read and write per cpu variables.


This patch converts __get_cpu_var into either an explicit address calculation using this_cpu_ptr()
or into a use of this_cpu operations that use the offset. Thereby address calculations are avoided
and less registers are used when code is generated.

At the end of the patch set all uses of __get_cpu_var have been removed so the macro is removed too.

The patch set includes passes over all arches as well. Once these operations are used throughout then
specialized macros can be defined in non -x86 arches as well in order to optimize per cpu access by
f.e. using a global register that may be set to the per cpu base.




Transformations done to __get_cpu_var()


1. Determine the address of the percpu instance of the current processor.

	DEFINE_PER_CPU(int, y);
	int *x = &__get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(&y);


2. Same as #1 but this time an array structure is involved.

	DEFINE_PER_CPU(int, y[20]);
	int *x = __get_cpu_var(y);

    Converts to

	int *x = this_cpu_ptr(y);


3. Retrieve the content of the current processors instance of a per cpu variable.

	DEFINE_PER_CPU(int, y);
	int x = __get_cpu_var(y)

   Converts to

	int x = __this_cpu_read(y);


4. Retrieve the content of a percpu struct

	DEFINE_PER_CPU(struct mystruct, y);
	struct mystruct x = __get_cpu_var(y);

   Converts to

	memcpy(&x, this_cpu_ptr(&y), sizeof(x));


5. Assignment to a per cpu variable

	DEFINE_PER_CPU(int, y)
	__get_cpu_var(y) = x;

   Converts to

	this_cpu_write(y, x);


6. Increment/Decrement etc of a per cpu variable

	DEFINE_PER_CPU(int, y);
	__get_cpu_var(y)++

   Converts to

	this_cpu_inc(y)

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/net/core/dev.c
===================================================================
--- linux.orig/net/core/dev.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/core/dev.c	2013-08-26 14:18:37.214005168 -0500
@@ -2129,7 +2129,7 @@ static inline void __netif_reschedule(st
 	unsigned long flags;
 
 	local_irq_save(flags);
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 	q->next_sched = NULL;
 	*sd->output_queue_tailp = q;
 	sd->output_queue_tailp = &q->next_sched;
@@ -2151,7 +2151,7 @@ void dev_kfree_skb_irq(struct sk_buff *s
 		unsigned long flags;
 
 		local_irq_save(flags);
-		sd = &__get_cpu_var(softnet_data);
+		sd = this_cpu_ptr(&softnet_data);
 		skb->next = sd->completion_queue;
 		sd->completion_queue = skb;
 		raise_softirq_irqoff(NET_TX_SOFTIRQ);
@@ -3111,7 +3111,7 @@ static void rps_trigger_softirq(void *da
 static int rps_ipi_queued(struct softnet_data *sd)
 {
 #ifdef CONFIG_RPS
-	struct softnet_data *mysd = &__get_cpu_var(softnet_data);
+	struct softnet_data *mysd = this_cpu_ptr(&softnet_data);
 
 	if (sd != mysd) {
 		sd->rps_ipi_next = mysd->rps_ipi_list;
@@ -3138,7 +3138,7 @@ static bool skb_flow_limit(struct sk_buf
 	if (qlen < (netdev_max_backlog >> 1))
 		return false;
 
-	sd = &__get_cpu_var(softnet_data);
+	sd = this_cpu_ptr(&softnet_data);
 
 	rcu_read_lock();
 	fl = rcu_dereference(sd->flow_limit);
@@ -3280,7 +3280,7 @@ EXPORT_SYMBOL(netif_rx_ni);
 
 static void net_tx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 
 	if (sd->completion_queue) {
 		struct sk_buff *clist;
@@ -3700,7 +3700,7 @@ EXPORT_SYMBOL(netif_receive_skb);
 static void flush_backlog(void *arg)
 {
 	struct net_device *dev = arg;
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	struct sk_buff *skb, *tmp;
 
 	rps_lock(sd);
@@ -4146,7 +4146,7 @@ void __napi_schedule(struct napi_struct
 	unsigned long flags;
 
 	local_irq_save(flags);
-	____napi_schedule(&__get_cpu_var(softnet_data), n);
+	____napi_schedule(this_cpu_ptr(&softnet_data), n);
 	local_irq_restore(flags);
 }
 EXPORT_SYMBOL(__napi_schedule);
@@ -4274,7 +4274,7 @@ EXPORT_SYMBOL(netif_napi_del);
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct softnet_data *sd = &__get_cpu_var(softnet_data);
+	struct softnet_data *sd = this_cpu_ptr(&softnet_data);
 	unsigned long time_limit = jiffies + 2;
 	int budget = netdev_budget;
 	void *have;
Index: linux/net/core/drop_monitor.c
===================================================================
--- linux.orig/net/core/drop_monitor.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/core/drop_monitor.c	2013-08-26 14:18:37.218005126 -0500
@@ -142,7 +142,7 @@ static void trace_drop_common(struct sk_
 	unsigned long flags;
 
 	local_irq_save(flags);
-	data = &__get_cpu_var(dm_cpu_data);
+	data = this_cpu_ptr(&dm_cpu_data);
 	spin_lock(&data->lock);
 	dskb = data->skb;
 
Index: linux/net/core/skbuff.c
===================================================================
--- linux.orig/net/core/skbuff.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/core/skbuff.c	2013-08-26 14:18:37.218005126 -0500
@@ -371,7 +371,7 @@ static void *__netdev_alloc_frag(unsigne
 	unsigned long flags;
 
 	local_irq_save(flags);
-	nc = &__get_cpu_var(netdev_alloc_cache);
+	nc = this_cpu_ptr(&netdev_alloc_cache);
 	if (unlikely(!nc->frag.page)) {
 refill:
 		for (order = NETDEV_FRAG_PAGE_MAX_ORDER; ;) {
Index: linux/net/ipv4/syncookies.c
===================================================================
--- linux.orig/net/ipv4/syncookies.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/ipv4/syncookies.c	2013-08-26 14:18:37.210005210 -0500
@@ -44,7 +44,7 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SH
 static u32 cookie_hash(__be32 saddr, __be32 daddr, __be16 sport, __be16 dport,
 		       u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv4_cookie_scratch);
+	__u32 *tmp = this_cpu_ptr(ipv4_cookie_scratch);
 
 	memcpy(tmp + 4, syncookie_secret[c], sizeof(syncookie_secret[c]));
 	tmp[0] = (__force u32)saddr;
Index: linux/net/ipv4/tcp_output.c
===================================================================
--- linux.orig/net/ipv4/tcp_output.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/ipv4/tcp_output.c	2013-08-26 14:18:37.218005126 -0500
@@ -810,7 +810,7 @@ void tcp_wfree(struct sk_buff *skb)
 
 		/* queue this socket to tasklet queue */
 		local_irq_save(flags);
-		tsq = &__get_cpu_var(tsq_tasklet);
+		tsq = this_cpu_ptr(&tsq_tasklet);
 		list_add(&tp->tsq_node, &tsq->head);
 		tasklet_schedule(&tsq->tasklet);
 		local_irq_restore(flags);
Index: linux/net/ipv6/syncookies.c
===================================================================
--- linux.orig/net/ipv6/syncookies.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/ipv6/syncookies.c	2013-08-26 14:18:37.214005168 -0500
@@ -66,7 +66,7 @@ static DEFINE_PER_CPU(__u32 [16 + 5 + SH
 static u32 cookie_hash(const struct in6_addr *saddr, const struct in6_addr *daddr,
 		       __be16 sport, __be16 dport, u32 count, int c)
 {
-	__u32 *tmp = __get_cpu_var(ipv6_cookie_scratch);
+	__u32 *tmp = this_cpu_ptr(ipv6_cookie_scratch);
 
 	/*
 	 * we have 320 bits of information to hash, copy in the remaining
Index: linux/net/rds/ib_rdma.c
===================================================================
--- linux.orig/net/rds/ib_rdma.c	2013-08-26 14:16:59.000000000 -0500
+++ linux/net/rds/ib_rdma.c	2013-08-26 14:18:37.218005126 -0500
@@ -267,7 +267,7 @@ static inline struct rds_ib_mr *rds_ib_r
 	unsigned long *flag;
 
 	preempt_disable();
-	flag = &__get_cpu_var(clean_list_grace);
+	flag = this_cpu_ptr(&clean_list_grace);
 	set_bit(CLEAN_LIST_BUSY_BIT, flag);
 	ret = llist_del_first(&pool->clean_list);
 	if (ret)
Index: linux/include/net/netfilter/nf_conntrack.h
===================================================================
--- linux.orig/include/net/netfilter/nf_conntrack.h	2013-08-26 14:23:46.000000000 -0500
+++ linux/include/net/netfilter/nf_conntrack.h	2013-08-26 14:24:17.190395755 -0500
@@ -243,7 +243,7 @@ extern s16 (*nf_ct_nat_offset)(const str
 DECLARE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 static inline struct nf_conn *nf_ct_untracked_get(void)
 {
-	return &__raw_get_cpu_var(nf_conntrack_untracked);
+	return __this_cpu_ptr(&nf_conntrack_untracked);
 }
 extern void nf_ct_untracked_status_or(unsigned long bits);
 
