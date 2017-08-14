From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Mon, 14 Aug 2017 15:59:58 +0300
Message-ID: <7267faab-c089-e60b-0696-3734f801c1ba@yandex-team.ru>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com>
 <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru>
 <CAM_iQpUJRAn75aBrBzoWABt21tgTYLo1MPNQwTUa9BSs0QXyaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1j.cmail.yandex.net ([5.255.227.106]:49818 "EHLO
        forwardcorp1j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753109AbdHNNAB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 09:00:01 -0400
In-Reply-To: <CAM_iQpUJRAn75aBrBzoWABt21tgTYLo1MPNQwTUa9BSs0QXyaQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12.08.2017 00:38, Cong Wang wrote:
> On Fri, Aug 11, 2017 at 1:36 PM, Konstantin Khlebnikov
> <khlebnikov@yandex-team.ru> wrote:
>>
>>
>> On 11.08.2017 23:18, Cong Wang wrote:
>>>
>>> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
>>> <khlebnikov@yandex-team.ru> wrote:
>>>>
>>>> In previous API tcf_destroy_chain() could be called several times and
>>>> some schedulers like hfsc and atm use that. In new API tcf_block_put()
>>>> frees block but leaves stale pointer, second call will free it once
>>>> again.
>>>
>>>
>>> Which call path do we call tcf_block_put() for multiple times on
>>> the same block? Please be specific, it is not obvious.
>>>
>>
>> For example in hfsc_destroy_qdisc() since
>> a4aebb83cf0da0363684f1c339f7e6149a3e74c1
>> second time in hfsc_destroy_class() called from it.
>>
>> Actually, I see the same pattern in all classy qdiscs.
> 
> Good find! But that means we can just move it up??
> Something like (PoC only, not even compile):

This should work, I suppose.

But this approach requires careful review for all qdisc, mine is completely mechanical.

> 
> diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> index b52f74610dc7..c7db8060e8ef 100644
> --- a/net/sched/sch_hfsc.c
> +++ b/net/sched/sch_hfsc.c
> @@ -1099,7 +1099,6 @@ hfsc_destroy_class(struct Qdisc *sch, struct
> hfsc_class *cl)
>   {
>          struct hfsc_sched *q = qdisc_priv(sch);
> 
> -       tcf_block_put(cl->block);
>          qdisc_destroy(cl->qdisc);
>          gen_kill_estimator(&cl->rate_est);
>          if (cl != &q->root)
> @@ -1243,8 +1242,10 @@ hfsc_put_class(struct Qdisc *sch, unsigned long arg)
>   {
>          struct hfsc_class *cl = (struct hfsc_class *)arg;
> 
> -       if (--cl->refcnt == 0)
> +       if (--cl->refcnt == 0) {
> +               tcf_block_put(cl->block);
>                  hfsc_destroy_class(sch, cl);
> +       }
>   }
> 
>   static unsigned long
> 
