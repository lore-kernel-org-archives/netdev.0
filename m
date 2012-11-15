From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] tcp: handle tcp_net_metrics_init() order-5 memory
 allocation failures
Date: Thu, 15 Nov 2012 15:55:52 -0800
Message-ID: <1353023752.24310.1.camel@joe-AO722>
References: <1353022864.10798.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Julien Tinnes <jln@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:41901 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751283Ab2KOXzw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 18:55:52 -0500
In-Reply-To: <1353022864.10798.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 15:41 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> order-5 allocations can fail with current kernels, we should
> try to reduce allocation sizes to allow network namespace
> creation.
> 
> Reported-by: Julien Tinnes <jln@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_metrics.c |   13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp_metrics.c
> index 53bc584..15e93c4 100644
> --- a/net/ipv4/tcp_metrics.c
> +++ b/net/ipv4/tcp_metrics.c
> @@ -1030,14 +1030,17 @@ static int __net_init tcp_net_metrics_init(struct net *net)
>  		else
>  			slots = 8 * 1024;
>  	}
> -
> +retry:
>  	net->ipv4.tcp_metrics_hash_log = order_base_2(slots);
>  	size = sizeof(struct tcpm_hash_bucket) << net->ipv4.tcp_metrics_hash_log;
>  
> -	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL);
> -	if (!net->ipv4.tcp_metrics_hash)
> -		return -ENOMEM;
> -
> +	net->ipv4.tcp_metrics_hash = kzalloc(size, GFP_KERNEL | __GFP_NOWARN);
> +	if (!net->ipv4.tcp_metrics_hash) {
> +		if (slots <= 16)
> +			return -ENOMEM;

maybe readd the warning for OOM reporting here?
