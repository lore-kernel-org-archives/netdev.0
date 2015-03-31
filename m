From: Petri Gynther <pgynther@google.com>
Subject: [PATCH net-next] net: bcmgenet: enable MoCA link state change detection
Date: Tue, 31 Mar 2015 15:00:08 -0700 (PDT)
Message-ID: <20150331220008.B9C2022023D@puck.mtv.corp.google.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:34119 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbbCaWAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 18:00:10 -0400
Received: by qgdq107 with SMTP id q107so2701811qgd.1
        for <netdev@vger.kernel.org>; Tue, 31 Mar 2015 15:00:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, MoCA fixed PHYs are always in link-up state, regardless of
whether the link is actually up or not.

Add code to properly detect MoCA link state changes and to reflect the
new state in MoCA fixed PHY. Only GENET V3 and V4 MACs are capable of
detecting MoCA link state changes.

The code works as follows:
1. GENET MAC detects MoCA link state change and issues UMAC_IRQ_LINK_UP
   or UMAC_IRQ_LINK_DOWN interrupt.
2. Link up/down interrupt is processed in bcmgenet_irq_task(), which
   calls phy_mac_interrupt().
3. phy_mac_interrupt() updates the fixed PHY phydev->link and kicks
   the PHY state machine.
4. PHY state machine proceeds to read the fixed PHY link status
   register.
5. When the fixed PHY link status register is being read, the new
   function bcmgenet_fixed_phy_link_update() gets called. It copies
   the fixed PHY phydev->link value to the fixed PHY status->link.
6. PHY state machine receives the new link state of the fixed PHY.
7. MoCA fixed PHY link state now correctly reflects the real MoCA
   hardware link state.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  9 +++++++--
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 16 ++++++++++++++++
 3 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f7855a6..6043734 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1734,6 +1734,9 @@ static int init_umac(struct bcmgenet_priv *priv)
 	} else if (priv->ext_phy) {
 		int0_enable |= UMAC_IRQ_LINK_EVENT;
 	} else if (priv->phy_interface == PHY_INTERFACE_MODE_MOCA) {
+		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
+			int0_enable |= UMAC_IRQ_LINK_EVENT;
+
 		reg = bcmgenet_bp_mc_get(priv);
 		reg |= BIT(priv->hw_params->bp_in_en_shift);
 
@@ -2926,7 +2929,8 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.rdma_offset = 0x10000,
 		.tdma_offset = 0x11000,
 		.words_per_bd = 2,
-		.flags = GENET_HAS_EXT | GENET_HAS_MDIO_INTR,
+		.flags = GENET_HAS_EXT | GENET_HAS_MDIO_INTR |
+			 GENET_HAS_MOCA_LINK_DET,
 	},
 	[GENET_V4] = {
 		.tx_queues = 4,
@@ -2944,7 +2948,8 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.rdma_offset = 0x2000,
 		.tdma_offset = 0x4000,
 		.words_per_bd = 3,
-		.flags = GENET_HAS_40BITS | GENET_HAS_EXT | GENET_HAS_MDIO_INTR,
+		.flags = GENET_HAS_40BITS | GENET_HAS_EXT |
+			 GENET_HAS_MDIO_INTR | GENET_HAS_MOCA_LINK_DET,
 	},
 };
 
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index ddaa40c..6f2887a 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -508,6 +508,7 @@ enum bcmgenet_version {
 #define GENET_HAS_40BITS	(1 << 0)
 #define GENET_HAS_EXT		(1 << 1)
 #define GENET_HAS_MDIO_INTR	(1 << 2)
+#define GENET_HAS_MOCA_LINK_DET	(1 << 3)
 
 /* BCMGENET hardware parameters, keep this structure nicely aligned
  * since it is going to be used in hot paths
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index 6d3b66a..ad94027 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -462,6 +462,15 @@ static int bcmgenet_mii_of_init(struct bcmgenet_priv *priv)
 	return 0;
 }
 
+static int bcmgenet_fixed_phy_link_update(struct net_device *dev,
+					  struct fixed_phy_status *status)
+{
+	if (dev && dev->phydev && status)
+		status->link = dev->phydev->link;
+
+	return 0;
+}
+
 static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 {
 	struct device *kdev = &priv->pdev->dev;
@@ -513,6 +522,13 @@ static int bcmgenet_mii_pd_init(struct bcmgenet_priv *priv)
 			dev_err(kdev, "failed to register fixed PHY device\n");
 			return -ENODEV;
 		}
+
+		if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET) {
+			ret = fixed_phy_set_link_update(phydev,
+						bcmgenet_fixed_phy_link_update);
+			if (!ret)
+				phydev->link = 0;
+		}
 	}
 
 	priv->phydev = phydev;
-- 
2.2.0.rc0.207.ga3a616c
