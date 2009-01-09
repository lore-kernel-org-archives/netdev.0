From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 28/45] tms380tr: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:25 -0800
Message-ID: <20090109230138.780019807@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42223 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754259AbZAIXR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:58 -0500
Content-Disposition: inline; filename=tr-tms.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Conver this related group of drivers to new API

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/tokenring/abyss.c    |    9 +++++++--
 drivers/net/tokenring/tms380tr.c |   21 ++++++++++++---------
 drivers/net/tokenring/tms380tr.h |    1 +
 drivers/net/tokenring/tmspci.c   |    4 ++--
 4 files changed, 22 insertions(+), 13 deletions(-)

--- a/drivers/net/tokenring/tms380tr.c	2009-01-05 16:15:58.973576676 -0800
+++ b/drivers/net/tokenring/tms380tr.c	2009-01-05 16:16:16.242321317 -0800
@@ -2330,6 +2330,17 @@ void tmsdev_term(struct net_device *dev)
 		DMA_BIDIRECTIONAL);
 }
 
+const struct net_device_ops tms380tr_netdev_ops = {
+	.ndo_open		= tms380tr_open,
+	.ndo_stop		= tms380tr_close,
+	.ndo_start_xmit		= tms380tr_send_packet,
+	.ndo_tx_timeout		= tms380tr_timeout,
+	.ndo_get_stats		= tms380tr_get_stats,
+	.ndo_set_multicast_list = tms380tr_set_multicast_list,
+	.ndo_set_mac_address	= tms380tr_set_mac_address,
+};
+EXPORT_SYMBOL(tms380tr_netdev_ops);
+
 int tmsdev_init(struct net_device *dev, struct device *pdev)
 {
 	struct net_local *tms_local;
@@ -2353,16 +2364,8 @@ int tmsdev_init(struct net_device *dev, 
 		return -ENOMEM;
 	}
 	
-	/* These can be overridden by the card driver if needed */
-	dev->open		= tms380tr_open;
-	dev->stop		= tms380tr_close;
-	dev->do_ioctl		= NULL; 
-	dev->hard_start_xmit	= tms380tr_send_packet;
-	dev->tx_timeout		= tms380tr_timeout;
+	dev->netdev_ops		= &tms380tr_netdev_ops;
 	dev->watchdog_timeo	= HZ;
-	dev->get_stats		= tms380tr_get_stats;
-	dev->set_multicast_list = &tms380tr_set_multicast_list;
-	dev->set_mac_address	= tms380tr_set_mac_address;
 
 	return 0;
 }
--- a/drivers/net/tokenring/abyss.c	2009-01-05 16:15:58.957573984 -0800
+++ b/drivers/net/tokenring/abyss.c	2009-01-05 16:24:48.186569023 -0800
@@ -92,6 +92,8 @@ static void abyss_sifwritew(struct net_d
 	outw(val, dev->base_addr + reg);
 }
 
+static struct net_device_ops abyss_netdev_ops;
+
 static int __devinit abyss_attach(struct pci_dev *pdev, const struct pci_device_id *ent)
 {	
 	static int versionprinted;
@@ -157,8 +159,7 @@ static int __devinit abyss_attach(struct
 
 	memcpy(tp->ProductID, "Madge PCI 16/4 Mk2", PROD_ID_SIZE + 1);
 		
-	dev->open = abyss_open;
-	dev->stop = abyss_close;
+	dev->netdev_ops = &abyss_netdev_ops;
 
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
@@ -450,6 +451,11 @@ static struct pci_driver abyss_driver = 
 
 static int __init abyss_init (void)
 {
+	abyss_netdev_ops = tms380tr_netdev_ops;
+
+	abyss_netdev_ops.ndo_open = abyss_open;
+	abyss_netdev_ops.ndo_stop = abyss_close;
+
 	return pci_register_driver(&abyss_driver);
 }
 
--- a/drivers/net/tokenring/tmspci.c	2009-01-05 16:15:58.939320188 -0800
+++ b/drivers/net/tokenring/tmspci.c	2009-01-05 16:16:16.242321317 -0800
@@ -157,8 +157,8 @@ static int __devinit tms_pci_attach(stru
 
 	tp->tmspriv = cardinfo;
 
-	dev->open = tms380tr_open;
-	dev->stop = tms380tr_close;
+	dev->netdev_ops = &tms380tr_netdev_ops;
+
 	pci_set_drvdata(pdev, dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
--- a/drivers/net/tokenring/tms380tr.h	2009-01-05 16:15:58.949569988 -0800
+++ b/drivers/net/tokenring/tms380tr.h	2009-01-05 16:16:16.242321317 -0800
@@ -14,6 +14,7 @@
 #include <linux/interrupt.h>
 
 /* module prototypes */
+extern const struct net_device_ops tms380tr_netdev_ops;
 int tms380tr_open(struct net_device *dev);
 int tms380tr_close(struct net_device *dev);
 irqreturn_t tms380tr_interrupt(int irq, void *dev_id);


