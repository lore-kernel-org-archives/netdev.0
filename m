From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 4/4] net: Implement SFEATURES compatibility for not updated drivers
Date: Wed, 23 Feb 2011 03:52:29 +0100 (CET)
Message-ID: <57863a3adf00fb5a1357d4fd2040ae5bc2db56fd.1298429033.git.mirq-linux@rere.qmqm.pl>
References: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47061 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754876Ab1BWCwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 21:52:31 -0500
In-Reply-To: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use discrete setting ops for not updated drivers. This will not make
them conform to full G/SFEATURES semantics, though.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/ethtool.h |    5 ++++
 net/core/ethtool.c      |   61 +++++++++++++++++++++++++++++++++++++++=
++++++++
 2 files changed, 66 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 54d776c..aac3e2e 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -591,6 +591,9 @@ struct ethtool_sfeatures {
  *      Probably there are other device-specific constraints on some f=
eatures
  *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is cons=
idered
  *      here as though ignored bits were cleared.
+ *   %ETHTOOL_F_COMPAT - some or all changes requested were made by ca=
lling
+ *      compatibility functions. Requested offload state cannot be pro=
perly
+ *      managed by kernel.
  *
  * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (n=
umber of
  * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS c=
ommands
@@ -600,10 +603,12 @@ struct ethtool_sfeatures {
 enum ethtool_sfeatures_retval_bits {
 	ETHTOOL_F_UNSUPPORTED__BIT,
 	ETHTOOL_F_WISH__BIT,
+	ETHTOOL_F_COMPAT__BIT,
 };
=20
 #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
+#define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
=20
 #ifdef __KERNEL__
=20
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 69a3edc..c1a71bb 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -178,6 +178,64 @@ static void ethtool_get_features_compat(struct net=
_device *dev,
 	if (dev->ethtool_ops->get_rx_csum)
 		if (dev->ethtool_ops->get_rx_csum(dev))
 			features[0].active |=3D NETIF_F_RXCSUM;
+
+	/* mark legacy-changeable features */
+	if (dev->ethtool_ops->set_sg)
+		features[0].available |=3D NETIF_F_SG;
+	if (dev->ethtool_ops->set_tx_csum)
+		features[0].available |=3D NETIF_F_ALL_CSUM;
+	if (dev->ethtool_ops->set_tso)
+		features[0].available |=3D NETIF_F_ALL_TSO;
+	if (dev->ethtool_ops->set_rx_csum)
+		features[0].available |=3D NETIF_F_RXCSUM;
+	if (dev->ethtool_ops->set_flags)
+		features[0].available |=3D flags_dup_features;
+}
+
+static int ethtool_set_feature_compat(struct net_device *dev,
+	int (*legacy_set)(struct net_device *, u32),
+	struct ethtool_set_features_block *features, u32 mask)
+{
+	u32 do_set;
+
+	if (!legacy_set)
+		return 0;
+
+	if (!(features[0].valid & mask))
+		return 0;
+
+	features[0].valid &=3D ~mask;
+
+	do_set =3D !!(features[0].requested & mask);
+
+	if (legacy_set(dev, do_set) < 0)
+		netdev_info(dev,
+			"Legacy feature change (%s) failed for 0x%08x\n",
+			do_set ? "set" : "clear", mask);
+
+	return 1;
+}
+
+static int ethtool_set_features_compat(struct net_device *dev,
+	struct ethtool_set_features_block *features)
+{
+	int compat;
+
+	if (!dev->ethtool_ops)
+		return 0;
+
+	compat  =3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_sg,
+		features, NETIF_F_SG);
+	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tx_=
csum,
+		features, NETIF_F_ALL_CSUM);
+	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tso=
,
+		features, NETIF_F_ALL_TSO);
+	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_rx_=
csum,
+		features, NETIF_F_RXCSUM);
+	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_fla=
gs,
+		features, flags_dup_features);
+
+	return compat;
 }
=20
 static int ethtool_get_features(struct net_device *dev, void __user *u=
seraddr)
@@ -234,6 +292,9 @@ static int ethtool_set_features(struct net_device *=
dev, void __user *useraddr)
 	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
 		return -EINVAL;
=20
+	if (ethtool_set_features_compat(dev, features))
+		ret |=3D ETHTOOL_F_COMPAT;
+
 	if (features[0].valid & ~dev->hw_features) {
 		features[0].valid &=3D dev->hw_features;
 		ret |=3D ETHTOOL_F_UNSUPPORTED;
--=20
1.7.2.3

