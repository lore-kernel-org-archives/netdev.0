From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/4][TG3]: Fix race condition when calling
 register_netdev().
Date: Fri, 15 Dec 2006 22:48:43 -0800
Message-ID: <1166251723.30429.10.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2775 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030609AbWLPF7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 00:59:17 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Fix race condition when calling register_netdev().

Hot-plug scripts can call tg3_open() as soon as register_netdev() is
called in tg3_init_one().  We need to call pci_set_drvdata() before
register_netdev(), and netif_carrier_off() needs to be moved to
tg3_open() to avoid race conditions.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d01538e..6804489 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6988,6 +6988,8 @@ static int tg3_open(struct net_device *d
 	struct tg3 *tp = netdev_priv(dev);
 	int err;
 
+	netif_carrier_off(tp->dev);
+
 	tg3_full_lock(tp, 0);
 
 	err = tg3_set_power_state(tp, PCI_D0);
@@ -11927,6 +11929,8 @@ static int __devinit tg3_init_one(struct
 	 */
 	pci_save_state(tp->pdev);
 
+	pci_set_drvdata(pdev, dev);
+
 	err = register_netdev(dev);
 	if (err) {
 		printk(KERN_ERR PFX "Cannot register net device, "
@@ -11934,8 +11938,6 @@ static int __devinit tg3_init_one(struct
 		goto err_out_iounmap;
 	}
 
-	pci_set_drvdata(pdev, dev);
-
 	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (%s) %s Ethernet ",
 	       dev->name,
 	       tp->board_part_number,
@@ -11966,8 +11968,6 @@ static int __devinit tg3_init_one(struct
 	       (pdev->dma_mask == DMA_32BIT_MASK) ? 32 :
 	        (((u64) pdev->dma_mask == DMA_40BIT_MASK) ? 40 : 64));
 
-	netif_carrier_off(tp->dev);
-
 	return 0;
 
 err_out_iounmap:


