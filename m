From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v3 1/5] net: Introduce new feature setting ops
Date: Sat, 29 Jan 2011 19:39:08 +0100 (CET)
Message-ID: <0d740ad53dd1e096b2b5d27662ca393ce12c7cf7.1296325509.git.mirq-linux@rere.qmqm.pl>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60407 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754851Ab1A2SjM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jan 2011 13:39:12 -0500
In-Reply-To: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This introduces a new framework to handle device features setting.
It consists of:
  - new fields in struct net_device:
	+ hw_features - features that hw/driver supports toggling
	+ wanted_features - features that user wants enabled, when possible
  - new netdev_ops:
	+ feat =3D ndo_fix_features(dev, feat) - API checking constraints for
		enabling features or their combinations
	+ ndo_set_features(dev) - API updating hardware state to match
		changed dev->features
  - new ethtool commands:
	+ ETHTOOL_GFEATURES/ETHTOOL_SFEATURES: get/set dev->wanted_features
		and trigger device reconfiguration if resulting dev->features
		changed
	+ ETHTOOL_GSTRINGS(ETH_SS_FEATURES): get feature bits names (meaning)

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/ethtool.h   |   86 +++++++++++++++++++++++++
 include/linux/netdevice.h |   44 ++++++++++++-
 net/core/dev.c            |   47 ++++++++++++--
 net/core/ethtool.c        |  154 +++++++++++++++++++++++++++++++++++++=
++++----
 4 files changed, 312 insertions(+), 19 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 1908929..b832083 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -251,6 +251,7 @@ enum ethtool_stringset {
 	ETH_SS_STATS,
 	ETH_SS_PRIV_FLAGS,
 	ETH_SS_NTUPLE_FILTERS,
+	ETH_SS_FEATURES,
 };
=20
 /* for passing string sets for data tagging */
@@ -523,6 +524,88 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
=20
+/* for returning and changing feature sets */
+
+/**
+ * struct ethtool_get_features_block - block with state of 32 features
+ * @avaliable: mask of changeable features
+ * @requested: mask of features requested to be enabled if possible
+ * @active: mask of currently enabled features
+ * @never_changed: mask of never-changeable features
+ */
+struct ethtool_get_features_block {
+	__u32	available;	/* features togglable */
+	__u32	requested;	/* features requested to be enabled */
+	__u32	active;		/* features currently enabled */
+	__u32	never_changed;	/* never-changeable features */
+};
+
+/**
+ * struct ethtool_gfeatures - command to get state of device's feature=
s
+ * @cmd: command number =3D %ETHTOOL_GFEATURES
+ * @size: in: array size of the features[] array
+ *       out: count of features[] elements filled
+ * @features: state of features
+ */
+struct ethtool_gfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_get_features_block features[0];
+};
+
+/**
+ * struct ethtool_set_features_block - block with request for 32 featu=
res
+ * @valid: mask of features to be changed
+ * @requested: values of features to be changed
+ */
+struct ethtool_set_features_block {
+	__u32	valid;		/* bits valid in .requested */
+	__u32	requested;	/* features requested */
+};
+
+/**
+ * struct ethtool_sfeatures - command to request change in device's fe=
atures
+ * @cmd: command number =3D %ETHTOOL_SFEATURES
+ * @size: array size of the features[] array
+ * @features: feature change masks
+ */
+struct ethtool_sfeatures {
+	__u32	cmd;
+	__u32	size;
+	struct ethtool_set_features_block features[0];
+};
+
+/*
+ * %ETHTOOL_SFEATURES changes features present in features[].valid to =
the
+ * values of corresponding bits in features[].requested. Bits in .requ=
ested
+ * not set in .valid or not changeable are ignored.
+ *
+ * Returns %EINVAL when .valid contains undefined or never-changable b=
its
+ * or size is not equal to required number of features words (32-bit b=
locks).
+ * Returns >=3D 0 if request was completed; bits set in the value mean=
:
+ *   %ETHTOOL_F_UNSUPPORTED - there were bits set in .valid that are n=
ot
+ *	changeable (not present in %ETHTOOL_GFEATURES' features[].available=
)
+ *	those bits were ignored.
+ *   %ETHTOOL_F_WISH - some or all changes requested were recorded but=
 the
+ *      resulting state of bits masked by .valid is not equal to .requ=
ested.
+ *      Probably there are other device-specific constraints on some f=
eatures
+ *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is cons=
idered
+ *      here as though ignored bits were cleared.
+ *
+ * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (n=
umber of
+ * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS c=
ommands
+ * for ETH_SS_FEATURES string set. First entry in the table correspond=
s to least
+ * significant bit in features[0] fields. Empty strings mark undefined=
 features.
+ */
+enum ethtool_sfeatures_retval_bits {
+	ETHTOOL_F_UNSUPPORTED__BIT,	/* .valid had unsupported bits set */
+	ETHTOOL_F_WISH__BIT,		/* resulting device features state in
+					 * .valid is not equal to .requested */
+};
+
+#define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
+#define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
+
 #ifdef __KERNEL__
