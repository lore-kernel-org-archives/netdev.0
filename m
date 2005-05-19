From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4/IPV6] Keep wmem accounting separate in ip*_push_pending_frames
Date: Fri, 20 May 2005 07:48:38 +1000
Message-ID: <20050519214838.GD24024@gondor.apana.org.au>
References: <20050515235913.GA20242@gondor.apana.org.au> <20050515.173944.122590923.davem@davemloft.net> <20050516010058.GA20704@gondor.apana.org.au> <20050519.123530.55508893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050519.123530.55508893.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 12:35:30PM -0700, David S. Miller wrote:
> 
> Ok, based upon this I am adding the following patch to my
> tree.  Thanks.

Thanks Dave, this looks good to me.

> --- 1/net/ipv4/netfilter/ip_conntrack_core.c.~1~	2005-05-18 22:45:26.000000000 -0700
> +++ 2/net/ipv4/netfilter/ip_conntrack_core.c	2005-05-19 12:32:26.000000000 -0700
> @@ -940,37 +940,25 @@
>  struct sk_buff *
>  ip_ct_gather_frags(struct sk_buff *skb, u_int32_t user)
>  {
> -	struct sock *sk = skb->sk;
>  #ifdef CONFIG_NETFILTER_DEBUG
>  	unsigned int olddebug = skb->nf_debug;
>  #endif
>  
> -	if (sk) {
> -		sock_hold(sk);
> -		skb_orphan(skb);
> -	}
> +	skb_orphan(skb);
>  
>  	local_bh_disable(); 
>  	skb = ip_defrag(skb, user);
>  	local_bh_enable();
>  
> -	if (!skb) {
> -		if (sk)
> -			sock_put(sk);
> -		return skb;
> -	}
> -
> -	if (sk) {
> -		skb_set_owner_w(skb, sk);
> -		sock_put(sk);
> -	}
> -
> -	ip_send_check(skb->nh.iph);
> -	skb->nfcache |= NFC_ALTERED;
> +	if (skb) {
> +		ip_send_check(skb->nh.iph);
> +		skb->nfcache |= NFC_ALTERED;
>  #ifdef CONFIG_NETFILTER_DEBUG
> -	/* Packet path as if nothing had happened. */
> -	skb->nf_debug = olddebug;
> +		/* Packet path as if nothing had happened. */
> +		skb->nf_debug = olddebug;
>  #endif
> +	}
> +
>  	return skb;
>  }
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
