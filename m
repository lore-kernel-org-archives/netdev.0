From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [RESEND PATCH net] net: fix ETHTOOL_SFEATURES compatibility with old ethtool_ops.set_flags
Date: Thu, 26 May 2011 12:42:57 +0200 (CEST)
Message-ID: <7bcc407f555d2fbbcd66d26e4b0195060cf8c063.1306405895.git.mirq-linux@rere.qmqm.pl>
References: <20110524215923.GA20138@rere.qmqm.pl>
	<20110516.140958.625993829749556424.davem@davemloft.net>
        <20110519100331.GA25103@rere.qmqm.pl>
        <20110524091437.GA10779@rere.qmqm.pl>
        <20110524.153930.610330240390616957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58395 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812Ab1EZKm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2011 06:42:58 -0400
In-Reply-To: <20110524215923.GA20138@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current code squashes flags to bool - this makes set_flags fail wheneve=
r
some ETH_FLAG_* equivalent features are set. Fix this.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/ethtool.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 84e7304..fd14116 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -233,6 +233,29 @@ static int ethtool_set_feature_compat(struct net_d=
evice *dev,
 	return 1;
 }
=20
+static int ethtool_set_flags_compat(struct net_device *dev,
+	int (*legacy_set)(struct net_device *, u32),
+	struct ethtool_set_features_block *features, u32 mask)
+{
+	u32 value;
+
+	if (!legacy_set)
+		return 0;
+
+	if (!(features[0].valid & mask))
+		return 0;
+
+	value =3D dev->features & ~features[0].valid;
+	value |=3D features[0].requested;
+
+	features[0].valid &=3D ~mask;
+
+	if (legacy_set(dev, value & mask) < 0)
+		netdev_info(dev, "Legacy flags change failed\n");
+
+	return 1;
+}
+
 static int ethtool_set_features_compat(struct net_device *dev,
 	struct ethtool_set_features_block *features)
 {
@@ -249,7 +272,7 @@ static int ethtool_set_features_compat(struct net_d=
evice *dev,
 		features, NETIF_F_ALL_TSO);
 	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_rx_=
csum,
 		features, NETIF_F_RXCSUM);
-	compat |=3D ethtool_set_feature_compat(dev, dev->ethtool_ops->set_fla=
gs,
+	compat |=3D ethtool_set_flags_compat(dev, dev->ethtool_ops->set_flags=
,
 		features, flags_dup_features);
=20
 	return compat;
--=20
1.7.2.5