=20
 #include <linux/rculist.h>
@@ -744,6 +827,9 @@ struct ethtool_ops {
 #define ETHTOOL_GRXFHINDIR	0x00000038 /* Get RX flow hash indir'n tabl=
e */
 #define ETHTOOL_SRXFHINDIR	0x00000039 /* Set RX flow hash indir'n tabl=
e */
=20
+#define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
+#define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings=
 */
+
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7d7074..6490860 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -783,6 +783,16 @@ struct netdev_tc_txq {
  *	Set hardware filter for RFS.  rxq_index is the target queue index;
  *	flow_id is a flow ID to be passed to rps_may_expire_flow() later.
  *	Return the filter ID on success, or a negative error code.
+ *
+ * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
+ *	Modifies features supported by device depending on device-specific
+ *	constraints. Should not modify hardware state.
+ *
+ * int (*ndo_set_features)(struct net_device *dev, u32 features);
+ *	Called to update hardware configuration to new features. Selected
+ *	features might be less than what was returned by ndo_fix_features()=
).
+ *	Must return >0 if it changed dev->features itself.
+ *
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -862,6 +872,10 @@ struct net_device_ops {
 						     u16 rxq_index,
 						     u32 flow_id);
 #endif
+	u32			(*ndo_fix_features)(struct net_device *dev,
+						    u32 features);
+	int			(*ndo_set_features)(struct net_device *dev,
+						    u32 features);
 };
=20
 /*
@@ -913,12 +927,18 @@ struct net_device {
 	struct list_head	napi_list;
 	struct list_head	unreg_list;
=20
-	/* Net device features */
+	/* currently active device features */
 	u32			features;
-
+	/* user-changeable features */
+	u32			hw_features;
+	/* user-requested features */
+	u32			wanted_features;
 	/* VLAN feature mask */
 	u32			vlan_features;
=20
+	/* Net device feature bits; if you change something,
+	 * also update netdev_features_strings[] in ethtool.c */
+
 #define NETIF_F_SG		1	/* Scatter/gather IO. */
 #define NETIF_F_IP_CSUM		2	/* Can checksum TCP/UDP over IPv4. */
 #define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack.=
 */
@@ -954,6 +974,12 @@ struct net_device {
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
=20
+	/* Features valid for ethtool to change */
+	/* =3D all defined minus driver/device-class-related */
+#define NETIF_F_NEVER_CHANGE	(NETIF_F_VLAN_CHALLENGED | \
+				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
+#define NETIF_F_ETHTOOL_BITS	(0x1f3fffff & ~NETIF_F_NEVER_CHANGE)
+
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
 				 NETIF_F_TSO6 | NETIF_F_UFO)
