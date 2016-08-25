From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: Re: [PATCH net] qdisc: fix a module refcount leak in
 qdisc_create_dflt()
Date: Thu, 25 Aug 2016 21:26:59 +0800
Message-ID: <ef703076-2e2c-3373-53b1-99ba5df2c2d5@gmail.com>
References: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        John Fastabend <john.fastabend@gmail.com>,
        stephen hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36606 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754563AbcHYNlW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 09:41:22 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so3156824pab.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 06:41:01 -0700 (PDT)
In-Reply-To: <1472056742.14381.93.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2016 12:39 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Should qdisc_alloc() fail, we must release the module refcount
> we got right before.
>
> Fixes: 6da7c8fcbcbd ("qdisc: allow setting default queuing discipline")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/sched/sch_generic.c |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> index e95b67cd5718..657c13362b19 100644
> --- a/net/sched/sch_generic.c
> +++ b/net/sched/sch_generic.c
> @@ -643,18 +643,19 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
>  	struct Qdisc *sch;
>  
>  	if (!try_module_get(ops->owner))
> -		goto errout;
> +		return NULL;
>  
>  	sch = qdisc_alloc(dev_queue, ops);
> -	if (IS_ERR(sch))
> -		goto errout;
> +	if (IS_ERR(sch)) {
> +		module_put(ops->owner);
> +		return NULL;
> +	}
>  	sch->parent = parentid;
>  
>  	if (!ops->init || ops->init(sch, NULL) == 0)
>  		return sch;
>  
>  	qdisc_destroy(sch);

ops->init() failed, missing module_put() here.


> -errout:
>  	return NULL;
>  }
>  EXPORT_SYMBOL(qdisc_create_dflt);
>
>
> .
>
