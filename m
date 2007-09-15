From: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Subject: Re: Please pull 'adm8211' branch of wireless-2.6
Date: Sat, 15 Sep 2007 17:32:40 -0400
Message-ID: <46EC4F78.4050700@garzik.org>
References: <20070915132220.GE6060@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070915132220.GE6060-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


Review summary:  many minor issues, only one major one:  irq handler loop


John W. Linville wrote:
> +static unsigned int tx_ring_size __read_mostly = 16;
> +static unsigned int rx_ring_size __read_mostly = 16;
> +
> +module_param(tx_ring_size, uint, 0);
> +module_param(rx_ring_size, uint, 0);

should be in ethtool (or another per-interface runtime config tool), not 
a module parameter.


> +static void adm8211_set_rx_mode(struct ieee80211_hw *dev,
> +				unsigned short flags, int mc_count)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned int bit_nr;
> +	u32 mc_filter[2];
> +	struct dev_mc_list *mclist;
> +	void *tmp;
> +
> +	if (flags & IFF_PROMISC) {
> +		priv->nar |= ADM8211_NAR_PR;
> +		priv->nar &= ~ADM8211_NAR_MM;
> +		mc_filter[1] = mc_filter[0] = ~0;
> +	} else if ((flags & IFF_ALLMULTI) || (mc_count > -1)) {

mc_count > -1 ?

what kind of bogus placeholder is that?


> +		priv->nar &= ~ADM8211_NAR_PR;
> +		priv->nar |= ADM8211_NAR_MM;
> +		mc_filter[1] = mc_filter[0] = ~0;
> +	} else {
> +		priv->nar &= ~(ADM8211_NAR_MM | ADM8211_NAR_PR);
> +		mc_filter[1] = mc_filter[0] = 0;
> +		mclist = NULL;
> +		while ((mclist = ieee80211_get_mc_list_item(dev, mclist, &tmp))) {
> +			bit_nr = ether_crc(ETH_ALEN, mclist->dmi_addr) >> 26;
> +
> +			bit_nr &= 0x3F;
> +			mc_filter[bit_nr >> 5] |= 1 << (bit_nr & 31);
> +		}
> +	}
> +
> +	ADM8211_IDLE_RX();
> +
> +	ADM8211_CSR_WRITE(MAR0, mc_filter[0]);
> +	ADM8211_CSR_WRITE(MAR1, mc_filter[1]);
> +	ADM8211_CSR_READ(NAR);
> +
> +	if (flags & IFF_PROMISC)
> +		dev->flags |= IEEE80211_HW_RX_INCLUDES_FCS;
> +	else
> +		dev->flags &= ~IEEE80211_HW_RX_INCLUDES_FCS;

why does promisc dictate inclusion of FCS?


> +static void adm8211_interrupt_tci(struct ieee80211_hw *dev)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned int dirty_tx;
> +
> +	spin_lock(&priv->lock);
> +
> +	for (dirty_tx = priv->dirty_tx; priv->cur_tx - dirty_tx; dirty_tx++) {
> +		unsigned int entry = dirty_tx % priv->tx_ring_size;
> +		u32 status = le32_to_cpu(priv->tx_ring[entry].status);
> +		struct adm8211_tx_ring_info *info;
> +		struct sk_buff *skb;
> +
> +		if (status & TDES0_CONTROL_OWN ||
> +		    !(status & TDES0_CONTROL_DONE))
> +			break;
> +
> +		info = &priv->tx_buffers[entry];
> +		skb = info->skb;
> +
> +		/* TODO: check TDES0_STATUS_TUF and TDES0_STATUS_TRO */
> +
> +		pci_unmap_single(priv->pdev, info->mapping,
> +				 info->skb->len, PCI_DMA_TODEVICE);
> +
> +		if (info->tx_control.flags & IEEE80211_TXCTL_REQ_TX_STATUS) {
> +			struct ieee80211_tx_status tx_status = {{0}};
> +			struct ieee80211_hdr *hdr;
> +			size_t hdrlen = info->hdrlen;
> +
> +			skb_pull(skb, sizeof(struct adm8211_tx_hdr));
> +			hdr = (struct ieee80211_hdr *)skb_push(skb, hdrlen);
> +			memcpy(hdr, skb->cb, hdrlen);
> +			memcpy(&tx_status.control, &info->tx_control,
> +			       sizeof(tx_status.control));
> +			if (!(status & TDES0_STATUS_ES))
> +				tx_status.flags |= IEEE80211_TX_STATUS_ACK;
> +			ieee80211_tx_status_irqsafe(dev, skb, &tx_status);
> +		} else
> +			dev_kfree_skb_irq(skb);
> +		info->skb = NULL;
> +	}
> +
> +	if (priv->cur_tx - dirty_tx < priv->tx_ring_size - 2)
> +		ieee80211_wake_queue(dev, 0);

not this driver's fault, but, ieee80211_wake_queue() warrants revisiting 
now that MQ stuff is in

when queue==0 is hardcoded, you can just use netif_wake/stop_queue() AFAICS


