From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/2] net sched act_vlan: Change stats update to
 use per-core stats
Date: Wed, 11 Oct 2017 08:27:40 -0400
Message-ID: <d79cf8b2-4c67-1101-0405-afec1e9f89c7@mojatatu.com>
References: <1507689147-22941-1-git-send-email-manish.kurup@verizon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: aring@mojatatu.com, mrv@mojatatu.com, manish.kurup@verizon.com
To: Manish Kurup <kurup.manish@gmail.com>, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35248 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdJKM1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 08:27:43 -0400
Received: by mail-io0-f196.google.com with SMTP id i38so1146835iod.2
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 05:27:43 -0700 (PDT)
In-Reply-To: <1507689147-22941-1-git-send-email-manish.kurup@verizon.com>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

minus lk

On 17-10-10 10:32 PM, Manish Kurup wrote:
> The VLAN action maintains one set of stats across all cores, and uses a
> spinlock to synchronize updates to it from the same. Changed this to use a
> per-CPU stats context instead.
> This change will result in better performance.
> 
> Signed-off-by: Manish Kurup <manish.kurup@verizon.com>
> ---
>   net/sched/act_vlan.c | 10 ++++++----
>   1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sched/act_vlan.c b/net/sched/act_vlan.c
> index 16eb067..14c262c 100644
> --- a/net/sched/act_vlan.c
> +++ b/net/sched/act_vlan.c
> @@ -30,9 +30,10 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>   	int err;
>   	u16 tci;
>   
> -	spin_lock(&v->tcf_lock);
>   	tcf_lastuse_update(&v->tcf_tm);
> -	bstats_update(&v->tcf_bstats, skb);
> +	bstats_cpu_update(this_cpu_ptr(v->common.cpu_bstats), skb);
> +
> +	spin_lock(&v->tcf_lock);
>   	action = v->tcf_action;
>   
>   	/* Ensure 'data' points at mac_header prior calling vlan manipulating
> @@ -85,7 +86,8 @@ static int tcf_vlan(struct sk_buff *skb, const struct tc_action *a,
>   
>   drop:
>   	action = TC_ACT_SHOT;
> -	v->tcf_qstats.drops++;
> +	qstats_drop_inc(this_cpu_ptr(v->common.cpu_qstats));
> +
>   unlock:
>   	if (skb_at_tc_ingress(skb))
>   		skb_pull_rcsum(skb, skb->mac_len);
> @@ -172,7 +174,7 @@ static int tcf_vlan_init(struct net *net, struct nlattr *nla,
>   
>   	if (!exists) {
>   		ret = tcf_idr_create(tn, parm->index, est, a,
> -				     &act_vlan_ops, bind, false);
> +						&act_vlan_ops, bind, true);
>

Indentation mismatch here?

Otherwise looks good to me.

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

cheers,
jamal
