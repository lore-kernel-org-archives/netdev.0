From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
Date: Tue, 3 Sep 2013 02:49:02 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE0168264F@039-SN2MPN1-021.039d.mgd.msft.net>
References: <1378174690-20316-1-git-send-email-B38611@freescale.com>
 <1F990F8245A4214A8CC4BFFBD9F790F908B45EA4@039-SN1MPN1-001.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Li Frank-B20596 <B20596@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:51869
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759296Ab3ICCtH convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 22:49:07 -0400
In-Reply-To: <1F990F8245A4214A8CC4BFFBD9F790F908B45EA4@039-SN1MPN1-001.039d.mgd.msft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Frank-B20596
Data: Tuesday, September 03, 2013 10:34 AM

> To: Duan Fugang-B38611; davem@davemloft.net
> Cc: netdev@vger.kernel.org; bhutchings@solarflare.com;
> stephen@networkplumber.org
> Subject: RE: [PATCH] net: fec: fix the error to get the previous BD entry
> 
> 
> > Bug: error to get the previous BD entry. When the current BD is the
> > first BD, the previous BD entry must be the last BD, not "bdp - 1" in
> current logic.
> >
> > V3:
> >   * Restore the API name because David suggest to use fec_enet_
> >     prefix for all function in fec driver.
> >     So, change next_bd() -> fec_enet_get_nextdesc()
> >         change pre_bd()  -> fec_enet_get_prevdesc()
> >   * Reduce the two APIs parameters for easy to call.
> >
> > V2:
> >   * Add tx_ring_size and rx_ring_size to struct fec_enet_private.
> >   * Replace api fec_enet_get_nextdesc() with next_bd().
> >     Replace api fec_enet_get_prevdesc() with pre_bd().
> >
> >   * Move all ring size check logic to next_bd() and pre_bd(), which
> >     simplifies the code redundancy.
> >
> > V1:
> >   * Add BD ring size check to get the previous BD entry in correctly.
> >
> > Reviewed-by: Li Frank <B20596@freescale.com>
> > Signed-off-by: Fugang Duan  <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec.h      |    3 +
> >  drivers/net/ethernet/freescale/fec_main.c |  120
> > ++++++++++++++++++---------
> > --
> >  2 files changed, 77 insertions(+), 46 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec.h
> > b/drivers/net/ethernet/freescale/fec.h
> > index ae23600..0120217 100644
> > --- a/drivers/net/ethernet/freescale/fec.h
> > +++ b/drivers/net/ethernet/freescale/fec.h
> > @@ -296,6 +296,9 @@ struct fec_enet_private {
> >  	/* The ring entries to be free()ed */
> >  	struct bufdesc	*dirty_tx;
> >
> > +	unsigned short tx_ring_size;
> > +	unsigned short rx_ring_size;
> > +
> >  	struct	platform_device *pdev;
> >
> >  	int	opened;
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 4ea1555..d5d8984 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -239,22 +239,57 @@ MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC
> > address");
> >
> >  static int mii_cnt;
> >
> > -static struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp, int
> > is_ex)
> > +static inline
> > +struct bufdesc *fec_enet_get_nextdesc(struct bufdesc *bdp, struct
> > +fec_enet_private *fep)
> >  {
> > -	struct bufdesc_ex *ex = (struct bufdesc_ex *)bdp;
> > -	if (is_ex)
> > -		return (struct bufdesc *)(ex + 1);
> > +	struct bufdesc *new_bd = bdp + 1;
> > +	struct bufdesc_ex *ex_new_bd = (struct bufdesc_ex *)bdp + 1;
> > +	struct bufdesc_ex *ex_base;
> > +	struct bufdesc *base;
> > +	int ring_size;
> > +
> > +	if (bdp >= fep->tx_bd_base) {
> > +		base = fep->tx_bd_base;
> > +		ring_size = fep->tx_ring_size;
> > +		ex_base = (struct bufdesc_ex *)fep->tx_bd_base;
> > +	} else {
> > +		base = fep->rx_bd_base;
> > +		ring_size = fep->rx_ring_size;
> > +		ex_base = (struct bufdesc_ex *)fep->rx_bd_base;
> > +	}
> > +
> > +	if (fep->bufdesc_ex)
> > +		return (struct bufdesc *)((ex_new_bd >= (ex_base +
> ring_size)) ?
> > +			(ex_new_bd - ring_size) : ex_new_bd);
> 
> I think  "exbase:ex_new_bd" is better
> 
> >  	else
> > -		return bdp + 1;
> > +		return (new_bd >= (base + ring_size)) ?
> > +			(new_bd - ring_size) : new_bd;
> 
> I think "base:new_bd" is better.
> 

Yes, it is more clean for code review. I have sent the V4 version.
Thanks.