> +static void adm8211_interrupt_rci(struct ieee80211_hw *dev)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned int entry = priv->cur_rx % priv->rx_ring_size;
> +	u32 status;
> +	unsigned int pktlen;
> +	struct sk_buff *skb, *newskb;
> +	unsigned int limit = priv->rx_ring_size;
> +	static const u8 rate_tbl[] = {10, 20, 55, 110, 220};
> +	u8 rssi, rate;
> +
> +	while (!(priv->rx_ring[entry].status & cpu_to_le32(RDES0_STATUS_OWN))) {
> +		if (!limit--)
> +			break;
> +
> +		status = le32_to_cpu(priv->rx_ring[entry].status);
> +		rate = (status & RDES0_STATUS_RXDR) >> 12;
> +		rssi = le32_to_cpu(priv->rx_ring[entry].length) &
> +			RDES1_STATUS_RSSI;
> +
> +		pktlen = status & RDES0_STATUS_FL;
> +		if (pktlen > RX_PKT_SIZE) {
> +			if (net_ratelimit())
> +				printk(KERN_DEBUG "%s: frame too long (%d)\n",
> +				       wiphy_name(dev->wiphy), pktlen);
> +			pktlen = RX_PKT_SIZE;
> +		}
> +
> +		if (!priv->soft_rx_crc && status & RDES0_STATUS_ES) {
> +			skb = NULL; /* old buffer will be reused */
> +			/* TODO: update RX error stats */
> +			/* TODO: check RDES0_STATUS_CRC*E */
> +		} else if (pktlen < RX_COPY_BREAK) {
> +			skb = dev_alloc_skb(pktlen);
> +			if (skb) {
> +				pci_dma_sync_single_for_cpu(
> +					priv->pdev,
> +					priv->rx_buffers[entry].mapping,
> +					pktlen, PCI_DMA_FROMDEVICE);
> +				memcpy(skb_put(skb, pktlen),
> +				       skb_tail_pointer(priv->rx_buffers[entry].skb),
> +				       pktlen);
> +				pci_dma_sync_single_for_device(
> +					priv->pdev,
> +					priv->rx_buffers[entry].mapping,
> +					RX_PKT_SIZE, PCI_DMA_FROMDEVICE);
> +			}
> +		} else {
> +			newskb = dev_alloc_skb(RX_PKT_SIZE);
> +			if (newskb) {
> +				skb = priv->rx_buffers[entry].skb;
> +				skb_put(skb, pktlen);
> +				pci_unmap_single(
> +					priv->pdev,
> +					priv->rx_buffers[entry].mapping,
> +					RX_PKT_SIZE, PCI_DMA_FROMDEVICE);
> +				priv->rx_buffers[entry].skb = newskb;
> +				priv->rx_buffers[entry].mapping =
> +					pci_map_single(priv->pdev,
> +						       skb_tail_pointer(newskb),
> +						       RX_PKT_SIZE,
> +						       PCI_DMA_FROMDEVICE);
> +			} else {
> +				skb = NULL;
> +				/* TODO: update rx dropped stats */
> +			}
> +
> +			priv->rx_ring[entry].buffer1 =
> +				cpu_to_le32(priv->rx_buffers[entry].mapping);
> +		}
> +
> +		priv->rx_ring[entry].status = cpu_to_le32(RDES0_STATUS_OWN |
> +							  RDES0_STATUS_SQL);
> +		priv->rx_ring[entry].length =
> +			cpu_to_le32(RX_PKT_SIZE |
> +				    (entry == priv->rx_ring_size - 1 ?
> +				     RDES1_CONTROL_RER : 0));
> +
> +		if (skb) {
> +			struct ieee80211_rx_status rx_status = {0};
> +
> +			if (priv->revid < ADM8211_REV_CA)
> +				rx_status.ssi = rssi;
> +			else
> +				rx_status.ssi = 100 - rssi;
> +
> +			if (rate <= 4)
> +				rx_status.rate = rate_tbl[rate];
> +
> +			rx_status.channel = priv->channel;
> +			rx_status.freq = adm8211_channels[priv->channel - 1].freq;
> +			rx_status.phymode = MODE_IEEE80211B;
> +
> +			ieee80211_rx_irqsafe(dev, skb, &rx_status);
> +		}
> +
> +		entry = (++priv->cur_rx) % priv->rx_ring_size;

the '%' operator is expensive.  mask combined with power-of-2 is better


> +static irqreturn_t adm8211_interrupt(int irq, void *dev_id)
> +{
> +#define ADM8211_INT(x)							   \
> +do {									   \
> +	if (unlikely(stsr & ADM8211_STSR_ ## x))			   \
> +		printk(KERN_DEBUG "%s: " #x "\n", wiphy_name(dev->wiphy)); \
> +} while (0)
> +
> +	struct ieee80211_hw *dev = dev_id;
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned int count = 0;
> +	u32 stsr;
> +
> +	do {
> +		stsr = ADM8211_CSR_READ(STSR);
> +		ADM8211_CSR_WRITE(STSR, stsr);
> +		if (stsr == 0xffffffff)
> +			return IRQ_HANDLED;
> +
> +		if (!(stsr & (ADM8211_STSR_NISS | ADM8211_STSR_AISS)))
> +			break;
> +
> +		if (stsr & ADM8211_STSR_RCI)
> +			adm8211_interrupt_rci(dev);
> +		if (stsr & ADM8211_STSR_TCI)
> +			adm8211_interrupt_tci(dev);
> +
> +		/*ADM8211_INT(LinkOn);*/
> +		/*ADM8211_INT(LinkOff);*/
> +
> +		ADM8211_INT(PCF);
> +		ADM8211_INT(BCNTC);
> +		ADM8211_INT(GPINT);
> +		ADM8211_INT(ATIMTC);
> +		ADM8211_INT(TSFTF);
> +		ADM8211_INT(TSCZ);
> +		ADM8211_INT(SQL);
> +		ADM8211_INT(WEPTD);
> +		ADM8211_INT(ATIME);
> +		/*ADM8211_INT(TBTT);*/
> +		ADM8211_INT(TEIS);
> +		ADM8211_INT(FBE);
> +		ADM8211_INT(REIS);
> +		ADM8211_INT(GPTT);
> +		ADM8211_INT(RPS);
> +		ADM8211_INT(RDU);
> +		ADM8211_INT(TUF);
> +		/*ADM8211_INT(TRT);*/
> +		/*ADM8211_INT(TLT);*/
> +		/*ADM8211_INT(TDU);*/
> +		ADM8211_INT(TPS);

lame.  WAY too many branches, even if marked with unlikely()

this should be surrounded by a single "if stsr & 
BITS_WE_SHOULD_NEVER_SEE" test


> +	} while (count++ < 20);

NAK -- talk about back to the past.

It's bogus to loop in the interrupt handler, then loop again in both RX 
and TX paths.  You are getting close to reinventing the wheel here.

Use NAPI rather than doing such a loop.



> +#define WRITE_SYN(name,v_mask,v_shift,a_mask,a_shift,bits,prewrite,postwrite)\
> +static void adm8211_rf_write_syn_ ## name (struct ieee80211_hw *dev,	     \
> +					   u16 addr, u32 value) {	     \
> +	struct adm8211_priv *priv = dev->priv;				     \
> +	unsigned int i;							     \
> +	u32 reg, bitbuf;						     \
> +									     \
> +	value &= v_mask;						     \
> +	addr &= a_mask;							     \
> +	bitbuf = (value << v_shift) | (addr << a_shift);		     \
> +									     \
> +	ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_IF_SELECT_1);		     \
> +	ADM8211_CSR_READ(SYNRF);					     \
> +	ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_IF_SELECT_0);		     \
> +	ADM8211_CSR_READ(SYNRF);					     \
> +									     \
> +	if (prewrite) {							     \
> +		ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_WRITE_SYNDATA_0);     \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +	}								     \
> +									     \
> +	for (i = 0; i <= bits; i++) {					     \
> +		if (bitbuf & (1 << (bits - i)))				     \
> +			reg = ADM8211_SYNRF_WRITE_SYNDATA_1;		     \
> +		else							     \
> +			reg = ADM8211_SYNRF_WRITE_SYNDATA_0;		     \
> +									     \
> +		ADM8211_CSR_WRITE(SYNRF, reg);				     \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +									     \
> +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_WRITE_CLOCK_1); \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_WRITE_CLOCK_0); \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +	}								     \
> +									     \
> +	if (postwrite == 1) {						     \
> +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_IF_SELECT_0);   \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +	}								     \
> +	if (postwrite == 2) {						     \
> +		ADM8211_CSR_WRITE(SYNRF, reg | ADM8211_SYNRF_IF_SELECT_1);   \
> +		ADM8211_CSR_READ(SYNRF);				     \
> +	}								     \
> +									     \
> +	ADM8211_CSR_WRITE(SYNRF, 0);					     \
> +	ADM8211_CSR_READ(SYNRF);					     \
> +}
> +
> +WRITE_SYN(max2820,  0x00FFF, 0, 0x0F, 12, 15, 1, 1)
> +WRITE_SYN(al2210l,  0xFFFFF, 4, 0x0F,  0, 23, 1, 1)
> +WRITE_SYN(rfmd2958, 0x3FFFF, 0, 0x1F, 18, 23, 0, 1)
> +WRITE_SYN(rfmd2948, 0x0FFFF, 4, 0x0F,  0, 21, 0, 2)

