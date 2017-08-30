From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net 6/9] sch_fq_codel: avoid double free on init failure
Date: Wed, 30 Aug 2017 10:36:25 -0700
Message-ID: <CAM_iQpUZoQYPnq6z3ofFQ_j4O1f+sSChCkYgv5=_cEXRutZeag@mail.gmail.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com> <1504086545-7777-7-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36784 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751771AbdH3Rgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:36:46 -0400
Received: by mail-pg0-f68.google.com with SMTP id 83so5538706pgb.3
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:36:46 -0700 (PDT)
In-Reply-To: <1504086545-7777-7-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 2:49 AM, Nikolay Aleksandrov
<nikolay@cumulusnetworks.com> wrote:
> It is very unlikely to happen but the backlogs memory allocation
> could fail and will free q->flows, but then ->destroy() will free
> q->flows too. For correctness remove the first free and let ->destroy
> clean up.
>
> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  net/sched/sch_fq_codel.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
> index 337f2d6d81e4..2c0c05f2cc34 100644
> --- a/net/sched/sch_fq_codel.c
> +++ b/net/sched/sch_fq_codel.c
> @@ -491,10 +491,8 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
>                 if (!q->flows)
>                         return -ENOMEM;
>                 q->backlogs = kvzalloc(q->flows_cnt * sizeof(u32), GFP_KERNEL);
> -               if (!q->backlogs) {
> -                       kvfree(q->flows);
> +               if (!q->backlogs)
>                         return -ENOMEM;
> -               }

This is fine. Or we can NULL it after kvfree().

I have no preference here. The only difference here is if we still
expect ->init() to cleanup its own failure.
