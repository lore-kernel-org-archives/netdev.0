From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v3 net-next] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Mon, 2 Jun 2014 13:39:50 +0900
Message-ID: <20140602043947.GA28083@verge.net.au>
References: <1401669515-24142-1-git-send-email-horms@verge.net.au>
 <20140602035153.E5721710BF@kuma.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, dev@openvswitch.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:56572 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbaFBEjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 00:39:54 -0400
Content-Disposition: inline
In-Reply-To: <20140602035153.E5721710BF@kuma.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 02, 2014 at 12:51:53PM +0900, YAMAMOTO Takashi wrote:
> > If an MPLS packet requires segmentation then use mpls_features
> > to determine if the software implementation should be used.
> > 
> > As no driver advertises MPLS GSO segmentation this will always be
> > the case.
> > 
> > I had not noticed that this was necessary before as software MPLS GSO
> > segmentation was already being used in my test environment. I believe that
> > the reason for that is the skbs in question always had fragments and the
> > driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> > case for most drivers). Thus software segmentation was activated by
> > skb_gso_ok().
> > 
> > Thanks to Jesse Gross for prompting me to investigate this.
> > 
> > Acked-by: Jesse Gross <jesse@nicira.com>
> > Signed-off-by: Simon Horman <horms@verge.net.au>
> > 
> > ---
> > v3
> > * As requested by David Miller
> >   - Do not mark net_mpls_features as inline
> >   - Correct alignment of parameters
> > 
> > v2
> > * Added Ack from Jesse Gross
> > * Removed duplicate 'Thus' from changelog
> > ---
> >  net/core/dev.c | 38 ++++++++++++++++++++++++++++++++++++++
> >  1 file changed, 38 insertions(+)
> > 
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0355ca5..1aa7004 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -2540,6 +2540,42 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
> >  }
> >  EXPORT_SYMBOL(netif_skb_features);
> >  
> > +/* If MPLS offload request, verify we are testing hardware MPLS features
> > + * instead of standard features for the netdev.
> > + */
> > +#ifdef CONFIG_NET_MPLS_GSO
> > +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> > +					   struct net_device *dev,
> > +					   netdev_features_t features)
> > +{
> > +	/* There is no support for MPLS LRO. So the only way that
> > +	 * an MPLS skb could require GSO segmentation is if it
> > +	 * was received as a non-MPLS skb and then became an MPLS skb.
> > +	 * This may be effected by Open vSwitch in which case the
> > +	 * mac_len will non-zero and not equal to skb_network_offset
> > +	 * as the former indicates the end of L2 the latter indicates
> 
> s/L2/& and/
> 
> > +	 * the beginning of L3 and there is a gap between them occupied
> > +	 * by the MPLS label stack.
> > +	 *
> > +	 * Thus it is possible to avoid traversing any VLAN tags that are
> > +	 * present to determine if the ethtype is MPLS. Instead the
> > +	 * inequality of mac_llen and skb_network_offset are used to
> 
> s/mac_llen/mac_len/
> 
> Acked-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

Thanks, I will fix that and post v4.
