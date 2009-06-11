From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Fix a race between sky2_down and sky2_poll
Date: Thu, 11 Jun 2009 10:04:48 -0700
Message-ID: <20090611100448.09a9b730@nehalam>
References: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49392 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752560AbZFKRFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 13:05:37 -0400
In-Reply-To: <392fb48f0906090703q66fbaf56wbf1157f90b97df0f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does the following fix the problem?
------------------------------
Subject: sky2: more careful shutdown

The code to shutdown hardware needs to be moer careful.
  * block napi from re-enabling
  * wait for status queue to drain before dropping rx (and tx) area
  * make sure no PCI posting bugs (synchronize does pci read)
  * add more reset pokes (from vendor sk98lin)

Rearrange exist tx/rx stop code for clarity

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-06-11 08:39:06.429163804 -0700
+++ b/drivers/net/sky2.c	2009-06-11 09:26:05.420060719 -0700
@@ -148,6 +148,7 @@ static const unsigned rxqaddr[] = { Q_R1
 static const u32 portirq_msk[] = { Y2_IS_PORT_1, Y2_IS_PORT_2 };
 
 static void sky2_set_multicast(struct net_device *dev);
+static void sky2_synchronize(struct sky2_hw *hw);
 
 /* Access to PHY via serial interconnect */
 static int gm_phy_write(struct sky2_hw *hw, unsigned port, u16 reg, u16 val)
@@ -1151,7 +1152,12 @@ stopped:
 
 	/* reset the Rx prefetch unit */
 	sky2_write32(hw, Y2_QADDR(rxq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
-	mmiowb();
+
+	/* Reset the RAM Buffer receive queue */
+	sky2_write8(hw, RB_ADDR(rxq, RB_CTRL), RB_RST_SET);
+
+	/* Reset Rx MAC FIFO */
+	sky2_write8(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), GMF_RST_SET);
 }
 
 /* Clean out receive buffer area, assumes receiver hardware stopped */
@@ -1792,6 +1798,51 @@ static void sky2_tx_complete(struct sky2
 		netif_wake_queue(dev);
 }
 
+/* Stop transmitter */
+static void sky2_tx_stop(struct sky2_port *sky2)
+{
+	struct sky2_hw *hw = sky2->hw;
+	unsigned port = sky2->port;
+	unsigned txq = txqaddr[port];
+	u16 ctrl;
+
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_STOP);
+	sky2_read32(hw, Q_ADDR(txq, Q_CSR));
+
+	sky2_write32(hw, RB_ADDR(txq, RB_CTRL), RB_RST_SET | RB_DIS_OP_MD);
+
+	ctrl = gma_read16(hw, port, GM_GP_CTRL);
+	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
+	gma_write16(hw, port, GM_GP_CTRL, ctrl);
+
+	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
+
+	/* Workaround shared GMAC reset */
+	if (!(hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0
+	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
+		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);
+
+	/* Disable Force Sync bit and Enable Alloc bit */
+	sky2_write8(hw, SK_REG(port, TXA_CTRL),
+		    TXA_DIS_FSYNC | TXA_DIS_ALLOC | TXA_STOP_RC);
+
+	/* Stop Interval Timer and Limit Counter of Tx Arbiter */
+	sky2_write32(hw, SK_REG(port, TXA_ITI_INI), 0L);
+	sky2_write32(hw, SK_REG(port, TXA_LIM_INI), 0L);
+
+	/* Reset the PCI FIFO of the async Tx queue */
+	sky2_write32(hw, Q_ADDR(txq, Q_CSR), BMU_RST_SET | BMU_FIFO_RST);
+
+	/* Reset the Tx prefetch units */
+	sky2_write32(hw, Y2_QADDR(txq, PREF_UNIT_CTRL), PREF_UNIT_RST_SET);
+
+	sky2_write32(hw, RB_ADDR(txq, RB_CTRL), RB_RST_SET);
+	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
+
+	/* set Pause Off */
+	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);
+}
+
 /* Cleanup all untransmitted buffers, assume transmitter not running */
 static void sky2_tx_clean(struct net_device *dev)
 {
@@ -1808,7 +1859,6 @@ static int sky2_down(struct net_device *
 	struct sky2_port *sky2 = netdev_priv(dev);
 	struct sky2_hw *hw = sky2->hw;
 	unsigned port = sky2->port;
-	u16 ctrl;
 	u32 imask;
 
 	/* Never really got started! */
@@ -1825,51 +1875,14 @@ static int sky2_down(struct net_device *
 
 	synchronize_irq(hw->pdev->irq);
 
-	sky2_gmac_reset(hw, port);
-
-	/* Stop transmitter */
-	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR), BMU_STOP);
-	sky2_read32(hw, Q_ADDR(txqaddr[port], Q_CSR));
-
-	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL),
-		     RB_RST_SET | RB_DIS_OP_MD);
-
-	ctrl = gma_read16(hw, port, GM_GP_CTRL);
-	ctrl &= ~(GM_GPCR_TX_ENA | GM_GPCR_RX_ENA);
-	gma_write16(hw, port, GM_GP_CTRL, ctrl);
-
-	/* Make sure no packets are pending */
-	napi_synchronize(&hw->napi);
-
-	sky2_write8(hw, SK_REG(port, GPHY_CTRL), GPC_RST_SET);
-
-	/* Workaround shared GMAC reset */
-	if (!(hw->chip_id == CHIP_ID_YUKON_XL && hw->chip_rev == 0
-	      && port == 0 && hw->dev[1] && netif_running(hw->dev[1])))
-		sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_RST_SET);
-
-	/* Disable Force Sync bit and Enable Alloc bit */
-	sky2_write8(hw, SK_REG(port, TXA_CTRL),
-		    TXA_DIS_FSYNC | TXA_DIS_ALLOC | TXA_STOP_RC);
-
-	/* Stop Interval Timer and Limit Counter of Tx Arbiter */
-	sky2_write32(hw, SK_REG(port, TXA_ITI_INI), 0L);
-	sky2_write32(hw, SK_REG(port, TXA_LIM_INI), 0L);
-
-	/* Reset the PCI FIFO of the async Tx queue */
-	sky2_write32(hw, Q_ADDR(txqaddr[port], Q_CSR),
-		     BMU_RST_SET | BMU_FIFO_RST);
-
-	/* Reset the Tx prefetch units */
-	sky2_write32(hw, Y2_QADDR(txqaddr[port], PREF_UNIT_CTRL),
-		     PREF_UNIT_RST_SET);
+	napi_disable(&hw->napi);
 
