From: Dariusz Marcinkiewicz <reksio@newterm.pl>
Subject: [PATCH 1/2] net: ec_bhf: remove excessive debug messages
Date: Fri, 15 Aug 2014 17:49:41 +0200
Message-ID: <20140815154941.GA16632@newterm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This cuts down on the number of debug information spit out by
the driver. Some of the potentially useful debug info gets exposed
by debugfs.

Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>
---
 drivers/net/ethernet/ec_bhf.c |  185 ++++++++++++++++++++++-------------------
 1 file changed, 99 insertions(+), 86 deletions(-)

diff --git a/drivers/net/ethernet/ec_bhf.c b/drivers/net/ethernet/ec_bhf.c
index 056b44b..935db19 100644
--- a/drivers/net/ethernet/ec_bhf.c
+++ b/drivers/net/ethernet/ec_bhf.c
@@ -1,5 +1,5 @@
  /*
- * drivers/net/ethernet/beckhoff/ec_bhf.c
+ * drivers/net/ethernet/ec_bhf.c
  *
  * Copyright (C) 2014 Darek Marcinkiewicz <reksio@newterm.pl>
  *
@@ -18,14 +18,12 @@
  * Those can be found on Bechhoff CX50xx industrial PCs.
  */
 
-#if 0
-#define DEBUG
-#endif
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
 #include <linux/pci.h>
 #include <linux/init.h>
