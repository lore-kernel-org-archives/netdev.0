From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [Patch net-next] net_sched: refactor out tcf_exts
Date: Sun, 05 Oct 2014 18:47:13 -0700
Message-ID: <5431F4A1.3040107@gmail.com>
References: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:52072 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:47:27 -0400
Received: by mail-oi0-f52.google.com with SMTP id a3so2948697oib.25
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 18:47:27 -0700 (PDT)
In-Reply-To: <1412376709-25564-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2014 03:51 PM, Cong Wang wrote:
> As Jamal pointed it out, tcf_exts is really unnecessary,
> we can definitely refactor it out without losing any functionality.
> This could also remove an indirect layer which makes the code
> much easier to read.
>
> This patch:
>
> 1) moves exts->action and exts->police into tp->ops, since they
> are statically assigned
>
> 2) moves exts->actions list head out
>
> 3) removes exts->type, act->type does the same thing
>
> 4) renames tcf_exts_*() functions to tcf_act_*()
>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.r.fastabend@intel.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---

Looks OK to me and removes a layer of abstraction without changing
the code much. This is going to conflict with my series so I'll hold
off resubmitting it until this is dealt with. I need to respin that
ematch fix up to drop the ingress lock.

Acked-by: John Fastabend <john.r.fastabend@intel.com>

[...]

>
> -void tcf_exts_change(struct tcf_proto *tp, struct tcf_exts *dst,
> -		     struct tcf_exts *src)
> +void tcf_act_change(struct tcf_proto *tp, struct list_head *dst,
> +		    struct list_head *src)
>   {
>   #ifdef CONFIG_NET_CLS_ACT
>   	LIST_HEAD(tmp);
>   	tcf_tree_lock(tp);
> -	list_splice_init(&dst->actions, &tmp);
> -	list_splice(&src->actions, &dst->actions);
> +	list_splice_init(dst, &tmp);
> +	list_splice(src, dst);
>   	tcf_tree_unlock(tp);
>   	tcf_action_destroy(&tmp, TCA_ACT_UNBIND);


This is overly complex now that tcf_act_change only
occurs on null lists. And unattached ones because of the
RCU semantics so I'm fairly sure we can drop the lock and
double splice.


[...]

-- 
John Fastabend         Intel Corporation
