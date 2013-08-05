From: Benjamin Poirier <bpoirier@suse.de>
Subject: Re: [PATCH net] net: esp{4,6}: fix potential MTU calculation
 overflows
Date: Mon, 5 Aug 2013 10:38:33 -0400
Message-ID: <20130805143833.GA27692@d2.synalogic.ca>
References: <1375699775-13769-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Steffen Klassert <steffen.klassert@secunet.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:57215 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752972Ab3HEOil (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 10:38:41 -0400
Content-Disposition: inline
In-Reply-To: <1375699775-13769-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/08/05 12:49, Daniel Borkmann wrote:
> Commit 91657eafb ("xfrm: take net hdr len into account for esp payload
> size calculation") introduced a possible interger overflow in
> esp{4,6}_get_mtu() handlers in case of x->props.mode equals
> XFRM_MODE_TUNNEL. Thus, the following expression will overflow
> 
>   unsigned int net_adj;
>   ...
>   <case ipv{4,6} XFRM_MODE_TUNNEL>
>          net_adj = 0;
>   ...
>   return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
>            net_adj) & ~(align - 1)) + (net_adj - 2);
> 
> where (net_adj - 2) would be evaluated as <foo> + (0 - 2) in an unsigned
> context. Fix it by simply removing brackets as those operations here

I can see this creating problems if there was comparison or type
promotion, but I don't see an integer overflow.

In any case, it is right to remove the parentheses. They are dubious
style at the expense of correctness. They have no effect in this case.

Acked-by: Benjamin Poirier <bpoirier@suse.de>

> do not need to have special precedence.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Benjamin Poirier <bpoirier@suse.de>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> ---
>  Note: only compile tested, maybe Benjamin can comment on why he added
>        brackets around this expression. *If* this is valid (which I do
>        not think), then this needs at least a big comment explaining so.
> 
>  net/ipv4/esp4.c | 2 +-
>  net/ipv6/esp6.c | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
> index ab3d814..109ee89 100644
> --- a/net/ipv4/esp4.c
> +++ b/net/ipv4/esp4.c
> @@ -477,7 +477,7 @@ static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
>  	}
>  
>  	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
> -		 net_adj) & ~(align - 1)) + (net_adj - 2);
> +		 net_adj) & ~(align - 1)) + net_adj - 2;
>  }
>  
>  static void esp4_err(struct sk_buff *skb, u32 info)
> diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
> index 40ffd72..aeac0dc 100644
> --- a/net/ipv6/esp6.c
> +++ b/net/ipv6/esp6.c
> @@ -425,7 +425,7 @@ static u32 esp6_get_mtu(struct xfrm_state *x, int mtu)
>  		net_adj = 0;
>  
>  	return ((mtu - x->props.header_len - crypto_aead_authsize(esp->aead) -
> -		 net_adj) & ~(align - 1)) + (net_adj - 2);
> +		 net_adj) & ~(align - 1)) + net_adj - 2;
>  }
>  
>  static void esp6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
> -- 
> 1.7.11.7
> 
