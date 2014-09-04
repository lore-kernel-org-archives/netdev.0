From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next v4 2/3] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Thu, 04 Sep 2014 10:48:58 -0700
Message-ID: <5408A60A.3070603@hp.com>
References: <20140904172906.7702.87598.stgit@ahduyck-bv4.jf.intel.com> <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hp.com ([15.217.136.92]:2062 "EHLO
	g2t1383g.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854AbaIDRtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 13:49:12 -0400
Received: from g6t1526.atlanta.hp.com (g6t1526.atlanta.hp.com [15.193.200.69])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by g2t1383g.austin.hp.com (Postfix) with ESMTPS id CAFF31FC
	for <netdev@vger.kernel.org>; Thu,  4 Sep 2014 17:49:11 +0000 (UTC)
In-Reply-To: <20140904173116.7702.30877.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/04/2014 10:31 AM, Alexander Duyck wrote:

>
> ---
>
> v2: Renamed function to skb_clone_sk.
>      Added destructor to call sock_put instead of doing it ourselves.
>      Dropped freeing functionality from skb_complete_tx_timestamp.
>      Added additional documentation to the code.
>
> v3: Renamed destructor sock_efree and moved to sock.c/h
>      Added sock_hold/sock_put around call to sock_queue_err_skb
>
> v4: Dropped combining sock_edemux with sock_efree where the 2 are identical
>
>   drivers/net/phy/dp83640.c |    6 +++---
>   include/linux/skbuff.h    |    2 ++
>   include/net/sock.h        |    1 +
>   net/core/skbuff.c         |   32 +++++++++++++++++++++++++-------
>   net/core/sock.c           |    6 ++++++
>   net/core/timestamping.c   |   14 +++-----------
>   6 files changed, 40 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
> index d5991ac..87648b3 100644
> --- a/drivers/net/phy/dp83640.c
> +++ b/drivers/net/phy/dp83640.c
> @@ -1148,7 +1148,7 @@ static void dp83640_remove(struct phy_device *phydev)
>   		kfree_skb(skb);
>
>   	while ((skb = skb_dequeue(&dp83640->tx_queue)) != NULL)
> -		skb_complete_tx_timestamp(skb, NULL);
> +		kfree_skb(skb);

I may not be following the flow correctly, and may be noticing only 
because I just did two "floor-sweeping" patches to shift be2net and 
mlx4_en to "consume" but would it be better if these kfree_skb calls 
were a "consume" variety?

rick jones

>
>   	clock = dp83640_clock_get(dp83640->clock);
>
> @@ -1405,7 +1405,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
>
>   	case HWTSTAMP_TX_ONESTEP_SYNC:
>   		if (is_sync(skb, type)) {
> -			skb_complete_tx_timestamp(skb, NULL);
> +			kfree_skb(skb);
>   			return;
>   		}
>   		/* fall through */
> @@ -1416,7 +1416,7 @@ static void dp83640_txtstamp(struct phy_device *phydev,
>
>   	case HWTSTAMP_TX_OFF:
>   	default:
> -		skb_complete_tx_timestamp(skb, NULL);
> +		kfree_skb(skb);
>   		break;
>   	}
>   }
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 02529fc..1cf0cfa 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2690,6 +2690,8 @@ static inline ktime_t net_invalid_timestamp(void)
>   	return ktime_set(0, 0);
>   }
>
> +struct sk_buff *skb_clone_sk(struct sk_buff *skb);
> +
>   #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
>
>   void skb_clone_tx_timestamp(struct sk_buff *skb);
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 3fde613..e02be37 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1574,6 +1574,7 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
>   void sock_wfree(struct sk_buff *skb);
>   void skb_orphan_partial(struct sk_buff *skb);
>   void sock_rfree(struct sk_buff *skb);
> +void sock_efree(struct sk_buff *skb);
>   void sock_edemux(struct sk_buff *skb);
>
>   int sock_setsockopt(struct socket *sock, int level, int op,
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 697e696..a936a40 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3511,6 +3511,27 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
>   }
>   EXPORT_SYMBOL(sock_dequeue_err_skb);
>
> +struct sk_buff *skb_clone_sk(struct sk_buff *skb)
> +{
> +	struct sock *sk = skb->sk;
> +	struct sk_buff *clone;
> +
> +	if (!sk || !atomic_inc_not_zero(&sk->sk_refcnt))
> +		return NULL;
> +
> +	clone = skb_clone(skb, GFP_ATOMIC);
> +	if (!clone) {
> +		sock_put(sk);
> +		return NULL;
> +	}
> +
> +	clone->sk = sk;
> +	clone->destructor = sock_efree;
> +
> +	return clone;
> +}
> +EXPORT_SYMBOL(skb_clone_sk);
> +
>   static void __skb_complete_tx_timestamp(struct sk_buff *skb,
>   					struct sock *sk,
>   					int tstype)
> @@ -3540,14 +3561,11 @@ void skb_complete_tx_timestamp(struct sk_buff *skb,
>   {
>   	struct sock *sk = skb->sk;
>
> -	skb->sk = NULL;
> +	/* take a reference to prevent skb_orphan() from freeing the socket */
> +	sock_hold(sk);
>
> -	if (hwtstamps) {
> -		*skb_hwtstamps(skb) = *hwtstamps;
> -		__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
> -	} else {
> -		kfree_skb(skb);
> -	}
> +	*skb_hwtstamps(skb) = *hwtstamps;
> +	__skb_complete_tx_timestamp(skb, sk, SCM_TSTAMP_SND);
>
>   	sock_put(sk);
>   }
> diff --git a/net/core/sock.c b/net/core/sock.c
> index f1a638e..d04005c 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1637,6 +1637,12 @@ void sock_rfree(struct sk_buff *skb)
>   }
>   EXPORT_SYMBOL(sock_rfree);
>
> +void sock_efree(struct sk_buff *skb)
> +{
> +	sock_put(skb->sk);
> +}
> +EXPORT_SYMBOL(sock_efree);
> +
>   void sock_edemux(struct sk_buff *skb)
>   {
>   	struct sock *sk = skb->sk;
> diff --git a/net/core/timestamping.c b/net/core/timestamping.c
> index f48a59f..43d3dd6 100644
> --- a/net/core/timestamping.c
> +++ b/net/core/timestamping.c
> @@ -36,10 +36,9 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
>   {
>   	struct phy_device *phydev;
>   	struct sk_buff *clone;
> -	struct sock *sk = skb->sk;
>   	unsigned int type;
>
> -	if (!sk)
> +	if (!skb->sk)
>   		return;
>
>   	type = classify(skb);
> @@ -48,16 +47,9 @@ void skb_clone_tx_timestamp(struct sk_buff *skb)
>
>   	phydev = skb->dev->phydev;
>   	if (likely(phydev->drv->txtstamp)) {
> -		if (!atomic_inc_not_zero(&sk->sk_refcnt))
> +		clone = skb_clone_sk(skb);
> +		if (!clone)
>   			return;
> -
> -		clone = skb_clone(skb, GFP_ATOMIC);
> -		if (!clone) {
> -			sock_put(sk);
> -			return;
> -		}
> -
> -		clone->sk = sk;
>   		phydev->drv->txtstamp(phydev, clone, type);
>   	}
>   }
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
