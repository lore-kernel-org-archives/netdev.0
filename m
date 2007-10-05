From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 16:24:00 -0700 (PDT)
Message-ID: <20071005.162400.35026372.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005083556.7076dd43@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33124
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756154AbXJEXYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:24:05 -0400
In-Reply-To: <20071005083556.7076dd43@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:35:56 -0700

> > +static void niu_log_rxchan_errors(struct niu *np, struct rx_ring_info *rp,
> > +				  u64 stat)
> > +{
> > +	printk(KERN_ERR PFX "%s: RX channel %u errors ( ",
> > +	       np->dev->name, rp->rx_channel);
> dev_err??

I've made conversions over to dev_err() where possible.

Thanks!

>From cbc4b58382eab08aa231f23d21839c011b4c9f8c Mon Sep 17 00:00:00 2001
From: David S. Miller <davem@sunset.davemloft.net>
Date: Fri, 5 Oct 2007 16:22:39 -0700
Subject: [PATCH] [NIU]: Use dev_err().

Suggested by Stephen Hemminger.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/niu.c |  317 +++++++++++++++++++++++++++--------------------------
 1 files changed, 161 insertions(+), 156 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index c29235e..1669a0f 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -137,10 +137,10 @@ static int __niu_set_and_wait_clear_mac(struct niu *np, unsigned long reg,
 	nw64_mac(reg, bits);
 	err = __niu_wait_bits_clear_mac(np, reg, bits, limit, delay);
 	if (err)
-		printk(KERN_ERR PFX "%s: bits (%llx) of register %s "
-		       "would not clear, val[%llx]\n",
-		       np->dev->name, (unsigned long long) bits, reg_name,
-		       (unsigned long long) nr64_mac(reg));
+		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
+			"would not clear, val[%llx]\n",
+			np->dev->name, (unsigned long long) bits, reg_name,
+			(unsigned long long) nr64_mac(reg));
 	return err;
 }
 
@@ -177,10 +177,10 @@ static int __niu_set_and_wait_clear_ipp(struct niu *np, unsigned long reg,
 
 	err = __niu_wait_bits_clear_ipp(np, reg, bits, limit, delay);
 	if (err)
-		printk(KERN_ERR PFX "%s: bits (%llx) of register %s "
-		       "would not clear, val[%llx]\n",
-		       np->dev->name, (unsigned long long) bits, reg_name,
-		       (unsigned long long) nr64_ipp(reg));
+		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
+			"would not clear, val[%llx]\n",
+			np->dev->name, (unsigned long long) bits, reg_name,
+			(unsigned long long) nr64_ipp(reg));
 	return err;
 }
 
@@ -218,10 +218,10 @@ static int __niu_set_and_wait_clear(struct niu *np, unsigned long reg,
 	nw64(reg, bits);
 	err = __niu_wait_bits_clear(np, reg, bits, limit, delay);
 	if (err)
-		printk(KERN_ERR PFX "%s: bits (%llx) of register %s "
-		       "would not clear, val[%llx]\n",
-		       np->dev->name, (unsigned long long) bits, reg_name,
-		       (unsigned long long) nr64(reg));
+		dev_err(np->device, PFX "%s: bits (%llx) of register %s "
+			"would not clear, val[%llx]\n",
+			np->dev->name, (unsigned long long) bits, reg_name,
+			(unsigned long long) nr64(reg));
 	return err;
 }
 
@@ -549,8 +549,9 @@ static int esr_reset(struct niu *np)
 	if (err)
 		return err;
 	if (reset != 0) {
-		printk(KERN_ERR PFX "Port %u ESR_RESET did not clear [%08x]\n",
-		       np->port, reset);
+		dev_err(np->device, PFX "Port %u ESR_RESET "
+			"did not clear [%08x]\n",
+			np->port, reset);
 		return -ENODEV;
 	}
 
@@ -670,8 +671,8 @@ static int serdes_init_10g(struct niu *np)
 	}
 
 	if ((sig & mask) != val) {
-		printk(KERN_ERR PFX "Port %u signal bits [%08x] are not "
-		       "[%08x]\n", np->port, (int) (sig & mask), (int) val);
+		dev_err(np->device, PFX "Port %u signal bits [%08x] are not "
+			"[%08x]\n", np->port, (int) (sig & mask), (int) val);
 		return -ENODEV;
 	}
 
