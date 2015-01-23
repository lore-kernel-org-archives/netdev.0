From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bonding: handle more gso types
Date: Fri, 23 Jan 2015 05:57:26 -0800
Message-ID: <1422021446.29618.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f170.google.com ([209.85.223.170]:52080 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750827AbbAWN52 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 08:57:28 -0500
Received: by mail-ie0-f170.google.com with SMTP id y20so3108845ier.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 05:57:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

In commit 5a7baa78851b ("bonding: Advertize vxlan offload features when
supported"), Or Gerlitz added support conditional vxlan offload.

In this patch I also add support for GRE, IPIP and SIT tunnels,
but we allow a bonding device to not require segmentation,
as it is always better to make this segmentation at the very last stage,
if a particular slave device requires it.

Tested:

ethtool -K bond0 tx-gre-segmentation off

super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
7538.32

ethtool -K bond0 tx-gre-segmentation on 

super_netperf 50 --google-pacing-rate 30000000 -H 10.7.8.152 -l 15
10200.5

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/bonding/bond_main.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 0dceba1a2ba15f4706922a5423f680e7cd17ef77..1e837fceb3fb7b739c543b0d5babc4da4797caf3 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -998,7 +998,10 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
 				 NETIF_F_HIGHDMA | NETIF_F_LRO)
 
 #define BOND_ENC_FEATURES	(NETIF_F_ALL_CSUM | NETIF_F_SG | NETIF_F_RXCSUM |\
-				 NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL)
+				 NETIF_F_TSO)
+
+#define BOND_ENC_ALWAYS		(NETIF_F_GSO_GRE | NETIF_F_GSO_IPIP | \
+				 NETIF_F_GSO_SIT | NETIF_F_GSO_UDP_TUNNEL)
 
 static void bond_compute_features(struct bonding *bond)
 {
@@ -1034,7 +1037,7 @@ static void bond_compute_features(struct bonding *bond)
 
 done:
 	bond_dev->vlan_features = vlan_features;
-	bond_dev->hw_enc_features = enc_features;
+	bond_dev->hw_enc_features = enc_features | BOND_ENC_ALWAYS;
 	bond_dev->hard_header_len = max_hard_header_len;
 	bond_dev->gso_max_segs = gso_max_segs;
 	netif_set_gso_max_size(bond_dev, gso_max_size);
@@ -4010,7 +4013,7 @@ void bond_setup(struct net_device *bond_dev)
 				NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	bond_dev->hw_features &= ~(NETIF_F_ALL_CSUM & ~NETIF_F_HW_CSUM);
-	bond_dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+	bond_dev->hw_features |= BOND_ENC_ALWAYS;
 	bond_dev->features |= bond_dev->hw_features;
 }
 
