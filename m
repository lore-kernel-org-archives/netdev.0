From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net 6/9] sch_fq_codel: avoid double free on init failure
Date: Thu, 31 Aug 2017 00:37:21 +0300
Message-ID: <152fa91b-f2a6-1fa1-f6d6-3a5a8f5db590@cumulusnetworks.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
 <1504086545-7777-7-git-send-email-nikolay@cumulusnetworks.com>
 <CAM_iQpUZoQYPnq6z3ofFQ_j4O1f+sSChCkYgv5=_cEXRutZeag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:38440 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdH3VhY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 17:37:24 -0400
Received: by mail-wm0-f46.google.com with SMTP id 187so9097627wmn.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 14:37:23 -0700 (PDT)
In-Reply-To: <CAM_iQpUZoQYPnq6z3ofFQ_j4O1f+sSChCkYgv5=_cEXRutZeag@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/17 20:36, Cong Wang wrote:
> On Wed, Aug 30, 2017 at 2:49 AM, Nikolay Aleksandrov
> <nikolay@cumulusnetworks.com> wrote:
>> It is very unlikely to happen but the backlogs memory allocation
>> could fail and will free q->flows, but then ->destroy() will free
>> q->flows too. For correctness remove the first free and let ->destroy
>> clean up.
>>
>> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>>  net/sched/sch_fq_codel.c | 4 +---
>>  1 file changed, 1 insertion(+), 3 deletions(-)
>>
>> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
>> index 337f2d6d81e4..2c0c05f2cc34 100644
>> --- a/net/sched/sch_fq_codel.c
>> +++ b/net/sched/sch_fq_codel.c
>> @@ -491,10 +491,8 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
>>                 if (!q->flows)
>>                         return -ENOMEM;
>>                 q->backlogs = kvzalloc(q->flows_cnt * sizeof(u32), GFP_KERNEL);
>> -               if (!q->backlogs) {
>> -                       kvfree(q->flows);
>> +               if (!q->backlogs)
>>                         return -ENOMEM;
>> -               }
> 
> This is fine. Or we can NULL it after kvfree().
> 
> I have no preference here. The only difference here is if we still
> expect ->init() to cleanup its own failure.
> 

We don't, that's the point of the changes that lead to these fixes,
the way ->destroy() is used by both the default qdisc infra and the
normal qdisc add suggest that it should clean up after ->init failure,
thus the change.
