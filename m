From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: use __GFP_NORETRY for high order allocations
Date: Thu, 06 Feb 2014 12:24:30 -0800
Message-ID: <1391718270.15777.20.camel@joe-AO722>
References: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	David Rientjes <rientjes@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391712162.10160.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-02-06 at 10:42 -0800, Eric Dumazet wrote:
> sock_alloc_send_pskb() & sk_page_frag_refill()
> have a loop trying high order allocations to prepare
> skb with low number of fragments as this increases performance.
> 
> Problem is that under memory pressure/fragmentation, this can
> trigger OOM while the intent was only to try the high order
> allocations, then fallback to order-0 allocations.
[]
> Call Trace:
>  [<ffffffff8043766c>] dump_header+0xe1/0x23e
>  [<ffffffff80437a02>] oom_kill_process+0x6a/0x323
>  [<ffffffff80438443>] out_of_memory+0x4b3/0x50d
>  [<ffffffff8043a4a6>] __alloc_pages_may_oom+0xa2/0xc7
>  [<ffffffff80236f42>] __alloc_pages_nodemask+0x1002/0x17f0
>  [<ffffffff8024bd23>] alloc_pages_current+0x103/0x2b0
>  [<ffffffff8028567f>] sk_page_frag_refill+0x8f/0x160
[]
> diff --git a/net/core/sock.c b/net/core/sock.c
[]
> @@ -1775,7 +1775,9 @@ struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
>  			while (order) {
>  				if (npages >= 1 << order) {
>  					page = alloc_pages(sk->sk_allocation |
> -							   __GFP_COMP | __GFP_NOWARN,
> +							   __GFP_COMP |
> +							   __GFP_NOWARN |
> +							   __GFP_NORETRY,
>  							   order);
>  					if (page)
>  						goto fill_page;
> @@ -1845,7 +1847,7 @@ bool skb_page_frag_refill(unsigned int sz, struct page_frag *pfrag, gfp_t prio)
>  		gfp_t gfp = prio;
>  
>  		if (order)
> -			gfp |= __GFP_COMP | __GFP_NOWARN;
> +			gfp |= __GFP_COMP | __GFP_NOWARN | __GFP_NORETRY;

Perhaps add __GFP_THISNODE too ?
