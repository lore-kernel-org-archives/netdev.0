From: =?UTF-8?Q?Mika_Penttil=c3=a4?= <mika.penttila@nextfour.com>
Subject: Re: [PATCH RFC] inetpeer: remove AVL implementation in favor of RB
 tree
Date: Wed, 5 Jul 2017 19:38:16 +0300
Message-ID: <fc780727-897c-13c1-30f6-ab2e3f21f321@nextfour.com>
References: <1499270405.16045.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Florian Westphal <fw@strlen.de>,
        netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1499270405.16045.8.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!


On 05.07.2017 19:00, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> As discussed in Faro during Netfilter Workshop 2017, RB trees can be
> used with RCU, using a seqlock.
>
> Note that net/rxrpc/conn_service.c is already using this.
>
> This patch converts inetpeer from AVL tree to RB tree, since it allows
> to remove private AVL code in favor of shared RB code.
>
> $ size net/ipv4/inetpeer.before net/ipv4/inetpeer.after
>    text	   data	    bss	    dec	    hex	filename
>    3195	     40	    128	   3363	    d23	net/ipv4/inetpeer.before
>    1562	     24	      0	   1586	    632	net/ipv4/inetpeer.after
>
> The same technique can be used to speed up
> net/netfilter/nft_set_rbtree.c
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  
>  	return p;
> @@ -467,8 +231,9 @@ EXPORT_SYMBOL_GPL(inet_getpeer);
>  void inet_putpeer(struct inet_peer *p)
>  {
>  	p->dtime = (__u32)jiffies;
> -	smp_mb__before_atomic();
> -	refcount_dec(&p->refcnt);
> +
> +	if (refcount_dec_and_test(&p->refcnt))

Missing rb_erase() here...

> +		call_rcu(&p->rcu, inetpeer_free_rcu);
>  }
>  EXPORT_SYMBOL_GPL(inet_putpeer);
>  
>
--Mika


