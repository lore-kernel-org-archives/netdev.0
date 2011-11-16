From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 1/9] net: remove legacy ethtool ops
Date: Wed, 16 Nov 2011 02:29:55 +0100 (CET)
Message-ID: <108f72ac6e9eafc2cef64dd582da8a7b22bd4262.1321404954.git.mirq-linux@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46023 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757691Ab1KPB36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:29:58 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As all drivers are converted, we may now remove discrete offload settin=
g
callback handling.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/ethtool.h   |   53 ------
 include/linux/netdevice.h |   16 --
 net/8021q/vlan_dev.c      |    6 +-
 net/core/dev.c            |   12 +-
 net/core/ethtool.c        |  422 +++----------------------------------=
--------
 5 files changed, 28 insertions(+), 481 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index de33de1..20db5b27 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -724,9 +724,6 @@ enum ethtool_sfeatures_retval_bits {
=20
 #include <linux/rculist.h>
=20
-/* needed by dev_disable_lro() */
-extern int __ethtool_set_flags(struct net_device *dev, u32 flags);
-
 extern int __ethtool_get_settings(struct net_device *dev,
 				  struct ethtool_cmd *cmd);
=20
@@ -750,19 +747,6 @@ struct net_device;
=20
 /* Some generic methods drivers may use in their ethtool_ops */
 u32 ethtool_op_get_link(struct net_device *dev);
-u32 ethtool_op_get_tx_csum(struct net_device *dev);
-int ethtool_op_set_tx_csum(struct net_device *dev, u32 data);
-int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data);
-int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data);
-u32 ethtool_op_get_sg(struct net_device *dev);
-int ethtool_op_set_sg(struct net_device *dev, u32 data);
-u32 ethtool_op_get_tso(struct net_device *dev);
-int ethtool_op_set_tso(struct net_device *dev, u32 data);
-u32 ethtool_op_get_ufo(struct net_device *dev);
-int ethtool_op_set_ufo(struct net_device *dev, u32 data);
-u32 ethtool_op_get_flags(struct net_device *dev);
-int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 support=
ed);
-bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 suppo=
rted);
=20
 /**
  * struct ethtool_ops - optional netdev operations
@@ -807,22 +791,6 @@ bool ethtool_invalid_flags(struct net_device *dev,=
 u32 data, u32 supported);
  * @get_pauseparam: Report pause parameters
  * @set_pauseparam: Set pause parameters.  Returns a negative error co=
de
  *	or zero.
- * @get_rx_csum: Deprecated in favour of the netdev feature %NETIF_F_R=
XCSUM.
- *	Report whether receive checksums are turned on or off.
- * @set_rx_csum: Deprecated in favour of generic netdev features.  Tur=
n
- *	receive checksum on or off.  Returns a negative error code or zero.
- * @get_tx_csum: Deprecated as redundant. Report whether transmit chec=
ksums
- *	are turned on or off.
- * @set_tx_csum: Deprecated in favour of generic netdev features.  Tur=
n
- *	transmit checksums on or off.  Returns a negative error code or zer=
o.
- * @get_sg: Deprecated as redundant.  Report whether scatter-gather is
- *	enabled. =20
- * @set_sg: Deprecated in favour of generic netdev features.  Turn
- *	scatter-gather on or off. Returns a negative error code or zero.
- * @get_tso: Deprecated as redundant.  Report whether TCP segmentation
- *	offload is enabled.
- * @set_tso: Deprecated in favour of generic netdev features.  Turn TC=
P
- *	segmentation offload on or off.  Returns a negative error code or z=
ero.
  * @self_test: Run specified self-tests
  * @get_strings: Return a set of strings that describe the requested o=
bjects
  * @set_phys_id: Identify the physical devices, e.g. by flashing an LE=
D
@@ -844,15 +812,6 @@ bool ethtool_invalid_flags(struct net_device *dev,=
 u32 data, u32 supported);
  *	negative error code or zero.
  * @complete: Function to be called after any other operation except
  *	@begin.  Will be called even if the other operation failed.
- * @get_ufo: Deprecated as redundant.  Report whether UDP fragmentatio=
n
- *	offload is enabled.
- * @set_ufo: Deprecated in favour of generic netdev features.  Turn UD=
P
- *	fragmentation offload on or off.  Returns a negative error code or =
zero.
- * @get_flags: Deprecated as redundant.  Report features included in
- *	&enum ethtool_flags that are enabled. =20
- * @set_flags: Deprecated in favour of generic netdev features.  Turn
- *	features included in &enum ethtool_flags on or off.  Returns a
- *	negative error code or zero.
  * @get_priv_flags: Report driver-specific feature flags.
  * @set_priv_flags: Set driver-specific feature flags.  Returns a nega=
tive
  *	error code or zero.
@@ -917,14 +876,6 @@ struct ethtool_ops {
 				  struct ethtool_pauseparam*);
 	int	(*set_pauseparam)(struct net_device *,
 				  struct ethtool_pauseparam*);
-	u32	(*get_rx_csum)(struct net_device *);
-	int	(*set_rx_csum)(struct net_device *, u32);
-	u32	(*get_tx_csum)(struct net_device *);
-	int	(*set_tx_csum)(struct net_device *, u32);
-	u32	(*get_sg)(struct net_device *);
-	int	(*set_sg)(struct net_device *, u32);
-	u32	(*get_tso)(struct net_device *);
-	int	(*set_tso)(struct net_device *, u32);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*set_phys_id)(struct net_device *, enum ethtool_phys_id_state);
@@ -932,10 +883,6 @@ struct ethtool_ops {
 				     struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
-	u32	(*get_ufo)(struct net_device *);
-	int	(*set_ufo)(struct net_device *, u32);
-	u32	(*get_flags)(struct net_device *);
-	int	(*set_flags)(struct net_device *, u32);
 	u32	(*get_priv_flags)(struct net_device *);
 	int	(*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cbeb586..e34717a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2592,22 +2592,6 @@ static inline int netif_is_bond_slave(struct net=
_device *dev)
=20
 extern struct pernet_operations __net_initdata loopback_net_ops;
=20
-static inline u32 dev_ethtool_get_rx_csum(struct net_device *dev)
-{
-	if (dev->features & NETIF_F_RXCSUM)
-		return 1;
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_rx_csum)
-		return 0;
-	return dev->ethtool_ops->get_rx_csum(dev);
-}
-
-static inline u32 dev_ethtool_get_flags(struct net_device *dev)
-{
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_flags)
-		return 0;
-	return dev->ethtool_ops->get_flags(dev);
-}
-
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
=20
 /* netdev_printk helpers, similar to dev_printk */
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index bc25286..6a4e0cb 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -596,13 +596,11 @@ static u32 vlan_dev_fix_features(struct net_devic=
e *dev, u32 features)
 	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
 	u32 old_features =3D features;
