From: Yinghai Lu <yhlu.kernel@gmail.com>
Subject: [PATCH] net: forcedeth call restore mac addr in nv_shutdown patch
Date: Sat, 16 Aug 2008 20:30:04 -0700
Message-ID: <1218943804-6198-1-git-send-email-yhlu.kernel@gmail.com>
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Yinghai Lu <yhlu.kernel@gmail.com>
To: Jeff Garzik <jgarzik@redhat.com>, Ingo Molnar <mingo@elte.hu>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:24679 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546AbYHQDaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Aug 2008 23:30:55 -0400
Received: by wa-out-1112.google.com with SMTP id j37so968616waf.23
        for <netdev@vger.kernel.org>; Sat, 16 Aug 2008 20:30:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

after

| commit f735a2a1a4f2a0f5cd823ce323e82675990469e2
| Author: Tobias Diedrich <ranma+kernel@tdiedrich.de>
| Date:   Sun May 18 15:02:37 2008 +0200
|
|    [netdrvr] forcedeth: setup wake-on-lan before shutting down
|
|    When hibernating in 'shutdown' mode, after saving the image the suspend hook
|    is not called again.
|    However, if the device is in promiscous mode, wake-on-lan will not work.
|    This adds a shutdown hook to setup wake-on-lan before the final shutdown.
|
|    Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>
|    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

my servers with nvidia ck804 and mcp55 will reverse mac address with kexec.

it turns out need to restore mac addr in nv_shutdown.

Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>

---
 drivers/net/forcedeth.c |   17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

Index: linux-2.6/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.orig/drivers/net/forcedeth.c
+++ linux-2.6/drivers/net/forcedeth.c
@@ -5643,6 +5643,7 @@ static int __devinit nv_probe(struct pci
 		dev->dev_addr[4] = (np->orig_mac[0] >>  8) & 0xff;
 		dev->dev_addr[5] = (np->orig_mac[0] >>  0) & 0xff;
 		writel(txreg|NVREG_TRANSMITPOLL_MAC_ADDR_REV, base + NvRegTransmitPoll);
+		printk(KERN_DEBUG "nv_probe: set workarund bit for reversed mac addr\n");
 	}
 	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
@@ -5890,14 +5891,12 @@ static void nv_restore_phy(struct net_de
 	}
 }
 
-static void __devexit nv_remove(struct pci_dev *pci_dev)
+static void nv_restore_mac_addr(struct pci_dev *pci_dev)
 {
 	struct net_device *dev = pci_get_drvdata(pci_dev);
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
 
-	unregister_netdev(dev);
-
 	/* special op: write back the misordered MAC address - otherwise
 	 * the next nv_probe would see a wrong address.
 	 */
@@ -5905,6 +5904,15 @@ static void __devexit nv_remove(struct p
 	writel(np->orig_mac[1], base + NvRegMacAddrB);
 	writel(readl(base + NvRegTransmitPoll) & ~NVREG_TRANSMITPOLL_MAC_ADDR_REV,
 	       base + NvRegTransmitPoll);
+}
+
+static void __devexit nv_remove(struct pci_dev *pci_dev)
+{
+	struct net_device *dev = pci_get_drvdata(pci_dev);
+
+	unregister_netdev(dev);
+
+	nv_restore_mac_addr(pci_dev);
 
 	/* restore any phy related changes */
 	nv_restore_phy(dev);
@@ -5970,11 +5978,12 @@ static int nv_resume(struct pci_dev *pde
 static void nv_shutdown(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct fe_priv *np = netdev_priv(dev);
 
 	if (netif_running(dev))
 		nv_close(dev);
 
+	nv_restore_mac_addr(pdev);
+
 	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
 	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
 	pci_disable_device(pdev);
