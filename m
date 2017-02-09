From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/12] nfp: allocate irqs in lower driver
Date: Thu,  9 Feb 2017 09:17:37 -0800
Message-ID: <20170209171738.17386-12-jakub.kicinski@netronome.com>
References: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34815 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdBIRb0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 12:31:26 -0500
Received: by mail-pg0-f41.google.com with SMTP id 14so2338919pgg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 09:29:57 -0800 (PST)
In-Reply-To: <20170209171738.17386-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PF services multiple ports using single PCI device therefore
IRQs can no longer be allocated in the netdev code.  Lower
portion of the driver has to allocate the IRQs and hand them
out to ports.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  17 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 144 +++++++++++----------
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  78 +++++++----
 3 files changed, 140 insertions(+), 99 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 60c9aa80bbd1..ef031010ae09 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -83,6 +83,7 @@
 #define NFP_NET_NON_Q_VECTORS		2
 #define NFP_NET_IRQ_LSC_IDX		0
 #define NFP_NET_IRQ_EXN_IDX		1
+#define NFP_NET_MIN_PORT_IRQS		(NFP_NET_NON_Q_VECTORS + 1)
 
 /* Queue/Ring definitions */
 #define NFP_NET_MAX_TX_RINGS	64	/* Max. # of Tx rings per device */
