From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 02/14] nfp: remove support for nfp3200
Date: Mon, 31 Oct 2016 20:43:10 +0000
Message-ID: <1477946602-19644-3-git-send-email-jakub.kicinski@netronome.com>
References: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36034 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034001AbcJaUoB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:44:01 -0400
Received: by mail-wm0-f51.google.com with SMTP id p190so170354278wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:44:00 -0700 (PDT)
In-Reply-To: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Drop all code related to nfp3200.  It was never widely deployed
as a NIC.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  7 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 95 ++--------------------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  | 13 +--
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    | 45 ++--------
 4 files changed, 22 insertions(+), 138 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index ed824e11a1e3..808c38ae4991 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -421,7 +421,6 @@ struct nfp_stat_pair {
  * @netdev:             Backpointer to net_device structure
  * @nfp_fallback:       Is the driver used in fallback mode?
  * @is_vf:              Is the driver attached to a VF?
- * @is_nfp3200:         Is the driver for a NFP-3200 card?
  * @fw_loaded:          Is the firmware loaded?
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
  * @ctrl:               Local copy of the control register/word.
@@ -487,7 +486,6 @@ struct nfp_net {
 
 	unsigned nfp_fallback:1;
 	unsigned is_vf:1;
-	unsigned is_nfp3200:1;
 	unsigned fw_loaded:1;
 	unsigned bpf_offload_skip_sw:1;
 
@@ -593,16 +591,13 @@ static inline void nn_writeb(struct nfp_net *nn, int off, u8 val)
 	writeb(val, nn->ctrl_bar + off);
 }
 
-/* NFP-3200 can't handle 16-bit accesses too well */
 static inline u16 nn_readw(struct nfp_net *nn, int off)
 {
-	WARN_ON_ONCE(nn->is_nfp3200);
 	return readw(nn->ctrl_bar + off);
 }
 
 static inline void nn_writew(struct nfp_net *nn, int off, u16 val)
 {
-	WARN_ON_ONCE(nn->is_nfp3200);
 	writew(val, nn->ctrl_bar + off);
 }
 
@@ -650,7 +645,7 @@ static inline void nn_pci_flush(struct nfp_net *nn)
 #define NFP_QCP_QUEUE_STS_HI			0x000c
 #define NFP_QCP_QUEUE_STS_HI_WRITEPTR_mask	0x3ffff
 
-/* The offset of a QCP queues in the PCIe Target (same on NFP3200 and NFP6000 */
+/* The offset of a QCP queues in the PCIe Target */
 #define NFP_PCIE_QUEUE(_q) (0x80000 + (NFP_QCP_QUEUE_ADDR_SZ * ((_q) & 0xff)))
 
 /* nfp_qcp_ptr - Read or Write Pointer of a queue */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f6a42c14a1f0..4e4b6e3b30d7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -249,43 +249,14 @@ int nfp_net_reconfig(struct nfp_net *nn, u32 update)
  */
 
 /**
- * nfp_net_irq_unmask_msix() - Unmask MSI-X after automasking
- * @nn:       NFP Network structure
- * @entry_nr: MSI-X table entry
- *
- * Clear the MSI-X table mask bit for the given entry bypassing Linux irq
- * handling subsystem.  Use *only* to reenable automasked vectors.
- */
-static void nfp_net_irq_unmask_msix(struct nfp_net *nn, unsigned int entry_nr)
-{
-	struct list_head *msi_head = &nn->pdev->dev.msi_list;
-	struct msi_desc *entry;
-	u32 off;
-
-	/* All MSI-Xs have the same mask_base */
-	entry = list_first_entry(msi_head, struct msi_desc, list);
-
-	off = (PCI_MSIX_ENTRY_SIZE * entry_nr) +
-		PCI_MSIX_ENTRY_VECTOR_CTRL;
-	writel(0, entry->mask_base + off);
-	readl(entry->mask_base);
-}
-
-/**
  * nfp_net_irq_unmask() - Unmask automasked interrupt
  * @nn:       NFP Network structure
  * @entry_nr: MSI-X table entry
  *
- * If MSI-X auto-masking is enabled clear the mask bit, otherwise
- * clear the ICR for the entry.
+ * Clear the ICR for the IRQ entry.
  */
 static void nfp_net_irq_unmask(struct nfp_net *nn, unsigned int entry_nr)
 {
-	if (nn->ctrl & NFP_NET_CFG_CTRL_MSIXAUTO) {
-		nfp_net_irq_unmask_msix(nn, entry_nr);
-		return;
-	}
-
 	nn_writeb(nn, NFP_NET_CFG_ICR(entry_nr), NFP_NET_CFG_ICR_UNMASKED);
 	nn_pci_flush(nn);
 }
@@ -1368,20 +1339,6 @@ static void nfp_net_set_hash(struct net_device *netdev, struct sk_buff *skb,
  * more cleanly separate packet receive code from other bookkeeping
  * functions performed in the napi poll function.
  *
- * There are differences between the NFP-3200 firmware and the
- * NFP-6000 firmware.  The NFP-3200 firmware uses a dedicated RX queue
- * to indicate that new packets have arrived.  The NFP-6000 does not
- * have this queue and uses the DD bit in the RX descriptor. This
- * method cannot be used on the NFP-3200 as it causes a race
- * condition: The RX ring write pointer on the NFP-3200 is updated
- * after packets (and descriptors) have been DMAed.  If the DD bit is
- * used and subsequently the read pointer is updated this may lead to
- * the RX queue to underflow (if the firmware has not yet update the
- * write pointer).  Therefore we use slightly ugly conditional code
- * below to handle the differences.  We may, in the future update the
- * NFP-3200 firmware to behave the same as the firmware on the
- * NFP-6000.
- *
  * Return: Number of packets received.
  */
 static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
@@ -1389,41 +1346,19 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 	struct nfp_net_r_vector *r_vec = rx_ring->r_vec;
 	struct nfp_net *nn = r_vec->nfp_net;
 	unsigned int data_len, meta_len;
-	int avail = 0, pkts_polled = 0;
 	struct sk_buff *skb, *new_skb;
 	struct nfp_net_rx_desc *rxd;
 	dma_addr_t new_dma_addr;
-	u32 qcp_wr_p;
+	int pkts_polled = 0;
 	int idx;
 
-	if (nn->is_nfp3200) {
-		/* Work out how many packets arrived */
-		qcp_wr_p = nfp_qcp_wr_ptr_read(rx_ring->qcp_rx);
-		idx = rx_ring->rd_p % rx_ring->cnt;
-
-		if (qcp_wr_p == idx)
-			/* No new packets */
-			return 0;
-
-		if (qcp_wr_p > idx)
-			avail = qcp_wr_p - idx;
-		else
-			avail = qcp_wr_p + rx_ring->cnt - idx;
-	} else {
-		avail = budget + 1;
-	}
-
-	while (avail > 0 && pkts_polled < budget) {
+	while (pkts_polled < budget) {
 		idx = rx_ring->rd_p % rx_ring->cnt;
 
 		rxd = &rx_ring->rxds[idx];
-		if (!(rxd->rxd.meta_len_dd & PCIE_DESC_RX_DD)) {
-			if (nn->is_nfp3200)
-				nn_dbg(nn, "RX descriptor not valid (DD)%d:%u rxd[0]=%#x rxd[1]=%#x\n",
-				       rx_ring->idx, idx,
-				       rxd->vals[0], rxd->vals[1]);
+		if (!(rxd->rxd.meta_len_dd & PCIE_DESC_RX_DD))
 			break;
-		}
+
 		/* Memory barrier to ensure that we won't do other reads
 		 * before the DD bit.
 		 */
@@ -1431,7 +1366,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 
 		rx_ring->rd_p++;
 		pkts_polled++;
-		avail--;
 
 		skb = rx_ring->rxbufs[idx].skb;
 
@@ -1508,9 +1442,6 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		napi_gro_receive(&rx_ring->r_vec->napi, skb);
 	}
 
-	if (nn->is_nfp3200)
-		nfp_qcp_rd_ptr_add(rx_ring->qcp_rx, pkts_polled);
-
 	return pkts_polled;
 }
 
@@ -1895,9 +1826,8 @@ static void nfp_net_write_mac_addr(struct nfp_net *nn)
 {
 	nn_writel(nn, NFP_NET_CFG_MACADDR + 0,
 		  get_unaligned_be32(nn->netdev->dev_addr));
-	/* We can't do writew for NFP-3200 compatibility */
-	nn_writel(nn, NFP_NET_CFG_MACADDR + 4,
-		  get_unaligned_be16(nn->netdev->dev_addr + 4) << 16);
+	nn_writew(nn, NFP_NET_CFG_MACADDR + 6,
+		  get_unaligned_be16(nn->netdev->dev_addr + 4));
 }
 
 static void nfp_net_vec_clear_ring_data(struct nfp_net *nn, unsigned int idx)
@@ -2675,8 +2605,7 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
  */
 void nfp_net_info(struct nfp_net *nn)
 {
-	nn_info(nn, "Netronome %s %sNetdev: TxQs=%d/%d RxQs=%d/%d\n",
-		nn->is_nfp3200 ? "NFP-32xx" : "NFP-6xxx",
+	nn_info(nn, "Netronome NFP-6xxx %sNetdev: TxQs=%d/%d RxQs=%d/%d\n",
 		nn->is_vf ? "VF " : "",
 		nn->num_tx_rings, nn->max_tx_rings,
 		nn->num_rx_rings, nn->max_rx_rings);
@@ -2891,13 +2820,7 @@ int nfp_net_netdev_init(struct net_device *netdev)
 		nn->ctrl |= NFP_NET_CFG_CTRL_IRQMOD;
 	}
 
-	/* On NFP-3200 enable MSI-X auto-masking, if supported and the
-	 * interrupts are not shared.
-	 */
-	if (nn->is_nfp3200 && nn->cap & NFP_NET_CFG_CTRL_MSIXAUTO)
-		nn->ctrl |= NFP_NET_CFG_CTRL_MSIXAUTO;
-
-	/* On NFP4000/NFP6000, determine RX packet/metadata boundary offset */
+	/* Determine RX packet/metadata boundary offset */
 	if (nn->fw_ver.major >= 2)
 		nn->rx_offset = nn_readl(nn, NFP_NET_CFG_RX_OFFSET);
 	else
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index 93b10b441acb..385ba355c965 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -50,7 +50,7 @@
 /**
  * Configuration BAR size.
  *
- * The configuration BAR is 8K in size, but on the NFP6000, due to
+ * The configuration BAR is 8K in size, but due to
  * THB-350, 32k needs to be reserved.
  */
 #define NFP_NET_CFG_BAR_SZ              (32 * 1024)
@@ -186,18 +186,13 @@
 #define NFP_NET_CFG_START_RXQ           0x004c
 
 /**
- * NFP-3200 workaround (0x0050 - 0x0058)
- * @NFP_NET_CFG_SPARE_ADDR:  DMA address for ME code to use (e.g. YDS-155 fix)
- */
-#define NFP_NET_CFG_SPARE_ADDR          0x0050
-/**
- * NFP6000/NFP4000 - Prepend configuration
+ * Prepend configuration
  */
 #define NFP_NET_CFG_RX_OFFSET		0x0050
 #define NFP_NET_CFG_RX_OFFSET_DYNAMIC		0	/* Prepend mode */
 
 /**
- * NFP6000/NFP4000 - VXLAN/UDP encap configuration
+ * VXLAN/UDP encap configuration
  * @NFP_NET_CFG_VXLAN_PORT:	Base address of table of tunnels' UDP dst ports
  * @NFP_NET_CFG_VXLAN_SZ:	Size of the UDP port table in bytes
  */
@@ -205,7 +200,7 @@
 #define NFP_NET_CFG_VXLAN_SZ		  0x0008
 
 /**
- * NFP6000 - BPF section
+ * BPF section
  * @NFP_NET_CFG_BPF_ABI:	BPF ABI version
  * @NFP_NET_CFG_BPF_CAP:	BPF capabilities
  * @NFP_NET_CFG_BPF_MAX_LEN:	Maximum size of JITed BPF code in bytes
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
index 2800bbf65a89..d065235034d4 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c
@@ -63,9 +63,7 @@ static void nfp_netvf_get_mac_addr(struct nfp_net *nn)
 	u8 mac_addr[ETH_ALEN];
 
 	put_unaligned_be32(nn_readl(nn, NFP_NET_CFG_MACADDR + 0), &mac_addr[0]);
-	/* We can't do readw for NFP-3200 compatibility */
-	put_unaligned_be16(nn_readl(nn, NFP_NET_CFG_MACADDR + 4) >> 16,
-			   &mac_addr[4]);
+	put_unaligned_be16(nn_readw(nn, NFP_NET_CFG_MACADDR + 6), &mac_addr[4]);
 
 	if (!is_valid_ether_addr(mac_addr)) {
 		eth_hw_addr_random(nn->netdev);
@@ -86,7 +84,6 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	int tx_bar_no, rx_bar_no;
 	u8 __iomem *ctrl_bar;
 	struct nfp_net *nn;
-	int is_nfp3200;
 	u32 startq;
 	int stride;
 	int err;
@@ -101,15 +98,6 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 		goto err_pci_disable;
 	}
 
-	switch (pdev->device) {
-	case PCI_DEVICE_NFP6000VF:
-		is_nfp3200 = 0;
-		break;
-	default:
-		err = -ENODEV;
-		goto err_pci_regions;
-	}
-
 	pci_set_master(pdev);
 
 	err = dma_set_mask_and_coherent(&pdev->dev,
@@ -149,15 +137,9 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	} else {
 		switch (fw_ver.major) {
 		case 1 ... 4:
-			if (is_nfp3200) {
-				stride = 2;
-				tx_bar_no = NFP_NET_Q0_BAR;
-				rx_bar_no = NFP_NET_Q1_BAR;
-			} else {
-				stride = 4;
-				tx_bar_no = NFP_NET_Q0_BAR;
-				rx_bar_no = tx_bar_no;
-			}
+			stride = 4;
+			tx_bar_no = NFP_NET_Q0_BAR;
+			rx_bar_no = tx_bar_no;
 			break;
 		default:
 			dev_err(&pdev->dev, "Unsupported Firmware ABI %d.%d.%d.%d\n",
@@ -189,20 +171,10 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 		max_rx_rings = (rx_bar_sz / NFP_QCP_QUEUE_ADDR_SZ) / 2;
 	}
 
-	/* XXX Implement a workaround for THB-350 here.  Ideally, we
-	 * have a different PCI ID for A rev VFs.
-	 */
-	switch (pdev->device) {
-	case PCI_DEVICE_NFP6000VF:
-		startq = readl(ctrl_bar + NFP_NET_CFG_START_TXQ);
-		tx_bar_off = NFP_PCIE_QUEUE(startq);
-		startq = readl(ctrl_bar + NFP_NET_CFG_START_RXQ);
-		rx_bar_off = NFP_PCIE_QUEUE(startq);
-		break;
-	default:
-		err = -ENODEV;
-		goto err_ctrl_unmap;
-	}
+	startq = readl(ctrl_bar + NFP_NET_CFG_START_TXQ);
+	tx_bar_off = NFP_PCIE_QUEUE(startq);
+	startq = readl(ctrl_bar + NFP_NET_CFG_START_RXQ);
+	rx_bar_off = NFP_PCIE_QUEUE(startq);
 
 	/* Allocate and initialise the netdev */
 	nn = nfp_net_netdev_alloc(pdev, max_tx_rings, max_rx_rings);
@@ -214,7 +186,6 @@ static int nfp_netvf_pci_probe(struct pci_dev *pdev,
 	nn->fw_ver = fw_ver;
 	nn->ctrl_bar = ctrl_bar;
 	nn->is_vf = 1;
-	nn->is_nfp3200 = is_nfp3200;
 	nn->stride_tx = stride;
 	nn->stride_rx = stride;
 
-- 
1.9.1
