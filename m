From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH net-next v4 5/5] xen-netback: enable IPv6 TCP GSO to the
 guest
Date: Wed, 16 Oct 2013 17:49:16 +0100
Message-ID: <1381942156.30409.19.camel@kazak.uk.xensource.com>
References: <1381503982-1418-1-git-send-email-paul.durrant@citrix.com>
	 <1381503982-1418-6-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:14544 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759389Ab3JPQtT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 12:49:19 -0400
In-Reply-To: <1381503982-1418-6-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-10-11 at 16:06 +0100, Paul Durrant wrote:
> This patch adds code to handle SKB_GSO_TCPV6 skbs and construct appropriate
> extra or prefix segments to pass the large packet to the frontend. New
> xenstore flags, feature-gso-tcpv6 and feature-gso-tcpv6-prefix, are sampled
> to determine if the frontend is capable of handling such packets.

IIRC the reason we have feature-gso-tcpv4 and feature-gso-tcpv4-prefix
is that the former did things in a way which Windows couldn't cope with.
I assuming that is true for v6 too. But could Linux cope with the prefix
version too for v6 and reduce the number of options? Or is the
non-prefix variant actually better, if the guest can manage, for some
reason?

I suppose in the end its all piggybacking off the v4 code paths so
supporting both isn't a hardship.


> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |    9 +++++--
>  drivers/net/xen-netback/interface.c |    6 +++--
>  drivers/net/xen-netback/netback.c   |   48 +++++++++++++++++++++++++++--------
>  drivers/net/xen-netback/xenbus.c    |   29 +++++++++++++++++++--
>  include/xen/interface/io/netif.h    |    1 +
>  5 files changed, 77 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index b4a9a3c..55b8dec 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -87,9 +87,13 @@ struct pending_tx_info {
>  struct xenvif_rx_meta {
>  	int id;
>  	int size;
> +	int gso_type;
>  	int gso_size;
>  };
>  
> +#define GSO_BIT(type) \
> +	(1 << XEN_NETIF_GSO_TYPE_ ## type)
> +
>  /* Discriminate from any valid pending_idx value. */
>  #define INVALID_PENDING_IDX 0xFFFF
>  
> @@ -150,9 +154,10 @@ struct xenvif {
>  	u8               fe_dev_addr[6];
>  
>  	/* Frontend feature information. */
> +	int gso_mask;
> +	int gso_prefix_mask;

Are these storing NETIF_F_FOO? In which case they should be
netif_feature_t I think. At the least it needs to be unsigned.

> +
>  	u8 can_sg:1;
> -	u8 gso:1;
> -	u8 gso_prefix:1;
>  	u8 ip_csum:1;
>  	u8 ipv6_csum:1;
>  
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index cb0d8ea..e4aa267 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -214,8 +214,10 @@ static netdev_features_t xenvif_fix_features(struct net_device *dev,
>  
>  	if (!vif->can_sg)
>  		features &= ~NETIF_F_SG;
> -	if (!vif->gso && !vif->gso_prefix)
> +	if (~(vif->gso_mask | vif->gso_prefix_mask) & GSO_BIT(TCPV4))

I must be blind -- where does this GSO_BIT macro come from?

I can't see it in current net-next...

> @@ -392,7 +394,14 @@ static void xenvif_gop_frag_copy(struct xenvif *vif, struct sk_buff *skb,
>  		}
>  
>  		/* Leave a gap for the GSO descriptor. */
> -		if (*head && skb_shinfo(skb)->gso_size && !vif->gso_prefix)
> +		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +		else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6)

I think you can use skb_is_gso(skb) and skb_is_gso_v6(skb) for these
ifs.

> +			gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +		else
> +			gso_type = XEN_NETIF_GSO_TYPE_NONE;
> +
> +		if (*head && ((1 << gso_type) & vif->gso_mask))

Perhaps test_bit(gso_type, &vif->gso_mask) rather than opencoding
bitops?

I see there are a lot of these, a vif_can_gso_type(vif, gso_type) helper
might be nice.

>  			vif->rx.req_cons++;
>  
>  		*head = 0; /* There must be something in this buffer now. */
> @@ -423,14 +432,28 @@ static int xenvif_gop_skb(struct sk_buff *skb,
>  	unsigned char *data;
>  	int head = 1;
>  	int old_meta_prod;
> +	int gso_type;
> +	int gso_size;
>  
>  	old_meta_prod = npo->meta_prod;
>  
> +	if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
> +		gso_type = XEN_NETIF_GSO_TYPE_TCPV4;
> +		gso_size = skb_shinfo(skb)->gso_size;
> +	} else if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
> +		gso_type = XEN_NETIF_GSO_TYPE_TCPV6;
> +		gso_size = skb_shinfo(skb)->gso_size;
> +	} else {
> +		gso_type = XEN_NETIF_GSO_TYPE_NONE;
> +		gso_size = 0;
> +	}
> +
>  	/* Set up a GSO prefix descriptor, if necessary */
> -	if (skb_shinfo(skb)->gso_size && vif->gso_prefix) {
> +	if ((1 << skb_shinfo(skb)->gso_type) & vif->gso_prefix_mask) {

Isn't skb->gso_type a Linux GSO flag thing and vif->gso_prefix_mask a
Xen netif.h GSO type? Are they really comparable in this way?

>  		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
>  		meta = npo->meta + npo->meta_prod++;
> -		meta->gso_size = skb_shinfo(skb)->gso_size;
> +		meta->gso_type = gso_type;
> +		meta->gso_size = gso_size;
>  		meta->size = 0;
>  		meta->id = req->id;
>  	}

> +	if (vif->gso_mask & vif->gso_prefix_mask) {
> +		xenbus_dev_fatal(dev, err,
> +				 "%s: gso and gso prefix flags are not "
> +				 "mutually exclusive",

Aren't they? I thought they were? Maybe I'm reading this error message
backwards, in which case I would contend that it is written
backwards ;-)

Ian.