+#include <linux/debugfs.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -131,9 +129,10 @@ struct bhf_dma {
 
 struct ec_bhf_priv {
 	struct net_device *net_dev;
-
 	struct pci_dev *dev;
 
+	struct dentry *root;
+
 	void __iomem *io;
 	void __iomem *dma_io;
 
@@ -164,29 +163,45 @@ struct ec_bhf_priv {
 
 #define ETHERCAT_MASTER_ID	0x14
 
-static void ec_bhf_print_status(struct ec_bhf_priv *priv)
-{
-	struct device *dev = PRIV_TO_DEV(priv);
+static struct debugfs_reg32 ec_bhf_debugfs_mii_regs[] = {
+	{
+		.name = "link-status",
+		.offset = MII_LINK_STATUS
+	}
+};
 
-	dev_dbg(dev, "Frame error counter: %d\n",
-		ioread8(priv->mac_io + MAC_FRAME_ERR_CNT));
-	dev_dbg(dev, "RX error counter: %d\n",
-		ioread8(priv->mac_io + MAC_RX_ERR_CNT));
-	dev_dbg(dev, "CRC error counter: %d\n",
-		ioread8(priv->mac_io + MAC_CRC_ERR_CNT));
-	dev_dbg(dev, "TX frame counter: %d\n",
-		ioread32(priv->mac_io + MAC_TX_FRAME_CNT));
-	dev_dbg(dev, "RX frame counter: %d\n",
-		ioread32(priv->mac_io + MAC_RX_FRAME_CNT));
-	dev_dbg(dev, "TX fifo level: %d\n",
-		ioread8(priv->mac_io + MAC_TX_FIFO_LVL));
-	dev_dbg(dev, "Dropped frames: %d\n",
-		ioread8(priv->mac_io + MAC_DROPPED_FRMS));
-	dev_dbg(dev, "Connected with CCAT slot: %d\n",
-		ioread8(priv->mac_io + MAC_CONNECTED_CCAT_FLAG));
-	dev_dbg(dev, "Link status: %d\n",
-		ioread8(priv->mii_io + MII_LINK_STATUS));
-}
+static struct debugfs_regset32 ec_bhf_debugfs_mii_regset = {
+	.regs = ec_bhf_debugfs_mii_regs,
+	.nregs = ARRAY_SIZE(ec_bhf_debugfs_mii_regs)
+};
+
+static struct debugfs_reg32 ec_bhf_debugfs_fifo_regs[] = {
+	{
+		.name = "fifo-tx",
+		.offset = FIFO_TX_REG
+	},
+	{
+		.name = "fifo-rx",
+		.offset = FIFO_RX_REG
+	}
+};
+
+static struct debugfs_regset32 ec_bhf_debugfs_fifo_regset = {
+	.regs = ec_bhf_debugfs_fifo_regs,
+	.nregs = ARRAY_SIZE(ec_bhf_debugfs_fifo_regs)
+};
+
+static struct debugfs_reg32 ec_bhf_debugfs_mac_regs[] = {
+	{
+		.name = "fifo-level",
+		.offset = MAC_TX_FIFO_LVL
+	},
+};
+
+static struct debugfs_regset32 ec_bhf_debugfs_mac_regset = {
+	.regs = ec_bhf_debugfs_mac_regs,
+	.nregs = ARRAY_SIZE(ec_bhf_debugfs_mac_regs)
+};
 
 static void ec_bhf_reset(struct ec_bhf_priv *priv)
 {
@@ -210,8 +225,6 @@ static void ec_bhf_send_packet(struct ec_bhf_priv *priv, struct tx_desc *desc)
 	u32 addr = (u8 *)desc - priv->tx_buf.buf;
 
 	iowrite32((ALIGN(len, 8) << 24) | addr, priv->fifo_io + FIFO_TX_REG);
-
-	dev_dbg(PRIV_TO_DEV(priv), "Done sending packet\n");
 }
 
 static int ec_bhf_desc_sent(struct tx_desc *desc)
@@ -244,7 +257,6 @@ static void ec_bhf_add_rx_desc(struct ec_bhf_priv *priv, struct rx_desc *desc)
 static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
 {
 	struct rx_desc *desc = &priv->rx_descs[priv->rx_dnext];
-	struct device *dev = PRIV_TO_DEV(priv);
 
 	while (ec_bhf_pkt_received(desc)) {
 		int pkt_size = (le16_to_cpu(desc->header.len) &
@@ -253,20 +265,16 @@ static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
 		struct sk_buff *skb;
 
 		skb = netdev_alloc_skb_ip_align(priv->net_dev, pkt_size);
-		dev_dbg(dev, "Received packet, size: %d\n", pkt_size);
-
 		if (skb) {
 			memcpy(skb_put(skb, pkt_size), data, pkt_size);
 			skb->protocol = eth_type_trans(skb, priv->net_dev);
-			dev_dbg(dev, "Protocol type: %x\n", skb->protocol);
-
 			priv->stat_rx_bytes += pkt_size;
 
 			netif_rx(skb);
 		} else {
-			dev_err_ratelimited(dev,
-				"Couldn't allocate a skb_buff for a packet of size %u\n",
-				pkt_size);
+			dev_err_ratelimited(PRIV_TO_DEV(priv),
+					    "Couldn't allocate a skb_buff for a packet of size %u\n",
+					    pkt_size);
 		}
 
 		desc->header.recv = 0;
@@ -276,7 +284,6 @@ static void ec_bhf_process_rx(struct ec_bhf_priv *priv)
 		priv->rx_dnext = (priv->rx_dnext + 1) % priv->rx_dcount;
 		desc = &priv->rx_descs[priv->rx_dnext];
 	}
-
 }
 
 static enum hrtimer_restart ec_bhf_timer_fun(struct hrtimer *timer)
@@ -299,14 +306,7 @@ static int ec_bhf_setup_offsets(struct ec_bhf_priv *priv)
 	unsigned block_count, i;
 	void __iomem *ec_info;
 
-	dev_dbg(dev, "Info block:\n");
-	dev_dbg(dev, "Type of function: %x\n", (unsigned)ioread16(priv->io));
-	dev_dbg(dev, "Revision of function: %x\n",
-		(unsigned)ioread16(priv->io + INFO_BLOCK_REV));
-
 	block_count = ioread8(priv->io + INFO_BLOCK_BLK_CNT);
-	dev_dbg(dev, "Number of function blocks: %x\n", block_count);
-
 	for (i = 0; i < block_count; i++) {
 		u16 type = ioread16(priv->io + i * INFO_BLOCK_SIZE +
 				    INFO_BLOCK_TYPE);
@@ -317,28 +317,20 @@ static int ec_bhf_setup_offsets(struct ec_bhf_priv *priv)
 		dev_err(dev, "EtherCAT master with DMA block not found\n");
 		return -ENODEV;
 	}
-	dev_dbg(dev, "EtherCAT master with DMA block found at pos: %d\n", i);
 
 	ec_info = priv->io + i * INFO_BLOCK_SIZE;
-	dev_dbg(dev, "EtherCAT master revision: %d\n",
-		ioread16(ec_info + INFO_BLOCK_REV));
 
 	priv->tx_dma_chan = ioread8(ec_info + INFO_BLOCK_TX_CHAN);
-	dev_dbg(dev, "EtherCAT master tx dma channel: %d\n",
-		priv->tx_dma_chan);
-
 	priv->rx_dma_chan = ioread8(ec_info + INFO_BLOCK_RX_CHAN);
-	dev_dbg(dev, "EtherCAT master rx dma channel: %d\n",
-		 priv->rx_dma_chan);
 
 	priv->ec_io = priv->io + ioread32(ec_info + INFO_BLOCK_OFFSET);
 	priv->mii_io = priv->ec_io + ioread32(priv->ec_io + EC_MII_OFFSET);
 	priv->fifo_io = priv->ec_io + ioread32(priv->ec_io + EC_FIFO_OFFSET);
 	priv->mac_io = priv->ec_io + ioread32(priv->ec_io + EC_MAC_OFFSET);
 
-	dev_dbg(dev,
-		"EtherCAT block addres: %p, fifo address: %p, mii address: %p, mac address: %p\n",
-		priv->ec_io, priv->fifo_io, priv->mii_io, priv->mac_io);
+	ec_bhf_debugfs_fifo_regset.base = priv->fifo_io;
+	ec_bhf_debugfs_mii_regset.base = priv->mii_io;
+	ec_bhf_debugfs_mac_regset.base = priv->mac_io;
 
 	return 0;
 }
@@ -350,8 +342,6 @@ static netdev_tx_t ec_bhf_start_xmit(struct sk_buff *skb,
 	struct tx_desc *desc;
 	unsigned len;
 
-	dev_dbg(PRIV_TO_DEV(priv), "Starting xmit\n");
-
 	desc = &priv->tx_descs[priv->tx_dnext];
 
 	skb_copy_and_csum_dev(skb, desc->data);
@@ -366,15 +356,12 @@ static netdev_tx_t ec_bhf_start_xmit(struct sk_buff *skb,
 	priv->tx_dnext = (priv->tx_dnext + 1) % priv->tx_dcount;
 
 	if (!ec_bhf_desc_sent(&priv->tx_descs[priv->tx_dnext])) {
-		/* Make sure that update updates to tx_dnext are perceived
+		/* Make sure that updates to tx_dnext are perceived
 		 * by timer routine.
 		 */
 		smp_wmb();
 
 		netif_stop_queue(net_dev);
-
-		dev_dbg(PRIV_TO_DEV(priv), "Stopping netif queue\n");
-		ec_bhf_print_status(priv);
 	}
 
 	priv->stat_tx_bytes += len;
@@ -397,7 +384,6 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 
 	mask = ioread32(priv->dma_io + offset);
 	mask &= DMA_WINDOW_SIZE_MASK;
-	dev_dbg(dev, "Read mask %x for channel %d\n", mask, channel);
 
 	/* We want to allocate a chunk of memory that is:
 	 * - aligned to the mask we just read
@@ -408,12 +394,10 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 	buf->len = min_t(int, ~mask + 1, size);
 	buf->alloc_len = 2 * buf->len;
 
-	dev_dbg(dev, "Allocating %d bytes for channel %d",
-		(int)buf->alloc_len, channel);
 	buf->alloc = dma_alloc_coherent(dev, buf->alloc_len, &buf->alloc_phys,
 					GFP_KERNEL);
 	if (buf->alloc == NULL) {
-		dev_info(dev, "Failed to allocate buffer\n");
+		dev_err(dev, "Failed to allocate buffer\n");
 		return -ENOMEM;
 	}
 
@@ -422,8 +406,6 @@ static int ec_bhf_alloc_dma_mem(struct ec_bhf_priv *priv,
 
 	iowrite32(0, priv->dma_io + offset + 4);
 	iowrite32(buf->buf_phys, priv->dma_io + offset);
-	dev_dbg(dev, "Buffer: %x and read from dev: %x",
-		(unsigned)buf->buf_phys, ioread32(priv->dma_io + offset));
 
 	return 0;
 }
@@ -433,7 +415,7 @@ static void ec_bhf_setup_tx_descs(struct ec_bhf_priv *priv)
 	int i = 0;
 
 	priv->tx_dcount = priv->tx_buf.len / sizeof(struct tx_desc);
-	priv->tx_descs = (struct tx_desc *) priv->tx_buf.buf;
+	priv->tx_descs = (struct tx_desc *)priv->tx_buf.buf;
 	priv->tx_dnext = 0;
 
 	for (i = 0; i < priv->tx_dcount; i++)
@@ -445,7 +427,7 @@ static void ec_bhf_setup_rx_descs(struct ec_bhf_priv *priv)
 	int i;
 
 	priv->rx_dcount = priv->rx_buf.len / sizeof(struct rx_desc);
-	priv->rx_descs = (struct rx_desc *) priv->rx_buf.buf;
+	priv->rx_descs = (struct rx_desc *)priv->rx_buf.buf;
 	priv->rx_dnext = 0;
 
 	for (i = 0; i < priv->rx_dcount; i++) {
@@ -469,8 +451,6 @@ static int ec_bhf_open(struct net_device *net_dev)
 	struct device *dev = PRIV_TO_DEV(priv);
 	int err = 0;
 
-	dev_info(dev, "Opening device\n");
-
 	ec_bhf_reset(priv);
 
 	err = ec_bhf_alloc_dma_mem(priv, &priv->rx_buf, priv->rx_dma_chan,
@@ -481,20 +461,13 @@ static int ec_bhf_open(struct net_device *net_dev)
 	}
 	ec_bhf_setup_rx_descs(priv);
 
-	dev_info(dev, "RX buffer allocated, address: %x\n",
-		 (unsigned)priv->rx_buf.buf_phys);
-
 	err = ec_bhf_alloc_dma_mem(priv, &priv->tx_buf, priv->tx_dma_chan,
 				   FIFO_SIZE * sizeof(struct tx_desc));
 	if (err) {
 		dev_err(dev, "Failed to allocate tx buffer\n");
 		goto error_rx_free;
 	}
-	dev_dbg(dev, "TX buffer allocated, addres: %x\n",
-		(unsigned)priv->tx_buf.buf_phys);
-
 	iowrite8(0, priv->mii_io + MII_MAC_FILT_FLAG);
-
 	ec_bhf_setup_tx_descs(priv);
 
 	netif_start_queue(net_dev);
@@ -504,10 +477,6 @@ static int ec_bhf_open(struct net_device *net_dev)
 	hrtimer_start(&priv->hrtimer, ktime_set(0, polling_frequency),
 		      HRTIMER_MODE_REL);
 
-	dev_info(PRIV_TO_DEV(priv), "Device open\n");
-
-	ec_bhf_print_status(priv);
-
 	return 0;
 
 error_rx_free:
@@ -536,6 +505,45 @@ static int ec_bhf_stop(struct net_device *net_dev)
 	return 0;
 }
 
+static int ec_bhf_init_debugfs(struct ec_bhf_priv *priv)
+{
+	struct dentry *root;
+	int err;
+
+	root = debugfs_create_dir("ec_bhf", NULL);
+	if (root == ERR_PTR(-ENODEV))
+		return 0;
+	if (root == NULL)
+		return -ENOMEM;
+
+	if (!debugfs_create_regset32("mii", S_IRUGO, root,
+				     &ec_bhf_debugfs_mii_regset)) {
+		err = -ENOMEM;
+		goto err_free_dir;
+	}
+
+	if (!debugfs_create_regset32("fifo", S_IRUGO, root,
+				     &ec_bhf_debugfs_fifo_regset)) {
+		err = -ENOMEM;
+		goto err_free_dir;
+	}
+
+	if (!debugfs_create_regset32("mac", S_IRUGO, root,
+				     &ec_bhf_debugfs_mac_regset)) {
+		err = -ENOMEM;
+		goto err_free_dir;
+	}
+
+	priv->root = root;
+
+	return 0;
+
+err_free_dir:
+	debugfs_remove_recursive(root);
+
+	return err;
+}
+
 static struct rtnl_link_stats64 *
 ec_bhf_get_stats(struct net_device *net_dev,
 		 struct rtnl_link_stats64 *stats)
@@ -640,15 +648,18 @@ static int ec_bhf_probe(struct pci_dev *dev, const struct pci_device_id *id)
 
 	memcpy_fromio(net_dev->dev_addr, priv->mii_io + MII_MAC_ADDR, 6);
 
-	dev_dbg(&dev->dev, "CX5020 Ethercat master address: %pM\n",
-		net_dev->dev_addr);
-
 	err = register_netdev(net_dev);
 	if (err < 0)
 		goto err_free_net_dev;
 
+	err = ec_bhf_init_debugfs(priv);
+	if (err < 0)
+		goto err_unregister_netdev;
+
 	return 0;
 
+err_unregister_netdev:
+	unregister_netdev(net_dev);
 err_free_net_dev:
 	free_netdev(net_dev);
 err_unmap_dma_io:
@@ -669,6 +680,8 @@ static void ec_bhf_remove(struct pci_dev *dev)
 	struct net_device *net_dev = pci_get_drvdata(dev);
 	struct ec_bhf_priv *priv = netdev_priv(net_dev);
 
+	debugfs_remove_recursive(priv->root);
+
 	unregister_netdev(net_dev);
 	free_netdev(net_dev);
 
-- 
1.7.10.4
