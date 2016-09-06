From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] vti: use right inner_mode for inbound inter address
 family policy checks
Date: Tue, 6 Sep 2016 13:15:23 +0200
Message-ID: <20160906111522.GG31137@gauss.secunet.com>
References: <20160904105713.3mqgszgqi7waxk5l@toau>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58757 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933713AbcIFLP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Sep 2016 07:15:28 -0400
Content-Disposition: inline
In-Reply-To: <20160904105713.3mqgszgqi7waxk5l@toau>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Sep 04, 2016 at 12:57:13PM +0200, Thomas Zeitlhofer wrote:
> In case of inter address family tunneling (IPv6 over vti4 or IPv4 over
> vti6), the inbound policy checks in vti_rcv_cb and vti6_rcv_cb are using
> the wrong address family. As a result, all inbound inter address family
> traffic is dropped.
> 
> Use the xfrm_ip2inner_mode helper (as done in xfrm_prepare_input and
> xfrm_input) to select the inner_mode that contains the right address family
> for the inbound policy checks.
> 
> Signed-off-by: Thomas Zeitlhofer <thomas.zeitlhofer+lkml@ze-it.at>
> ---
> 
> Notes:
>     The patch was developed by looking at the code, but without knowledge of
>     the XFRM code in the kernel. It has been successfully tested, but it is
>     more a guess that might be helpful for the maintainers to find a proper
>     solution.
> 
>  net/ipv4/ip_vti.c  | 12 +++++++++++-
>  net/ipv6/ip6_vti.c | 12 +++++++++++-
>  2 files changed, 22 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
> index a917903..44d5449 100644
> --- a/net/ipv4/ip_vti.c
> +++ b/net/ipv4/ip_vti.c
> @@ -88,6 +88,7 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
>  	struct net_device *dev;
>  	struct pcpu_sw_netstats *tstats;
>  	struct xfrm_state *x;
> +	struct xfrm_mode *inner_mode;
>  	struct ip_tunnel *tunnel = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4;
>  	u32 orig_mark = skb->mark;
>  	int ret;
> @@ -105,7 +106,16 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
>  	}
>  
>  	x = xfrm_input_state(skb);
> -	family = x->inner_mode->afinfo->family;
> +
> +	inner_mode = x->inner_mode;
> +
> +	if (x->sel.family == AF_UNSPEC) {
> +		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> +		if (inner_mode == NULL)
> +			return -EPERM;

You better return -EINVAL instead of -EPERM here.
Also you should bump the LINUX_MIB_XFRMINSTATEMODEERROR
counter as we do in xfrm_input.

> +	}
> +
> +	family = inner_mode->afinfo->family;
>  
>  	skb->mark = be32_to_cpu(tunnel->parms.i_key);
>  	ret = xfrm_policy_check(NULL, XFRM_POLICY_IN, skb, family);
> diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
> index d90a11f..3149757 100644
> --- a/net/ipv6/ip6_vti.c
> +++ b/net/ipv6/ip6_vti.c
> @@ -340,6 +340,7 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
>  	struct net_device *dev;
>  	struct pcpu_sw_netstats *tstats;
>  	struct xfrm_state *x;
> +	struct xfrm_mode *inner_mode;
>  	struct ip6_tnl *t = XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6;
>  	u32 orig_mark = skb->mark;
>  	int ret;
> @@ -357,7 +358,16 @@ static int vti6_rcv_cb(struct sk_buff *skb, int err)
>  	}
>  
>  	x = xfrm_input_state(skb);
> -	family = x->inner_mode->afinfo->family;
> +
> +	inner_mode = x->inner_mode;
> +
> +	if (x->sel.family == AF_UNSPEC) {
> +		inner_mode = xfrm_ip2inner_mode(x, XFRM_MODE_SKB_CB(skb)->protocol);
> +		if (inner_mode == NULL)
> +			return -EPERM;

Same here.

Other that that it looks ok to me.
