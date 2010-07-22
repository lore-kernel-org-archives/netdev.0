From: Baruch Siach <baruch@tkos.co.il>
Subject: Re: [PATCH] fec: use interrupt for MDIO completion indication
Date: Thu, 22 Jul 2010 09:17:15 +0300
Message-ID: <20100722061715.GB12359@jasper.tkos.co.il>
References: <006416d38a8e51ba8dd8631613a991528dc7976a.1278918594.git.baruch@tkos.co.il>
 <4C3E812C.10303@canonical.com>
 <20100715040956.GA7690@jasper.tkos.co.il>
 <20100721125113.GA2651@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bryan Wu <bryan.wu@canonical.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	Sascha Hauer <kernel@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tango.tkos.co.il ([62.219.50.35]:38714 "EHLO tango.tkos.co.il"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751883Ab0GVGRw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 02:17:52 -0400
Content-Disposition: inline
In-Reply-To: <20100721125113.GA2651@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Wolfram, Bryan,

On Wed, Jul 21, 2010 at 02:51:13PM +0200, Wolfram Sang wrote:
> > > Thanks for this patch, we tested on our i.MX51 board with Ubuntu. It 
> > > works fine.
> > > 
> > > Wolfram, you can pick up this, too. -;)
> > 
> > Dave has already applied this patch to his net-next tree.
> 
> Bryan, thanks for letting me know, I missed this one.
> 
> However, have you guys ever tried pulling the cable off/on or restarting
> the interface with 'ifconfig down/up'? This always caused a stalled PHY
> for me. This patch helps:

I can confirm the problem and the fix on a i.MX25 based system. Thanks 
Wolfram.

baruch

> From: Wolfram Sang <w.sang@pengutronix.de>
> Subject: [PATCH] net/fec: restore interrupt mask after software-reset in fec_stop()
> 
> After the change from mdio polling to irq, it became necessary to
> restore the interrupt mask after resetting the chip in fec_stop().
> Otherwise, with all irqs disabled, no communication with the PHY will be
> possible after e.g. un-/replugging the cable and the device gets
> stalled.
> 
> Signed-off-by: Wolfram Sang <w.sang@pengutronix.de>
> ---
>  drivers/net/fec.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
> index 391a553..768b840 100644
> --- a/drivers/net/fec.c
> +++ b/drivers/net/fec.c
> @@ -118,6 +118,8 @@ static unsigned char	fec_mac_default[] = {
>  #define FEC_ENET_MII	((uint)0x00800000)	/* MII interrupt */
>  #define FEC_ENET_EBERR	((uint)0x00400000)	/* SDMA bus error */
>  
> +#define FEC_DEFAULT_IMASK (FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII)
> +
>  /* The FEC stores dest/src/type, data, and checksum for receive packets.
>   */
>  #define PKT_MAXBUF_SIZE		1518
> @@ -1213,8 +1215,7 @@ fec_restart(struct net_device *dev, int duplex)
>  	writel(0, fep->hwp + FEC_R_DES_ACTIVE);
>  
>  	/* Enable interrupts we wish to service */
> -	writel(FEC_ENET_TXF | FEC_ENET_RXF | FEC_ENET_MII,
> -			fep->hwp + FEC_IMASK);
> +	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>  }
>  
>  static void
> @@ -1233,8 +1234,8 @@ fec_stop(struct net_device *dev)
>  	/* Whack a reset.  We should wait for this. */
>  	writel(1, fep->hwp + FEC_ECNTRL);
>  	udelay(10);
> -
>  	writel(fep->phy_speed, fep->hwp + FEC_MII_SPEED);
> +	writel(FEC_DEFAULT_IMASK, fep->hwp + FEC_IMASK);
>  }
>  
>  static int __devinit
> -- 
> 1.7.1
> 
> ==========================
> 
> BUT, while it helps and may possibly be a quick fix for 2.6.35,
> resetting the chip in fec_stop() looks like a wrong thing to do for me.
> In the long run, it probably is better to make sure the chip is set up
> correctly during initialization, so the reset in fec_stop() is not
> needed at all. I had a quick shot at this, but seem to have missed
> something as it didn't work. As I will be away from the computers for
> two weeks in about 24 hours, I at least wanted to bring up the issue.
> 
> Regards,
> 
>    Wolfram
> 
> -- 
> Pengutronix e.K.                           | Wolfram Sang                |
> Industrial Linux Solutions                 | http://www.pengutronix.de/  |



-- 
                                                     ~. .~   Tk Open Systems
=}------------------------------------------------ooO--U--Ooo------------{=
   - baruch@tkos.co.il - tel: +972.2.679.5364, http://www.tkos.co.il -
