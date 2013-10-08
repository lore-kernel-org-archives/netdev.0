From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v2 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Tue, 8 Oct 2013 13:40:07 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD012F2F2@AMSPEX01CL01.citrite.net>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-6-git-send-email-paul.durrant@citrix.com>
 <20131008133421.GK28411@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:31895 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753805Ab3JHNkK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 09:40:10 -0400
In-Reply-To: <20131008133421.GK28411@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 08 October 2013 14:34
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [PATCH net-next v2 5/5] xen-netback: enable IPv6 TCP GSO to
> the guest
> 
> On Tue, Oct 08, 2013 at 11:58:16AM +0100, Paul Durrant wrote:
> [...]
> >  	/* Data must not cross a page boundary. */
> >  	BUG_ON(size + offset > PAGE_SIZE<<compound_order(page));
> > @@ -392,7 +393,14 @@ static void xenvif_gop_frag_copy(struct xenvif
> *vif, struct sk_buff *skb,
> >  		}
> >
> >  		/* Leave a gap for the GSO descriptor. */
> > -		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> > +		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> > +			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> > +		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)
> > +			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> > +		else
> > +			gso_type = 0;
> 
> Should probably #define XEN_NETIF_GSO_TYPE_NONE 0 instead of using
> plain
> 0?

All I need is a bit shift that's not going to hit in the mask. Probably worth reserving the value in the header.

> 
> > +	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
> > +		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> > +		gso_size = skb_shinfo(skb)->gso_size;
> > +	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
> > +		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> > +		gso_size = skb_shinfo(skb)->gso_size;
> > +	} else {
> > +		gso_type = 0;
> 
> Ditto.
> 
> > -	if (!vif->gso_prefix)
> > -		meta->gso_size = skb_shinfo(skb)->gso_size;
> > -	else
> > +	if ((1 << gso_type) & vif->gso_mask) {
> > +		meta->gso_type = gso_type;
> > +		meta->gso_size = gso_size;
> > +	} else {
> > +		meta->gso_type = 0;
> 
> Ditto.
> 
> >  		meta->gso_size = 0;
> [...]
> > @@ -573,15 +573,40 @@ static int connect_rings(struct backend_info *be)
> >  		val = 0;
> >  	vif->can_sg = !!val;
> >
> > +	vif->gso_mask = 0;
> > +	vif->gso_prefix_mask = 0;
> > +
> >  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
> >  			 "%d", &val) < 0)
> >  		val = 0;
> > -	vif->gso = !!val;
> > +	if (val)
> > +		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;
> 
> Not using "|=" ?
> 
> >
> >  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-
> prefix",
> >  			 "%d", &val) < 0)
> >  		val = 0;
> > -	vif->gso_prefix = !!val;
> > +	if (val)
> > +		vif->gso_prefix_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV4;
> > +
> > +	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
> > +			 "%d", &val) < 0)
> > +		val = 0;
> > +	if (val)
> > +		vif->gso_mask = 1 << XEN_NETIF_GSO_TYPE_TCPV6;
> > +
> 
> Not using "|="? Are feature-gso_tcpv{4,6} mutually exclusive?
> 
> Same question goes to the setting of gso_prefix_mask.
> 

That's very odd. You're correct and I could have sworn the code did have |= in these places; thanks for catching that.

  Paul
