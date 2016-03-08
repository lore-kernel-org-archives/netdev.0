From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4vf: Enable interrupts before we register our network devices
Date: Tue,  8 Mar 2016 10:50:17 +0530
Message-ID: <1457414420-5237-2-git-send-email-hariprasad@chelsio.com>
References: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:63062 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753947AbcCHFWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:22:14 -0500
In-Reply-To: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids a race condition where a system that has network devices set up
to be automatically configured and we get the first Port Link Status
message from the firmware on the Asynchronous Firmware Event Queue before
we've enabled interrupts. If that happens, we end up losing the interrupt
and never realizing that the links has actually come up.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |   51 ++++++++++----------
 1 files changed, 26 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 91857b8..fcafe34 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2771,6 +2771,24 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 		}
 	}
 
+	/* See what interrupts we'll be using.  If we've been configured to
+	 * use MSI-X interrupts, try to enable them but fall back to using
+	 * MSI interrupts if we can't enable MSI-X interrupts.  If we can't
+	 * get MSI interrupts we bail with the error.
+	 */
+	if (msi == MSI_MSIX && enable_msix(adapter) == 0)
+		adapter->flags |= USING_MSIX;
+	else {
+		err = pci_enable_msi(pdev);
+		if (err) {
+			dev_err(&pdev->dev, "Unable to allocate %s interrupts;"
+				" err=%d\n",
+				msi == MSI_MSIX ? "MSI-X or MSI" : "MSI", err);
+			goto err_free_dev;
+		}
+		adapter->flags |= USING_MSI;
+	}
+
 	/*
 	 * The "card" is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole "card" but rather proceed
@@ -2793,7 +2811,7 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	}
 	if (adapter->registered_device_map == 0) {
 		dev_err(&pdev->dev, "could not register any net devices\n");
-		goto err_free_dev;
+		goto err_disable_interrupts;
 	}
 
 	/*
@@ -2811,25 +2829,6 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	}
 
 	/*
-	 * See what interrupts we'll be using.  If we've been configured to
-	 * use MSI-X interrupts, try to enable them but fall back to using
-	 * MSI interrupts if we can't enable MSI-X interrupts.  If we can't
-	 * get MSI interrupts we bail with the error.
-	 */
-	if (msi == MSI_MSIX && enable_msix(adapter) == 0)
-		adapter->flags |= USING_MSIX;
-	else {
-		err = pci_enable_msi(pdev);
-		if (err) {
-			dev_err(&pdev->dev, "Unable to allocate %s interrupts;"
-				" err=%d\n",
-				msi == MSI_MSIX ? "MSI-X or MSI" : "MSI", err);
-			goto err_free_debugfs;
-		}
-		adapter->flags |= USING_MSI;
-	}
-
-	/*
 	 * Now that we know how many "ports" we have and what their types are,
 	 * and how many Queue Sets we can support, we can configure our queue
 	 * resources.
@@ -2856,11 +2855,13 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	 * Error recovery and exit code.  Unwind state that's been created
 	 * so far and return the error.
 	 */
-
-err_free_debugfs:
-	if (!IS_ERR_OR_NULL(adapter->debugfs_root)) {
-		cleanup_debugfs(adapter);
-		debugfs_remove_recursive(adapter->debugfs_root);
+err_disable_interrupts:
+	if (adapter->flags & USING_MSIX) {
+		pci_disable_msix(adapter->pdev);
+		adapter->flags &= ~USING_MSIX;
+	} else if (adapter->flags & USING_MSI) {
+		pci_disable_msi(adapter->pdev);
+		adapter->flags &= ~USING_MSI;
 	}
 
 err_free_dev:
-- 
1.7.3
