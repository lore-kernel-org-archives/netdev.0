From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 2/4] net: avoid initial "Features changed" message
Date: Wed, 23 Feb 2011 03:52:28 +0100 (CET)
Message-ID: <dca89b8c68689d85a4a47789c13e4910308e1b36.1298429033.git.mirq-linux@rere.qmqm.pl>
References: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47060 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753561Ab1BWCwa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 21:52:30 -0500
In-Reply-To: <cover.1298429033.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid "Features changed" message and ndo_set_features call on device
registration caused by automatic enabling of GSO and GRO. Driver should
have enabled hardware offloads it set in features, so the ndo_set_featu=
res()
is not needed at registration time.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/core/dev.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 77e5edb..69a3c08 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5476,12 +5476,14 @@ int register_netdevice(struct net_device *dev)
 	 * software offloads (GSO and GRO).
 	 */
 	dev->hw_features |=3D NETIF_F_SOFT_FEATURES;
-	dev->wanted_features =3D (dev->features & dev->hw_features)
-		| NETIF_F_SOFT_FEATURES;
+	dev->features |=3D NETIF_F_SOFT_FEATURES;
+	dev->wanted_features =3D dev->features & dev->hw_features;
=20
 	/* Avoid warning from netdev_fix_features() for GSO without SG */
-	if (!(dev->wanted_features & NETIF_F_SG))
+	if (!(dev->wanted_features & NETIF_F_SG)) {
 		dev->wanted_features &=3D ~NETIF_F_GSO;
+		dev->features &=3D ~NETIF_F_GSO;
+	}
=20
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
--=20
1.7.2.3

