From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 06/10] net: remove NETIF_F_ALL_TX_OFFLOADS
Date: Thu, 14 Jul 2011 02:10:29 +0200 (CEST)
Message-ID: <7750f18707f8ebc674a830555b0227c49cbfd608.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59821 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752733Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no software fallback implemented for SCTP or FCoE checksumming=
,
and so it should not be passed on by software devices like bridge or bo=
nding.

=46or VLAN devices, this is different. First, the driver for underlying=
 device
should be prepared to get offloaded packets even when the feature is di=
sabled
(especially if it advertises it in vlan_features). Second, devices unde=
r
VLANs do not get replaced without tearing down the VLAN first.

This fixes a mess I accidentally introduced while converting bonding to
ndo_fix_features.

NETIF_F_SOFT_FEATURES are removed from BOND_VLAN_FEATURES because they
are unused as of commit 712ae51afd.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_main.c |    6 +++---
 include/linux/netdevice.h       |    6 ------
 net/8021q/vlan_dev.c            |    6 +++++-
 3 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 61265f7..b9eaf5c 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1415,9 +1415,9 @@ out:
 	return features;
 }
=20
-#define BOND_VLAN_FEATURES	(NETIF_F_ALL_TX_OFFLOADS | \
-				 NETIF_F_SOFT_FEATURES | \
-				 NETIF_F_LRO)
+#define BOND_VLAN_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
+				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
+				 NETIF_F_HIGHDMA | NETIF_F_LRO)
=20
 static void bond_compute_features(struct bonding *bond)
 {
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 7538237..faa415d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1084,12 +1084,6 @@ struct net_device {
 #define NETIF_F_ALL_FCOE	(NETIF_F_FCOE_CRC | NETIF_F_FCOE_MTU | \
 				 NETIF_F_FSO)
=20
-#define NETIF_F_ALL_TX_OFFLOADS	(NETIF_F_ALL_CSUM | NETIF_F_SG | \
-				 NETIF_F_FRAGLIST | NETIF_F_ALL_TSO | \
-				 NETIF_F_HIGHDMA | \
-				 NETIF_F_SCTP_CSUM | \
-				 NETIF_F_ALL_FCOE)
-
 	/*
 	 * If one device supports one of these features, then enable them
 	 * for all in netdev_increment_features.
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 7f67f2e..3db056b 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -530,7 +530,11 @@ static int vlan_dev_init(struct net_device *dev)
 					  (1<<__LINK_STATE_DORMANT))) |
 		      (1<<__LINK_STATE_PRESENT);
=20
-	dev->hw_features =3D NETIF_F_ALL_TX_OFFLOADS;
+	dev->hw_features =3D NETIF_F_ALL_CSUM | NETIF_F_SG |
+			   NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |
+			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CSUM |
+			   NETIF_F_ALL_FCOE;
+
 	dev->features |=3D real_dev->vlan_features | NETIF_F_LLTX;
 	dev->gso_max_size =3D real_dev->gso_max_size;
=20
--=20
1.7.5.4

