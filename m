From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 1/2] net: More fine-grained support for
 encapsulated GSO features
Date: Thu, 25 Apr 2013 17:03:10 +0900
Message-ID: <20130425080310.GC29748@verge.net.au>
References: <1366683556-4956-1-git-send-email-horms@verge.net.au>
 <1366683556-4956-2-git-send-email-horms@verge.net.au>
 <alpine.LFD.2.02.1304231354440.5598@morpheus.jf.intel.com>
 <20130425073644.GC7936@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, jarno.rajahalme@nsn.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Maciej =?utf-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:34517 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754869Ab3DYIDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 04:03:13 -0400
Content-Disposition: inline
In-Reply-To: <20130425073644.GC7936@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 04:36:44PM +0900, Simon Horman wrote:
> On Tue, Apr 23, 2013 at 02:00:19PM -0700, Joseph Gasparakis wrote:
> > 
> > 
> > On Mon, 22 Apr 2013, Simon Horman wrote:
> > 
> > > "net: Add support for hardware-offloaded encapsulation" introduced
> > > the encapsulation field of struct skb, which when set provides hints
> > > that GSO should handle an skb that encapsulates a packet.
> > > 
> > > This patch adds an encapsulation_features field which provides
> > > a hint to dev dev_hard_start_xmit() that harware-offload encapsulation
> > > features should be used. Previously this hint was provided by the
> > > encapsulation field.
> > > 
> > > The other uses of the encapsulation field are left unchanged.
> > > 
> > > The two in-tree locations that set the encapsulation have been updated to
> > > also set encapsulation_field.
> > > 
> > > The motivation for this is to provide support segmentation of GSO MPLS skbs.
> > > This may be necessary when a non-MPLS GSO skb is turned into an MPLS GSO
> > > skb by Open vSwtich and its MPLS push action.
> > > 
> > > In this case it  harware-offload encapsulation features should be used,
> > > actually to be more exact software segmentation should be selected, but
> > > other hints provided by the encapsulation field are not applicable.
> > > 
> > > Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
> > > Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
> > > Cc: Alexander Duyck <alexander.h.duyck@intel.com>
> > > Signed-off-by: Simon Horman <horms@verge.net.au>
> > > ---
> > >  include/linux/skbuff.h | 9 ++++++++-
> > >  net/core/dev.c         | 2 +-
> > >  net/core/skbuff.c      | 1 +
> > >  net/ipv4/gre.c         | 1 +
> > >  net/ipv4/ipip.c        | 1 +
> > >  5 files changed, 12 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> > > index 2e0ced1..d9ec1de 100644
> > > --- a/include/linux/skbuff.h
> > > +++ b/include/linux/skbuff.h
> > > @@ -494,7 +494,14 @@ struct sk_buff {
> > >  	 * headers if needed
> > >  	 */
> > >  	__u8			encapsulation:1;
> > > -	/* 7/9 bit hole (depending on ndisc_nodetype presence) */
> > > +	/* Encapsulation protocol and NIC drivers should use
> > > +	 * this flag to indicate to each other if the skb contains
> > > +	 * encapsulated packet and GSO should use encapsulation features
> > > +	 * instead of standard features for the netdev. This is typically
> > > +	 * a subset of cases where skb->encapsulation is set.
> > > +	 */
> > > +	__u8			encapsulation_features:1;
> > > +	/* 6/8 bit hole (depending on ndisc_nodetype presence) */
> > >  	kmemcheck_bitfield_end(flags2);
> > >  
> > >  #ifdef CONFIG_NET_DMA
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 9e26b8d..53236c5 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -2498,7 +2498,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
> > >  		 * hardware encapsulation features instead of standard
> > >  		 * features for the netdev
> > >  		 */
> > > -		if (skb->encapsulation)
> > > +		if (skb->encapsulation_features)
> > >  			features &= dev->hw_enc_features;
> > >  
> > >  		if (netif_needs_gso(skb, features)) {
> > > diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> > > index 898cf5c..f23d136 100644
> > > --- a/net/core/skbuff.c
> > > +++ b/net/core/skbuff.c
> > > @@ -708,6 +708,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
> > >  	new->l4_rxhash		= old->l4_rxhash;
> > >  	new->no_fcs		= old->no_fcs;
> > >  	new->encapsulation	= old->encapsulation;
> > > +	new->encapsulation_features = old->encapsulation_features;
> > >  #ifdef CONFIG_XFRM
> > >  	new->sp			= secpath_get(old->sp);
> > >  #endif
> > > diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
> > > index 0ae998b..8420f29 100644
> > > --- a/net/ipv4/gre.c
> > > +++ b/net/ipv4/gre.c
> > > @@ -157,6 +157,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
> > >  	}
> > >  
> > >  	skb->encapsulation = 0;
> > > +	skb->encapsulation_features = 0;
> > >  
> > >  	if (unlikely(!pskb_may_pull(skb, ghl)))
> > >  		goto out;
> > > diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> > > index 77bfcce..a6db3c0 100644
> > > --- a/net/ipv4/ipip.c
> > > +++ b/net/ipv4/ipip.c
> > > @@ -220,6 +220,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
> > >  	if (likely(!skb->encapsulation)) {
> > >  		skb_reset_inner_headers(skb);
> > >  		skb->encapsulation = 1;
> > > +		skb->encapsulation_features = 1;
> > >  	}
> > >  
> > >  	ip_tunnel_xmit(skb, dev, tiph);
> > > 
> > 
> > Any particular reason to introduce skb->encapsulation_features instead of 
> > using the existing skb->encapsulation? Also I don't see it used in your 
> > second patch either.
> 
> My reasoning is that skb->encapsulation seems to alter the behaviour of
> many different locations and I'm not sure that any of them, other than the
> one in dev_hard_start_xmit() make sense for MPLS.
> 
> For example the following in inet_gso_segment()
> 
> 	tunnel = !!skb->encapsulation;
> 	...
> 	do {
> 		...
> 		if (!tunnel && proto == IPPROTO_UDP) {
> 			iph->id = htons(id);
> 			iph->frag_off = htons(offset >> 3);
> 			if (skb->next != NULL)
> 				iph->frag_off |= htons(IP_MF);
> 			offset += (skb->len - skb->mac_len - iph->ihl * 4);
> 		} else  {
> 			iph->id = htons(id++);
> 		}
> 		...
> 
> On reflection I need to examine the relevant code-paths more closely, but I
> believe the !tunnel portion of the above code is intended to help effect
> GSO segmentation UDP tunnelling protocols and is not relevant to MPLS.

I forgot to mention in my previous email that this change is used in the
patch "[PATCH v2.26] datapath: Add basic MPLS support to kernel".