@@ -345,7 +346,7 @@ struct nfp_net_rx_ring {
  * @tx_ring:        Pointer to TX ring
  * @rx_ring:        Pointer to RX ring
  * @xdp_ring:	    Pointer to an extra TX ring for XDP
- * @irq_idx:        Index into MSI-X table
+ * @irq_entry:      MSI-X table entry (use for talking to the device)
  * @rx_sync:	    Seqlock for atomic updates of RX stats
  * @rx_pkts:        Number of received packets
  * @rx_bytes:	    Number of received bytes
@@ -362,6 +363,7 @@ struct nfp_net_rx_ring {
  * @tx_lso:	    Counter of LSO packets sent
  * @tx_errors:	    How many TX errors were encountered
  * @tx_busy:        How often was TX busy (no space)?
+ * @irq_vector:     Interrupt vector number (use for talking to the OS)
  * @handler:        Interrupt handler for this ring vector
  * @name:           Name of the interrupt vector
  * @affinity_mask:  SMP affinity mask for this vector
@@ -378,7 +380,7 @@ struct nfp_net_r_vector {
 	struct nfp_net_tx_ring *tx_ring;
 	struct nfp_net_rx_ring *rx_ring;
 
-	int irq_idx;
+	u16 irq_entry;
 
 	struct u64_stats_sync rx_sync;
 	u64 rx_pkts;
@@ -400,6 +402,7 @@ struct nfp_net_r_vector {
 	u64 tx_errors;
 	u64 tx_busy;
 
+	u32 irq_vector;
 	irq_handler_t handler;
 	char name[IFNAMSIZ + 8];
 	cpumask_t affinity_mask;
@@ -788,8 +791,14 @@ int nfp_net_reconfig(struct nfp_net *nn, u32 update);
 void nfp_net_rss_write_itbl(struct nfp_net *nn);
 void nfp_net_rss_write_key(struct nfp_net *nn);
 void nfp_net_coalesce_write_cfg(struct nfp_net *nn);
-int nfp_net_irqs_alloc(struct nfp_net *nn);
-void nfp_net_irqs_disable(struct nfp_net *nn);
+
+unsigned int
+nfp_net_irqs_alloc(struct pci_dev *pdev, struct msix_entry *irq_entries,
+		   unsigned int min_irqs, unsigned int want_irqs);
+void nfp_net_irqs_disable(struct pci_dev *pdev);
+void
+nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
+		    unsigned int n);
 int
 nfp_net_ring_reconfig(struct nfp_net *nn, struct bpf_prog **xdp_prog,
 		      struct nfp_net_ring_set *rx, struct nfp_net_ring_set *tx);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 6ac43abf561b..074259cc8e06 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2015 Netronome Systems, Inc.
+ * Copyright (C) 2015-2017 Netronome Systems, Inc.
  *
  * This software is dual licensed under the GNU General License Version 2,
  * June 1991 as shown in the file COPYING in the top-level directory of this
@@ -281,72 +281,76 @@ static void nfp_net_irq_unmask(struct nfp_net *nn, unsigned int entry_nr)
 }
 
 /**
- * nfp_net_msix_alloc() - Try to allocate MSI-X irqs
- * @nn:       NFP Network structure
- * @nr_vecs:  Number of MSI-X vectors to allocate
- *
- * For MSI-X we want at least NFP_NET_NON_Q_VECTORS + 1 vectors.
+ * nfp_net_irqs_alloc() - allocates MSI-X irqs
+ * @pdev:        PCI device structure
+ * @irq_entries: Array to be initialized and used to hold the irq entries
+ * @min_irqs:    Minimal acceptable number of interrupts
+ * @wanted_irqs: Target number of interrupts to allocate
  *
- * Return: Number of MSI-X vectors obtained or 0 on error.
+ * Return: Number of irqs obtained or 0 on error.
  */
-static int nfp_net_msix_alloc(struct nfp_net *nn, int nr_vecs)
+unsigned int
+nfp_net_irqs_alloc(struct pci_dev *pdev, struct msix_entry *irq_entries,
+		   unsigned int min_irqs, unsigned int wanted_irqs)
 {
-	struct pci_dev *pdev = nn->pdev;
-	int nvecs;
-	int i;
+	unsigned int i;
+	int got_irqs;
 
-	for (i = 0; i < nr_vecs; i++)
-		nn->irq_entries[i].entry = i;
+	for (i = 0; i < wanted_irqs; i++)
+		irq_entries[i].entry = i;
 
-	nvecs = pci_enable_msix_range(pdev, nn->irq_entries,
-				      NFP_NET_NON_Q_VECTORS + 1, nr_vecs);
-	if (nvecs < 0) {
-		nn_warn(nn, "Failed to enable MSI-X. Wanted %d-%d (err=%d)\n",
-			NFP_NET_NON_Q_VECTORS + 1, nr_vecs, nvecs);
+	got_irqs = pci_enable_msix_range(pdev, irq_entries,
+					 min_irqs, wanted_irqs);
+	if (got_irqs < 0) {
+		dev_err(&pdev->dev, "Failed to enable %d-%d MSI-X (err=%d)\n",
+			min_irqs, wanted_irqs, got_irqs);
 		return 0;
 	}
 
-	return nvecs;
+	if (got_irqs < wanted_irqs)
+		dev_warn(&pdev->dev, "Unable to allocate %d IRQs got only %d\n",
+			 wanted_irqs, got_irqs);
+
+	return got_irqs;
 }
 
 /**
- * nfp_net_irqs_alloc() - allocates MSI-X irqs
- * @nn:       NFP Network structure
+ * nfp_net_irqs_assign() - Assign interrupts allocated externally to netdev
+ * @nn:		 NFP Network structure
+ * @irq_entries: Table of allocated interrupts
+ * @n:		 Size of @irq_entries (number of entries to grab)
  *
- * Return: Number of irqs obtained or 0 on error.
+ * After interrupts are allocated with nfp_net_irqs_alloc() this function
+ * should be called to assign them to a specific netdev (port).
  */
-int nfp_net_irqs_alloc(struct nfp_net *nn)
+void
+nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
+		    unsigned int n)
 {
-	int wanted_irqs;
-	unsigned int n;
-
-	wanted_irqs = nn->num_r_vecs + NFP_NET_NON_Q_VECTORS;
-
-	n = nfp_net_msix_alloc(nn, wanted_irqs);
-	if (n == 0) {
-		nn_err(nn, "Failed to allocate MSI-X IRQs\n");
-		return 0;
-	}
-
 	nn->max_r_vecs = n - NFP_NET_NON_Q_VECTORS;
 	nn->num_r_vecs = nn->max_r_vecs;
 
-	if (n < wanted_irqs)
-		nn_warn(nn, "Unable to allocate %d vectors. Got %d instead\n",
-			wanted_irqs, n);
+	memcpy(nn->irq_entries, irq_entries, sizeof(*irq_entries) * n);
 
-	return n;
+	if (nn->num_rx_rings > nn->num_r_vecs ||
+	    nn->num_tx_rings > nn->num_r_vecs)
+		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
+			nn->num_rx_rings, nn->num_tx_rings, nn->num_r_vecs);
+
+	nn->num_rx_rings = min(nn->num_r_vecs, nn->num_rx_rings);
+	nn->num_tx_rings = min(nn->num_r_vecs, nn->num_tx_rings);
+	nn->num_stack_tx_rings = nn->num_tx_rings;
 }
 
 /**
  * nfp_net_irqs_disable() - Disable interrupts
- * @nn:       NFP Network structure
+ * @pdev:        PCI device structure
  *
  * Undoes what @nfp_net_irqs_alloc() does.
  */
-void nfp_net_irqs_disable(struct nfp_net *nn)
+void nfp_net_irqs_disable(struct pci_dev *pdev)
 {
-	pci_disable_msix(nn->pdev);
+	pci_disable_msix(pdev);
 }
 
 /**
@@ -410,10 +414,13 @@ static void nfp_net_read_link_status(struct nfp_net *nn)
 static irqreturn_t nfp_net_irq_lsc(int irq, void *data)
 {
 	struct nfp_net *nn = data;
+	struct msix_entry *entry;
+
+	entry = &nn->irq_entries[NFP_NET_IRQ_LSC_IDX];
 
 	nfp_net_read_link_status(nn);
 
-	nfp_net_irq_unmask(nn, NFP_NET_IRQ_LSC_IDX);
+	nfp_net_irq_unmask(nn, entry->entry);
 
 	return IRQ_HANDLED;
 }
@@ -476,32 +483,28 @@ nfp_net_rx_ring_init(struct nfp_net_rx_ring *rx_ring,
 }
 
 /**
- * nfp_net_irqs_assign() - Assign IRQs and setup rvecs.
+ * nfp_net_vecs_init() - Assign IRQs and setup rvecs.
  * @netdev:   netdev structure
  */
-static void nfp_net_irqs_assign(struct net_device *netdev)
+static void nfp_net_vecs_init(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_r_vector *r_vec;
 	int r;
 
-	if (nn->num_rx_rings > nn->num_r_vecs ||
-	    nn->num_tx_rings > nn->num_r_vecs)
-		nn_warn(nn, "More rings (%d,%d) than vectors (%d).\n",
-			nn->num_rx_rings, nn->num_tx_rings, nn->num_r_vecs);
-
-	nn->num_rx_rings = min(nn->num_r_vecs, nn->num_rx_rings);
-	nn->num_tx_rings = min(nn->num_r_vecs, nn->num_tx_rings);
-	nn->num_stack_tx_rings = nn->num_tx_rings;
-
 	nn->lsc_handler = nfp_net_irq_lsc;
 	nn->exn_handler = nfp_net_irq_exn;
 
 	for (r = 0; r < nn->max_r_vecs; r++) {
+		struct msix_entry *entry;
+
+		entry = &nn->irq_entries[NFP_NET_NON_Q_VECTORS + r];
+
 		r_vec = &nn->r_vecs[r];
 		r_vec->nfp_net = nn;
 		r_vec->handler = nfp_net_irq_rxtx;
-		r_vec->irq_idx = NFP_NET_NON_Q_VECTORS + r;
+		r_vec->irq_entry = entry->entry;
+		r_vec->irq_vector = entry->vector;
 
 		cpumask_set_cpu(r, &r_vec->affinity_mask);
 	}
@@ -534,7 +537,7 @@ nfp_net_aux_irq_request(struct nfp_net *nn, u32 ctrl_offset,
 		       entry->vector, err);
 		return err;
 	}
-	nn_writeb(nn, ctrl_offset, vector_idx);
+	nn_writeb(nn, ctrl_offset, entry->entry);
 
 	return 0;
 }
