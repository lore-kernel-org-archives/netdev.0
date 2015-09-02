From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 1/4] net: qdisc: add op to run filters/actions
 before enqueue
Date: Wed, 2 Sep 2015 16:29:17 -0400
Message-ID: <55E75C1D.8020006@mojatatu.com>
References: <cover.1441123709.git.daniel@iogearbox.net>
 <a18f0baba2668f0bbc15a45036713dcaa4bb09b0.1441123709.git.daniel@iogearbox.net>
 <CAHA+R7O-EAnGL1hhb_WtXXw1-Rj4kiFUqFkDkZe2SKWB-7Otrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	john fastabend <john.fastabend@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	netdev <netdev@vger.kernel.org>,
	John Fastabend <john.r.fastabend@intel.com>
To: Cong Wang <cwang@twopensource.com>,
	Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:37436 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756025AbbIBU3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:29:25 -0400
Received: by igbni9 with SMTP id ni9so23735806igb.0
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:29:24 -0700 (PDT)
In-Reply-To: <CAHA+R7O-EAnGL1hhb_WtXXw1-Rj4kiFUqFkDkZe2SKWB-7Otrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/15 02:22, Cong Wang wrote:
> (Why not Cc'ing Jamal for net_sched pathes?)
>
> On Tue, Sep 1, 2015 at 9:34 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>> From: John Fastabend <john.r.fastabend@intel.com>
>>
>> Add a new ->preclassify() op to allow multiqueue queuing disciplines
>> to call tc_classify() or perform other work before dev_pick_tx().
>>
>> This helps, for example, with mqprio queueing discipline that has
>> offload support by most popular 10G NICs, where the txq effectively
>> picks the qdisc.
>>
>> Once traffic is being directed to a specific queue then hardware TX
>> rings may be tuned to support this traffic type. mqprio already
>> gives the ability to do this via skb->priority where the ->preclassify()
>> provides more control over packet steering, it can classify the skb
>> and set the priority, for example, from an eBPF classifier (or action).
>>
>> Also this allows traffic classifiers to be run without holding the
>> qdisc lock and gives one place to attach filters when mqprio is
>> in use. ->preclassify() could also be added to other mq qdiscs later
>> on: f.e. most classful qdiscs first check major/minor numbers of
>> skb->priority before actually consulting a more complex classifier.
>>
>> For mqprio case today, a filter has to be attached to each txq qdisc
>> to have all traffic hit the filter. Since ->preclassify() is currently
>> only used by mqprio, the __dev_queue_xmit() fast path is guarded by
>> a generic, hidden Kconfig option (NET_CLS_PRECLASSIFY) that is only
>> selected by mqprio, otherwise it defaults to off. Also, the Qdisc
>> structure size will stay the same, we move __parent, used by cbq only
>> into a write-mostly hole. If actions are enabled, __parent is written
>> on every enqueue, and only read, rewritten in reshape_fail() phase.
>> Therefore, this place in the read-mostly cacheline could be used by
>> preclassify, which is written only once.
>>
>
> I don't like this approach. Ideally, qdisc layer should be totally
> on top of tx queues, which means tx queue selection should
> happen after dequeue. I looked at this before, the change is not
> trivial at all given the fact that qdisc ties too much with tx queue
> probably due to historical reasons, especially the tx softirq part.
> But that is really a long-term solution for me.
>
> I have no big objection for this as a short-term solution, however,
> once we add these filters before enqueue, we can't remove them
> any more. We really need to think twice about it.
>
> Jamal, do you have any better idea?
>

Sorry for the top quote:
Given the rcu-fication of classifiers i believe the idea will
mostly work; expect user will go nuts sticking all kinds of
classifiers and actions that wont work (example, I dont think
connmark action would work nicely here).
Could we strive to do proper offload ala switchdev?

The comment on the patch on reshape_fail + __parent: for the
record, that is an extremely useful feature (allows an inner qdisc
to provide an opportunity for a classful parent qdisc to
reclassify and therefore reschedule).
Yes, CBQ is the only user - but maybe if it was properly documented
more schedulers could put it to good use.

cheers,
jamal
