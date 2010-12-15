From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RFC PATCH 02/12] net: Introduce new feature setting ops
Date: Wed, 15 Dec 2010 23:24:29 +0100 (CET)
Message-ID: <822f5776f99cab9889cd72d658d5fe50c56bb247.1292451559.git.mirq-linux@rere.qmqm.pl>
References: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:53549 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847Ab0LOWYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 17:24:30 -0500
In-Reply-To: <cover.1292451559.git.mirq-linux@rere.qmqm.pl>
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
	[TODO: this might be extended to support device-specific flags, and
	keep NETIF_F flags from becoming part of ABI by using GET_STRINGS
	for describing the bits]
	[Note: ETHTOOL_GFEATURES and ETHTOOL_SFEATURES' data is supposed to
	be 'compatible', so that you can R/M/W without additional copying]

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/ethtool.h   |   28 ++++++++++++++++++++++
 include/linux/netdevice.h |   29 +++++++++++++++++++++++
 net/core/dev.c            |   40 ++++++++++++++++++++++++++++----
 net/core/ethtool.c        |   56 +++++++++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 148 insertions(+), 5 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 1908929..0267d45 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -523,6 +523,31 @@ struct ethtool_flash {
 	char	data[ETHTOOL_FLASH_MAX_FILENAME];
 };
=20
+/* for returning feature sets */
+#define ETHTOOL_DEV_FEATURE_WORDS	1
+
+struct ethtool_get_features_block {
+	__u32	available;	/* features togglable */
+	__u32	requested;	/* features requested to be enabled */
+	__u32	active;		/* features currently enabled */
+	__u32	__pad[1];
+};
+
+struct ethtool_set_features_block {
+	__u32	valid;		/* bits valid in .requested */
+	__u32	requested;	/* features requested */
+	__u32	__pad[2];
+};
+
+struct ethtool_features {
+	__u32	cmd;
+	__u32	count;		/* blocks */
+	union {
+		struct ethtool_get_features_block get;
+		struct ethtool_set_features_block set;
+	} features[0];
+};
+
 #ifdef __KERNEL__
=20
 #include <linux/rculist.h>
