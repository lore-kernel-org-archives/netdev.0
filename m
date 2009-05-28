From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next] korina: periodically poll the media
Date: Thu, 28 May 2009 12:58:41 +0200
Message-ID: <200905281258.41956.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Felix Fietkau <nbd@openwrt.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:63269 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbZE1K6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 06:58:45 -0400
Received: by ewy24 with SMTP id 24so5272539ewy.37
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 03:58:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the korina driver poll the media
for link change. This is actually required on
Mikrotik RB532 (not RB532A) for korina to
operate properly.

Signed-off-by: Felix Fietkau <nbd@openwrt.org>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index dc23856..b4cf602 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -133,6 +133,7 @@ struct korina_private {
 	int dma_halt_cnt;
 	int dma_run_cnt;
 	struct napi_struct napi;
+	struct timer_list media_check_timer;
 	struct mii_if_info mii_if;
 	struct net_device *dev;
 	int phy_addr;
@@ -664,6 +665,15 @@ static void korina_check_media(struct net_device *dev, unsigned int init_media)
 						&lp->eth_regs->ethmac2);
 }
 
+static void korina_poll_media(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	struct korina_private *lp = netdev_priv(dev);
+
+	korina_check_media(dev, 0);
+	mod_timer(&lp->media_check_timer, jiffies + HZ);
+}
+
 static void korina_set_carrier(struct mii_if_info *mii)
 {
 	if (mii->force_media) {
@@ -1034,6 +1044,7 @@ static int korina_open(struct net_device *dev)
 		    dev->name, lp->und_irq);
 		goto err_free_ovr_irq;
 	}
+	mod_timer(&lp->media_check_timer, jiffies + 1);
 out:
 	return ret;
 
@@ -1053,6 +1064,8 @@ static int korina_close(struct net_device *dev)
 	struct korina_private *lp = netdev_priv(dev);
 	u32 tmp;
 
+	del_timer(&lp->media_check_timer);
+
 	/* Disable interrupts */
 	disable_irq(lp->rx_irq);
 	disable_irq(lp->tx_irq);
@@ -1183,6 +1196,7 @@ static int korina_probe(struct platform_device *pdev)
 			": cannot register net device %d\n", rc);
 		goto probe_err_register;
 	}
+	setup_timer(&lp->media_check_timer, korina_poll_media, (unsigned long) dev);
 out:
 	return rc;
 
