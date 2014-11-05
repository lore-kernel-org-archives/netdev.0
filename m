From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 1/2] ethtool: Support for configurable RSS hash function
Date: Wed,  5 Nov 2014 13:59:28 +0200
Message-ID: <1415188769-19593-2-git-send-email-amirv@mellanox.com>
References: <1415188769-19593-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38222 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754004AbaKEL7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 06:59:35 -0500
In-Reply-To: <1415188769-19593-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

This patch adds an RSS hash functions string-set, and two
ethtool-options for set/get current RSS hash function. User-kernel API is done
through the new hfunc mask field in the ethtool_rxfh struct. A bit set
in the hfunc is corresponding to an index in the string-set.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 include/linux/ethtool.h      | 28 ++++++++++++++++++++++++
 include/uapi/linux/ethtool.h |  6 ++++-
 net/core/ethtool.c           | 52 ++++++++++++++++++++++++++++++--------------
 3 files changed, 69 insertions(+), 17 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c1a2d60..61003b1 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -59,6 +59,29 @@ enum ethtool_phys_id_state {
 	ETHTOOL_ID_OFF
 };
 
+enum {
+	RSS_HASH_TOP_BIT, /* Configurable RSS hash function - Toeplitz */
+	RSS_HASH_XOR_BIT, /* Configurable RSS hash function - Xor */
+
+	/*
+	 * Add your fresh new hash function bits above and remember to update
+	 * rss_hash_func_strings[] below
+	 */
+	RSS_HASH_FUNCS_COUNT
+};
+
+#define __RSS_HASH_BIT(bit)	((u32)1 << (bit))
+#define __RSS_HASH(name)	 __RSS_HASH_BIT(RSS_HASH_##name##_BIT)
+
+#define RSS_HASH_TOP		__RSS_HASH(TOP)
+#define RSS_HASH_XOR		__RSS_HASH(XOR)
+
+static const char
+rss_hash_func_strings[RSS_HASH_FUNCS_COUNT][ETH_GSTRING_LEN] = {
+	[RSS_HASH_TOP_BIT] =     "toeplitz",
+	[RSS_HASH_XOR_BIT] =     "xor",
+};
+
 struct net_device;
 
 /* Some generic methods drivers may use in their ethtool_ops */
@@ -158,6 +181,9 @@ static inline u32 ethtool_rxfh_indir_default(u32 index, u32 n_rx_rings)
  *	Returns zero if not supported for this specific device.
  * @get_rxfh_indir_size: Get the size of the RX flow hash indirection table.
  *	Returns zero if not supported for this specific device.
+ * @get_rxfh_func: Get the hardware RX flow hash function.
+ * @set_rxfh_func: Set the hardware RX flow hash function. Returns a negative
+ *	error code or zero.
  * @get_rxfh: Get the contents of the RX flow hash indirection table and hash
  *	key.
  *	Will only be called if one or both of @get_rxfh_indir_size and
@@ -241,6 +267,8 @@ struct ethtool_ops {
 	int	(*reset)(struct net_device *, u32 *);
 	u32	(*get_rxfh_key_size)(struct net_device *);
 	u32	(*get_rxfh_indir_size)(struct net_device *);
+	u32	(*get_rxfh_func)(struct net_device *);
+	int	(*set_rxfh_func)(struct net_device *, u32);
 	int	(*get_rxfh)(struct net_device *, u32 *indir, u8 *key);
 	int	(*set_rxfh)(struct net_device *, const u32 *indir,
 			    const u8 *key);
diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index eb2095b..eb91da4 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -534,6 +534,7 @@ struct ethtool_pauseparam {
  * @ETH_SS_NTUPLE_FILTERS: Previously used with %ETHTOOL_GRXNTUPLE;
  *	now deprecated
  * @ETH_SS_FEATURES: Device feature names
+ * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -541,6 +542,7 @@ enum ethtool_stringset {
 	ETH_SS_PRIV_FLAGS,
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
+	ETH_SS_RSS_HASH_FUNCS,
 };
 
 /**
@@ -900,7 +902,9 @@ struct ethtool_rxfh {
 	__u32	rss_context;
 	__u32   indir_size;
 	__u32   key_size;
-	__u32	rsvd[2];
+	__u8	hfunc;
+	__u8	rsvd8[3];
+	__u32	rsvd32;
 	__u32   rss_config[0];
 };
 #define ETH_RXFH_INDIR_NO_CHANGE	0xffffffff
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 06dfb29..4791c17 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -185,6 +185,9 @@ static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 	if (sset == ETH_SS_FEATURES)
 		return ARRAY_SIZE(netdev_features_strings);
 
+	if (sset == ETH_SS_RSS_HASH_FUNCS)
+		return ARRAY_SIZE(rss_hash_func_strings);
+
 	if (ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
@@ -199,6 +202,9 @@ static void __ethtool_get_strings(struct net_device *dev,
 	if (stringset == ETH_SS_FEATURES)
 		memcpy(data, netdev_features_strings,
 			sizeof(netdev_features_strings));
+	else if (stringset == ETH_SS_RSS_HASH_FUNCS)
+		memcpy(data, rss_hash_func_strings,
+		       sizeof(rss_hash_func_strings));
 	else
 		/* ops->get_strings is valid because checked earlier */
 		ops->get_strings(dev, stringset, data);
@@ -682,7 +688,7 @@ static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
 	int ret;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u32 user_indir_size, user_key_size;
-	u32 dev_indir_size = 0, dev_key_size = 0;
+	u32 dev_indir_size = 0, dev_key_size = 0, dev_hfunc = 0;
 	struct ethtool_rxfh rxfh;
 	u32 total_size;
 	u32 indir_bytes;
@@ -690,17 +696,18 @@ static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
 	u8 *hkey = NULL;
 	u8 *rss_config;
 
-	if (!(dev->ethtool_ops->get_rxfh_indir_size ||
-	      dev->ethtool_ops->get_rxfh_key_size) ||
-	      !dev->ethtool_ops->get_rxfh)
+	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size ||
+	      ops->get_rxfh_func) || !ops->get_rxfh)
 		return -EOPNOTSUPP;
 
