From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 2/9] net-ethtool: Convert (hw_/vlan_/wanted_)features fields from u32 type to u64.
Date: Fri, 22 Apr 2011 16:36:00 -0700
Message-ID: <1303515367-25595-3-git-send-email-maheshb@google.com>
References: <1303515367-25595-1-git-send-email-maheshb@google.com>
 <1303515367-25595-2-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:35995 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755450Ab1DVXgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 19:36:17 -0400
In-Reply-To: <1303515367-25595-2-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/ethtool.h |   26 +++++++------
 net/core/ethtool.c      |   89 ++++++++++++++++------------------------------
 2 files changed, 45 insertions(+), 70 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 9de3127..71e8a02 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -605,10 +605,10 @@ struct ethtool_flash {
  * @never_changed: mask of features not changeable for any device
  */
 struct ethtool_get_features_block {
-	__u32	available;
-	__u32	requested;
-	__u32	active;
-	__u32	never_changed;
+	__u64	available;
+	__u64	requested;
+	__u64	active;
+	__u64	never_changed;
 };
 
 /**
@@ -618,10 +618,11 @@ struct ethtool_get_features_block {
  *       out: number of elements in features[] needed to hold all features
  * @features: state of features
  */
+/* TODO Why is this needed XXX */
 struct ethtool_gfeatures {
 	__u32	cmd;
 	__u32	size;
-	struct ethtool_get_features_block features[0];
+	struct ethtool_get_features_block features;
 };
 
 /**
@@ -630,8 +631,8 @@ struct ethtool_gfeatures {
  * @requested: values of features to be changed
  */
 struct ethtool_set_features_block {
-	__u32	valid;
-	__u32	requested;
+	__u64	valid;
+	__u64	requested;
 };
 
 /**
@@ -640,10 +641,11 @@ struct ethtool_set_features_block {
  * @size: array size of the features[] array
  * @features: feature change masks
  */
+/* TODO Why is this needed XXX */
 struct ethtool_sfeatures {
 	__u32	cmd;
 	__u32	size;
-	struct ethtool_set_features_block features[0];
+	struct ethtool_set_features_block features;
 };
 
 /*
@@ -686,7 +688,7 @@ enum ethtool_sfeatures_retval_bits {
 #include <linux/rculist.h>
 
 /* needed by dev_disable_lro() */
-extern int __ethtool_set_flags(struct net_device *dev, u32 flags);
+extern int __ethtool_set_flags(struct net_device *dev, u64 flags);
 
 struct ethtool_rx_ntuple_flow_spec_container {
 	struct ethtool_rx_ntuple_flow_spec fs;
@@ -730,10 +732,10 @@ u32 ethtool_op_get_tso(struct net_device *dev);
 int ethtool_op_set_tso(struct net_device *dev, u32 data);
 u32 ethtool_op_get_ufo(struct net_device *dev);
 int ethtool_op_set_ufo(struct net_device *dev, u32 data);
-u32 ethtool_op_get_flags(struct net_device *dev);
-int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported);
+u64 ethtool_op_get_flags(struct net_device *dev);
+int ethtool_op_set_flags(struct net_device *dev, u64 data, u64 supported);
 void ethtool_ntuple_flush(struct net_device *dev);
-bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
+bool ethtool_invalid_flags(struct net_device *dev, u64 data, u64 supported);
 
 /**
  * struct ethtool_ops - optional netdev operations
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index d8b1a8d..8a25090 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -128,11 +128,11 @@ EXPORT_SYMBOL(ethtool_op_set_ufo);
 /* the following list of flags are the same as their associated
  * NETIF_F_xxx values in include/linux/netdevice.h
  */
-static const u32 flags_dup_features =
+static const u64 flags_dup_features =
 	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
 	 ETH_FLAG_RXHASH);
 
