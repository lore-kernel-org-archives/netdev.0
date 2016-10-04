From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [Xen-devel] [PATCH v2 net-next 2/7] xen-netback: retire guest rx
 side prefix GSO feature
Date: Tue, 4 Oct 2016 08:52:05 -0400
Message-ID: <20161004125205.GE30836@localhost.localdomain>
References: <1475573358-32414-1-git-send-email-paul.durrant@citrix.com>
 <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
        Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>, annie.li@oracle.com,
        joao.m.martins@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:48553 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751549AbcJDMwU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 08:52:20 -0400
Content-Disposition: inline
In-Reply-To: <1475573358-32414-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 04, 2016 at 10:29:13AM +0100, Paul Durrant wrote:
> As far as I am aware only very old Windows network frontends make use of
> this style of passing GSO packets from backend to frontend. These
> frontends can easily be replaced by the freely available Xen Project
> Windows PV network frontend, which uses the 'default' mechanism for
> passing GSO packets, which is also used by all Linux frontends.

It is not that simple. Some companies have extra juice in their Windows
frontends so can't easily swap over to the Xen Project one.

Either way CC-ing Annie

Also would it make sense to CC the FreeBSD and NetBSD maintainers of
their PV drivers just to make sure? (Or has that been confirmed)

> 
> NOTE: Removal of this feature will not cause breakage in old Windows
>       frontends. They simply will no longer receive GSO packets - the
>       packets instead being fragmented in the backend.

Did you also test this with SuSE/Novell Windows PV drivers?

Thanks.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> ---
> Cc: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |  1 -
>  drivers/net/xen-netback/interface.c |  4 ++--
>  drivers/net/xen-netback/rx.c        | 26 --------------------------
>  drivers/net/xen-netback/xenbus.c    | 21 ---------------------
>  4 files changed, 2 insertions(+), 50 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index b38fb2c..0ba5910 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -260,7 +260,6 @@ struct xenvif {
>  
>  	/* Frontend feature information. */
>  	int gso_mask;
> -	int gso_prefix_mask;
>  
>  	u8 can_sg:1;
>  	u8 ip_csum:1;
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index fb50c6d..211d542 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -319,9 +319,9 @@ static netdev_features_t xenvif_fix_features(struct net_device *dev,
>  
>  	if (!vif->can_sg)
>  		features &= ~NETIF_F_SG;
> -	if (~(vif->gso_mask | vif->gso_prefix_mask) & GSO_BIT(TCPV4))
> +	if (~(vif->gso_mask) & GSO_BIT(TCPV4))
>  		features &= ~NETIF_F_TSO;
> -	if (~(vif->gso_mask | vif->gso_prefix_mask) & GSO_BIT(TCPV6))
> +	if (~(vif->gso_mask) & GSO_BIT(TCPV6))
>  		features &= ~NETIF_F_TSO6;
>  	if (!vif->ip_csum)
>  		features &= ~NETIF_F_IP_CSUM;
> diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
> index 03836aa..6bd7d6e 100644
> --- a/drivers/net/xen-netback/rx.c
> +++ b/drivers/net/xen-netback/rx.c
> @@ -347,16 +347,6 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
>  	}
>  
> -	/* Set up a GSO prefix descriptor, if necessary */
> -	if ((1 << gso_type) & vif->gso_prefix_mask) {
> -		RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++, &req);
> -		meta = npo->meta + npo->meta_prod++;
> -		meta->gso_type = gso_type;
> -		meta->gso_size = skb_shinfo(skb)->gso_size;
> -		meta->size = 0;
> -		meta->id = req.id;
> -	}
> -
>  	RING_COPY_REQUEST(&queue->rx, queue->rx.req_cons++, &req);
>  	meta = npo->meta + npo->meta_prod++;
>  
> @@ -511,22 +501,6 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
>  	while ((skb = __skb_dequeue(&rxq)) != NULL) {
>  		struct xen_netif_extra_info *extra = NULL;
>  
> -		if ((1 << queue->meta[npo.meta_cons].gso_type) &
> -		    vif->gso_prefix_mask) {
> -			resp = RING_GET_RESPONSE(&queue->rx,
> -						 queue->rx.rsp_prod_pvt++);
> -
> -			resp->flags = XEN_NETRXF_gso_prefix |
> -				      XEN_NETRXF_more_data;
> -
> -			resp->offset = queue->meta[npo.meta_cons].gso_size;
> -			resp->id = queue->meta[npo.meta_cons].id;
> -			resp->status = XENVIF_RX_CB(skb)->meta_slots_used;
> -
> -			npo.meta_cons++;
> -			XENVIF_RX_CB(skb)->meta_slots_used--;
> -		}
> -
>  		queue->stats.tx_bytes += skb->len;
>  		queue->stats.tx_packets++;
>  
> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
> index daf4c78..7056404 100644
> --- a/drivers/net/xen-netback/xenbus.c
> +++ b/drivers/net/xen-netback/xenbus.c
> @@ -1135,7 +1135,6 @@ static int read_xenbus_vif_flags(struct backend_info *be)
>  	vif->can_sg = !!val;
>  
>  	vif->gso_mask = 0;
> -	vif->gso_prefix_mask = 0;
>  
>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4",
>  			 "%d", &val) < 0)
> @@ -1143,32 +1142,12 @@ static int read_xenbus_vif_flags(struct backend_info *be)
>  	if (val)
>  		vif->gso_mask |= GSO_BIT(TCPV4);
>  
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv4-prefix",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	if (val)
> -		vif->gso_prefix_mask |= GSO_BIT(TCPV4);
> -
>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6",
>  			 "%d", &val) < 0)
>  		val = 0;
>  	if (val)
>  		vif->gso_mask |= GSO_BIT(TCPV6);
>  
> -	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-gso-tcpv6-prefix",
> -			 "%d", &val) < 0)
> -		val = 0;
> -	if (val)
> -		vif->gso_prefix_mask |= GSO_BIT(TCPV6);
> -
> -	if (vif->gso_mask & vif->gso_prefix_mask) {
> -		xenbus_dev_fatal(dev, err,
> -				 "%s: gso and gso prefix flags are not "
> -				 "mutually exclusive",
> -				 dev->otherend);
> -		return -EOPNOTSUPP;
> -	}
> -
>  	if (xenbus_scanf(XBT_NIL, dev->otherend, "feature-no-csum-offload",
>  			 "%d", &val) < 0)
>  		val = 0;
> -- 
> 2.1.4
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> https://lists.xen.org/xen-devel
