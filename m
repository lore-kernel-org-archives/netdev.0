From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 2/3] TI Davinci EMAC : add platform specific interrupt enable/disable logic.
Date: Wed, 18 Nov 2009 15:12:07 +0530
Message-ID: <1258537328-31527-3-git-send-email-srk@ti.com>
References: <1258537328-31527-1-git-send-email-srk@ti.com>
 <1258537328-31527-2-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42090 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754986AbZKRJmK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 04:42:10 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAI9gE86022896
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 03:42:16 -0600
In-Reply-To: <1258537328-31527-2-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain SOCs, the EMAC controller is interfaced with a wrapper logic
for handling interrupts. This  patch implements a platform
specific hook to cater to platforms that require custom interrupt
handling logic

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
---
 drivers/net/davinci_emac.c   |   11 +++++++++++
 include/linux/davinci_emac.h |    2 ++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 6aec8f5..81931f8 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -487,6 +487,9 @@ struct emac_priv {
 	struct mii_bus *mii_bus;
 	struct phy_device *phydev;
 	spinlock_t lock;
+	/*platform specific members*/
+	void (*wrapper_int_enable) (void);
+	void (*wrapper_int_disable) (void);
 };
 
 /* clock frequency for EMAC */
@@ -1001,6 +1004,8 @@ static void emac_int_disable(struct emac_priv *priv)
 		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0x0);
 		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0x0);
 		/* NOTE: Rx Threshold and Misc interrupts are not disabled */
+		if (priv->wrapper_int_disable)
+			priv->wrapper_int_disable();
 
 		local_irq_restore(flags);
 
@@ -1020,6 +1025,9 @@ static void emac_int_disable(struct emac_priv *priv)
 static void emac_int_enable(struct emac_priv *priv)
 {
 	if (priv->version == EMAC_VERSION_2) {
+		if (priv->wrapper_int_enable)
+			priv->wrapper_int_enable();
+
 		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0xff);
 		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0xff);
 
@@ -2662,6 +2670,9 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->phy_mask = pdata->phy_mask;
 	priv->rmii_en = pdata->rmii_en;
 	priv->version = pdata->version;
+	priv->wrapper_int_enable = pdata->wrapper_interrupt_enable;
+	priv->wrapper_int_disable = pdata->wrapper_interrupt_disable;
+
 	emac_dev = &ndev->dev;
 	/* Get EMAC platform data */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index ff55487..eb24dc0 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -25,6 +25,8 @@ struct emac_platform_data {
 	u32 mdio_max_freq;
 	u8 rmii_en;
 	u8 version;
+	void (*wrapper_interrupt_enable) (void);
+	void (*wrapper_interrupt_disable) (void);
 };
 
 enum {
-- 
1.6.2.4

