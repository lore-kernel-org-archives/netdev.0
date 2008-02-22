From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 01/04] smc91x: pass along private data V2
Date: Fri, 22 Feb 2008 09:26:35 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802220925520.2732@xanadu.home>
References: <20080222105456.7408.11277.sendpatchset@clockwork.opensource.se>
 <20080222105505.7408.73708.sendpatchset@clockwork.opensource.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:56050 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751187AbYBVO0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 09:26:47 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MH-MR001.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWN0002Q9GB1C40@VL-MH-MR001.ip.videotron.ca> for
 netdev@vger.kernel.org; Fri, 22 Feb 2008 09:26:38 -0500 (EST)
In-reply-to: <20080222105505.7408.73708.sendpatchset@clockwork.opensource.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Feb 2008, Magnus Damm wrote:

> Pass a private data pointer to macros and functions. This makes it easy
> to later on make run time decisions. This patch does not change any logic.
> These changes should be optimized away during compilation.
> 
> V2 changes the macro argument name from "priv" to "lp".
> 
> Signed-off-by: Magnus Damm <damm@igel.co.jp>

Acked-by: Nicolas Pitre <nico@cam.org>


> ---
> 
>  drivers/net/smc91x.c |  301 +++++++++++++++++++++++++-------------------------
>  drivers/net/smc91x.h |  254 +++++++++++++++++++++---------------------
>  2 files changed, 280 insertions(+), 275 deletions(-)
> 
> --- 0001/drivers/net/smc91x.c
> +++ work/drivers/net/smc91x.c	2008-02-22 14:07:43.000000000 +0900
> @@ -220,22 +220,22 @@ static void PRINT_PKT(u_char *buf, int l
>  
>  
>  /* this enables an interrupt in the interrupt mask register */
> -#define SMC_ENABLE_INT(x) do {						\
> +#define SMC_ENABLE_INT(lp, x) do {					\
>  	unsigned char mask;						\
>  	spin_lock_irq(&lp->lock);					\
> -	mask = SMC_GET_INT_MASK();					\
> +	mask = SMC_GET_INT_MASK(lp);					\
>  	mask |= (x);							\
> -	SMC_SET_INT_MASK(mask);						\
> +	SMC_SET_INT_MASK(lp, mask);					\
>  	spin_unlock_irq(&lp->lock);					\
>  } while (0)
>  
>  /* this disables an interrupt from the interrupt mask register */
> -#define SMC_DISABLE_INT(x) do {						\
> +#define SMC_DISABLE_INT(lp, x) do {					\
>  	unsigned char mask;						\
>  	spin_lock_irq(&lp->lock);					\
> -	mask = SMC_GET_INT_MASK();					\
> +	mask = SMC_GET_INT_MASK(lp);					\
>  	mask &= ~(x);							\
> -	SMC_SET_INT_MASK(mask);						\
> +	SMC_SET_INT_MASK(lp, mask);					\
>  	spin_unlock_irq(&lp->lock);					\
>  } while (0)
>  
> @@ -244,10 +244,10 @@ static void PRINT_PKT(u_char *buf, int l
>   * if at all, but let's avoid deadlocking the system if the hardware
>   * decides to go south.
>   */
> -#define SMC_WAIT_MMU_BUSY() do {					\
> -	if (unlikely(SMC_GET_MMU_CMD() & MC_BUSY)) {			\
> +#define SMC_WAIT_MMU_BUSY(lp) do {					\
> +	if (unlikely(SMC_GET_MMU_CMD(lp) & MC_BUSY)) {		\
>  		unsigned long timeout = jiffies + 2;			\
> -		while (SMC_GET_MMU_CMD() & MC_BUSY) {			\
> +		while (SMC_GET_MMU_CMD(lp) & MC_BUSY) {		\
>  			if (time_after(jiffies, timeout)) {		\
>  				printk("%s: timeout %s line %d\n",	\
>  					dev->name, __FILE__, __LINE__);	\
> @@ -273,8 +273,8 @@ static void smc_reset(struct net_device 
>  
>  	/* Disable all interrupts, block TX tasklet */
>  	spin_lock_irq(&lp->lock);
> -	SMC_SELECT_BANK(2);
> -	SMC_SET_INT_MASK(0);
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_INT_MASK(lp, 0);
>  	pending_skb = lp->pending_tx_skb;
>  	lp->pending_tx_skb = NULL;
>  	spin_unlock_irq(&lp->lock);
> @@ -290,15 +290,15 @@ static void smc_reset(struct net_device 
>  	 * This resets the registers mostly to defaults, but doesn't
>  	 * affect EEPROM.  That seems unnecessary
>  	 */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RCR(RCR_SOFTRST);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RCR(lp, RCR_SOFTRST);
>  
>  	/*
>  	 * Setup the Configuration Register
>  	 * This is necessary because the CONFIG_REG is not affected
>  	 * by a soft reset
>  	 */
> -	SMC_SELECT_BANK(1);
> +	SMC_SELECT_BANK(lp, 1);
>  
>  	cfg = CONFIG_DEFAULT;
>  
> @@ -316,7 +316,7 @@ static void smc_reset(struct net_device 
>  	 */
>  	cfg |= CONFIG_EPH_POWER_EN;
>  
> -	SMC_SET_CONFIG(cfg);
> +	SMC_SET_CONFIG(lp, cfg);
>  
>  	/* this should pause enough for the chip to be happy */
>  	/*
> @@ -329,12 +329,12 @@ static void smc_reset(struct net_device 
>  	udelay(1);
>  
>  	/* Disable transmit and receive functionality */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RCR(RCR_CLEAR);
> -	SMC_SET_TCR(TCR_CLEAR);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RCR(lp, RCR_CLEAR);
> +	SMC_SET_TCR(lp, TCR_CLEAR);
>  
> -	SMC_SELECT_BANK(1);
> -	ctl = SMC_GET_CTL() | CTL_LE_ENABLE;
> +	SMC_SELECT_BANK(lp, 1);
> +	ctl = SMC_GET_CTL(lp) | CTL_LE_ENABLE;
>  
>  	/*
>  	 * Set the control register to automatically release successfully
> @@ -345,12 +345,12 @@ static void smc_reset(struct net_device 
>  		ctl |= CTL_AUTO_RELEASE;
>  	else
>  		ctl &= ~CTL_AUTO_RELEASE;
> -	SMC_SET_CTL(ctl);
> +	SMC_SET_CTL(lp, ctl);
>  
>  	/* Reset the MMU */
> -	SMC_SELECT_BANK(2);
> -	SMC_SET_MMU_CMD(MC_RESET);
> -	SMC_WAIT_MMU_BUSY();
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_MMU_CMD(lp, MC_RESET);
> +	SMC_WAIT_MMU_BUSY(lp);
>  }
>  
>  /*
> @@ -365,19 +365,19 @@ static void smc_enable(struct net_device
>  	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
>  
>  	/* see the header file for options in TCR/RCR DEFAULT */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_TCR(lp->tcr_cur_mode);
> -	SMC_SET_RCR(lp->rcr_cur_mode);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_TCR(lp, lp->tcr_cur_mode);
> +	SMC_SET_RCR(lp, lp->rcr_cur_mode);
>  
> -	SMC_SELECT_BANK(1);
> -	SMC_SET_MAC_ADDR(dev->dev_addr);
> +	SMC_SELECT_BANK(lp, 1);
> +	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
>  
>  	/* now, enable interrupts */
>  	mask = IM_EPH_INT|IM_RX_OVRN_INT|IM_RCV_INT;
>  	if (lp->version >= (CHIP_91100 << 4))
>  		mask |= IM_MDINT;
> -	SMC_SELECT_BANK(2);
> -	SMC_SET_INT_MASK(mask);
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_INT_MASK(lp, mask);
>  
>  	/*
>  	 * From this point the register bank must _NOT_ be switched away
> @@ -400,8 +400,8 @@ static void smc_shutdown(struct net_devi
>  
>  	/* no more interrupts for me */
>  	spin_lock_irq(&lp->lock);
> -	SMC_SELECT_BANK(2);
> -	SMC_SET_INT_MASK(0);
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_INT_MASK(lp, 0);
>  	pending_skb = lp->pending_tx_skb;
>  	lp->pending_tx_skb = NULL;
>  	spin_unlock_irq(&lp->lock);
> @@ -409,14 +409,14 @@ static void smc_shutdown(struct net_devi
>  		dev_kfree_skb(pending_skb);
>  
>  	/* and tell the card to stay away from that nasty outside world */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RCR(RCR_CLEAR);
> -	SMC_SET_TCR(TCR_CLEAR);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RCR(lp, RCR_CLEAR);
> +	SMC_SET_TCR(lp, TCR_CLEAR);
>  
>  #ifdef POWER_DOWN
>  	/* finally, shut the chip down */
> -	SMC_SELECT_BANK(1);
> -	SMC_SET_CONFIG(SMC_GET_CONFIG() & ~CONFIG_EPH_POWER_EN);
> +	SMC_SELECT_BANK(lp, 1);
> +	SMC_SET_CONFIG(lp, SMC_GET_CONFIG(lp) & ~CONFIG_EPH_POWER_EN);
>  #endif
>  }
>  
> @@ -431,17 +431,17 @@ static inline void  smc_rcv(struct net_d
>  
>  	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
>  
> -	packet_number = SMC_GET_RXFIFO();
> +	packet_number = SMC_GET_RXFIFO(lp);
>  	if (unlikely(packet_number & RXFIFO_REMPTY)) {
>  		PRINTK("%s: smc_rcv with nothing on FIFO.\n", dev->name);
>  		return;
>  	}
>  
>  	/* read from start of packet */
> -	SMC_SET_PTR(PTR_READ | PTR_RCV | PTR_AUTOINC);
> +	SMC_SET_PTR(lp, PTR_READ | PTR_RCV | PTR_AUTOINC);
>  
>  	/* First two words are status and packet length */
> -	SMC_GET_PKT_HDR(status, packet_len);
> +	SMC_GET_PKT_HDR(lp, status, packet_len);
>  	packet_len &= 0x07ff;  /* mask off top bits */
>  	DBG(2, "%s: RX PNR 0x%x STATUS 0x%04x LENGTH 0x%04x (%d)\n",
>  		dev->name, packet_number, status,
> @@ -460,8 +460,8 @@ static inline void  smc_rcv(struct net_d
>  					dev->name, packet_len, status);
>  			status |= RS_TOOSHORT;
>  		}
> -		SMC_WAIT_MMU_BUSY();
> -		SMC_SET_MMU_CMD(MC_RELEASE);
> +		SMC_WAIT_MMU_BUSY(lp);
> +		SMC_SET_MMU_CMD(lp, MC_RELEASE);
>  		dev->stats.rx_errors++;
>  		if (status & RS_ALGNERR)
>  			dev->stats.rx_frame_errors++;
> @@ -490,8 +490,8 @@ static inline void  smc_rcv(struct net_d
>  		if (unlikely(skb == NULL)) {
>  			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
>  				dev->name);
> -			SMC_WAIT_MMU_BUSY();
> -			SMC_SET_MMU_CMD(MC_RELEASE);
> +			SMC_WAIT_MMU_BUSY(lp);
> +			SMC_SET_MMU_CMD(lp, MC_RELEASE);
>  			dev->stats.rx_dropped++;
>  			return;
>  		}
> @@ -510,10 +510,10 @@ static inline void  smc_rcv(struct net_d
>  		 */
>  		data_len = packet_len - ((status & RS_ODDFRAME) ? 5 : 6);
>  		data = skb_put(skb, data_len);
> -		SMC_PULL_DATA(data, packet_len - 4);
> +		SMC_PULL_DATA(lp, data, packet_len - 4);
>  
> -		SMC_WAIT_MMU_BUSY();
> -		SMC_SET_MMU_CMD(MC_RELEASE);
> +		SMC_WAIT_MMU_BUSY(lp);
> +		SMC_SET_MMU_CMD(lp, MC_RELEASE);
>  
>  		PRINT_PKT(data, packet_len - 4);
>  
> @@ -591,7 +591,7 @@ static void smc_hardware_send_pkt(unsign
>  	}
>  	lp->pending_tx_skb = NULL;
>  
> -	packet_no = SMC_GET_AR();
> +	packet_no = SMC_GET_AR(lp);
>  	if (unlikely(packet_no & AR_FAILED)) {
>  		printk("%s: Memory allocation failed.\n", dev->name);
>  		dev->stats.tx_errors++;
> @@ -601,8 +601,8 @@ static void smc_hardware_send_pkt(unsign
>  	}
>  
>  	/* point to the beginning of the packet */
> -	SMC_SET_PN(packet_no);
> -	SMC_SET_PTR(PTR_AUTOINC);
> +	SMC_SET_PN(lp, packet_no);
> +	SMC_SET_PTR(lp, PTR_AUTOINC);
>  
>  	buf = skb->data;
>  	len = skb->len;
> @@ -614,13 +614,13 @@ static void smc_hardware_send_pkt(unsign
>  	 * Send the packet length (+6 for status words, length, and ctl.
>  	 * The card will pad to 64 bytes with zeroes if packet is too small.
>  	 */
> -	SMC_PUT_PKT_HDR(0, len + 6);
> +	SMC_PUT_PKT_HDR(lp, 0, len + 6);
>  
>  	/* send the actual data */
> -	SMC_PUSH_DATA(buf, len & ~1);
> +	SMC_PUSH_DATA(lp, buf, len & ~1);
>  
>  	/* Send final ctl word with the last byte if there is one */
> -	SMC_outw(((len & 1) ? (0x2000 | buf[len-1]) : 0), ioaddr, DATA_REG);
> +	SMC_outw(((len & 1) ? (0x2000 | buf[len-1]) : 0), ioaddr, DATA_REG(lp));
>  
>  	/*
>  	 * If THROTTLE_TX_PKTS is set, we stop the queue here. This will
> @@ -634,14 +634,14 @@ static void smc_hardware_send_pkt(unsign
>  		netif_stop_queue(dev);
>  
>  	/* queue the packet for TX */
> -	SMC_SET_MMU_CMD(MC_ENQUEUE);
> +	SMC_SET_MMU_CMD(lp, MC_ENQUEUE);
>  	smc_special_unlock(&lp->lock);
>  
>  	dev->trans_start = jiffies;
>  	dev->stats.tx_packets++;
>  	dev->stats.tx_bytes += len;
>  
> -	SMC_ENABLE_INT(IM_TX_INT | IM_TX_EMPTY_INT);
> +	SMC_ENABLE_INT(lp, IM_TX_INT | IM_TX_EMPTY_INT);
>  
>  done:	if (!THROTTLE_TX_PKTS)
>  		netif_wake_queue(dev);
> @@ -688,7 +688,7 @@ static int smc_hard_start_xmit(struct sk
>  	smc_special_lock(&lp->lock);
>  
>  	/* now, try to allocate the memory */
> -	SMC_SET_MMU_CMD(MC_ALLOC | numPages);
> +	SMC_SET_MMU_CMD(lp, MC_ALLOC | numPages);
>  
>  	/*
>  	 * Poll the chip for a short amount of time in case the
> @@ -696,9 +696,9 @@ static int smc_hard_start_xmit(struct sk
>  	 */
>  	poll_count = MEMORY_WAIT_TIME;
>  	do {
> -		status = SMC_GET_INT();
> +		status = SMC_GET_INT(lp);
>  		if (status & IM_ALLOC_INT) {
> -			SMC_ACK_INT(IM_ALLOC_INT);
> +			SMC_ACK_INT(lp, IM_ALLOC_INT);
>    			break;
>  		}
>     	} while (--poll_count);
> @@ -710,7 +710,7 @@ static int smc_hard_start_xmit(struct sk
>  		/* oh well, wait until the chip finds memory later */
>  		netif_stop_queue(dev);
>  		DBG(2, "%s: TX memory allocation deferred.\n", dev->name);
> -		SMC_ENABLE_INT(IM_ALLOC_INT);
> +		SMC_ENABLE_INT(lp, IM_ALLOC_INT);
>     	} else {
>  		/*
>  		 * Allocation succeeded: push packet to the chip's own memory
> @@ -736,19 +736,19 @@ static void smc_tx(struct net_device *de
>  	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
>  
>  	/* If the TX FIFO is empty then nothing to do */
> -	packet_no = SMC_GET_TXFIFO();
> +	packet_no = SMC_GET_TXFIFO(lp);
>  	if (unlikely(packet_no & TXFIFO_TEMPTY)) {
>  		PRINTK("%s: smc_tx with nothing on FIFO.\n", dev->name);
>  		return;
>  	}
>  
>  	/* select packet to read from */
> -	saved_packet = SMC_GET_PN();
> -	SMC_SET_PN(packet_no);
> +	saved_packet = SMC_GET_PN(lp);
> +	SMC_SET_PN(lp, packet_no);
>  
>  	/* read the first word (status word) from this packet */
> -	SMC_SET_PTR(PTR_AUTOINC | PTR_READ);
> -	SMC_GET_PKT_HDR(tx_status, pkt_len);
> +	SMC_SET_PTR(lp, PTR_AUTOINC | PTR_READ);
> +	SMC_GET_PKT_HDR(lp, tx_status, pkt_len);
>  	DBG(2, "%s: TX STATUS 0x%04x PNR 0x%02x\n",
>  		dev->name, tx_status, packet_no);
>  
> @@ -771,17 +771,17 @@ static void smc_tx(struct net_device *de
>  	}
>  
>  	/* kill the packet */
> -	SMC_WAIT_MMU_BUSY();
> -	SMC_SET_MMU_CMD(MC_FREEPKT);
> +	SMC_WAIT_MMU_BUSY(lp);
> +	SMC_SET_MMU_CMD(lp, MC_FREEPKT);
>  
>  	/* Don't restore Packet Number Reg until busy bit is cleared */
> -	SMC_WAIT_MMU_BUSY();
> -	SMC_SET_PN(saved_packet);
> +	SMC_WAIT_MMU_BUSY(lp);
> +	SMC_SET_PN(lp, saved_packet);
>  
>  	/* re-enable transmit */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_TCR(lp->tcr_cur_mode);
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_TCR(lp, lp->tcr_cur_mode);
> +	SMC_SELECT_BANK(lp, 2);
>  }
>  
>  
> @@ -793,7 +793,7 @@ static void smc_mii_out(struct net_devic
>  	void __iomem *ioaddr = lp->base;
>  	unsigned int mii_reg, mask;
>  
> -	mii_reg = SMC_GET_MII() & ~(MII_MCLK | MII_MDOE | MII_MDO);
> +	mii_reg = SMC_GET_MII(lp) & ~(MII_MCLK | MII_MDOE | MII_MDO);
>  	mii_reg |= MII_MDOE;
>  
>  	for (mask = 1 << (bits - 1); mask; mask >>= 1) {
> @@ -802,9 +802,9 @@ static void smc_mii_out(struct net_devic
>  		else
>  			mii_reg &= ~MII_MDO;
>  
> -		SMC_SET_MII(mii_reg);
> +		SMC_SET_MII(lp, mii_reg);
>  		udelay(MII_DELAY);
> -		SMC_SET_MII(mii_reg | MII_MCLK);
> +		SMC_SET_MII(lp, mii_reg | MII_MCLK);
>  		udelay(MII_DELAY);
>  	}
>  }
> @@ -815,16 +815,16 @@ static unsigned int smc_mii_in(struct ne
>  	void __iomem *ioaddr = lp->base;
>  	unsigned int mii_reg, mask, val;
>  
> -	mii_reg = SMC_GET_MII() & ~(MII_MCLK | MII_MDOE | MII_MDO);
> -	SMC_SET_MII(mii_reg);
> +	mii_reg = SMC_GET_MII(lp) & ~(MII_MCLK | MII_MDOE | MII_MDO);
> +	SMC_SET_MII(lp, mii_reg);
>  
>  	for (mask = 1 << (bits - 1), val = 0; mask; mask >>= 1) {
> -		if (SMC_GET_MII() & MII_MDI)
> +		if (SMC_GET_MII(lp) & MII_MDI)
>  			val |= mask;
>  
> -		SMC_SET_MII(mii_reg);
> +		SMC_SET_MII(lp, mii_reg);
>  		udelay(MII_DELAY);
> -		SMC_SET_MII(mii_reg | MII_MCLK);
> +		SMC_SET_MII(lp, mii_reg | MII_MCLK);
>  		udelay(MII_DELAY);
>  	}
>  
> @@ -840,7 +840,7 @@ static int smc_phy_read(struct net_devic
>  	void __iomem *ioaddr = lp->base;
>  	unsigned int phydata;
>  
> -	SMC_SELECT_BANK(3);
> +	SMC_SELECT_BANK(lp, 3);
>  
>  	/* Idle - 32 ones */
>  	smc_mii_out(dev, 0xffffffff, 32);
> @@ -852,12 +852,12 @@ static int smc_phy_read(struct net_devic
>  	phydata = smc_mii_in(dev, 18);
>  
>  	/* Return to idle state */
> -	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
> +	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
>  
>  	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
>  		__FUNCTION__, phyaddr, phyreg, phydata);
>  
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 2);
>  	return phydata;
>  }
>  
> @@ -870,7 +870,7 @@ static void smc_phy_write(struct net_dev
>  	struct smc_local *lp = netdev_priv(dev);
>  	void __iomem *ioaddr = lp->base;
>  
> -	SMC_SELECT_BANK(3);
> +	SMC_SELECT_BANK(lp, 3);
>  
>  	/* Idle - 32 ones */
>  	smc_mii_out(dev, 0xffffffff, 32);
> @@ -879,12 +879,12 @@ static void smc_phy_write(struct net_dev
>  	smc_mii_out(dev, 5 << 28 | phyaddr << 23 | phyreg << 18 | 2 << 16 | phydata, 32);
>  
>  	/* Return to idle state */
> -	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
> +	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
>  
>  	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
>  		__FUNCTION__, phyaddr, phyreg, phydata);
>  
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 2);
>  }
>  
>  /*
> @@ -957,9 +957,9 @@ static int smc_phy_fixed(struct net_devi
>  	smc_phy_write(dev, phyaddr, MII_BMCR, bmcr);
>  
>  	/* Re-Configure the Receive/Phy Control register */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RPC(lp->rpc_cur_mode);
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RPC(lp, lp->rpc_cur_mode);
> +	SMC_SELECT_BANK(lp, 2);
>  
>  	return 1;
>  }
> @@ -1050,8 +1050,8 @@ static void smc_phy_check_media(struct n
>  			lp->tcr_cur_mode &= ~TCR_SWFDUP;
>  		}
>  
> -		SMC_SELECT_BANK(0);
> -		SMC_SET_TCR(lp->tcr_cur_mode);
> +		SMC_SELECT_BANK(lp, 0);
> +		SMC_SET_TCR(lp, lp->tcr_cur_mode);
>  	}
>  }
>  
> @@ -1100,8 +1100,8 @@ static void smc_phy_configure(struct wor
>  		PHY_INT_SPDDET | PHY_INT_DPLXDET);
>  
>  	/* Configure the Receive/Phy Control register */
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RPC(lp->rpc_cur_mode);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RPC(lp, lp->rpc_cur_mode);
>  
>  	/* If the user requested no auto neg, then go set his request */
>  	if (lp->mii.force_media) {
> @@ -1158,7 +1158,7 @@ static void smc_phy_configure(struct wor
>  	smc_phy_check_media(dev, 1);
>  
>  smc_phy_configure_exit:
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 2);
>  	spin_unlock_irq(&lp->lock);
>  	lp->work_pending = 0;
>  }
> @@ -1200,9 +1200,9 @@ static void smc_10bt_check_media(struct 
>  
>  	old_carrier = netif_carrier_ok(dev) ? 1 : 0;
>  
> -	SMC_SELECT_BANK(0);
> -	new_carrier = (SMC_GET_EPH_STATUS() & ES_LINK_OK) ? 1 : 0;
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 0);
> +	new_carrier = (SMC_GET_EPH_STATUS(lp) & ES_LINK_OK) ? 1 : 0;
> +	SMC_SELECT_BANK(lp, 2);
>  
>  	if (init || (old_carrier != new_carrier)) {
>  		if (!new_carrier) {
> @@ -1224,11 +1224,11 @@ static void smc_eph_interrupt(struct net
>  
>  	smc_10bt_check_media(dev, 0);
>  
> -	SMC_SELECT_BANK(1);
> -	ctl = SMC_GET_CTL();
> -	SMC_SET_CTL(ctl & ~CTL_LE_ENABLE);
> -	SMC_SET_CTL(ctl);
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 1);
> +	ctl = SMC_GET_CTL(lp);
> +	SMC_SET_CTL(lp, ctl & ~CTL_LE_ENABLE);
> +	SMC_SET_CTL(lp, ctl);
> +	SMC_SELECT_BANK(lp, 2);
>  }
>  
>  /*
> @@ -1252,22 +1252,22 @@ static irqreturn_t smc_interrupt(int irq
>  	 * ISR. */
>  	SMC_INTERRUPT_PREAMBLE;
>  
> -	saved_pointer = SMC_GET_PTR();
> -	mask = SMC_GET_INT_MASK();
> -	SMC_SET_INT_MASK(0);
> +	saved_pointer = SMC_GET_PTR(lp);
> +	mask = SMC_GET_INT_MASK(lp);
> +	SMC_SET_INT_MASK(lp, 0);
>  
>  	/* set a timeout value, so I don't stay here forever */
>  	timeout = MAX_IRQ_LOOPS;
>  
>  	do {
> -		status = SMC_GET_INT();
> +		status = SMC_GET_INT(lp);
>  
>  		DBG(2, "%s: INT 0x%02x MASK 0x%02x MEM 0x%04x FIFO 0x%04x\n",
>  			dev->name, status, mask,
> -			({ int meminfo; SMC_SELECT_BANK(0);
> -			   meminfo = SMC_GET_MIR();
> -			   SMC_SELECT_BANK(2); meminfo; }),
> -			SMC_GET_FIFO());
> +			({ int meminfo; SMC_SELECT_BANK(lp, 0);
> +			   meminfo = SMC_GET_MIR(lp);
> +			   SMC_SELECT_BANK(lp, 2); meminfo; }),
> +			SMC_GET_FIFO(lp));
>  
>  		status &= mask;
>  		if (!status)
> @@ -1277,7 +1277,7 @@ static irqreturn_t smc_interrupt(int irq
>  			/* do this before RX as it will free memory quickly */
>  			DBG(3, "%s: TX int\n", dev->name);
>  			smc_tx(dev);
> -			SMC_ACK_INT(IM_TX_INT);
> +			SMC_ACK_INT(lp, IM_TX_INT);
>  			if (THROTTLE_TX_PKTS)
>  				netif_wake_queue(dev);
>  		} else if (status & IM_RCV_INT) {
> @@ -1292,9 +1292,9 @@ static irqreturn_t smc_interrupt(int irq
>  			mask &= ~IM_TX_EMPTY_INT;
>  
>  			/* update stats */
> -			SMC_SELECT_BANK(0);
> -			card_stats = SMC_GET_COUNTER();
> -			SMC_SELECT_BANK(2);
> +			SMC_SELECT_BANK(lp, 0);
> +			card_stats = SMC_GET_COUNTER(lp);
> +			SMC_SELECT_BANK(lp, 2);
>  
>  			/* single collisions */
>  			dev->stats.collisions += card_stats & 0xF;
> @@ -1304,26 +1304,26 @@ static irqreturn_t smc_interrupt(int irq
>  			dev->stats.collisions += card_stats & 0xF;
>  		} else if (status & IM_RX_OVRN_INT) {
>  			DBG(1, "%s: RX overrun (EPH_ST 0x%04x)\n", dev->name,
> -			       ({ int eph_st; SMC_SELECT_BANK(0);
> -				  eph_st = SMC_GET_EPH_STATUS();
> -				  SMC_SELECT_BANK(2); eph_st; }) );
> -			SMC_ACK_INT(IM_RX_OVRN_INT);
> +			       ({ int eph_st; SMC_SELECT_BANK(lp, 0);
> +				  eph_st = SMC_GET_EPH_STATUS(lp);
> +				  SMC_SELECT_BANK(lp, 2); eph_st; }));
> +			SMC_ACK_INT(lp, IM_RX_OVRN_INT);
>  			dev->stats.rx_errors++;
>  			dev->stats.rx_fifo_errors++;
>  		} else if (status & IM_EPH_INT) {
>  			smc_eph_interrupt(dev);
>  		} else if (status & IM_MDINT) {
> -			SMC_ACK_INT(IM_MDINT);
> +			SMC_ACK_INT(lp, IM_MDINT);
>  			smc_phy_interrupt(dev);
>  		} else if (status & IM_ERCV_INT) {
> -			SMC_ACK_INT(IM_ERCV_INT);
> +			SMC_ACK_INT(lp, IM_ERCV_INT);
>  			PRINTK("%s: UNSUPPORTED: ERCV INTERRUPT \n", dev->name);
>  		}
>  	} while (--timeout);
>  
>  	/* restore register states */
> -	SMC_SET_PTR(saved_pointer);
> -	SMC_SET_INT_MASK(mask);
> +	SMC_SET_PTR(lp, saved_pointer);
> +	SMC_SET_INT_MASK(lp, mask);
>  	spin_unlock(&lp->lock);
>  
>  	if (timeout == MAX_IRQ_LOOPS)
> @@ -1366,13 +1366,13 @@ static void smc_timeout(struct net_devic
>  	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
>  
>  	spin_lock_irq(&lp->lock);
> -	status = SMC_GET_INT();
> -	mask = SMC_GET_INT_MASK();
> -	fifo = SMC_GET_FIFO();
> -	SMC_SELECT_BANK(0);
> -	eph_st = SMC_GET_EPH_STATUS();
> -	meminfo = SMC_GET_MIR();
> -	SMC_SELECT_BANK(2);
> +	status = SMC_GET_INT(lp);
> +	mask = SMC_GET_INT_MASK(lp);
> +	fifo = SMC_GET_FIFO(lp);
> +	SMC_SELECT_BANK(lp, 0);
> +	eph_st = SMC_GET_EPH_STATUS(lp);
> +	meminfo = SMC_GET_MIR(lp);
> +	SMC_SELECT_BANK(lp, 2);
>  	spin_unlock_irq(&lp->lock);
>  	PRINTK( "%s: TX timeout (INT 0x%02x INTMASK 0x%02x "
>  		"MEM 0x%04x FIFO 0x%04x EPH_ST 0x%04x)\n",
> @@ -1492,13 +1492,13 @@ static void smc_set_multicast_list(struc
>  	}
>  
>  	spin_lock_irq(&lp->lock);
> -	SMC_SELECT_BANK(0);
> -	SMC_SET_RCR(lp->rcr_cur_mode);
> +	SMC_SELECT_BANK(lp, 0);
> +	SMC_SET_RCR(lp, lp->rcr_cur_mode);
>  	if (update_multicast) {
> -		SMC_SELECT_BANK(3);
> -		SMC_SET_MCAST(multicast_table);
> +		SMC_SELECT_BANK(lp, 3);
> +		SMC_SET_MCAST(lp, multicast_table);
>  	}
> -	SMC_SELECT_BANK(2);
> +	SMC_SELECT_BANK(lp, 2);
>  	spin_unlock_irq(&lp->lock);
>  }
>  
> @@ -1702,8 +1702,9 @@ static const struct ethtool_ops smc_etht
>   * I just deleted auto_irq.c, since it was never built...
>   *   --jgarzik
>   */
> -static int __init smc_findirq(void __iomem *ioaddr)
> +static int __init smc_findirq(struct smc_local *lp)
>  {
> +	void __iomem *ioaddr = lp->base;
>  	int timeout = 20;
>  	unsigned long cookie;
>  
> @@ -1717,14 +1718,14 @@ static int __init smc_findirq(void __iom
>  	 * when done.
>  	 */
>  	/* enable ALLOCation interrupts ONLY */
> -	SMC_SELECT_BANK(2);
> -	SMC_SET_INT_MASK(IM_ALLOC_INT);
> +	SMC_SELECT_BANK(lp, 2);
> +	SMC_SET_INT_MASK(lp, IM_ALLOC_INT);
>  
>  	/*
>   	 * Allocate 512 bytes of memory.  Note that the chip was just
>  	 * reset so all the memory is available
>  	 */
> -	SMC_SET_MMU_CMD(MC_ALLOC | 1);
> +	SMC_SET_MMU_CMD(lp, MC_ALLOC | 1);
>  
>  	/*
>  	 * Wait until positive that the interrupt has been generated
> @@ -1732,7 +1733,7 @@ static int __init smc_findirq(void __iom
>  	do {
>  		int int_status;
>  		udelay(10);
> -		int_status = SMC_GET_INT();
> +		int_status = SMC_GET_INT(lp);
>  		if (int_status & IM_ALLOC_INT)
>  			break;		/* got the interrupt */
>  	} while (--timeout);
> @@ -1745,7 +1746,7 @@ static int __init smc_findirq(void __iom
>  	 */
>  
>  	/* and disable all interrupts again */
> -	SMC_SET_INT_MASK(0);
> +	SMC_SET_INT_MASK(lp, 0);
>  
>  	/* and return what I found */
>  	return probe_irq_off(cookie);
> @@ -1788,7 +1789,7 @@ static int __init smc_probe(struct net_d
>  	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
>  
>  	/* First, see if the high byte is 0x33 */
> -	val = SMC_CURRENT_BANK();
> +	val = SMC_CURRENT_BANK(lp);
>  	DBG(2, "%s: bank signature probe returned 0x%04x\n", CARDNAME, val);
>  	if ((val & 0xFF00) != 0x3300) {
>  		if ((val & 0xFF) == 0x33) {
> @@ -1804,8 +1805,8 @@ static int __init smc_probe(struct net_d
>  	 * The above MIGHT indicate a device, but I need to write to
>  	 * further test this.
>  	 */
> -	SMC_SELECT_BANK(0);
> -	val = SMC_CURRENT_BANK();
> +	SMC_SELECT_BANK(lp, 0);
> +	val = SMC_CURRENT_BANK(lp);
>  	if ((val & 0xFF00) != 0x3300) {
>  		retval = -ENODEV;
>  		goto err_out;
> @@ -1817,8 +1818,8 @@ static int __init smc_probe(struct net_d
>  	 * register to bank 1, so I can access the base address
>  	 * register
>  	 */
> -	SMC_SELECT_BANK(1);
> -	val = SMC_GET_BASE();
> +	SMC_SELECT_BANK(lp, 1);
> +	val = SMC_GET_BASE(lp);
>  	val = ((val & 0x1F00) >> 3) << SMC_IO_SHIFT;
>  	if (((unsigned int)ioaddr & (0x3e0 << SMC_IO_SHIFT)) != val) {
>  		printk("%s: IOADDR %p doesn't match configuration (%x).\n",
> @@ -1830,8 +1831,8 @@ static int __init smc_probe(struct net_d
>  	 * recognize.  These might need to be added to later,
>  	 * as future revisions could be added.
>  	 */
> -	SMC_SELECT_BANK(3);
> -	revision_register = SMC_GET_REV();
> +	SMC_SELECT_BANK(lp, 3);
> +	revision_register = SMC_GET_REV(lp);
>  	DBG(2, "%s: revision = 0x%04x\n", CARDNAME, revision_register);
>  	version_string = chip_ids[ (revision_register >> 4) & 0xF];
>  	if (!version_string || (revision_register & 0xff00) != 0x3300) {
> @@ -1855,8 +1856,8 @@ static int __init smc_probe(struct net_d
>  	spin_lock_init(&lp->lock);
>  
>  	/* Get the MAC address */
> -	SMC_SELECT_BANK(1);
> -	SMC_GET_MAC_ADDR(dev->dev_addr);
> +	SMC_SELECT_BANK(lp, 1);
> +	SMC_GET_MAC_ADDR(lp, dev->dev_addr);
>  
>  	/* now, reset the chip, and put it into a known state */
>  	smc_reset(dev);
> @@ -1881,7 +1882,7 @@ static int __init smc_probe(struct net_d
>  
>  		trials = 3;
>  		while (trials--) {
> -			dev->irq = smc_findirq(ioaddr);
> +			dev->irq = smc_findirq(lp);
>  			if (dev->irq)
>  				break;
>  			/* kick the card and try again */
> --- 0001/drivers/net/smc91x.h
> +++ work/drivers/net/smc91x.h	2008-02-22 14:05:18.000000000 +0900
> @@ -720,7 +720,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Transmit Control Register
>  /* BANK 0  */
> -#define TCR_REG 	SMC_REG(0x0000, 0)
> +#define TCR_REG(lp) 	SMC_REG(lp, 0x0000, 0)
>  #define TCR_ENABLE	0x0001	// When 1 we can transmit
>  #define TCR_LOOP	0x0002	// Controls output pin LBK
>  #define TCR_FORCOL	0x0004	// When 1 will force a collision
> @@ -739,7 +739,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // EPH Status Register
>  /* BANK 0  */
> -#define EPH_STATUS_REG	SMC_REG(0x0002, 0)
> +#define EPH_STATUS_REG(lp)	SMC_REG(lp, 0x0002, 0)
>  #define ES_TX_SUC	0x0001	// Last TX was successful
>  #define ES_SNGL_COL	0x0002	// Single collision detected for last tx
>  #define ES_MUL_COL	0x0004	// Multiple collisions detected for last tx
> @@ -758,7 +758,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Receive Control Register
>  /* BANK 0  */
> -#define RCR_REG		SMC_REG(0x0004, 0)
> +#define RCR_REG(lp)		SMC_REG(lp, 0x0004, 0)
>  #define RCR_RX_ABORT	0x0001	// Set if a rx frame was aborted
>  #define RCR_PRMS	0x0002	// Enable promiscuous mode
>  #define RCR_ALMUL	0x0004	// When set accepts all multicast frames
> @@ -775,17 +775,17 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Counter Register
>  /* BANK 0  */
> -#define COUNTER_REG	SMC_REG(0x0006, 0)
> +#define COUNTER_REG(lp)	SMC_REG(lp, 0x0006, 0)
>  
>  
>  // Memory Information Register
>  /* BANK 0  */
> -#define MIR_REG		SMC_REG(0x0008, 0)
> +#define MIR_REG(lp)		SMC_REG(lp, 0x0008, 0)
>  
>  
>  // Receive/Phy Control Register
>  /* BANK 0  */
> -#define RPC_REG		SMC_REG(0x000A, 0)
> +#define RPC_REG(lp)		SMC_REG(lp, 0x000A, 0)
>  #define RPC_SPEED	0x2000	// When 1 PHY is in 100Mbps mode.
>  #define RPC_DPLX	0x1000	// When 1 PHY is in Full-Duplex Mode
>  #define RPC_ANEG	0x0800	// When 1 PHY is in Auto-Negotiate Mode
> @@ -819,7 +819,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Configuration Reg
>  /* BANK 1 */
> -#define CONFIG_REG	SMC_REG(0x0000,	1)
> +#define CONFIG_REG(lp)	SMC_REG(lp, 0x0000,	1)
>  #define CONFIG_EXT_PHY	0x0200	// 1=external MII, 0=internal Phy
>  #define CONFIG_GPCNTRL	0x0400	// Inverse value drives pin nCNTRL
>  #define CONFIG_NO_WAIT	0x1000	// When 1 no extra wait states on ISA bus
> @@ -831,24 +831,24 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Base Address Register
>  /* BANK 1 */
> -#define BASE_REG	SMC_REG(0x0002, 1)
> +#define BASE_REG(lp)	SMC_REG(lp, 0x0002, 1)
>  
>  
>  // Individual Address Registers
>  /* BANK 1 */
> -#define ADDR0_REG	SMC_REG(0x0004, 1)
> -#define ADDR1_REG	SMC_REG(0x0006, 1)
> -#define ADDR2_REG	SMC_REG(0x0008, 1)
> +#define ADDR0_REG(lp)	SMC_REG(lp, 0x0004, 1)
> +#define ADDR1_REG(lp)	SMC_REG(lp, 0x0006, 1)
> +#define ADDR2_REG(lp)	SMC_REG(lp, 0x0008, 1)
>  
>  
>  // General Purpose Register
>  /* BANK 1 */
> -#define GP_REG		SMC_REG(0x000A, 1)
> +#define GP_REG(lp)		SMC_REG(lp, 0x000A, 1)
>  
>  
>  // Control Register
>  /* BANK 1 */
> -#define CTL_REG		SMC_REG(0x000C, 1)
> +#define CTL_REG(lp)		SMC_REG(lp, 0x000C, 1)
>  #define CTL_RCV_BAD	0x4000 // When 1 bad CRC packets are received
>  #define CTL_AUTO_RELEASE 0x0800 // When 1 tx pages are released automatically
>  #define CTL_LE_ENABLE	0x0080 // When 1 enables Link Error interrupt
> @@ -861,7 +861,7 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // MMU Command Register
>  /* BANK 2 */
> -#define MMU_CMD_REG	SMC_REG(0x0000, 2)
> +#define MMU_CMD_REG(lp)	SMC_REG(lp, 0x0000, 2)
>  #define MC_BUSY		1	// When 1 the last release has not completed
>  #define MC_NOP		(0<<5)	// No Op
>  #define MC_ALLOC	(1<<5) 	// OR with number of 256 byte packets
> @@ -875,30 +875,30 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Packet Number Register
>  /* BANK 2 */
> -#define PN_REG		SMC_REG(0x0002, 2)
> +#define PN_REG(lp)		SMC_REG(lp, 0x0002, 2)
>  
>  
>  // Allocation Result Register
>  /* BANK 2 */
> -#define AR_REG		SMC_REG(0x0003, 2)
> +#define AR_REG(lp)		SMC_REG(lp, 0x0003, 2)
>  #define AR_FAILED	0x80	// Alocation Failed
>  
>  
>  // TX FIFO Ports Register
>  /* BANK 2 */
> -#define TXFIFO_REG	SMC_REG(0x0004, 2)
> +#define TXFIFO_REG(lp)	SMC_REG(lp, 0x0004, 2)
>  #define TXFIFO_TEMPTY	0x80	// TX FIFO Empty
>  
>  // RX FIFO Ports Register
>  /* BANK 2 */
> -#define RXFIFO_REG	SMC_REG(0x0005, 2)
> +#define RXFIFO_REG(lp)	SMC_REG(lp, 0x0005, 2)
>  #define RXFIFO_REMPTY	0x80	// RX FIFO Empty
>  
> -#define FIFO_REG	SMC_REG(0x0004, 2)
> +#define FIFO_REG(lp)	SMC_REG(lp, 0x0004, 2)
>  
>  // Pointer Register
>  /* BANK 2 */
> -#define PTR_REG		SMC_REG(0x0006, 2)
> +#define PTR_REG(lp)		SMC_REG(lp, 0x0006, 2)
>  #define PTR_RCV		0x8000 // 1=Receive area, 0=Transmit area
>  #define PTR_AUTOINC 	0x4000 // Auto increment the pointer on each access
>  #define PTR_READ	0x2000 // When 1 the operation is a read
> @@ -906,17 +906,17 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Data Register
>  /* BANK 2 */
> -#define DATA_REG	SMC_REG(0x0008, 2)
> +#define DATA_REG(lp)	SMC_REG(lp, 0x0008, 2)
>  
>  
>  // Interrupt Status/Acknowledge Register
>  /* BANK 2 */
> -#define INT_REG		SMC_REG(0x000C, 2)
> +#define INT_REG(lp)		SMC_REG(lp, 0x000C, 2)
>  
>  
>  // Interrupt Mask Register
>  /* BANK 2 */
> -#define IM_REG		SMC_REG(0x000D, 2)
> +#define IM_REG(lp)		SMC_REG(lp, 0x000D, 2)
>  #define IM_MDINT	0x80 // PHY MI Register 18 Interrupt
>  #define IM_ERCV_INT	0x40 // Early Receive Interrupt
>  #define IM_EPH_INT	0x20 // Set by Ethernet Protocol Handler section
> @@ -929,15 +929,15 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  
>  // Multicast Table Registers
>  /* BANK 3 */
> -#define MCAST_REG1	SMC_REG(0x0000, 3)
> -#define MCAST_REG2	SMC_REG(0x0002, 3)
> -#define MCAST_REG3	SMC_REG(0x0004, 3)
> -#define MCAST_REG4	SMC_REG(0x0006, 3)
> +#define MCAST_REG1(lp)	SMC_REG(lp, 0x0000, 3)
> +#define MCAST_REG2(lp)	SMC_REG(lp, 0x0002, 3)
> +#define MCAST_REG3(lp)	SMC_REG(lp, 0x0004, 3)
> +#define MCAST_REG4(lp)	SMC_REG(lp, 0x0006, 3)
>  
>  
>  // Management Interface Register (MII)
>  /* BANK 3 */
> -#define MII_REG		SMC_REG(0x0008, 3)
> +#define MII_REG(lp)		SMC_REG(lp, 0x0008, 3)
>  #define MII_MSK_CRS100	0x4000 // Disables CRS100 detection during tx half dup
>  #define MII_MDOE	0x0008 // MII Output Enable
>  #define MII_MCLK	0x0004 // MII Clock, pin MDCLK
> @@ -948,20 +948,20 @@ smc_pxa_dma_irq(int dma, void *dummy)
>  // Revision Register
>  /* BANK 3 */
>  /* ( hi: chip id   low: rev # ) */
> -#define REV_REG		SMC_REG(0x000A, 3)
> +#define REV_REG(lp)		SMC_REG(lp, 0x000A, 3)
>  
>  
>  // Early RCV Register
>  /* BANK 3 */
>  /* this is NOT on SMC9192 */
> -#define ERCV_REG	SMC_REG(0x000C, 3)
> +#define ERCV_REG(lp)	SMC_REG(lp, 0x000C, 3)
>  #define ERCV_RCV_DISCRD	0x0080 // When 1 discards a packet being received
>  #define ERCV_THRESHOLD	0x001F // ERCV Threshold Mask
>  
>  
>  // External Register
>  /* BANK 7 */
> -#define EXT_REG		SMC_REG(0x0000, 7)
> +#define EXT_REG(lp)		SMC_REG(lp, 0x0000, 7)
>  
>  
>  #define CHIP_9192	3
> @@ -1085,9 +1085,9 @@ static const char * chip_ids[ 16 ] =  {
>   */
>  
>  #if SMC_DEBUG > 0
> -#define SMC_REG(reg, bank)						\
> +#define SMC_REG(lp, reg, bank)					\
>  	({								\
> -		int __b = SMC_CURRENT_BANK();				\
> +		int __b = SMC_CURRENT_BANK(lp);			\
>  		if (unlikely((__b & ~0xf0) != (0x3300 | bank))) {	\
>  			printk( "%s: bank reg screwed (0x%04x)\n",	\
>  				CARDNAME, __b );			\
> @@ -1096,7 +1096,7 @@ static const char * chip_ids[ 16 ] =  {
>  		reg<<SMC_IO_SHIFT;					\
>  	})
>  #else
> -#define SMC_REG(reg, bank)	(reg<<SMC_IO_SHIFT)
> +#define SMC_REG(lp, reg, bank)	(reg<<SMC_IO_SHIFT)
>  #endif
>  
>  /*
> @@ -1110,65 +1110,65 @@ static const char * chip_ids[ 16 ] =  {
>   */
>  #define SMC_MUST_ALIGN_WRITE	SMC_CAN_USE_32BIT
>  
> -#define SMC_GET_PN()							\
> -	( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, PN_REG))		\
> -				: (SMC_inw(ioaddr, PN_REG) & 0xFF) )
> +#define SMC_GET_PN(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, PN_REG(lp)))	\
> +				: (SMC_inw(ioaddr, PN_REG(lp)) & 0xFF))
>  
> -#define SMC_SET_PN(x)							\
> +#define SMC_SET_PN(lp, x)						\
>  	do {								\
>  		if (SMC_MUST_ALIGN_WRITE)				\
> -			SMC_outl((x)<<16, ioaddr, SMC_REG(0, 2));	\
> +			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 0, 2));	\
>  		else if (SMC_CAN_USE_8BIT)				\
> -			SMC_outb(x, ioaddr, PN_REG);			\
> +			SMC_outb(x, ioaddr, PN_REG(lp));		\
>  		else							\
> -			SMC_outw(x, ioaddr, PN_REG);			\
> +			SMC_outw(x, ioaddr, PN_REG(lp));		\
>  	} while (0)
>  
> -#define SMC_GET_AR()							\
> -	( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, AR_REG))		\
> -	  			: (SMC_inw(ioaddr, PN_REG) >> 8) )
> +#define SMC_GET_AR(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, AR_REG(lp)))	\
> +				: (SMC_inw(ioaddr, PN_REG(lp)) >> 8))
>  
> -#define SMC_GET_TXFIFO()						\
> -	( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, TXFIFO_REG))		\
> -				: (SMC_inw(ioaddr, TXFIFO_REG) & 0xFF) )
> +#define SMC_GET_TXFIFO(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, TXFIFO_REG(lp)))	\
> +				: (SMC_inw(ioaddr, TXFIFO_REG(lp)) & 0xFF))
>  
> -#define SMC_GET_RXFIFO()						\
> -	  ( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, RXFIFO_REG))		\
> -				: (SMC_inw(ioaddr, TXFIFO_REG) >> 8) )
> +#define SMC_GET_RXFIFO(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, RXFIFO_REG(lp)))	\
> +				: (SMC_inw(ioaddr, TXFIFO_REG(lp)) >> 8))
>  
> -#define SMC_GET_INT()							\
> -	( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, INT_REG))		\
> -				: (SMC_inw(ioaddr, INT_REG) & 0xFF) )
> +#define SMC_GET_INT(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, INT_REG(lp)))	\
> +				: (SMC_inw(ioaddr, INT_REG(lp)) & 0xFF))
>  
> -#define SMC_ACK_INT(x)							\
> +#define SMC_ACK_INT(lp, x)						\
>  	do {								\
>  		if (SMC_CAN_USE_8BIT)					\
> -			SMC_outb(x, ioaddr, INT_REG);			\
> +			SMC_outb(x, ioaddr, INT_REG(lp));		\
>  		else {							\
>  			unsigned long __flags;				\
>  			int __mask;					\
>  			local_irq_save(__flags);			\
> -			__mask = SMC_inw( ioaddr, INT_REG ) & ~0xff;	\
> -			SMC_outw( __mask | (x), ioaddr, INT_REG );	\
> +			__mask = SMC_inw(ioaddr, INT_REG(lp)) & ~0xff; \
> +			SMC_outw(__mask | (x), ioaddr, INT_REG(lp));	\
>  			local_irq_restore(__flags);			\
>  		}							\
>  	} while (0)
>  
> -#define SMC_GET_INT_MASK()						\
> -	( SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, IM_REG))		\
> -				: (SMC_inw( ioaddr, INT_REG ) >> 8) )
> +#define SMC_GET_INT_MASK(lp)						\
> +	(SMC_CAN_USE_8BIT	? (SMC_inb(ioaddr, IM_REG(lp)))	\
> +				: (SMC_inw(ioaddr, INT_REG(lp)) >> 8))
>  
> -#define SMC_SET_INT_MASK(x)						\
> +#define SMC_SET_INT_MASK(lp, x)					\
>  	do {								\
>  		if (SMC_CAN_USE_8BIT)					\
> -			SMC_outb(x, ioaddr, IM_REG);			\
> +			SMC_outb(x, ioaddr, IM_REG(lp));		\
>  		else							\
> -			SMC_outw((x) << 8, ioaddr, INT_REG);		\
> +			SMC_outw((x) << 8, ioaddr, INT_REG(lp));	\
>  	} while (0)
>  
> -#define SMC_CURRENT_BANK()	SMC_inw(ioaddr, BANK_SELECT)
> +#define SMC_CURRENT_BANK(lp)	SMC_inw(ioaddr, BANK_SELECT)
>  
> -#define SMC_SELECT_BANK(x)						\
> +#define SMC_SELECT_BANK(lp, x)					\
>  	do {								\
>  		if (SMC_MUST_ALIGN_WRITE)				\
>  			SMC_outl((x)<<16, ioaddr, 12<<SMC_IO_SHIFT);	\
> @@ -1176,118 +1176,119 @@ static const char * chip_ids[ 16 ] =  {
>  			SMC_outw(x, ioaddr, BANK_SELECT);		\
>  	} while (0)
>  
> -#define SMC_GET_BASE()		SMC_inw(ioaddr, BASE_REG)
> +#define SMC_GET_BASE(lp)		SMC_inw(ioaddr, BASE_REG(lp))
>  
> -#define SMC_SET_BASE(x)		SMC_outw(x, ioaddr, BASE_REG)
> +#define SMC_SET_BASE(lp, x)		SMC_outw(x, ioaddr, BASE_REG(lp))
>  
> -#define SMC_GET_CONFIG()	SMC_inw(ioaddr, CONFIG_REG)
> +#define SMC_GET_CONFIG(lp)	SMC_inw(ioaddr, CONFIG_REG(lp))
>  
> -#define SMC_SET_CONFIG(x)	SMC_outw(x, ioaddr, CONFIG_REG)
> +#define SMC_SET_CONFIG(lp, x)	SMC_outw(x, ioaddr, CONFIG_REG(lp))
>  
> -#define SMC_GET_COUNTER()	SMC_inw(ioaddr, COUNTER_REG)
> +#define SMC_GET_COUNTER(lp)	SMC_inw(ioaddr, COUNTER_REG(lp))
>  
> -#define SMC_GET_CTL()		SMC_inw(ioaddr, CTL_REG)
> +#define SMC_GET_CTL(lp)		SMC_inw(ioaddr, CTL_REG(lp))
>  
> -#define SMC_SET_CTL(x)		SMC_outw(x, ioaddr, CTL_REG)
> +#define SMC_SET_CTL(lp, x)		SMC_outw(x, ioaddr, CTL_REG(lp))
>  
> -#define SMC_GET_MII()		SMC_inw(ioaddr, MII_REG)
> +#define SMC_GET_MII(lp)		SMC_inw(ioaddr, MII_REG(lp))
>  
> -#define SMC_SET_MII(x)		SMC_outw(x, ioaddr, MII_REG)
> +#define SMC_SET_MII(lp, x)		SMC_outw(x, ioaddr, MII_REG(lp))
>  
> -#define SMC_GET_MIR()		SMC_inw(ioaddr, MIR_REG)
> +#define SMC_GET_MIR(lp)		SMC_inw(ioaddr, MIR_REG(lp))
>  
> -#define SMC_SET_MIR(x)		SMC_outw(x, ioaddr, MIR_REG)
> +#define SMC_SET_MIR(lp, x)		SMC_outw(x, ioaddr, MIR_REG(lp))
>  
> -#define SMC_GET_MMU_CMD()	SMC_inw(ioaddr, MMU_CMD_REG)
> +#define SMC_GET_MMU_CMD(lp)	SMC_inw(ioaddr, MMU_CMD_REG(lp))
>  
> -#define SMC_SET_MMU_CMD(x)	SMC_outw(x, ioaddr, MMU_CMD_REG)
> +#define SMC_SET_MMU_CMD(lp, x)	SMC_outw(x, ioaddr, MMU_CMD_REG(lp))
>  
> -#define SMC_GET_FIFO()		SMC_inw(ioaddr, FIFO_REG)
> +#define SMC_GET_FIFO(lp)		SMC_inw(ioaddr, FIFO_REG(lp))
>  
> -#define SMC_GET_PTR()		SMC_inw(ioaddr, PTR_REG)
> +#define SMC_GET_PTR(lp)		SMC_inw(ioaddr, PTR_REG(lp))
>  
> -#define SMC_SET_PTR(x)							\
> +#define SMC_SET_PTR(lp, x)						\
>  	do {								\
>  		if (SMC_MUST_ALIGN_WRITE)				\
> -			SMC_outl((x)<<16, ioaddr, SMC_REG(4, 2));	\
> +			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 4, 2));	\
>  		else							\
> -			SMC_outw(x, ioaddr, PTR_REG);			\
> +			SMC_outw(x, ioaddr, PTR_REG(lp));		\
>  	} while (0)
>  
> -#define SMC_GET_EPH_STATUS()	SMC_inw(ioaddr, EPH_STATUS_REG)
> +#define SMC_GET_EPH_STATUS(lp)	SMC_inw(ioaddr, EPH_STATUS_REG(lp))
>  
> -#define SMC_GET_RCR()		SMC_inw(ioaddr, RCR_REG)
> +#define SMC_GET_RCR(lp)		SMC_inw(ioaddr, RCR_REG(lp))
>  
> -#define SMC_SET_RCR(x)		SMC_outw(x, ioaddr, RCR_REG)
> +#define SMC_SET_RCR(lp, x)		SMC_outw(x, ioaddr, RCR_REG(lp))
>  
> -#define SMC_GET_REV()		SMC_inw(ioaddr, REV_REG)
> +#define SMC_GET_REV(lp)		SMC_inw(ioaddr, REV_REG(lp))
>  
> -#define SMC_GET_RPC()		SMC_inw(ioaddr, RPC_REG)
> +#define SMC_GET_RPC(lp)		SMC_inw(ioaddr, RPC_REG(lp))
>  
> -#define SMC_SET_RPC(x)							\
> +#define SMC_SET_RPC(lp, x)						\
>  	do {								\
>  		if (SMC_MUST_ALIGN_WRITE)				\
> -			SMC_outl((x)<<16, ioaddr, SMC_REG(8, 0));	\
> +			SMC_outl((x)<<16, ioaddr, SMC_REG(lp, 8, 0));	\
>  		else							\
> -			SMC_outw(x, ioaddr, RPC_REG);			\
> +			SMC_outw(x, ioaddr, RPC_REG(lp));		\
>  	} while (0)
>  
> -#define SMC_GET_TCR()		SMC_inw(ioaddr, TCR_REG)
> +#define SMC_GET_TCR(lp)		SMC_inw(ioaddr, TCR_REG(lp))
>  
> -#define SMC_SET_TCR(x)		SMC_outw(x, ioaddr, TCR_REG)
> +#define SMC_SET_TCR(lp, x)		SMC_outw(x, ioaddr, TCR_REG(lp))
>  
>  #ifndef SMC_GET_MAC_ADDR
> -#define SMC_GET_MAC_ADDR(addr)						\
> +#define SMC_GET_MAC_ADDR(lp, addr)					\
>  	do {								\
>  		unsigned int __v;					\
> -		__v = SMC_inw( ioaddr, ADDR0_REG );			\
> +		__v = SMC_inw(ioaddr, ADDR0_REG(lp));			\
>  		addr[0] = __v; addr[1] = __v >> 8;			\
> -		__v = SMC_inw( ioaddr, ADDR1_REG );			\
> +		__v = SMC_inw(ioaddr, ADDR1_REG(lp));			\
>  		addr[2] = __v; addr[3] = __v >> 8;			\
> -		__v = SMC_inw( ioaddr, ADDR2_REG );			\
> +		__v = SMC_inw(ioaddr, ADDR2_REG(lp));			\
>  		addr[4] = __v; addr[5] = __v >> 8;			\
>  	} while (0)
>  #endif
>  
> -#define SMC_SET_MAC_ADDR(addr)						\
> +#define SMC_SET_MAC_ADDR(lp, addr)					\
>  	do {								\
> -		SMC_outw( addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG );	\
> -		SMC_outw( addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG );	\
> -		SMC_outw( addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG );	\
> +		SMC_outw(addr[0]|(addr[1] << 8), ioaddr, ADDR0_REG(lp)); \
> +		SMC_outw(addr[2]|(addr[3] << 8), ioaddr, ADDR1_REG(lp)); \
> +		SMC_outw(addr[4]|(addr[5] << 8), ioaddr, ADDR2_REG(lp)); \
>  	} while (0)
>  
> -#define SMC_SET_MCAST(x)						\
> +#define SMC_SET_MCAST(lp, x)						\
>  	do {								\
>  		const unsigned char *mt = (x);				\
> -		SMC_outw( mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1 );	\
> -		SMC_outw( mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2 );	\
> -		SMC_outw( mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3 );	\
> -		SMC_outw( mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4 );	\
> +		SMC_outw(mt[0] | (mt[1] << 8), ioaddr, MCAST_REG1(lp)); \
> +		SMC_outw(mt[2] | (mt[3] << 8), ioaddr, MCAST_REG2(lp)); \
> +		SMC_outw(mt[4] | (mt[5] << 8), ioaddr, MCAST_REG3(lp)); \
> +		SMC_outw(mt[6] | (mt[7] << 8), ioaddr, MCAST_REG4(lp)); \
>  	} while (0)
>  
> -#define SMC_PUT_PKT_HDR(status, length)					\
> +#define SMC_PUT_PKT_HDR(lp, status, length)				\
>  	do {								\
>  		if (SMC_CAN_USE_32BIT)					\
> -			SMC_outl((status) | (length)<<16, ioaddr, DATA_REG); \
> +			SMC_outl((status) | (length)<<16, ioaddr,	\
> +				 DATA_REG(lp));			\
>  		else {							\
> -			SMC_outw(status, ioaddr, DATA_REG);		\
> -			SMC_outw(length, ioaddr, DATA_REG);		\
> +			SMC_outw(status, ioaddr, DATA_REG(lp));	\
> +			SMC_outw(length, ioaddr, DATA_REG(lp));	\
>  		}							\
>  	} while (0)
>  
> -#define SMC_GET_PKT_HDR(status, length)					\
> +#define SMC_GET_PKT_HDR(lp, status, length)				\
>  	do {								\
>  		if (SMC_CAN_USE_32BIT) {				\
> -			unsigned int __val = SMC_inl(ioaddr, DATA_REG);	\
> +			unsigned int __val = SMC_inl(ioaddr, DATA_REG(lp)); \
>  			(status) = __val & 0xffff;			\
>  			(length) = __val >> 16;				\
>  		} else {						\
> -			(status) = SMC_inw(ioaddr, DATA_REG);		\
> -			(length) = SMC_inw(ioaddr, DATA_REG);		\
> +			(status) = SMC_inw(ioaddr, DATA_REG(lp));	\
> +			(length) = SMC_inw(ioaddr, DATA_REG(lp));	\
>  		}							\
>  	} while (0)
>  
> -#define SMC_PUSH_DATA(p, l)						\
> +#define SMC_PUSH_DATA(lp, p, l)					\
>  	do {								\
>  		if (SMC_CAN_USE_32BIT) {				\
>  			void *__ptr = (p);				\
> @@ -1295,23 +1296,25 @@ static const char * chip_ids[ 16 ] =  {
>  			void __iomem *__ioaddr = ioaddr;		\
>  			if (__len >= 2 && (unsigned long)__ptr & 2) {	\
>  				__len -= 2;				\
> -				SMC_outw(*(u16 *)__ptr, ioaddr, DATA_REG); \
> +				SMC_outw(*(u16 *)__ptr, ioaddr,		\
> +					DATA_REG(lp));		\
>  				__ptr += 2;				\
>  			}						\
>  			if (SMC_CAN_USE_DATACS && lp->datacs)		\
>  				__ioaddr = lp->datacs;			\
> -			SMC_outsl(__ioaddr, DATA_REG, __ptr, __len>>2);	\
> +			SMC_outsl(__ioaddr, DATA_REG(lp), __ptr, __len>>2); \
>  			if (__len & 2) {				\
>  				__ptr += (__len & ~3);			\
> -				SMC_outw(*((u16 *)__ptr), ioaddr, DATA_REG); \
> +				SMC_outw(*((u16 *)__ptr), ioaddr,	\
> +					 DATA_REG(lp));		\
>  			}						\
>  		} else if (SMC_CAN_USE_16BIT)				\
> -			SMC_outsw(ioaddr, DATA_REG, p, (l) >> 1);	\
> +			SMC_outsw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
>  		else if (SMC_CAN_USE_8BIT)				\
> -			SMC_outsb(ioaddr, DATA_REG, p, l);		\
> +			SMC_outsb(ioaddr, DATA_REG(lp), p, l);	\
>  	} while (0)
>  
> -#define SMC_PULL_DATA(p, l)						\
> +#define SMC_PULL_DATA(lp, p, l)					\
>  	do {								\
>  		if (SMC_CAN_USE_32BIT) {				\
>  			void *__ptr = (p);				\
> @@ -1333,16 +1336,17 @@ static const char * chip_ids[ 16 ] =  {
>  				 */					\
>  				__ptr -= 2;				\
>  				__len += 2;				\
> -				SMC_SET_PTR(2|PTR_READ|PTR_RCV|PTR_AUTOINC); \
> +				SMC_SET_PTR(lp,			\
> +					2|PTR_READ|PTR_RCV|PTR_AUTOINC); \
>  			}						\
>  			if (SMC_CAN_USE_DATACS && lp->datacs)		\
>  				__ioaddr = lp->datacs;			\
>  			__len += 2;					\
> -			SMC_insl(__ioaddr, DATA_REG, __ptr, __len>>2);	\
> +			SMC_insl(__ioaddr, DATA_REG(lp), __ptr, __len>>2); \
>  		} else if (SMC_CAN_USE_16BIT)				\
> -			SMC_insw(ioaddr, DATA_REG, p, (l) >> 1);	\
> +			SMC_insw(ioaddr, DATA_REG(lp), p, (l) >> 1);	\
>  		else if (SMC_CAN_USE_8BIT)				\
> -			SMC_insb(ioaddr, DATA_REG, p, l);		\
> +			SMC_insb(ioaddr, DATA_REG(lp), p, l);		\
>  	} while (0)
>  
>  #endif  /* _SMC91X_H_ */
> 


Nicolas
