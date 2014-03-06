From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/5] net_sched: add replace func in struct
 Qdisc_ops
Date: Thu, 06 Mar 2014 06:55:46 -0800
Message-ID: <1394117746.27473.33.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
	 <1394111321-11192-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:64932 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751169AbaCFOzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 09:55:49 -0500
Received: by mail-pa0-f45.google.com with SMTP id kl14so2749354pab.32
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 06:55:48 -0800 (PST)
In-Reply-To: <1394111321-11192-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-03-06 at 21:08 +0800, Yang Yingliang wrote:
> Add replace func, if NLM_F_REPLACE is set, use replace func.
> Otherwise, use change func.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> ---
>  include/net/sch_generic.h |  1 +
>  net/sched/sch_api.c       | 12 +++++++++---
>  2 files changed, 10 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> index d062f81c692f..ef8a41bcb9a7 100644
> --- a/include/net/sch_generic.h
> +++ b/include/net/sch_generic.h
> @@ -170,6 +170,7 @@ struct Qdisc_ops {
>  	void			(*reset)(struct Qdisc *);
>  	void			(*destroy)(struct Qdisc *);
>  	int			(*change)(struct Qdisc *, struct nlattr *arg);
> +	int			(*replace)(struct Qdisc *, struct nlattr *arg);
>  	void			(*attach)(struct Qdisc *);
>  
>  	int			(*dump)(struct Qdisc *, struct sk_buff *);
> diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> index 961cb0f1bd0c..8f0f8e9d5475 100644
> --- a/net/sched/sch_api.c
> +++ b/net/sched/sch_api.c
> @@ -999,9 +999,15 @@ static int qdisc_change(struct Qdisc *sch, struct nlattr **tca, u16 flags)
>  	int err = 0;
>  
>  	if (tca[TCA_OPTIONS]) {
> -		if (sch->ops->change == NULL)
> -			return -EINVAL;
> -		err = sch->ops->change(sch, tca[TCA_OPTIONS]);
> +		if (flags & NLM_F_REPLACE) {
> +			if (sch->ops->replace == NULL)
> +				return -EINVAL;
> +			err = sch->ops->replace(sch, tca[TCA_OPTIONS]);
> +		} else {
> +			if (sch->ops->change == NULL)
> +				return -EINVAL;
> +			err = sch->ops->change(sch, tca[TCA_OPTIONS]);
> +		}
>  		if (err)
>  			return err;
>  	}

NACK

This breaks existing userland scripts.

Have you tried :

tc qdisc replace dev eth0 root fq
