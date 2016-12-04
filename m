From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCN net-next] net_sched: gen_estimator: complete rewrite of
 rate estimators
Date: Sat, 03 Dec 2016 23:12:27 -0800
Message-ID: <1480835547.18162.459.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2016-12-03 at 23:07 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Old code was hard to maintain, due to complex lock chains.
>    (We probably will be able to remove some kfree_rcu() in callers)
> 
> 2) Using a single timer to update all estimators does not scale.
> 
> 3) Code was buggy on 32bit kernel (WRITE_ONCE() on 64bit quantity
>    is not supposed to work well)


> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index c7adcb57654ea57d1ba6702c91743cb7d2c74d28..859b60bfa86712031186fffc09c65bc43aa065dd 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2081,6 +2081,14 @@ static bool tcp_small_queue_check(struct sock *sk, const struct sk_buff *skb,
>  	limit <<= factor;
>  
>  	if (atomic_read(&sk->sk_wmem_alloc) > limit) {
> +		/* Special case where TX completion is delayed too much :
> +		 * If the skb we try to send is the first skb in write queue,
> +		 * then send it !
> +		 * No need to wait for TX completion to call us back.
> +		 */
> +		if (skb == sk->sk_write_queue.next)
> +			return false;
> +

Oups, this has nothing to do here. I will send a v2, sorry.


