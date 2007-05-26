From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH][NET_SCHED] Update htb rate when stats are polled.
Date: Sat, 26 May 2007 07:10:52 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705260650530.22705@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Ranjit Manomohan <ranjitm@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48941 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752150AbXEZEK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 May 2007 00:10:56 -0400
In-Reply-To: <Pine.LNX.4.63.0705250923210.27351@ranjit.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

...couple of formatting related things, see inline comment...

On Fri, 25 May 2007, Ranjit Manomohan wrote:

> Currently the HTB rate for a class is update very slowly (once
> every 16 seconds). This patch updates the rate whenever the stats
> are requested from user space. This enables more accurate rate
> monitoring.
> 
> Signed-off-by: Ranjit Manomohan <ranjitm@google.com>
> 
> diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
> index 035788c..1d6ec60 100644
> --- a/net/sched/sch_htb.c
> +++ b/net/sched/sch_htb.c
> @@ -92,6 +92,7 @@ struct htb_class {
>  	struct gnet_stats_basic bstats;
>  	struct gnet_stats_queue qstats;
>  	struct gnet_stats_rate_est rate_est;
> +	unsigned long rate_est_when;	/* last time rate was calculated */
>  	struct tc_htb_xstats xstats;	/* our special stats */
>  	int refcnt;		/* usage count of this class */
> 
> @@ -679,6 +680,23 @@ static int htb_requeue(struct sk_buff *s
> 
>  #ifdef HTB_RATECM
>  #define RT_GEN(D,R) R+=D-(R/HTB_EWMAC);D=0
> +
> +/* Update packet/byte rate for a class. */
> +static void calc_rate(struct htb_class *cl)
> +{
> +	unsigned long now = jiffies;
> +	if (time_after(now, (cl->rate_est_when + HZ))) {
> +	unsigned int elapsed_secs =
> +			(now - cl->rate_est_when)/HZ;

...add whitespaces around the operator please, fix indentation and 
remove unnecessary newline, it should fit to a single line...

> +		cl->sum_bytes /= elapsed_secs;
> +		cl->sum_packets /= elapsed_secs;
> +		RT_GEN (cl->sum_bytes,cl->rate_bytes);
> +		RT_GEN (cl->sum_packets,cl->rate_packets);

Could you please fix these two back to the original formatting that 
was compliant with the kernel Documentation/CodingStyle guidelines...

> +		cl->rate_est_when = now;
> +	} else if time_before(now, cl->rate_est_when)
> +		cl->rate_est_when = now; /* Wraparound */
> +}
> +
>  static void htb_rate_timer(unsigned long arg)
>  {
>  	struct Qdisc *sch = (struct Qdisc *)arg;
> @@ -697,10 +715,8 @@ static void htb_rate_timer(unsigned long
>  	if (++q->recmp_bucket >= HTB_HSIZE)
>  		q->recmp_bucket = 0;
> 
> -	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist) {
> -		RT_GEN(cl->sum_bytes, cl->rate_bytes);
> -		RT_GEN(cl->sum_packets, cl->rate_packets);
> -	}
> +	hlist_for_each_entry(cl,p, q->hash + q->recmp_bucket, hlist)

...I guess nobody would complain if you fix whitespacing here too (since 
you're modifying the line) but that's not mandatory since the problem in 
the original.

> +		calc_rate(cl);
>  	spin_unlock_bh(&sch->dev->queue_lock);
>  }
> [...snip...]


-- 
 i.
