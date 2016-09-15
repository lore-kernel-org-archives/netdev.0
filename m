From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3 net 1/1] net sched actions: fix GETing actions
Date: Thu, 15 Sep 2016 15:15:58 +0300
Message-ID: <8bd6eb1d-6fa6-7cbb-b42a-d1444ad5a989@cogentembedded.com>
References: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:34815 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764687AbcIOMQF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:16:05 -0400
Received: by mail-lf0-f53.google.com with SMTP id u14so32959965lfd.1
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 05:16:04 -0700 (PDT)
In-Reply-To: <1473721658-6034-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/13/2016 2:07 AM, Jamal Hadi Salim wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> With the batch changes that translated transient actions into
> a temporary list lost in the translation was the fact that
> tcf_action_destroy() will eventually delete the action from
> the permanent location if the refcount is zero.
>
> Example of what broke:
> ...add a gact action to drop
> sudo $TC actions add action drop index 10
> ...now retrieve it, looks good
> sudo $TC actions get action gact index 10
> ...retrieve it again and find it is gone!
> sudo $TC actions get action gact index 10
>
> Fixes:
> commit 22dc13c837c3 ("net_sched: convert tcf_exts from list to pointer array"),
> commit 824a7e8863b3 ("net_sched: remove an unnecessary list_del()")
> commit f07fed82ad79 ("net_sched: remove the leftover cleanup_a()")
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  net/sched/act_api.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
>
> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
> index d09d068..50720b1 100644
> --- a/net/sched/act_api.c
> +++ b/net/sched/act_api.c
> @@ -592,6 +592,16 @@ err_out:
>  	return ERR_PTR(err);
>  }
>
> +static void cleanup_a(struct list_head *actions, int ovr)
> +{
> +	struct tc_action *a;
> +
> +	list_for_each_entry(a, actions, list) {
> +		if (ovr)
> +			a->tcfa_refcnt -= 1;

			a->tcfa_refcnt--;

[...]
> @@ -612,8 +622,15 @@ int tcf_action_init(struct net *net, struct nlattr *nla,
>  			goto err;
>  		}
>  		act->order = i;
> +		if (ovr)
> +			act->tcfa_refcnt += 1;

			act->tcfa_refcnt++;

[...]
> @@ -883,6 +900,8 @@ tca_action_gd(struct net *net, struct nlattr *nla, struct nlmsghdr *n,
>  			goto err;
>  		}
>  		act->order = i;
> +		if (event == RTM_GETACTION)
> +			act->tcfa_refcnt += 1;

		act->tcfa_refcnt++;

[...]

MBR, Sergei
