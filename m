From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 4/5] xen-netback: handle IPv6 TCP GSO
 packets from the guest
Date: Wed, 16 Oct 2013 17:16:58 +0100
Message-ID: <1381940218.30409.6.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-5-git-send-email-paul.durrant@citrix.com>
	 <1381940113.30409.5.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:34531 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab3JPQRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:17:01 -0400
In-Reply-To: <1381940113.30409.5.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-16 at 17:15 +0100, Ian Campbell wrote:
> On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> > This patch adds a xenstore feature flag, festure-gso-tcpv6, to advertise
> > that netback can handle IPv6 TCP GSO packets. It creates SKB_GSO_TCPV6 skbs
> > if the frontend passes an extra segment with the new type
> > XEN_NETIF_GSO_TYPE_TCPV6 added to netif.h.
> > 
> > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> 
> This patch looks fine but should it not be after the following patch
> which actually causes the necessary pull ups to happen?

Sorry, it is, I shouldn't review series in two halves, forget what I've
already seen!

> > Cc: Wei Liu <wei.liu2@citrix.com>
> > Cc: David Vrabel <david.vrabel@citrix.com>

Acked-by: Ian Campbell <ian.campbell@citrix.com>

> > ---
> >  drivers/net/xen-netback/netback.c |   11 ++++++++---
> >  drivers/net/xen-netback/xenbus.c  |    7 +++++++
> >  include/xen/interface/io/netif.h  |   10 +++++++++-
> >  3 files changed, 24 insertions(+), 4 deletions(-)
> > 
> > diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> > index 74c13b9..65f04e7 100644
> > --- a/drivers/net/xen-netback/netback.c
> > +++ b/drivers/net/xen-netback/netback.c
> > @@ -1096,15 +1096,20 @@ static int xenvif_set_skb_gso(struct xenvif *vif,
> >  		return -EINVAL;
> >  	}
> >  
> > -	/* Currently only TCPv4 S.O. is supported. */
> > -	if (gso->u.gso.type != XEN_NETIF_GSO_TYPE_TCPV4) {
> > +	switch (gso->u.gso.type) {
> > +	case XEN_NETIF_GSO_TYPE_TCPV4:
> > +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> > +		break;
> > +	case XEN_NETIF_GSO_TYPE_TCPV6:
> > +		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
> > +		break;
> > +	default:
> >  		netdev_err(vif->dev, "Bad GSO type %d.\n", gso->u.gso.type);
> >  		xenvif_fatal_tx_err(vif);
> >  		return -EINVAL;
> >  	}
> >  
> >  	skb_shinfo(skb)->gso_size = gso->u.gso.size;
> > -	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> >  
> >  	/* Header must be checked, and gso_segs computed. */
> >  	skb_shinfo(skb)->gso_type |= SKB_GSO_DODGY;
> > diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> > index 9c9b37d..7e4dcc9 100644
> > --- a/drivers/net/xen-netback/xenbus.c
> > +++ b/drivers/net/xen-netback/xenbus.c
> > @@ -105,6 +105,13 @@ static int netback_probe(struct xenbus_device *dev,
> >  			goto abort_transaction;
> >  		}
> >  
> > +		err = xenbus_printf(xbt, dev->nodename, "feature-gso-tcpv6",
> > +				    "%d", sg);
> > +		if (err) {
> > +			message = "writing feature-gso-tcpv6";
> > +			goto abort_transaction;
> > +		}
> > +
> >  		/* We support partial checksum setup for IPv6 packets */
> >  		err = xenbus_printf(xbt, dev->nodename,
> >  				    "feature-ipv6-csum-offload",
> > diff --git a/include/xen/interface/io/netif.h b/include/xen/interface/io/netif.h
> > index d9fb44739..d7dd8d7 100644
> > --- a/include/xen/interface/io/netif.h
> > +++ b/include/xen/interface/io/netif.h
> > @@ -61,6 +61,13 @@
> >   */
> >  
> >  /*
> > + * "feature-gso-tcpv4" and "feature-gso-tcpv6" advertise the capability to
> > + * handle large TCP packets (in IPv4 or IPv6 form respectively). Neither
> > + * frontends nor backends are assumed to be capable unless the flags are
> > + * present.
> > + */
> > +
> > +/*
> >   * This is the 'wire' format for packets:
> >   *  Request 1: xen_netif_tx_request  -- XEN_NETTXF_* (any flags)
> >   * [Request 2: xen_netif_extra_info]    (only if request 1 has XEN_NETTXF_extra_info)
> > @@ -105,8 +112,9 @@ struct xen_netif_tx_request {
> >  #define _XEN_NETIF_EXTRA_FLAG_MORE	(0)
> >  #define  XEN_NETIF_EXTRA_FLAG_MORE	(1U<<_XEN_NETIF_EXTRA_FLAG_MORE)
> >  
> > -/* GSO types - only TCPv4 currently supported. */
> > +/* GSO types */
> >  #define XEN_NETIF_GSO_TYPE_TCPV4	(1)
> > +#define XEN_NETIF_GSO_TYPE_TCPV6	(2)
> >  
> >  /*
> >   * This structure needs to fit within both netif_tx_request and
> 
