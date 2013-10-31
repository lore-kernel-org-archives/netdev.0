From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: pkt_sched: PIE AQM scheme
Date: Thu, 31 Oct 2013 10:03:26 -0700
Message-ID: <1383239006.4857.84.camel@edumazet-glaptop.roam.corp.google.com>
References: <1383167922-22495-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	Mythili Prabhu <mysuryan@cisco.com>,
	Dave Taht <dave.taht@bufferbloat.net>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:46069 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750735Ab3JaRDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Oct 2013 13:03:30 -0400
Received: by mail-ob0-f174.google.com with SMTP id vb8so3330688obc.19
        for <netdev@vger.kernel.org>; Thu, 31 Oct 2013 10:03:28 -0700 (PDT)
In-Reply-To: <1383167922-22495-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-10-30 at 14:18 -0700, Vijay Subramanian wrote:


+       if (tb[TCA_PIE_TUPDATE]) {
+               /* tupdate is in us */
+               u32 tupdate = nla_get_u32(tb[TCA_PIE_TUPDATE]);
+               /* convert to pschedtime */
+               q->params.tupdate = PSCHED_NS2TICKS((u64) tupdate * NSEC_PER_USEC);
+       }

...

> +static void pie_timer(unsigned long arg)
> +{
> +	struct Qdisc *sch = (struct Qdisc *)arg;
> +	struct pie_sched_data *q = qdisc_priv(sch);
> +	u32 tup;
> +	spinlock_t *root_lock = qdisc_lock(qdisc_root_sleeping(sch));
> +
> +	spin_lock(root_lock);
> +	calculate_probability(sch);
> +
> +	/* reset the timer to fire after 'tupdate'. tupdate is currently in
> +	 * psched_time; mod_timer expects time to be in jiffies so convert from
> +	 * pschedtime to jiffies
> +	 */
> +	tup = PSCHED_TICKS2NS(q->params.tupdate);
> +	tup = tup / NSEC_PER_MSEC;
> +	tup = (tup * HZ) / MSEC_PER_SEC;
> +
> +	mod_timer(&q->adapt_timer, jiffies + tup);
> +	spin_unlock(root_lock);
> +
> +}

Oh well, this makes no sense.

mod_timer() resolution is in jiffies, so please maintains params.tupdate
in usec, and use usecs_to_jiffies()

	mod_timer(&q->adapt_timer, jiffies +
				   usecs_to_jiffies(q->params.tupdate));
