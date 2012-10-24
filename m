From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH]ipv6: Add an ICMP error handler icmpv6_err
Date: Wed, 24 Oct 2012 07:01:56 +0200
Message-ID: <20121024050156.GG27385@secunet.com>
References: <5086B6AD.8060306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Duan Jiong <djduanjiong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56928 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401Ab2JXFB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 01:01:59 -0400
Content-Disposition: inline
In-Reply-To: <5086B6AD.8060306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 23, 2012 at 11:24:29PM +0800, Duan Jiong wrote:
> 
> Add an ICMP error handler icmpv6_err to deal with ICMPV6 Error
> Messages and Redirect Message, when we do not have a socket
> context.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>
> ---
>  net/ipv6/icmp.c | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)
> 
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 24d69db..d3cb61d 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -82,9 +82,12 @@ static inline struct sock *icmpv6_sk(struct net *net)
>  }
>  
>  static int icmpv6_rcv(struct sk_buff *skb);
> +static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> +			u8 type, u8 code, int offset, __be32 info);
>  
>  static const struct inet6_protocol icmpv6_protocol = {
>  	.handler	=	icmpv6_rcv,
> +	.err_handler	=	icmpv6_err,
>  	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
>  };
>  
> @@ -782,6 +785,26 @@ drop_no_count:
>  	return 0;
>  }
>  
> +static void icmpv6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> +			u8 type, u8 code, int offset, __be32 info)
> +{
> +	struct net *net = dev_net(skb->dev);
> +	struct icmp6hdr *hdr = icmp6_hdr(skb);
> +
> +	switch (hdr->icmp6_type) {
> +	case ICMPV6_PKT_TOOBIG:
> +		ip6_update_pmtu(skb, net, info, 0, 0);
> +		break;
> +
> +	case NDISC_REDIRECT:
> +		ip6_redirect(skb, net, 0, 0);
> +		break;
> +
> +	default:
> +		break;
> +	}
> +}
> +

Not sure if it really matters, but the ip6_update_pmtu/ip6_redirect
function would be called twice if we have (raw) socket context. Maybe
it's better to do this in raw6_icmp_error() if we have no socket context.
 
