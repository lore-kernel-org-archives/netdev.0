From: Brice Goglin <brice@myri.com>
Subject: [PATCH 13/16] myri10ge: add routines for multislices
Date: Fri, 09 May 2008 02:21:10 +0200
Message-ID: <482398F6.3060902@myri.com>
References: <482397A3.1050604@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1866 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754099AbYEIAUv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 May 2008 20:20:51 -0400
In-Reply-To: <482397A3.1050604@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add several routines that multislices support will use.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  256 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 256 insertions(+)

Index: linux-2.6/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-2.6.orig/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:12:46.000000000 +0200
+++ linux-2.6/drivers/net/myri10ge/myri10ge.c	2008-05-09 00:14:33.000000000 +0200
@@ -1928,6 +1928,76 @@
 	return 0;
 }
 
+#if 0
+static int myri10ge_get_txrx(struct myri10ge_priv *mgp, int slice)
+{
+	struct myri10ge_cmd cmd;
+	struct myri10ge_slice_state *ss;
+	int status;
+
+	ss = &mgp->ss[slice];
+	cmd.data0 = 0;		/* single slice for now */
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
+	ss->tx.lanai = (struct mcp_kreq_ether_send __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	cmd.data0 = slice;
+	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SMALL_RX_OFFSET,
+				    &cmd, 0);
+	ss->rx_small.lanai = (struct mcp_kreq_ether_recv __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	cmd.data0 = slice;
+	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_BIG_RX_OFFSET, &cmd, 0);
+	ss->rx_big.lanai = (struct mcp_kreq_ether_recv __iomem *)
+	    (mgp->sram + cmd.data0);
+
+	if (myri10ge_wcfifo && mgp->wc_enabled) {
+		ss->tx.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_SEND_4 + 64 * slice;
+		ss->rx_small.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_RECV_SMALL + 64 * slice;
+		ss->rx_big.wc_fifo = (u8 __iomem *)
+		    mgp->sram + MXGEFW_ETH_RECV_BIG + 64 * slice;
+	} else {
+		ss->tx.wc_fifo = NULL;
+		ss->rx_small.wc_fifo = NULL;
+		ss->rx_big.wc_fifo = NULL;
+	}
+	return status;
+
+}
+
+static int myri10ge_set_stats(struct myri10ge_priv *mgp, int slice)
+{
+	struct myri10ge_cmd cmd;
+	struct myri10ge_slice_state *ss;
+	int status;
+
+	ss = &mgp->ss[slice];
+	cmd.data0 = MYRI10GE_LOWPART_TO_U32(ss->fw_stats_bus);
+	cmd.data1 = MYRI10GE_HIGHPART_TO_U32(ss->fw_stats_bus);
+	cmd.data2 = sizeof(struct mcp_irq_data);
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_STATS_DMA_V2, &cmd, 0);
+	if (status == -ENOSYS) {
+		dma_addr_t bus = ss->fw_stats_bus;
+		if (slice != 0)
+			return -EINVAL;
+		bus += offsetof(struct mcp_irq_data, send_done_count);
+		cmd.data0 = MYRI10GE_LOWPART_TO_U32(bus);
+		cmd.data1 = MYRI10GE_HIGHPART_TO_U32(bus);
+		status = myri10ge_send_cmd(mgp,
+					   MXGEFW_CMD_SET_STATS_DMA_OBSOLETE,
+					   &cmd, 0);
+		/* Firmware cannot support multicast without STATS_DMA_V2 */
+		mgp->fw_multicast_support = 0;
+	} else {
+		mgp->fw_multicast_support = 1;
+	}
+	return 0;
+}
+#endif
+
 static int myri10ge_open(struct net_device *dev)
 {
 	struct myri10ge_priv *mgp = netdev_priv(dev);
@@ -3106,6 +3176,192 @@
 	mgp->watchdog_pause = rx_pause_cnt;
 }
 