@@ -729,8 +730,8 @@ static int bcm8704_reset(struct niu *np)
 			break;
 	}
 	if (limit < 0) {
-		printk(KERN_ERR PFX "Port %u PHY will not reset "
-		       "(bmcr=%04x)\n", np->port, (err & 0xffff));
+		dev_err(np->device, PFX "Port %u PHY will not reset "
+			"(bmcr=%04x)\n", np->port, (err & 0xffff));
 		return -ENODEV;
 	}
 	return 0;
@@ -910,8 +911,8 @@ static int mii_reset(struct niu *np)
 			break;
 	}
 	if (limit < 0) {
-		printk(KERN_ERR PFX "Port %u MII would not reset, "
-		       "bmcr[%04x]\n", np->port, err);
+		dev_err(np->device, PFX "Port %u MII would not reset, "
+			"bmcr[%04x]\n", np->port, err);
 		return -ENODEV;
 	}
 
@@ -1010,8 +1011,8 @@ static int mii_init_common(struct niu *np)
 	if (err < 0)
 		return err;
 #if 0
-	printk(KERN_ERR PFX "Port %u after MII init bmcr[%04x] bmsr[%04x]\n",
-	       np->port, bmcr, bmsr);
+	pr_info(PFX "Port %u after MII init bmcr[%04x] bmsr[%04x]\n",
+		np->port, bmcr, bmsr);
 #endif
 
 	return 0;
@@ -2462,8 +2463,8 @@ static int niu_poll(struct napi_struct *napi, int budget)
 static void niu_log_rxchan_errors(struct niu *np, struct rx_ring_info *rp,
 				  u64 stat)
 {
-	printk(KERN_ERR PFX "%s: RX channel %u errors ( ",
-	       np->dev->name, rp->rx_channel);
+	dev_err(np->device, PFX "%s: RX channel %u errors ( ",
+		np->dev->name, rp->rx_channel);
 
 	if (stat & RX_DMA_CTL_STAT_RBR_TMOUT)
 		printk("RBR_TMOUT ");
@@ -2502,8 +2503,8 @@ static int niu_rx_error(struct niu *np, struct rx_ring_info *rp)
 	u64 stat = nr64(RX_DMA_CTL_STAT(rp->rx_channel));
 	int err = 0;
 
-	printk(KERN_ERR PFX "%s: RX channel %u error, stat[%llx]\n",
-	       np->dev->name, rp->rx_channel, (unsigned long long) stat);
+	dev_err(np->device, PFX "%s: RX channel %u error, stat[%llx]\n",
+		np->dev->name, rp->rx_channel, (unsigned long long) stat);
 
 	niu_log_rxchan_errors(np, rp, stat);
 
@@ -2520,8 +2521,8 @@ static int niu_rx_error(struct niu *np, struct rx_ring_info *rp)
 static void niu_log_txchan_errors(struct niu *np, struct tx_ring_info *rp,
 				  u64 cs)
 {
-	printk(KERN_ERR PFX "%s: TX channel %u errors ( ",
-	       np->dev->name, rp->tx_channel);
+	dev_err(np->device, PFX "%s: TX channel %u errors ( ",
+		np->dev->name, rp->tx_channel);
 
 	if (cs & TX_CS_MBOX_ERR)
 		printk("MBOX ");
@@ -2551,12 +2552,12 @@ static int niu_tx_error(struct niu *np, struct tx_ring_info *rp)
 	logh = nr64(TX_RNG_ERR_LOGH(rp->tx_channel));
 	logl = nr64(TX_RNG_ERR_LOGL(rp->tx_channel));
 
-	printk(KERN_ERR PFX "%s: TX channel %u error, "
-	       "cs[%llx] logh[%llx] logl[%llx]\n",
-	       np->dev->name, rp->tx_channel,
-	       (unsigned long long) cs,
-	       (unsigned long long) logh,
-	       (unsigned long long) logl);
+	dev_err(np->device, PFX "%s: TX channel %u error, "
+		"cs[%llx] logh[%llx] logl[%llx]\n",
+		np->dev->name, rp->tx_channel,
+		(unsigned long long) cs,
+		(unsigned long long) logh,
+		(unsigned long long) logl);
 
 	niu_log_txchan_errors(np, rp, cs);
 
@@ -2575,9 +2576,9 @@ static int niu_mif_interrupt(struct niu *np)
 			phy_mdint = 1;
 	}
 
-	printk(KERN_ERR PFX "%s: MIF interrupt, "
-	       "stat[%llx] phy_mdint(%d)\n",
-	       np->dev->name, (unsigned long long) mif_status, phy_mdint);
+	dev_err(np->device, PFX "%s: MIF interrupt, "
+		"stat[%llx] phy_mdint(%d)\n",
+		np->dev->name, (unsigned long long) mif_status, phy_mdint);
 
 	return -ENODEV;
 }
