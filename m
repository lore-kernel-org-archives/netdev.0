From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 3/3] 8139cp: allocate statistics space only when needed
Date: Wed, 16 Mar 2005 15:04:33 -0800
Message-ID: <20050316150433.68cd8cf5@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Don't crash if ethtool statistics are requested and device is down.
Fix is to allocate pci space for statiistics only when needed.
No locking necessary because ethtool calls occur under RTNL semaphore.


Once again, not tested on real hardware, just making 8169 and 8139cp compatible;
needs blessing by someone with a real board.


diff -Nru a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c	2005-03-16 14:55:31 -08:00
+++ b/drivers/net/8139cp.c	2005-03-16 14:55:31 -08:00
@@ -1101,10 +1101,6 @@
 	cp->rx_ring = mem;
 	cp->tx_ring = &cp->rx_ring[CP_RX_RING_SIZE];
 
-	mem += (CP_RING_BYTES - CP_STATS_SIZE);
-	cp->nic_stats = mem;
-	cp->nic_stats_dma = cp->ring_dma + (CP_RING_BYTES - CP_STATS_SIZE);
-
 	return cp_init_rings(cp);
 }
 
@@ -1143,7 +1139,6 @@
 	pci_free_consistent(cp->pdev, CP_RING_BYTES, cp->rx_ring, cp->ring_dma);
 	cp->rx_ring = NULL;
 	cp->tx_ring = NULL;
-	cp->nic_stats = NULL;
 }
 
 static int cp_open (struct net_device *dev)
@@ -1472,14 +1467,17 @@
 				  struct ethtool_stats *estats, u64 *tmp_stats)
 {
 	struct cp_private *cp = netdev_priv(dev);
+	struct cp_dma_stats *nic_stats;
+	dma_addr_t dma;
 	int i;
 
-	memset(cp->nic_stats, 0, sizeof(struct cp_dma_stats));
+	nic_stats = pci_alloc_consistent(cp->pdev, sizeof(*nic_stats), &dma);
+	if (!nic_stats)
+		return;
 
 	/* begin NIC statistics dump */
-	cpw32(StatsAddr + 4, (cp->nic_stats_dma >> 16) >> 16);
-	cpw32(StatsAddr, (cp->nic_stats_dma & 0xffffffff) | DumpStats);
-	cpr32(StatsAddr);
+	cpw32(StatsAddr + 4, (u64)dma >> 32);
+	cpw32(StatsAddr, ((u64)dma & DMA_32BIT_MASK) | DumpStats);
 
 	for (i = 0; i < 1000; i++) {
 		if ((cpr32(StatsAddr) & DumpStats) == 0)
@@ -1490,21 +1488,23 @@
 	cpw32(StatsAddr + 4, 0);
 
 	i = 0;
-	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->tx_ok);
-	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->rx_ok);
-	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->tx_err);
-	tmp_stats[i++] = le32_to_cpu(cp->nic_stats->rx_err);
-	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->rx_fifo);
-	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->frame_align);
-	tmp_stats[i++] = le32_to_cpu(cp->nic_stats->tx_ok_1col);
-	tmp_stats[i++] = le32_to_cpu(cp->nic_stats->tx_ok_mcol);
-	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->rx_ok_phys);
-	tmp_stats[i++] = le64_to_cpu(cp->nic_stats->rx_ok_bcast);
-	tmp_stats[i++] = le32_to_cpu(cp->nic_stats->rx_ok_mcast);
-	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->tx_abort);
-	tmp_stats[i++] = le16_to_cpu(cp->nic_stats->tx_underrun);
+	tmp_stats[i++] = le64_to_cpu(nic_stats->tx_ok);
+	tmp_stats[i++] = le64_to_cpu(nic_stats->rx_ok);
+	tmp_stats[i++] = le64_to_cpu(nic_stats->tx_err);
+	tmp_stats[i++] = le32_to_cpu(nic_stats->rx_err);
+	tmp_stats[i++] = le16_to_cpu(nic_stats->rx_fifo);
+	tmp_stats[i++] = le16_to_cpu(nic_stats->frame_align);
+	tmp_stats[i++] = le32_to_cpu(nic_stats->tx_ok_1col);
+	tmp_stats[i++] = le32_to_cpu(nic_stats->tx_ok_mcol);
+	tmp_stats[i++] = le64_to_cpu(nic_stats->rx_ok_phys);
+	tmp_stats[i++] = le64_to_cpu(nic_stats->rx_ok_bcast);
+	tmp_stats[i++] = le32_to_cpu(nic_stats->rx_ok_mcast);
+	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_abort);
+	tmp_stats[i++] = le16_to_cpu(nic_stats->tx_underrun);
 	if (i != CP_NUM_STATS)
 		BUG();
+
+	pci_free_consistent(cp->pdev, sizeof(*nic_stats), nic_stats, dma);
 }
 
 static struct ethtool_ops cp_ethtool_ops = {