@@ -1706,7 +1709,7 @@ static int nfp_net_poll(struct napi_struct *napi, int budget)
 
 	if (pkts_polled < budget) {
 		napi_complete_done(napi, pkts_polled);
-		nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_idx);
+		nfp_net_irq_unmask(r_vec->nfp_net, r_vec->irq_entry);
 	}
 
 	return pkts_polled;
@@ -1988,7 +1991,6 @@ static int
 nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 		       int idx)
 {
-	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
 	int err;
 
 	/* Setup NAPI */
@@ -1997,17 +1999,19 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 
 	snprintf(r_vec->name, sizeof(r_vec->name),
 		 "%s-rxtx-%d", nn->netdev->name, idx);
-	err = request_irq(entry->vector, r_vec->handler, 0, r_vec->name, r_vec);
+	err = request_irq(r_vec->irq_vector, r_vec->handler, 0, r_vec->name,
+			  r_vec);
 	if (err) {
 		netif_napi_del(&r_vec->napi);
-		nn_err(nn, "Error requesting IRQ %d\n", entry->vector);
+		nn_err(nn, "Error requesting IRQ %d\n", r_vec->irq_vector);
 		return err;
 	}
-	disable_irq(entry->vector);
+	disable_irq(r_vec->irq_vector);
 
-	irq_set_affinity_hint(entry->vector, &r_vec->affinity_mask);
+	irq_set_affinity_hint(r_vec->irq_vector, &r_vec->affinity_mask);
 
-	nn_dbg(nn, "RV%02d: irq=%03d/%03d\n", idx, entry->vector, entry->entry);
+	nn_dbg(nn, "RV%02d: irq=%03d/%03d\n", idx, r_vec->irq_vector,
+	       r_vec->irq_entry);
 
 	return 0;
 }