code bloat from hell.  just pass these arguments (or a pointer to an 
entry in a table that contains this info)



> +static void adm8211_hw_init(struct ieee80211_hw *dev)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	u32 reg;
> +	u8 cline;
> +
> +	reg = le32_to_cpu(ADM8211_CSR_READ(PAR));
> +	reg |= ADM8211_PAR_MRLE | ADM8211_PAR_MRME;
> +	reg &= ~(ADM8211_PAR_BAR | ADM8211_PAR_CAL);

what do BAR and CAL bits do?


> +	if (!pci_set_mwi(priv->pdev)) {
> +		reg |= 0x1 << 24;
> +		pci_read_config_byte(priv->pdev, PCI_CACHE_LINE_SIZE, &cline);
> +
> +		switch (cline) {
> +		case  0x8: reg |= (0x1 << 14);
> +			   break;
> +		case 0x16: reg |= (0x2 << 14);
> +			   break;
> +		case 0x32: reg |= (0x3 << 14);
> +			   break;
> +		  default: reg |= (0x0 << 14);
> +			   break;
> +		}
> +	}
> +
> +	ADM8211_CSR_WRITE(PAR, reg);

this should be set regardless of MWI usage AFAICS


> +	reg = ADM8211_CSR_READ(CSR_TEST1);
> +	reg &= ~(0xF << 28);
> +	reg |= (1 << 28) | (1 << 31);
> +	ADM8211_CSR_WRITE(CSR_TEST1, reg);
> +
> +	/* lose link after 4 lost beacons */
> +	reg = (0x04 << 21) | ADM8211_WCSR_TSFTWE | ADM8211_WCSR_LSOE;
> +	ADM8211_CSR_WRITE(WCSR, reg);
> +
> +	/* Disable APM, enable receive FIFO threshold, and set drain receive
> +	 * threshold to store-and-forward */
> +	reg = ADM8211_CSR_READ(CMDR);
> +	reg &= ~(ADM8211_CMDR_APM | ADM8211_CMDR_DRT);
> +	reg |= ADM8211_CMDR_RTE | ADM8211_CMDR_DRT_SF;
> +	ADM8211_CSR_WRITE(CMDR, reg);
> +
> +	adm8211_set_rate(dev);
> +
> +	/* 4-bit values:
> +	 * PWR1UP   = 8 * 2 ms
> +	 * PWR0PAPE = 8 us or 5 us
> +	 * PWR1PAPE = 1 us or 3 us
> +	 * PWR0TRSW = 5 us
> +	 * PWR1TRSW = 12 us
> +	 * PWR0PE2  = 13 us
> +	 * PWR1PE2  = 1 us
> +	 * PWR0TXPE = 8 or 6 */
> +	if (priv->revid < ADM8211_REV_CA)
> +		ADM8211_CSR_WRITE(TOFS2, 0x8815cd18);
> +	else
> +		ADM8211_CSR_WRITE(TOFS2, 0x8535cd16);
> +
> +	/* Enable store and forward for transmit */
> +	priv->nar = ADM8211_NAR_SF | ADM8211_NAR_PB;
> +	ADM8211_CSR_WRITE(NAR, priv->nar);
> +
> +	/* Reset RF */
> +	ADM8211_CSR_WRITE(SYNRF, ADM8211_SYNRF_RADIO);
> +	ADM8211_CSR_READ(SYNRF);
> +	msleep(10);
> +	ADM8211_CSR_WRITE(SYNRF, 0);
> +	ADM8211_CSR_READ(SYNRF);
> +	msleep(5);
> +
> +	/* Set CFP Max Duration to 0x10 TU */
> +	reg = ADM8211_CSR_READ(CFPP);
> +	reg &= ~(0xffff << 8);
> +	reg |= 0x0010 << 8;
> +	ADM8211_CSR_WRITE(CFPP, reg);
> +
> +	/* USCNT = 0x16 (number of system clocks, 22 MHz, in 1us
> +	 * TUCNT = 0x3ff - Tu counter 1024 us  */
> +	ADM8211_CSR_WRITE(TOFS0, (0x16 << 24) | 0x3ff);
> +
> +	/* SLOT=20 us, SIFS=110 cycles of 22 MHz (5 us),
> +	 * DIFS=50 us, EIFS=100 us */
> +	if (priv->revid < ADM8211_REV_CA)
> +		ADM8211_CSR_WRITE(IFST, (20 << 23) | (110 << 15) |
> +					(50 << 9)  | 100);
> +	else
> +		ADM8211_CSR_WRITE(IFST, (20 << 23) | (24 << 15) |
> +					(50 << 9)  | 100);
> +
> +	/* PCNT = 1 (MAC idle time awake/sleep, unit S)
> +	 * RMRD = 2346 * 8 + 1 us (max RX duration)  */
> +	ADM8211_CSR_WRITE(RMD, (1 << 16) | 18769);
> +
> +	/* MART=65535 us, MIRT=256 us, TSFTOFST=0 us */
> +	ADM8211_CSR_WRITE(RSPT, 0xffffff00);
> +
> +	/* Initialize BBP (and SYN) */
> +	adm8211_hw_init_bbp(dev);
> +
> +	/* make sure interrupts are off */
> +	ADM8211_CSR_WRITE(IER, 0);
> +
> +	/* ACK interrupts */
> +	ADM8211_CSR_WRITE(STSR, ADM8211_CSR_READ(STSR));
> +
> +	/* Setup WEP (turns it off for now) */
> +	reg = ADM8211_CSR_READ(MACTEST);
> +	reg &= ~(7 << 20);
> +	ADM8211_CSR_WRITE(MACTEST, reg);
> +
> +	reg = ADM8211_CSR_READ(WEPCTL);
> +	reg &= ~ADM8211_WEPCTL_WEPENABLE;
> +	reg |= ADM8211_WEPCTL_WEPRXBYP;
> +	ADM8211_CSR_WRITE(WEPCTL, reg);
> +
> +	/* Clear the missed-packet counter. */
> +	ADM8211_CSR_READ(LPC);
> +
> +	if (!priv->mac_addr)
> +		return;
> +
> +	/* set mac address */
> +	ADM8211_CSR_WRITE(PAR0, *(u32 *)priv->mac_addr);
> +	ADM8211_CSR_WRITE(PAR1, *(u16 *)&priv->mac_addr[4]);
> +}

