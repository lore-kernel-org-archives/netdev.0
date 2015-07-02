From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next 6/6] net_sched: act: remove spinlock in fast
 path
Date: Thu, 02 Jul 2015 09:35:25 -0700
Message-ID: <5595684D.90500@gmail.com>
References: <1435842455-30501-1-git-send-email-edumazet@google.com> <1435842455-30501-7-git-send-email-edumazet@google.com>
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
Received: from mail-oi0-f48.google.com ([209.85.218.48]:33648 "EHLO
	mail-oi0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753834AbbGBQfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2015 12:35:31 -0400
Received: by oiyy130 with SMTP id y130so60043721oiy.0
        for <netdev@vger.kernel.org>; Thu, 02 Jul 2015 09:35:31 -0700 (PDT)
In-Reply-To: <1435842455-30501-7-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15-07-02 06:07 AM, Eric Dumazet wrote:
> Final step for gact RCU operation :
> 
> 1) Use percpu stats
> 2) update lastuse only every clock tick
> 3) Remove spinlock acquisition, as it is no longer needed.
> 
> Since this is the last contended lock in packet RX when tc gact is used,
> this gives impressive gain.
> 
> My host with 8 RX queues was handling 5 Mpps before the patch,
> and more than 10 Mpps after patch.
> 
> Tested:
> 
> On receiver :
> IP=ip
> TC=tc
> dev=eth0
> 
> $TC qdisc del dev $dev ingress 2>/dev/null
> $TC qdisc add dev $dev ingress
> $TC filter del dev $dev root pref 10 2>/dev/null
> $TC filter del dev $dev pref 10 2>/dev/null
> tc filter add dev $dev est 1sec 4sec parent ffff: protocol ip prio 1 \
> 	u32 match ip src 7.0.0.0/8 flowid 1:15 action drop
> 
> Sender sends packets flood from 7/8 network
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Alexei Starovoitov <ast@plumgrid.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> ---
>  net/sched/act_gact.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)

[...]

> @@ -121,9 +121,8 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
>  		    struct tcf_result *res)
>  {
>  	struct tcf_gact *gact = a->priv;
> -	int action = gact->tcf_action;
> +	int action = READ_ONCE(gact->tcf_action);
>  
> -	spin_lock(&gact->tcf_lock);
>  #ifdef CONFIG_GACT_PROB
>  	{
>  	u32 ptype = READ_ONCE(gact->tcfg_ptype);
> @@ -132,12 +131,11 @@ static int tcf_gact(struct sk_buff *skb, const struct tc_action *a,
>  		action = gact_rand[ptype](gact);
>  	}
>  #endif
> -	gact->tcf_bstats.bytes += qdisc_pkt_len(skb);
> -	gact->tcf_bstats.packets++;
> +	bstats_cpu_update(this_cpu_ptr(gact->common.cpu_bstats), skb);
>  	if (action == TC_ACT_SHOT)
> -		gact->tcf_qstats.drops++;
> -	gact->tcf_tm.lastuse = jiffies;
> -	spin_unlock(&gact->tcf_lock);
> +		qstats_drop_inc(this_cpu_ptr(gact->common.cpu_qstats));
> +	if (gact->tcf_tm.lastuse != jiffies)
> +		gact->tcf_tm.lastuse = jiffies;

I'm missing the point of the if block. Is that really good enough
for the 32bit system case? I would have expected some wrapper to
handle it here something like u64_stats_() maybe _u64_jiffies(). Maybe
after a coffee I'll make sense of it.

>  
>  	return action;
>  }
> 
