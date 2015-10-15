From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/4] net_sched: update hierarchical backlog too
Date: Wed, 14 Oct 2015 21:32:06 -0700
Message-ID: <CAM_iQpWmxhY9Y9PU+9kYYvoc2C07aTxMPxSny1pW+cVYu4TqGQ@mail.gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-3-git-send-email-xiyou.wangcong@gmail.com>
	<561E4663.4080101@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:32934 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbbJOEcI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 00:32:08 -0400
Received: by obbwb3 with SMTP id wb3so29626430obb.0
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 21:32:06 -0700 (PDT)
In-Reply-To: <561E4663.4080101@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 14, 2015 at 5:11 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> On 10/12/15 14:38, Cong Wang wrote:
>>
>> When the bottom qdisc decides to, for example, drop some packet,
>> it calls qdisc_tree_decrease_qlen() to update the queue length
>> for all its ancestors, we need to update the backlog too to
>> keep the stats on root qdisc accurate.
>>
>
>
> There is more than one change in there (the codel change seems
> out of place and i wasnt sure why it was needed).

I thought it is clear that when codel decides to drop some packets
we don't know how many bytes it drops, we only know how many
packets before my patch. For example,

-               qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
+               qdisc_tree_reduce_backlog(sch, q->cstats.drop_count,
+                                         q->cstats.drop_len);

This clearly means I need some codel stats from codel to pass to
qdisc_tree_reduce_backlog(), this is  why the codel part is
necessary.


> Also it seems possible you are double-dipping in some cases;
> i dont have time to scrutinize - but looking at codel_change() change
> when the queue limit is exceeded you will end up affecting backlog from
> both qdisc_qstats_backlog_dec() and your new
> qdisc_tree_reduce_backlog()

Nope, qdisc_qstats_backlog_dec() decreases the backlog of itself,
qdisc_tree_reduce_backlog() decreases its upper qdiscs'. It is correct
as it was.

Thanks.