@@ -2702,8 +2703,8 @@ static int niu_mac_interrupt(struct niu *np)
 
 static void niu_log_device_error(struct niu *np, u64 stat)
 {
-	printk(KERN_ERR PFX "%s: Core device errors ( ",
-	       np->dev->name);
+	dev_err(np->device, PFX "%s: Core device errors ( ",
+		np->dev->name);
 
 	if (stat & SYS_ERR_MASK_META2)
 		printk("META2 ");
@@ -2735,8 +2736,8 @@ static int niu_device_error(struct niu *np)
 {
 	u64 stat = nr64(SYS_ERR_STAT);
 
-	printk(KERN_ERR PFX "%s: Core device error, stat[%llx]\n",
-	       np->dev->name, (unsigned long long) stat);
+	dev_err(np->device, PFX "%s: Core device error, stat[%llx]\n",
+		np->dev->name, (unsigned long long) stat);
 
 	niu_log_device_error(np, stat);
 
@@ -2878,7 +2879,7 @@ static irqreturn_t niu_interrupt(int irq, void *dev_id)
 	u64 v0, v1, v2;
 
 	if (netif_msg_intr(np))
-		printk(KERN_ERR PFX "niu_interrupt() ldg[%p](%d) ",
+		printk(KERN_DEBUG PFX "niu_interrupt() ldg[%p](%d) ",
 		       lp, ldg);
 
 	spin_lock_irqsave(&np->lock, flags);
@@ -3013,8 +3014,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->mbox)
 		return -ENOMEM;
 	if ((unsigned long)rp->mbox & (64UL - 1)) {
-		printk(KERN_ERR PFX "%s: Coherent alloc gives misaligned "
-		       "RXDMA mailbox %p\n", np->dev->name, rp->mbox);
+		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
+			"RXDMA mailbox %p\n", np->dev->name, rp->mbox);
 		return -EINVAL;
 	}
 
@@ -3024,8 +3025,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->rcr)
 		return -ENOMEM;
 	if ((unsigned long)rp->rcr & (64UL - 1)) {
-		printk(KERN_ERR PFX "%s: Coherent alloc gives misaligned "
-		       "RXDMA RCR table %p\n", np->dev->name, rp->rcr);
+		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
+			"RXDMA RCR table %p\n", np->dev->name, rp->rcr);
 		return -EINVAL;
 	}
 	rp->rcr_table_size = MAX_RCR_RING_SIZE;
@@ -3037,8 +3038,8 @@ static int niu_alloc_rx_ring_info(struct niu *np,
 	if (!rp->rbr)
 		return -ENOMEM;
 	if ((unsigned long)rp->rbr & (64UL - 1)) {
-		printk(KERN_ERR PFX "%s: Coherent alloc gives misaligned "
-		       "RXDMA RBR table %p\n", np->dev->name, rp->rbr);
+		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
+			"RXDMA RBR table %p\n", np->dev->name, rp->rbr);
 		return -EINVAL;
 	}
 	rp->rbr_table_size = MAX_RBR_RING_SIZE;
@@ -3068,8 +3069,8 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 	if (!rp->mbox)
 		return -ENOMEM;
 	if ((unsigned long)rp->mbox & (64UL - 1)) {
-		printk(KERN_ERR PFX "%s: Coherent alloc gives misaligned "
-		       "TXDMA mailbox %p\n", np->dev->name, rp->mbox);
+		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
+			"TXDMA mailbox %p\n", np->dev->name, rp->mbox);
 		return -EINVAL;
 	}
 
