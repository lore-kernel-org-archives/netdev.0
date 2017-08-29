From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net] sch_htb: fix crash on init failure
Date: Tue, 29 Aug 2017 21:19:05 +0300
Message-ID: <3a6ccb7f-7339-3a24-128e-a858e4fc26fc@cumulusnetworks.com>
References: <1504029487-7085-1-git-send-email-nikolay@cumulusnetworks.com>
 <1504030196.11498.82.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us,
        roopa@cumulusnetworks.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f179.google.com ([209.85.128.179]:36876 "EHLO
        mail-wr0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750822AbdH2STI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 14:19:08 -0400
Received: by mail-wr0-f179.google.com with SMTP id k9so243340wre.4
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 11:19:07 -0700 (PDT)
In-Reply-To: <1504030196.11498.82.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/08/17 21:09, Eric Dumazet wrote:
> On Tue, 2017-08-29 at 20:58 +0300, Nikolay Aleksandrov wrote:
>> The commit below added a call to the ->destroy() callback for all qdiscs
>> which failed in their ->init(), but some were not prepared for such
>> change and can't handle partially initialized qdisc. HTB is one of them
>> and if any error occurs before the qdisc watchdog timer and qdisc work are
>> initialized then we can hit either a null ptr deref (timer->base) when
>> canceling in ->destroy or lockdep error info about trying to register
>> a non-static key and a stack dump. So to fix these two move the watchdog
>> timer and workqueue init before anything that can err out.
>> To reproduce userspace needs to send broken htb qdisc create request,
>> tested with a modified tc (q_htb.c).
> 
>> Note that probably this bug goes further back because the default qdisc
>> handling always calls ->destroy on init failure too.
>>
>> Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>> ---
>> Always calling qdisc destroy on init failure in the default qdisc handling
>> was added in commit 0fbbeb1ba43b. I'm not sure if I should include that
>> one as fixes tag.
> 
> Well, we probably need to audit init/destroy not only in net/sched, but
> other parts of networking stack.
> 

I'm not sure I follow, I hit this while working on a net/sched/ patch and had to error
out in the init() function.

> What about the qdisc_skb_head_init(&q->direct_queue) call ?
> 
> I am surprised you do not crash in __skb_queue_purge(&q->direct_queue);
> 

Hm, do you mean in __qdisc_reset_queue() ? 
I have only tried/seen the crash happen on qdisc add.

A much simpler and easier bug is sch_multiq (ethX non-multiq):
$ tc qdisc add dev ethX root multiq
(error EOPNOTSUPP + double free of ->queues due to free in init())
and e.g. $ ip l add dumdum type dummy
to see a crash due to the corrupted memory.
