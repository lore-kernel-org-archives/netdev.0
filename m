From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 3/4] save/restore device configuration space
Date: Sun, 18 May 2008 15:03:44 +0200
Message-ID: <20080518130344.GC21417@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:39379 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756011AbYERNER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 09:04:17 -0400
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>

The memory mapped device configuration space is lost during hibernate.
Save and restore it (fixes 'swapped mac' problem).

Signed-off-by: TTobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:53:06.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:53:10.000000000 +0200
@@ -426,6 +426,7 @@
 #define NV_PCI_REGSZ_VER1      	0x270
 #define NV_PCI_REGSZ_VER2      	0x2d4
 #define NV_PCI_REGSZ_VER3      	0x604
+#define NV_PCI_REGSZ_MAX       	0x604
 
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -784,6 +785,9 @@
 
 	/* flow control */
 	u32 pause_flags;
+
+	/* power saved state */
+	u32 saved_config_space[NV_PCI_REGSZ_MAX/4];
 };
 
 /*
@@ -5785,6 +5789,8 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	int i;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5794,6 +5800,10 @@
 	// Gross.
 	nv_close(dev);
 
+	/* save non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		np->saved_config_space[i] = readl(base + i*sizeof(u32));
+
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -5804,9 +5814,9 @@
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int rc = 0;
-	u32 txreg;
+	int i, rc = 0;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5817,10 +5827,9 @@
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	/* restore mac address reverse flag */
-	txreg = readl(base + NvRegTransmitPoll);
-	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
-	writel(txreg, base + NvRegTransmitPoll);
+	/* restore non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
 	rc = nv_open(dev);
 	nv_set_multicast(dev);
