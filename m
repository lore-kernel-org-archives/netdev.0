From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH 2/3] net: via-rhine: reduce usage of the PCI-specific struct
Date: Mon, 27 Jan 2014 15:51:42 +0400
Message-ID: <1390823503-24087-3-git-send-email-alchark@gmail.com>
References: <1385227995-3956-1-git-send-email-alchark@gmail.com>
 <1390823503-24087-1-git-send-email-alchark@gmail.com>
Cc: Alexey Charkov <alchark@gmail.com>
To: netdev@vger.kernel.org, linux@prisktech.co.nz,
	devicetree@vger.kernel.org, rl@hellgate.ch,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390823503-24087-1-git-send-email-alchark@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use more generic data structures instead of struct pci_dev wherever
possible in preparation for OF bus binding

Signed-off-by: Alexey Charkov <alchark@gmail.com>
Signed-off-by: Roger Luethi <rl@hellgate.ch>
---
 drivers/net/ethernet/via/via-rhine.c | 116 +++++++++++++++++++----------------
 1 file changed, 62 insertions(+), 54 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index fee8732..95c2e93 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -446,7 +446,8 @@ struct rhine_private {
 	unsigned char *tx_bufs;
 	dma_addr_t tx_bufs_dma;
 
-	struct pci_dev *pdev;
+	int revision;
+	int irq;
 	long pioaddr;
 	struct net_device *dev;
 	struct napi_struct napi;
@@ -701,7 +702,7 @@ static void rhine_reload_eeprom(long pioaddr, struct net_device *dev)
 static void rhine_poll(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
-	const int irq = rp->pdev->irq;
+	const int irq = rp->irq;
 
 	disable_irq(irq);
 	rhine_interrupt(irq, dev);
@@ -871,6 +872,8 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct net_device *dev;
 	struct rhine_private *rp;
+	struct device *hwdev = &pdev->dev;
+	int revision = pdev->revision;
 	int i, rc;
 	u32 quirks;
 	long pioaddr;
@@ -893,21 +896,19 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	phy_id = 0;
 	quirks = 0;
 	name = "Rhine";
-	if (pdev->revision < VTunknown0) {
+	if (revision < VTunknown0) {
 		quirks = rqRhineI;
 		io_size = 128;
-	}
-	else if (pdev->revision >= VT6102) {
+	} else if (revision >= VT6102) {
 		quirks = rqWOL | rqForceReset;
-		if (pdev->revision < VT6105) {
+		if (revision < VT6105) {
 			name = "Rhine II";
 			quirks |= rqStatusWBRace;	/* Rhine-II exclusive */
-		}
-		else {
+		} else {
 			phy_id = 1;	/* Integrated PHY, phy_id fixed to 1 */
-			if (pdev->revision >= VT6105_B0)
+			if (revision >= VT6105_B0)
 				quirks |= rq6patterns;
-			if (pdev->revision < VT6105M)
+			if (revision < VT6105M)
 				name = "Rhine III";
 			else
 				name = "Rhine III (Management Adapter)";
@@ -919,10 +920,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out;
 
 	/* this should always be supported */
-	rc = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
+	rc = dma_set_mask(hwdev, DMA_BIT_MASK(32));
 	if (rc) {
-		dev_err(&pdev->dev,
-			"32-bit DMA addresses not supported by the card!?\n");
+		dev_err(hwdev, "32-bit DMA addresses not supported by the card!?\n");
 		goto err_out;
 	}
 
@@ -930,7 +930,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if ((pci_resource_len(pdev, 0) < io_size) ||
 	    (pci_resource_len(pdev, 1) < io_size)) {
 		rc = -EIO;
-		dev_err(&pdev->dev, "Insufficient PCI resources, aborting\n");
+		dev_err(hwdev, "Insufficient PCI resources, aborting\n");
 		goto err_out;
 	}
 
@@ -944,13 +944,13 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rc = -ENOMEM;
 		goto err_out;
 	}
-	SET_NETDEV_DEV(dev, &pdev->dev);
+	SET_NETDEV_DEV(dev, hwdev);
 
 	rp = netdev_priv(dev);
 	rp->dev = dev;
+	rp->revision = revision;
 	rp->quirks = quirks;
 	rp->pioaddr = pioaddr;
-	rp->pdev = pdev;
 	rp->msg_enable = netif_msg_init(debug, RHINE_MSG_DEFAULT);
 
 	rc = pci_request_regions(pdev, DRV_NAME);
@@ -960,9 +960,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ioaddr = pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
 		rc = -EIO;
-		dev_err(&pdev->dev,
+		dev_err(hwdev,
 			"ioremap failed for device %s, region 0x%X @ 0x%lX\n",
-			pci_name(pdev), io_size, memaddr);
+			dev_name(hwdev), io_size, memaddr);
 		goto err_out_free_res;
 	}
 
@@ -977,7 +977,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		unsigned char b = readb(ioaddr+reg);
 		if (a != b) {
 			rc = -EIO;
-			dev_err(&pdev->dev,
+			dev_err(hwdev,
 				"MMIO do not match PIO [%02x] (%02x != %02x)\n",
 				reg, a, b);
 			goto err_out_unmap;
@@ -986,6 +986,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif /* USE_MMIO */
 
 	rp->base = ioaddr;
+	rp->irq = pdev->irq;
 
 	u64_stats_init(&rp->tx_stats.syncp);
 	u64_stats_init(&rp->rx_stats.syncp);
@@ -1030,7 +1031,7 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (rp->quirks & rqRhineI)
 		dev->features |= NETIF_F_SG|NETIF_F_HW_CSUM;
 
-	if (pdev->revision >= VT6105M)
+	if (rp->revision >= VT6105M)
 		dev->features |= NETIF_F_HW_VLAN_CTAG_TX |
 				 NETIF_F_HW_VLAN_CTAG_RX |
 				 NETIF_F_HW_VLAN_CTAG_FILTER;
@@ -1047,9 +1048,9 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #else
 		    (long)ioaddr,
 #endif
-		    dev->dev_addr, pdev->irq);
+		    dev->dev_addr, rp->irq);
 
-	pci_set_drvdata(pdev, dev);
+	dev_set_drvdata(hwdev, dev);
 
 	{
 		u16 mii_cmd;
@@ -1091,10 +1092,11 @@ err_out:
 static int alloc_ring(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	void *ring;
 	dma_addr_t ring_dma;
 
-	ring = dma_alloc_coherent(&rp->pdev->dev,
+	ring = dma_alloc_coherent(hwdev,
 				    RX_RING_SIZE * sizeof(struct rx_desc) +
 				    TX_RING_SIZE * sizeof(struct tx_desc),
 				    &ring_dma,
@@ -1104,12 +1106,12 @@ static int alloc_ring(struct net_device* dev)
 		return -ENOMEM;
 	}
 	if (rp->quirks & rqRhineI) {
-		rp->tx_bufs = dma_alloc_coherent(&rp->pdev->dev,
+		rp->tx_bufs = dma_alloc_coherent(hwdev,
 						   PKT_BUF_SZ * TX_RING_SIZE,
 						   &rp->tx_bufs_dma,
 						   GFP_ATOMIC);
 		if (rp->tx_bufs == NULL) {
-			dma_free_coherent(&rp->pdev->dev,
+			dma_free_coherent(hwdev,
 				    RX_RING_SIZE * sizeof(struct rx_desc) +
 				    TX_RING_SIZE * sizeof(struct tx_desc),
 				    ring, ring_dma);
@@ -1128,15 +1130,16 @@ static int alloc_ring(struct net_device* dev)
 static void free_ring(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 
-	dma_free_coherent(&rp->pdev->dev,
+	dma_free_coherent(hwdev,
 			    RX_RING_SIZE * sizeof(struct rx_desc) +
 			    TX_RING_SIZE * sizeof(struct tx_desc),
 			    rp->rx_ring, rp->rx_ring_dma);
 	rp->tx_ring = NULL;
 
 	if (rp->tx_bufs)
-		dma_free_coherent(&rp->pdev->dev, PKT_BUF_SZ * TX_RING_SIZE,
+		dma_free_coherent(hwdev, PKT_BUF_SZ * TX_RING_SIZE,
 				    rp->tx_bufs, rp->tx_bufs_dma);
 
 	rp->tx_bufs = NULL;
@@ -1146,6 +1149,7 @@ static void free_ring(struct net_device* dev)
 static void alloc_rbufs(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	dma_addr_t next;
 	int i;
 
@@ -1174,9 +1178,9 @@ static void alloc_rbufs(struct net_device *dev)
 			break;
 
 		rp->rx_skbuff_dma[i] =
-			dma_map_single(&rp->pdev->dev, skb->data, rp->rx_buf_sz,
+			dma_map_single(hwdev, skb->data, rp->rx_buf_sz,
 				       DMA_FROM_DEVICE);
-		if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[i])) {
+		if (dma_mapping_error(hwdev, rp->rx_skbuff_dma[i])) {
 			rp->rx_skbuff_dma[i] = 0;
 			dev_kfree_skb(skb);
 			break;
@@ -1190,6 +1194,7 @@ static void alloc_rbufs(struct net_device *dev)
 static void free_rbufs(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	int i;
 
 	/* Free all the skbuffs in the Rx queue. */
@@ -1197,7 +1202,7 @@ static void free_rbufs(struct net_device* dev)
 		rp->rx_ring[i].rx_status = 0;
 		rp->rx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (rp->rx_skbuff[i]) {
-			dma_unmap_single(&rp->pdev->dev,
+			dma_unmap_single(hwdev,
 					 rp->rx_skbuff_dma[i],
 					 rp->rx_buf_sz, DMA_FROM_DEVICE);
 			dev_kfree_skb(rp->rx_skbuff[i]);
@@ -1230,6 +1235,7 @@ static void alloc_tbufs(struct net_device* dev)
 static void free_tbufs(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	int i;
 
 	for (i = 0; i < TX_RING_SIZE; i++) {
@@ -1238,7 +1244,7 @@ static void free_tbufs(struct net_device* dev)
 		rp->tx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (rp->tx_skbuff[i]) {
 			if (rp->tx_skbuff_dma[i]) {
-				dma_unmap_single(&rp->pdev->dev,
+				dma_unmap_single(hwdev,
 						 rp->tx_skbuff_dma[i],
 						 rp->tx_skbuff[i]->len,
 						 DMA_TO_DEVICE);
@@ -1469,7 +1475,7 @@ static void init_registers(struct net_device *dev)
 
 	rhine_set_rx_mode(dev);
 
-	if (rp->pdev->revision >= VT6105M)
+	if (rp->revision >= VT6105M)
 		rhine_init_cam_filter(dev);
 
 	napi_enable(&rp->napi);
@@ -1581,16 +1587,15 @@ static int rhine_open(struct net_device *dev)
 	void __iomem *ioaddr = rp->base;
 	int rc;
 
-	rc = request_irq(rp->pdev->irq, rhine_interrupt, IRQF_SHARED, dev->name,
-			dev);
+	rc = request_irq(rp->irq, rhine_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc)
 		return rc;
 
-	netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp->pdev->irq);
+	netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp->irq);
 
 	rc = alloc_ring(dev);
 	if (rc) {
-		free_irq(rp->pdev->irq, dev);
+		free_irq(rp->irq, dev);
 		return rc;
 	}
 	alloc_rbufs(dev);
@@ -1659,6 +1664,7 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 				  struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	void __iomem *ioaddr = rp->base;
 	unsigned entry;
 
@@ -1695,9 +1701,9 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 						       rp->tx_bufs));
 	} else {
 		rp->tx_skbuff_dma[entry] =
-			dma_map_single(&rp->pdev->dev, skb->data, skb->len,
+			dma_map_single(hwdev, skb->data, skb->len,
 				       DMA_TO_DEVICE);
-		if (dma_mapping_error(&rp->pdev->dev, rp->tx_skbuff_dma[entry])) {
+		if (dma_mapping_error(hwdev, rp->tx_skbuff_dma[entry])) {
 			dev_kfree_skb(skb);
 			rp->tx_skbuff_dma[entry] = 0;
 			dev->stats.tx_dropped++;
@@ -1788,6 +1794,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 static void rhine_tx(struct net_device *dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	int txstatus = 0, entry = rp->dirty_tx % TX_RING_SIZE;
 
 	/* find and cleanup dirty tx descriptors */
@@ -1831,7 +1838,7 @@ static void rhine_tx(struct net_device *dev)
 		}
 		/* Free the original skb. */
 		if (rp->tx_skbuff_dma[entry]) {
-			dma_unmap_single(&rp->pdev->dev,
+			dma_unmap_single(hwdev,
 					 rp->tx_skbuff_dma[entry],
 					 rp->tx_skbuff[entry]->len,
 					 DMA_TO_DEVICE);
@@ -1863,6 +1870,7 @@ static inline u16 rhine_get_vlan_tci(struct sk_buff *skb, int data_size)
 static int rhine_rx(struct net_device *dev, int limit)
 {
 	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 	int count;
 	int entry = rp->cur_rx % RX_RING_SIZE;
 
@@ -1924,7 +1932,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 			if (pkt_len < rx_copybreak)
 				skb = netdev_alloc_skb_ip_align(dev, pkt_len);
 			if (skb) {
-				dma_sync_single_for_cpu(&rp->pdev->dev,
+				dma_sync_single_for_cpu(hwdev,
 							    rp->rx_skbuff_dma[entry],
 							    rp->rx_buf_sz,
 							    DMA_FROM_DEVICE);
@@ -1933,7 +1941,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 						 rp->rx_skbuff[entry]->data,
 						 pkt_len);
 				skb_put(skb, pkt_len);
-				dma_sync_single_for_device(&rp->pdev->dev,
+				dma_sync_single_for_device(hwdev,
 							       rp->rx_skbuff_dma[entry],
 							       rp->rx_buf_sz,
 							       DMA_FROM_DEVICE);
@@ -1945,7 +1953,7 @@ static int rhine_rx(struct net_device *dev, int limit)
 				}
 				rp->rx_skbuff[entry] = NULL;
 				skb_put(skb, pkt_len);
-				dma_unmap_single(&rp->pdev->dev,
+				dma_unmap_single(hwdev,
 						 rp->rx_skbuff_dma[entry],
 						 rp->rx_buf_sz,
 						 DMA_FROM_DEVICE);
@@ -1979,10 +1987,11 @@ static int rhine_rx(struct net_device *dev, int limit)
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			rp->rx_skbuff_dma[entry] =
-				dma_map_single(&rp->pdev->dev, skb->data,
+				dma_map_single(hwdev, skb->data,
 					       rp->rx_buf_sz,
 					       DMA_FROM_DEVICE);
-			if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[entry])) {
+			if (dma_mapping_error(hwdev,
+					      rp->rx_skbuff_dma[entry])) {
 				dev_kfree_skb(skb);
 				rp->rx_skbuff_dma[entry] = 0;
 				break;
@@ -2103,7 +2112,7 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		/* Too many to match, or accept all multicasts. */
 		iowrite32(0xffffffff, ioaddr + MulticastFilter0);
 		iowrite32(0xffffffff, ioaddr + MulticastFilter1);
-	} else if (rp->pdev->revision >= VT6105M) {
+	} else if (rp->revision >= VT6105M) {
 		int i = 0;
 		u32 mCAMmask = 0;	/* 32 mCAMs (6105M and better) */
 		netdev_for_each_mc_addr(ha, dev) {
@@ -2125,7 +2134,7 @@ static void rhine_set_rx_mode(struct net_device *dev)
 		iowrite32(mc_filter[1], ioaddr + MulticastFilter1);
 	}
 	/* enable/disable VLAN receive filtering */
-	if (rp->pdev->revision >= VT6105M) {
+	if (rp->revision >= VT6105M) {
 		if (dev->flags & IFF_PROMISC)
 			BYTE_REG_BITS_OFF(BCR1_VIDFR, ioaddr + PCIBusConfig1);
 		else
@@ -2136,11 +2145,11 @@ static void rhine_set_rx_mode(struct net_device *dev)
 
 static void netdev_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct rhine_private *rp = netdev_priv(dev);
+	struct device *hwdev = dev->dev.parent;
 
 	strlcpy(info->driver, DRV_NAME, sizeof(info->driver));
 	strlcpy(info->version, DRV_VERSION, sizeof(info->version));
-	strlcpy(info->bus_info, pci_name(rp->pdev), sizeof(info->bus_info));
+	strlcpy(info->bus_info, dev_name(hwdev), sizeof(info->bus_info));
 }
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -2277,7 +2286,7 @@ static int rhine_close(struct net_device *dev)
 	/* Stop the chip's Tx and Rx processes. */
 	iowrite16(CmdStop, ioaddr + ChipCmd);
 
-	free_irq(rp->pdev->irq, dev);
+	free_irq(rp->irq, dev);
 	free_rbufs(dev);
 	free_tbufs(dev);
 	free_ring(dev);
@@ -2354,8 +2363,7 @@ static void rhine_shutdown (struct pci_dev *pdev)
 #ifdef CONFIG_PM_SLEEP
 static int rhine_suspend(struct device *device)
 {
-	struct pci_dev *pdev = to_pci_dev(device);
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = dev_get_drvdata(device);
 	struct rhine_private *rp = netdev_priv(dev);
 
 	if (!netif_running(dev))
@@ -2367,15 +2375,15 @@ static int rhine_suspend(struct device *device)
 
 	netif_device_detach(dev);
 
-	rhine_shutdown(pdev);
+	if (!strncmp(device->bus->name, "pci", 3))
+		rhine_shutdown(to_pci_dev(device));
 
 	return 0;
 }
 
 static int rhine_resume(struct device *device)
 {
-	struct pci_dev *pdev = to_pci_dev(device);
-	struct net_device *dev = pci_get_drvdata(pdev);
+	struct net_device *dev = dev_get_drvdata(device);
 	struct rhine_private *rp = netdev_priv(dev);
 
 	if (!netif_running(dev))
-- 
1.8.5.1
