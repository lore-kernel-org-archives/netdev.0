From: Andrew Shewmaker <agshew@gmail.com>
Subject: Re: [PATCH net-next 2/7] tcp: track min RTT using windowed min-filter
Date: Wed, 14 Oct 2015 02:28:00 -0700
Message-ID: <20151014092800.GA3748@mininet-vm>
References: <1445057867-32257-1-git-send-email-ycheng@google.com>
 <1445057867-32257-3-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:32907 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbbJROQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 10:16:50 -0400
Received: by iodv82 with SMTP id v82so165115966iod.0
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2015 07:16:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1445057867-32257-3-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 09:57:42PM -0700, Yuchung Cheng wrote:
...
> diff --git a/include/linux/tcp.h b/include/linux/tcp.h
> index 86a7eda..90edef5 100644
> --- a/include/linux/tcp.h
> +++ b/include/linux/tcp.h
> @@ -217,6 +217,9 @@ struct tcp_sock {
>  	u32	mdev_max_us;	/* maximal mdev for the last rtt period	*/
>  	u32	rttvar_us;	/* smoothed mdev_max			*/
>  	u32	rtt_seq;	/* sequence number to update rttvar	*/
> +	struct rtt_meas {
> +		u32 rtt, ts;	/* RTT in usec and sampling time in jiffies. */
> +	} rtt_min[3];

First, thanks for all the work in this patch series. In particular,
applying Kern's check to ca_seq_rtt_us should fix some bad behavior
I've observed recently.

I only have a couple comments, so I abbreviated most of your patch.
Should rtt_meas.rtt be rtt_meas.rtt_us in order to be more consistent
with the naming of related variables?

...
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 38743e5..e177386 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
...
> @@ -2961,7 +3028,7 @@ void tcp_synack_rtt_meas(struct sock *sk, struct request_sock *req)
>  		rtt_us = skb_mstamp_us_delta(&now, &tcp_rsk(req)->snt_synack);
>  	}
>  
> -	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L);
> +	tcp_ack_update_rtt(sk, FLAG_SYN_ACKED, rtt_us, -1L, rtt_us);
>  }

This didn't apply to net-next for me. I see seq_rtt_us instead of
rtt_us and a check on the existence of tp->srtt_us. Maybe I've
misapplied the patch? I'll try again and test the patch series
against the bad behavior I mentioned above as soon as I can.
Hopefully today.

-Andrew Shewmaker
