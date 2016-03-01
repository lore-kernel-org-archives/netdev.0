From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: net-next build failure due to 16e5cc64?
Date: Tue, 1 Mar 2016 10:16:02 -0800
Message-ID: <CAM_iQpXZ-ReWS7sXU3EHqKGvkrOjNyMt097ts1AfWK36Q210ZQ@mail.gmail.com>
References: <20160301174233.GO16369@oracle.com>
	<CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	john fastabend <john.fastabend@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f176.google.com ([209.85.161.176]:35461 "EHLO
	mail-yw0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750813AbcCASQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 13:16:03 -0500
Received: by mail-yw0-f176.google.com with SMTP id g127so156023320ywf.2
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 10:16:02 -0800 (PST)
In-Reply-To: <CAM_iQpU8WNCi3GEW0isLsMDWOwzFVkHmDmnqzueLOf7K6P=mAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2016 at 10:13 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Tue, Mar 1, 2016 at 9:42 AM, Sowmini Varadhan
> <sowmini.varadhan@oracle.com> wrote:
>>
>> John,
>>
>> I'm getting a failure when I try to build the latest net-next. I see
>>
>> net/sched/sch_mqprio.c: In function `mqprio_init':
>> net/sched/sch_mqprio.c:145: error: unknown field `tc' specified in initializer
>> net/sched/sch_mqprio.c:145: warning: missing braces around initializer
>> net/sched/sch_mqprio.c:145: warning: (near initialization for `tc.<anonymous>')
>> make[2]: *** [net/sched/sch_mqprio.o] Error 1
>>
>> I'm not sure why this wasn't noticed before, but in case this is due to my
>> compiler version:
>>    # gcc --version
>>    gcc (GCC) 4.4.7 20120313 (Red Hat 4.4.7-16)
>>    Copyright (C) 2010 Free Software Foundation, Inc.
>>
>> I'm finding that the minimum fix to avoid this error should be something like
>>
>
> Why not just initialize these fields explicitly? For example,
>
> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> index f9947d1..19323b6 100644
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -28,7 +28,7 @@ static void mqprio_destroy(struct Qdisc *sch)
>  {
>         struct net_device *dev = qdisc_dev(sch);
>         struct mqprio_sched *priv = qdisc_priv(sch);
> -       struct tc_to_netdev tc = {.type = TC_SETUP_MQPRIO};
> +       struct tc_to_netdev tc;
>         unsigned int ntx;
>
>         if (priv->qdiscs) {
> @@ -39,6 +39,7 @@ static void mqprio_destroy(struct Qdisc *sch)
>                 kfree(priv->qdiscs);
>         }
>
> +       tc.type = TC_SETUP_MQPRIO;

And also set the rest to zero...

>         if (priv->hw_owned && dev->netdev_ops->ndo_setup_tc)
>                 dev->netdev_ops->ndo_setup_tc(dev, sch->handle, 0, &tc);
>         else
