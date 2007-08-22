From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [01/10] pasemi_mac: Abstract out register access
Date: Wed, 22 Aug 2007 09:12:44 -0500
Message-ID: <20070822141244.GB16830@lixom.net>
References: <20070817205413.548020000@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline; filename=pasemi_mac-regaccess
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Abstract out the PCI config read/write accesses into reg read/write ones,
still calling the pci accessors on the back end.

Signed-off-by: Olof Johansson <olof@lixom.net>


Index: mainline/drivers/net/pasemi_mac.c
===================================================================
--- mainline.orig/drivers/net/pasemi_mac.c
+++ mainline/drivers/net/pasemi_mac.c
@@ -81,6 +81,48 @@ MODULE_PARM_DESC(debug, "PA Semi MAC bit
 
 static struct pasdma_status *dma_status;
 
+static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
+{
+	unsigned int val;
+
+	pci_read_config_dword(mac->iob_pdev, reg, &val);
+	return val;
+}
+
+static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
+			  unsigned int val)
+{
+	pci_write_config_dword(mac->iob_pdev, reg, val);
+}
+
+static unsigned int read_mac_reg(struct pasemi_mac *mac, unsigned int reg)
+{
+	unsigned int val;
+
+	pci_read_config_dword(mac->pdev, reg, &val);
+	return val;
+}
+
+static void write_mac_reg(struct pasemi_mac *mac, unsigned int reg,
+			  unsigned int val)
+{
+	pci_write_config_dword(mac->pdev, reg, val);
+}
+
+static unsigned int read_dma_reg(struct pasemi_mac *mac, unsigned int reg)
+{
+	unsigned int val;
+
+	pci_read_config_dword(mac->dma_pdev, reg, &val);
+	return val;
+}
+
+static void write_dma_reg(struct pasemi_mac *mac, unsigned int reg,
+			  unsigned int val)
+{
+	pci_write_config_dword(mac->dma_pdev, reg, val);
+}
+
 static int pasemi_get_mac_addr(struct pasemi_mac *mac)
 {
 	struct pci_dev *pdev = mac->pdev;
@@ -166,22 +208,21 @@ static int pasemi_mac_setup_rx_resources
 
 	memset(ring->buffers, 0, RX_RING_SIZE * sizeof(u64));
 
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEL(chan_id),
-			       PAS_DMA_RXCHAN_BASEL_BRBL(ring->dma));
+	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEL(chan_id), PAS_DMA_RXCHAN_BASEL_BRBL(ring->dma));
+
+	write_dma_reg(mac, PAS_DMA_RXCHAN_BASEU(chan_id),
+			   PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
+			   PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 2));
+
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CFG(chan_id),
+			   PAS_DMA_RXCHAN_CFG_HBU(1));
 
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_BASEU(chan_id),
-			       PAS_DMA_RXCHAN_BASEU_BRBH(ring->dma >> 32) |
-			       PAS_DMA_RXCHAN_BASEU_SIZ(RX_RING_SIZE >> 2));
-
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXCHAN_CFG(chan_id),
-			       PAS_DMA_RXCHAN_CFG_HBU(1));
-
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEL(mac->dma_if),
-			       PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
-
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_RXINT_BASEU(mac->dma_if),
-			       PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
-			       PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
+	write_dma_reg(mac, PAS_DMA_RXINT_BASEL(mac->dma_if),
+			   PAS_DMA_RXINT_BASEL_BRBL(__pa(ring->buffers)));
+
+	write_dma_reg(mac, PAS_DMA_RXINT_BASEU(mac->dma_if),
+			   PAS_DMA_RXINT_BASEU_BRBH(__pa(ring->buffers) >> 32) |
+			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -233,18 +274,18 @@ static int pasemi_mac_setup_tx_resources
 
 	memset(ring->desc, 0, TX_RING_SIZE * sizeof(struct pas_dma_xct_descr));
 
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEL(chan_id),
-			       PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
+	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEL(chan_id),
+			   PAS_DMA_TXCHAN_BASEL_BRBL(ring->dma));
 	val = PAS_DMA_TXCHAN_BASEU_BRBH(ring->dma >> 32);
 	val |= PAS_DMA_TXCHAN_BASEU_SIZ(TX_RING_SIZE >> 2);
 
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_BASEU(chan_id), val);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_BASEU(chan_id), val);
 
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_TXCHAN_CFG(chan_id),
-			       PAS_DMA_TXCHAN_CFG_TY_IFACE |
-			       PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
-			       PAS_DMA_TXCHAN_CFG_UP |
-			       PAS_DMA_TXCHAN_CFG_WT(2));
+	write_dma_reg(mac, PAS_DMA_TXCHAN_CFG(chan_id),
+			   PAS_DMA_TXCHAN_CFG_TY_IFACE |
+			   PAS_DMA_TXCHAN_CFG_TATTR(mac->dma_if) |
+			   PAS_DMA_TXCHAN_CFG_UP |
+			   PAS_DMA_TXCHAN_CFG_WT(2));
 
 	ring->next_to_use = 0;
 	ring->next_to_clean = 0;
