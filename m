From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 2/4] net: sched: introduce per-egress action device callbacks
Date: Wed, 11 Oct 2017 09:41:08 +0200
Message-ID: <20171011074110.2800-3-jiri@resnulli.us>
References: <20171011074110.2800-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        mlxsw@mellanox.com, David.Laight@ACULAB.COM, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:50263 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751030AbdJKHlO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 03:41:14 -0400
Received: by mail-wm0-f67.google.com with SMTP id u138so2567408wmu.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 00:41:14 -0700 (PDT)
In-Reply-To: <20171011074110.2800-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce infrastructure that allows drivers to register callbacks that
are called whenever tc would offload inserted rule and specified device
acts as tc action egress device.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- take rtnl for register/unregister
---
 include/net/act_api.h |  34 ++++++++
 include/net/pkt_cls.h |   2 +
 net/sched/act_api.c   | 220 ++++++++++++++++++++++++++++++++++++++++++++++++++
 net/sched/cls_api.c   |  30 +++++++
 4 files changed, 286 insertions(+)

diff --git a/include/net/act_api.h b/include/net/act_api.h
index 900168a..f5e8c90 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -174,4 +174,38 @@ static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 #endif
 }
 
+typedef int tc_setup_cb_t(enum tc_setup_type type,
+			  void *type_data, void *cb_priv);
+
+#ifdef CONFIG_NET_CLS_ACT
+int tc_setup_cb_egdev_register(const struct net_device *dev,
+			       tc_setup_cb_t *cb, void *cb_priv);
+void tc_setup_cb_egdev_unregister(const struct net_device *dev,
+				  tc_setup_cb_t *cb, void *cb_priv);
+int tc_setup_cb_egdev_call(const struct net_device *dev,
+			   enum tc_setup_type type, void *type_data,
+			   bool err_stop);
+#else
+static inline
+int tc_setup_cb_egdev_register(const struct net_device *dev,
+			       tc_setup_cb_t *cb, void *cb_priv)
+{
+	return 0;
+}
+
+static inline
+void tc_setup_cb_egdev_unregister(const struct net_device *dev,
+				  tc_setup_cb_t *cb, void *cb_priv)
+{
+}
+
+static inline
+int tc_setup_cb_egdev_call(const struct net_device *dev,
+			   enum tc_setup_type type, void *type_data,
+			   bool err_stop)
+{
+	return 0;
+}
+#endif
+
 #endif
diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index e80edd8..6f8149c 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -206,6 +206,8 @@ int tcf_exts_dump(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_dump_stats(struct sk_buff *skb, struct tcf_exts *exts);
 int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 		     struct net_device **hw_dev);
