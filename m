From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/4] cxgb4vf: Configure queue based on resource and interrupt type
Date: Tue,  8 Mar 2016 10:50:18 +0530
Message-ID: <1457414420-5237-3-git-send-email-hariprasad@chelsio.com>
References: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:58885 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753956AbcCHFWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 00:22:16 -0500
In-Reply-To: <1457414420-5237-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Queue Set Configuration code was always reserving room for a
Forwarded interrupt Queue even in the cases where we weren't using it.
Figure out how many Ports and Queue Sets we can support. This depends on
knowing our Virtual Function Resources and may be called a second time
if we fall back from MSI-X to MSI Interrupt Mode. This change fixes that
problem.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  165 +++++++++++---------
 1 files changed, 94 insertions(+), 71 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index fcafe34..17a3153 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -2176,6 +2176,73 @@ static void cleanup_debugfs(struct adapter *adapter)
 	/* nothing to do */
 }
 
+/* Figure out how many Ports and Queue Sets we can support.  This depends on
+ * knowing our Virtual Function Resources and may be called a second time if
+ * we fall back from MSI-X to MSI Interrupt Mode.
+ */
+static void size_nports_qsets(struct adapter *adapter)
+{
+	struct vf_resources *vfres = &adapter->params.vfres;
+	unsigned int ethqsets, pmask_nports;
+
+	/* The number of "ports" which we support is equal to the number of
+	 * Virtual Interfaces with which we've been provisioned.
+	 */
+	adapter->params.nports = vfres->nvi;
+	if (adapter->params.nports > MAX_NPORTS) {
+		dev_warn(adapter->pdev_dev, "only using %d of %d maximum"
+			 " allowed virtual interfaces\n", MAX_NPORTS,
+			 adapter->params.nports);
+		adapter->params.nports = MAX_NPORTS;
+	}
+
+	/* We may have been provisioned with more VIs than the number of
+	 * ports we're allowed to access (our Port Access Rights Mask).
+	 * This is obviously a configuration conflict but we don't want to
+	 * crash the kernel or anything silly just because of that.
+	 */
+	pmask_nports = hweight32(adapter->params.vfres.pmask);
+	if (pmask_nports < adapter->params.nports) {
+		dev_warn(adapter->pdev_dev, "only using %d of %d provissioned"
+			 " virtual interfaces; limited by Port Access Rights"
+			 " mask %#x\n", pmask_nports, adapter->params.nports,
+			 adapter->params.vfres.pmask);
+		adapter->params.nports = pmask_nports;
+	}
+
+	/* We need to reserve an Ingress Queue for the Asynchronous Firmware
+	 * Event Queue.  And if we're using MSI Interrupts, we'll also need to
+	 * reserve an Ingress Queue for a Forwarded Interrupts.
+	 *
+	 * The rest of the FL/Intr-capable ingress queues will be matched up
+	 * one-for-one with Ethernet/Control egress queues in order to form
+	 * "Queue Sets" which will be aportioned between the "ports".  For
+	 * each Queue Set, we'll need the ability to allocate two Egress
+	 * Contexts -- one for the Ingress Queue Free List and one for the TX
+	 * Ethernet Queue.
+	 *
+	 * Note that even if we're currently configured to use MSI-X
+	 * Interrupts (module variable msi == MSI_MSIX) we may get downgraded
+	 * to MSI Interrupts if we can't get enough MSI-X Interrupts.  If that
+	 * happens we'll need to adjust things later.
+	 */
+	ethqsets = vfres->niqflint - 1 - (msi == MSI_MSI);
+	if (vfres->nethctrl != ethqsets)
+		ethqsets = min(vfres->nethctrl, ethqsets);
+	if (vfres->neq < ethqsets*2)
+		ethqsets = vfres->neq/2;
+	if (ethqsets > MAX_ETH_QSETS)
+		ethqsets = MAX_ETH_QSETS;
+	adapter->sge.max_ethqsets = ethqsets;
+
+	if (adapter->sge.max_ethqsets < adapter->params.nports) {
+		dev_warn(adapter->pdev_dev, "only using %d of %d available"
+			 " virtual interfaces (too few Queue Sets)\n",
+			 adapter->sge.max_ethqsets, adapter->params.nports);
+		adapter->params.nports = adapter->sge.max_ethqsets;
+	}
+}
+
 /*
  * Perform early "adapter" initialization.  This is where we discover what
  * adapter parameters we're going to be using and initialize basic adapter
@@ -2183,10 +2250,8 @@ static void cleanup_debugfs(struct adapter *adapter)
  */
 static int adap_init0(struct adapter *adapter)
 {
-	struct vf_resources *vfres = &adapter->params.vfres;
 	struct sge_params *sge_params = &adapter->params.sge;
 	struct sge *s = &adapter->sge;
-	unsigned int ethqsets;
 	int err;
 	u32 param, val = 0;
 
@@ -2295,69 +2360,18 @@ static int adap_init0(struct adapter *adapter)
 		return err;
 	}
 
