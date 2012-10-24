From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] ipv6: fix the bug when propagating Redirect Message
Date: Wed, 24 Oct 2012 06:54:10 +0200
Message-ID: <20121024045410.GF27385@secunet.com>
References: <5086B721.1090905@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56893 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750736Ab2JXEyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 00:54:13 -0400
Content-Disposition: inline
In-Reply-To: <5086B721.1090905@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 11:26:25PM +0800, Duan Jiong wrote:
> 
> Before using icmpv6_notify() to propagate redirect, change skb->data
> to poing the IP packet that triggered the sending of the Redirect.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
> ---
>  net/ipv6/ndisc.c |   39 +++++++++++++++++++++++++++++++++++++++
>  1 files changed, 39 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index ff36194..0f73303 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -1334,6 +1334,11 @@ out:
>  
>  static void ndisc_redirect_rcv(struct sk_buff *skb)
>  {
> +	int opt_len;
> +	int opt_offset;
> +	int ndisc_head_len;
> +	struct nd_opt_hdr *nd_opt;
> +	
>  #ifdef CONFIG_IPV6_NDISC_NODETYPE
>  	switch (skb->ndisc_nodetype) {
>  	case NDISC_NODETYPE_HOST:
> @@ -1350,6 +1355,40 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
>  		return;
>  	}
>  
> +	ndisc_head_len = sizeof(struct icmp6hdr) + 2*sizeof(struct in6_addr);
> +	if (!pskb_may_pull(skb, ndisc_head_len)) {
> +		return;
> +	}
> +
> +	nd_opt = (struct nd_opt_hdr *)(skb->data + ndisc_head_len);
> +
> +	opt_len = skb->tail - skb->transport_header - ndisc_head_len;
> +	if (opt_len < 0) {
> +		return;
> +	}
> +	while (opt_len) {
> +		int l;
> +	
> +		if (opt_len < sizeof(struct nd_opt_hdr)) {
> +			return;
> +		}
> +		l = nd_opt->nd_opt_len << 3;
> +		if (opt_len < l || l == 0) {
> +			return;
> +		}
> +		if (nd_opt->nd_opt_type == ND_OPT_REDIRECT_HDR) {
> +			__skb_pull(skb, ndisc_head_len + opt_offset + 8);
> +			break;
> +		}
> +		opt_len -= l;
> +		nd_opt = ((void *)nd_opt) + 1;
> +		opt_offset += 1;
> +	}

Instead of the above loop, you could use ndisc_parse_options().
This does the same what you are doing here and it would make it
a bit clearer what's going on.
