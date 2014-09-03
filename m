From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net-timestamp: Make the clone operation stand-alone
 from phy timestamping
Date: Wed, 03 Sep 2014 14:07:18 -0700
Message-ID: <1409778438.26422.54.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903155022.1896.59030.stgit@ahduyck-bv4.jf.intel.com>
	 <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:43676 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755957AbaICVHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 17:07:21 -0400
Received: by mail-pa0-f45.google.com with SMTP id bj1so18270074pad.32
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 14:07:21 -0700 (PDT)
In-Reply-To: <20140903155357.1896.92538.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 11:53 -0400, Alexander Duyck wrote:
> The phy timestamping takes a different path than the regular timestamping
> does in that it will create a clone first so that the packets needing to be
> timestamped can be placed in a queue, or the context block could be used.
> 
> In order to support these use cases I am pulling the core of the code out
> so it can be used in other drivers beyond just phy devices.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> ---
>  include/linux/skbuff.h  |    2 ++
>  net/core/skbuff.c       |   20 ++++++++++++++++++++
>  net/core/timestamping.c |   14 +++-----------
>  3 files changed, 25 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 02529fc..19eb787 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2690,6 +2690,8 @@ static inline ktime_t net_invalid_timestamp(void)
>  	return ktime_set(0, 0);
>  }
>  
> +struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb);
> +
>  #ifdef CONFIG_NETWORK_PHY_TIMESTAMPING
>  
>  void skb_clone_tx_timestamp(struct sk_buff *skb);
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 488d902..3f5cf29 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -3511,6 +3511,26 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sock_dequeue_err_skb);
>  
> +struct sk_buff *__skb_clone_tx_timestamp(struct sk_buff *skb)
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
> +
> +	return clone;
> +}
> +EXPORT_SYMBOL(__skb_clone_tx_timestamp);


Normally, if one skb holds a reference to a socket, it should have
skb->destructor set to a cleanup function.

Otherwise, we rely on callers following a convention, to release sk
reference.

If you believe its needed, it should be dully documented.

Thanks