-u32 ethtool_op_get_flags(struct net_device *dev)
+u64 ethtool_op_get_flags(struct net_device *dev)
 {
 	/* in the future, this function will probably contain additional
 	 * handling for flags which are not so easily handled
@@ -148,9 +148,9 @@ EXPORT_SYMBOL(ethtool_op_get_flags);
  * If feature can not be toggled, it state (enabled or disabled) must match
  * hardcoded device features state, otherwise flags are marked as invalid.
  */
-bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
+bool ethtool_invalid_flags(struct net_device *dev, u64 data, u64 supported)
 {
-	u32 features = dev->features & flags_dup_features;
+	u64 features = dev->features & flags_dup_features;
 	/* "data" can contain only flags_dup_features bits,
 	 * see __ethtool_set_flags */
 
@@ -158,7 +158,7 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported)
 }
 EXPORT_SYMBOL(ethtool_invalid_flags);
 
-int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 supported)
+int ethtool_op_set_flags(struct net_device *dev, u64 data, u64 supported)
 {
 	if (ethtool_invalid_flags(dev, data, supported))
 		return -EINVAL;
@@ -183,8 +183,6 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
 
 /* Handlers for each ethtool command */
 
-#define ETHTOOL_DEV_FEATURE_WORDS	1
-
 static void ethtool_get_features_compat(struct net_device *dev,
 	struct ethtool_get_features_block *features)
 {
@@ -211,23 +209,23 @@ static void ethtool_get_features_compat(struct net_device *dev,
 
 static int ethtool_set_feature_compat(struct net_device *dev,
 	int (*legacy_set)(struct net_device *, u32),
-	struct ethtool_set_features_block *features, u32 mask)
+	struct ethtool_set_features_block *features, u64 mask)
 {
 	u32 do_set;
 
 	if (!legacy_set)
 		return 0;
 
-	if (!(features[0].valid & mask))
+	if (!(features->valid & mask))
 		return 0;
 
-	features[0].valid &= ~mask;
+	features->valid &= ~mask;
 
-	do_set = !!(features[0].requested & mask);
+	do_set = !!(features->requested & mask);
 
 	if (legacy_set(dev, do_set) < 0)
 		netdev_info(dev,
-			"Legacy feature change (%s) failed for 0x%08x\n",
+			"Legacy feature change (%s) failed for 0x%016lX\n",
 			do_set ? "set" : "clear", mask);
 
 	return 1;
@@ -259,33 +257,15 @@ static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gfeatures cmd = {
 		.cmd = ETHTOOL_GFEATURES,
-		.size = ETHTOOL_DEV_FEATURE_WORDS,
-	};
-	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS] = {
-		{
-			.available = dev->hw_features,
-			.requested = dev->wanted_features,
-			.active = dev->features,
-			.never_changed = NETIF_F_NEVER_CHANGE,
-		},
+		.features.available = dev->hw_features,
+		.features.requested = dev->wanted_features,
+		.features.active = dev->features,
+		.features.never_changed = NETIF_F_NEVER_CHANGE,
 	};
-	u32 __user *sizeaddr;
-	u32 copy_size;
-
-	ethtool_get_features_compat(dev, features);
-
-	sizeaddr = useraddr + offsetof(struct ethtool_gfeatures, size);
-	if (get_user(copy_size, sizeaddr))
-		return -EFAULT;
-
-	if (copy_size > ETHTOOL_DEV_FEATURE_WORDS)
-		copy_size = ETHTOOL_DEV_FEATURE_WORDS;
 
+	ethtool_get_features_compat(dev, &cmd.features);
 	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
 		return -EFAULT;
-	useraddr += sizeof(cmd);
-	if (copy_to_user(useraddr, features, copy_size * sizeof(*features)))
-		return -EFAULT;
 
 	return 0;
 }
@@ -293,41 +273,34 @@ static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_sfeatures cmd;
-	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS];
 	int ret = 0;
 
 	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
 		return -EFAULT;
-	useraddr += sizeof(cmd);
-
-	if (cmd.size != ETHTOOL_DEV_FEATURE_WORDS)
-		return -EINVAL;
-
-	if (copy_from_user(features, useraddr, sizeof(features)))
-		return -EFAULT;
 
