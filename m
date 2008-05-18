From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 4/4] reorder suspend/resume code
Date: Sun, 18 May 2008 15:04:29 +0200
Message-ID: <20080518130429.GD21417@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:39383 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757255AbYERNFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 09:05:01 -0400
Content-Disposition: inline
In-Reply-To: <20080518125715.GA19229@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Match the suspend/resume code ordering in e100/e1000e more closely.
For example the configuration space should be saved on suspend even for
devices that are not up.

Signed-off-by: Tobias Diedrich <ranma+kernel@tdiedrich.de>

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:53:10.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:54:04.000000000 +0200
@@ -5792,22 +5792,20 @@
 	u8 __iomem *base = get_hwbase(dev);
 	int i;
 
-	if (!netif_running(dev))
-		goto out;
-
+	if (netif_running(dev)) {
+		// Gross.
+		nv_close(dev);
+	}
 	netif_device_detach(dev);
 
-	// Gross.
-	nv_close(dev);
-
 	/* save non-pci configuration space */
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		np->saved_config_space[i] = readl(base + i*sizeof(u32));
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
 	return 0;
 }
 
@@ -5818,22 +5816,20 @@
 	u8 __iomem *base = get_hwbase(dev);
 	int i, rc = 0;
 
-	if (!netif_running(dev))
-		goto out;
-
-	netif_device_attach(dev);
-
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/* ack any pending wake events, disable PME */
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* restore non-pci configuration space */
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
-	rc = nv_open(dev);
-	nv_set_multicast(dev);
-out:
+	netif_device_attach(dev);
+	if (netif_running(dev)) {
+		rc = nv_open(dev);
+		nv_set_multicast(dev);
+	}
 	return rc;
 }
 
