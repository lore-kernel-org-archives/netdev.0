From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [PATCH net 1/4] sh_eth: Ensure proper ordering of descriptor
 active bit write/read
Date: Mon, 13 Apr 2015 23:32:02 +0100
Message-ID: <1428964322.8341.47.camel@xylophone.i.decadent.org.uk>
References: <1425343868.4288.8.camel@xylophone.i.decadent.org.uk>
	 <1425343920.4288.9.camel@xylophone.i.decadent.org.uk>
	 <5526FB5A.8090005@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:49426 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbDMWcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 18:32:08 -0400
In-Reply-To: <5526FB5A.8090005@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-10 at 01:21 +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 03/03/2015 03:52 AM, Ben Hutchings wrote:
> 
> > When submitting a DMA descriptor, the active bit must be written last.
> > When reading a completed DMA descriptor, the active bit must be read
> > first.
> 
> > Add memory barriers to ensure that this ordering is maintained.
> 
>     Looks like those should have been lighter dma_rmb() and dma_wmb() instead.

Yes, I think so.  I missed those additions to the DMA API.

Ben.

> Correct, Alexander?
> 
> > Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> > ---
> >   drivers/net/ethernet/renesas/sh_eth.c |    6 ++++++
> >   1 file changed, 6 insertions(+)
> >
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index 654b48d1e61a..5c212a833bcf 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> > @@ -1410,6 +1410,8 @@ static int sh_eth_txfree(struct net_device *ndev)
> >   		txdesc = &mdp->tx_ring[entry];
> >   		if (txdesc->status & cpu_to_edmac(mdp, TD_TACT))
> >   			break;
> > +		/* TACT bit must be checked before all the following reads */
> > +		rmb();
> >   		/* Free the original skb. */
> >   		if (mdp->tx_skbuff[entry]) {
> >   			dma_unmap_single(&ndev->dev, txdesc->addr,
> > @@ -1447,6 +1449,8 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
> >   	limit = boguscnt;
> >   	rxdesc = &mdp->rx_ring[entry];
> >   	while (!(rxdesc->status & cpu_to_edmac(mdp, RD_RACT))) {
> > +		/* RACT bit must be checked before all the following reads */
> > +		rmb();
> >   		desc_status = edmac_to_cpu(mdp, rxdesc->status);
> >   		pkt_len = rxdesc->frame_length;
> >
> > @@ -1526,6 +1530,7 @@ static int sh_eth_rx(struct net_device *ndev, u32 intr_status, int *quota)
> >   			skb_checksum_none_assert(skb);
> >   			rxdesc->addr = dma_addr;
> >   		}
> > +		wmb(); /* RACT bit must be set after all the above writes */
> >   		if (entry >= mdp->num_rx_ring - 1)
> >   			rxdesc->status |=
> >   				cpu_to_edmac(mdp, RD_RACT | RD_RFP | RD_RDEL);
> > @@ -2195,6 +2200,7 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >   	}
> >   	txdesc->buffer_length = skb->len;
> >
> > +	wmb(); /* TACT bit must be set after all the above writes */
> >   	if (entry >= mdp->num_tx_ring - 1)
> >   		txdesc->status |= cpu_to_edmac(mdp, TD_TACT | TD_TDLE);
> >   	else
> 
> WBR, Sergei
> 
