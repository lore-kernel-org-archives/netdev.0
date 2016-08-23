From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 02/15] net: sched: allow qdiscs to handle locking
Date: Tue, 23 Aug 2016 15:32:22 -0700
Message-ID: <57BCCEF6.3090405@gmail.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
 <20160823202320.14368.17683.stgit@john-Precision-Tower-5810>
 <1471986499.14381.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36128 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753548AbcHWWda (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 18:33:30 -0400
Received: by mail-pa0-f66.google.com with SMTP id ez1so10565245pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 15:32:39 -0700 (PDT)
In-Reply-To: <1471986499.14381.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-23 02:08 PM, Eric Dumazet wrote:
> On Tue, 2016-08-23 at 13:23 -0700, John Fastabend wrote:
>> This patch adds a flag for queueing disciplines to indicate the
>> stack does not need to use the qdisc lock to protect operations.
>> This can be used to build lockless scheduling algorithms and
>> improving performance.
>> 

[...]

>> * Heuristic to force contended enqueues to serialize on a *
>> separate lock before trying to get qdisc main lock. @@ -3898,19
>> +3913,22 @@ static void net_tx_action(struct softirq_action *h)
>> 
>> while (head) { struct Qdisc *q = head; -			spinlock_t *root_lock; +
>> spinlock_t *root_lock = NULL;
>> 
>> head = head->next_sched;
>> 
>> -			root_lock = qdisc_lock(q); -			spin_lock(root_lock); +			if
>> (!(q->flags & TCQ_F_NOLOCK)) { +				root_lock = qdisc_lock(q); +
>> spin_lock(root_lock); +			} /* We need to make sure
>> head->next_sched is read * before clearing __QDISC_STATE_SCHED */ 
>> smp_mb__before_atomic(); clear_bit(__QDISC_STATE_SCHED,
>> &q->state); qdisc_run(q); -			spin_unlock(root_lock); +			if
>> (!(q->flags & TCQ_F_NOLOCK))
> 
> This might be faster to use : if (root_lock) (one less memory read
> and mask)
> 

hmm this actually gets factored out in patch 12 but I'll go ahead
and make this change and then I think it reads a bit better through
the series.

>> +				spin_unlock(root_lock); } } } diff --git
>> a/net/sched/sch_generic.c b/net/sched/sch_generic.c index
>> e305a55..af32418 100644 --- a/net/sched/sch_generic.c +++
>> b/net/sched/sch_generic.c @@ -170,7 +170,8 @@ int
>> sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q, int ret =
>> NETDEV_TX_BUSY;
>> 
>> /* And release qdisc */ -	spin_unlock(root_lock); +	if (!(q->flags
>> & TCQ_F_NOLOCK)) +		spin_unlock(root_lock);
> 
> You might use the same trick, if root_lock is NULL for lockless
> qdisc.

So what I just did is pass NULL into sch_direct_xmit() for root_lock
when the qdisc is lockless. This replaces the qdisc flags checks in this
call to checking root_lock.

Seems like a nice cleanup/optimization. I'll wait a bit and then push
it in v2 after giving folks a day or two to review this set.