@@ -3079,8 +3080,8 @@ static int niu_alloc_tx_ring_info(struct niu *np,
 	if (!rp->descr)
 		return -ENOMEM;
 	if ((unsigned long)rp->descr & (64UL - 1)) {
-		printk(KERN_ERR PFX "%s: Coherent alloc gives misaligned "
-		       "TXDMA descr table %p\n", np->dev->name, rp->descr);
+		dev_err(np->device, PFX "%s: Coherent alloc gives misaligned "
+			"TXDMA descr table %p\n", np->dev->name, rp->descr);
 		return -EINVAL;
 	}
 
@@ -3353,10 +3354,10 @@ static int niu_init_one_tx_channel(struct niu *np, struct tx_ring_info *rp)
 
 	if (rp->descr_dma & ~(TX_RNG_CFIG_STADDR_BASE |
 			      TX_RNG_CFIG_STADDR)) {
-		printk(KERN_ERR PFX "%s: TX ring channel %d "
-		       "DMA addr (%llx) is not aligned.\n",
-		       np->dev->name, channel,
-		       (unsigned long long) rp->descr_dma);
+		dev_err(np->device, PFX "%s: TX ring channel %d "
+			"DMA addr (%llx) is not aligned.\n",
+			np->dev->name, channel,
+			(unsigned long long) rp->descr_dma);
 		return -EINVAL;
 	}
 
@@ -3373,10 +3374,10 @@ static int niu_init_one_tx_channel(struct niu *np, struct tx_ring_info *rp)
 
 	if (((rp->mbox_dma >> 32) & ~TXDMA_MBH_MBADDR) ||
 	    ((u32)rp->mbox_dma & ~TXDMA_MBL_MBADDR)) {
-		printk(KERN_ERR PFX "%s: TX ring channel %d "
-		       "MBOX addr (%llx) is has illegal bits.\n",
-		       np->dev->name, channel,
-		       (unsigned long long) rp->mbox_dma);
+		dev_err(np->device, PFX "%s: TX ring channel %d "
+			"MBOX addr (%llx) is has illegal bits.\n",
+			np->dev->name, channel,
+			(unsigned long long) rp->mbox_dma);
 		return -EINVAL;
 	}
 	nw64(TXDMA_MBH(channel), rp->mbox_dma >> 32);
@@ -3771,9 +3772,9 @@ static int niu_zcp_read(struct niu *np, int index, u64 *data)
 	err = niu_wait_bits_clear(np, ZCP_RAM_ACC, ZCP_RAM_ACC_BUSY,
 				  1000, 100);
 	if (err) {
-		printk(KERN_ERR PFX "%s: ZCP read busy won't clear, "
-		       "ZCP_RAM_ACC[%llx]\n", np->dev->name,
-		       (unsigned long long) nr64(ZCP_RAM_ACC));
+		dev_err(np->device, PFX "%s: ZCP read busy won't clear, "
+			"ZCP_RAM_ACC[%llx]\n", np->dev->name,
+			(unsigned long long) nr64(ZCP_RAM_ACC));
 		return err;
 	}
 
@@ -3785,9 +3786,9 @@ static int niu_zcp_read(struct niu *np, int index, u64 *data)
 	err = niu_wait_bits_clear(np, ZCP_RAM_ACC, ZCP_RAM_ACC_BUSY,
 				  1000, 100);
 	if (err) {
-		printk(KERN_ERR PFX "%s: ZCP read busy2 won't clear, "
-		       "ZCP_RAM_ACC[%llx]\n", np->dev->name,
-		       (unsigned long long) nr64(ZCP_RAM_ACC));
+		dev_err(np->device, PFX "%s: ZCP read busy2 won't clear, "
+			"ZCP_RAM_ACC[%llx]\n", np->dev->name,
+			(unsigned long long) nr64(ZCP_RAM_ACC));
 		return err;
 	}
 
@@ -4114,10 +4115,10 @@ static int niu_reset_tx_bmac(struct niu *np)
 		udelay(100);
 	}
 	if (limit < 0) {
-		printk(KERN_ERR PFX "Port %u TX BMAC would not reset, "
-		       "BTXMAC_SW_RST[%llx]\n",
-		       np->port,
-		       (unsigned long long) nr64_mac(BTXMAC_SW_RST));
+		dev_err(np->device, PFX "Port %u TX BMAC would not reset, "
+			"BTXMAC_SW_RST[%llx]\n",
+			np->port,
+			(unsigned long long) nr64_mac(BTXMAC_SW_RST));
 		return -ENODEV;
 	}
 
