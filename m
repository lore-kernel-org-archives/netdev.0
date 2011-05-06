From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: Fix vlan_features propagation
Date: Fri,  6 May 2011 19:56:29 +0200 (CEST)
Message-ID: <20110506175629.AF59713A6A@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:35149 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901Ab1EFR4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 May 2011 13:56:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix VLAN features propagation for devices which change vlan_features.
=46or this to work, driver needs to make sure netdev_features_changed()
gets called after the change (it is e.g. after ndo_set_features()).

Side effect is that a user might request features that will never
be enabled on a VLAN device.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/8021q/vlan_dev.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index d174c31..526159a 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -531,7 +531,7 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
=20
-	dev->hw_features =3D real_dev->vlan_features & NETIF_F_ALL_TX_OFFLOAD=
S;
+	dev->hw_features =3D NETIF_F_ALL_TX_OFFLOADS;
 	dev->features |=3D real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size =3D real_dev->gso_max_size;
=20
@@ -590,9 +590,11 @@ static u32 vlan_dev_fix_features(struct net_device=
 *dev, u32 features)
 {
 	struct net_device *real_dev =3D vlan_dev_info(dev)->real_dev;
=20
-	features &=3D (real_dev->features | NETIF_F_LLTX);
+	features &=3D real_dev->features;
+	features &=3D real_dev->vlan_features;
 	if (dev_ethtool_get_rx_csum(real_dev))
 		features |=3D NETIF_F_RXCSUM;
+	features |=3D NETIF_F_LLTX;
=20
 	return features;
 }
--=20
1.7.2.5

