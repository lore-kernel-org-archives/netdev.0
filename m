From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next] vlan: Add ability to always enable TSO/UFO
Date: Wed, 10 Dec 2014 11:43:13 +0900
Message-ID: <1418179394-4470-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:59969 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754011AbaLJCnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 21:43:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the real device can segment packets by software, a vlan device
can set TSO/UFO even when the real device doesn't have those features.
Unlike GSO, this allows packets to be segmented after Qdisc.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/8021q/vlan_dev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 3768050..1189564 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -579,11 +579,12 @@ static int vlan_dev_init(struct net_device *dev)
 		      (1<<__LINK_STATE_PRESENT);
 
 	dev->hw_features = NETIF_F_ALL_CSUM | NETIF_F_SG |
-			   NETIF_F_FRAGLIST | NETIF_F_ALL_TSO |
+			   NETIF_F_FRAGLIST | NETIF_F_GSO_SOFTWARE |
 			   NETIF_F_HIGHDMA | NETIF_F_SCTP_CSUM |
 			   NETIF_F_ALL_FCOE;
 
-	dev->features |= real_dev->vlan_features | NETIF_F_LLTX;
+	dev->features |= real_dev->vlan_features | NETIF_F_LLTX |
+			 NETIF_F_GSO_SOFTWARE;
 	dev->gso_max_size = real_dev->gso_max_size;
 	if (dev->features & NETIF_F_VLAN_FEATURES)
 		netdev_warn(real_dev, "VLAN features are set incorrectly.  Q-in-Q configurations may not work correctly.\n");
@@ -648,7 +649,7 @@ static netdev_features_t vlan_dev_fix_features(struct net_device *dev,
 	features |= NETIF_F_RXCSUM;
 	features = netdev_intersect_features(features, real_dev->features);
 
-	features |= old_features & NETIF_F_SOFT_FEATURES;
+	features |= old_features & (NETIF_F_SOFT_FEATURES | NETIF_F_GSO_SOFTWARE);
 	features |= NETIF_F_LLTX;
 
 	return features;
-- 
1.8.1.2
