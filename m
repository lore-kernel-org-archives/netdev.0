From: martinbj2008@gmail.com
Subject: [PATCH v1 net-next 4/5] drop_monitor: let drop stat support net ns
Date: Wed, 12 Jul 2017 18:40:52 +0800
Message-ID: <1499856053-30475-4-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org, martinbj2008@gmail.com,
        zhangjunweimartin@didichuxing.com
To: nhorman@tuxdriver.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34845 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755279AbdGLKlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2017 06:41:22 -0400
Received: by mail-pf0-f193.google.com with SMTP id q85so2732874pfq.2
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 03:41:21 -0700 (PDT)
In-Reply-To: <1499856053-30475-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin Zhang <zhangjunweimartin@didichuxing.com>

move the detail drop stat to per net ns.
A net ns has its per cpu stat.

keep the work under per cpu to send netlink alter message.

all the net ns share a work under a CPU, the work will be scheduled
by any ns, and will send message in all the ns.

Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
---
 net/core/drop_monitor.c | 123 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 91 insertions(+), 32 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 875e8b4..5828bf2 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -47,6 +47,10 @@
  */
 
 struct ns_pcpu_dm_data {
+	spinlock_t	lock;
+	struct sk_buff	*skb;
+	struct net	*net;
+	struct timer_list	send_timer;
 };
 
 /**
@@ -59,15 +63,13 @@ struct per_ns_dm_cb {
 	int trace_state;
 	struct mutex ns_dm_mutex;
 	struct list_head hw_stats_list;
+	struct ns_pcpu_dm_data __percpu *pcpu_data;
 };
 
 static DEFINE_MUTEX(trace_state_mutex);
 
 struct per_cpu_dm_data {
-	spinlock_t		lock;
-	struct sk_buff		*skb;
 	struct work_struct	dm_alert_work;
-	struct timer_list	send_timer;
 };
 
 struct dm_hw_stat_delta {
@@ -88,7 +90,7 @@ struct dm_hw_stat_delta {
 static int dm_delay = 1;
 static unsigned long dm_hw_check_delta = 2*HZ;
 
-static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
+static struct sk_buff *reset_per_cpu_data(struct ns_pcpu_dm_data *ns_dm_data)
 {
 	size_t al;
 	struct net_dm_alert_msg *msg;
@@ -125,11 +127,11 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 	goto out;
 
 err:
-	mod_timer(&data->send_timer, jiffies + HZ / 10);
+	mod_timer(&ns_dm_data->send_timer, jiffies + HZ / 10);
 out:
-	spin_lock_irqsave(&data->lock, flags);
-	swap(data->skb, skb);
-	spin_unlock_irqrestore(&data->lock, flags);
+	spin_lock_irqsave(&ns_dm_data->lock, flags);
+	swap(ns_dm_data->skb, skb);
+	spin_unlock_irqrestore(&ns_dm_data->lock, flags);
 
 	if (skb) {
 		struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
@@ -147,16 +149,30 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 
 static void send_dm_alert(struct work_struct *work)
 {
+	struct net *net;
 	struct sk_buff *skb;
-	struct per_cpu_dm_data *data;
-
-	data = container_of(work, struct per_cpu_dm_data, dm_alert_work);
-
-	skb = reset_per_cpu_data(data);
-
-	if (skb)
-		genlmsg_multicast(&net_drop_monitor_family, skb, 0,
-				  0, GFP_KERNEL);
+	struct ns_pcpu_dm_data *pcpu_data;
+	struct per_ns_dm_cb *ns_dm_net;
+	struct ns_pcpu_dm_data *data;
+
+	for_each_net_rcu(net) {
+		ns_dm_net = net_generic(net, dm_net_id);
+		if (!ns_dm_net)
+			continue;
+		if (ns_dm_net->trace_state == TRACE_OFF)
+			continue;
+
+		pcpu_data = ns_dm_net->pcpu_data;
+		if (!pcpu_data)
+			continue;
+
+		data = (struct ns_pcpu_dm_data *)this_cpu_ptr(pcpu_data);
+		WARN_ON(data->net != net);
+		skb = reset_per_cpu_data(data);
+		if (skb)
+			genlmsg_multicast_netns(&net_drop_monitor_family, net,
+						skb, 0, 0, GFP_KERNEL);
+	}
 }
 
 /*
@@ -166,9 +182,15 @@ static void send_dm_alert(struct work_struct *work)
  */
 static void sched_send_work(unsigned long _data)
 {
-	struct per_cpu_dm_data *data = (struct per_cpu_dm_data *)_data;
+	int cpu;
+	struct per_cpu_dm_data *dm_data;
 
-	schedule_work(&data->dm_alert_work);
+	cpu = (int)_data;
+	if (unlikely(cpu < 0))
+		return;
+
+	dm_data = &per_cpu(dm_cpu_data, cpu);
+	schedule_work(&dm_data->dm_alert_work);
 }
 
 static void trace_drop_common(struct sk_buff *skb, void *location)