-	sky2_write32(hw, RB_ADDR(txqaddr[port], RB_CTRL), RB_RST_SET);
+	sky2_gmac_reset(hw, port);
 
+	sky2_tx_stop(sky2);
 	sky2_rx_stop(sky2);
 
-	sky2_write8(hw, SK_REG(port, RX_GMF_CTRL_T), GMF_RST_SET);
-	sky2_write8(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_RST_SET);
+	sky2_synchronize(hw);
 
 	sky2_phy_power_down(hw, port);
 
@@ -1894,6 +1907,8 @@ static int sky2_down(struct net_device *
 	sky2->rx_ring = NULL;
 	sky2->tx_ring = NULL;
 
+	napi_enable(&hw->napi);
+
 	return 0;
 }
 
@@ -2782,6 +2797,16 @@ done:
 	return work_done;
 }
 
+/* Process all pending status entries */
+static void sky2_synchronize(struct sky2_hw *hw)
+{
+	u16 idx;
+
+	while ((idx = sky2_read16(hw, STAT_PUT_IDX)) != hw->st_idx) {
+		sky2_status_intr(hw, NAPI_WEIGHT, idx);
+	}
+}
+
 static irqreturn_t sky2_intr(int irq, void *dev_id)
 {
 	struct sky2_hw *hw = dev_id;
