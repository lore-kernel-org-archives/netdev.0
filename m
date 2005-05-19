From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netlink: defer socket destruction a bit
Date: Fri, 20 May 2005 07:38:39 +1000
Message-ID: <20050519213839.GC24024@gondor.apana.org.au>
References: <20050511230309.GA21547@gondor.apana.org.au> <1115891821.30106.86.camel@tsc-6.cph.tpack.net> <20050512103639.GA25631@gondor.apana.org.au> <20050519.130859.115641546.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tommy.christensen@tpack.net, netdev@oss.sgi.com, chamas@h4.dion.ne.jp
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050519.130859.115641546.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, May 19, 2005 at 01:08:59PM -0700, David S. Miller wrote:
> 
> Ok, I think I got all the patches straight.  All of Tommy's
> patches combined together look like this diff in my tree.
> Please double check it.

Yes this is the one.

> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -735,11 +735,15 @@ static inline int do_one_broadcast(struc
>  
>  	sock_hold(sk);
>  	if (p->skb2 == NULL) {
> -		if (atomic_read(&p->skb->users) != 1) {
> +		if (skb_shared(p->skb)) {
>  			p->skb2 = skb_clone(p->skb, p->allocation);
>  		} else {
> -			p->skb2 = p->skb;
> -			atomic_inc(&p->skb->users);
> +			p->skb2 = skb_get(p->skb);
> +			/*
> +			 * skb ownership may have been set when
> +			 * delivered to a previous socket.
> +			 */
> +			skb_orphan(p->skb2);
>  		}
>  	}
>  	if (p->skb2 == NULL) {
> @@ -785,11 +789,12 @@ int netlink_broadcast(struct sock *ssk, 
>  	sk_for_each_bound(sk, node, &nl_table[ssk->sk_protocol].mc_list)
>  		do_one_broadcast(sk, &info);
>  
> +	kfree_skb(skb);
> +
>  	netlink_unlock_table();
>  
>  	if (info.skb2)
>  		kfree_skb(info.skb2);
> -	kfree_skb(skb);
>  
>  	if (info.delivered) {
>  		if (info.congested && (allocation & __GFP_WAIT))
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