@@ -4220,10 +4221,10 @@ static int niu_reset_rx_xmac(struct niu *np)
 		udelay(100);
 	}
 	if (limit < 0) {
-		printk(KERN_ERR PFX "Port %u RX XMAC would not reset, "
-		       "XRXMAC_SW_RST[%llx]\n",
-		       np->port,
-		       (unsigned long long) nr64_mac(XRXMAC_SW_RST));
+		dev_err(np->device, PFX "Port %u RX XMAC would not reset, "
+			"XRXMAC_SW_RST[%llx]\n",
+			np->port,
+			(unsigned long long) nr64_mac(XRXMAC_SW_RST));
 		return -ENODEV;
 	}
 
@@ -4242,10 +4243,10 @@ static int niu_reset_rx_bmac(struct niu *np)
 		udelay(100);
 	}
 	if (limit < 0) {
-		printk(KERN_ERR PFX "Port %u RX BMAC would not reset, "
-		       "BRXMAC_SW_RST[%llx]\n",
-		       np->port,
-		       (unsigned long long) nr64_mac(BRXMAC_SW_RST));
+		dev_err(np->device, PFX "Port %u RX BMAC would not reset, "
+			"BRXMAC_SW_RST[%llx]\n",
+			np->port,
+			(unsigned long long) nr64_mac(BRXMAC_SW_RST));
 		return -ENODEV;
 	}
 
@@ -4547,11 +4548,11 @@ static void niu_disable_ipp(struct niu *np)
 	}
 	if (limit < 0 &&
 	    (rd != 0 && wr != 1)) {
-		printk(KERN_ERR PFX "%s: IPP would not quiesce, "
-		       "rd_ptr[%llx] wr_ptr[%llx]\n",
-		       np->dev->name,
-		       (unsigned long long) nr64_ipp(IPP_DFIFO_RD_PTR),
-		       (unsigned long long) nr64_ipp(IPP_DFIFO_WR_PTR));
+		dev_err(np->device, PFX "%s: IPP would not quiesce, "
+			"rd_ptr[%llx] wr_ptr[%llx]\n",
+			np->dev->name,
+			(unsigned long long) nr64_ipp(IPP_DFIFO_RD_PTR),
+			(unsigned long long) nr64_ipp(IPP_DFIFO_WR_PTR));
 	}
 
 	val = nr64_ipp(IPP_CFIG);
@@ -5068,8 +5069,8 @@ static void niu_tx_timeout(struct net_device *dev)
 {
 	struct niu *np = netdev_priv(dev);
 
-	printk(KERN_ERR PFX "%s: Transmit timed out, resetting\n",
-	       dev->name);
+	dev_err(np->device, PFX "%s: Transmit timed out, resetting\n",
+		dev->name);
 
 	schedule_work(&np->reset_task);
 }
@@ -5171,8 +5172,8 @@ static int niu_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
 		netif_stop_queue(dev);
-		printk(KERN_ERR PFX "%s: BUG! Tx ring full when "
-		       "queue awake!\n", dev->name);
+		dev_err(np->device, PFX "%s: BUG! Tx ring full when "
+			"queue awake!\n", dev->name);
 		rp->tx_errors++;
 		return NETDEV_TX_BUSY;
 	}
@@ -5687,10 +5688,11 @@ static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
 		 * interrupts and that's painful to debug.
 		 */
 		if (nr64(LDG_NUM(ldn)) != ldg) {
-			printk(KERN_ERR PFX "Port %u, mis-matched LDG assignment "
-			       "for ldn %d, should be %d is %llu\n",
-			       np->port, ldn, ldg,
-			       (unsigned long long) nr64(LDG_NUM(ldn)));
+			dev_err(np->device, PFX "Port %u, mis-matched "
+				"LDG assignment "
+				"for ldn %d, should be %d is %llu\n",
+				np->port, ldn, ldg,
+				(unsigned long long) nr64(LDG_NUM(ldn)));
 			return -EINVAL;
 		}
 	} else
@@ -5741,8 +5743,8 @@ static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
 			break;
 	} while (limit--);
 	if (!(frame & ESPC_PIO_STAT_READ_END)) {
-		printk(KERN_ERR PFX "EEPROM read timeout frame[%llx]\n",
-		       (unsigned long long) frame);
+		dev_err(np->device, PFX "EEPROM read timeout frame[%llx]\n",
+			(unsigned long long) frame);
 		return -ENODEV;
 	}
 
