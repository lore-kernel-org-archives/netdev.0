From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: fix rxvlan feature
Date: Tue, 10 Mar 2015 10:02:26 +0000
Message-ID: <BY2PR03MB377A6CBBDA4B25EB098EA64F5180@BY2PR03MB377.namprd03.prod.outlook.com>
References: <1425920153-13319-1-git-send-email-m.grzeschik@pengutronix.de>
 <20150309.224258.796431155596045482.davem@davemloft.net>
 <BY2PR03MB377A83B758C88EBD3B689DEF5180@BY2PR03MB377.namprd03.prod.outlook.com>
 <20150310093908.GA6704@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Michael Grzeschik <mgr@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0119.outbound.protection.outlook.com ([207.46.100.119]:3396
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751057AbbCJKC3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 06:02:29 -0400
In-Reply-To: <20150310093908.GA6704@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <mgr@pengutronix.de> Sent: Tuesday, March 10, 2015 5:39 PM
> To: Duan Fugang-B38611
> Cc: David Miller; Li Frank-B20596; netdev@vger.kernel.org;
> kernel@pengutronix.de
> Subject: Re: [PATCH] net: fec: fix rxvlan feature
> 
> 
> On Tue, Mar 10, 2015 at 03:29:35AM +0000, fugang.duan@freescale.com wrote:
> > From: David Miller <davem@davemloft.net> Sent: Tuesday, March 10, 2015
> > 10:43 AM
> > > To: m.grzeschik@pengutronix.de
> > > Cc: Duan Fugang-B38611; Li Frank-B20596; netdev@vger.kernel.org;
> > > kernel@pengutronix.de
> > > Subject: Re: [PATCH] net: fec: fix rxvlan feature
> > >
> > > From: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > > Date: Mon,  9 Mar 2015 17:55:53 +0100
> > >
> > > > The patch 1b7bde6d659d30f171259cc2dfba8e5dab34e735
> > > > "net: fec: implement rx_copybreak to improve rx performance"
> > > > changed the code path for the vlan check in fec_enet_rx_queue:
> > > >
> > > >  @@ -1417,62 +1486,48 @@ fec_enet_rx_queue(struct net_device
> > > > *ndev, int
> > > budget, u16 queue_id)
> > > >  		/* If this is a VLAN packet remove the VLAN Tag */
> > > >  		vlan_packet_rcvd = false;
> > > >  		if ((ndev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
> > > >  			fep->bufdesc_ex && (ebdp->cbd_esc &
> BD_ENET_RX_VLAN)) {
> > > >  			/* Push and remove the vlan tag */
> > > >                          struct vlan_hdr *vlan_header =
> > > >                                          (struct vlan_hdr *) (data
> > > > +
> > > ETH_HLEN);
> > > >                          vlan_tag = ntohs(vlan_header->h_vlan_TCI);
> > > >  -                       pkt_len -= VLAN_HLEN;
> > > >
> > > >                          vlan_packet_rcvd = true;  +
> > > >  +                       skb_copy_to_linear_data_offset(skb,
> VLAN_HLEN,
> > > >  +                                                      data, (2 *
> > > ETH_ALEN));
> > > >  +                       skb_pull(skb, VLAN_HLEN);
> > > >                  }
> > > >
> > > > With the call of skb_copy_to_linear_data_offset the code here is
> > > > doing more than previously and is breaking the rxvlan feature.
> > > > This patch removes this call to fix it.
> > > >
> > > > Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > >
> > > But don't we want to copy the proper header there in the linear case?
> > >
> > > I'd rather hear from the original author why they put that copy
> > > there before it just gets blindly removed.
> > >
> > > And you'll need to update your commit message with more explanation
> > > once that discussion occurs.
> >
> > There have no function change comparing with previous commit version.
> > If enable hw VLAN support (sw simulate hw), software remove VLAN tag.
> >
> > Below code is previous code base, it also removes the VLAN tag.
> > -                       /* Extract the frame data without the VLAN
> header. */
> > -                       skb_copy_to_linear_data(skb, data, (2 *
> ETH_ALEN));
> > -                       if (vlan_packet_rcvd)
> > -                               payload_offset = (2 * ETH_ALEN) +
> VLAN_HLEN;
> > -                       skb_copy_to_linear_data_offset(skb, (2 *
> ETH_ALEN),
> > -                                                      data +
> payload_offset,
> > -                                                      pkt_len - 4 - (2
> * ETH_ALEN));
> >
> >
> > Does there have un-correct points ? I did run some VLAN test pass.
> 
> Yes, in the previous version the skb_copy_... functions were working on
> two different memory pointers. The code was calling netdev_alloc_skb to
> create the new memory.
> 
> Currently the code is calling this:
> 
> data = skb->data;
> 
> which leads the skb_copy_... operations, which are no more then memcpy,
> to work on the same memory. This can not be valid.
> 
You are right. I will generate one patch for the issue and then pls help for the test with your case.

Regards,
Andy