> +static int adm8211_init_rings(struct ieee80211_hw *dev)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	struct adm8211_desc *desc = NULL;
> +	struct adm8211_rx_ring_info *rx_info;
> +	struct adm8211_tx_ring_info *tx_info;
> +	unsigned int i;
> +
> +	for (i = 0; i < priv->rx_ring_size; i++) {
> +		desc = &priv->rx_ring[i];
> +		desc->status = 0;
> +		desc->length = cpu_to_le32(RX_PKT_SIZE);
> +		priv->rx_buffers[i].skb = NULL;
> +	}
> +	/* Mark the end of RX ring; hw returns to base address after this
> +	 * descriptor */
> +	desc->length |= cpu_to_le32(RDES1_CONTROL_RER);
> +
> +	for (i = 0; i < priv->rx_ring_size; i++) {
> +		desc = &priv->rx_ring[i];
> +		rx_info = &priv->rx_buffers[i];
> +
> +		rx_info->skb = dev_alloc_skb(RX_PKT_SIZE);
> +		if (rx_info->skb == NULL)
> +			break;

it seems highly bogus to set RX_PKT_SIZE for all RX descriptors, then 
bail if allocation starts failing.  the state of the ring becomes out of 
sync with reality.




> +/* Transmit skb w/adm8211_tx_hdr (802.11 header created by hardware) */
> +static void adm8211_tx_raw(struct ieee80211_hw *dev, struct sk_buff *skb,
> +			   u16 plcp_signal,
> +			   struct ieee80211_tx_control *control,
> +			   size_t hdrlen)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned long flags;
> +	dma_addr_t mapping;
> +	unsigned int entry;
> +	u32 flag;
> +
> +	mapping = pci_map_single(priv->pdev, skb->data, skb->len,
> +				 PCI_DMA_TODEVICE);
> +
> +	spin_lock_irqsave(&priv->lock, flags);
> +
> +	if (priv->cur_tx - priv->dirty_tx == priv->tx_ring_size / 2)
> +		flag = TDES1_CONTROL_IC | TDES1_CONTROL_LS | TDES1_CONTROL_FS;
> +	else
> +		flag = TDES1_CONTROL_LS | TDES1_CONTROL_FS;
> +
> +	if (priv->cur_tx - priv->dirty_tx == priv->tx_ring_size - 2)

extra parens would be nice for readability


> +		ieee80211_stop_queue(dev, 0);

same as above:  when queue==0 is hardcoded, things (in the stack) could 
be simplified.  not a comment on this driver, but a comment on the stack.


> +	entry = priv->cur_tx % priv->tx_ring_size;

'%' is expensive


> +	priv->tx_buffers[entry].skb = skb;
> +	priv->tx_buffers[entry].mapping = mapping;
> +	memcpy(&priv->tx_buffers[entry].tx_control, control, sizeof(*control));
> +	priv->tx_buffers[entry].hdrlen = hdrlen;
> +	priv->tx_ring[entry].buffer1 = cpu_to_le32(mapping);
> +
> +	if (entry == priv->tx_ring_size - 1)
> +		flag |= TDES1_CONTROL_TER;
> +	priv->tx_ring[entry].length = cpu_to_le32(flag | skb->len);
> +
> +	/* Set TX rate (SIGNAL field in PLCP PPDU format) */
> +	flag = TDES0_CONTROL_OWN | (plcp_signal << 20) | 8 /* ? */;
> +	priv->tx_ring[entry].status = cpu_to_le32(flag);
> +
> +	priv->cur_tx++;
> +
> +	spin_unlock_irqrestore(&priv->lock, flags);
> +
> +	/* Trigger transmit poll */
> +	ADM8211_CSR_WRITE(TDR, 0);
> +}
> +
> +/* Put adm8211_tx_hdr on skb and transmit */
> +static int adm8211_tx(struct ieee80211_hw *dev, struct sk_buff *skb,
> +		      struct ieee80211_tx_control *control)
> +{
> +	struct adm8211_tx_hdr *txhdr;
> +	u16 fc;
> +	size_t payload_len, hdrlen;
> +	int plcp, dur, len, plcp_signal, short_preamble;
> +	struct ieee80211_hdr *hdr;
> +
> +	if (control->tx_rate < 0) {
> +		short_preamble = 1;
> +		plcp_signal = -control->tx_rate;
> +	} else {
> +		short_preamble = 0;
> +		plcp_signal = control->tx_rate;
> +	}
> +
> +	hdr = (struct ieee80211_hdr *)skb->data;
> +	fc = le16_to_cpu(hdr->frame_control) & ~IEEE80211_FCTL_PROTECTED;
> +	hdrlen = ieee80211_get_hdrlen(fc);
> +	memcpy(skb->cb, skb->data, hdrlen);

to confirm:  I thought skb->cb was owned by the skb creator?  In this 
the driver is definitely _not_ the skb creator

maybe this is just a wireless thing I need to learn.


> +	hdr = (struct ieee80211_hdr *)skb->cb;
> +	skb_pull(skb, hdrlen);
> +	payload_len = skb->len;
> +
> +	txhdr = (struct adm8211_tx_hdr *) skb_push(skb, sizeof(*txhdr));
> +	memset(txhdr, 0, sizeof(*txhdr));
> +	memcpy(txhdr->da, ieee80211_get_DA(hdr), ETH_ALEN);
> +	txhdr->signal = plcp_signal;
> +	txhdr->frame_body_size = cpu_to_le16(payload_len);
> +	txhdr->frame_control = hdr->frame_control;
> +
> +	len = hdrlen + payload_len + FCS_LEN;
> +	if (fc & IEEE80211_FCTL_PROTECTED)
> +		len += 8;
> +
> +	txhdr->frag = cpu_to_le16(0x0FFF);
> +	adm8211_calc_durations(&dur, &plcp, payload_len,
> +			       len, plcp_signal, short_preamble);
> +	txhdr->plcp_frag_head_len = cpu_to_le16(plcp);
> +	txhdr->plcp_frag_tail_len = cpu_to_le16(plcp);
> +	txhdr->dur_frag_head = cpu_to_le16(dur);
> +	txhdr->dur_frag_tail = cpu_to_le16(dur);
> +
> +	txhdr->header_control = cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_EXTEND_HEADER);
> +
> +	if (short_preamble)
> +		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_SHORT_PREAMBLE);
> +
> +	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
> +		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
> +
> +	if (fc & IEEE80211_FCTL_PROTECTED)
> +		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_WEP_ENGINE);
> +
> +	txhdr->retry_limit = control->retry_limit;
> +
> +	adm8211_tx_raw(dev, skb, plcp_signal, control, hdrlen);
> +
> +	return NETDEV_TX_OK;
> +}
> +
> +static int adm8211_alloc_rings(struct ieee80211_hw *dev)
> +{
> +	struct adm8211_priv *priv = dev->priv;
> +	unsigned int ring_size;
> +
> +	priv->rx_buffers = kmalloc(sizeof(*priv->rx_buffers) * priv->rx_ring_size +
> +				   sizeof(*priv->tx_buffers) * priv->tx_ring_size, GFP_KERNEL);
> +	if (!priv->rx_buffers)
> +		return -ENOMEM;
> +
> +	priv->tx_buffers = (void *)priv->rx_buffers +
> +			   sizeof(*priv->rx_buffers) * priv->rx_ring_size;
> +
> +	/* Allocate TX/RX descriptors */
> +	ring_size = sizeof(struct adm8211_desc) * priv->rx_ring_size +
> +		    sizeof(struct adm8211_desc) * priv->tx_ring_size;
> +	priv->rx_ring = pci_alloc_consistent(priv->pdev, ring_size,
> +					     &priv->rx_ring_dma);
> +
> +	if (!priv->rx_ring) {
> +		kfree(priv->rx_buffers);
> +		priv->rx_buffers = NULL;
> +		priv->tx_buffers = NULL;
> +		return -ENOMEM;
> +	}
> +
> +	priv->tx_ring = (struct adm8211_desc *)(priv->rx_ring +
> +						priv->rx_ring_size);
> +	priv->tx_ring_dma = priv->rx_ring_dma +
> +			    sizeof(struct adm8211_desc) * priv->rx_ring_size;
> +

why not alloc ring contents (skbs) here too?


> +static int __devinit adm8211_probe(struct pci_dev *pdev,
> +				   const struct pci_device_id *id)
> +{
> +	struct ieee80211_hw *dev;
> +	struct adm8211_priv *priv;
> +	unsigned long mem_addr, mem_len;
> +	unsigned int io_addr, io_len;
> +	int err;
> +	u32 reg;
> +	u8 perm_addr[ETH_ALEN];
> +
> +#ifndef MODULE
> +	static unsigned int cardidx;
> +	if (!cardidx++)
> +		printk(version);
> +#endif

this is silly leftover logic from ancient days.

unconditionally printk() the version here, and remove from module init



> +	err = pci_enable_device(pdev);
> +	if (err) {
> +		printk(KERN_ERR "%s (adm8211): Cannot enable new PCI device\n",
> +		       pci_name(pdev));

no need for printk, PCI layer already does this


> +		return err;
> +	}
> +
> +	io_addr = pci_resource_start(pdev, 0);
> +	io_len = pci_resource_len(pdev, 0);
> +	mem_addr = pci_resource_start(pdev, 1);
> +	mem_len = pci_resource_len(pdev, 1);
> +	if (io_len < 256 || mem_len < 1024) {
> +		printk(KERN_ERR "%s (adm8211): Too short PCI resources\n",
> +		       pci_name(pdev));
> +		goto err_disable_pdev;
> +	}
> +
> +
> +	/* check signature */
> +	pci_read_config_dword(pdev, 0x80 /* CR32 */, &reg);
> +	if (reg != ADM8211_SIG1 && reg != ADM8211_SIG2) {
> +		printk(KERN_ERR "%s (adm8211): Invalid signature (0x%x)\n",
> +		       pci_name(pdev), reg);
> +		goto err_disable_pdev;
> +	}
> +
> +	err = pci_request_regions(pdev, "adm8211");
> +	if (err) {
> +		printk(KERN_ERR "%s (adm8211): Cannot obtain PCI resources\n",
> +		       pci_name(pdev));

ditto


> +		return err; /* someone else grabbed it? don't disable it */
> +	}
> +
> +	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK) ||
> +	    pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK)) {
> +		printk(KERN_ERR "%s (adm8211): No suitable DMA available\n",
> +		       pci_name(pdev));
> +		goto err_free_reg;
> +	}
> +
> +	pci_set_master(pdev);
> +
> +	dev = ieee80211_alloc_hw(sizeof(*priv), &adm8211_ops);
> +	if (!dev) {
> +		printk(KERN_ERR "%s (adm8211): ieee80211 alloc failed\n",
> +		       pci_name(pdev));
> +		err = -ENOMEM;
> +		goto err_free_reg;
> +	}
> +	priv = dev->priv;
> +	priv->pdev = pdev;
> +
> +	spin_lock_init(&priv->lock);
> +
> +	SET_IEEE80211_DEV(dev, &pdev->dev);
> +
> +	pci_set_drvdata(pdev, dev);
> +
> +	priv->map = pci_iomap(pdev, 1, mem_len);
> +	if (!priv->map)
> +		priv->map = pci_iomap(pdev, 0, io_len);

