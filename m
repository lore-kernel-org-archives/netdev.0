From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next v2 10/11] act_police: improved accuracy at high
 rates
Date: Fri, 08 Feb 2013 11:12:35 -0800
Message-ID: <1360350755.28557.108.camel@edumazet-glaptop>
References: <1360349981-27801-1-git-send-email-jiri@resnulli.us>
	 <1360349981-27801-11-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	jhs@mojatatu.com, kuznet@ms2.inr.ac.ru, j.vimal@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f50.google.com ([209.85.210.50]:35000 "EHLO
	mail-da0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760377Ab3BHTMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 14:12:38 -0500
Received: by mail-da0-f50.google.com with SMTP id h15so1938542dan.23
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 11:12:37 -0800 (PST)
In-Reply-To: <1360349981-27801-11-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 19:59 +0100, Jiri Pirko wrote:
> Current act_police uses rate table computed by the "tc" userspace program,
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
>  net/sched/act_police.c | 119 +++++++++++++++++++++++--------------------------
>  1 file changed, 57 insertions(+), 62 deletions(-)
> 
> diff --git a/net/sched/act_police.c b/net/sched/act_police.c
> index 378a649..8723183 100644
> --- a/net/sched/act_police.c
> +++ b/net/sched/act_police.c
> @@ -26,20 +26,19 @@ struct tcf_police {
>  	struct tcf_common	common;
>  	int			tcfp_result;
>  	u32			tcfp_ewma_rate;
> -	u32			tcfp_burst;
> +	s64			tcfp_burst;
>  	u32			tcfp_mtu;
> -	u32			tcfp_toks;
> -	u32			tcfp_ptoks;
> +	s64			tcfp_toks;
> +	s64			tcfp_ptoks;
>  	psched_time_t		tcfp_t_c;
> -	struct qdisc_rate_table	*tcfp_R_tab;
> -	struct qdisc_rate_table	*tcfp_P_tab;
> +	struct psched_ratecfg	rate;
> +	bool			rate_present;
> +	struct psched_ratecfg	peak;
> +	bool			peak_present;
>  };
>  #define to_police(pc)	\
>  	container_of(pc, struct tcf_police, common)
>  
> -#define L2T(p, L)   qdisc_l2t((p)->tcfp_R_tab, L)
> -#define L2T_P(p, L) qdisc_l2t((p)->tcfp_P_tab, L)
> -
>  #define POL_TAB_MASK     15
>  static struct tcf_common *tcf_police_ht[POL_TAB_MASK + 1];
>  static u32 police_idx_gen;
> @@ -123,10 +122,6 @@ static void tcf_police_destroy(struct tcf_police *p)
>  			write_unlock_bh(&police_lock);
>  			gen_kill_estimator(&p->tcf_bstats,
>  					   &p->tcf_rate_est);
> -			if (p->tcfp_R_tab)
> -				qdisc_put_rtab(p->tcfp_R_tab);
> -			if (p->tcfp_P_tab)
> -				qdisc_put_rtab(p->tcfp_P_tab);
>  			/*
>  			 * gen_estimator est_timer() might access p->tcf_lock
>  			 * or bstats, wait a RCU grace period before freeing p
> @@ -154,7 +149,6 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
>  	struct nlattr *tb[TCA_POLICE_MAX + 1];
>  	struct tc_police *parm;
>  	struct tcf_police *police;
> -	struct qdisc_rate_table *R_tab = NULL, *P_tab = NULL;
>  	int size;
>  
>  	if (nla == NULL)
> @@ -197,21 +191,37 @@ static int tcf_act_police_locate(struct net *net, struct nlattr *nla,
>  	if (bind)
>  		police->tcf_bindcnt = 1;
>  override:
> +	spin_lock_bh(&police->tcf_lock);
> +	police->tcfp_mtu = parm->mtu;
> +	police->rate_present = false;
> +	police->peak_present = false;
>  	if (parm->rate.rate) {
> +		struct qdisc_rate_table *tab;
> +
>  		err = -ENOMEM;
> -		R_tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);
> -		if (R_tab == NULL)
> -			goto failure;
> +		tab = qdisc_get_rtab(&parm->rate, tb[TCA_POLICE_RATE]);

This patch was not tested, it cannot possibly work

spin_lock_bh();
rtab = kmalloc(sizeof(*rtab), GFP_KERNEL);

should crash or complain loudly.
