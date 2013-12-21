From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC Patch net-next] net_sched: make classifying lockless on
 ingress
Date: Fri, 20 Dec 2013 17:09:54 -0800
Message-ID: <52B4EA62.2020603@intel.com>
References: <1387582105-1789-1-git-send-email-xiyou.wangcong@gmail.com> <1387583344.19078.475.camel@edumazet-glaptop2.roam.corp.google.com> <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34807 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3LUBKJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 20:10:09 -0500
In-Reply-To: <CAM_iQpWLTL-PmiNz8k7Kv9KcHsFTennATKgbwQWXX2FN8vdxjg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 3:57 PM, Cong Wang wrote:
> On Fri, Dec 20, 2013 at 3:49 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2013-12-20 at 15:28 -0800, Cong Wang wrote:
>>
>>> diff --git a/net/core/dev.c b/net/core/dev.c
>>> index c482fe8..7cc0d6a 100644
>>> --- a/net/core/dev.c
>>> +++ b/net/core/dev.c
>>> @@ -3382,10 +3382,8 @@ static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
>>>
>>>        q = rxq->qdisc;
>>>        if (q != &noop_qdisc) {
>>> -             spin_lock(qdisc_lock(q));
>>>                if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
>>>                        result = qdisc_enqueue_root(skb, q);
>>> -             spin_unlock(qdisc_lock(q));
>>>        }
>>>
>>
>> Well... That would be too easy.
>>
>> Really, a lot more work would be needed.
>>
>> Qdisc ->enqueue()/dequeue()/reset()/... all assume the qdisc lock is
>> held.
>
> Just push the lock down to ->enqueue() ? Since ingress qdisc is classless
> and its ->dequeue() is nop.
>

huh? You need to make all the classifiers lockless probably via RCU and
then make the actions safe as well. If you want to take a look at what
I started doing its here https://github.com/jrfastab/Linux-Kernel-QOS/ 
complete with a nasty bug in the u32 classifier that I haven't had time
to track down yet. Probably others for that matter.

I have primarily been concerned with xmit qdiscs so far and using mqprio
allows using the skb->priority field for qdisc selection in the
multiqueue nics which has been good enough. I suppose I should _finally_
get around to completing this seeing its come up twice now in a few
weeks and I've been thinking about if for longer than I care to
remember.

.John
