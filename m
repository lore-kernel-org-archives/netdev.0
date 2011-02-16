From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v6 5/9] net: Introduce new feature setting ops
Date: Wed, 16 Feb 2011 03:59:17 +0100 (CET)
Message-ID: <6e3e35a4119852d72c8a0c48f33fd0c1afaefc38.1297824704.git.mirq-linux@rere.qmqm.pl>
References: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57728 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab1BPC7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 21:59:19 -0500
In-Reply-To: <cover.1297824704.git.mirq-linux@rere.qmqm.pl>
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
 include/linux/ethtool.h   |   85 ++++++++++++++++++++++++++++++
 include/linux/netdevice.h |   37 +++++++++++++-
 net/core/dev.c            |   46 ++++++++++++++--
 net/core/ethtool.c        |  125 +++++++++++++++++++++++++++++++++++++=
+++++++-
 4 files changed, 283 insertions(+), 10 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 1908929..806e716 100644
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
@@ -523,6 +524,87 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
=20
+/* for returning and changing feature sets */
+
+/**
+ * struct ethtool_get_features_block - block with state of 32 features
+ * @available: mask of changeable features
+ * @requested: mask of features requested to be enabled if possible
+ * @active: mask of currently enabled features
+ * @never_changed: mask of features not changeable for any device
+ */
+struct ethtool_get_features_block {
+	__u32	available;
+	__u32	requested;
+	__u32	active;
+	__u32	never_changed;
+};
+
+/**
+ * struct ethtool_gfeatures - command to get state of device's feature=
s
+ * @cmd: command number =3D %ETHTOOL_GFEATURES
+ * @size: in: number of elements in the features[] array;
+ *       out: number of elements in features[] needed to hold all feat=
ures
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
+	__u32	valid;
+	__u32	requested;
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
+	ETHTOOL_F_UNSUPPORTED__BIT,
+	ETHTOOL_F_WISH__BIT,
+};
+
+#define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
+#define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
+
 #ifdef __KERNEL__
=20
 #include <linux/rculist.h>
@@ -744,6 +826,9 @@ struct ethtool_ops {
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
index dede3fd..85f67e2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -791,6 +791,18 @@ struct netdev_tc_txq {
  *
  * int (*ndo_del_slave)(struct net_device *dev, struct net_device *sla=
ve_dev);
  *	Called to release previously enslaved netdev.
+ *
+ *      Feature/offload setting functions.
+ * u32 (*ndo_fix_features)(struct net_device *dev, u32 features);
+ *	Adjusts the requested feature flags according to device-specific
+ *	constraints, and returns the resulting flags. Must not modify
+ *	the device state.
+ *
+ * int (*ndo_set_features)(struct net_device *dev, u32 features);
+ *	Called to update device configuration to new features. Passed
+ *	feature set might be less than what was returned by ndo_fix_feature=
s()).
+ *	Must return >0 or -errno if it changed dev->features itself.
+ *
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -874,6 +886,10 @@ struct net_device_ops {
 						 struct net_device *slave_dev);
 	int			(*ndo_del_slave)(struct net_device *dev,
 						 struct net_device *slave_dev);
+	u32			(*ndo_fix_features)(struct net_device *dev,
+						    u32 features);
+	int			(*ndo_set_features)(struct net_device *dev,
+						    u32 features);
 };
=20
 /*
@@ -925,12 +941,18 @@ struct net_device {
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
@@ -966,6 +988,12 @@ struct net_device {
 #define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_FSO		(SKB_GSO_FCOE << NETIF_F_GSO_SHIFT)
=20
+	/* Features valid for ethtool to change */
+	/* =3D all defined minus driver/device-class-related */
+#define NETIF_F_NEVER_CHANGE	(NETIF_F_HIGHDMA | NETIF_F_VLAN_CHALLENGE=
D | \
+				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
+#define NETIF_F_ETHTOOL_BITS	(0x1f3fffff & ~NETIF_F_NEVER_CHANGE)
+
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
 				 NETIF_F_TSO6 | NETIF_F_UFO)