-	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
+	if (cmd.features.valid & ~NETIF_F_ETHTOOL_BITS)
 		return -EINVAL;
 
-	if (ethtool_set_features_compat(dev, features))
+	if (ethtool_set_features_compat(dev, &cmd.features))
 		ret |= ETHTOOL_F_COMPAT;
 
-	if (features[0].valid & ~dev->hw_features) {
-		features[0].valid &= dev->hw_features;
+	if (cmd.features.valid & ~dev->hw_features) {
+		cmd.features.valid &= dev->hw_features;
 		ret |= ETHTOOL_F_UNSUPPORTED;
 	}
 
-	dev->wanted_features &= ~features[0].valid;
-	dev->wanted_features |= features[0].valid & features[0].requested;
+	dev->wanted_features &= ~cmd.features.valid;
+	dev->wanted_features |= cmd.features.valid & cmd.features.requested;
 	__netdev_update_features(dev);
 
-	if ((dev->wanted_features ^ dev->features) & features[0].valid)
+	if ((dev->wanted_features ^ dev->features) & cmd.features.valid)
 		ret |= ETHTOOL_F_WISH;
 
 	return ret;
 }
 
-static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GSTRING_LEN] = {
+static const char
+netdev_features_strings[sizeof(u64) * BITS_PER_BYTE][ETH_GSTRING_LEN] = {
 	/* NETIF_F_SG */              "tx-scatter-gather",
 	/* NETIF_F_IP_CSUM */         "tx-checksum-ipv4",
 	/* NETIF_F_NO_CSUM */         "tx-checksum-unneeded",
@@ -391,7 +364,7 @@ static void __ethtool_get_strings(struct net_device *dev,
 		ops->get_strings(dev, stringset, data);
 }
 
-static u32 ethtool_get_feature_mask(u32 eth_cmd)
+static u64 ethtool_get_feature_mask(u32 eth_cmd)
 {
 	/* feature masks of legacy discrete ethtool ops */
 
@@ -445,7 +418,7 @@ static void *__ethtool_get_one_feature_actor(struct net_device *dev, u32 ethcmd)
 	}
 }
 
-static u32 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
+static u64 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
 {
 	return !!(dev->features & NETIF_F_ALL_CSUM);
 }
@@ -453,7 +426,7 @@ static u32 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
 static int ethtool_get_one_feature(struct net_device *dev,
 	char __user *useraddr, u32 ethcmd)
 {
-	u32 mask = ethtool_get_feature_mask(ethcmd);
+	u64 mask = ethtool_get_feature_mask(ethcmd);
 	struct ethtool_value edata = {
 		.cmd = ethcmd,
 		.data = !!(dev->features & mask),
@@ -461,7 +434,7 @@ static int ethtool_get_one_feature(struct net_device *dev,
 
 	/* compatibility with discrete get_ ops */
 	if (!(dev->hw_features & mask)) {
-		u32 (*actor)(struct net_device *);
+		u64 (*actor)(struct net_device *);
 
 		actor = __ethtool_get_one_feature_actor(dev, ethcmd);
 
@@ -488,7 +461,7 @@ static int ethtool_set_one_feature(struct net_device *dev,
 	void __user *useraddr, u32 ethcmd)
 {
 	struct ethtool_value edata;
-	u32 mask;
+	u64 mask;
 
 	if (copy_from_user(&edata, useraddr, sizeof(edata)))
 		return -EFAULT;
@@ -530,9 +503,9 @@ static int ethtool_set_one_feature(struct net_device *dev,
 	}
 }
 
-int __ethtool_set_flags(struct net_device *dev, u32 data)
+int __ethtool_set_flags(struct net_device *dev, u64 data)
 {
-	u32 changed;
+	u64 changed;
 
 	if (data & ~flags_dup_features)
 		return -EINVAL;
-- 
1.7.3.1