@@ -5756,8 +5758,8 @@ static int __devinit niu_pci_eeprom_read(struct niu *np, u32 addr)
 			break;
 	} while (limit--);
 	if (!(frame & ESPC_PIO_STAT_READ_END)) {
-		printk(KERN_ERR PFX "EEPROM read timeout frame[%llx]\n",
-		       (unsigned long long) frame);
+		dev_err(np->device, PFX "EEPROM read timeout frame[%llx]\n",
+			(unsigned long long) frame);
 		return -ENODEV;
 	}
 
@@ -5913,8 +5915,8 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 		}
 
 		if (max_len && prop_len > max_len) {
-			printk(KERN_ERR PFX "Property '%s' length (%d) is "
-			       "too long.\n", namebuf, prop_len);
+			dev_err(np->device, PFX "Property '%s' length (%d) is "
+				"too long.\n", namebuf, prop_len);
 			return -EINVAL;
 		}
 
@@ -6060,17 +6062,17 @@ static void __devinit niu_pci_vpd_validate(struct niu *np)
 	u8 val8;
 
 	if (!is_valid_ether_addr(&vpd->local_mac[0])) {
-		printk(KERN_ERR PFX "VPD MAC invalid, "
-		       "falling back to SPROM.\n");
+		dev_err(np->device, PFX "VPD MAC invalid, "
+			"falling back to SPROM.\n");
 
 		np->flags &= ~NIU_FLAGS_VPD_VALID;
 		return;
 	}
 
 	if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
-		printk(KERN_ERR PFX "Illegal phy string [%s].\n",
-		       np->vpd.phy_type);
-		printk(KERN_ERR PFX "Falling back to SPROM.\n");
+		dev_err(np->device, PFX "Illegal phy string [%s].\n",
+			np->vpd.phy_type);
+		dev_err(np->device, PFX "Falling back to SPROM.\n");
 		np->flags &= ~NIU_FLAGS_VPD_VALID;
 		return;
 	}
@@ -6110,8 +6112,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	}
 	niudbg(PROBE, "SPROM: Checksum %x\n", (int)(sum & 0xff));
 	if ((sum & 0xff) != 0xab) {
-		printk(KERN_ERR PFX "Bad SPROM checksum "
-		       "(%x, should be 0xab)\n", (int) (sum & 0xff));
+		dev_err(np->device, PFX "Bad SPROM checksum "
+			"(%x, should be 0xab)\n", (int) (sum & 0xff));
 		return -EINVAL;
 	}
 
@@ -6134,8 +6136,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 			ESPC_PHY_TYPE_PORT3_SHIFT;
 		break;
 	default:
-		printk(KERN_ERR PFX "Bogus port number %u\n",
-		       np->port);
+		dev_err(np->device, PFX "Bogus port number %u\n",
+			np->port);
 		return -EINVAL;
 	}
 	niudbg(PROBE, "SPROM: PHY type %llx\n", (unsigned long long) val);
@@ -6170,8 +6172,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 		break;
 
 	default:
-		printk(KERN_ERR PFX "Bogus SPROM phy type %llu\n",
-		       (unsigned long long) val);
+		dev_err(np->device, PFX "Bogus SPROM phy type %llu\n",
+			(unsigned long long) val);
 		return -EINVAL;
 	}
 
@@ -6190,8 +6192,8 @@ static int __devinit niu_pci_probe_sprom(struct niu *np)
 	dev->perm_addr[5] = (val >>  8) & 0xff;
 
 	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
-		printk(KERN_ERR PFX "SPROM MAC address invalid\n");
-		printk(KERN_ERR PFX "[ \n");
+		dev_err(np->device, PFX "SPROM MAC address invalid\n");
+		dev_err(np->device, PFX "[ \n");
 		for (i = 0; i < 6; i++)
 			printk("%02x ", dev->perm_addr[i]);
 		printk("]\n");
@@ -6716,8 +6718,8 @@ static int __devinit niu_init_mac_ipp_pcs_base(struct niu *np)
 		break;
 
 	default:
-		printk(KERN_ERR PFX "Port %u is invalid, cannot "
-		       "compute MAC block offset.\n", np->port);
+		dev_err(np->device, PFX "Port %u is invalid, cannot "
+			"compute MAC block offset.\n", np->port);
 		return -EINVAL;
 	}
 
