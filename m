From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v5 2/9] net: ethtool: break association of ETH_FLAG_* with
 NETIF_F_*
Date: Wed, 16 Nov 2011 02:29:55 +0100 (CET)
Message-ID: <768d41024675f5dd2ca20e77e2f04cc7a8aa0519.1321404954.git.mirq-linux@rere.qmqm.pl>
References: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:46024 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757687Ab1KPB35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 20:29:57 -0500
In-Reply-To: <cover.1321404954.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the only place left where dev->features are directly
exposed to userspace.

I know checkpatch.pl complains about __ethtool_{get,set}_flags(), but
the code is easier to read this way.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index db8a77b..a354919 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -240,32 +240,45 @@ static int ethtool_set_one_feature(struct net_dev=
ice *dev,
 	return 0;
 }
=20
-/* the following list of flags are the same as their associated
- * NETIF_F_xxx values in include/linux/netdevice.h
- */
-static const u32 flags_dup_features =3D
-	(ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN | ETH_FLAG_NTUPLE |
-	 ETH_FLAG_RXHASH);
+#define ETH_ALL_FLAGS    (ETH_FLAG_LRO | ETH_FLAG_RXVLAN | ETH_FLAG_TX=
VLAN | \
+			  ETH_FLAG_NTUPLE | ETH_FLAG_RXHASH)
+#define ETH_ALL_FEATURES (NETIF_F_LRO | NETIF_F_HW_VLAN_RX | \
+			  NETIF_F_HW_VLAN_TX | NETIF_F_NTUPLE | NETIF_F_RXHASH)
=20
 static u32 __ethtool_get_flags(struct net_device *dev)
 {
-	return dev->features & flags_dup_features;
+	u32 flags =3D 0;
+
+	if (dev->features & NETIF_F_LRO)	flags |=3D ETH_FLAG_LRO;
+	if (dev->features & NETIF_F_HW_VLAN_RX)	flags |=3D ETH_FLAG_RXVLAN;
+	if (dev->features & NETIF_F_HW_VLAN_TX)	flags |=3D ETH_FLAG_TXVLAN;
+	if (dev->features & NETIF_F_NTUPLE)	flags |=3D ETH_FLAG_NTUPLE;
+	if (dev->features & NETIF_F_RXHASH)	flags |=3D ETH_FLAG_RXHASH;
+
+	return flags;
 }
=20
 static int __ethtool_set_flags(struct net_device *dev, u32 data)
 {
+	u32 features =3D 0;
 	u32 changed;
=20
-	if (data & ~flags_dup_features)
+	if (data & ~ETH_ALL_FLAGS)
 		return -EINVAL;
=20
+	if (data & ETH_FLAG_LRO)	features |=3D NETIF_F_LRO;
+	if (data & ETH_FLAG_RXVLAN)	features |=3D NETIF_F_HW_VLAN_RX;
+	if (data & ETH_FLAG_TXVLAN)	features |=3D NETIF_F_HW_VLAN_TX;
+	if (data & ETH_FLAG_NTUPLE)	features |=3D NETIF_F_NTUPLE;
+	if (data & ETH_FLAG_RXHASH)	features |=3D NETIF_F_RXHASH;
+
 	/* allow changing only bits set in hw_features */
-	changed =3D (data ^ dev->features) & flags_dup_features;
+	changed =3D (features ^ dev->features) & ETH_ALL_FEATURES;
 	if (changed & ~dev->hw_features)
 		return (changed & dev->hw_features) ? -EINVAL : -EOPNOTSUPP;
=20
 	dev->wanted_features =3D
-		(dev->wanted_features & ~changed) | (data & dev->hw_features);
+		(dev->wanted_features & ~changed) | (features & changed);
=20
 	__netdev_update_features(dev);
=20
--=20
1.7.7.1