@@ -383,12 +424,8 @@ static void pasemi_mac_replenish_rx_ring
 
 	wmb();
 
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXCHAN_INCR(mac->dma_rxch),
-			       limit - count);
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXINT_INCR(mac->dma_if),
-			       limit - count);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), limit - count);
+	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), limit - count);
 
 	mac->rx->next_to_fill += limit - count;
 }
@@ -404,9 +441,7 @@ static void pasemi_mac_restart_rx_intr(s
 
 	reg = PAS_IOB_DMA_RXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_RXCH_RESET_PINTC;
 
-	pci_write_config_dword(mac->iob_pdev,
-			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch),
-			       reg);
+	write_iob_reg(mac, PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
 }
 
 static void pasemi_mac_restart_tx_intr(struct pasemi_mac *mac)
@@ -418,8 +453,7 @@ static void pasemi_mac_restart_tx_intr(s
 
 	reg = PAS_IOB_DMA_TXCH_RESET_PCNT(pcnt) | PAS_IOB_DMA_TXCH_RESET_PINTC;
 
-	pci_write_config_dword(mac->iob_pdev,
-			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
+	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
 }
 
 
@@ -574,8 +608,6 @@ static irqreturn_t pasemi_mac_rx_intr(in
 	 * all others.
 	 */
 
-	pci_read_config_dword(mac->dma_pdev, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), &reg);
-
 	reg = 0;
 	if (*mac->rx_status & PAS_STATUS_SOFT)
 		reg |= PAS_IOB_DMA_RXCH_RESET_SINTC;
@@ -586,9 +618,7 @@ static irqreturn_t pasemi_mac_rx_intr(in
 
 	netif_rx_schedule(dev);
 
-	pci_write_config_dword(mac->iob_pdev,
-			       PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
-
+	write_iob_reg(mac, PAS_IOB_DMA_RXCH_RESET(mac->dma_rxch), reg);
 
 	return IRQ_HANDLED;
 }
@@ -613,9 +643,7 @@ static irqreturn_t pasemi_mac_tx_intr(in
 	if (*mac->tx_status & PAS_STATUS_ERROR)
 		reg |= PAS_IOB_DMA_TXCH_RESET_DINTC;
 
-	pci_write_config_dword(mac->iob_pdev,
-			       PAS_IOB_DMA_TXCH_RESET(mac->dma_txch),
-			       reg);
+	write_iob_reg(mac, PAS_IOB_DMA_TXCH_RESET(mac->dma_txch), reg);
 
 	return IRQ_HANDLED;
 }
@@ -641,7 +669,7 @@ static void pasemi_adjust_link(struct ne
 	} else
 		netif_carrier_on(dev);
 
-	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
 	new_flags = flags & ~(PAS_MAC_CFG_PCFG_HD | PAS_MAC_CFG_PCFG_SPD_M |
 			      PAS_MAC_CFG_PCFG_TSR_M);
 
@@ -673,7 +701,7 @@ static void pasemi_adjust_link(struct ne
 	mac->link = mac->phydev->link;
 
 	if (new_flags != flags)
-		pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, new_flags);
+		write_mac_reg(mac, PAS_MAC_CFG_PCFG, new_flags);
 
 	if (msg && netif_msg_link(mac))
 		printk(KERN_INFO "%s: Link is up at %d Mbps, %s duplex.\n",
@@ -736,39 +764,37 @@ static int pasemi_mac_open(struct net_de
 	int ret;
 
 	/* enable rx section */
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_RXCMD,
-			       PAS_DMA_COM_RXCMD_EN);
+	write_dma_reg(mac, PAS_DMA_COM_RXCMD, PAS_DMA_COM_RXCMD_EN);
 
 	/* enable tx section */
-	pci_write_config_dword(mac->dma_pdev, PAS_DMA_COM_TXCMD,
-			       PAS_DMA_COM_TXCMD_EN);
+	write_dma_reg(mac, PAS_DMA_COM_TXCMD, PAS_DMA_COM_TXCMD_EN);
 
 	flags = PAS_MAC_CFG_TXP_FCE | PAS_MAC_CFG_TXP_FPC(3) |
 		PAS_MAC_CFG_TXP_SL(3) | PAS_MAC_CFG_TXP_COB(0xf) |
 		PAS_MAC_CFG_TXP_TIFT(8) | PAS_MAC_CFG_TXP_TIFG(12);
 
-	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_TXP, flags);
+	write_mac_reg(mac, PAS_MAC_CFG_TXP, flags);
 
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
 
 	flags |= PAS_MAC_CFG_PCFG_TSR_1G | PAS_MAC_CFG_PCFG_SPD_1G;
 
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
-			       PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
+	write_iob_reg(mac, PAS_IOB_DMA_RXCH_CFG(mac->dma_rxch),
+			   PAS_IOB_DMA_RXCH_CFG_CNTTH(0));
 
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
-			       PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
+	write_iob_reg(mac, PAS_IOB_DMA_TXCH_CFG(mac->dma_txch),
+			   PAS_IOB_DMA_TXCH_CFG_CNTTH(32));
 
 	/* Clear out any residual packet count state from firmware */
 	pasemi_mac_restart_rx_intr(mac);
 	pasemi_mac_restart_tx_intr(mac);
 
 	/* 0xffffff is max value, about 16ms */
-	pci_write_config_dword(mac->iob_pdev, PAS_IOB_DMA_COM_TIMEOUTCFG,
-			       PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
+	write_iob_reg(mac, PAS_IOB_DMA_COM_TIMEOUTCFG,
+			   PAS_IOB_DMA_COM_TIMEOUTCFG_TCNT(0xffffff));
 
-	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
 
 	ret = pasemi_mac_setup_rx_resources(dev);
 	if (ret)
@@ -778,25 +804,22 @@ static int pasemi_mac_open(struct net_de
 	if (ret)
 		goto out_tx_resources;
 
-	pci_write_config_dword(mac->pdev, PAS_MAC_IPC_CHNL,
-			       PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
-			       PAS_MAC_IPC_CHNL_BCH(mac->dma_rxch));
+	write_mac_reg(mac, PAS_MAC_IPC_CHNL,
+			   PAS_MAC_IPC_CHNL_DCHNO(mac->dma_rxch) |
+			   PAS_MAC_IPC_CHNL_BCH(mac->dma_rxch));
 
 	/* enable rx if */
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-			       PAS_DMA_RXINT_RCMDSTA_EN);
+	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
+			   PAS_DMA_RXINT_RCMDSTA_EN);
 
 	/* enable rx channel */
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
-			       PAS_DMA_RXCHAN_CCMDSTA_EN |
-			       PAS_DMA_RXCHAN_CCMDSTA_DU);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
+			   PAS_DMA_RXCHAN_CCMDSTA_EN |
+			   PAS_DMA_RXCHAN_CCMDSTA_DU);
 
 	/* enable tx channel */
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-			       PAS_DMA_TXCHAN_TCMDSTA_EN);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
+			   PAS_DMA_TXCHAN_TCMDSTA_EN);
 
 	pasemi_mac_replenish_rx_ring(dev);
 