@@ -6926,8 +6928,9 @@ static int __devinit niu_get_of_props(struct niu *np)
 
 	phy_type = of_get_property(dp, "phy-type", &prop_len);
 	if (!phy_type) {
-		printk(KERN_ERR PFX "%s: OF node lacks phy-type property\n",
-		       dp->full_name);
+		dev_err(np->device, PFX "%s: OF node lacks "
+			"phy-type property\n",
+			dp->full_name);
 		return -EINVAL;
 	}
 
@@ -6937,29 +6940,31 @@ static int __devinit niu_get_of_props(struct niu *np)
 	strcpy(np->vpd.phy_type, phy_type);
 
 	if (niu_phy_type_prop_decode(np, np->vpd.phy_type)) {
-		printk(KERN_ERR PFX "%s: Illegal phy string [%s].\n",
-		       dp->full_name, np->vpd.phy_type);
+		dev_err(np->device, PFX "%s: Illegal phy string [%s].\n",
+			dp->full_name, np->vpd.phy_type);
 		return -EINVAL;
 	}
 
 	mac_addr = of_get_property(dp, "local-mac-address", &prop_len);
 	if (!mac_addr) {
-		printk(KERN_ERR PFX "%s: OF node lacks local-mac-address property\n",
-		       dp->full_name);
+		dev_err(np->device, PFX "%s: OF node lacks "
+			"local-mac-address property\n",
+			dp->full_name);
 		return -EINVAL;
 	}
 	if (prop_len != dev->addr_len) {
-		printk(KERN_ERR PFX "%s: OF MAC address prop len (%d) is wrong.\n",
-		       dp->full_name, prop_len);
+		dev_err(np->device, PFX "%s: OF MAC address prop len (%d) "
+			"is wrong.\n",
+			dp->full_name, prop_len);
 	}
 	memcpy(dev->perm_addr, mac_addr, dev->addr_len);
 	if (!is_valid_ether_addr(&dev->perm_addr[0])) {
 		int i;
 
-		printk(KERN_ERR PFX "%s: OF MAC address is invalid\n",
-		       dp->full_name);
-		printk(KERN_ERR PFX "%s: [ \n",
-		       dp->full_name);
+		dev_err(np->device, PFX "%s: OF MAC address is invalid\n",
+			dp->full_name);
+		dev_err(np->device, PFX "%s: [ \n",
+			dp->full_name);
 		for (i = 0; i < 6; i++)
 			printk("%02x ", dev->perm_addr[i]);
 		printk("]\n");
@@ -7350,7 +7355,7 @@ static struct net_device * __devinit niu_alloc_and_init(struct device *gen_dev,
 	struct niu *np;
 
 	if (!dev) {
-		printk(KERN_ERR PFX "Etherdev alloc failed, aborting.\n");
+		dev_err(gen_dev, PFX "Etherdev alloc failed, aborting.\n");
 		return NULL;
 	}
 
@@ -7423,30 +7428,30 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot enable PCI device, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot enable PCI device, "
+			"aborting.\n");
 		return err;
 	}
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM) ||
 	    !(pci_resource_flags(pdev, 2) & IORESOURCE_MEM)) {
-		printk(KERN_ERR PFX "Cannot find proper PCI device "
-		       "base addresses, aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot find proper PCI device "
+			"base addresses, aborting.\n");
 		err = -ENODEV;
 		goto err_out_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, DRV_MODULE_NAME);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot obtain PCI resources, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot obtain PCI resources, "
+			"aborting.\n");
 		goto err_out_disable_pdev;
 	}
 
 	pos = pci_find_capability(pdev, PCI_CAP_ID_EXP);
 	if (pos <= 0) {
-		printk(KERN_ERR PFX "Cannot find PCI Express capability, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot find PCI Express capability, "
+			"aborting.\n");
 		goto err_out_free_res;
 	}
 
