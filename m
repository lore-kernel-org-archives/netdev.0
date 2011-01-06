From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH V8 12/13] ptp: Added a clock driver for the IXP46x.
Date: Thu, 06 Jan 2011 22:01:59 +0100
Message-ID: <m3ei8plpa0.fsf@intrepid.localdomain>
References: <cover.1293820862.git.richard.cochran@omicron.at>
	<8151196c018776704df34748f333bdb159497d0b.1293820862.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8151196c018776704df34748f333bdb159497d0b.1293820862.git.richard.cochran@omicron.at>
	(Richard Cochran's message of "Fri, 31 Dec 2010 20:17:23 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Cochran <richardcochran@gmail.com> writes:

> +struct ixp46x_channel_ctl {
> +	u32 Ch_Control; /* 0x40 Time Synchronization Channel Control */
> +	u32 Ch_Event;   /* 0x44 Time Synchronization Channel Event */
> +	u32 TxSnapLo;   /* 0x48 Transmit Snapshot Low Register */
> +	u32 TxSnapHi;   /* 0x4C Transmit Snapshot High Register */
> +	u32 RxSnapLo;   /* 0x50 Receive Snapshot Low Register */
> +	u32 RxSnapHi;   /* 0x54 Receive Snapshot High Register */
> +	u32 SrcUUIDLo;  /* 0x58 Source UUID0 Low Register */
> +	u32 SrcUUIDHi;  /* 0x5C Sequence Identifier/Source UUID0 High */

I don't like these XxxYyyZzz either :-(

> +static void do_tx_timestamp(struct port *port, struct sk_buff *skb)
> +{
> +#ifdef __ARMEB__
> +	struct skb_shared_hwtstamps shhwtstamps;
> +	struct ixp46x_ts_regs *regs;
> +	struct skb_shared_info *shtx;
> +	u64 ns;
> +	u32 ch, cnt, hi, lo, val;
> +
> +	shtx = skb_shinfo(skb);
> +	if (unlikely(shtx->tx_flags & SKBTX_HW_TSTAMP && port->hwts_tx_en))
> +		shtx->tx_flags |= SKBTX_IN_PROGRESS;
> +	else
> +		return;
> +
> +	ch = PORT2CHANNEL(port);
> +
> +	regs = (struct ixp46x_ts_regs __iomem *) IXP4XX_TIMESYNC_BASE_VIRT;
> +
> +	/*
> +	 * This really stinks, but we have to poll for the Tx time stamp.
> +	 * Usually, the time stamp is ready after 4 to 6 microseconds.
> +	 */
> +	for (cnt = 0; cnt < 100; cnt++) {
> +		val = __raw_readl(&regs->channel[ch].Ch_Event);
> +		if (val & TX_SNAPSHOT_LOCKED)
> +			break;
> +		udelay(1);
> +	}
> +	if (!(val & TX_SNAPSHOT_LOCKED)) {
> +		shtx->tx_flags &= ~SKBTX_IN_PROGRESS;
> +		return;
> +	}
> +
> +	lo = __raw_readl(&regs->channel[ch].TxSnapLo);
> +	hi = __raw_readl(&regs->channel[ch].TxSnapHi);
> +	ns = ((u64) hi) << 32;
> +	ns |= lo;
> +	ns <<= TICKS_NS_SHIFT;
> +
> +	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
> +	shhwtstamps.hwtstamp = ns_to_ktime(ns);
> +	skb_tstamp_tx(skb, &shhwtstamps);
> +
> +	__raw_writel(TX_SNAPSHOT_LOCKED, &regs->channel[ch].Ch_Event);
> +#endif
> +}

And what if we're little-endian? Why does it depend on BE?

> @@ -1171,6 +1357,11 @@ static int __devinit eth_init_one(struct platform_device *pdev)
>  	char phy_id[MII_BUS_ID_SIZE + 3];
>  	int err;
>  
> +	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
> +		pr_err("ixp4xx_eth: bad ptp filter\n");
> +		return -EINVAL;
> +	}
> +
>  	if (!(dev = alloc_etherdev(sizeof(struct port))))
>  		return -ENOMEM;

Shouldn't it depend on CPU type?
BTW which CPU is required? IXP46x (455/460/465)? Does it work on 43x?

> +	if (NO_IRQ == irq)
> +		return NO_IRQ;

Don't like these either :-(
Not showstoppers but...

Also I don't like the ixp_read/ixp_write() trivial macros. Why not
simply call __raw_readl() and __raw_writel()?
-- 
Krzysztof Halasa