@@ -875,20 +898,12 @@ static int pasemi_mac_close(struct net_d
 	pasemi_mac_clean_rx(mac, RX_RING_SIZE);
 
 	/* Disable interface */
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-			       PAS_DMA_TXCHAN_TCMDSTA_ST);
-	pci_write_config_dword(mac->dma_pdev,
-		      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-		      PAS_DMA_RXINT_RCMDSTA_ST);
-	pci_write_config_dword(mac->dma_pdev,
-		      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
-		      PAS_DMA_RXCHAN_CCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), PAS_DMA_TXCHAN_TCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), PAS_DMA_RXINT_RCMDSTA_ST);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), PAS_DMA_RXCHAN_CCMDSTA_ST);
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		pci_read_config_dword(mac->dma_pdev,
-				      PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch),
-				      &stat);
+		stat = read_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch));
 		if (!(stat & PAS_DMA_TXCHAN_TCMDSTA_ACT))
 			break;
 		cond_resched();
@@ -898,9 +913,7 @@ static int pasemi_mac_close(struct net_d
 		dev_err(&mac->dma_pdev->dev, "Failed to stop tx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		pci_read_config_dword(mac->dma_pdev,
-				      PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch),
-				      &stat);
+		stat = read_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch));
 		if (!(stat & PAS_DMA_RXCHAN_CCMDSTA_ACT))
 			break;
 		cond_resched();