=20
-	features &=3D real_dev->features;
 	features &=3D real_dev->vlan_features;
+	features |=3D NETIF_F_RXCSUM;
+	features &=3D real_dev->features;
=20
 	features |=3D old_features & NETIF_F_SOFT_FEATURES;
-
-	if (dev_ethtool_get_rx_csum(real_dev))
-		features |=3D NETIF_F_RXCSUM;
 	features |=3D NETIF_F_LLTX;
=20
 	return features;
diff --git a/net/core/dev.c b/net/core/dev.c
index 6ba50a1..1cd2136 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1320,8 +1320,6 @@ EXPORT_SYMBOL(dev_close);
  */
 void dev_disable_lro(struct net_device *dev)
 {
-	u32 flags;
-
 	/*
 	 * If we're trying to disable lro on a vlan device
 	 * use the underlying physical device instead
@@ -1329,15 +1327,9 @@ void dev_disable_lro(struct net_device *dev)
 	if (is_vlan_dev(dev))
 		dev =3D vlan_dev_real_dev(dev);
=20
-	if (dev->ethtool_ops && dev->ethtool_ops->get_flags)
-		flags =3D dev->ethtool_ops->get_flags(dev);
-	else
-		flags =3D ethtool_op_get_flags(dev);
+	dev->wanted_features &=3D ~NETIF_F_LRO;
+	netdev_update_features(dev);
=20
-	if (!(flags & ETH_FLAG_LRO))
-		return;
-
-	__ethtool_set_flags(dev, flags & ~ETH_FLAG_LRO);
 	if (unlikely(dev->features & NETIF_F_LRO))
 		netdev_WARN(dev, "failed to disable LRO!\n");
 }
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index f444817..db8a77b 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -36,236 +36,10 @@ u32 ethtool_op_get_link(struct net_device *dev)
 }
 EXPORT_SYMBOL(ethtool_op_get_link);
=20
-u32 ethtool_op_get_tx_csum(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_ALL_CSUM) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_tx_csum);
-
-int ethtool_op_set_tx_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_IP_CSUM;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tx_csum);
-
-int ethtool_op_set_tx_hw_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_HW_CSUM;
-	else
-		dev->features &=3D ~NETIF_F_HW_CSUM;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tx_hw_csum);
-
-int ethtool_op_set_tx_ipv6_csum(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-	else
-		dev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tx_ipv6_csum);
-
-u32 ethtool_op_get_sg(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_SG) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_sg);
-
-int ethtool_op_set_sg(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_SG;
-	else
-		dev->features &=3D ~NETIF_F_SG;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_sg);
-
-u32 ethtool_op_get_tso(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_tso);
-
-int ethtool_op_set_tso(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_TSO;
-	else
-		dev->features &=3D ~NETIF_F_TSO;
-
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_tso);
-
-u32 ethtool_op_get_ufo(struct net_device *dev)
-{
-	return (dev->features & NETIF_F_UFO) !=3D 0;
-}
-EXPORT_SYMBOL(ethtool_op_get_ufo);
-
-int ethtool_op_set_ufo(struct net_device *dev, u32 data)
-{
-	if (data)
-		dev->features |=3D NETIF_F_UFO;
-	else
-		dev->features &=3D ~NETIF_F_UFO;
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_ufo);
-
-/* the following list of flags are the same as their associated
- * NETIF_F_xxx values in include/linux/netdevice.h
- */
-static const u32 flags_dup_features =3D
-	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
-	 ETH_FLAG_RXHASH);
-
-u32 ethtool_op_get_flags(struct net_device *dev)
-{
-	/* in the future, this function will probably contain additional
-	 * handling for flags which are not so easily handled
-	 * by a simple masking operation
-	 */
-
-	return dev->features & flags_dup_features;
-}
-EXPORT_SYMBOL(ethtool_op_get_flags);
-
-/* Check if device can enable (or disable) particular feature coded in=
 "data"
- * argument. Flags "supported" describe features that can be toggled b=
y device.
- * If feature can not be toggled, it state (enabled or disabled) must =
match
- * hardcoded device features state, otherwise flags are marked as inva=
lid.
- */
-bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 suppo=
rted)
-{
-	u32 features =3D dev->features & flags_dup_features;
-	/* "data" can contain only flags_dup_features bits,
-	 * see __ethtool_set_flags */
-
-	return (features & ~supported) !=3D (data & ~supported);
-}
-EXPORT_SYMBOL(ethtool_invalid_flags);
-
-int ethtool_op_set_flags(struct net_device *dev, u32 data, u32 support=
ed)
-{
-	if (ethtool_invalid_flags(dev, data, supported))
-		return -EINVAL;
-
-	dev->features =3D ((dev->features & ~flags_dup_features) |
-			 (data & flags_dup_features));
-	return 0;
-}
-EXPORT_SYMBOL(ethtool_op_set_flags);
-
 /* Handlers for each ethtool command */