@@ -2015,11 +2019,9 @@ nfp_net_prepare_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec,
 static void
 nfp_net_cleanup_vector(struct nfp_net *nn, struct nfp_net_r_vector *r_vec)
 {
-	struct msix_entry *entry = &nn->irq_entries[r_vec->irq_idx];
-
-	irq_set_affinity_hint(entry->vector, NULL);
+	irq_set_affinity_hint(r_vec->irq_vector, NULL);
 	netif_napi_del(&r_vec->napi);
-	free_irq(entry->vector, r_vec);
+	free_irq(r_vec->irq_vector, r_vec);
 }
 
 /**
@@ -2148,7 +2150,7 @@ nfp_net_rx_ring_hw_cfg_write(struct nfp_net *nn,
 	/* Write the DMA address, size and MSI-X info to the device */
 	nn_writeq(nn, NFP_NET_CFG_RXR_ADDR(idx), rx_ring->dma);
 	nn_writeb(nn, NFP_NET_CFG_RXR_SZ(idx), ilog2(rx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), rx_ring->r_vec->irq_idx);
+	nn_writeb(nn, NFP_NET_CFG_RXR_VEC(idx), rx_ring->r_vec->irq_entry);
 }
 
 static void
@@ -2157,7 +2159,7 @@ nfp_net_tx_ring_hw_cfg_write(struct nfp_net *nn,
 {
 	nn_writeq(nn, NFP_NET_CFG_TXR_ADDR(idx), tx_ring->dma);
 	nn_writeb(nn, NFP_NET_CFG_TXR_SZ(idx), ilog2(tx_ring->cnt));
-	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), tx_ring->r_vec->irq_idx);
+	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), tx_ring->r_vec->irq_entry);
 }
 
 static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
