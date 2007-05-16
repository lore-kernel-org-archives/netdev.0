From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: Fix msi enable leak on error, don't print error message,
	cleanup
Date: Wed, 16 May 2007 01:31:20 -0700
Message-ID: <20070516083120.23311.3272.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	hpa@zytor.com, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49001 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756701AbXEPP2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 May 2007 11:28:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pci_enable_msi failure is a normal event so we should not print any error.
Going over the code I spotted a missing pci_disable_msi() leak when irq
allocation fails. The whole code also needed a cleanup, so I combined the
two different calls to pci_request_irq into a single call making this
look a lot better.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Cc: H. Peter Anvin <hpa@zytor.com>
---

 drivers/net/e1000/e1000_main.c |   32 +++++++++++++++-----------------
 1 files changed, 15 insertions(+), 17 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 637ae8f..b2c5b8e 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -300,31 +300,29 @@ module_exit(e1000_exit_module);
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int flags, err = 0;
+	void (*handler) = &e1000_intr;
+	int irq_flags = IRQF_SHARED;
+	int err;
 
-	flags = IRQF_SHARED;
 #ifdef CONFIG_PCI_MSI
 	if (adapter->hw.mac_type >= e1000_82571) {
-		adapter->have_msi = TRUE;
-		if ((err = pci_enable_msi(adapter->pdev))) {
-			DPRINTK(PROBE, ERR,
-			 "Unable to allocate MSI interrupt Error: %d\n", err);
-			adapter->have_msi = FALSE;
+		adapter->have_msi = !pci_enable_msi(adapter->pdev);
+		if (adapter->have_msi) {
+			handler = &e1000_intr_msi;
+			irq_flags = 0;
 		}
 	}
-	if (adapter->have_msi) {
-		flags &= ~IRQF_SHARED;
-		err = request_irq(adapter->pdev->irq, &e1000_intr_msi, flags,
-		                  netdev->name, netdev);
-		if (err)
-			DPRINTK(PROBE, ERR,
-			       "Unable to allocate interrupt Error: %d\n", err);
-	} else
 #endif
-	if ((err = request_irq(adapter->pdev->irq, &e1000_intr, flags,
-	                       netdev->name, netdev)))
+	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
+	                  netdev);
+	if (err) {
+#ifdef CONFIG_PCI_MSI
+		if (adapter->have_msi)
+			pci_disable_msi(adapter->pdev);
+#endif
 		DPRINTK(PROBE, ERR,
 		        "Unable to allocate interrupt Error: %d\n", err);
+	}
 
 	return err;
 }