+int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
+			   void *type_data, bool err_stop);
 
 /**
  * struct tcf_pkt_info - packet information
diff --git a/net/sched/act_api.c b/net/sched/act_api.c
index da6fa82..ac97db9 100644
--- a/net/sched/act_api.c
+++ b/net/sched/act_api.c
@@ -21,6 +21,8 @@
 #include <linux/kmod.h>
 #include <linux/err.h>
 #include <linux/module.h>
+#include <linux/rhashtable.h>
+#include <linux/list.h>
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <net/sch_generic.h>
@@ -1249,8 +1251,226 @@ static int tc_dump_action(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+struct tcf_action_net {
+	struct rhashtable egdev_ht;
+};
+
+static unsigned int tcf_action_net_id;
+
+struct tcf_action_egdev_cb {
+	struct list_head list;
+	tc_setup_cb_t *cb;
+	void *cb_priv;
+};
+
+struct tcf_action_egdev {
+	struct rhash_head ht_node;
+	const struct net_device *dev;
+	unsigned int refcnt;
+	struct list_head cb_list;
+};
+
+static const struct rhashtable_params tcf_action_egdev_ht_params = {
+	.key_offset = offsetof(struct tcf_action_egdev, dev),
+	.head_offset = offsetof(struct tcf_action_egdev, ht_node),
+	.key_len = sizeof(const struct net_device *),
+};
+
+static struct tcf_action_egdev *
+tcf_action_egdev_lookup(const struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct tcf_action_net *tan = net_generic(net, tcf_action_net_id);
+
+	return rhashtable_lookup_fast(&tan->egdev_ht, &dev,
+				      tcf_action_egdev_ht_params);
+}
+
+static struct tcf_action_egdev *
+tcf_action_egdev_get(const struct net_device *dev)
+{
+	struct tcf_action_egdev *egdev;
+	struct tcf_action_net *tan;
+
+	egdev = tcf_action_egdev_lookup(dev);
+	if (egdev)
+		goto inc_ref;
+
+	egdev = kzalloc(sizeof(*egdev), GFP_KERNEL);
+	if (!egdev)
+		return NULL;
+	INIT_LIST_HEAD(&egdev->cb_list);
+	tan = net_generic(dev_net(dev), tcf_action_net_id);
+	rhashtable_insert_fast(&tan->egdev_ht, &egdev->ht_node,
+			       tcf_action_egdev_ht_params);
+
+inc_ref:
+	egdev->refcnt++;
+	return egdev;
+}
+
+static void tcf_action_egdev_put(struct tcf_action_egdev *egdev)
+{
+	struct tcf_action_net *tan;
+
+	if (--egdev->refcnt)
+		return;
+	tan = net_generic(dev_net(egdev->dev), tcf_action_net_id);
+	rhashtable_remove_fast(&tan->egdev_ht, &egdev->ht_node,
+			       tcf_action_egdev_ht_params);
+	kfree(egdev);
+}
+
+static struct tcf_action_egdev_cb *
+tcf_action_egdev_cb_lookup(struct tcf_action_egdev *egdev,
+			   tc_setup_cb_t *cb, void *cb_priv)
+{
+	struct tcf_action_egdev_cb *egdev_cb;
+
+	list_for_each_entry(egdev_cb, &egdev->cb_list, list)
+		if (egdev_cb->cb == cb && egdev_cb->cb_priv == cb_priv)
+			return egdev_cb;
+	return NULL;
+}
+
+static int tcf_action_egdev_cb_call(struct tcf_action_egdev *egdev,
+				    enum tc_setup_type type,
+				    void *type_data, bool err_stop)
+{
+	struct tcf_action_egdev_cb *egdev_cb;
+	int ok_count = 0;
+	int err;
+
+	list_for_each_entry(egdev_cb, &egdev->cb_list, list) {
+		err = egdev_cb->cb(type, type_data, egdev_cb->cb_priv);
+		if (err) {
+			if (err_stop)
+				return err;
+		} else {
+			ok_count++;
+		}
+	}
+	return ok_count;
+}
+
+static int tcf_action_egdev_cb_add(struct tcf_action_egdev *egdev,
+				   tc_setup_cb_t *cb, void *cb_priv)
+{
+	struct tcf_action_egdev_cb *egdev_cb;
+
+	egdev_cb = tcf_action_egdev_cb_lookup(egdev, cb, cb_priv);
+	if (WARN_ON(egdev_cb))
+		return -EEXIST;
+	egdev_cb = kzalloc(sizeof(*egdev_cb), GFP_KERNEL);
+	if (!egdev_cb)
+		return -ENOMEM;
+	egdev_cb->cb = cb;
+	egdev_cb->cb_priv = cb_priv;
+	list_add(&egdev_cb->list, &egdev->cb_list);
+	return 0;
+}
+
+static void tcf_action_egdev_cb_del(struct tcf_action_egdev *egdev,
+				    tc_setup_cb_t *cb, void *cb_priv)
+{
+	struct tcf_action_egdev_cb *egdev_cb;
+
+	egdev_cb = tcf_action_egdev_cb_lookup(egdev, cb, cb_priv);
+	if (WARN_ON(!egdev_cb))
+		return;
+	list_del(&egdev_cb->list);
+	kfree(egdev_cb);
+}
+
+static int __tc_setup_cb_egdev_register(const struct net_device *dev,
+					tc_setup_cb_t *cb, void *cb_priv)
+{
+	struct tcf_action_egdev *egdev = tcf_action_egdev_get(dev);
+	int err;
+
+	if (!egdev)
+		return -ENOMEM;
+	err = tcf_action_egdev_cb_add(egdev, cb, cb_priv);
+	if (err)
+		goto err_cb_add;
+	return 0;
+
+err_cb_add:
+	tcf_action_egdev_put(egdev);
+	return err;
+}
+int tc_setup_cb_egdev_register(const struct net_device *dev,
+			       tc_setup_cb_t *cb, void *cb_priv)
+{
+	int err;
+
+	rtnl_lock();
+	err = __tc_setup_cb_egdev_register(dev, cb, cb_priv);
+	rtnl_unlock();
+	return err;
+}
+EXPORT_SYMBOL_GPL(tc_setup_cb_egdev_register);
+
+static void __tc_setup_cb_egdev_unregister(const struct net_device *dev,
+					   tc_setup_cb_t *cb, void *cb_priv)
+{
+	struct tcf_action_egdev *egdev = tcf_action_egdev_lookup(dev);
+
+	if (WARN_ON(!egdev))
+		return;
+	tcf_action_egdev_cb_del(egdev, cb, cb_priv);
+	tcf_action_egdev_put(egdev);
+}
+void tc_setup_cb_egdev_unregister(const struct net_device *dev,
+				  tc_setup_cb_t *cb, void *cb_priv)
+{
+	rtnl_lock();
+	__tc_setup_cb_egdev_unregister(dev, cb, cb_priv);
+	rtnl_unlock();
+}
+EXPORT_SYMBOL_GPL(tc_setup_cb_egdev_unregister);
+
+int tc_setup_cb_egdev_call(const struct net_device *dev,
+			   enum tc_setup_type type, void *type_data,
+			   bool err_stop)
+{
+	struct tcf_action_egdev *egdev = tcf_action_egdev_lookup(dev);
+
+	if (!egdev)
+		return 0;
+	return tcf_action_egdev_cb_call(egdev, type, type_data, err_stop);
+}
+EXPORT_SYMBOL_GPL(tc_setup_cb_egdev_call);
+
+static __net_init int tcf_action_net_init(struct net *net)
+{
+	struct tcf_action_net *tan = net_generic(net, tcf_action_net_id);
+
+	return rhashtable_init(&tan->egdev_ht, &tcf_action_egdev_ht_params);
+}
+
+static void __net_exit tcf_action_net_exit(struct net *net)
+{
+	struct tcf_action_net *tan = net_generic(net, tcf_action_net_id);
+
+	rhashtable_destroy(&tan->egdev_ht);
+}
+
+static struct pernet_operations tcf_action_net_ops = {
+	.init = tcf_action_net_init,
+	.exit = tcf_action_net_exit,
+	.id = &tcf_action_net_id,
+	.size = sizeof(struct tcf_action_net),
+};
+
 static int __init tc_action_init(void)
 {
+	int err;
+
+	err = register_pernet_subsys(&tcf_action_net_ops);
+	if (err)
+		return err;
+
 	rtnl_register(PF_UNSPEC, RTM_NEWACTION, tc_ctl_action, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_DELACTION, tc_ctl_action, NULL, 0);
 	rtnl_register(PF_UNSPEC, RTM_GETACTION, tc_ctl_action, tc_dump_action,
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 450873b..99f9432 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -1026,6 +1026,36 @@ int tcf_exts_get_dev(struct net_device *dev, struct tcf_exts *exts,
 }
 EXPORT_SYMBOL(tcf_exts_get_dev);
 
+int tcf_exts_egdev_cb_call(struct tcf_exts *exts, enum tc_setup_type type,
+			   void *type_data, bool err_stop)
+{
+	int ok_count = 0;
+#ifdef CONFIG_NET_CLS_ACT
+	const struct tc_action *a;
+	struct net_device *dev;
+	LIST_HEAD(actions);
+	int ret;
+
+	if (!tcf_exts_has_actions(exts))
+		return 0;
+
+	tcf_exts_to_list(exts, &actions);
+	list_for_each_entry(a, &actions, list) {
+		if (!a->ops->get_dev)
+			continue;
+		dev = a->ops->get_dev(a);
+		if (!dev || !tc_can_offload(dev))
+			continue;
+		ret = tc_setup_cb_egdev_call(dev, type, type_data, err_stop);
+		if (ret < 0)
+			return ret;
+		ok_count += ret;
+	}
+#endif
+	return ok_count;
+}
+EXPORT_SYMBOL(tcf_exts_egdev_cb_call);
+
 static int __init tc_filter_init(void)
 {
 	rtnl_register(PF_UNSPEC, RTM_NEWTFILTER, tc_ctl_tfilter, NULL, 0);
-- 
2.9.5