@@ -2251,7 +2253,7 @@ static void nfp_net_open_stack(struct nfp_net *nn)
 
 	for (r = 0; r < nn->num_r_vecs; r++) {
 		napi_enable(&nn->r_vecs[r].napi);
-		enable_irq(nn->irq_entries[nn->r_vecs[r].irq_idx].vector);
+		enable_irq(nn->r_vecs[r].irq_vector);
 	}
 
 	netif_tx_wake_all_queues(nn->netdev);
@@ -2375,7 +2377,7 @@ static void nfp_net_close_stack(struct nfp_net *nn)
 	nn->link_up = false;
 
 	for (r = 0; r < nn->num_r_vecs; r++) {
-		disable_irq(nn->irq_entries[nn->r_vecs[r].irq_idx].vector);
+		disable_irq(nn->r_vecs[r].irq_vector);
 		napi_disable(&nn->r_vecs[r].napi);
 	}
 
@@ -3259,7 +3261,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	netif_carrier_off(netdev);
 
 	nfp_net_set_ethtool_ops(netdev);
-	nfp_net_irqs_assign(netdev);
+	nfp_net_vecs_init(netdev);
 
 	return register_netdev(netdev);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index ad0cc629cc32..39407f7cc586 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -45,6 +45,24 @@
 
 #include "nfp_net_ctrl.h"
 #include "nfp_net.h"
+#include "nfp_main.h"
+
+/**
+ * struct nfp_net_vf - NFP VF-specific device structure
+ * @nn:		NFP Net structure for this device
+ * @irq_entries: Pre-allocated array of MSI-X entries
+ * @q_bar:	Pointer to mapped QC memory (NULL if TX/RX mapped directly)
+ * @ddir:	Per-device debugfs directory
+ */
+struct nfp_net_vf {
+	struct nfp_net *nn;
+
+	struct msix_entry irq_entries[NFP_NET_NON_Q_VECTORS +
+				      NFP_NET_MAX_TX_RINGS];
+	u8 __iomem *q_bar;
+
+	struct dentry *ddir;
+};
 
 static const char nfp_net_driver_name[] = "nfp_netvf";
 
@@ -82,16 +100,22 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	u32 tx_bar_off, rx_bar_off;
 	u32 tx_bar_sz, rx_bar_sz;
 	int tx_bar_no, rx_bar_no;
+	struct nfp_net_vf *vf;
+	unsigned int num_irqs;
 	u8 __iomem *ctrl_bar;
-	struct dentry *ddir;
 	struct nfp_net *nn;
 	u32 startq;
 	int stride;
 	int err;
 
+	vf = kzalloc(sizeof(*vf), GFP_KERNEL);
+	if (!vf)
+		return -ENOMEM;
+	pci_set_drvdata(pdev, vf);
+
 	err = pci_enable_device_mem(pdev);
 	if (err)
-		return err;
+		goto err_free_vf;
 
 	err = pci_request_regions(pdev, nfp_net_driver_name);
 	if (err) {
@@ -183,6 +207,7 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 		err = PTR_ERR(nn);
 		goto err_ctrl_unmap;
 	}
+	vf->nn = nn;
 
 	nn->fw_ver = fw_ver;
 	nn->ctrl_bar = ctrl_bar;
@@ -206,17 +231,17 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 			bar_sz = (rx_bar_off + rx_bar_sz) - bar_off;
 
 		map_addr = pci_resource_start(pdev, tx_bar_no) + bar_off;
