From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: reduce number of reference taken on sk_refcnt
Date: Mon, 18 May 2009 21:58:23 -0700 (PDT)
Message-ID: <20090518.215823.98238538.davem@davemloft.net>
References: <4A067D9E.7050706@cosmosbay.com>
	<4A0685A0.8020002@cosmosbay.com>
	<4A06B064.9080801@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: khc@pm.waw.pl, netdev@vger.kernel.org, satoru.satoh@gmail.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54469
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752060AbZESE6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 00:58:25 -0400
In-Reply-To: <4A06B064.9080801@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 10 May 2009 12:45:56 +0200

> Patch follows for RFC only (not Signed-of...), and based on net-next-2.6 

Thanks for the analysis.

> @@ -922,10 +922,13 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
>  	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
>  		wake_up_interruptible_poll(sk->sk_sleep,
>  					   POLLIN | POLLRDNORM | POLLRDBAND);
> -		if (!inet_csk_ack_scheduled(sk))
> +		if (!inet_csk_ack_scheduled(sk)) {
> +			unsigned int delay = (3 * tcp_rto_min(sk)) / 4;
> +
> +			delay = min(inet_csk(sk)->icsk_ack.ato, delay);
>  			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
> -						  (3 * tcp_rto_min(sk)) / 4,
> -						  TCP_RTO_MAX);
> +						  delay, TCP_RTO_MAX);
> +		}
>  	}
>  	return 1;

I think this code is trying to aggressively stretch the ACK when
prequeueing.  In order to make sure there is enough time to get
the process on the CPU and send a response, and thus piggyback
the ACK.

If that turns out not to really matter, or matter less than your
problem, then we can make your change and I'm all for it.