@@ -7485,17 +7490,17 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 		dev->features |= NETIF_F_HIGHDMA;
 		err = pci_set_consistent_dma_mask(pdev, dma_mask);
 		if (err) {
-			printk(KERN_ERR PFX "Unable to obtain 44 bit "
-			       "DMA for consistent allocations, "
-			       "aborting.\n");
+			dev_err(&pdev->dev, PFX "Unable to obtain 44 bit "
+				"DMA for consistent allocations, "
+				"aborting.\n");
 			goto err_out_release_parent;
 		}
 	}
 	if (err || dma_mask == DMA_32BIT_MASK) {
 		err = pci_set_dma_mask(pdev, DMA_32BIT_MASK);
 		if (err) {
-			printk(KERN_ERR PFX "No usable DMA configuration, "
-			       "aborting.\n");
+			dev_err(&pdev->dev, PFX "No usable DMA configuration, "
+				"aborting.\n");
 			goto err_out_release_parent;
 		}
 	}
@@ -7507,8 +7512,8 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 
 	np->regs = ioremap_nocache(niureg_base, niureg_len);
 	if (!np->regs) {
-		printk(KERN_ERR PFX "Cannot map device registers, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot map device registers, "
+			"aborting.\n");
 		err = -ENOMEM;
 		goto err_out_release_parent;
 	}
@@ -7523,15 +7528,15 @@ static int __devinit niu_pci_init_one(struct pci_dev *pdev,
 	err = niu_get_invariants(np);
 	if (err) {
 		if (err != -ENODEV)
-			printk(KERN_ERR PFX "Problem fetching invariants "
-			       "of chip, aborting.\n");
+			dev_err(&pdev->dev, PFX "Problem fetching invariants "
+				"of chip, aborting.\n");
 		goto err_out_iounmap;
 	}
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		dev_err(&pdev->dev, PFX "Cannot register net device, "
+			"aborting.\n");
 		goto err_out_iounmap;
 	}
 
@@ -7729,8 +7734,8 @@ static int __devinit niu_of_probe(struct of_device *op, const struct of_device_i
 
 	reg = of_get_property(op->node, "reg", NULL);
 	if (!reg) {
-		printk(KERN_ERR PFX "%s: No 'reg' property, aborting.\n",
-		       op->node->full_name);
+		dev_err(&op->dev, PFX "%s: No 'reg' property, aborting.\n",
+			op->node->full_name);
 		return -ENODEV;
 	}
 
@@ -7758,8 +7763,8 @@ static int __devinit niu_of_probe(struct of_device *op, const struct of_device_i
 			      res_size(&op->resource[1]),
 			      "niu regs");
 	if (!np->regs) {
-		printk(KERN_ERR PFX "Cannot map device registers, "
-		       "aborting.\n");
+		dev_err(&op->dev, PFX "Cannot map device registers, "
+			"aborting.\n");
 		err = -ENOMEM;
 		goto err_out_release_parent;
 	}
@@ -7768,8 +7773,8 @@ static int __devinit niu_of_probe(struct of_device *op, const struct of_device_i
 				    res_size(&op->resource[2]),
 				    "niu vregs-1");
 	if (!np->vir_regs_1) {
-		printk(KERN_ERR PFX "Cannot map device vir registers 1, "
-		       "aborting.\n");
+		dev_err(&op->dev, PFX "Cannot map device vir registers 1, "
+			"aborting.\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -7778,8 +7783,8 @@ static int __devinit niu_of_probe(struct of_device *op, const struct of_device_i
 				    res_size(&op->resource[3]),
 				    "niu vregs-2");
 	if (!np->vir_regs_2) {
-		printk(KERN_ERR PFX "Cannot map device vir registers 2, "
-		       "aborting.\n");
+		dev_err(&op->dev, PFX "Cannot map device vir registers 2, "
+			"aborting.\n");
 		err = -ENOMEM;
 		goto err_out_iounmap;
 	}
@@ -7789,15 +7794,15 @@ static int __devinit niu_of_probe(struct of_device *op, const struct of_device_i
 	err = niu_get_invariants(np);
 	if (err) {
 		if (err != -ENODEV)
-			printk(KERN_ERR PFX "Problem fetching invariants "
-			       "of chip, aborting.\n");
+			dev_err(&op->dev, PFX "Problem fetching invariants "
+				"of chip, aborting.\n");
 		goto err_out_iounmap;
 	}
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR PFX "Cannot register net device, "
-		       "aborting.\n");
+		dev_err(&op->dev, PFX "Cannot register net device, "
+			"aborting.\n");
 		goto err_out_iounmap;
 	}
 
-- 
1.5.3.3

