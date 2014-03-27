From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] packet: respect devices with LLTX flag in
 direct xmit
Date: Thu, 27 Mar 2014 09:01:34 -0700
Message-ID: <1395936094.12610.299.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:49196 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086AbaC0QBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 12:01:36 -0400
Received: by mail-pd0-f178.google.com with SMTP id x10so3543350pdj.23
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 09:01:36 -0700 (PDT)
In-Reply-To: <1395934710-29182-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-27 at 16:38 +0100, Daniel Borkmann wrote:
> Quite often it can be useful to test with dummy or similar
> devices as a blackhole sink for skbs. Such devices are only
> equipped with a single txq, but marked as NETIF_F_LLTX as
> they do not require locking their internal queues on xmit
> (or implement locking themselves). Therefore, rather use
> HARD_TX_{UN,}LOCK API, so that NETIF_F_LLTX will be respected.
> 
> trafgen mmap/TX_RING example against dummy device with config
> foo: { fill(0xff, 64) } results in the following performance
> improvements for such scenarios on an ordinary Core i7/2.80GHz:
> 
> Before:
> 
>  Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):
> 
>    160,975,944,159 instructions:k            #    0.55  insns per cycle          ( +-  0.09% )
>    293,319,390,278 cycles:k                  #    0.000 GHz                      ( +-  0.35% )
>        192,501,104 branch-misses:k                                               ( +-  1.63% )
>                831 context-switches:k                                            ( +-  9.18% )
>                  7 cpu-migrations:k                                              ( +-  7.40% )
>             69,382 cache-misses:k            #    0.010 % of all cache refs      ( +-  2.18% )
>        671,552,021 cache-references:k                                            ( +-  1.29% )
> 
>       22.856401569 seconds time elapsed                                          ( +-  0.33% )
> 
> After:
> 
>  Performance counter stats for 'trafgen -i foo -o du0 -n100000000' (10 runs):
> 
>    133,788,739,692 instructions:k            #    0.92  insns per cycle          ( +-  0.06% )
>    145,853,213,256 cycles:k                  #    0.000 GHz                      ( +-  0.17% )
>         59,867,100 branch-misses:k                                               ( +-  4.72% )
>                384 context-switches:k                                            ( +-  3.76% )
>                  6 cpu-migrations:k                                              ( +-  6.28% )
>             70,304 cache-misses:k            #    0.077 % of all cache refs      ( +-  1.73% )
>         90,879,408 cache-references:k                                            ( +-  1.35% )
> 
>       11.719372413 seconds time elapsed                                          ( +-  0.24% )
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> ---
>  net/packet/af_packet.c | 40 ++++++++++++++++++++--------------------
>  1 file changed, 20 insertions(+), 20 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 097a354..01039d2 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -243,40 +243,40 @@ static int packet_direct_xmit(struct sk_buff *skb)
>  	const struct net_device_ops *ops = dev->netdev_ops;
>  	netdev_features_t features;
>  	struct netdev_queue *txq;
> +	int ret = NETDEV_TX_BUSY;
>  	u16 queue_map;
> -	int ret;
>  
>  	if (unlikely(!netif_running(dev) ||
> -		     !netif_carrier_ok(dev))) {
> -		kfree_skb(skb);
> -		return NET_XMIT_DROP;
> -	}
> +		     !netif_carrier_ok(dev)))
> +		goto drop;
>  
>  	features = netif_skb_features(skb);
>  	if (skb_needs_linearize(skb, features) &&
> -	    __skb_linearize(skb)) {
> -		kfree_skb(skb);
> -		return NET_XMIT_DROP;
> -	}
> +	    __skb_linearize(skb))
> +		goto drop;
>  
>  	queue_map = skb_get_queue_mapping(skb);
>  	txq = netdev_get_tx_queue(dev, queue_map);
>  
> -	__netif_tx_lock_bh(txq);
> -	if (unlikely(netif_xmit_frozen_or_stopped(txq))) {
> -		ret = NETDEV_TX_BUSY;
> -		kfree_skb(skb);
> -		goto out;
> +	local_bh_disable();
> +
> +	HARD_TX_LOCK(dev, txq, smp_processor_id());
> +	if (!netif_xmit_frozen_or_stopped(txq)) {
> +		ret = ops->ndo_start_xmit(skb, dev);
> +		if (ret == NETDEV_TX_OK)
> +			txq_trans_update(txq);
>  	}
> +	HARD_TX_UNLOCK(dev, txq);
>  
> -	ret = ops->ndo_start_xmit(skb, dev);
> -	if (likely(dev_xmit_complete(ret)))
> -		txq_trans_update(txq);

I think this is problematic.

If you have concurrent traffic going through txq, and a flood
going through packet_direct_xmit(), the timeout will trigger on txq
because we do no longer update txq->trans_start

So I think you should force the update

	txq->trans_start = jiffies;


> -	else
> +	local_bh_enable();
> +
> +	if (!dev_xmit_complete(ret))
>  		kfree_skb(skb);
> -out:
> -	__netif_tx_unlock_bh(txq);
> +
>  	return ret;
> +drop:
> +	kfree_skb(skb);


Yep, another spot we likely need to 

	atomic_long_inc(&dev->tx_dropped); 

;)

> +	return NET_XMIT_DROP;
>  }
>  
