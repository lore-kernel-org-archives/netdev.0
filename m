From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v3 1/6] net: fec: Factorize the .xmit transmit function
Date: Thu, 5 Jun 2014 09:58:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17257ACC@AcuExch.aculab.com>
References: <1401951572-6538-1-git-send-email-b38611@freescale.com>
 <1401951572-6538-2-git-send-email-b38611@freescale.com>
 <063D6719AE5E284EB5DD2968C1650D6D17257A93@AcuExch.aculab.com>
 <d93f47b1073f46319b170dee27206bed@BLUPR03MB373.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
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
To: "'fugang.duan@freescale.com'" <fugang.duan@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45212 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750910AbaFEJ6n convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 05:58:43 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 32213-01 for <netdev@vger.kernel.org>;
 Thu,  5 Jun 2014 10:58:34 +0100 (BST)
In-Reply-To: <d93f47b1073f46319b170dee27206bed@BLUPR03MB373.namprd03.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: fugang.duan@freescale.
> > From: Fugang Duan
> > > Make the code more readable and easy to support other features like
> > > SG, TSO, moving the common transmit function to one api.
> > >
> > > And the patch also factorize the getting BD index to it own function.
> > >
> > > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > > ---
> > >  drivers/net/ethernet/freescale/fec_main.c |   87 ++++++++++++++++++-----
> > ------
> > >  1 files changed, 54 insertions(+), 33 deletions(-)
> > >
> > > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > > b/drivers/net/ethernet/freescale/fec_main.c
> > > index 802be17..32c2276 100644
> > > --- a/drivers/net/ethernet/freescale/fec_main.c
> > > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > > @@ -287,6 +287,25 @@ struct bufdesc *fec_enet_get_prevdesc(struct bufdesc
> > *bdp, struct fec_enet_priva
> > >  		return (new_bd < base) ? (new_bd + ring_size) : new_bd;  }
> > >
> > > +static inline
> > > +int fec_enet_get_bd_index(struct bufdesc *bdp, struct
> > > +fec_enet_private *fep) {
> > > +	struct bufdesc *base;
> > > +	int index;
> > > +
> > > +	if (bdp >= fep->tx_bd_base)
> > > +		base = fep->tx_bd_base;
> > > +	else
> > > +		base = fep->rx_bd_base;
> >
> > You really don't want the above conditional.
> > It is known from the call site - but the compiler can't determine that and
> > remove the test.

> Can you give me more training for this ?  Sorry, I don't understand the means.

Single 'if' statements can have measurable performance impact on ethernet
code paths - so it isn't a good idea to add ones that aren't strictly required.

If the function had an extra argument 'tx_ring' (don't add one) which
would be constant at all the call sites and the code read:
	base = tx_ring ? fep->tx_bd_base : fep->rx_bd_base;
when the compiler inlines the function calls it would be able to
optimise away the conditional.

> > You may not want to rely on the tx and rx descriptors being allocated as a
> > single entity - particularly now that they (probably) consume more than a
> > single page.
> >
> BDs consumes more than single page, but it use " dma_alloc_coherent()" to allocate continuous memory,
> I don't know why it is cannot do it like this.
> 
> > > +
> > > +	if (fep->bufdesc_ex)
> > > +		index = (struct bufdesc_ex *)bdp - (struct bufdesc_ex *)base;
> > > +	else
> > > +		index = bdp - base;
> >
> > Save the sizeof the descriptor structure as (say) fep->bufdesc_size
> > (Possibly replacing bufdesc_ex) and then just calculate:
> > 	index = ((const char *)bdp - (const char *)base)/fep->bufdesc_size;
> >
> > 	David
> >
> You means:
> if (fep->bufdesc_ex)
> 	bufdesc_size = sizeof(struct bufdesc_ex);
> else
> 	bufdesc_size = sizeof(struct bufdesc);
> index = ((const char *)bdp - (const char *)base)/bufdesc_size;

No, that is still a conditional in the normal path.
Assign fep->bufdesc_size during initialisation.

Then end up with something like:
static
int fec_enet_get_bd_index(struct bufdesc *base, struct bufdesc *bdp,
		struct fec_enet_private *fep)
{
	return ((const char *)bdp - (const char *)base)/fep->bufdesc_size;
}

	David
