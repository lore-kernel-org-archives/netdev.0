From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 5/6] net_sched: act: read tcfg_ptype once
Date: Thu, 02 Jul 2015 08:47:16 -0700
Message-ID: <55955D04.702@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Eric Dumazet <edumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:35951 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751772AbbGBPr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 11:47:27 -0400
Received: by obdbs4 with SMTP id bs4so52351444obd.3
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 08:47:25 -0700 (PDT)
In-Reply-To: <1435842455-30501-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> Third step for gact RCU operation :
> 
> Following patch will get rid of spinlock protection,
> so we need to read tcfg_ptype once.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---
>  net/sched/act_gact.c | 14 +++++++-------
>  1 file changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
> index e968290e8378..7c7e72e95943 100644
> --- a/net/sched/act_gact.c
> +++ b/net/sched/act_gact.c
> @@ -121,16 +121,16 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
>  		    struct tcf_result *res)
>  {
>  	struct tcf_gact *gact = a->priv;
> -	int action = TC_ACT_SHOT;
> +	int action = gact->tcf_action;
>  
>  	spin_lock(&gact->tcf_lock);
>  #ifdef CONFIG_GACT_PROB
> -	if (gact->tcfg_ptype)
> -		action = gact_rand[gact->tcfg_ptype](gact);
> -	else
> -		action = gact->tcf_action;
> -#else
> -	action = gact->tcf_action;
> +	{
> +	u32 ptype = READ_ONCE(gact->tcfg_ptype);
> +
> +	if (ptype)
> +		action = gact_rand[ptype](gact);
> +	}
>  #endif
>  	gact->tcf_bstats.bytes += qdisc_pkt_len(skb);
>  	gact->tcf_bstats.packets++;
> 

Acked-by: John Fastabend <john.r.fastabend@intel.com>