=20
 #define ETHTOOL_DEV_FEATURE_WORDS	1
=20
-static void ethtool_get_features_compat(struct net_device *dev,
-	struct ethtool_get_features_block *features)
-{
-	if (!dev->ethtool_ops)
-		return;
-
-	/* getting RX checksum */
-	if (dev->ethtool_ops->get_rx_csum)
-		if (dev->ethtool_ops->get_rx_csum(dev))
-			features[0].active |=3D NETIF_F_RXCSUM;
-
-	/* mark legacy-changeable features */
-	if (dev->ethtool_ops->set_sg)
-		features[0].available |=3D NETIF_F_SG;
-	if (dev->ethtool_ops->set_tx_csum)
-		features[0].available |=3D NETIF_F_ALL_CSUM;
-	if (dev->ethtool_ops->set_tso)
-		features[0].available |=3D NETIF_F_ALL_TSO;
-	if (dev->ethtool_ops->set_rx_csum)
-		features[0].available |=3D NETIF_F_RXCSUM;
-	if (dev->ethtool_ops->set_flags)
-		features[0].available |=3D flags_dup_features;
-}
-
-static int ethtool_set_feature_compat(struct net_device *dev,
-	int (*legacy_set)(struct net_device *, u32),
-	struct ethtool_set_features_block *features, u32 mask)
-{
-	u32 do_set;
-
-	if (!legacy_set)
-		return 0;
-
-	if (!(features[0].valid & mask))
-		return 0;
-
-	features[0].valid &=3D ~mask;
-
-	do_set =3D !!(features[0].requested & mask);
-
-	if (legacy_set(dev, do_set) < 0)
-		netdev_info(dev,
-			"Legacy feature change (%s) failed for 0x%08x\n",
-			do_set ? "set" : "clear", mask);
-
-	return 1;
-}
-
-static int ethtool_set_flags_compat(struct net_device *dev,
-	int (*legacy_set)(struct net_device *, u32),
-	struct ethtool_set_features_block *features, u32 mask)
-{
-	u32 value;
-
-	if (!legacy_set)
-		return 0;
-
-	if (!(features[0].valid & mask))
-		return 0;
-
-	value =3D dev->features & ~features[0].valid;
-	value |=3D features[0].requested;
-
-	features[0].valid &=3D ~mask;
-
-	if (legacy_set(dev, value & mask) < 0)
-		netdev_info(dev, "Legacy flags change failed\n");
-
-	return 1;
-}
-
-static int ethtool_set_features_compat(struct net_device *dev,
-	struct ethtool_set_features_block *features)
-{
-	int compat;
-
-	if (!dev->ethtool_ops)
-		return 0;
-
-	compat  =3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_sg,
-		features, NETIF_F_SG);
-	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tx_=
csum,
-		features, NETIF_F_ALL_CSUM);
-	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tso=
,
-		features, NETIF_F_ALL_TSO);
-	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_rx_=
csum,
-		features, NETIF_F_RXCSUM);
-	compat |=3D ethtool_set_flags_compat(dev, dev->ethtool_ops->set_flags=
,
-		features, flags_dup_features);
-
-	return compat;
-}
-
 static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
 {
 	struct ethtool_gfeatures cmd =3D {
@@ -283,8 +57,6 @@ static int ethtool_get_features(struct net_device *d=
ev, void __user *useraddr)
 	u32 __user *sizeaddr;
 	u32 copy_size;
=20
-	ethtool_get_features_compat(dev, features);
-
 	sizeaddr =3D useraddr + offsetof(struct ethtool_gfeatures, size);
 	if (get_user(copy_size, sizeaddr))
 		return -EFAULT;
@@ -320,9 +92,6 @@ static int ethtool_set_features(struct net_device *d=
ev, void __user *useraddr)
 	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
 		return -EINVAL;
=20
-	if (ethtool_set_features_compat(dev, features))
-		ret |=3D ETHTOOL_F_COMPAT;
-
 	if (features[0].valid & ~dev->hw_features) {
 		features[0].valid &=3D dev->hw_features;
 		ret |=3D ETHTOOL_F_UNSUPPORTED;
@@ -433,34 +202,6 @@ static u32 ethtool_get_feature_mask(u32 eth_cmd)
 	}
 }
=20
-static void *__ethtool_get_one_feature_actor(struct net_device *dev, u=
32 ethcmd)
-{
-	const struct ethtool_ops *ops =3D dev->ethtool_ops;
-
-	if (!ops)
-		return NULL;
-
-	switch (ethcmd) {
-	case ETHTOOL_GTXCSUM:
-		return ops->get_tx_csum;
-	case ETHTOOL_GRXCSUM:
-		return ops->get_rx_csum;
-	case ETHTOOL_SSG:
-		return ops->get_sg;
-	case ETHTOOL_STSO:
-		return ops->get_tso;
-	case ETHTOOL_SUFO:
-		return ops->get_ufo;
-	default:
-		return NULL;
-	}
-}
-
-static u32 __ethtool_get_rx_csum_oldbug(struct net_device *dev)
-{
-	return !!(dev->features & NETIF_F_ALL_CSUM);
-}
-
 static int ethtool_get_one_feature(struct net_device *dev,
 	char __user *useraddr, u32 ethcmd)
 {
@@ -470,31 +211,11 @@ static int ethtool_get_one_feature(struct net_dev=
ice *dev,
 		.data =3D !!(dev->features & mask),
 	};
=20
-	/* compatibility with discrete get_ ops */
-	if (!(dev->hw_features & mask)) {
-		u32 (*actor)(struct net_device *);
-
-		actor =3D __ethtool_get_one_feature_actor(dev, ethcmd);
-
-		/* bug compatibility with old get_rx_csum */
-		if (ethcmd =3D=3D ETHTOOL_GRXCSUM && !actor)
-			actor =3D __ethtool_get_rx_csum_oldbug;
-
-		if (actor)
-			edata.data =3D actor(dev);
-	}
-
 	if (copy_to_user(useraddr, &edata, sizeof(edata)))
 		return -EFAULT;
 	return 0;
 }
=20
-static int __ethtool_set_tx_csum(struct net_device *dev, u32 data);
-static int __ethtool_set_rx_csum(struct net_device *dev, u32 data);
-static int __ethtool_set_sg(struct net_device *dev, u32 data);
-static int __ethtool_set_tso(struct net_device *dev, u32 data);
-static int __ethtool_set_ufo(struct net_device *dev, u32 data);
-
 static int ethtool_set_one_feature(struct net_device *dev,
 	void __user *useraddr, u32 ethcmd)
 {
@@ -506,56 +227,38 @@ static int ethtool_set_one_feature(struct net_dev=
ice *dev,
=20
 	mask =3D ethtool_get_feature_mask(ethcmd);
 	mask &=3D dev->hw_features;
-	if (mask) {
-		if (edata.data)
-			dev->wanted_features |=3D mask;
-		else
-			dev->wanted_features &=3D ~mask;
-
-		__netdev_update_features(dev);
-		return 0;
-	}
-
-	/* Driver is not converted to ndo_fix_features or does not
-	 * support changing this offload. In the latter case it won't
-	 * have corresponding ethtool_ops field set.
-	 *
-	 * Following part is to be removed after all drivers advertise
-	 * their changeable features in netdev->hw_features and stop
-	 * using discrete offload setting ops.
-	 */
-
-	switch (ethcmd) {
-	case ETHTOOL_STXCSUM:
-		return __ethtool_set_tx_csum(dev, edata.data);
-	case ETHTOOL_SRXCSUM:
-		return __ethtool_set_rx_csum(dev, edata.data);
-	case ETHTOOL_SSG:
-		return __ethtool_set_sg(dev, edata.data);
-	case ETHTOOL_STSO:
-		return __ethtool_set_tso(dev, edata.data);
-	case ETHTOOL_SUFO:
-		return __ethtool_set_ufo(dev, edata.data);
-	default:
+	if (!mask)
 		return -EOPNOTSUPP;
-	}
+
+	if (edata.data)
+		dev->wanted_features |=3D mask;
+	else
+		dev->wanted_features &=3D ~mask;
+
+	__netdev_update_features(dev);
+
+	return 0;
+}
+
+/* the following list of flags are the same as their associated
+ * NETIF_F_xxx values in include/linux/netdevice.h
+ */
+static const u32 flags_dup_features =3D
+	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
+	 ETH_FLAG_RXHASH);
+
+static u32 __ethtool_get_flags(struct net_device *dev)
+{
+	return dev->features & flags_dup_features;
 }
=20
-int __ethtool_set_flags(struct net_device *dev, u32 data)
+static int __ethtool_set_flags(struct net_device *dev, u32 data)
 {
 	u32 changed;
=20
 	if (data & ~flags_dup_features)
 		return -EINVAL;
=20
-	/* legacy set_flags() op */
-	if (dev->ethtool_ops->set_flags) {
-		if (unlikely(dev->hw_features & flags_dup_features))
-			netdev_warn(dev,
-				"driver BUG: mixed hw_features and set_flags()\n");
-		return dev->ethtool_ops->set_flags(dev, data);
-	}
-
 	/* allow changing only bits set in hw_features */
 	changed =3D (data ^ dev->features) & flags_dup_features;
 	if (changed & ~dev->hw_features)
@@ -1231,81 +934,6 @@ static int ethtool_set_pauseparam(struct net_devi=
ce *dev, void __user *useraddr)
 	return dev->ethtool_ops->set_pauseparam(dev, &pauseparam);
 }
=20
-static int __ethtool_set_sg(struct net_device *dev, u32 data)
-{
-	int err;
-
-	if (!dev->ethtool_ops->set_sg)
-		return -EOPNOTSUPP;
-
-	if (data && !(dev->features & NETIF_F_ALL_CSUM))
-		return -EINVAL;
-
-	if (!data && dev->ethtool_ops->set_tso) {
-		err =3D dev->ethtool_ops->set_tso(dev, 0);
-		if (err)
-			return err;
-	}
-
-	if (!data && dev->ethtool_ops->set_ufo) {
-		err =3D dev->ethtool_ops->set_ufo(dev, 0);
-		if (err)
-			return err;
-	}
-	return dev->ethtool_ops->set_sg(dev, data);
-}
-
-static int __ethtool_set_tx_csum(struct net_device *dev, u32 data)
-{
-	int err;
-
-	if (!dev->ethtool_ops->set_tx_csum)
-		return -EOPNOTSUPP;
-
-	if (!data && dev->ethtool_ops->set_sg) {
-		err =3D __ethtool_set_sg(dev, 0);
-		if (err)
-			return err;
-	}
-
-	return dev->ethtool_ops->set_tx_csum(dev, data);
-}
-
-static int __ethtool_set_rx_csum(struct net_device *dev, u32 data)
-{
-	if (!dev->ethtool_ops->set_rx_csum)
-		return -EOPNOTSUPP;
-
-	if (!data)
-		dev->features &=3D ~NETIF_F_GRO;
-
-	return dev->ethtool_ops->set_rx_csum(dev, data);
-}
-
-static int __ethtool_set_tso(struct net_device *dev, u32 data)
-{
-	if (!dev->ethtool_ops->set_tso)
-		return -EOPNOTSUPP;
-
-	if (data && !(dev->features & NETIF_F_SG))
-		return -EINVAL;
-
-	return dev->ethtool_ops->set_tso(dev, data);
-}
-
-static int __ethtool_set_ufo(struct net_device *dev, u32 data)
-{
-	if (!dev->ethtool_ops->set_ufo)
-		return -EOPNOTSUPP;
-	if (data && !(dev->features & NETIF_F_SG))
-		return -EINVAL;
-	if (data && !((dev->features & NETIF_F_GEN_CSUM) ||
-		(dev->features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
-			=3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))
-		return -EINVAL;
-	return dev->ethtool_ops->set_ufo(dev, data);
-}
-
 static int ethtool_self_test(struct net_device *dev, char __user *user=
addr)
 {
 	struct ethtool_test test;
@@ -1771,9 +1399,7 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		break;
 	case ETHTOOL_GFLAGS:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       (dev->ethtool_ops->get_flags ?
-					dev->ethtool_ops->get_flags :
-					ethtool_op_get_flags));
+					__ethtool_get_flags);
 		break;
 	case ETHTOOL_SFLAGS:
 		rc =3D ethtool_set_value(dev, useraddr, __ethtool_set_flags);
--=20
1.7.7.1