@@ -910,9 +923,7 @@ static int pasemi_mac_close(struct net_d
 		dev_err(&mac->dma_pdev->dev, "Failed to stop rx channel\n");
 
 	for (retries = 0; retries < MAX_RETRIES; retries++) {
-		pci_read_config_dword(mac->dma_pdev,
-				      PAS_DMA_RXINT_RCMDSTA(mac->dma_if),
-				      &stat);
+		stat = read_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if));
 		if (!(stat & PAS_DMA_RXINT_RCMDSTA_ACT))
 			break;
 		cond_resched();
@@ -925,12 +936,9 @@ static int pasemi_mac_close(struct net_d
 	 * stopping, since you can't disable when active.
 	 */
 
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_TCMDSTA(mac->dma_txch), 0);
+	write_dma_reg(mac, PAS_DMA_RXCHAN_CCMDSTA(mac->dma_rxch), 0);
+	write_dma_reg(mac, PAS_DMA_RXINT_RCMDSTA(mac->dma_if), 0);
 
 	free_irq(mac->tx_irq, dev);
 	free_irq(mac->rx_irq, dev);
@@ -1011,8 +1019,7 @@ static int pasemi_mac_start_tx(struct sk
 
 	spin_unlock_irqrestore(&txring->lock, flags);
 
-	pci_write_config_dword(mac->dma_pdev,
-			       PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
+	write_dma_reg(mac, PAS_DMA_TXCHAN_INCR(mac->dma_txch), 1);
 
 	return NETDEV_TX_OK;
 
@@ -1035,7 +1042,7 @@ static void pasemi_mac_set_rx_mode(struc
 	struct pasemi_mac *mac = netdev_priv(dev);
 	unsigned int flags;
 
-	pci_read_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, &flags);
+	flags = read_mac_reg(mac, PAS_MAC_CFG_PCFG);
 
 	/* Set promiscuous */
 	if (dev->flags & IFF_PROMISC)
@@ -1043,7 +1050,7 @@ static void pasemi_mac_set_rx_mode(struc
 	else
 		flags &= ~PAS_MAC_CFG_PCFG_PR;
 
-	pci_write_config_dword(mac->pdev, PAS_MAC_CFG_PCFG, flags);
+	write_mac_reg(mac, PAS_MAC_CFG_PCFG, flags);
 }
 
 

--
