From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 7/9] switchdev: add swdev features
Date: Fri, 19 Sep 2014 15:49:48 +0200
Message-ID: <1411134590-4586-8-git-send-email-jiri@resnulli.us>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@cumulusnetworks.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, dev@openvswitch.org, jasowang@redhat.com,
	ebiederm@xmission.com, nicolas.dichtel@6wind.com,
	ryazanov.s.a@gmail.com, buytenh@wantstofly.org,
	aviadr@mellanox.com, nbd@openwrt.org, alexei.starovoitov@gmail.com,
	Neil.Jerram@metaswitch.com, ronye@mellanox.com,
	simon.horman@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:41433 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756107AbaISNuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 09:50:03 -0400
Received: by mail-we0-f173.google.com with SMTP id t60so2503067wes.32
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 06:50:01 -0700 (PDT)
In-Reply-To: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver should define ndo_swdev_festures_get and indicate which switch
features it supports.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/netdevice.h |  5 +++++
 include/net/switchdev.h   | 18 ++++++++++++++++++
 net/switchdev/switchdev.c | 33 +++++++++++++++++++++++++++++++++
 3 files changed, 56 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 034baca..b87d0cc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1006,6 +1006,10 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	If driver implements this, it indicates that it represents a port
  *	of a switch chip.
  *
+ * swdev_features_t (*ndo_swdev_features_get)(struct net_device *dev);
+ *	Called to get a list of features the switch chip this port is part of
+ *	supports.
+ *
  * int (*ndo_swdev_flow_insert)(struct net_device *dev,
  *				const struct swdev_flow *flow);
  *	Called to insert a flow into switch device. If driver does
@@ -1169,6 +1173,7 @@ struct net_device_ops {
 #ifdef CONFIG_NET_SWITCHDEV
 	int			(*ndo_swdev_id_get)(struct net_device *dev,
 						    struct netdev_phys_item_id *psid);
+	swdev_features_t	(*ndo_swdev_features_get)(struct net_device *dev);
 	int			(*ndo_swdev_flow_insert)(struct net_device *dev,
 							 const struct swdev_flow *flow);
 	int			(*ndo_swdev_flow_remove)(struct net_device *dev,
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 060d3fc..91cdb47 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -12,6 +12,18 @@
 
 #include <linux/netdevice.h>
 
+typedef u64 swdev_features_t;
+
+enum {
+	SWDEV_F_FLOW_MATCH_KEY_BIT,	/* Supports fixed key match */
+	/**/SWDEV_FEATURE_COUNT
+};
+
+#define __SWDEV_F_BIT(bit)	((swdev_features_t)1 << (bit))
+#define __SWDEV_F(name)		__SWDEV_F_BIT(SWDEV_F_##name##_BIT)
+
+#define SWDEV_F_FLOW_MATCH_KEY	__SWDEV_F(FLOW_MATCH_KEY)
+
 struct swdev_flow_match_key {
 	struct {
 		u32	priority;	/* Packet QoS priority. */
@@ -114,6 +126,7 @@ static inline struct swdev_flow *swdev_flow_alloc(unsigned action_count,
 #ifdef CONFIG_NET_SWITCHDEV
 
 int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid);
+swdev_features_t swdev_features_get(struct net_device *dev);
 int swdev_flow_insert(struct net_device *dev, const struct swdev_flow *flow);
 int swdev_flow_remove(struct net_device *dev, const struct swdev_flow *flow);
 
@@ -125,6 +138,11 @@ static inline int swdev_id_get(struct net_device *dev,
 	return -EOPNOTSUPP;
 }
 
+static inline swdev_features_t swdev_features_get(struct net_device *dev)
+{
+	return 0;
+}
+
 static inline int swdev_flow_insert(struct net_device *dev,
 				    const struct swdev_flow *flow)
 {
diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
index 90bc5e4..5348125 100644
--- a/net/switchdev/switchdev.c
+++ b/net/switchdev/switchdev.c
@@ -31,6 +31,22 @@ int swdev_id_get(struct net_device *dev, struct netdev_phys_item_id *psid)
 }
 EXPORT_SYMBOL(swdev_id_get);
 
+/**
+ *	swdev_features_get - Get list of features switch supports
+ *	@dev: port device
+ *
+ *	Get list of features switch this port is part of supports.
+ */
+swdev_features_t swdev_features_get(struct net_device *dev)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (!ops->ndo_swdev_features_get)
+		return 0;
+	return ops->ndo_swdev_features_get(dev);
+}
+EXPORT_SYMBOL(swdev_features_get);
+
 static void print_flow_key_phy(const char *prefix,
 			       const struct swdev_flow_match_key *key)
 {
@@ -116,6 +132,15 @@ static void print_flow(const struct swdev_flow *flow, struct net_device *dev,
 	print_flow_actions(flow->action, flow->action_count);
 }
 
+static int check_match_type_features(struct net_device *dev,
+				     const struct swdev_flow *flow)
+{
+	if (flow->match.type == SW_FLOW_MATCH_TYPE_KEY &&
+	    !(swdev_features_get(dev) & SWDEV_F_FLOW_MATCH_KEY))
+		return -EOPNOTSUPP;
+	return 0;
+}
+
 /**
  *	swdev_flow_insert - Insert a flow into switch
  *	@dev: port device
@@ -126,10 +151,14 @@ static void print_flow(const struct swdev_flow *flow, struct net_device *dev,
 int swdev_flow_insert(struct net_device *dev, const struct swdev_flow *flow)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	int err;
 
 	print_flow(flow, dev, "insert");
 	if (!ops->ndo_swdev_flow_insert)
 		return -EOPNOTSUPP;
+	err = check_match_type_features(dev, flow);
+	if (err)
+		return err;
 	WARN_ON(!ops->ndo_swdev_id_get);
 	return ops->ndo_swdev_flow_insert(dev, flow);
 }
@@ -145,10 +174,14 @@ EXPORT_SYMBOL(swdev_flow_insert);
 int swdev_flow_remove(struct net_device *dev, const struct swdev_flow *flow)
 {
 	const struct net_device_ops *ops = dev->netdev_ops;
+	int err;
 
 	print_flow(flow, dev, "remove");
 	if (!ops->ndo_swdev_flow_remove)
 		return -EOPNOTSUPP;
+	err = check_match_type_features(dev, flow);
+	if (err)
+		return err;
 	WARN_ON(!ops->ndo_swdev_id_get);
 	return ops->ndo_swdev_flow_remove(dev, flow);
 }
-- 
1.9.3
