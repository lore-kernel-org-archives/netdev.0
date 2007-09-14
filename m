From: David Miller <davem@davemloft.net>
Subject: Re: new NAPI interface broken
Date: Fri, 14 Sep 2007 15:12:52 -0700 (PDT)
Message-ID: <20070914.151252.85399360.davem@davemloft.net>
References: <200709071137.02801.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org,
	themann@de.ibm.com, raisch@de.ibm.com
To: ossthema@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:43344
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757822AbXINWND (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 18:13:03 -0400
In-Reply-To: <200709071137.02801.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan-Bernd Themann <ossthema@de.ibm.com>
Date: Fri, 7 Sep 2007 11:37:02 +0200

> Its about the question who inserts and removes devices from the poll list.
> 
> netif_rx_schedule: sets NAPI_STATE_SCHED flag, insert device in poll list.
> netif_rx_complete: clears NAPI_STATE_SCHED
> netif_rx_reschedule: sets NAPI_STATE_SCHED, insert device in poll list.
> net_rx_action: 
>  -removes dev from poll list
>  -calls poll function
>  -adds dev to poll list if NAPI_STATE_SCHED still set

Ok, for now I'm going to try and deal with this by reverting
the list handling to something approximating the old NAPI
code, as per the patch below.

I've only quickly test booted into this kernel on my workstation.
So take care when trying it out.

I took the liberty to add some assertions and comments all over
wrt. list and quota handling.  One thing to note that (and this
was true previously too) that if ->poll() uses the whole quota
it _MUST_ _NOT_ modify the NAPI state by doing a complete or
reschedule.  The net_rx_action code still owns the NAPI state in
that case, and therefore is allowed to make modifications to the
->poll_list.

I realize this adds a lot of IRQ enable/disable overhead back
into the code, but we can't get rid of that cleanly without
solving this list ownership and modification issue properly.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0106fa6..9837ed3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -284,7 +284,14 @@ extern int __init netdev_boot_setup(char *str);
  * Structure for NAPI scheduling similar to tasklet but with weighting
  */
 struct napi_struct {
+	/* The poll_list must only be managed by the entity which
+	 * changes the state of the NAPI_STATE_SCHED bit.  This means
+	 * whoever atomically sets that bit can add this napi_struct
+	 * to the per-cpu poll_list, and whoever clears that bit
+	 * can remove from the list right before clearing the bit.
+	 */
 	struct list_head	poll_list;
+
 	unsigned long		state;
 	int			weight;
 	int			quota;
@@ -336,13 +343,21 @@ static inline void napi_schedule(struct napi_struct *n)
  *
  * Mark NAPI processing as complete.
  */
-static inline void napi_complete(struct napi_struct *n)
+static inline void __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
+	list_del(&n->poll_list);
 	smp_mb__before_clear_bit();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
 }
 
+static inline void napi_complete(struct napi_struct *n)
+{
+	local_irq_disable();
+	__napi_complete(n);
+	local_irq_enable();
+}
+
 /**
  *	napi_disable - prevent NAPI from scheduling
  *	@n: napi context
@@ -1184,19 +1199,11 @@ static inline u32 netif_msg_init(int debug_value, int default_msg_enable_bits)
 	return (1 << debug_value) - 1;
 }
 
-/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().
- * Do not inline this?
- */
+/* Try to reschedule poll. Called by dev->poll() after netif_rx_complete().  */
 static inline int netif_rx_reschedule(struct napi_struct *n)
 {
 	if (napi_schedule_prep(n)) {
-		unsigned long flags;
-
-		local_irq_save(flags);
-		list_add_tail(&n->poll_list,
-			      &__get_cpu_var(softnet_data).poll_list);
-		__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-		local_irq_restore(flags);
+		__napi_schedule(n);
 		return 1;
 	}
 	return 0;
@@ -1234,7 +1241,7 @@ static inline void netif_rx_schedule(struct net_device *dev,
 static inline void __netif_rx_complete(struct net_device *dev,
 				       struct napi_struct *napi)
 {
-	napi_complete(napi);
+	__napi_complete(napi);
 	dev_put(dev);
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index f119dc0..2897352 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2120,6 +2120,13 @@ static int process_backlog(struct napi_struct *napi, int quota)
 	return work;
 }
 
+static void napi_check_quota_bug(struct napi_struct *n)
+{
+	/* It is illegal to consume more than the given quota.  */
+	if (WARN_ON_ONCE(n->quota < 0))
+		n->quota = 0;
+}
+
 /**
  * __napi_schedule - schedule for receive
  * @napi: entry to schedule
@@ -2130,10 +2137,8 @@ void fastcall __napi_schedule(struct napi_struct *n)
 {
 	unsigned long flags;
 
-	if (n->quota < 0)
-		n->quota += n->weight;
-	else
-		n->quota = n->weight;
+	napi_check_quota_bug(n);
+	n->quota = n->weight;
 
 	local_irq_save(flags);
 	list_add_tail(&n->poll_list, &__get_cpu_var(softnet_data).poll_list);
@@ -2145,32 +2150,36 @@ EXPORT_SYMBOL(__napi_schedule);
 
 static void net_rx_action(struct softirq_action *h)
 {
-	struct list_head list;
+	struct list_head *list = &__get_cpu_var(softnet_data).poll_list;
 	unsigned long start_time = jiffies;
 	int budget = netdev_budget;
 	void *have;
 
 	local_irq_disable();
-	list_replace_init(&__get_cpu_var(softnet_data).poll_list, &list);
-	local_irq_enable();
 
-	while (!list_empty(&list)) {
+	while (!list_empty(list)) {
 		struct napi_struct *n;
 
-		/* if softirq window is exhuasted then punt */
-		if (unlikely(budget <= 0 || jiffies != start_time)) {
-			local_irq_disable();
-			list_splice(&list, &__get_cpu_var(softnet_data).poll_list);
-			__raise_softirq_irqoff(NET_RX_SOFTIRQ);
-			local_irq_enable();
-			break;
-		}
+		/* If softirq window is exhuasted then punt.
+		 *
+		 * Note that this is a slight policy change from the
+		 * previous NAPI code, which would allow up to 2
+		 * jiffies to pass before breaking out.  The test
+		 * used to be "jiffies - start_time > 1".
+		 */
+		if (unlikely(budget <= 0 || jiffies != start_time))
+			goto softnet_break;
 
-		n = list_entry(list.next, struct napi_struct, poll_list);
+		local_irq_enable();
 
-		have = netpoll_poll_lock(n);
+		/* Even though interrupts have been re-enabled, this
+		 * access is safe because interrupts can only add new
+		 * entries to the tail of this list, and only ->poll()
+		 * calls can remove this head entry from the list.
+		 */
+		n = list_entry(list->next, struct napi_struct, poll_list);
 
-		list_del(&n->poll_list);
+		have = netpoll_poll_lock(n);
 
 		/* if quota not exhausted process work */
 		if (likely(n->quota > 0)) {
@@ -2180,12 +2189,25 @@ static void net_rx_action(struct softirq_action *h)
 			n->quota -= work;
 		}
 
-		/* if napi_complete not called, reschedule */
-		if (test_bit(NAPI_STATE_SCHED, &n->state))
-			__napi_schedule(n);
+		local_irq_disable();
+
+		napi_check_quota_bug(n);
+
+		/* Drivers must not modify the NAPI state if they
+		 * consume the entire quota.  In such cases this code
+		 * still "owns" the NAPI instance and therefore can
+		 * move the instance around on the list at-will.
+		 */
+		if (unlikely(!n->quota)) {
+			n->quota = n->weight;
+			list_move_tail(&n->poll_list, list);
+		}
 
 		netpoll_poll_unlock(have);
 	}
+out:
+	local_irq_enable();
+
 #ifdef CONFIG_NET_DMA
 	/*
 	 * There may not be any more sk_buffs coming right now, so push
@@ -2200,6 +2222,13 @@ static void net_rx_action(struct softirq_action *h)
 		}
 	}
 #endif
+
+	return;
+
+softnet_break:
+	__get_cpu_var(netdev_rx_stat).time_squeeze++;
+	__raise_softirq_irqoff(NET_RX_SOFTIRQ);
+	goto out;
 }
 
 static gifconf_func_t * gifconf_list [NPROTO];
