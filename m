From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
Date: Thu, 5 Jun 2014 09:34:44 +0000
Message-ID: <d93f47b1073f46319b170dee27206bed@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1401951572-6538-1-git-send-email-b38611@freescale.com>
 <1401951572-6538-2-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D17257A93@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	"ezequiel.garcia@free-electrons.com"
	<ezequiel.garcia@free-electrons.com>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0181.outbound.protection.outlook.com ([207.46.163.181]:39199
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751121AbaFEJes convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 05:34:48 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17257A93@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM> Data: Thursday, June 05, 2014 5:07 PM
> To: Duan Fugang-B38611; davem@davemloft.net
> Cc: netdev@vger.kernel.org; shawn.guo@linaro.org; Estevam Fabio-R49496;
> ezequiel.garcia@free-electrons.com; bhutchings@solarflare.com;
> stephen@networkplumber.org; Li Frank-B20596; eric.dumazet@gmail.com
> Subject: RE: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
> 
> From: Fugang Duan
> > Make the code more readable and easy to support other features like
> > SG, TSO, moving the common transmit function to one api.
> >
> > And the patch also factorize the getting BD index to it own function.
> >
> > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c |   87 ++++++++++++++++++-----
> ------
> >  1 files changed, 54 insertions(+), 33 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 802be17..32c2276 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -287,6 +287,25 @@ struct bufdesc *fec_enet_get_prevdesc(struct bufdesc
> *bdp, struct fec_enet_priva
> >  		return (new_bd < base) ? (new_bd + ring_size) : new_bd;  }
> >
> > +static inline
> > +int fec_enet_get_bd_index(struct bufdesc *bdp, struct
> > +fec_enet_private *fep) {
> > +	struct bufdesc *base;
> > +	int index;
> > +
> > +	if (bdp >= fep->tx_bd_base)
> > +		base = fep->tx_bd_base;
> > +	else
> > +		base = fep->rx_bd_base;
> 
> You really don't want the above conditional.
> It is known from the call site - but the compiler can't determine that and
> remove the test.
Can you give me more training for this ?  Sorry, I don't understand the means. 

> You may not want to rely on the tx and rx descriptors being allocated as a
> single entity - particularly now that they (probably) consume more than a
> single page.
> 
BDs consumes more than single page, but it use " dma_alloc_coherent()" to allocate continuous memory,
I don't know why it is cannot do it like this.

> > +
> > +	if (fep->bufdesc_ex)
> > +		index = (struct bufdesc_ex *)bdp - (struct bufdesc_ex *)base;
> > +	else
> > +		index = bdp - base;
> 
> Save the sizeof the descriptor structure as (say) fep->bufdesc_size
> (Possibly replacing bufdesc_ex) and then just calculate:
> 	index = ((const char *)bdp - (const char *)base)/fep->bufdesc_size;
> 
> 	David
> 
You means:
if (fep->bufdesc_ex)
	bufdesc_size = sizeof(struct bufdesc_ex);
else
	bufdesc_size = sizeof(struct bufdesc);
index = ((const char *)bdp - (const char *)base)/bufdesc_size;


Thanks,
Andy
