From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] drop_monitor: dont sleep in atomic context
Date: Mon, 04 Jun 2012 11:12:43 +0200
Message-ID: <1338801163.2760.1786.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:56576 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596Ab2FDJM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 05:12:56 -0400
Received: by eaak11 with SMTP id k11so1072228eaa.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 02:12:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

drop_monitor calls several sleeping functions while in atomic context.

 BUG: sleeping function called from invalid context at mm/slub.c:943
 in_atomic(): 1, irqs_disabled(): 0, pid: 2103, name: kworker/0:2
 Pid: 2103, comm: kworker/0:2 Not tainted 3.5.0-rc1+ #55
 Call Trace:
  [<ffffffff810697ca>] __might_sleep+0xca/0xf0
  [<ffffffff811345a3>] kmem_cache_alloc_node+0x1b3/0x1c0
  [<ffffffff8105578c>] ? queue_delayed_work_on+0x11c/0x130
  [<ffffffff815343fb>] __alloc_skb+0x4b/0x230
  [<ffffffffa00b0360>] ? reset_per_cpu_data+0x160/0x160 [drop_monitor]
  [<ffffffffa00b022f>] reset_per_cpu_data+0x2f/0x160 [drop_monitor]
  [<ffffffffa00b03ab>] send_dm_alert+0x4b/0xb0 [drop_monitor]
  [<ffffffff810568e0>] process_one_work+0x130/0x4c0
  [<ffffffff81058249>] worker_thread+0x159/0x360
  [<ffffffff810580f0>] ? manage_workers.isra.27+0x240/0x240
  [<ffffffff8105d403>] kthread+0x93/0xa0
  [<ffffffff816be6d4>] kernel_thread_helper+0x4/0x10
  [<ffffffff8105d370>] ? kthread_freezable_should_stop+0x80/0x80
  [<ffffffff816be6d0>] ? gs_change+0xb/0xb

Rework the logic to call the sleeping functions in right context.

Also avoid a loop if reset_per_cpu_data() cannot allocate memory :
use mod_timer() to wait 1/10 second before next try.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
---
 net/core/drop_monitor.c |   92 ++++++++++++--------------------------
 1 file changed, 30 insertions(+), 62 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index ea5fb9f..4ffbf67 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -48,11 +48,10 @@ static int trace_state = TRACE_OFF;
 static DEFINE_MUTEX(trace_state_mutex);
 
 struct per_cpu_dm_data {
-	struct work_struct dm_alert_work;
-	struct sk_buff __rcu *skb;
-	atomic_t dm_hit_count;
-	struct timer_list send_timer;
-	int cpu;
+	spinlock_t		lock;
+	struct sk_buff		*skb;
+	struct work_struct	dm_alert_work;
+	struct timer_list	send_timer;
 };
 
 struct dm_hw_stat_delta {
@@ -78,13 +77,13 @@ static int dm_delay = 1;
 static unsigned long dm_hw_check_delta = 2*HZ;
 static LIST_HEAD(hw_stats_list);
 
-static void reset_per_cpu_data(struct per_cpu_dm_data *data)
+static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 {
 	size_t al;
 	struct net_dm_alert_msg *msg;
 	struct nlattr *nla;
 	struct sk_buff *skb;
-	struct sk_buff *oskb = rcu_dereference_protected(data->skb, 1);
+	unsigned long flags;
 
 	al = sizeof(struct net_dm_alert_msg);
 	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
@@ -99,50 +98,28 @@ static void reset_per_cpu_data(struct per_cpu_dm_data *data)
 				  sizeof(struct net_dm_alert_msg));
 		msg = nla_data(nla);
 		memset(msg, 0, al);
-	} else
-		schedule_work_on(data->cpu, &data->dm_alert_work);
-
-	/*
-	 * Don't need to lock this, since we are guaranteed to only
-	 * run this on a single cpu at a time.
-	 * Note also that we only update data->skb if the old and new skb
-	 * pointers don't match.  This ensures that we don't continually call
-	 * synchornize_rcu if we repeatedly fail to alloc a new netlink message.
-	 */
-	if (skb != oskb) {
-		rcu_assign_pointer(data->skb, skb);
-
-		synchronize_rcu();
-
-		atomic_set(&data->dm_hit_count, dm_hit_limit);
+	} else {
+		mod_timer(&data->send_timer, jiffies + HZ / 10);
 	}
 
