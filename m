From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v2] net: Loosen constraints for recalculating
 checksum in skb_segment()
Date: Mon, 20 May 2013 12:19:04 +0900
Message-ID: <20130520031904.GF16811@verge.net.au>
References: <1368773342-31882-1-git-send-email-horms@verge.net.au>
 <1368810123.3301.96.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43940 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192Ab3ETDTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 23:19:08 -0400
Content-Disposition: inline
In-Reply-To: <1368810123.3301.96.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 10:02:03AM -0700, Eric Dumazet wrote:
> On Fri, 2013-05-17 at 15:49 +0900, Simon Horman wrote:
> > In the case where the ability to offload checksums changes
> > then it may be necessary for software checksumming of an skb to occur.
> > 
> > An example of such a case is where a non-GRE packet is received but
> > is to be encapsulated and transmitted as GRE.
> > 
> > Another example relates to my proposed support for for GSO packets
> > that are non-MPLS when received but MPLS when transmitted.
> > 
> > The cost of this change is that csum may be checked when it previously
> > was not. In the case where csum is true this is pure overhead. In the
> > case where csum is false it leads to software checksumming, which
> > I believe also leads to correct checksums in transmitted packets for
> > the cases described above.
> > 
> > This patch relies on the return value of can_checksum_protocol()
> > being correct and in turn the return value of skb_network_protocol(),
> > used to provide the protocol parameter of can_checksum_protocol(),
> > being correct. It also relies on the features passed to skb_segment()
> > and in turn to can_checksum_protocol() being correct.
> > 
> > I believe that this problem does has not been observed for VLANs because it
> > appears that all drivers except xgbe set vlan_features such that that the
> > checksum offload support for VLAN packets is greater than or equal to that
> > of non-VLAN packets.
> > 
> > I wonder if the code in xgbe may be an oversight and the hardware does
> > support checksumming of VLAN packets.  If so it may be worth updating the
> > vlan_features of the driver as this patch will force such checksums to be
> > performed in software rather than hardware.
> > 
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > ---
> > 
> > Tested using the bnx2 driver.
> > 
> > v2
> > Rewrite changlog after further analysis
> > ---
> >  net/core/skbuff.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > index af9185d..3a43be4 100644
> > --- a/net/core/skbuff.c
> > +++ b/net/core/skbuff.c
> > @@ -2853,7 +2853,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
> >  						 doffset + tnl_hlen);
> >  
> >  		if (fskb != skb_shinfo(skb)->frag_list)
> > -			continue;
> > +			goto csum;
> >  
> >  		if (!sg) {
> >  			nskb->ip_summed = CHECKSUM_NONE;
> > @@ -2917,6 +2917,7 @@ skip_fraglist:
> >  		nskb->len += nskb->data_len;
> >  		nskb->truesize += nskb->data_len;
> >  
> > +csum:
> >  		if (!csum) {
> >  			nskb->csum = skb_checksum(nskb, doffset,
> >  						  nskb->len - doffset, 0);
> 
> 
> I had hard time to understand this patch, but I think I now get it.
> 
> Changelog seems to be very specific, while the change looks like a more
> generic problem about skbs having a frag_list ? Oh well...
> 
> skb_segment() is probably too complex for my understanding.
> 
> Could you please change the label name ?
> 
> perform_csum_check for example, and maybe it would be easier :)

Thanks, I have updated and reposted the patch accordingly.
I also update the change log to try and make things clearer.
