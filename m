From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net/sched: reset block pointer in tcf_block_put()
Date: Fri, 11 Aug 2017 14:38:59 -0700
Message-ID: <CAM_iQpUJRAn75aBrBzoWABt21tgTYLo1MPNQwTUa9BSs0QXyaQ@mail.gmail.com>
References: <150235751251.493255.14955523507789154918.stgit@buzz>
 <CAM_iQpX=XLheuuBk_kAa+jHO-e16hnzavHhzHJ4EYWwpjGFzMg@mail.gmail.com> <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Jiri Pirko <jiri@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35184 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753401AbdHKVjU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 17:39:20 -0400
Received: by mail-pf0-f193.google.com with SMTP id j68so4433538pfc.2
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 14:39:20 -0700 (PDT)
In-Reply-To: <ad81a570-dff5-7c74-170e-70e764778cba@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 11, 2017 at 1:36 PM, Konstantin Khlebnikov
<khlebnikov@yandex-team.ru> wrote:
>
>
> On 11.08.2017 23:18, Cong Wang wrote:
>>
>> On Thu, Aug 10, 2017 at 2:31 AM, Konstantin Khlebnikov
>> <khlebnikov@yandex-team.ru> wrote:
>>>
>>> In previous API tcf_destroy_chain() could be called several times and
>>> some schedulers like hfsc and atm use that. In new API tcf_block_put()
>>> frees block but leaves stale pointer, second call will free it once
>>> again.
>>
>>
>> Which call path do we call tcf_block_put() for multiple times on
>> the same block? Please be specific, it is not obvious.
>>
>
> For example in hfsc_destroy_qdisc() since
> a4aebb83cf0da0363684f1c339f7e6149a3e74c1
> second time in hfsc_destroy_class() called from it.
>
> Actually, I see the same pattern in all classy qdiscs.

Good find! But that means we can just move it up??
Something like (PoC only, not even compile):

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index b52f74610dc7..c7db8060e8ef 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1099,7 +1099,6 @@ hfsc_destroy_class(struct Qdisc *sch, struct
hfsc_class *cl)
 {
        struct hfsc_sched *q = qdisc_priv(sch);

-       tcf_block_put(cl->block);
        qdisc_destroy(cl->qdisc);
        gen_kill_estimator(&cl->rate_est);
        if (cl != &q->root)
@@ -1243,8 +1242,10 @@ hfsc_put_class(struct Qdisc *sch, unsigned long arg)
 {
        struct hfsc_class *cl = (struct hfsc_class *)arg;

-       if (--cl->refcnt == 0)
+       if (--cl->refcnt == 0) {
+               tcf_block_put(cl->block);
                hfsc_destroy_class(sch, cl);
+       }
 }

 static unsigned long
