From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] alx: add a simple AR816x/AR817x device driver
Date: Sun, 16 Jun 2013 21:41:52 +0200
Message-ID: <1371411712.8365.2.camel@jlt4.sipsolutions.net>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1371069202-21576-1-git-send-email-johannes@sipsolutions.net>
	 <20130613222411.GA5396@sig21.net>
	 <1371162553.8335.28.camel@jlt4.sipsolutions.net>
	 <20130614055346.GB6547@sig21.net>
	 <1371320772.8319.2.camel@jlt4.sipsolutions.net>
	 <1371327319.14174.1.camel@jlt4.sipsolutions.net>
	 <20130616094930.GA5899@sig21.net>
	 <1371381472.8546.1.camel@jlt4.sipsolutions.net>
	 <20130616174834.GA5236@sig21.net> <20130616184220.GA5469@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:59932 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755418Ab3FPTl4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 15:41:56 -0400
In-Reply-To: <20130616184220.GA5469@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> --- ./drivers/net/ethernet/atheros/alx/main.c.orig	2013-06-16 11:13:30.763491166 +0200
> +++ ./drivers/net/ethernet/atheros/alx/main.c	2013-06-16 20:34:24.351045235 +0200
> @@ -722,6 +722,7 @@ static int alx_init_sw(struct alx_priv *
>  		      ALX_MAC_CTRL_TXFC_EN |
>  		      7 << ALX_MAC_CTRL_PRMBLEN_SHIFT;
>  
> +	pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;

Heh, ok.

> The compat-wireless-3.6.8-1-snpc driver applied this
> flag for AR8161 and AR8162 if I got it correctly.

I can't download that any more it seems.

I think it should be like this then:

diff --git a/drivers/net/ethernet/atheros/alx/alx.h b/drivers/net/ethernet/atheros/alx/alx.h
index e367eb2..50b3ae2 100644
--- a/drivers/net/ethernet/atheros/alx/alx.h
+++ b/drivers/net/ethernet/atheros/alx/alx.h
@@ -72,6 +72,10 @@ struct alx_tx_queue {
 
 #define ALX_DEFAULT_TX_WORK 128
 
+enum alx_device_quirks {
+	ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG = BIT(0),
+};
+
 struct alx_priv {
 	struct net_device *dev;
 
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 3476e38..418de8b 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1322,6 +1322,9 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->irq = pdev->irq;
 	netdev->watchdog_timeo = ALX_WATCHDOG_TIME;
 
+	if (ent->driver_data & ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG)
+		pdev->dev_flags |= PCI_DEV_FLAGS_MSI_INTX_DISABLE_BUG;
+
 	err = alx_init_sw(alx);
 	if (err) {
 		dev_err(&pdev->dev, "net device private data init failed\n");
@@ -1592,9 +1595,12 @@ static SIMPLE_DEV_PM_OPS(alx_pm_ops, alx_suspend, alx_resume);
 #endif
 
 static DEFINE_PCI_DEVICE_TABLE(alx_pci_tbl) = {
-	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8161) },
-	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2200) },
-	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162) },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8161),
+	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_E2200),
+	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
+	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8162),
+	  .driver_data = ALX_DEV_QUIRK_MSI_INTX_DISABLE_BUG },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8171) },
 	{ PCI_VDEVICE(ATTANSIC, ALX_DEV_ID_AR8172) },
 	{}


Can you try that? Full driver patch here:
http://p.sipsolutions.net/f8e6f95ff0894d89.txt

johannes
