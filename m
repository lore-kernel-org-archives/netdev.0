From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v3 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Fri, 11 Oct 2013 11:11:43 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013263A@AMSPEX01CL01.citrite.net>
References: <1381418733-20470-1-git-send-email-paul.durrant@citrix.com>
 <1381418733-20470-6-git-send-email-paul.durrant@citrix.com>
 <20131011100950.GF15556@zion.uk.xensource.com>
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
Received: from smtp02.citrix.com ([66.165.176.63]:52141 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754858Ab3JKLLq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 07:11:46 -0400
In-Reply-To: <20131011100950.GF15556@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 11 October 2013 11:10
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [PATCH net-next v3 5/5] xen-netback: enable IPv6 TCP GSO to
> the guest
> 
> On Thu, Oct 10, 2013 at 04:25:33PM +0100, Paul Durrant wrote:
> [...]
> >  	return max;
> > @@ -312,6 +312,7 @@ static struct xenvif_rx_meta
> *get_next_rx_buffer(struct xenvif *vif,
> >  	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
> >
> >  	meta = npo->meta + npo->meta_prod++;
> > +	meta->gso_type = 0;
> 
> Should use XEN_NETIF_GSO_TYPE_NONE here.
> 
> >  	meta->gso_size = 0;
> >  	meta->size = 0;
> [...]
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
> > +		gso_size = 0;
> > +	}
> > +
> [...]
> > @@ -438,10 +461,13 @@ static int xenvif_gop_skb(struct sk_buff *skb,
> >  	req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
> >  	meta = npo->meta + npo->meta_prod++;
> >
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
> > +	}
> >
> >  	meta->size = 0;
> >  	meta->id = req->id;
> > @@ -587,7 +613,8 @@ void xenvif_rx_action(struct xenvif *vif)
> >
> >  		vif = netdev_priv(skb->dev);
> >
> > -		if (vif->meta[npo.meta_cons].gso_size && vif->gso_prefix) {
> > +		if ((1 << vif->meta[npo.meta_cons].gso_type) &
> > +		    vif->gso_prefix_mask) {
> 
> The logic is changed here. Why do you remove the test on gso_size?
> 
> >  			resp = RING_GET_RESPONSE(&vif->rx,
> >  						 vif->rx.rsp_prod_pvt++);
> >
> > @@ -624,7 +651,8 @@ void xenvif_rx_action(struct xenvif *vif)
> >  					vif->meta[npo.meta_cons].size,
> >  					flags);
> >
> > -		if (vif->meta[npo.meta_cons].gso_size && !vif->gso_prefix)
> {
> > +		if ((1 << vif->meta[npo.meta_cons].gso_type) &
> > +		    vif->gso_mask) {
> 
> Ditto.
> 
> >  			struct xen_netif_extra_info *gso =
> >  				(struct xen_netif_extra_info *)
> >  				RING_GET_RESPONSE(&vif->rx,
> > @@ -632,8 +660,8 @@ void xenvif_rx_action(struct xenvif *vif)
> >
> [...]
> >  	 * was turned on by a zero value in (or lack of)
> > diff --git a/include/xen/interface/io/netif.h
> b/include/xen/interface/io/netif.h
> > index d7dd8d7..41674bc 100644
> > --- a/include/xen/interface/io/netif.h
> > +++ b/include/xen/interface/io/netif.h
> > @@ -113,6 +113,7 @@ struct xen_netif_tx_request {
> >  #define  XEN_NETIF_EXTRA_FLAG_MORE
> 	(1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
> >
> >  /* GSO types */
> > +#define XEN_NETIF_GSO_TYPE_NONE         (0)
> 
> Indentation.
> 

Agreed. I managed to lose a load of changes and this patch was one I had to re-construct; I'll fix.

  Paul
