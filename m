From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/12) skge: use array for port irq masks
Date: Thu, 3 Mar 2005 11:38:25 -0800
Message-ID: <20050303113825.10fcc6dc@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use array to represent the transmit and recieve irqmask per port.
And rename txq to txqaddr to be more descriptive

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 17:39:20.000000000 -0800
+++ skge-2.6.11/drivers/net/skge.c	2005-03-03 09:40:43.000000000 -0800
@@ -107,8 +107,10 @@
 static void genesis_mac_init(struct skge_hw *hw, int port);
 static void genesis_reset(struct skge_hw *hw, int port);
 
-static const int txq[] = { Q_XA1, Q_XA2 };
-static const int rxq[] = { Q_R1, Q_R2 };
+static const int txqaddr[] = { Q_XA1, Q_XA2 };
+static const int rxqaddr[] = { Q_R1, Q_R2 };
+static const u32 rxirqmask[] = { IS_R1_F, IS_R2_F };
+static const u32 txirqmask[] = { IS_XA1_F, IS_XA2_F };
 
 /* Don't need to look at whole 16K.
  * last interesting register is descriptor poll timer.
@@ -568,11 +570,9 @@
 		do_div(delay, skge_freq(hw));
 		msk = skge_read32(hw, B2_IRQM_MSK);
 
-		if (((port == 0) && (msk & IS_R1_F)) ||
-		    ((port == 1) && (msk & IS_R2_F)))
+		if (msk & rxirqmask[port])
 			ecmd->rx_coalesce_usecs = delay;
-		if (((port == 0) && (msk & IS_XA1_F)) ||
-		    ((port == 1) && (msk & IS_XA1_F)))
+		if (msk & txirqmask[port])
 			ecmd->tx_coalesce_usecs = delay;
 	}
 
@@ -590,22 +590,22 @@
 	u32 delay = 25;
 
 	if (ecmd->rx_coalesce_usecs == 0)
-		msk &= ~(port == 0 ? IS_R1_F : IS_R2_F);
+		msk &= ~rxirqmask[port];
 	else if (ecmd->rx_coalesce_usecs < 25 ||
 		 ecmd->rx_coalesce_usecs > 33333)
 		return -EINVAL;
 	else {
-		msk |= port == 0 ? IS_R1_F : IS_R2_F;
+		msk |= rxirqmask[port];
 		delay = ecmd->rx_coalesce_usecs;
 	}
 
 	if (ecmd->tx_coalesce_usecs == 0)
-		msk &= ~((port == 0) ? IS_XA1_F : IS_XA2_F);
+		msk &= ~txirqmask[port];
 	else if (ecmd->tx_coalesce_usecs < 25 ||
 		 ecmd->tx_coalesce_usecs > 33333)
 		return -EINVAL;
 	else {
-		msk |= (port == 0) ? IS_XA1_F : IS_XA2_F;
+		msk |= txirqmask[port];
 		delay = min(delay, ecmd->rx_coalesce_usecs);
 	}
 
@@ -2174,16 +2174,16 @@
 	chunk = hw->ram_size / (isdualport(hw) ? 4 : 2);
 	ram_addr = hw->ram_offset + 2 * chunk * port;
 
-	skge_ramset(hw, rxq[port], ram_addr, chunk);
-	skge_qset(skge, rxq[port], skge->rx_ring.to_clean);
+	skge_ramset(hw, rxqaddr[port], ram_addr, chunk);
+	skge_qset(skge, rxqaddr[port], skge->rx_ring.to_clean);
 
 	BUG_ON(skge->tx_ring.to_use != skge->tx_ring.to_clean);
-	skge_ramset(hw, txq[port], ram_addr+chunk, chunk);
-	skge_qset(skge, txq[port], skge->tx_ring.to_use);
+	skge_ramset(hw, txqaddr[port], ram_addr+chunk, chunk);
+	skge_qset(skge, txqaddr[port], skge->tx_ring.to_use);
 
 	/* Start receiver BMU */
 	wmb();
-	skge_write8(hw, Q_ADDR(rxq[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
+	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
 
 	pr_debug("skge_up completed\n");
 	return 0;
@@ -2212,8 +2212,8 @@
 	del_timer_sync(&skge->link_check);
 
 	/* Stop transmitter */
-	skge_write8(hw, Q_ADDR(txq[port], Q_CSR), CSR_STOP);
-	skge_write32(hw, RB_ADDR(txq[port], RB_CTRL),
+	skge_write8(hw, Q_ADDR(txqaddr[port], Q_CSR), CSR_STOP);
+	skge_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL),
 		     RB_RST_SET|RB_DIS_OP_MD);
 
 	if (hw->chip_id == CHIP_ID_GENESIS)
@@ -2230,16 +2230,16 @@
 	skge_write32(hw, SKGEMAC_REG(port, TXA_LIM_INI), 0L);
 
 	/* Reset PCI FIFO */
-	skge_write32(hw, Q_ADDR(txq[port], Q_CSR), CSR_SET_RESET);
-	skge_write32(hw, RB_ADDR(txq[port], RB_CTRL), RB_RST_SET);
+	skge_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), CSR_SET_RESET);
+	skge_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);
 
 	/* Reset the RAM Buffer async Tx queue */
 	skge_write8(hw, RB_ADDR(port == 0 ? Q_XA1 : Q_XA2, RB_CTRL), RB_RST_SET);
 	/* stop receiver */
-	skge_write8(hw, Q_ADDR(rxq[port], Q_CSR), CSR_STOP);
+	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_STOP);
 	skge_write32(hw, RB_ADDR(port ? Q_R2 : Q_R1, RB_CTRL),
 		     RB_RST_SET|RB_DIS_OP_MD);
-	skge_write32(hw, Q_ADDR(rxq[port], Q_CSR), CSR_SET_RESET);
+	skge_write32(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_SET_RESET);
 
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		skge_write8(hw, SKGEMAC_REG(port, TX_MFF_CTRL2), MFF_RST_SET);
@@ -2348,7 +2348,7 @@
 	td->control = BMU_OWN | BMU_SW | BMU_STF | control | len;
 	wmb();
 
-	skge_write8(hw, Q_ADDR(txq[skge->port], Q_CSR), CSR_START);
+	skge_write8(hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_START);
 
 	if (netif_msg_tx_queued(skge))
 		printk(KERN_DEBUG "%s: tx queued, slot %d, len %d\n",
@@ -2406,7 +2406,7 @@
 	if (netif_msg_timer(skge))
 		printk(KERN_DEBUG PFX "%s: tx timeout\n", dev->name);
 
-	skge_write8(skge->hw, Q_ADDR(txq[skge->port], Q_CSR), CSR_STOP);
+	skge_write8(skge->hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_STOP);
 	skge_tx_clean(skge);
 }
 
@@ -2609,7 +2609,7 @@
 
 	/* restart receiver */
 	wmb();
-	skge_write8(hw, Q_ADDR(rxq[skge->port], Q_CSR),
+	skge_write8(hw, Q_ADDR(rxqaddr[skge->port], Q_CSR),
 		    CSR_START | CSR_IRQ_CL_F);
 
 	if (done) {
@@ -2650,7 +2650,7 @@
 		++skge->tx_avail;
 	}
 	ring->to_clean = e;
-	skge_write8(hw, Q_ADDR(txq[skge->port], Q_CSR), CSR_IRQ_CL_F);
+	skge_write8(hw, Q_ADDR(txqaddr[skge->port], Q_CSR), CSR_IRQ_CL_F);
 
 	if (skge->tx_avail > MAX_SKB_FRAGS + 1)
 		netif_wake_queue(dev);
