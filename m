From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: [PATCH] 8139cp: Catch all interrupts
Date: Thu, 01 Sep 2005 22:16:58 +0200
Message-ID: <431761BA.5080007@drzeus.cx>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_hermes.drzeus.cx-5029-1125605817-0001-2"
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030363AbVIAURB@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Felipe Damasio <felipewd@terra.com.br>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_hermes.drzeus.cx-5029-1125605817-0001-2
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit

Register interrupt handler when net device is registered. Avoids missing
interrupts if the interrupt mask gets out of sync.

Signed-off-by: Pierre Ossman <drzeus@drzeus.cx>

---

The reason this patch is needed for me is that the resume function is
broken. It enables interrupts unconditionally, but the interrupt handler
is only registered when the device is up.

I don't have enough knowledge about the driver to fix the resume
function so this patch will instead make sure that the interrupt handler
is registered at all times (which can be a nice safeguard even when the
resume function gets fixed).

--=_hermes.drzeus.cx-5029-1125605817-0001-2
Content-Type: text/x-patch; name="8139cp-catch-irq.patch"; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8139cp-catch-irq.patch"

Index: linux-wbsd/drivers/net/8139cp.c
===================================================================
--- linux-wbsd/drivers/net/8139cp.c	(revision 165)
+++ linux-wbsd/drivers/net/8139cp.c	(working copy)
@@ -1204,20 +1204,11 @@
 
 	cp_init_hw(cp);
 
-	rc = request_irq(dev->irq, cp_interrupt, SA_SHIRQ, dev->name, dev);
-	if (rc)
-		goto err_out_hw;
-
 	netif_carrier_off(dev);
 	mii_check_media(&cp->mii_if, netif_msg_link(cp), TRUE);
 	netif_start_queue(dev);
 
 	return 0;
-
-err_out_hw:
-	cp_stop_hw(cp);
-	cp_free_rings(cp);
-	return rc;
 }
 
 static int cp_close (struct net_device *dev)
@@ -1238,7 +1229,6 @@
 	spin_unlock_irqrestore(&cp->lock, flags);
 
 	synchronize_irq(dev->irq);
-	free_irq(dev->irq, dev);
 
 	cp_free_rings(cp);
 	return 0;
@@ -1813,6 +1803,10 @@
 	if (rc)
 		goto err_out_iomap;
 
+	rc = request_irq(dev->irq, cp_interrupt, SA_SHIRQ, dev->name, dev);
+	if (rc)
+		goto err_out_unreg;
+
 	printk (KERN_INFO "%s: RTL-8139C+ at 0x%lx, "
 		"%02x:%02x:%02x:%02x:%02x:%02x, "
 		"IRQ %d\n",
@@ -1832,6 +1826,8 @@
 
 	return 0;
 
+err_out_unreg:
+	unregister_netdev(dev);
 err_out_iomap:
 	iounmap(regs);
 err_out_res:
@@ -1852,6 +1848,7 @@
 
 	if (!dev)
 		BUG();
+	free_irq(dev->irq, dev);
 	unregister_netdev(dev);
 	iounmap(cp->regs);
 	if (cp->wol_enabled) pci_set_power_state (pdev, PCI_D0);

--=_hermes.drzeus.cx-5029-1125605817-0001-2--
