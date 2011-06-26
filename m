From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net_sched: fix dequeuer fairness
Date: Sun, 26 Jun 2011 15:53:53 +0100
Message-ID: <1309100033.3093.1499.camel@localhost>
References: <1309097254.5134.24.camel@mojatatu>
	 <1309097862.5134.26.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41364 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919Ab1FZOx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jun 2011 10:53:57 -0400
In-Reply-To: <1309097862.5134.26.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-26 at 10:17 -0400, jamal wrote:
[...]
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index b4c6809..578269e 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -190,14 +190,18 @@ static inline int qdisc_restart(struct Qdisc *q)
>  void __qdisc_run(struct Qdisc *q)
>  {
>         unsigned long start_time = jiffies;
> +       int quota = 0;
> +       int work = weight_p;

These variable names seem to be the wrong way round, i.e. the weight is
our 'quota' and the number of packets dequeued is the 'work' we've done.

Ben.

>         while (qdisc_restart(q)) {
> +               quota++;
>                 /*
> -                * Postpone processing if
> -                * 1. another process needs the CPU;
> -                * 2. we've been doing it for too long.
> +                * Ordered by possible occurrence: Postpone processing if
> +                * 1. we've exceeded packet quota
> +                * 2. another process needs the CPU;
> +                * 3. we've been doing it for too long.
>                  */
> -               if (need_resched() || jiffies != start_time) {
> +               if (quota >= work || need_resched() || jiffies != start_time) {
>                         __netif_schedule(q);
>                         break;
>                 }
> 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