is this paranoia?

just code 100% MMIO only, and ditch the iomap per-register-access overhead


> +	pci_read_config_byte(pdev, PCI_CLASS_REVISION, &priv->revid);

this is in struct pci_dev now




> +static int __init adm8211_init(void)
> +{
> +#ifdef MODULE
> +	printk(version);
> +#endif

see above


> +	return pci_register_driver(&adm8211_driver);
> +}
> +
> +
> +static void __exit adm8211_exit(void)
> +{
> +	pci_unregister_driver(&adm8211_driver);
> --- /dev/null
> +++ b/drivers/net/wireless/adm8211.h
> @@ -0,0 +1,659 @@
> +#ifndef ADM8211_H
> +#define ADM8211_H
> +
> +/* ADM8211 Registers */
> +
> +/* CR32 (SIG) signature */
> +#define ADM8211_SIG1		0x82011317 /* ADM8211A */
> +#define ADM8211_SIG2		0x82111317 /* ADM8211B/ADM8211C */
> +
> +#define ADM8211_CSR_READ(r) ioread32(&priv->map->r)
> +#define ADM8211_CSR_WRITE(r, val) iowrite32((val), &priv->map->r)

see above, re MMIO-only


> +/* CSR (Host Control and Status Registers) */
> +struct adm8211_csr {
> +	__le32 PAR;		/* 0x00 CSR0 */
> +	__le32 FRCTL;		/* 0x04 CSR0A */
> +	__le32 TDR;		/* 0x08 CSR1 */
> +	__le32 WTDP;		/* 0x0C CSR1A */
> +	__le32 RDR;		/* 0x10 CSR2 */
> +	__le32 WRDP;		/* 0x14 CSR2A */
> +	__le32 RDB;		/* 0x18 CSR3 */
> +	__le32 TDBH;		/* 0x1C CSR3A */
> +	__le32 TDBD;		/* 0x20 CSR4 */
> +	__le32 TDBP;		/* 0x24 CSR4A */
> +	__le32 STSR;		/* 0x28 CSR5 */
> +	__le32 TDBB;		/* 0x2C CSR5A */
> +	__le32 NAR;		/* 0x30 CSR6 */
> +	__le32 CSR6A;		/* reserved */
> +	__le32 IER;		/* 0x38 CSR7 */
> +	__le32 TKIPSCEP;	/* 0x3C CSR7A */
> +	__le32 LPC;		/* 0x40 CSR8 */
> +	__le32 CSR_TEST1;	/* 0x44 CSR8A */
> +	__le32 SPR;		/* 0x48 CSR9 */
> +	__le32 CSR_TEST0;	/* 0x4C CSR9A */
> +	__le32 WCSR;		/* 0x50 CSR10 */
> +	__le32 WPDR;		/* 0x54 CSR10A */
> +	__le32 GPTMR;		/* 0x58 CSR11 */
> +	__le32 GPIO;		/* 0x5C CSR11A */
> +	__le32 BBPCTL;		/* 0x60 CSR12 */
> +	__le32 SYNCTL;		/* 0x64 CSR12A */
> +	__le32 PLCPHD;		/* 0x68 CSR13 */
> +	__le32 MMIWA;		/* 0x6C CSR13A */
> +	__le32 MMIRD0;		/* 0x70 CSR14 */
> +	__le32 MMIRD1;		/* 0x74 CSR14A */
> +	__le32 TXBR;		/* 0x78 CSR15 */
> +	__le32 SYNDATA;		/* 0x7C CSR15A */
> +	__le32 ALCS;		/* 0x80 CSR16 */
> +	__le32 TOFS2;		/* 0x84 CSR17 */
> +	__le32 CMDR;		/* 0x88 CSR18 */
> +	__le32 PCIC;		/* 0x8C CSR19 */
> +	__le32 PMCSR;		/* 0x90 CSR20 */
> +	__le32 PAR0;		/* 0x94 CSR21 */
> +	__le32 PAR1;		/* 0x98 CSR22 */
> +	__le32 MAR0;		/* 0x9C CSR23 */
> +	__le32 MAR1;		/* 0xA0 CSR24 */
> +	__le32 ATIMDA0;		/* 0xA4 CSR25 */
> +	__le32 ABDA1;		/* 0xA8 CSR26 */
> +	__le32 BSSID0;		/* 0xAC CSR27 */
> +	__le32 TXLMT;		/* 0xB0 CSR28 */
> +	__le32 MIBCNT;		/* 0xB4 CSR29 */
> +	__le32 BCNT;		/* 0xB8 CSR30 */
> +	__le32 TSFTH;		/* 0xBC CSR31 */
> +	__le32 TSC;		/* 0xC0 CSR32 */
> +	__le32 SYNRF;		/* 0xC4 CSR33 */
> +	__le32 BPLI;		/* 0xC8 CSR34 */
> +	__le32 CAP0;		/* 0xCC CSR35 */
> +	__le32 CAP1;		/* 0xD0 CSR36 */
> +	__le32 RMD;		/* 0xD4 CSR37 */
> +	__le32 CFPP;		/* 0xD8 CSR38 */
> +	__le32 TOFS0;		/* 0xDC CSR39 */
> +	__le32 TOFS1;		/* 0xE0 CSR40 */
> +	__le32 IFST;		/* 0xE4 CSR41 */
> +	__le32 RSPT;		/* 0xE8 CSR42 */
> +	__le32 TSFTL;		/* 0xEC CSR43 */
> +	__le32 WEPCTL;		/* 0xF0 CSR44 */
> +	__le32 WESK;		/* 0xF4 CSR45 */
> +	__le32 WEPCNT;		/* 0xF8 CSR46 */
> +	__le32 MACTEST;		/* 0xFC CSR47 */
> +	__le32 FER;		/* 0x100 */
> +	__le32 FEMR;		/* 0x104 */
> +	__le32 FPSR;		/* 0x108 */
> +	__le32 FFER;		/* 0x10C */
> +} __attribute__ ((packed));

attributed(packed) is unneccesary here, and its use results in 
sub-optimal code


> +/* CSR0 - PAR (PCI Address Register) */
> +#define ADM8211_PAR_MWIE	(1 << 24)
> +#define ADM8211_PAR_MRLE	(1 << 23)
> +#define ADM8211_PAR_MRME	(1 << 21)
> +#define ADM8211_PAR_RAP		((1 << 18) | (1 << 17))
> +#define ADM8211_PAR_CAL		((1 << 15) | (1 << 14))
> +#define ADM8211_PAR_PBL		0x00003f00
> +#define ADM8211_PAR_BLE		(1 << 7)
> +#define ADM8211_PAR_DSL		0x0000007c
> +#define ADM8211_PAR_BAR		(1 << 1)
> +#define ADM8211_PAR_SWR		(1 << 0)
> +
> +/* CSR1 - FRCTL (Frame Control Register) */
> +#define ADM8211_FRCTL_PWRMGT	(1 << 31)
> +#define ADM8211_FRCTL_MAXPSP	(1 << 27)
> +#define ADM8211_FRCTL_DRVPRSP	(1 << 26)
> +#define ADM8211_FRCTL_DRVBCON	(1 << 25)
> +#define ADM8211_FRCTL_AID	0x0000ffff
> +#define ADM8211_FRCTL_AID_ON	0x0000c000
> +
> +/* CSR5 - STSR (Status Register) */
> +#define ADM8211_STSR_PCF	(1 << 31)
> +#define ADM8211_STSR_BCNTC	(1 << 30)
> +#define ADM8211_STSR_GPINT	(1 << 29)
> +#define ADM8211_STSR_LinkOff	(1 << 28)
> +#define ADM8211_STSR_ATIMTC	(1 << 27)
> +#define ADM8211_STSR_TSFTF	(1 << 26)
> +#define ADM8211_STSR_TSCZ	(1 << 25)
> +#define ADM8211_STSR_LinkOn	(1 << 24)
> +#define ADM8211_STSR_SQL	(1 << 23)
> +#define ADM8211_STSR_WEPTD	(1 << 22)
> +#define ADM8211_STSR_ATIME	(1 << 21)
> +#define ADM8211_STSR_TBTT	(1 << 20)
> +#define ADM8211_STSR_NISS	(1 << 16)
> +#define ADM8211_STSR_AISS	(1 << 15)
> +#define ADM8211_STSR_TEIS	(1 << 14)
> +#define ADM8211_STSR_FBE	(1 << 13)
> +#define ADM8211_STSR_REIS	(1 << 12)
> +#define ADM8211_STSR_GPTT	(1 << 11)
> +#define ADM8211_STSR_RPS	(1 << 8)
> +#define ADM8211_STSR_RDU	(1 << 7)
> +#define ADM8211_STSR_RCI	(1 << 6)
> +#define ADM8211_STSR_TUF	(1 << 5)
> +#define ADM8211_STSR_TRT	(1 << 4)
> +#define ADM8211_STSR_TLT	(1 << 3)
> +#define ADM8211_STSR_TDU	(1 << 2)
> +#define ADM8211_STSR_TPS	(1 << 1)
> +#define ADM8211_STSR_TCI	(1 << 0)
> +
> +/* CSR6 - NAR (Network Access Register) */
> +#define ADM8211_NAR_TXCF	(1 << 31)
> +#define ADM8211_NAR_HF		(1 << 30)
> +#define ADM8211_NAR_UTR		(1 << 29)
> +#define ADM8211_NAR_SQ		(1 << 28)
> +#define ADM8211_NAR_CFP		(1 << 27)
> +#define ADM8211_NAR_SF		(1 << 21)
> +#define ADM8211_NAR_TR		((1 << 15) | (1 << 14))
> +#define ADM8211_NAR_ST		(1 << 13)
> +#define ADM8211_NAR_OM		((1 << 11) | (1 << 10))
> +#define ADM8211_NAR_MM		(1 << 7)
> +#define ADM8211_NAR_PR		(1 << 6)
> +#define ADM8211_NAR_EA		(1 << 5)
> +#define ADM8211_NAR_PB		(1 << 3)
> +#define ADM8211_NAR_STPDMA	(1 << 2)
> +#define ADM8211_NAR_SR		(1 << 1)
> +#define ADM8211_NAR_CTX		(1 << 0)

enums are preferred.  they do not disappear at the cpp stage, and confer 
type information.


> +#define ADM8211_IDLE_RX() 						\
> +do {									\
> +	if (priv->nar & ADM8211_NAR_SR) {				\
> +		ADM8211_CSR_WRITE(NAR, priv->nar & ~ADM8211_NAR_SR);	\
> +		ADM8211_CSR_READ(NAR);					\
> +		mdelay(20);						\
> +	}								\
> +} while (0)

should be msleep() AFAICS


> +struct adm8211_eeprom {
> +	__le16	signature;		/* 0x00 */
> +	u8	major_version;		/* 0x02 */
> +	u8	minor_version;		/* 0x03 */
> +	u8	reserved_1[4];		/* 0x04 */
> +	u8	hwaddr[6];		/* 0x08 */
> +	u8	reserved_2[8];		/* 0x1E */
> +	__le16	cr49;			/* 0x16 */
> +	u8	cr03;			/* 0x18 */
> +	u8	cr28;			/* 0x19 */
> +	u8	cr29;			/* 0x1A */
> +	u8	country_code;		/* 0x1B */
> +
> +/* specific bbp types */
> +#define ADM8211_BBP_RFMD3000	0x00
> +#define ADM8211_BBP_RFMD3002	0x01
> +#define ADM8211_BBP_ADM8011	0x04
> +	u8	specific_bbptype;	/* 0x1C */
> +	u8	specific_rftype;	/* 0x1D */
> +	u8	reserved_3[2];		/* 0x1E */
> +	__le16	device_id;		/* 0x20 */
> +	__le16	vendor_id;		/* 0x22 */
> +	__le16	subsystem_id;		/* 0x24 */
> +	__le16	subsystem_vendor_id;	/* 0x26 */
> +	u8	maxlat;			/* 0x28 */
> +	u8	mingnt;			/* 0x29 */
> +	__le16	cis_pointer_low;	/* 0x2A */
> +	__le16	cis_pointer_high;	/* 0x2C */
> +	__le16	csr18;			/* 0x2E */
> +	u8	reserved_4[16];		/* 0x30 */
> +	u8	d1_pwrdara;		/* 0x40 */
> +	u8	d0_pwrdara;		/* 0x41 */
> +	u8	d3_pwrdara;		/* 0x42 */
> +	u8	d2_pwrdara;		/* 0x43 */
> +	u8	antenna_power[14];	/* 0x44 */
> +	__le16	cis_wordcnt;		/* 0x52 */
> +	u8	tx_power[14];		/* 0x54 */
> +	u8	lpf_cutoff[14];		/* 0x62 */
> +	u8	lnags_threshold[14];	/* 0x70 */
> +	__le16	checksum;		/* 0x7E */
> +	u8	cis_data[0];		/* 0x80, 384 bytes */
> +} __attribute__ ((packed));

same attributed(packed) comment as above


> +struct adm8211_priv {
> +	struct pci_dev *pdev;
> +	spinlock_t lock;
> +	struct adm8211_csr __iomem *map;
> +	struct adm8211_desc *rx_ring;
> +	struct adm8211_desc *tx_ring;
> +	dma_addr_t rx_ring_dma;
> +	dma_addr_t tx_ring_dma;
> +	struct adm8211_rx_ring_info *rx_buffers;
> +	struct adm8211_tx_ring_info *tx_buffers;
> +	unsigned int rx_ring_size, tx_ring_size;
> +	unsigned int cur_tx, dirty_tx, cur_rx;
> +
> +	struct ieee80211_low_level_stats stats;
> +	struct ieee80211_hw_mode modes[1];
> +	struct ieee80211_channel channels[ARRAY_SIZE(adm8211_channels)];
> +	struct ieee80211_rate rates[ARRAY_SIZE(adm8211_rates)];
> +	int mode;
> +
> +	int channel;
> +	u8 bssid[ETH_ALEN];
> +	u8 ssid[32];
> +	size_t ssid_len;
> +	u8 *mac_addr;
> +
> +	u8 soft_rx_crc;
> +	u8 retry_limit;
> +
> +	u8 ant_power;
> +	u8 tx_power;
> +	u8 lpf_cutoff;
> +	u8 lnags_threshold;
> +	struct adm8211_eeprom *eeprom;
> +	size_t eeprom_len;
> +
> +	u8 revid;
> +
> +	u32 nar;

use of <tab> to separate type and name greatly enhances readability. 
look at many other net drivers, to see the positive effects
