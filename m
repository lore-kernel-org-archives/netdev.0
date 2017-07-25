From: martinbj2008@gmail.com
Subject: [PATCH v2 net-next 2/5] drop_monitor: let dm trace state support ns
Date: Tue, 25 Jul 2017 19:38:56 +0800
Message-ID: <1500982739-15805-2-git-send-email-zhangjunweimartin@didichuxing.com>
References: <1499855478-29736-1-git-send-email-zhangjunweimartin@didichuxing.com>
 <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Cc: netdev@vger.kernel.org,
        martin Zhang <zhangjunweimartin@didichuxing.com>
To: martinbj2008@gmail.com, davem@davemloft.net, nhorman@tuxdriver.com,
        xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:37179 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbdGYLjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 07:39:13 -0400
Received: by mail-pg0-f67.google.com with SMTP id g14so9610325pgu.4
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 04:39:12 -0700 (PDT)
In-Reply-To: <1500982739-15805-1-git-send-email-zhangjunweimartin@didichuxing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: martin Zhang <zhangjunweimartin@didichuxing.com>

Every net ns has its own trace_state,
and use a ref to control trace state of whole kernel.

trace_state in struct per_ns_dm_cb:
Just like the previous trace state, record the trace state for
every net ns. Possible values are ON/OFF.

dm_trace_ref: record how many net namespace is set to
TRACE_ON. increase when a net ns change to ON,
and decrease for OFF.

Signed-off-by: martin Zhang <zhangjunweimartin@didichuxing.com>
---
 net/core/drop_monitor.c | 88 +++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 75 insertions(+), 13 deletions(-)

diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
index 6a75e04..0cf25c3 100644
--- a/net/core/drop_monitor.c
+++ b/net/core/drop_monitor.c
@@ -49,10 +49,16 @@
 struct ns_pcpu_dm_data {
 };
 
+/**
+ * struct per_ns_dm_cb  - drop monitor control block in per net ns.
+ * @trace_state:    the trace state.
+ * @ns_dm_mutex:    protect whole per_ns_dm_cb.
+ */
 struct per_ns_dm_cb {
+	int trace_state;
+	struct mutex ns_dm_mutex;
 };
 
-static int trace_state = TRACE_OFF;
 static DEFINE_MUTEX(trace_state_mutex);
 
 struct per_cpu_dm_data {
@@ -70,6 +76,7 @@ struct dm_hw_stat_delta {
 	unsigned long last_drop_val;
 };
 
+int dm_trace_ref;
 static int dm_net_id __read_mostly;
 static struct genl_family net_drop_monitor_family;
 
@@ -254,9 +261,16 @@ static int set_all_monitor_traces(int state)
 
 	mutex_lock(&trace_state_mutex);
 
-	if (state == trace_state) {
-		rc = -EAGAIN;
-		goto out_unlock;
+	//Cases: Only inc/dec reference value.
+	if (state == TRACE_ON && dm_trace_ref > 0)
+		goto skip_register_trace;
+	else if (state == TRACE_OFF && dm_trace_ref > 1)
+		goto skip_register_trace;
+
+	//Bad cases.
+	if (dm_trace_ref < 0 || (dm_trace_ref == 0 && state == TRACE_OFF)) {
+		rc = -EINPROGRESS;
+		goto skip_register_trace;
 	}
 
 	switch (state) {
@@ -294,12 +308,15 @@ static int set_all_monitor_traces(int state)
 		break;
 	}
 
-	if (!rc)
-		trace_state = state;
-	else
+skip_register_trace:
+	if (!rc) {
+		if (state == TRACE_ON)
+			dm_trace_ref++;
+		else if (state == TRACE_OFF)
+			dm_trace_ref--;
+	} else
 		rc = -EINPROGRESS;
 
-out_unlock:
 	mutex_unlock(&trace_state_mutex);
 
 	return rc;
@@ -315,22 +332,65 @@ static int net_dm_cmd_config(struct sk_buff *skb,
 static int net_dm_cmd_trace(struct sk_buff *skb,
 			struct genl_info *info)
 {
+	int state;
+	struct net *net;
+	struct per_ns_dm_cb *ns_dm_cb;
+
+	if (!skb->sk)
+		return -ENOTSUPP;
+	net = sock_net(skb->sk);
+	ns_dm_cb = net_generic(net, dm_net_id);
+
+	if (!ns_dm_cb)
+		return -ENOMEM;
+
 	switch (info->genlhdr->cmd) {
 	case NET_DM_CMD_START:
-		return set_all_monitor_traces(TRACE_ON);
+		state = TRACE_ON;
+		break;
+
 	case NET_DM_CMD_STOP:
-		return set_all_monitor_traces(TRACE_OFF);
+		state = TRACE_OFF;
+		break;
+
+	default:
+		return -ENOTSUPP;
 	}
 
-	return -ENOTSUPP;
+	mutex_lock(&ns_dm_cb->ns_dm_mutex);
+	if (state == ns_dm_cb->trace_state) {
+		mutex_unlock(&ns_dm_cb->ns_dm_mutex);
+		return -EAGAIN;
+	}
+
+	if (set_all_monitor_traces(state) != 0) {
+		mutex_unlock(&ns_dm_cb->ns_dm_mutex);
+		return -ENOTSUPP;
+	}
+
+	ns_dm_cb->trace_state = state;
+	mutex_unlock(&ns_dm_cb->ns_dm_mutex);
+
+	return 0;
 }
 
 static int dropmon_net_event(struct notifier_block *ev_block,
 			     unsigned long event, void *ptr)
 {
-	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+	struct net *net;
+	struct net_device *dev;
 	struct dm_hw_stat_delta *new_stat = NULL;
 	struct dm_hw_stat_delta *tmp;
+	struct per_ns_dm_cb *ns_dm_cb;
+
+	dev = netdev_notifier_info_to_dev(ptr);
+	if (!dev)
+		goto out;
+
+	net = dev_net(dev);
+	ns_dm_cb = net_generic(net, dm_net_id);
+	if (!ns_dm_cb)
+		goto out;
 
 	switch (event) {
 	case NETDEV_REGISTER:
@@ -350,7 +410,7 @@ static int dropmon_net_event(struct notifier_block *ev_block,
 		list_for_each_entry_safe(new_stat, tmp, &hw_stats_list, list) {
 			if (new_stat->dev == dev) {
 				new_stat->dev = NULL;
-				if (trace_state == TRACE_OFF) {
+				if (ns_dm_cb->trace_state == TRACE_OFF) {
 					list_del_rcu(&new_stat->list);
 					kfree_rcu(new_stat, rcu);
 					break;
@@ -402,6 +462,7 @@ static int __net_init dm_net_init(struct net *net)
 	if (!ns_dm_cb)
 		return -ENOMEM;
 
+	ns_dm_cb->trace_state = TRACE_OFF;
 	return 0;
 }
 
@@ -432,6 +493,7 @@ static int __init init_net_drop_monitor(void)
 		pr_err("Unable to store program counters on this arch, Drop monitor failed\n");
 		return -ENOSPC;
 	}
+	dm_trace_ref = 0;
 	rc = register_pernet_subsys(&dm_net_ops);
 
 	rc = genl_register_family(&net_drop_monitor_family);
-- 
1.8.3.1
