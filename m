From: Bryan Wu <bryan.wu@analog.com>
Subject: [PATCH 2/8] [Blackfin] EMAC driver: define MDC_CLK=2.5MHz and caculate mdc_div according to SCLK.
Date: Wed, 30 Jan 2008 16:52:22 +0800
Message-ID: <1201683148-23931-3-git-send-email-bryan.wu@analog.com>
References: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Cc: linux-kernel@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:51389 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753312AbYA3Iwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 03:52:36 -0500
In-Reply-To: <1201683148-23931-1-git-send-email-bryan.wu@analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Bryan Wu <bryan.wu@analog.com>
---
 drivers/net/bfin_mac.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index 4006a5d..ee39819 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -412,20 +412,26 @@ static void bf537_adjust_link(struct net_device *dev)
 	spin_unlock_irqrestore(&lp->lock, flags);
 }
 
+/* MDC  = 2.5 MHz */
+#define MDC_CLK 2500000
+
 static int mii_probe(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 	unsigned short sysctl;
 	int i;
+	u32 sclk, mdc_div;
 
 	/* Enable PHY output early */
 	if (!(bfin_read_VR_CTL() & PHYCLKOE))
 		bfin_write_VR_CTL(bfin_read_VR_CTL() | PHYCLKOE);
 
-	/* MDC  = 2.5 MHz */
+	sclk = get_sclk();
+	mdc_div = ((sclk / MDC_CLK) / 2) - 1;
+
 	sysctl = bfin_read_EMAC_SYSCTL();
-	sysctl |= SET_MDCDIV(24);
+	sysctl |= SET_MDCDIV(mdc_div);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
 	/* search for connect PHY device */
@@ -477,8 +483,10 @@ static int mii_probe(struct net_device *dev)
 	lp->phydev = phydev;
 
 	printk(KERN_INFO "%s: attached PHY driver [%s] "
-	       "(mii_bus:phy_addr=%s, irq=%d)\n",
-	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq);
+	       "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)"
+	       "@sclk=%dMHz)\n",
+	       DRV_NAME, phydev->drv->name, phydev->dev.bus_id, phydev->irq,
+	       MDC_CLK, mdc_div, sclk/1000000);
 
 	return 0;
 }
-- 
1.5.3.4
