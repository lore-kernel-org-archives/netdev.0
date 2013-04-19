From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: Re: net/macb: clear tx/rx completion flags in ISR
Date: Fri, 19 Apr 2013 11:38:29 +0200
Message-ID: <20130419093829.GB660@pengutronix.de>
References: <5170D276.6070208@yahoo.es>
 <20130419073058.GA660@pengutronix.de>
 <5170F6DB.6030500@atmel.com>
 <51710C90.5070606@yahoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	Ludovic Desroches <ludovic.desroches@atmel.com>
To: Hein Tibosch <hein_tibosch@yahoo.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33241 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756967Ab3DSJid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 05:38:33 -0400
Content-Disposition: inline
In-Reply-To: <51710C90.5070606@yahoo.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 19, 2013 at 05:21:20PM +0800, Hein Tibosch wrote:
> Hi,
> 
> On 4/19/2013 3:48 PM, Nicolas Ferre wrote:
> > On 04/19/2013 09:30 AM, Steffen Trumtrar :
> >> Hi Hein,
> >>
> >> On Fri, Apr 19, 2013 at 01:13:26PM +0800, Hein Tibosch wrote:
> >>> Hi Steffen,
> >>>
> >>>> At least in the cadence IP core on the Xilinx Zynq SoC the TCOMP/RCOMP flags
> >>>> are not auto-cleaned. As these flags are evaluated, they need to be cleaned.
> >>> This patch does not work for at least the AVR32 platform. Both RCOMP/RCOMP
> >>> are cleared by *reading* the ISR and writing them would be fatal.
> >>>
> >> :-(
> >>
> >>> Could you tell me the version of the macb of Xilinx Zynq?
> >>>
> >>>     u32 version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
> >>>             | MACB_GREGS_VERSION;
> >>>
> >>> On an AP7000 it reads as 0x0000010D
> >>>
> >> This gives me 0x00000119. The TRM says it is version r1p23.
> >>
> >>> I am thinking of making a patch like:
> >>>
> >>>     if (bp->version >= xxx)
> >>>         macb_writel(bp, ISR, MACB_BIT(TCOMP));
> >>>
> >>>     if (bp->version >= xxx)
> >>>         macb_writel(bp, ISR, MACB_BIT(RCOMP));
> >>>
> >>> which would make it work on both platforms.
> > Well, keep in mind that it is the hot path: It can harm the performance
> > if too much tests are performed...
> 
> Yes it's in the hot path, both tests will be done within an interrupt.
> 
> I just gave it a quick try:
> 
> ---
>  drivers/net/ethernet/cadence/macb.c |    8 ++++++--
>  drivers/net/ethernet/cadence/macb.h |    1 +
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index ed2cb13..fe31951 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -315,6 +315,8 @@ int macb_mii_init(struct macb *bp)
>  	struct macb_platform_data *pdata;
>  	int err = -ENXIO, i;
>  
> +	bp->ip_version = (macb_readl(bp, MID) & ((1 << MACB_REV_SIZE) - 1))
> +			| MACB_GREGS_VERSION;
>  	/* Enable management port */
>  	macb_writel(bp, NCR, MACB_BIT(MPE));
>  @@ -485,7 +487,8 @@ static void macb_tx_interrupt(struct macb *bp)
>  	status = macb_readl(bp, TSR);
>  	macb_writel(bp, TSR, status);
>  
> -	macb_writel(bp, ISR, MACB_BIT(TCOMP));
> +	if (bp->ip_version == 0x00000119)
> +		macb_writel(bp, ISR, MACB_BIT(TCOMP));
>   	netdev_vdbg(bp->dev, "macb_tx_interrupt status = 0x%03lx\n",
>  		(unsigned long)status);
> @@ -738,7 +741,8 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
>  			 * now.
>  			 */
>  			macb_writel(bp, IDR, MACB_RX_INT_FLAGS);
> -			macb_writel(bp, ISR, MACB_BIT(RCOMP));
> +			if (bp->ip_version == 0x00000119)
> +				macb_writel(bp, ISR, MACB_BIT(RCOMP));
>   			if (napi_schedule_prep(&bp->napi)) {
>  				netdev_vdbg(bp->dev, "scheduling RX softirq\n");
> diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
> index 993d703..0fbb440 100644
> --- a/drivers/net/ethernet/cadence/macb.h
> +++ b/drivers/net/ethernet/cadence/macb.h
> @@ -575,6 +575,7 @@ struct macb {
>  	unsigned int 		duplex;
>  
>  	phy_interface_t		phy_interface;
> +	unsigned		ip_version;
>   	/* AT91RM9200 transmit */
>  	struct sk_buff *skb;			/* holds skb until xmit interrupt completes */
> --
> 1.7.10
> 
> On my AP7000 platforms, on a 100mbit LAN, I could not measure any drop
> of performance using iperf:
> 
> Before the patch:
> [  6]  0.0-10.1 sec  67.4 MBytes  56.1 Mbits/sec
> [  7]  0.0-10.1 sec  65.5 MBytes  54.6 Mbits/sec
> [  6]  0.0-10.1 sec  67.8 MBytes  56.4 Mbits/sec
> [  7]  0.0-10.1 sec  65.1 MBytes  54.3 Mbits/sec
> 
> After the patch:
> [  6]  0.0-10.1 sec  68.1 MBytes  56.8 Mbits/sec
> [  7]  0.0-10.1 sec  66.5 MBytes  55.4 Mbits/sec
> [  6]  0.0- 9.9 sec  67.5 MBytes  57.2 Mbits/sec
> [  8]  0.0-10.1 sec  66.5 MBytes  55.5 Mbits/sec
> 
> It looks a bit faster, which is pure coincidence.
> >
> >> The documentation I have is a little bit confusing in that regard.
> >> The cadence datasheet says, this register is R/W, the Xilinx datasheet says,
> >> it is "normaly RO", but the programming guide explicitely mentions clearing
> >> the bit by writing to it.
> 
> Steffen, did you really see it happen that TCOMP/RCOMP were not cleared by just
> reading the ISR?
> The Atmel manual says about each ISR field: 'Cleared on read'
> 

I just reverted that patch to confirm and the system hangs with
	[    2.680000] Sending DHCP requests .

So, yes. It is needed. Either Cadence changed something or Xilinx is doing
something weird with the core.

> >> It seems, that something like your patch is inevitable.
> > I also had bad feedbacks concerning this patch. Maybe we should take
> > more time to validate this change: event it is in net-next, maybe we
> > should revert it for the moment...

Regards,
Steffen

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
