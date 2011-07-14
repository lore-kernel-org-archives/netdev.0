From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 1/1 net] net: fix bonding advertising offloads it can't support
Date: Fri, 15 Jul 2011 00:34:50 +0200 (CEST)
Message-ID: <45ec1e78b1bf8934a84e68968a0bb8b747eec6bf.1310682766.git.mirq-linux@rere.qmqm.pl>
References: <20110714.145857.1611970250010658023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:34245 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932363Ab1GNWew (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2011 18:34:52 -0400
In-Reply-To: <20110714.145857.1611970250010658023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no software fallback implemented for SCTP or FCoE checksumming=
,
and so it should not be passed on by software devices like bridge or
bonding.

=46or VLAN devices, this is different. First, the driver for underlying
device should be prepared to get offloaded packets even when the featur=
e
is disabled (especially if it advertises it in vlan_features). Second,
devices under VLANs do not get replaced without tearing down the VLAN
first.

This fixes a mess I accidentally introduced while converting bonding to
ndo_fix_features in b2a103e6d0.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index eafe44a..63c22b0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1428,9 +1428,9 @@ out:
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
--=20
1.7.5.4