-		nn->q_bar = ioremap_nocache(map_addr, bar_sz);
-		if (!nn->q_bar) {
+		vf->q_bar = ioremap_nocache(map_addr, bar_sz);
+		if (!vf->q_bar) {
 			nn_err(nn, "Failed to map resource %d\n", tx_bar_no);
 			err = -EIO;
 			goto err_netdev_free;
 		}
 
 		/* TX queues */
-		nn->tx_bar = nn->q_bar + (tx_bar_off - bar_off);
+		nn->tx_bar = vf->q_bar + (tx_bar_off - bar_off);
 		/* RX queues */
-		nn->rx_bar = nn->q_bar + (rx_bar_off - bar_off);
+		nn->rx_bar = vf->q_bar + (rx_bar_off - bar_off);
 	} else {
 		resource_size_t map_addr;
 
@@ -241,12 +266,15 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 
 	nfp_netvf_get_mac_addr(nn);
 
-	err = nfp_net_irqs_alloc(nn);
-	if (!err) {
+	num_irqs = nfp_net_irqs_alloc(pdev, vf->irq_entries,
+				      NFP_NET_MIN_PORT_IRQS,
+				      NFP_NET_NON_Q_VECTORS + nn->num_r_vecs);
+	if (!num_irqs) {
 		nn_warn(nn, "Unable to allocate MSI-X Vectors. Exiting\n");
 		err = -EIO;
 		goto err_unmap_rx;
 	}
+	nfp_net_irqs_assign(nn, vf->irq_entries, num_irqs);
 
 	/* Get ME clock frequency from ctrl BAR
 	 * XXX for now frequency is hardcoded until we figure out how
@@ -258,27 +286,23 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_irqs_disable;
 
-	pci_set_drvdata(pdev, nn);
-
 	nfp_net_info(nn);
-	ddir = nfp_net_debugfs_device_add(pdev);
-	nfp_net_debugfs_port_add(nn, ddir, 0);
-	nn->debugfs_dir = ddir;
+	vf->ddir = nfp_net_debugfs_device_add(pdev);
+	nfp_net_debugfs_port_add(nn, vf->ddir, 0);
 
 	return 0;
 
 err_irqs_disable:
-	nfp_net_irqs_disable(nn);
+	nfp_net_irqs_disable(pdev);
 err_unmap_rx:
-	if (!nn->q_bar)
+	if (!vf->q_bar)
 		iounmap(nn->rx_bar);
 err_unmap_tx:
-	if (!nn->q_bar)
+	if (!vf->q_bar)
 		iounmap(nn->tx_bar);
 	else
-		iounmap(nn->q_bar);
+		iounmap(vf->q_bar);
 err_netdev_free:
-	pci_set_drvdata(pdev, NULL);
 	nfp_net_netdev_free(nn);
 err_ctrl_unmap:
 	iounmap(ctrl_bar);
@@ -286,36 +310,42 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	pci_release_regions(pdev);
 err_pci_disable:
 	pci_disable_device(pdev);
+err_free_vf:
+	pci_set_drvdata(pdev, NULL);
+	kfree(vf);
 	return err;
 }
 
 static void nfp_netvf_pci_remove(struct pci_dev *pdev)
 {
-	struct nfp_net *nn = pci_get_drvdata(pdev);
+	struct nfp_net_vf *vf = pci_get_drvdata(pdev);
+	struct nfp_net *nn = vf->nn;
 
 	/* Note, the order is slightly different from above as we need
 	 * to keep the nn pointer around till we have freed everything.
 	 */
 	nfp_net_debugfs_dir_clean(&nn->debugfs_dir);
+	nfp_net_debugfs_dir_clean(&vf->ddir);
 
 	nfp_net_netdev_clean(nn->netdev);
 
-	nfp_net_irqs_disable(nn);
+	nfp_net_irqs_disable(pdev);
 
-	if (!nn->q_bar) {
+	if (!vf->q_bar) {
 		iounmap(nn->rx_bar);
 		iounmap(nn->tx_bar);
 	} else {
-		iounmap(nn->q_bar);
+		iounmap(vf->q_bar);
 	}
 	iounmap(nn->ctrl_bar);
 
-	pci_set_drvdata(pdev, NULL);
-
 	nfp_net_netdev_free(nn);
 
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
+
+	pci_set_drvdata(pdev, NULL);
+	kfree(vf);
 }
 
 struct pci_driver nfp_netvf_pci_driver = {
-- 
2.11.0
