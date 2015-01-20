From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net-next v13 3/3] net: hisilicon: new hip04 ethernet
 driver
Date: Tue, 20 Jan 2015 10:12:04 -0800
Message-ID: <1421777524.2724.3.camel@perches.com>
References: <1421217254-12008-1-git-send-email-dingtianhong@huawei.com>
	 <9314032.C8yR0htxiP@wuerfel> <54BDBA29.10703@huawei.com>
	 <17360357.cJoZFH8idi@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Alexander Graf <agraf-l3A5Bk7waGM@public.gmane.org>, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org, sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	xuwei5-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <17360357.cJoZFH8idi@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2015-01-20 at 13:01 +0100, Arnd Bergmann wrote:
> On Tuesday 20 January 2015 10:15:05 Ding Tianhong wrote:
> > On 2015/1/20 4:34, Arnd Bergmann wrote:
> > > On Monday 19 January 2015 19:11:11 Alexander Graf wrote:
> > >>
> > >> After hammering on the box a bit again, I'm in a situation where I get 
> > >> lots of
> > >>
> > >> [302398.232603] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302398.377309] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302398.395198] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302398.466118] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302398.659009] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.053389] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.122067] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.268192] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.286081] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.594201] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.683416] hip04-ether e28b0000.ethernet eth0: rx drop
> > >> [302399.701307] hip04-ether e28b0000.ethernet eth0: rx drop
> > >>
> > >> and I really am getting a lot of drops - I can't even ping the machine 
> > >> anymore.
> > >>
> > >> However, as it is there's a good chance the machine is simply 
> > >> unreachable because it's busy writing to the UART, and even if not all 
> > >> useful messages indicating anything have scrolled out. I really don't 
> > >> think you should emit any message over and over again to the user. Once 
> > >> or twice is enough.

[]

> The hip04 ethernet driver currently acknowledges all interrupts directly
> in the interrupt handler, and leaves all interrupts except the RX data
> enabled the whole time. This causes multiple problems:
[]
> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
[]
> @@ -564,23 +563,21 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
>  	if (!ists)
>  		return IRQ_NONE;
>  
> -	writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
> -
>  	if (unlikely(ists & DEF_INT_ERR)) {
> -		if (ists & (RCV_NOBUF | RCV_DROP))
> +		if (ists & (RCV_NOBUF | RCV_DROP)) {
>  			stats->rx_errors++;
>  			stats->rx_dropped++;
> -			netdev_err(ndev, "rx drop\n"
> +			netdev_dbg(ndev, "rx drop\n");
> +		}
>  		if (ists & TX_DROP) {
>  			stats->tx_dropped++;
> -			netdev_err(ndev, "tx drop\n");
> +			netdev_dbg(ndev, "tx drop\n");
>  		}
>  	}
>  

While these are dubious messages to output at all, it
probably would benefit to use net_ratelimit() before the
netdev_dbg() and maybe output the counter as well:

		if (...) {
			stats++
			if (net_ratelimit())
				netdev_dbg(ndev, "[rt]x drop: %u\n", stats);
		}


--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
