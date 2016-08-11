From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH net-next 2/3] net: mpls fixes for GSO
Date: Thu, 11 Aug 2016 09:47:36 +0200
Message-ID: <20160811074735.GA32385@penelope.isobedori.kobe.vergenet.net>
References: <1470897812-8213-1-git-send-email-roopa@cumulusnetworks.com>
 <1470897812-8213-3-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dsa@cumulusnetworks.com, buytenh@wantstofly.org,
	ebiederm@xmission.com, rshearma@brocade.com, tom@herbertland.com,
	tgraf@suug.ch, olivier.dugeon@orange.com
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35272 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866AbcHKHrl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 03:47:41 -0400
Received: by mail-wm0-f52.google.com with SMTP id f65so13584312wmi.0
        for <netdev@vger.kernel.org>; Thu, 11 Aug 2016 00:47:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1470897812-8213-3-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 10, 2016 at 11:43:31PM -0700, Roopa Prabhu wrote:
> From: David Ahern <dsa@cumulusnetworks.com>
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> Reported-by: Lennert Buytenhek <buytenh@wantstofly.org>

Thanks. This looks like it should be correct to me.  However, I would
appreciate it if you could give me a little time to test it against OvS.

I think the changelog could also do with a few more words given the
complexity (at least to me) of getting this right for all consumers.

> ---
>  net/mpls/mpls_gso.c      | 24 ++++++++++++++++--------
>  net/mpls/mpls_iptunnel.c |  7 +++++++
>  2 files changed, 23 insertions(+), 8 deletions(-)
> 
> diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
> index 2055e57..8829ee0 100644
> --- a/net/mpls/mpls_gso.c
> +++ b/net/mpls/mpls_gso.c
> @@ -22,26 +22,28 @@
>  static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>  				       netdev_features_t features)
>  {
> +	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
>  	struct sk_buff *segs = ERR_PTR(-EINVAL);
> +	u16 mac_offset = skb->mac_header;
>  	netdev_features_t mpls_features;
>  	__be16 mpls_protocol;
> +	u16 mac_len = skb->mac_len;
>  
>  	/* Setup inner SKB. */
>  	mpls_protocol = skb->protocol;
>  	skb->protocol = skb->inner_protocol;
>  
> -	/* Push back the mac header that skb_mac_gso_segment() has pulled.
> -	 * It will be re-pulled by the call to skb_mac_gso_segment() below
> -	 */
> -	__skb_push(skb, skb->mac_len);
> +	__skb_pull(skb, tnl_hlen);
> +	skb->mac_len = skb_inner_network_offset(skb);
>  
>  	/* Segment inner packet. */
>  	mpls_features = skb->dev->mpls_features & features;
>  	segs = skb_mac_gso_segment(skb, mpls_features);
> -
> -
> -	/* Restore outer protocol. */
> -	skb->protocol = mpls_protocol;
> +	if (IS_ERR_OR_NULL(segs)) {
> +		skb_gso_error_unwind(skb, mpls_protocol, tnl_hlen, mac_offset,
> +				     mac_len);
> +		goto out;
> +	}
>  
>  	/* Re-pull the mac header that the call to skb_mac_gso_segment()
>  	 * above pulled.  It will be re-pushed after returning
> @@ -49,6 +51,12 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
>  	 */
>  	__skb_pull(skb, skb->data - skb_mac_header(skb));
>  
> +	/* Restore outer protocol. */
> +	skb->protocol = mpls_protocol;
> +	for (skb = segs; skb; skb = skb->next)
> +		skb->protocol = mpls_protocol;
> +
> +out:
>  	return segs;
>  }
>  
> diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
> index aed872c..87e035a 100644
> --- a/net/mpls/mpls_iptunnel.c
> +++ b/net/mpls/mpls_iptunnel.c
> @@ -90,8 +90,15 @@ static int mpls_xmit(struct sk_buff *skb)
>  	if (skb_cow(skb, hh_len + new_header_size))
>  		goto drop;
>  
> +	skb_reset_mac_header(skb);
> +	skb_reset_inner_headers(skb);
> +	skb->encapsulation = 1;
> +
>  	skb_push(skb, new_header_size);
> +
>  	skb_reset_network_header(skb);
> +	skb_reset_transport_header(skb);
> +	skb_set_inner_protocol(skb, skb->protocol);
>  
>  	skb->dev = out_dev;
>  	skb->protocol = htons(ETH_P_MPLS_UC);
> -- 
> 1.9.1
> 
