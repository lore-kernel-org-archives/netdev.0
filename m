From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: fix ETHTOOL_SFEATURES compatibility with old ethtool_ops.set_flags
Date: Sat, 14 May 2011 12:41:32 +0200 (CEST)
Message-ID: <20110514104132.5304F13A6A@rere.qmqm.pl>
References: <20110514103111.3FD5913A6A@rere.qmqm.pl>
	<20110514095457.GA31970@rere.qmqm.pl>
        <1305335142.2851.70.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43639 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752358Ab1ENKld (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 06:41:33 -0400
In-Reply-To: <20110514103111.3FD5913A6A@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
v2: fix 'valid' bits clearing before use

 net/core/ethtool.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index b8c2bcf..d1c8b64 100644
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

