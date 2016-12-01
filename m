From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH net-next V2 5/8] net/sched: cls_flower: Add offload support using egress Hardware device
Date: Thu,  1 Dec 2016 14:06:37 +0200
Message-ID: <1480594000-8428-6-git-send-email-hadarh@mellanox.com>
References: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45355 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758790AbcLANCb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 08:02:31 -0500
In-Reply-To: <1480594000-8428-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support hardware offloading when the device given by the tc
rule is different from the Hardware underline device, extract the mirred
(egress) device from the tc action when a filter is added, using the new
tc_action_ops, get_dev().

Flower caches the information about the mirred device and use it for
calling ndo_setup_tc in filter change, update stats and delete.

Calling ndo_setup_tc of the mirred (egress) device instead of the
ingress device will allow a resolution between the software ingress
device and the underline hardware device.

The resolution will take place inside the offloading driver using
'egress_device' flag added to tc_to_netdev struct which is provided to
the offloading driver.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Acked-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/netdevice.h |  1 +
 include/net/pkt_cls.h     |  2 ++
 net/sched/cls_api.c       | 24 ++++++++++++++++++++++++
 net/sched/cls_flower.c    | 41 ++++++++++++++++++++++++-----------------
 4 files changed, 51 insertions(+), 17 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3755317..1ff5ea6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -802,6 +802,7 @@ struct tc_to_netdev {
 		struct tc_cls_matchall_offload *cls_mall;
 		struct tc_cls_bpf_offload *cls_bpf;
 	};
+	bool egress_dev;
 };
 
 /* These structures hold the attributes of xdp state that are being passed
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index 45ad9aa..f0a0514 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -171,6 +171,8 @@ void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
 		     struct tcf_exts *src);
 int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
+int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
+		     struct net_device **hw_dev);
 
 /**
  * struct tcf_pkt_info - packet information
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index b05d4a2..3fbba79 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -682,6 +682,30 @@ int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts)
 }
 EXPORT_SYMBOL(tcf_exts_dump_stats);
 
+int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
+		     struct net_device **hw_dev)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	const struct tc_action *a;
+	LIST_HEAD(actions);
+
+	if (tc_no_actions(exts))
+		return -EINVAL;
+
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
+		if (a->ops->get_dev) {
+			a->ops->get_dev(a, dev_net(dev), hw_dev);
+			break;
+		}
+	}
+	if (*hw_dev)
+		return 0;
+#endif
+	return -EOPNOTSUPP;
+}
+EXPORT_SYMBOL(tcf_exts_get_dev);
+
 static int __init tc_filter_init(void)
 {
 	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, NULL);
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 13b349f..1cacfa5 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -78,6 +78,8 @@ struct cls_fl_filter {
 	u32 handle;
 	u32 flags;
 	struct rcu_head	rcu;
+	struct tc_to_netdev tc;
+	struct net_device *hw_dev;
 };
 
 static unsigned short int fl_mask_range(const struct fl_flow_mask *mask)
@@ -203,9 +205,9 @@ static void fl_destroy_filter(struct rcu_head *head)
 
 static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
-	struct tc_to_netdev tc;
+	struct net_device *dev = f->hw_dev;
+	struct tc_to_netdev *tc = &f->tc;
 
 	if (!tc_can_offload(dev, tp))
 		return;
@@ -213,10 +215,10 @@ static void fl_hw_destroy_filter(struct tcf_proto *tp, struct cls_fl_filter *f)
 	offload.command = TC_CLSFLOWER_DESTROY;
 	offload.cookie = (unsigned long)f;
 
-	tc.type = TC_SETUP_CLSFLOWER;
-	tc.cls_flower = &offload;
+	tc->type = TC_SETUP_CLSFLOWER;
+	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, tc);
 }
 
 static int fl_hw_replace_filter(struct tcf_proto *tp,
@@ -226,11 +228,17 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 {
 	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
-	struct tc_to_netdev tc;
+	struct tc_to_netdev *tc = &f->tc;
 	int err;
 
-	if (!tc_can_offload(dev, tp))
-		return tc_skip_sw(f->flags) ? -EINVAL : 0;
+	if (!tc_can_offload(dev, tp)) {
+		if (tcf_exts_get_dev(dev, &f->exts, &f->hw_dev))
+			return tc_skip_sw(f->flags) ? -EINVAL : 0;
+		dev = f->hw_dev;
+		tc->egress_dev = true;
+	} else {
+		f->hw_dev = dev;
+	}
 
 	offload.command = TC_CLSFLOWER_REPLACE;
 	offload.cookie = (unsigned long)f;
@@ -239,23 +247,22 @@ static int fl_hw_replace_filter(struct tcf_proto *tp,
 	offload.key = &f->key;
 	offload.exts = &f->exts;
 
-	tc.type = TC_SETUP_CLSFLOWER;
-	tc.cls_flower = &offload;
+	tc->type = TC_SETUP_CLSFLOWER;
+	tc->cls_flower = &offload;
 
 	err = dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol,
-					    &tc);
+					    tc);
 
 	if (tc_skip_sw(f->flags))
 		return err;
-
 	return 0;
 }
 
 static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 {
-	struct net_device *dev = tp->q->dev_queue->dev;
 	struct tc_cls_flower_offload offload = {0};
-	struct tc_to_netdev tc;
+	struct net_device *dev = f->hw_dev;
+	struct tc_to_netdev *tc = &f->tc;
 
 	if (!tc_can_offload(dev, tp))
 		return;
@@ -264,10 +271,10 @@ static void fl_hw_update_stats(struct tcf_proto *tp, struct cls_fl_filter *f)
 	offload.cookie = (unsigned long)f;
 	offload.exts = &f->exts;
 
-	tc.type = TC_SETUP_CLSFLOWER;
-	tc.cls_flower = &offload;
+	tc->type = TC_SETUP_CLSFLOWER;
+	tc->cls_flower = &offload;
 
-	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, &tc);
+	dev->netdev_ops->ndo_setup_tc(dev, tp->q->handle, tp->protocol, tc);
 }
 
 static void __fl_delete(struct tcf_proto *tp, struct cls_fl_filter *f)
-- 
1.8.3.1
