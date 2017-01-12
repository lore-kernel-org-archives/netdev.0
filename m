From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH/RFC net] ravb: do not use zero-length alighment DMA
 request
Date: Thu, 12 Jan 2017 16:46:47 +0100
Message-ID: <20170112154647.GA2329@verge.net.au>
References: <1484229217-25585-1-git-send-email-horms+renesas@verge.net.au>
 <20170112.102102.2249793963798495642.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com, magnus.damm@gmail.com,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170112.102102.2249793963798495642.davem@davemloft.net>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 12, 2017 at 10:21:02AM -0500, David Miller wrote:
> From: Simon Horman <horms+renesas@verge.net.au>
> Date: Thu, 12 Jan 2017 14:53:37 +0100
> 
> > diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
> > index 92d7692c840d..3b4d2504285e 100644
> > --- a/drivers/net/ethernet/renesas/ravb_main.c
> > +++ b/drivers/net/ethernet/renesas/ravb_main.c
> > @@ -1508,6 +1508,8 @@ static netdev_tx_t ravb_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> >  	buffer = PTR_ALIGN(priv->tx_align[q], DPTR_ALIGN) +
> >  		 entry / NUM_TX_DESC * DPTR_ALIGN;
> >  	len = PTR_ALIGN(skb->data, DPTR_ALIGN) - skb->data;
> > +	if (len == 0)
> > +		len = skb->len > 4 ? 4 : skb->len;
> >  	memcpy(buffer, skb->data, len);
> >  	dma_addr = dma_map_single(ndev->dev.parent, buffer, len, DMA_TO_DEVICE);
> >  	if (dma_mapping_error(ndev->dev.parent, dma_addr))
> 
> Assume len ends up being skb->len, then the second DMA mapping will be
> made of zero length.
> 
> This code needs a bit of TLC.

Thanks, I realised that after sending this patch.

What I now see is that a few lines further up there is:

	 if (skb_put_padto(skb, ETH_ZLEN))
		goto drop;

	where ETH_ZLEN is 60.

So I don't think we need to worry about skb->len being less than 60 and
this patch can be simplified to:

	if (len == 0)
		len = 4;
