From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Tue, 17 Mar 2009 09:37:24 +0000
Message-ID: <20090317093724.GA5743@ff.dom.local>
References: <20090316132240.GA18413@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, emil.s.tantilov@intel.com,
	alexander.h.duyck@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:51066 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763168AbZCQJhh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 05:37:37 -0400
Received: by wa-out-1112.google.com with SMTP id v33so2059793wah.21
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2009 02:37:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090316132240.GA18413@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-2009 14:22, Herbert Xu wrote:
...
> GRO: Move netpoll checks to correct location
...
> +static inline int netpoll_rx_on(struct sk_buff *skb)
> +{
> +	struct netpoll_info *npinfo = skb->dev->npinfo;
> +
> +	return npinfo && (npinfo->rx_np || npinfo->rx_flags);
> +}
> +
>  static inline int netpoll_receive_skb(struct sk_buff *skb)
>  {
>  	if (!list_empty(&skb->dev->napi_list))
> @@ -99,6 +106,10 @@ static inline int netpoll_rx(struct sk_buff *skb)
>  {
>  	return 0;
>  }
> +static inline int netpoll_rx_on(struct sk_buff *skb)
> +{
> +	return 0;
> +}
>  static inline int netpoll_receive_skb(struct sk_buff *skb)
>  {
>  	return 0;
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 2d6e405..6227248 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -79,6 +79,9 @@ static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
>  {
>  	struct sk_buff *p;
>  
> +	if (netpoll_rx_on(skb))
> +		return GRO_NORMAL;
> +

Probably I miss something, but you seem to assume here this skb will
be taken by netpoll later. But if it's not active (trapped) vlan
packet will be passed as "normal"?

Thanks,
Jarek P.