+	spin_lock_irqsave(&data->lock, flags);
+	swap(data->skb, skb);
+	spin_unlock_irqrestore(&data->lock, flags);
+
+	return skb;
 }
 
-static void send_dm_alert(struct work_struct *unused)
+static void send_dm_alert(struct work_struct *work)
 {
 	struct sk_buff *skb;
-	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
+	struct per_cpu_dm_data *data;
 
-	WARN_ON_ONCE(data->cpu != smp_processor_id());
+	data = container_of(work, struct per_cpu_dm_data, dm_alert_work);
 
-	/*
-	 * Grab the skb we're about to send
-	 */
-	skb = rcu_dereference_protected(data->skb, 1);
+	skb = reset_per_cpu_data(data);
 
-	/*
-	 * Replace it with a new one
-	 */
-	reset_per_cpu_data(data);
-
-	/*
-	 * Ship it!
-	 */
 	if (skb)
 		genlmsg_multicast(skb, 0, NET_DM_GRP_ALERT, GFP_KERNEL);
-
-	put_cpu_var(dm_cpu_data);
 }
 
 /*
@@ -153,11 +130,9 @@ static void send_dm_alert(struct work_struct *unused)
  */
 static void sched_send_work(unsigned long unused)
 {
-	struct per_cpu_dm_data *data =  &get_cpu_var(dm_cpu_data);
+	struct per_cpu_dm_data *data = &__get_cpu_var(dm_cpu_data);
 
-	schedule_work_on(smp_processor_id(), &data->dm_alert_work);
-
-	put_cpu_var(dm_cpu_data);
+	schedule_work(&data->dm_alert_work);
 }
 
 static void trace_drop_common(struct sk_buff *skb, void *location)
@@ -167,33 +142,28 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
 	struct nlattr *nla;
 	int i;
 	struct sk_buff *dskb;
-	struct per_cpu_dm_data *data = &get_cpu_var(dm_cpu_data);
-
+	struct per_cpu_dm_data *data;
+	unsigned long flags;
 
-	rcu_read_lock();
-	dskb = rcu_dereference(data->skb);
+	local_irq_save(flags);
+	data = &__get_cpu_var(dm_cpu_data);
+	spin_lock(&data->lock);
+	dskb = data->skb;
 
 	if (!dskb)
 		goto out;
 
-	if (!atomic_add_unless(&data->dm_hit_count, -1, 0)) {
-		/*
-		 * we're already at zero, discard this hit
-		 */
-		goto out;
-	}
-
 	nlh = (struct nlmsghdr *)dskb->data;
 	nla = genlmsg_data(nlmsg_data(nlh));
 	msg = nla_data(nla);
 	for (i = 0; i < msg->entries; i++) {
 		if (!memcmp(&location, msg->points[i].pc, sizeof(void *))) {
 			msg->points[i].count++;
-			atomic_inc(&data->dm_hit_count);
 			goto out;
 		}
 	}
-
+	if (msg->entries == dm_hit_limit)
+		goto out;
 	/*
 	 * We need to create a new entry
 	 */
@@ -205,13 +175,11 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
 
 	if (!timer_pending(&data->send_timer)) {
 		data->send_timer.expires = jiffies + dm_delay * HZ;
-		add_timer_on(&data->send_timer, smp_processor_id());
+		add_timer(&data->send_timer);
 	}
 
 out:
-	rcu_read_unlock();
-	put_cpu_var(dm_cpu_data);
-	return;
+	spin_unlock_irqrestore(&data->lock, flags);
 }
 
 static void trace_kfree_skb_hit(void *ignore, struct sk_buff *skb, void *location)
@@ -418,11 +386,11 @@ static int __init init_net_drop_monitor(void)
 
 	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
-		data->cpu = cpu;
 		INIT_WORK(&data->dm_alert_work, send_dm_alert);
 		init_timer(&data->send_timer);
 		data->send_timer.data = cpu;
 		data->send_timer.function = sched_send_work;
+		spin_lock_init(&data->lock);
 		reset_per_cpu_data(data);
 	}
 
