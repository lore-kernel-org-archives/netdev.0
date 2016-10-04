From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest rx
 side prefix GSO feature
Date: Tue, 4 Oct 2016 10:24:04 -0400
Message-ID: <20161004142404.GC18821@char.us.oracle.com>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
 <20161004125205.GE30836@localhost.localdomain>
 <6af51a0a84cf41d5a31168b3e8626fcd@AMSPEX02CL03.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "annie.li@oracle.com" <annie.li@oracle.com>,
        "joao.m.martins@oracle.com" <joao.m.martins@oracle.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
        Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>, bouyer@NetBSD.org,
        roger.pau@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49224 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751125AbcJDOYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 10:24:17 -0400
Content-Disposition: inline
In-Reply-To: <6af51a0a84cf41d5a31168b3e8626fcd@AMSPEX02CL03.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 01:35:41PM +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: Konrad Rzeszutek Wilk [mailto:konrad.wilk@oracle.com]
> > Sent: 04 October 2016 13:52
> > To: Paul Durrant <Paul.Durrant@citrix.com>; annie.li@oracle.com;
> > joao.m.martins@oracle.com
> > Cc: netdev@vger.kernel.org; xen-devel@lists.xenproject.org; Wei Liu
> > <wei.liu2@citrix.com>
> > Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest
> > rx side prefix GSO feature
> > 
> > On Tue, Oct 04, 2016 at 10:29:13AM +0100, Paul Durrant wrote:
> > > As far as I am aware only very old Windows network frontends make use
> > > of this style of passing GSO packets from backend to frontend. These
> > > frontends can easily be replaced by the freely available Xen Project
> > > Windows PV network frontend, which uses the 'default' mechanism for
> > > passing GSO packets, which is also used by all Linux frontends.
> > 
> > It is not that simple. Some companies have extra juice in their Windows
> > frontends so can't easily swap over to the Xen Project one.
> 
> Ok, then those frontends will continue to work, but they won't get GSO packets any more. Prefix GSO has never been specified in the canonical netif header and so has been in a limbo state forever so such frontends have always been on borrowed time and only just happened to work against a linux backend. If someone wants to actually specify prefix GSO properly then it could be added back in, but it should not be necessary now that the RX side req<->rsp identity relation is documented (http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/include/public/io/netif.h;hb=HEAD#l729).
> 
> > 
> > Either way CC-ing Annie
> > 
> > Also would it make sense to CC the FreeBSD and NetBSD maintainers of their
> > PV drivers just to make sure? (Or has that been confirmed)
> > 
> 
> I could do that, but I'd hope that they would be subscribed to xen-devel and will chime in if there's likely to be a problem.

Usually one CCs those folks. I think you are asking me to do
the legwork and find them and CC them here?

CC-ing Roger and  Manuel Bouyer.

> 
> > >
> > > NOTE: Removal of this feature will not cause breakage in old Windows
> > >       frontends. They simply will no longer receive GSO packets - the
> > >       packets instead being fragmented in the backend.
> > 
> > Did you also test this with SuSE/Novell Windows PV drivers?
> > 
> 
> No, I don't have copies of these. Internal XenServer testing has not shown up any issues with 'legacy' PV drivers though (which do still have the prefix GSO code in).

