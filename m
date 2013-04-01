From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] cbq: incorrect processing of high limits
Date: Mon, 01 Apr 2013 09:24:36 -0700
Message-ID: <1364833476.5113.157.camel@edumazet-glaptop>
References: <5159852C.8060003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Vasily Averin <vvs@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:54722 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875Ab3DAQYi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 12:24:38 -0400
Received: by mail-pa0-f47.google.com with SMTP id bj3so1392321pad.34
        for <netdev@vger.kernel.org>; Mon, 01 Apr 2013 09:24:38 -0700 (PDT)
In-Reply-To: <5159852C.8060003@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-01 at 17:01 +0400, Vasily Averin wrote:
> currently cbq works incorrectly for limits > 10% real link bandwidth,
> and practically does not work for limits > 50% real link bandwidth.
> Below are results of experiments taken on 1 Gbit link
> 
>  In shaper | Actual Result
> -----------+---------------
>   100M     | 108 Mbps
>   200M     | 244 Mbps
>   300M     | 412 Mbps
>   500M     | 893 Mbps
> 
> This happen because of q->now changes incorrectly in cbq_dequeue():
> when it is called before real end of packet transmitting,
> L2T is greater than real time delay, q_now gets an extra boost
> but never compensate it.
> 
> To fix this problem we prevent change of q->now until its synchronization
> with real time.
> 
> Signed-off-by: Vasily Averin <vvs@openvz.org>
> Reviewed-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> ---
>  net/sched/sch_cbq.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
> index 6aabd77..5b5c83a 100644
> --- a/net/sched/sch_cbq.c
> +++ b/net/sched/sch_cbq.c
> @@ -962,8 +962,11 @@ cbq_dequeue(struct Qdisc *sch)
> 		cbq_update(q);
> 		if ((incr -= incr2) < 0)
> 			incr = 0;
> +		q->now += incr;
> +	} else {
> +		if (now > q->now)
> +			q->now = now;
> 	}
> -	q->now += incr;
> 	q->now_rt = now;
> 
> 	for (;;) {

Acked-by: Eric Dumazet <edumazet@google.com>

Still, after your patch a limit of 500Mbit gives :

 rate 515872Kbit 946pps backlog 0b 2p requeues 0 

HTB is more precise :

 rate 500667Kbit 41336pps backlog 0b 2p requeues 0 