@@ -964,6 +990,12 @@ struct net_device {
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
=20
+#define NETIF_F_ALL_TSO 	(NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN=
)
+
+#define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
+				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
+				 NETIF_F_SCTP_CSUM | NETIF_F_FCOE_CRC)
+
 	/*
 	 * If one device supports one of these features, then enable them
 	 * for all in netdev_increment_features.
@@ -972,6 +1004,9 @@ struct net_device {
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
 				 NETIF_F_FRAGLIST)
=20
+	/* changeable features with no special hardware requirements */
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
@@ -2405,8 +2440,13 @@ extern char *netdev_drivername(const struct net_=
device *dev, char *buffer, int l
=20
 extern void linkwatch_run_queue(void);
=20
+static inline u32 netdev_get_wanted_features(struct net_device *dev)
+{
+	return (dev->features & ~dev->hw_features) | dev->wanted_features;
+}
 u32 netdev_increment_features(u32 all, u32 one, u32 mask);
 u32 netdev_fix_features(struct net_device *dev, u32 features);
+void netdev_update_features(struct net_device *dev);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index ddd5df2..0ccbee6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5245,6 +5245,12 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 		features &=3D ~NETIF_F_TSO;
 	}
=20
+	/* Software GSO depends on SG. */
+	if ((features & NETIF_F_GSO) && !(features & NETIF_F_SG)) {
+		netdev_info(dev, "Dropping NETIF_F_GSO since no SG feature.\n");
+		features &=3D ~NETIF_F_GSO;
+	}
+
 	/* UFO needs SG and checksumming */
 	if (features & NETIF_F_UFO) {
 		/* maybe split UFO into V4 and V6? */
@@ -5267,6 +5273,35 @@ u32 netdev_fix_features(struct net_device *dev, =
u32 features)
 }
 EXPORT_SYMBOL(netdev_fix_features);
=20
+void netdev_update_features(struct net_device *dev)
+{
+	u32 features;
+	int err =3D 0;
+
+	features =3D netdev_get_wanted_features(dev);
+
+	if (dev->netdev_ops->ndo_fix_features)
+		features =3D dev->netdev_ops->ndo_fix_features(dev, features);
+
+	/* driver might be less strict about feature dependencies */
+	features =3D netdev_fix_features(dev, features);
+
+	if (dev->features =3D=3D features)
+		return;
+
+	netdev_info(dev, "Features changed: 0x%08x -> 0x%08x\n",
+		dev->features, features);
+
+	if (dev->netdev_ops->ndo_set_features)
+		err =3D dev->netdev_ops->ndo_set_features(dev, features);
+
+	if (!err)
+		dev->features =3D features;
+	else if (err < 0)
+		netdev_err(dev, "set_features() failed (%d)\n", err);
+}
+EXPORT_SYMBOL(netdev_update_features);
+
 /**
  *	netif_stacked_transfer_operstate -	transfer operstate
  *	@rootdev: the root or lower level device to transfer state from
@@ -5401,11 +5436,13 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
-	dev->features =3D netdev_fix_features(dev, dev->features);
-
-	/* Enable software GSO if SG is supported. */
-	if (dev->features & NETIF_F_SG)
-		dev->features |=3D NETIF_F_GSO;
+	/* Transfer changeable features to wanted_features and enable
+	 * software offloads (GSO and GRO).
+	 */
+	dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
+	dev->wanted_features =3D (dev->features & dev->hw_features)
+		| NETIF_F_SOFT_FEATURES;
+	netdev_update_features(dev);
=20
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 5984ee0..1420edd 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -55,6 +55,7 @@ int ethtool_op_set_tx_csum(struct net_device *dev, u3=
2 data)
=20
 	return 0;
 }
