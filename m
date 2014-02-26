From: =?utf-8?B?U8O2cmVu?= Brinkmann <soren.brinkmann@xilinx.com>
Subject: Re: [PATCH RFC 1/2] net: macb: Check DMA mappings for error
Date: Wed, 26 Feb 2014 10:36:42 -0800
Message-ID: <bcd23902-b961-4c12-b577-29dec9b1d6d1@TX2EHSMHS010.ehs.local>
References: <1393011025-18537-1-git-send-email-soren.brinkmann@xilinx.com>
 <1393011025-18537-2-git-send-email-soren.brinkmann@xilinx.com>
 <1393114393.6823.25.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, Vinod Koul <vinod.koul@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393114393.6823.25.camel@deadeye.wl.decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-02-23 at 12:13AM +0000, Ben Hutchings wrote:
> On Fri, 2014-02-21 at 11:30 -0800, Soren Brinkmann wrote:
> [...]
> > --- a/drivers/net/ethernet/cadence/macb.c
> > +++ b/drivers/net/ethernet/cadence/macb.c
> > @@ -632,11 +632,16 @@ static void gem_rx_refill(struct macb *bp)
> >  					   "Unable to allocate sk_buff\n");
> >  				break;
> >  			}
> > -			bp->rx_skbuff[entry] =3D skb;
> > =20
> >  			/* now fill corresponding descriptor entry */
> >  			paddr =3D dma_map_single(&bp->pdev->dev, skb->data,
> >  					       bp->rx_buffer_size, DMA_FROM_DEVICE);
> > +			if (dma_mapping_error(&bp->pdev->dev, paddr)) {
> > +				dev_kfree_skb(skb);
> > +				break;
> > +			}
> > +
> > +			bp->rx_skbuff[entry] =3D skb;
>=20
> This bit looks good.
>=20
> >  			if (entry =3D=3D RX_RING_SIZE - 1)
> >  				paddr |=3D MACB_BIT(RX_WRAP);
> > @@ -1040,6 +1045,10 @@ static int macb_start_xmit(struct sk_buff *s=
kb, struct net_device *dev)
> >  	netdev_vdbg(bp->dev, "Allocated ring entry %u\n", entry);
> >  	mapping =3D dma_map_single(&bp->pdev->dev, skb->data,
> >  				 len, DMA_TO_DEVICE);
> > +	if (dma_mapping_error(&bp->pdev->dev, mapping)) {
> > +		dev_kfree_skb(skb);
>=20
> You need to unlock bp->lock before returning.  Also, I think this sho=
uld
> be kfree_skb(), as that can be observed through dropwatch whereas
> dev_kfree_skb() is completely silent.

I interpret Ben's comments as: This series is not utterly wrong and
wanted. I'll send a v2 with the changes Ben suggested.
Thanks for reviewing.

	S=C3=B6ren