-	/*
-	 * The number of "ports" which we support is equal to the number of
-	 * Virtual Interfaces with which we've been provisioned.
-	 */
-	adapter->params.nports = vfres->nvi;
-	if (adapter->params.nports > MAX_NPORTS) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d allowed"
-			 " virtual interfaces\n", MAX_NPORTS,
-			 adapter->params.nports);
-		adapter->params.nports = MAX_NPORTS;
-	}
-
-	/*
-	 * We need to reserve a number of the ingress queues with Free List
-	 * and Interrupt capabilities for special interrupt purposes (like
-	 * asynchronous firmware messages, or forwarded interrupts if we're
-	 * using MSI).  The rest of the FL/Intr-capable ingress queues will be
-	 * matched up one-for-one with Ethernet/Control egress queues in order
-	 * to form "Queue Sets" which will be aportioned between the "ports".
-	 * For each Queue Set, we'll need the ability to allocate two Egress
-	 * Contexts -- one for the Ingress Queue Free List and one for the TX
-	 * Ethernet Queue.
-	 */
-	ethqsets = vfres->niqflint - INGQ_EXTRAS;
-	if (vfres->nethctrl != ethqsets) {
-		dev_warn(adapter->pdev_dev, "unequal number of [available]"
-			 " ingress/egress queues (%d/%d); using minimum for"
-			 " number of Queue Sets\n", ethqsets, vfres->nethctrl);
-		ethqsets = min(vfres->nethctrl, ethqsets);
-	}
-	if (vfres->neq < ethqsets*2) {
-		dev_warn(adapter->pdev_dev, "Not enough Egress Contexts (%d)"
-			 " to support Queue Sets (%d); reducing allowed Queue"
-			 " Sets\n", vfres->neq, ethqsets);
-		ethqsets = vfres->neq/2;
-	}
-	if (ethqsets > MAX_ETH_QSETS) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d allowed Queue"
-			 " Sets\n", MAX_ETH_QSETS, adapter->sge.max_ethqsets);
-		ethqsets = MAX_ETH_QSETS;
-	}
-	if (vfres->niq != 0 || vfres->neq > ethqsets*2) {
-		dev_warn(adapter->pdev_dev, "unused resources niq/neq (%d/%d)"
-			 " ignored\n", vfres->niq, vfres->neq - ethqsets*2);
-	}
-	adapter->sge.max_ethqsets = ethqsets;
-
-	/*
-	 * Check for various parameter sanity issues.  Most checks simply
-	 * result in us using fewer resources than our provissioning but we
-	 * do need at least  one "port" with which to work ...
-	 */
-	if (adapter->sge.max_ethqsets < adapter->params.nports) {
-		dev_warn(adapter->pdev_dev, "only using %d of %d available"
-			 " virtual interfaces (too few Queue Sets)\n",
-			 adapter->sge.max_ethqsets, adapter->params.nports);
-		adapter->params.nports = adapter->sge.max_ethqsets;
-	}
-	if (adapter->params.nports == 0) {
+	/* Check for various parameter sanity issues */
+	if (adapter->params.vfres.nvi == 0) {
 		dev_err(adapter->pdev_dev, "no virtual interfaces configured/"
 			"usable!\n");
 		return -EINVAL;
 	}
+
+	/* Initialize nports and max_ethqsets now that we have our Virtual
+	 * Function Resources.
+	 */
+	size_nports_qsets(adapter);
+
 	return 0;
 }
 
@@ -2779,16 +2793,32 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	if (msi == MSI_MSIX && enable_msix(adapter) == 0)
 		adapter->flags |= USING_MSIX;
 	else {
+		if (msi == MSI_MSIX) {
+			dev_info(adapter->pdev_dev,
+				 "Unable to use MSI-X Interrupts; falling "
+				 "back to MSI Interrupts\n");
+
+			/* We're going to need a Forwarded Interrupt Queue so
+			 * that may cut into how many Queue Sets we can
+			 * support.
+			 */
+			msi = MSI_MSI;
+			size_nports_qsets(adapter);
+		}
 		err = pci_enable_msi(pdev);
 		if (err) {
-			dev_err(&pdev->dev, "Unable to allocate %s interrupts;"
-				" err=%d\n",
-				msi == MSI_MSIX ? "MSI-X or MSI" : "MSI", err);
+			dev_err(&pdev->dev, "Unable to allocate MSI Interrupts;"
+				" err=%d\n", err);
 			goto err_free_dev;
 		}
 		adapter->flags |= USING_MSI;
 	}
 
+	/* Now that we know how many "ports" we have and what interrupt
+	 * mechanism we're going to use, we can configure our queue resources.
+	 */
+	cfg_queues(adapter);
+
 	/*
 	 * The "card" is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole "card" but rather proceed
@@ -2829,13 +2859,6 @@ static int cxgb4vf_pci_probe(struct pci_dev *pdev,
 	}
 
 	/*
-	 * Now that we know how many "ports" we have and what their types are,
-	 * and how many Queue Sets we can support, we can configure our queue
-	 * resources.
-	 */
-	cfg_queues(adapter);
-
-	/*
 	 * Print a short notice on the existence and configuration of the new
 	 * VF network device ...
 	 */
-- 
1.7.3
