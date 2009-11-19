From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH-v2 2/3] TI Davinci EMAC : add platform specific interrupt enable/disable logic.
Date: Thu, 19 Nov 2009 15:58:26 +0530
Message-ID: <1258626507-5570-3-git-send-email-srk@ti.com>
References: <1258626507-5570-1-git-send-email-srk@ti.com>
 <1258626507-5570-2-git-send-email-srk@ti.com>
Cc: netdev@vger.kernel.org, Sriramakrishnan <srk@ti.com>
To: davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55758 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757510AbZKSK23 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2009 05:28:29 -0500
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id nAJASXwh002656
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 19 Nov 2009 04:28:35 -0600
In-Reply-To: <1258626507-5570-2-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain SOCs, the EMAC controller is interfaced with a wrapper logic
for handling interrupts. This  patch implements a platform
specific hook to cater to platforms that require custom interrupt
handling logic

Signed-off-by: Sriramakrishnan <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/davinci_emac.c   |   11 +++++++++++
 include/linux/davinci_emac.h |    2 ++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 6aec8f5..5372582 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -487,6 +487,9 @@ struct emac_priv {
 	struct mii_bus *mii_bus;
 	struct phy_device *phydev;
 	spinlock_t lock;
+	/*platform specific members*/
+	void (*int_enable) (void);
+	void (*int_disable) (void);
 };
 
 /* clock frequency for EMAC */
@@ -1001,6 +1004,8 @@ static void emac_int_disable(struct emac_priv *priv)
 		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0x0);
 		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0x0);
 		/* NOTE: Rx Threshold and Misc interrupts are not disabled */
+		if (priv->int_disable)
+			priv->int_disable();
 
 		local_irq_restore(flags);
 
@@ -1020,6 +1025,9 @@ static void emac_int_disable(struct emac_priv *priv)
 static void emac_int_enable(struct emac_priv *priv)
 {
 	if (priv->version == EMAC_VERSION_2) {
+		if (priv->int_enable)
+			priv->int_enable();
+
 		emac_ctrl_write(EMAC_DM646X_CMRXINTEN, 0xff);
 		emac_ctrl_write(EMAC_DM646X_CMTXINTEN, 0xff);
 
@@ -2662,6 +2670,9 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->phy_mask = pdata->phy_mask;
 	priv->rmii_en = pdata->rmii_en;
 	priv->version = pdata->version;
+	priv->int_enable = pdata->interrupt_enable;
+	priv->int_disable = pdata->interrupt_disable;
+
 	emac_dev = &ndev->dev;
 	/* Get EMAC platform data */
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
diff --git a/include/linux/davinci_emac.h b/include/linux/davinci_emac.h
index ff55487..6d894ef 100644
--- a/include/linux/davinci_emac.h
+++ b/include/linux/davinci_emac.h
@@ -25,6 +25,8 @@ struct emac_platform_data {
 	u32 mdio_max_freq;
 	u8 rmii_en;
 	u8 version;
+	void (*interrupt_enable) (void);
+	void (*interrupt_disable) (void);
 };
 
 enum {
-- 
1.6.2.4