+	if (ops->get_rxfh_func)
+		dev_hfunc = ops->get_rxfh_func(dev);
 	if (ops->get_rxfh_indir_size)
 		dev_indir_size = ops->get_rxfh_indir_size(dev);
 	if (ops->get_rxfh_key_size)
 		dev_key_size = ops->get_rxfh_key_size(dev);
 
-	if ((dev_key_size + dev_indir_size) == 0)
+	if ((dev_key_size + dev_indir_size + dev_hfunc) == 0)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
@@ -709,17 +716,19 @@ static noinline_for_stack int ethtool_get_rxfh(struct net_device *dev,
 	user_key_size = rxfh.key_size;
 
 	/* Check that reserved fields are 0 for now */
-	if (rxfh.rss_context || rxfh.rsvd[0] || rxfh.rsvd[1])
+	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] ||
+	    rxfh.rsvd8[2] || rxfh.rsvd32)
 		return -EINVAL;
 
 	rxfh.indir_size = dev_indir_size;
 	rxfh.key_size = dev_key_size;
+	rxfh.hfunc = dev_hfunc;
 	if (copy_to_user(useraddr, &rxfh, sizeof(rxfh)))
 		return -EFAULT;
 
-	/* If the user buffer size is 0, this is just a query for the
-	 * device table size and key size.  Otherwise, if the User size is
-	 * not equal to device table size or key size it's an error.
+	/* If the user buffer size is 0, this is just a query for the device
+	 * hash function, table size and key size.  Otherwise, if the User size
+	 * is not equal to device table size or key size it's an error.
 	 */
 	if (!user_indir_size && !user_key_size)
 		return 0;
@@ -760,32 +769,43 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	struct ethtool_rxnfc rx_rings;
 	struct ethtool_rxfh rxfh;
-	u32 dev_indir_size = 0, dev_key_size = 0, i;
+	u32 dev_indir_size = 0, dev_key_size = 0, dev_hfunc = 0, i;
 	u32 *indir = NULL, indir_bytes = 0;
 	u8 *hkey = NULL;
 	u8 *rss_config;
 	u32 rss_cfg_offset = offsetof(struct ethtool_rxfh, rss_config[0]);
 
-	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size) ||
-	    !ops->get_rxnfc || !ops->set_rxfh)
+	if (!(ops->get_rxfh_indir_size || ops->get_rxfh_key_size ||
+	      ops->get_rxfh_func) || !ops->get_rxnfc || !ops->set_rxfh)
 		return -EOPNOTSUPP;
 
+	if (ops->get_rxfh_func)
+		dev_hfunc = ops->get_rxfh_func(dev);
 	if (ops->get_rxfh_indir_size)
 		dev_indir_size = ops->get_rxfh_indir_size(dev);
 	if (ops->get_rxfh_key_size)
 		dev_key_size = dev->ethtool_ops->get_rxfh_key_size(dev);
-	if ((dev_key_size + dev_indir_size) == 0)
+	if ((dev_key_size + dev_indir_size + dev_hfunc) == 0)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&rxfh, useraddr, sizeof(rxfh)))
 		return -EFAULT;
 
 	/* Check that reserved fields are 0 for now */
-	if (rxfh.rss_context || rxfh.rsvd[0] || rxfh.rsvd[1])
+	if (rxfh.rss_context || rxfh.rsvd8[0] || rxfh.rsvd8[1] ||
+	    rxfh.rsvd8[2] || rxfh.rsvd32)
 		return -EINVAL;
 
+	if (rxfh.hfunc != dev_hfunc) {
+		if (!ops->set_rxfh_func)
+			return -EOPNOTSUPP;
+		ret = ops->set_rxfh_func(dev, rxfh.hfunc);
+		if (ret)
+			return ret;
+	}
+
 	/* If either indir or hash key is valid, proceed further.
-	 * It is not valid to request that both be unchanged.
+	 * Must request at least one change: indir size, hash key or function.
 	 */
 	if ((rxfh.indir_size &&
 	     rxfh.indir_size != ETH_RXFH_INDIR_NO_CHANGE &&
@@ -793,7 +813,7 @@ static noinline_for_stack int ethtool_set_rxfh(struct net_device *dev,
 	    (rxfh.key_size && (rxfh.key_size != dev_key_size)) ||
 	    (rxfh.indir_size == ETH_RXFH_INDIR_NO_CHANGE &&
 	     rxfh.key_size == 0))
-		return -EINVAL;
+		return rxfh.hfunc ? 0 : -EINVAL;
 
 	if (rxfh.indir_size != ETH_RXFH_INDIR_NO_CHANGE)
 		indir_bytes = dev_indir_size * sizeof(indir[0]);
-- 
1.8.3.4
