From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 11:11:37 -0700
Message-ID: <46D859D9.6030407@hp.com>
References: <200708310009.RAA04175@tardy.cup.hp.com>	<20070830.173912.79067694.davem@davemloft.net>	<46D769C1.8090808@hp.com> <20070830.220911.41008322.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:37706 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965726AbXHaSLy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 14:11:54 -0400
In-Reply-To: <20070830.220911.41008322.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 30 Aug 2007 18:07:13 -0700
> 
> 
>>Anyhow, I'll try grubbing around the source code (already doing that to 
>>see about writing a pet tcp cong module) but if pointers to the likely 
>>relevant files were available I could try to help thrash-out the routing 
>>metric version.  Like I said the consumers of this are a triffle well, 
>>"anxious" :)
> 
> 
> The change is actually a lot simpler than the sysctl version.
> 
> In fact it borders on trivial :-)
> 
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index c91476c..dff3192 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -351,6 +351,8 @@ enum
>  #define RTAX_INITCWND RTAX_INITCWND
>  	RTAX_FEATURES,
>  #define RTAX_FEATURES RTAX_FEATURES
> +	RTAX_RTO_MIN,
> +#define RTAX_RTO_MIN RTAX_RTO_MIN
>  	__RTAX_MAX
>  };
>  
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 9785df3..1ee7212 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -555,6 +555,16 @@ static void tcp_event_data_recv(struct sock *sk, struct sk_buff *skb)
>  		tcp_grow_window(sk, skb);
>  }
>  
> +static u32 tcp_rto_min(struct sock *sk)
> +{
> +	struct dst_entry *dst = __sk_dst_get(sk);
> +	u32 rto_min = TCP_RTO_MIN;
> +
> +	if (dst_metric_locked(dst, RTAX_RTO_MIN))
> +		rto_min = dst->metrics[RTAX_RTO_MIN-1];
> +	return rto_min;
> +}
> +
>  /* Called to compute a smoothed rtt estimate. The data fed to this
>   * routine either comes from timestamps, or from segments that were
>   * known _not_ to have been retransmitted [see Karn/Partridge
> @@ -616,13 +626,13 @@ static void tcp_rtt_estimator(struct sock *sk, const __u32 mrtt)
>  			if (tp->mdev_max < tp->rttvar)
>  				tp->rttvar -= (tp->rttvar-tp->mdev_max)>>2;
>  			tp->rtt_seq = tp->snd_nxt;
> -			tp->mdev_max = TCP_RTO_MIN;
> +			tp->mdev_max = tcp_rto_min(sk);
>  		}
>  	} else {
>  		/* no previous measure. */
>  		tp->srtt = m<<3;	/* take the measured time to be rtt */
>  		tp->mdev = m<<1;	/* make sure rto = 3*rtt */
> -		tp->mdev_max = tp->rttvar = max(tp->mdev, TCP_RTO_MIN);
> +		tp->mdev_max = tp->rttvar = max(tp->mdev, tcp_rto_min(sk));
>  		tp->rtt_seq = tp->snd_nxt;
>  	}
>  }

At the risk of showing my ignorance (what me worry about that?-) I 
presume this is then an interface expecting to take-in jiffies?  That 
means the user has to know the value of HZ which can be (IIRC) one of 
three different values?

rick jones