@@ -744,6 +769,9 @@ struct ethtool_ops {
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
index d31bc3c..4b20944 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -756,6 +756,17 @@ struct xps_dev_maps {
  * int (*ndo_set_vf_port)(struct net_device *dev, int vf,
  *			  struct nlattr *port[]);
  * int (*ndo_get_vf_port)(struct net_device *dev, int vf, struct sk_bu=
ff *skb);
+ *
+ * unsigned long (*ndo_fix_features)(struct net_device *dev,
+ *				     unsigned long features);
+ *	Modifies features supported by device depending on device-specific
+ *	constraints. Should not modify hardware state.
+ *
+ * int (*ndo_set_features)(struct net_device *dev, unsigned long featu=
res);
+ *	Called to update hardware configuration to new features. Selected
+ *	features might be less than what was returned by ndo_fix_features()=
).
+ *	Must return >0 if it changed dev->features by itself.
+ *
  */
 #define HAVE_NET_DEVICE_OPS
 struct net_device_ops {
@@ -828,6 +839,10 @@ struct net_device_ops {
 	int			(*ndo_fcoe_get_wwn)(struct net_device *dev,
 						    u64 *wwn, int type);
 #endif
+	unsigned long		(*ndo_fix_features)(struct net_device *dev,
+						    unsigned long features);
+	int			(*ndo_set_features)(struct net_device *dev,
+						    unsigned long features);
 };
=20
 /*
@@ -934,6 +949,14 @@ struct net_device {
 				 NETIF_F_SG | NETIF_F_HIGHDMA |		\
 				 NETIF_F_FRAGLIST)
=20
+	/* toggable features with no driver requirements */
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+
+	/* ethtool-toggable features */
+	unsigned long		hw_features;
+	/* ethtool-requested features */
+	unsigned long		wanted_features;
+
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
@@ -2286,9 +2309,15 @@ extern char *netdev_drivername(const struct net_=
device *dev, char *buffer, int l
=20
 extern void linkwatch_run_queue(void);
=20
+static inline unsigned long netdev_get_wanted_features(struct net_devi=
ce *dev)
+{
+	unsigned long toggable =3D dev->hw_features | NETIF_F_SOFT_FEATURES;
+	return (dev->features & ~toggable) | dev->wanted_features;
+}
 unsigned long netdev_increment_features(unsigned long all, unsigned lo=
ng one,
 					unsigned long mask);
 unsigned long netdev_fix_features(unsigned long features, const char *=
name);
+void netdev_update_features(struct net_device *dev);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 6823275..1e616bb 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5078,6 +5078,35 @@ unsigned long netdev_fix_features(unsigned long =
features, const char *name)
 }
 EXPORT_SYMBOL(netdev_fix_features);
=20
+void netdev_update_features(struct net_device *dev)
+{
+	unsigned long enable;
+	int err =3D 0;
+
+	enable =3D netdev_get_wanted_features(dev);
+
+	if (dev->netdev_ops->ndo_fix_features)
+		enable =3D dev->netdev_ops->ndo_fix_features(dev, enable);
+
+	/* driver might be less strict about feature dependencies */
+	enable =3D netdev_fix_features(enable, dev->name);
+
+	if (dev->features =3D=3D enable)
+		return;
+
+	netdev_info(dev, "Features changed: %08lx -> %08lx\n",
+		dev->features, enable);
+
+	if (dev->netdev_ops->ndo_set_features)
+		err =3D dev->netdev_ops->ndo_set_features(dev, enable);
+
+	if (!err)
+		dev->features =3D enable;
+	else if (err < 0)
+		netdev_err(dev, "set_features() failed (%d)\n", err);
+}
+EXPORT_SYMBOL(netdev_update_features);
+
 /**
  *	netif_stacked_transfer_operstate -	transfer operstate
  *	@rootdev: the root or lower level device to transfer state from
@@ -5212,11 +5241,12 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
-	dev->features =3D netdev_fix_features(dev->features, dev->name);
-
-	/* Enable software GSO if SG is supported. */
-	if (dev->features & NETIF_F_SG)
-		dev->features |=3D NETIF_F_GSO;
+	/* Transfer toggable features to wanted_features and enable
+	 * software GSO and GRO as these need no driver support.
+	 */
+	dev->wanted_features =3D (dev->features & dev->hw_features)
+		| NETIF_F_SOFT_FEATURES;
+	netdev_update_features(dev);
=20
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 1774178..f08e7f1 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -171,6 +171,55 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
=20
 /* Handlers for each ethtool command */
=20
+static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
+{
+	struct ethtool_features cmd =3D {
+		.cmd =3D ETHTOOL_GFEATURES,
+		.count =3D ETHTOOL_DEV_FEATURE_WORDS,
+	};
+	struct ethtool_get_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
 =3D {
+		{
+			.available =3D dev->hw_features,
+			.requested =3D dev->wanted_features,
+			.active =3D dev->features,
+		},
+	};
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
+	struct ethtool_features cmd;
+	struct ethtool_set_features_block features[ETHTOOL_DEV_FEATURE_WORDS]=
;
+
+	if (copy_from_user(&cmd, useraddr, sizeof(cmd)))
+		return -EFAULT;
+	useraddr +=3D sizeof(cmd);
+
+	if (cmd.count > ETHTOOL_DEV_FEATURE_WORDS)
+		cmd.count =3D ETHTOOL_DEV_FEATURE_WORDS;
+
+	if (copy_from_user(features, useraddr, sizeof(*features) * cmd.count)=
)
+		return -EFAULT;
+	memset(features + cmd.count, 0,
+		sizeof(features) - sizeof(*features) * cmd.count);
+
+	features[0].valid &=3D dev->hw_features | NETIF_F_SOFT_FEATURES;
+
+	dev->wanted_features &=3D ~features[0].valid;
+	dev->wanted_features |=3D features[0].valid & features[0].requested;
+
+	netdev_update_features(dev);
+
+	return 0;
+}
+
 static int ethtool_get_settings(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_cmd cmd =3D { .cmd =3D ETHTOOL_GSET };
@@ -1500,6 +1549,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 	case ETHTOOL_GRXCLSRLCNT:
 	case ETHTOOL_GRXCLSRULE:
 	case ETHTOOL_GRXCLSRLALL:
+	case ETHTOOL_GFEATURES:
 		break;
 	default:
 		if (!capable(CAP_NET_ADMIN))
@@ -1693,6 +1743,12 @@ int dev_ethtool(struct net *net, struct ifreq *i=
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

