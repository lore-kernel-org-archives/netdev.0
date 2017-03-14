From: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 06/12] net: bcmgenet: remove handling of wol interrupts from isr0
Date: Mon, 13 Mar 2017 17:41:36 -0700
Message-ID: <20170314004142.4746-7-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        rafal-g1n6cQUeyibVItvQsEIGlw@public.gmane.org, xow-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, joel-U3u1mxZcP9KHXe+LvDLADg@public.gmane.org,
        jon.mason-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        pgynther-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, jaedon.shin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170314004142.4746-1-opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The bcmgenet_wol_isr() handler performs the necessary processing for
waking from a GENET event.  There is no necessary functionality behind
servicing the UMAC_IRQ_MPD_R event in the handling of isr0.  Therefore
the code that unmasks and masks this interrupt and that gets invoked
in response to it is removed by this commit.

Signed-off-by: Doug Berger <opendmb-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c     | 10 +---------
 drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c | 15 +--------------
 2 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 9be884021679..661ca1b39c89 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -2455,13 +2455,6 @@ static void bcmgenet_irq_task(struct work_struct *work)
 
 	netif_dbg(priv, intr, priv->dev, "%s\n", __func__);
 
-	if (priv->irq0_stat & UMAC_IRQ_MPD_R) {
-		priv->irq0_stat &= ~UMAC_IRQ_MPD_R;
-		netif_dbg(priv, wol, priv->dev,
-			  "magic packet detected, waking up\n");
-		bcmgenet_power_up(priv, GENET_POWER_WOL_MAGIC);
-	}
-
 	/* Link UP/DOWN event */
 	if (priv->irq0_stat & UMAC_IRQ_LINK_EVENT) {
 		phy_mac_interrupt(priv->phydev,
@@ -2558,8 +2551,7 @@ static irqreturn_t bcmgenet_isr0(int irq, void *dev_id)
 				UMAC_IRQ_PHY_DET_F |
 				UMAC_IRQ_LINK_EVENT |
 				UMAC_IRQ_HFB_SM |
-				UMAC_IRQ_HFB_MM |
-				UMAC_IRQ_MPD_R)) {
+				UMAC_IRQ_HFB_MM)) {
 		/* all other interested interrupts handled in bottom half */
 		schedule_work(&priv->bcmgenet_irq_work);
 	}
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
index b97122926d3a..2fbd027f0148 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet_wol.c
@@ -1,7 +1,7 @@
 /*
  * Broadcom GENET (Gigabit Ethernet) Wake-on-LAN support
  *
- * Copyright (c) 2014 Broadcom Corporation
+ * Copyright (c) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -127,7 +127,6 @@ int bcmgenet_wol_power_down_cfg(struct bcmgenet_priv *priv,
 				enum bcmgenet_power_mode mode)
 {
 	struct net_device *dev = priv->dev;
-	u32 cpu_mask_clear;
 	int retries = 0;
 	u32 reg;
 
@@ -173,18 +172,12 @@ int bcmgenet_wol_power_down_cfg(struct bcmgenet_priv *priv,
 		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 	}
 
-	/* Enable the MPD interrupt */
-	cpu_mask_clear = UMAC_IRQ_MPD_R;
-
-	bcmgenet_intrl2_0_writel(priv, cpu_mask_clear, INTRL2_CPU_MASK_CLEAR);
-
 	return 0;
 }
 
 void bcmgenet_wol_power_up_cfg(struct bcmgenet_priv *priv,
 			       enum bcmgenet_power_mode mode)
 {
-	u32 cpu_mask_set;
 	u32 reg;
 
 	if (mode != GENET_POWER_WOL_MAGIC) {
@@ -201,10 +194,4 @@ void bcmgenet_wol_power_up_cfg(struct bcmgenet_priv *priv,
 	reg &= ~CMD_CRC_FWD;
 	bcmgenet_umac_writel(priv, reg, UMAC_CMD);
 	priv->crc_fwd_en = 0;
-
-	/* Stop monitoring magic packet IRQ */
-	cpu_mask_set = UMAC_IRQ_MPD_R;
-
-	/* Stop monitoring magic packet IRQ */
-	bcmgenet_intrl2_0_writel(priv, cpu_mask_set, INTRL2_CPU_MASK_SET);
 }
-- 
2.11.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
