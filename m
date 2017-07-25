From: martinbj2008@gmail.com
Subject: [PATCH v2 net-next 3/5] drop_monitor: let hw_stats_list support net ns
Date: Tue, 25 Jul 2017 19:38:57 +0800
Message-ID: <1500982739-15805-3-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499855478-29736-1-git-send-email-zhangjunweimartin@didichuxing.com>
 <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org,
        martin Zhang <zhangjunweimartin@didichuxing.com>
To: martinbj2008@gmail.com, davem@davemloft.net, nhorman@tuxdriver.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34868 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751655AbdGYLjR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:39:17 -0400
Received: by mail-pg0-f65.google.com with SMTP id d193so14248071pgc.2
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:39:17 -0700 (PDT)
In-Reply-To: <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin Zhang <zhangjunweimartin@didichuxing.com>

hw_stats_list is used to record NAPI state for net device.
Every net device belongs to one net ns.
so every net ns has a list head to record them.

Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
---
 net/core/drop_monitor.c | 54 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 21 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 0cf25c3..875e8b4 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -53,10 +53,12 @@ struct ns_pcpu_dm_data {
  * struct per_ns_dm_cb  - drop monitor control block in per net ns.
  * @trace_state:    the trace state.
  * @ns_dm_mutex:    protect whole per_ns_dm_cb.
+ * @hw_stats_list:  monitor for NAPI of net device.
  */
 struct per_ns_dm_cb {
 	int trace_state;
 	struct mutex ns_dm_mutex;
+	struct list_head hw_stats_list;
 };
 
 static DEFINE_MUTEX(trace_state_mutex);
@@ -85,7 +87,6 @@ struct dm_hw_stat_delta {
 static int dm_hit_limit = 64;
 static int dm_delay = 1;
 static unsigned long dm_hw_check_delta = 2*HZ;
-static LIST_HEAD(hw_stats_list);
 
 static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
 {
@@ -225,16 +226,22 @@ static void trace_kfree_skb_hit(void *ignore, struct sk_buff *skb, void *locatio
 static void trace_napi_poll_hit(void *ignore, struct napi_struct *napi,
 				int work, int budget)
 {
+	struct net *net;
 	struct dm_hw_stat_delta *new_stat;
+	struct per_ns_dm_cb *ns_dm_net;
 
 	/*
 	 * Don't check napi structures with no associated device
 	 */
 	if (!napi->dev)
 		return;
+	net = dev_net(napi->dev);
+	ns_dm_net = net_generic(net, dm_net_id);
+	if (!ns_dm_net)
+		return;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
+	list_for_each_entry_rcu(new_stat, &ns_dm_net->hw_stats_list, list) {
 		/*
 		 * only add a note to our monitor buffer if:
 		 * 1) this is the dev we received on
@@ -256,8 +263,6 @@ static void trace_napi_poll_hit(void *ignore, struct napi_struct *napi,
 static int set_all_monitor_traces(int state)
 {
 	int rc = 0;
-	struct dm_hw_stat_delta *new_stat = NULL;
-	struct dm_hw_stat_delta *temp;
 
 	mutex_lock(&trace_state_mutex);
 
@@ -290,16 +295,6 @@ static int set_all_monitor_traces(int state)
 
 		tracepoint_synchronize_unregister();
 
-		/*
-		 * Clean the device list
-		 */
-		list_for_each_entry_safe(new_stat, temp, &hw_stats_list, list) {
-			if (new_stat->dev == NULL) {
-				list_del_rcu(&new_stat->list);
-				kfree_rcu(new_stat, rcu);
-			}
-		}
-
 		module_put(THIS_MODULE);
 
 		break;
@@ -368,6 +363,19 @@ static int net_dm_cmd_trace(struct sk_buff *skb,
 		return -ENOTSUPP;
 	}
 
+	if (state == TRACE_OFF) {
+		/* Clean the device list */
+		struct dm_hw_stat_delta *new_stat = NULL;
+		struct dm_hw_stat_delta *temp;
+		struct list_head *head = &ns_dm_cb->hw_stats_list;
+
+		list_for_each_entry_safe(new_stat, temp, head, list) {
+			if (!new_stat->dev) {
+				list_del_rcu(&new_stat->list);
+				kfree_rcu(new_stat, rcu);
+			}
+		}
+	}
 	ns_dm_cb->trace_state = state;
 	mutex_unlock(&ns_dm_cb->ns_dm_mutex);
 
@@ -382,6 +390,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 	struct dm_hw_stat_delta *new_stat = NULL;
 	struct dm_hw_stat_delta *tmp;
 	struct per_ns_dm_cb *ns_dm_cb;
+	struct list_head *head;
 
 	dev = netdev_notifier_info_to_dev(ptr);
 	if (!dev)
@@ -391,23 +400,23 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 	ns_dm_cb = net_generic(net, dm_net_id);
 	if (!ns_dm_cb)
 		goto out;
+	head = &ns_dm_cb->hw_stats_list;
 
 	switch (event) {
 	case NETDEV_REGISTER:
 		new_stat = kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
-
 		if (!new_stat)
 			goto out;
 
 		new_stat->dev = dev;
 		new_stat->last_rx = jiffies;
-		mutex_lock(&trace_state_mutex);
-		list_add_rcu(&new_stat->list, &hw_stats_list);
-		mutex_unlock(&trace_state_mutex);
+		mutex_lock(&ns_dm_cb->ns_dm_mutex);
+		list_add_rcu(&new_stat->list, head);
+		mutex_unlock(&ns_dm_cb->ns_dm_mutex);
 		break;
 	case NETDEV_UNREGISTER:
-		mutex_lock(&trace_state_mutex);
-		list_for_each_entry_safe(new_stat, tmp, &hw_stats_list, list) {
+		mutex_lock(&ns_dm_cb->ns_dm_mutex);
+		list_for_each_entry_safe(new_stat, tmp, head, list) {
 			if (new_stat->dev == dev) {
 				new_stat->dev = NULL;
 				if (ns_dm_cb->trace_state == TRACE_OFF) {
@@ -417,7 +426,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 				}
 			}
 		}
-		mutex_unlock(&trace_state_mutex);
+		mutex_unlock(&ns_dm_cb->ns_dm_mutex);
 		break;
 	}
 out:
@@ -462,7 +471,10 @@ static int __net_init dm_net_init(struct net *net)
 	if (!ns_dm_cb)
 		return -ENOMEM;
 
+	mutex_init(&ns_dm_cb->ns_dm_mutex);
 	ns_dm_cb->trace_state = TRACE_OFF;
+	INIT_LIST_HEAD(&ns_dm_cb->hw_stats_list);
+
 	return 0;
 }
 
-- 
1.8.3.1
