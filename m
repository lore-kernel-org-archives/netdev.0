From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 15/25] bnx2x: No LRO without Rx checksum
Date: Wed, 13 Aug 2008 17:15:20 +0300
Message-ID: <1218636920.547.91.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2057 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756645AbYHMOPo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:15:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No LRO without Rx checksum
Disabling LRO when Rx checksum is disabled

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   67 ++++++++++++++++++++++++++-------------------
 1 files changed, 39 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 6fe1972..d29f227 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8272,33 +8272,6 @@ static int bnx2x_set_coalesce(struct net_device *dev,
 	return 0;
 }
 
-static int bnx2x_set_flags(struct net_device *dev, u32 data)
-{
-	struct bnx2x *bp = netdev_priv(dev);
-	int changed = 0;
-	int rc = 0;
-
-	if (data & ETH_FLAG_LRO) {
-		if (!(dev->features & NETIF_F_LRO)) {
-			dev->features |= NETIF_F_LRO;
-			bp->flags |= TPA_ENABLE_FLAG;
-			changed = 1;
-		}
-
-	} else if (dev->features & NETIF_F_LRO) {
-		dev->features &= ~NETIF_F_LRO;
-		bp->flags &= ~TPA_ENABLE_FLAG;
-		changed = 1;
-	}
-
-	if (changed && netif_running(dev)) {
-		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
-	}
-
-	return rc;
-}
-
 static void bnx2x_get_ringparam(struct net_device *dev,
 				struct ethtool_ringparam *ering)
 {
@@ -8400,6 +8373,34 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	return 0;
 }
 
+static int bnx2x_set_flags(struct net_device *dev, u32 data)
+{
+	struct bnx2x *bp = netdev_priv(dev);
+	int changed = 0;
+	int rc = 0;
+
+	/* TPA requires Rx CSUM offloading */
+	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
+		if (!(dev->features & NETIF_F_LRO)) {
+			dev->features |= NETIF_F_LRO;
+			bp->flags |= TPA_ENABLE_FLAG;
+			changed = 1;
+		}
+
+	} else if (dev->features & NETIF_F_LRO) {
+		dev->features &= ~NETIF_F_LRO;
+		bp->flags &= ~TPA_ENABLE_FLAG;
+		changed = 1;
+	}
+
+	if (changed && netif_running(dev)) {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		rc = bnx2x_nic_load(bp, LOAD_NORMAL);
+	}
+
+	return rc;
+}
+
 static u32 bnx2x_get_rx_csum(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
@@ -8410,9 +8411,19 @@ static u32 bnx2x_get_rx_csum(struct net_device *dev)
 static int bnx2x_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct bnx2x *bp = netdev_priv(dev);
+	int rc = 0;
 
 	bp->rx_csum = data;
-	return 0;
+
+	/* Disable TPA, when Rx CSUM is disabled. Otherwise all
+	   TPA'ed packets will be discarded due to wrong TCP CSUM */
+	if (!data) {
+		u32 flags = ethtool_op_get_flags(dev);
+
+		rc = bnx2x_set_flags(dev, (flags & ~ETH_FLAG_LRO));
+	}
+
+	return rc;
 }
 
 static int bnx2x_set_tso(struct net_device *dev, u32 data)
-- 
1.5.3.2