+EXPORT_SYMBOL(ethtool_op_set_tx_csum);
=20
 int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
 {
@@ -171,6 +172,136 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
=20
 /* Handlers for each ethtool command */
=20
+#define ETHTOOL_DEV_FEATURE_WORDS	1
+
+static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
+{
+	struct ethtool_gfeatures cmd =3D {
+		.cmd =3D ETHTOOL_GFEATURES,
+		.size =3D ETHTOOL_DEV_FEATURE_WORDS,
+	};
+	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
 =3D {
+		{
+			.available =3D dev->hw_features,
+			.requested =3D dev->wanted_features,
+			.active =3D dev->features,
+			.never_changed =3D NETIF_F_NEVER_CHANGE,
+		},
+	};
+	u32 __user *sizeaddr;
+	u32 in_size;
+
+	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
+	if (get_user(in_size, sizeaddr))
+		return -EFAULT;
+
+	if (in_size < ETHTOOL_DEV_FEATURE_WORDS)
+		return -EINVAL;
+
+	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
+		return -EFAULT;
+	useraddr +=3D sizeof(cmd);
+	if (copy_to_user(useraddr, features, sizeof(features)))
+		return -EFAULT;
+	return 0;
+}
+
+static int ethtool_set_features(struct net_device *dev, void __user *u=
seraddr)
+{
+	struct ethtool_sfeatures cmd;
+	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
;
+	int ret =3D 0;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+	useraddr +=3D sizeof(cmd);
+
+	if (cmd.size !=3D ETHTOOL_DEV_FEATURE_WORDS)
+		return -EINVAL;
+
+	if (copy_from_user(features, useraddr, sizeof(features)))
+		return -EFAULT;
+
+	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
+		return -EINVAL;
+
+	if (features[0].valid & ~dev->hw_features) {
+		features[0].valid &=3D dev->hw_features;
+		ret |=3D ETHTOOL_F_UNSUPPORTED;
+	}
+
+	dev->wanted_features &=3D ~features[0].valid;
+	dev->wanted_features |=3D features[0].valid & features[0].requested;
+	netdev_update_features(dev);
+
+	if ((dev->wanted_features ^ dev->features) & features[0].valid)
+		ret |=3D ETHTOOL_F_WISH;
+
+	return ret;
+}
+
+static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * =
32][ETH_GSTRING_LEN] =3D {
+	/* NETIF_F_SG */              "scatter-gather",
+	/* NETIF_F_IP_CSUM */         "tx-checksum-hw-ipv4",
+	/* NETIF_F_NO_CSUM */         "tx-checksum-local",
+	/* NETIF_F_HW_CSUM */         "tx-checksum-hw-ip-generic",
+	/* NETIF_F_IPV6_CSUM */       "tx_checksum-hw-ipv6",
+	/* NETIF_F_HIGHDMA */         "highdma",
+	/* NETIF_F_FRAGLIST */        "scatter-gather-fraglist",
+	/* NETIF_F_HW_VLAN_TX */      "tx-vlan-hw",
+
+	/* NETIF_F_HW_VLAN_RX */      "rx-vlan-hw",
+	/* NETIF_F_HW_VLAN_FILTER */  "rx-vlan-filter",
+	/* NETIF_F_VLAN_CHALLENGED */ "*vlan-challenged",
+	/* NETIF_F_GSO */             "generic-segmentation-offload",
+	/* NETIF_F_LLTX */            "*lockless-tx",
+	/* NETIF_F_NETNS_LOCAL */     "*netns-local",
+	/* NETIF_F_GRO */             "generic-receive-offload",
+	/* NETIF_F_LRO */             "large-receive-offload",
+
+	/* NETIF_F_TSO */             "tcp-segmentation-offload",
+	/* NETIF_F_UFO */             "udp-fragmentation-offload",
+	/* NETIF_F_GSO_ROBUST */      "gso-robust",
+	/* NETIF_F_TSO_ECN */         "tcp-ecn-segmentation-offload",
+	/* NETIF_F_TSO6 */            "ipv6-tcp-segmentation-offload",
+	/* NETIF_F_FSO */             "fcoe-segmentation-offload",
+	"",
+	"",
+
+	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
+	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
+	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
+	/* NETIF_F_NTUPLE */          "ntuple-filter",
+	/* NETIF_F_RXHASH */          "rx-hashing-offload",
+	"",
+	"",
+	"",
+};
+
+static int __ethtool_get_sset_count(struct net_device *dev, int sset)
+{
+	const struct ethtool_ops *ops =3D dev->ethtool_ops;
+
+	if (sset =3D=3D ETH_SS_FEATURES)
+		return ARRAY_SIZE(netdev_features_strings);
+	else if (ops && ops->get_sset_count)
+		return ops->get_sset_count(dev, sset);
+	else
+		return -EINVAL;
+}
+
+static void __ethtool_get_strings(struct net_device *dev,
+	u32 stringset, u8 *data)
+{
+	const struct ethtool_ops *ops =3D dev->ethtool_ops;
+
+	if (stringset =3D=3D ETH_SS_FEATURES)
+		memcpy(data, netdev_features_strings,
+			sizeof(netdev_features_strings));
+	else if (ops && ops->get_strings)
+		ops->get_strings(dev, stringset, data);
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_cmd cmd =3D { .cmd =3D ETHTOOL_GSET };
@@ -251,14 +382,10 @@ static noinline_for_stack int ethtool_get_sset_in=
fo(struct net_device *dev,
 						    void __user *useraddr)
 {
 	struct ethtool_sset_info info;
-	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	u64 sset_mask;
 	int i, idx =3D 0, n_bits =3D 0, ret, rc;
 	u32 *info_buf =3D NULL;
=20
-	if (!ops->get_sset_count)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&info, useraddr, sizeof(info)))
 		return -EFAULT;
