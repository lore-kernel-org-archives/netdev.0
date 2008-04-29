From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: RE: [PATCH] ucc_geth: Ack IRQ events as late as possible.
Date: Tue, 29 Apr 2008 13:14:04 +0200
Message-ID: <1209467644.6904.46.camel@gentoo-jocke.transmode.se>
References: <1209138209-8073-1-git-send-email-Joakim.Tjernlund@transmode.se>
	 <989B956029373F45A0B8AF029708189002007ECF@zch01exm26.fsl.freescale.net>
Reply-To: joakim.tjernlund@transmode.se
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Li Yang <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.transmode.se ([83.241.175.147]:17333 "EHLO
	tmnt04.transmode.se" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756942AbYD2LOH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 07:14:07 -0400
In-Reply-To: <989B956029373F45A0B8AF029708189002007ECF@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2008-04-29 at 17:26 +0800, Li Yang wrote:
> > -----Original Message-----
> > From: Joakim Tjernlund [mailto:Joakim.Tjernlund@transmode.se] 
> > Sent: Friday, April 25, 2008 11:43 PM
> > To: Li Yang; Netdev
> > Cc: Joakim Tjernlund
> > Subject: [PATCH] ucc_geth: Ack IRQ events as late as possible.
> > 
> > Late acking of IRQ events will reduce number of interrupts 
> > that needs to be served.
> > 
> > Makes the system somewhat responsive during a ping -f -l 10
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> >  drivers/net/ucc_geth.c |   36 ++++++++++++++++++++++--------------
> >  drivers/net/ucc_geth.h |    4 ++--
> >  2 files changed, 24 insertions(+), 16 deletions(-)
> > 
> > diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c 
> > index 28431aa..c6bf4d3 100644
> > --- a/drivers/net/ucc_geth.c
> > +++ b/drivers/net/ucc_geth.c
> > @@ -3449,6 +3449,7 @@ static int ucc_geth_rx(struct 
> > ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
> >  	u32 bd_status;
> >  	u8 *bdBuffer;
> >  	struct net_device *dev;
> > +	struct ucc_fast_private *uccf = ugeth->uccf;
> >  
> >  	ugeth_vdbg("%s: IN", __FUNCTION__);
> >  
> > @@ -3457,10 +3458,21 @@ static int ucc_geth_rx(struct 
> > ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
> >  	/* collect received buffers */
> >  	bd = ugeth->rxBd[rxQ];
> >  
> > -	bd_status = in_be32((u32 *)bd);
> > -
> >  	/* while there are received buffers and BD is full (~R_E) */
> > -	while (!((bd_status & (R_E)) || (--rx_work_limit < 0))) {
> > +	while (1) {
> > +		if (in_be32(uccf->p_ucce) & UCCE_BSY) {
> > +			dev->stats.rx_missed_errors++;
> > +			dev->stats.rx_errors++;
> > +		}
> > +		out_be32(uccf->p_ucce, UCCE_RX_EVENTS);
> > +
> > +		if (--rx_work_limit < 0)
> > +			break;
> > +
> > +		bd_status = in_be32((u32 *)bd);
> > +		if (bd_status & R_E)
> > +			break; /* No more RX buffers */
> > +
> >  		bdBuffer = (u8 *) in_be32(&((struct qe_bd *)bd)->buf);
> >  		length = (u16) ((bd_status & BD_LENGTH_MASK) - 4);
> >  		skb = ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]];
> > @@ -3530,6 +3542,7 @@ static int ucc_geth_tx(struct 
> > net_device *dev, u8 txQ)  {
> >  	/* Start from the next BD that should be filled */
> >  	struct ucc_geth_private *ugeth = netdev_priv(dev);
> > +	struct ucc_fast_private *uccf = ugeth->uccf;
> >  	u8 *bd;			/* BD pointer */
> >  	u32 bd_status;
> >  
> > @@ -3541,6 +3554,7 @@ static int ucc_geth_tx(struct 
> > net_device *dev, u8 txQ)
> >  		/* BD contains already transmitted buffer.   */
> >  		/* Handle the transmitted buffer and release */
> >  		/* the BD to be used with the current frame  */
> > +		out_be32(uccf->p_ucce, UCCE_TX_EVENTS);
> >  
> >  		if ((bd == ugeth->txBd[txQ]) && 
> > (netif_queue_stopped(dev) == 0))
> >  			break;
> > @@ -3619,10 +3633,8 @@ static irqreturn_t 
> > ucc_geth_irq_handler(int irq, void *info)
> >  	ug_info = ugeth->ug_info;
> >  
> >  	/* read and clear events */
> > -	ucce = (u32) in_be32(uccf->p_ucce);
> >  	uccm = (u32) in_be32(uccf->p_uccm);
> > -	ucce &= uccm;
> > -	out_be32(uccf->p_ucce, ucce);
> > +	ucce = (u32) in_be32(uccf->p_ucce) & uccm;
> >  
> >  	/* check for receive events that require processing */
> >  	if (ucce & UCCE_RX_EVENTS) {
> > @@ -3643,6 +3655,7 @@ static irqreturn_t 
> > ucc_geth_irq_handler(int irq, void *info)  #endif /* 
> > CONFIG_UGETH_NAPI */
> >  	}
> >  
> > +	ucce = (u32) in_be32(uccf->p_ucce) & uccm;
> >  	/* Tx event processing */
> >  	if (ucce & UCCE_TX_EVENTS) {
> >  		spin_lock(&ugeth->lock);
> > @@ -3655,15 +3668,10 @@ static irqreturn_t 
> > ucc_geth_irq_handler(int irq, void *info)
> >  		}
> >  		spin_unlock(&ugeth->lock);
> >  	}
> > -
> > -	/* Errors and other events */
> > +	ucce = (u32) in_be32(uccf->p_ucce) & uccm;
> > +	/* Other events */
> >  	if (ucce & UCCE_OTHER) {
> > -		if (ucce & UCCE_BSY) {
> > -			dev->stats.rx_errors++;
> > -		}
> > -		if (ucce & UCCE_TXE) {
> > -			dev->stats.tx_errors++;
> > -		}
> > +		out_be32(uccf->p_ucce, UCCE_OTHER);
> >  	}
> >  
> >  	return IRQ_HANDLED;
> > diff --git a/drivers/net/ucc_geth.h b/drivers/net/ucc_geth.h 
> > index cc24e87..7451f17 100644
> > --- a/drivers/net/ucc_geth.h
> > +++ b/drivers/net/ucc_geth.h
> > @@ -207,8 +207,8 @@ struct ucc_geth {
> >  			UCCE_RXB3 | UCCE_RXB2 | UCCE_RXB1 | UCCE_RXB0)
> >  #define UCCE_RXF         (UCCE_RXF7 | UCCE_RXF6 | UCCE_RXF5 
> > | UCCE_RXF4 |\
> >  			UCCE_RXF3 | UCCE_RXF2 | UCCE_RXF1 | UCCE_RXF0)
> > -#define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA  | UCCE_CBPR 
> > | UCCE_BSY  |\
> > -			UCCE_RXC  | UCCE_TXC  | UCCE_TXE)
> > +#define UCCE_OTHER       (UCCE_SCAR | UCCE_GRA | UCCE_CBPR |\
> > +			UCCE_RXC  | UCCE_TXC)
> 
> This will remove UCCE_BSY and UCCE_TXE from the uccm_mask, hence
> disabled them from generating interrupts.

Yeah, got mislead by the UCCE_RX_EVENTS and UCC_TX_EVENTS just below.
So the UCCE_OTHER change should go, but the rest stay.

> 
> How is the improvement after your change to put off interrupt ack?
> Isn't it caused by disabling the busy interrupts?

Not sure, got no time to measure ATM. Besides that, I do think this
change is needed anyway. There is no sane way to handle the stats
counters in the main irq loop. The next step would be to actually start
counting errors. Agreed?

> 
> - Leo
> 
> 