@@ -178,14 +200,30 @@ static void trace_drop_common(struct sk_buff *skb, void *location)
 	struct nlattr *nla;
 	int i;
 	struct sk_buff *dskb;
-	struct per_cpu_dm_data *data;
+	struct ns_pcpu_dm_data *data;
 	unsigned long flags;
+	struct net *net;
+	struct per_ns_dm_cb *ns_dm_net;
+
+	if (skb->dev)
+		net = dev_net(skb->dev);
+	else if (skb->sk)
+		net = sock_net(skb->sk);
+	else
+		return;
+
+	ns_dm_net = net_generic(net, dm_net_id);
+	if (unlikely(!ns_dm_net))
+		return;
+
+	data = this_cpu_ptr(ns_dm_net->pcpu_data);
+	if (unlikely(!data))
+		return;
 
 	local_irq_save(flags);
-	data = this_cpu_ptr(&dm_cpu_data);
 	spin_lock(&data->lock);
-	dskb = data->skb;
 
+	dskb = data->skb;
 	if (!dskb)
 		goto out;
 
@@ -465,7 +503,10 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 
 static int __net_init dm_net_init(struct net *net)
 {
+	int cpu;
+	struct ns_pcpu_dm_data *pcpu_data;
 	struct per_ns_dm_cb *ns_dm_cb;
+	struct ns_pcpu_dm_data *data;
 
 	ns_dm_cb = net_generic(net, dm_net_id);
 	if (!ns_dm_cb)
@@ -474,17 +515,45 @@ static int __net_init dm_net_init(struct net *net)
 	mutex_init(&ns_dm_cb->ns_dm_mutex);
 	ns_dm_cb->trace_state = TRACE_OFF;
 	INIT_LIST_HEAD(&ns_dm_cb->hw_stats_list);
+	pcpu_data = alloc_percpu(struct ns_pcpu_dm_data);
+	ns_dm_cb->pcpu_data = pcpu_data;
+	if (!pcpu_data)
+		return -ENOMEM;
+
+	for_each_possible_cpu(cpu) {
+		data = (struct ns_pcpu_dm_data *)per_cpu_ptr(pcpu_data, cpu);
+		spin_lock_init(&data->lock);
+		data->skb = NULL;
+		data->net = net;
+		setup_timer(&data->send_timer, sched_send_work,
+			    (unsigned long)cpu);
+		reset_per_cpu_data(data);
+	}
 
 	return 0;
 }
 
 static void __net_exit dm_net_exit(struct net *net)
 {
+	int cpu;
+	struct ns_pcpu_dm_data *pcpu_data;
 	struct per_ns_dm_cb *ns_dm_cb;
+	struct ns_pcpu_dm_data *data;
 
 	ns_dm_cb = net_generic(net, dm_net_id);
 	if (!ns_dm_cb)
 		return;
+
+	pcpu_data = ns_dm_cb->pcpu_data;
+	if (!pcpu_data)
+		return;
+
+	for_each_possible_cpu(cpu) {
+		data = (struct ns_pcpu_dm_data *)per_cpu_ptr(pcpu_data, cpu);
+		if (data->skb)
+			kfree_skb(data->skb);
+		del_timer_sync(&data->send_timer);;
+	}
 }
 
 static struct pernet_operations dm_net_ops = {
@@ -526,10 +595,6 @@ static int __init init_net_drop_monitor(void)
 	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
 		INIT_WORK(&data->dm_alert_work, send_dm_alert);
-		setup_timer(&data->send_timer, sched_send_work,
-			    (unsigned long)data);
-		spin_lock_init(&data->lock);
-		reset_per_cpu_data(data);
 	}
 
 
@@ -558,13 +623,7 @@ static void exit_net_drop_monitor(void)
 	unregister_pernet_subsys(&dm_net_ops);
 	for_each_possible_cpu(cpu) {
 		data = &per_cpu(dm_cpu_data, cpu);
-		del_timer_sync(&data->send_timer);
 		cancel_work_sync(&data->dm_alert_work);
-		/*
-		 * At this point, we should have exclusive access
-		 * to this struct and can free the skb inside it
-		 */
-		kfree_skb(data->skb);
 	}
 
 	BUG_ON(genl_unregister_family(&net_drop_monitor_family));
-- 
1.8.3.1
