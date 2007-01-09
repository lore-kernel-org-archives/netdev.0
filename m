From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/3] myri10ge: check that we can get an irq
Date: Tue, 09 Jan 2007 21:05:04 +0100
Message-ID: <45A3F570.5060901@myri.com>
References: <45A3F4FF.5000803@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-64-172-73-26.dsl.lsan03.pacbell.net ([64.172.73.26]:1798
	"EHLO myri.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932418AbXAIUa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:30:27 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45A3F4FF.5000803@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that IRQ allocation is done in myri10ge_open(), we want to still
check when loading the driver that IRQ allocation could succeed later.

Additionaly, we fix the initialization and printing of netdev->irq.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-01-09 19:30:00.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-01-09 19:30:41.000000000 +0100
@@ -2882,7 +2882,6 @@
 	netdev->hard_start_xmit = myri10ge_xmit;
 	netdev->get_stats = myri10ge_get_stats;
 	netdev->base_addr = mgp->iomem_base;
-	netdev->irq = pdev->irq;
 	netdev->change_mtu = myri10ge_change_mtu;
 	netdev->set_multicast_list = myri10ge_set_multicast_list;
 	netdev->set_mac_address = myri10ge_set_mac_address;
@@ -2892,6 +2891,15 @@
 	netdev->poll = myri10ge_poll;
 	netdev->weight = myri10ge_napi_weight;
 
+	/* make sure we can get an irq, and that MSI can be
+	 * setup (if available).  Also ensure netdev->irq
+	 * is set to correct value if MSI is enabled */
+	status = myri10ge_request_irq(mgp);
+	if (status != 0)
+		goto abort_with_firmware;
+	netdev->irq = pdev->irq;
+	myri10ge_free_irq(mgp);
+
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
 	pci_save_state(pdev);
@@ -2907,8 +2915,9 @@
 		dev_err(&pdev->dev, "register_netdev failed: %d\n", status);
 		goto abort_with_state;
 	}
-	dev_info(dev, "%d, tx bndry %d, fw %s, WC %s\n",
-		 pdev->irq, mgp->tx.boundary, mgp->fw_name,
+	dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+		 (mgp->msi_enabled ? "MSI" : "xPIC"),
+		 netdev->irq, mgp->tx.boundary, mgp->fw_name,
 		 (mgp->mtrr >= 0 ? "Enabled" : "Disabled"));
 
 	return 0;