=20
@@ -285,7 +412,7 @@ static noinline_for_stack int ethtool_get_sset_info=
(struct net_device *dev,
 		if (!(sset_mask & (1ULL << i)))
 			continue;
=20
-		rc =3D ops->get_sset_count(dev, i);
+		rc =3D __ethtool_get_sset_count(dev, i);
 		if (rc >=3D 0) {
 			info.sset_mask |=3D (1ULL << i);
 			info_buf[idx++] =3D rc;
@@ -1287,17 +1414,13 @@ static int ethtool_self_test(struct net_device =
*dev, char __user *useraddr)
 static int ethtool_get_strings(struct net_device *dev, void __user *us=
eraddr)
 {
 	struct ethtool_gstrings gstrings;
-	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	u8 *data;
 	int ret;
=20
-	if (!ops->get_strings || !ops->get_sset_count)
-		return -EOPNOTSUPP;
-
 	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
 		return -EFAULT;
=20
-	ret =3D ops->get_sset_count(dev, gstrings.string_set);
+	ret =3D __ethtool_get_sset_count(dev, gstrings.string_set);
 	if (ret < 0)
 		return ret;
=20
@@ -1307,7 +1430,7 @@ static int ethtool_get_strings(struct net_device =
*dev, void __user *useraddr)
 	if (!data)
 		return -ENOMEM;
=20
-	ops->get_strings(dev, gstrings.string_set, data);
+	__ethtool_get_strings(dev, gstrings.string_set, data);
=20
 	ret =3D -EFAULT;
 	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
@@ -1317,7 +1440,7 @@ static int ethtool_get_strings(struct net_device =
*dev, void __user *useraddr)
 		goto out;
 	ret =3D 0;
=20
- out:
+out:
 	kfree(data);
 	return ret;
 }
@@ -1500,6 +1623,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
+	case ETHTOOL_GFEATURES:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1693,6 +1817,12 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
 	case ETHTOOL_SRXFHINDIR:
 		rc =3D ethtool_set_rxfh_indir(dev, useraddr);
 		break;
+	case ETHTOOL_GFEATURES:
+		rc =3D ethtool_get_features(dev, useraddr);
+		break;
+	case ETHTOOL_SFEATURES:
+		rc =3D ethtool_set_features(dev, useraddr);
+		break;
 	default:
 		rc =3D -EOPNOTSUPP;
 	}
--=20
1.7.2.3