@@ -2428,8 +2456,13 @@ extern char *netdev_drivername(const struct net_=
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
index 8686f6f..4f69439 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5302,6 +5302,37 @@ u32 netdev_fix_features(struct net_device *dev, =
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
+		netdev_err(dev,
+			"set_features() failed (%d); wanted 0x%08x, left 0x%08x\n",
+			err, features, dev->features);
+}
+EXPORT_SYMBOL(netdev_update_features);
+
 /**
  *	netif_stacked_transfer_operstate -	transfer operstate
  *	@rootdev: the root or lower level device to transfer state from
@@ -5436,15 +5467,18 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
-	/* Enable software offloads by default - will be stripped in
-	 * netdev_fix_features() if not supported. */
-	dev->features |=3D NETIF_F_SOFT_FEATURES;
+	/* Transfer changeable features to wanted_features and enable
+	 * software offloads (GSO and GRO).
+	 */
+	dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
+	dev->wanted_features =3D (dev->features & dev->hw_features)
+		| NETIF_F_SOFT_FEATURES;
=20
 	/* Avoid warning from netdev_fix_features() for GSO without SG */
-	if (!(dev->features & NETIF_F_SG))
-		dev->features &=3D ~NETIF_F_GSO;
+	if (!(dev->wanted_features & NETIF_F_SG))
+		dev->wanted_features &=3D ~NETIF_F_GSO;
=20
-	dev->features =3D netdev_fix_features(dev, dev->features);
+	netdev_update_features(dev);
=20
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c3fb8f9..9577396 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -172,10 +172,120 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
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
+	u32 copy_size;
+
+	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
+	if (get_user(copy_size, sizeaddr))
+		return -EFAULT;
+
+	if (copy_size > ETHTOOL_DEV_FEATURE_WORDS)
+		copy_size =3D ETHTOOL_DEV_FEATURE_WORDS;
+
+	if (copy_to_user(useraddr, &cmd, sizeof(cmd)))
+		return -EFAULT;
+	useraddr +=3D sizeof(cmd);
+	if (copy_to_user(useraddr, features, copy_size * sizeof(*features)))
+		return -EFAULT;
+
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
+	/* NETIF_F_SG */              "tx-scatter-gather",
+	/* NETIF_F_IP_CSUM */         "tx-checksum-ipv4",
+	/* NETIF_F_NO_CSUM */         "tx-checksum-unneeded",
+	/* NETIF_F_HW_CSUM */         "tx-checksum-ip-generic",
+	/* NETIF_F_IPV6_CSUM */       "tx_checksum-ipv6",
+	/* NETIF_F_HIGHDMA */         "highdma",
+	/* NETIF_F_FRAGLIST */        "tx-scatter-gather-fraglist",
+	/* NETIF_F_HW_VLAN_TX */      "tx-vlan-hw-insert",
+
+	/* NETIF_F_HW_VLAN_RX */      "rx-vlan-hw-parse",
+	/* NETIF_F_HW_VLAN_FILTER */  "rx-vlan-filter",
+	/* NETIF_F_VLAN_CHALLENGED */ "vlan-challenged",
+	/* NETIF_F_GSO */             "tx-generic-segmentation",
+	/* NETIF_F_LLTX */            "tx-lockless",
+	/* NETIF_F_NETNS_LOCAL */     "netns-local",
+	/* NETIF_F_GRO */             "rx-gro",
+	/* NETIF_F_LRO */             "rx-lro",
+
+	/* NETIF_F_TSO */             "tx-tcp-segmentation",
+	/* NETIF_F_UFO */             "tx-udp-fragmentation",
+	/* NETIF_F_GSO_ROBUST */      "tx-gso-robust",
+	/* NETIF_F_TSO_ECN */         "tx-tcp-ecn-segmentation",
+	/* NETIF_F_TSO6 */            "tx-tcp6-segmentation",
+	/* NETIF_F_FSO */             "tx-fcoe-segmentation",
+	"",
+	"",
+
+	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
+	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
+	/* NETIF_F_FCOE_MTU */        "fcoe-mtu",
+	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
+	/* NETIF_F_RXHASH */          "rx-hashing",
+	"",
+	"",
+	"",
+};
+
 static int __ethtool_get_sset_count(struct net_device *dev, int sset)
 {
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
=20
+	if (sset =3D=3D ETH_SS_FEATURES)
+		return ARRAY_SIZE(netdev_features_strings);
+
 	if (ops && ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
@@ -187,8 +297,12 @@ static void __ethtool_get_strings(struct net_devic=
e *dev,
 {
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
=20
-	/* ops->get_strings is valid because checked earlier */
-	ops->get_strings(dev, stringset, data);
+	if (stringset =3D=3D ETH_SS_FEATURES)
+		memcpy(data, netdev_features_strings,
+			sizeof(netdev_features_strings));
+	else
+		/* ops->get_strings is valid because checked earlier */
+		ops->get_strings(dev, stringset, data);
 }
=20
 static u32 ethtool_get_feature_mask(u32 eth_cmd)
@@ -1533,6 +1647,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
+	case ETHTOOL_GFEATURES:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1678,6 +1793,12 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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
 	case ETHTOOL_GTXCSUM:
 	case ETHTOOL_GSG:
 	case ETHTOOL_GTSO:
--=20
1.7.2.3