+#if 0
+static void myri10ge_free_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_slice_state *ss;
+	struct pci_dev *pdev = mgp->pdev;
+	size_t bytes;
+	int i;
+
+	if (mgp->ss == NULL)
+		return;
+
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		if (ss->rx_done.entry != NULL) {
+			bytes = mgp->max_intr_slots *
+			    sizeof(*ss->rx_done.entry);
+			dma_free_coherent(&pdev->dev, bytes,
+					  ss->rx_done.entry, ss->rx_done.bus);
+			ss->rx_done.entry = NULL;
+		}
+		if (ss->fw_stats != NULL) {
+			bytes = sizeof(*ss->fw_stats);
+			dma_free_coherent(&pdev->dev, bytes,
+					  ss->fw_stats, ss->fw_stats_bus);
+			ss->fw_stats = NULL;
+		}
+	}
+	kfree(mgp->ss);
+	mgp->ss = NULL;
+}
+
+static int myri10ge_alloc_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_slice_state *ss;
+	struct pci_dev *pdev = mgp->pdev;
+	size_t bytes;
+	int i;
+
+	bytes = sizeof(*mgp->ss) * mgp->num_slices;
+	mgp->ss = kzalloc(bytes, GFP_KERNEL);
+	if (mgp->ss == NULL) {
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < mgp->num_slices; i++) {
+		ss = &mgp->ss[i];
+		bytes = mgp->max_intr_slots * sizeof(*ss->rx_done.entry);
+		ss->rx_done.entry = dma_alloc_coherent(&pdev->dev, bytes,
+						       &ss->rx_done.bus,
+						       GFP_KERNEL);
+		if (ss->rx_done.entry == NULL)
+			goto abort;
+		memset(ss->rx_done.entry, 0, bytes);
+		bytes = sizeof(*ss->fw_stats);
+		ss->fw_stats = dma_alloc_coherent(&pdev->dev, bytes,
+						  &ss->fw_stats_bus,
+						  GFP_KERNEL);
+		if (ss->fw_stats == NULL)
+			goto abort;
+		ss->mgp = mgp;
+		ss->dev = mgp->dev;
+		netif_napi_add(ss->dev, &ss->napi, myri10ge_poll,
+			       myri10ge_napi_weight);
+	}
+	return 0;
+abort:
+	myri10ge_free_slices(mgp);
+	return -ENOMEM;
+}
+
+/*
+ * This function determines the number of slices supported.
+ * The number slices is the minumum of the number of CPUS,
+ * the number of MSI-X irqs supported, the number of slices
+ * supported by the firmware
+ */
+static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
+{
+	struct myri10ge_cmd cmd;
+	struct pci_dev *pdev = mgp->pdev;
+	char *old_fw;
+	int i, status, ncpus, msix_cap;
+
+	mgp->num_slices = 1;
+	msix_cap = pci_find_capability(pdev, PCI_CAP_ID_MSIX);
+	ncpus = num_online_cpus();
+
+	if (myri10ge_max_slices == 1 || msix_cap == 0 ||
+	    (myri10ge_max_slices == -1 && ncpus < 2))
+		return;
+
+	/* try to load the slice aware rss firmware */
+	old_fw = mgp->fw_name;
+	if (old_fw == myri10ge_fw_aligned)
+		mgp->fw_name = myri10ge_fw_rss_aligned;
+	else
+		mgp->fw_name = myri10ge_fw_rss_unaligned;
+	status = myri10ge_load_firmware(mgp, 0);
+	if (status != 0) {
+		dev_info(&pdev->dev, "Rss firmware not found\n");
+		return;
+	}
+
+	/* hit the board with a reset to ensure it is alive */
+	memset(&cmd, 0, sizeof(cmd));
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_RESET, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev, "failed reset\n");
+		goto abort_with_fw;
+		return;
+	}
+
+	mgp->max_intr_slots = cmd.data0 / sizeof(struct mcp_slot);
+
+	/* tell it the size of the interrupt queues */
+	cmd.data0 = mgp->max_intr_slots * sizeof(struct mcp_slot);
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_SET_INTRQ_SIZE, &cmd, 0);
+	if (status != 0) {
+		dev_err(&mgp->pdev->dev, "failed MXGEFW_CMD_SET_INTRQ_SIZE\n");
+		goto abort_with_fw;
+	}
+
+	/* ask the maximum number of slices it supports */
+	status = myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_MAX_RSS_QUEUES, &cmd, 0);
+	if (status != 0)
+		goto abort_with_fw;
+	else
+		mgp->num_slices = cmd.data0;
+
+	/* Only allow multiple slices if MSI-X is usable */
+	if (!myri10ge_msi) {
+		goto abort_with_fw;
+	}
+
+	/* if the admin did not specify a limit to how many
+	 * slices we should use, cap it automatically to the
+	 * number of CPUs currently online */
+	if (myri10ge_max_slices == -1)
+		myri10ge_max_slices = ncpus;
+
+	if (mgp->num_slices > myri10ge_max_slices)
+		mgp->num_slices = myri10ge_max_slices;
+
+	/* Now try to allocate as many MSI-X vectors as we have
+	 * slices. We give up on MSI-X if we can only get a single
+	 * vector. */
+
+	mgp->msix_vectors = kzalloc(mgp->num_slices *
+				    sizeof(*mgp->msix_vectors), GFP_KERNEL);
+	if (mgp->msix_vectors == NULL)
+		goto disable_msix;
+	for (i = 0; i < mgp->num_slices; i++) {
+		mgp->msix_vectors[i].entry = i;
+	}
+
+	while (mgp->num_slices > 1) {
+		/* make sure it is a power of two */
+		while (!is_power_of_2(mgp->num_slices))
+			mgp->num_slices--;
+		if (mgp->num_slices == 1)
+			goto disable_msix;
+		status = pci_enable_msix(pdev, mgp->msix_vectors,
+					 mgp->num_slices);
+		if (status == 0) {
+			pci_disable_msix(pdev);
+			return;
+		}
+		if (status > 0)
+			mgp->num_slices = status;
+		else
+			goto disable_msix;
+	}
+
+disable_msix:
+	if (mgp->msix_vectors != NULL) {
+		kfree(mgp->msix_vectors);
+		mgp->msix_vectors = NULL;
+	}
+
+abort_with_fw:
+	mgp->num_slices = 1;
+	mgp->fw_name = old_fw;
+	myri10ge_load_firmware(mgp, 0);
+}
+#endif
+
 static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *netdev;


