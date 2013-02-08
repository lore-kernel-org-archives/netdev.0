From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next 6/7] tbf: improved accuracy at high rates
Date: Fri, 08 Feb 2013 08:42:47 -0800
Message-ID: <1360341767.28557.104.camel@edumazet-glaptop>
References: <1360328327-7144-1-git-send-email-jiri@resnulli.us>
	 <1360328327-7144-7-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:53071 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946552Ab3BHQmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:42:51 -0500
Received: by mail-pa0-f48.google.com with SMTP id hz10so2144341pad.21
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:42:50 -0800 (PST)
In-Reply-To: <1360328327-7144-7-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 13:58 +0100, Jiri Pirko wrote:
> Current TBF uses rate table computed by the "tc" userspace program,
> which has the following issue:
> 
> The rate table has 256 entries to map packet lengths to
> token (time units).  With TSO sized packets, the 256 entry granularity
> leads to loss/gain of rate, making the token bucket inaccurate.
> 
> Thus, instead of relying on rate table, this patch explicitly computes
> the time and accounts for packet transmission times with nanosecond
> granularity.
> 
> This is a followup to 56b765b79e9a78dc7d3f8850ba5e5567205a3ecd
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/sched/sch_tbf.c | 60 ++++++++++++++++++++++++++---------------------------
>  1 file changed, 29 insertions(+), 31 deletions(-)
> 
> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> index 4b056c15..35bfd49 100644
> --- a/net/sched/sch_tbf.c
> +++ b/net/sched/sch_tbf.c
> @@ -19,6 +19,7 @@
>  #include <linux/errno.h>
>  #include <linux/skbuff.h>
>  #include <net/netlink.h>
> +#include <net/sch_generic.h>
>  #include <net/pkt_sched.h>
>  
> 
> @@ -100,23 +101,21 @@
>  struct tbf_sched_data {
>  /* Parameters */
>  	u32		limit;		/* Maximal length of backlog: bytes */
> -	u32		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
> +	s64		buffer;		/* Token bucket depth/rate: MUST BE >= MTU/B */
>  	u32		mtu;
>  	u32		max_size;
> -	struct qdisc_rate_table	*R_tab;
> -	struct qdisc_rate_table	*P_tab;
> +	struct psched_ratecfg rate;
> +	struct psched_ratecfg peek;
> +	bool peek_present;
>  

Seems good to me, I'll add my Ack when you resend it with 'peak' typo
and after my tests.
