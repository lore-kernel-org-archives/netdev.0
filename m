From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next] ipv6: use ipv6_dup_options() from
 ip6_append_data()
Date: Fri, 17 May 2013 21:58:04 +0800
Message-ID: <20130517135804.GA16069@gondor.apana.org.au>
References: <1368742990.3301.67.camel@edumazet-glaptop>
 <1368750452.3301.74.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Neal Cardwell <ncardwell@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:37104 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753389Ab3EQN6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 09:58:47 -0400
Content-Disposition: inline
In-Reply-To: <1368750452.3301.74.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 05:27:32PM -0700, Eric Dumazet wrote:
> On Thu, 2013-05-16 at 15:23 -0700, Eric Dumazet wrote:
> > Hi Herbert
> > 
> > Looking at the code added in commit 0178b695fd6b40a62a215cb
> > ("ipv6: Copy cork options in ip6_append_data") it looks like we can have
> > either a memleak or corruption (later in ip6_cork_release()) in case one
> > of the sub-allocation (ip6_opt_dup()/ip6_rthdr_dup()) fails.
> > 
> > I would at least use a kzalloc() instead of kmalloc() in 
> > 
> > np->cork.opt = kmalloc(opt->tot_len, sk->sk_allocation);
> > 
> > Or maybe better, reuse the code in  ipv6_dup_options() so that we
> > perform a single memory allocation ?
> 
> Something like following maybe ?
> 
> [PATCH net-next] ipv6: use ipv6_dup_options() from ip6_append_data()
> 
> commit 0178b695fd6b4 ("ipv6: Copy cork options in ip6_append_data")
> added some code duplication and bad error recovery, leading to potential
> crash.
> 
> Allow ipv6_dup_options() to be called with a NULL socket argument
> so that we can reuse it.

Yes you're quite right, my code was definitely buggy.

> @@ -721,7 +721,11 @@ ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
>  {
>  	struct ipv6_txoptions *opt2;
>  
> -	opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
> +	if (sk)
> +		opt2 = sock_kmalloc(sk, opt->tot_len, GFP_ATOMIC);
> +	else
> +		opt2 = kmalloc(opt->tot_len, GFP_ATOMIC);
> +

However, I think this function is just as buggy as the original
code that I replaced.  If you look at the code that fills in the
options in ip6_datagram_send_ctl, you'll find that the options do
not lie in the memory area of the opt + opt->tot_len.  They instead
point to data in the cmsg.

So I think we should

1) fix ipv6_dup_options to do what I tried do but in a non-buggy way;
2) make the UDP path use it.

BTW, in the UDP path we also have a socket so we can just charge the
memory to it and avoid using kmalloc at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