You can download these drivers and install on your guests.
> 
>   Paul
> 
> > Thanks.
> > >
> > > Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> > > ---
> > > Cc: Wei Liu <wei.liu2@citrix.com>
> > > ---
> > >  drivers/net/xen-netback/common.h    |  1 -
> > >  drivers/net/xen-netback/interface.c |  4 ++--
> > >  drivers/net/xen-netback/rx.c        | 26 --------------------------
> > >  drivers/net/xen-netback/xenbus.c    | 21 ---------------------
> > >  4 files changed, 2 insertions(+), 50 deletions(-)
> > >
> > > diff --git a/drivers/net/xen-netback/common.h
> > > b/drivers/net/xen-netback/common.h
> > > index b38fb2c..0ba5910 100644
> > > --- a/drivers/net/xen-netback/common.h
> > > +++ b/drivers/net/xen-netback/common.h
> > > @@ -260,7 +260,6 @@ struct xenvif {
> > >
> > >  	/* Frontend feature information. */
> > >  	int gso_mask;
> > > -	int gso_prefix_mask;
> > >
> > >  	u8 can_sg:1;
> > >  	u8 ip_csum:1;
> > > diff --git a/drivers/net/xen-netback/interface.c
> > > b/drivers/net/xen-netback/interface.c
> > > index fb50c6d..211d542 100644
> > > --- a/drivers/net/xen-netback/interface.c
> > > +++ b/drivers/net/xen-netback/interface.c
> > > @@ -319,9 +319,9 @@ static netdev_features_t
> > > xenvif_fix_features(struct net_device *dev,
> > >
> > >  	if (!vif->can_sg)
> > >  		features &= ~NETIF_F_SG;
> > > -	if (~(vif->gso_mask | vif->gso_prefix_mask) & GSO_BIT(TCPV4))
> > > +	if (~(vif->gso_mask) & GSO_BIT(TCPV4))
> > >  		features &= ~NETIF_F_TSO;
> > > -	if (~(vif->gso_mask | vif->gso_prefix_mask) & GSO_BIT(TCPV6))
> > > +	if (~(vif->gso_mask) & GSO_BIT(TCPV6))
> > >  		features &= ~NETIF_F_TSO6;
> > >  	if (!vif->ip_csum)
> > >  		features &= ~NETIF_F_IP_CSUM;
> > > diff --git a/drivers/net/xen-netback/rx.c
> > > b/drivers/net/xen-netback/rx.c index 03836aa..6bd7d6e 100644
> > > --- a/drivers/net/xen-netback/rx.c
> > > +++ b/drivers/net/xen-netback/rx.c
> > > @@ -347,16 +347,6 @@ static int xenvif_gop_skb(struct sk_buff *skb,
> > >  			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> > >  	}
> > >
> > > -	/* Set up a GSO prefix descriptor, if necessary */
> > > -	if ((1 << gso_type) & vif->gso_prefix_mask) {
> > > -		RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++,
> > &req);
> > > -		meta = npo->meta + npo->meta_prod++;
> > > -		meta->gso_type = gso_type;
> > > -		meta->gso_size = skb_shinfo(skb)->gso_size;
> > > -		meta->size = 0;
> > > -		meta->id = req.id;
> > > -	}
> > > -
> > >  	RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++, &req);
> > >  	meta = npo->meta + npo->meta_prod++;
> > >
> > > @@ -511,22 +501,6 @@ static void xenvif_rx_action(struct xenvif_queue
> > *queue)
> > >  	while ((skb = __skb_dequeue(&rxq)) != NULL) {
> > >  		struct xen_netif_extra_info *extra = NULL;
> > >
> > > -		if ((1 << queue->meta[npo.meta_cons].gso_type) &
> > > -		    vif->gso_prefix_mask) {
> > > -			resp = RING_GET_RESPONSE(&queue->rx,
> > > -						 queue->rx.rsp_prod_pvt++);
> > > -
> > > -			resp->flags = XEN_NETRXF_gso_prefix |
> > > -				      XEN_NETRXF_more_data;
> > > -
> > > -			resp->offset = queue-
> > >meta[npo.meta_cons].gso_size;
> > > -			resp->id = queue->meta[npo.meta_cons].id;
> > > -			resp->status = XENVIF_RX_CB(skb)-
> > >meta_slots_used;
> > > -
> > > -			npo.meta_cons++;
> > > -			XENVIF_RX_CB(skb)->meta_slots_used--;
> > > -		}
> > > -
> > >  		queue->stats.tx_bytes += skb->len;
> > >  		queue->stats.tx_packets++;
> > >
> > > diff --git a/drivers/net/xen-netback/xenbus.c
> > > b/drivers/net/xen-netback/xenbus.c
> > > index daf4c78..7056404 100644
> > > --- a/drivers/net/xen-netback/xenbus.c
> > > +++ b/drivers/net/xen-netback/xenbus.c
> > > @@ -1135,7 +1135,6 @@ static int read_xenbus_vif_flags(struct
> > backend_info *be)
> > >  	vif->can_sg = !!val;
> > >
> > >  	vif->gso_mask = 0;
> > > -	vif->gso_prefix_mask = 0;
> > >
> > >  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
> > >  			 "%d", &val) < 0)
> > > @@ -1143,32 +1142,12 @@ static int read_xenbus_vif_flags(struct
> > backend_info *be)
> > >  	if (val)
> > >  		vif->gso_mask |= GSO_BIT(TCPV4);
> > >
> > > -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-
> > prefix",
> > > -			 "%d", &val) < 0)
> > > -		val = 0;
> > > -	if (val)
> > > -		vif->gso_prefix_mask |= GSO_BIT(TCPV4);
> > > -
> > >  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
> > >  			 "%d", &val) < 0)
> > >  		val = 0;
> > >  	if (val)
> > >  		vif->gso_mask |= GSO_BIT(TCPV6);
> > >
> > > -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6-
> > prefix",
> > > -			 "%d", &val) < 0)
> > > -		val = 0;
> > > -	if (val)
> > > -		vif->gso_prefix_mask |= GSO_BIT(TCPV6);
> > > -
> > > -	if (vif->gso_mask & vif->gso_prefix_mask) {
> > > -		xenbus_dev_fatal(dev, err,
> > > -				 "%s: gso and gso prefix flags are not "
> > > -				 "mutually exclusive",
> > > -				 dev->otherend);
> > > -		return -EOPNOTSUPP;
> > > -	}
> > > -
> > >  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-
> > offload",
> > >  			 "%d", &val) < 0)
> > >  		val = 0;
> > > --
> > > 2.1.4
> > >
> > >
> > > _______________________________________________
> > > Xen-devel mailing list
> > > Xen-devel@lists.xen.org
> > > https://lists.xen.org/xen-devel
