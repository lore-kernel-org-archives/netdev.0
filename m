From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v2] net, sched: add clsact qdisc
Date: Tue, 12 Jan 2016 15:46:14 +0100
Message-ID: <569511B6.8010306@iogearbox.net>
References: <61198814638d88ce3555dbecf8ef875523b95743.1452197856.git.daniel@iogearbox.net> <5694F6F0.3020205@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexei.starovoitov@gmail.com,
	john.fastabend@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34082 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965075AbcALOqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 09:46:19 -0500
In-Reply-To: <5694F6F0.3020205@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2016 01:52 PM, Jamal Hadi Salim wrote:
>
> General comment: I like the approach. We can now do direct xmit.
> Means that for hardware offloading we can now avoid the lock (so mqprio
> seems like a very simple consumer of this i.e direct to hardware without
> going to qdisc).
> Even with John's effort to reduce the cost of the lock I think this
> still stands on it own.
>
> More comments below:
>
> On 16-01-07 04:29 PM, Daniel Borkmann wrote:
>> This work adds a generalization of the ingress qdisc as a qdisc holding
>> only classifiers. The clsact qdisc works on ingress, but also on egress.
>> In both cases, it's execution happens without taking the qdisc lock, and
>> the main difference for the egress part compared to prior version of [1]
>> is that this can be applied with _any_ underlying real egress qdisc (also
>> classless ones).
>
> How about rename to "classact" (no space between the two words ;->).

Heh, seems like we're getting better each time with choosing names in tc. :)

Btw, I initially had "clsonly", but then we went with "clsact", I'd like
to avoid yet another renaming as it's already in tree and I think there's
not too much benefit on one over the other (rather noisy patches that would
need to be dealt with).

>> Besides solving the use-case of [1], that is, allowing for more programmability
>> on assigning skb->priority for the mqprio case that is supported by most
>> popular 10G+ NICs, it also opens up a lot more flexibility for other tc
>> applications. The main work on classification can already be done at clsact
>> egress time if the use-case allows and state stored for later retrieval
>> f.e. again in skb->priority with major/minors (which is checked by most
>> classful qdiscs before consulting tc_classify()) and/or in other skb fields
>> like skb->tc_index for some light-weight post-processing to get to the
>> eventual classid in case of a classful qdisc.
>
> I think all skb metadata and even cb[] can be set and handed directly to
> the driver..
>
> Another use case is that
>> the clsact egress part allows to have a central egress counterpart to
>> the ingress classifiers, so that classifiers can easily share state (e.g.
>> in cls_bpf via eBPF maps) for ingress and egress.
>>
>> Currently, default setups like mq + pfifo_fast would require for this to
>> use, for example, prio qdisc instead (to get a tc_classify() run) and to
>> duplicate the egress classifier for each queue. With clsact, it allows
>> for leaving the setup as is, it can additionally assign skb->priority to
>> put the skb in one of pfifo_fast's bands and it can share state with maps.
>> Moreover, we can access the skb's dst entry (f.e. to retrieve tclassid)
>> w/o the need to perform a skb_dst_force() to hold on to it any longer. In
>> lwt case, we can also use this facility to setup dst metadata via cls_bpf
>> (bpf_skb_set_tunnel_key()) without needing a real egress qdisc just for
>> that (case of IFF_NO_QUEUE devices, for example).
>
> For hardware offloading or drivers that dont need packet scheduling then
> IFF_NO_QUEUE seems like the right thing to do.
>
>> The realization can be done without any changes to the scheduler core
>> framework. All it takes is that we have two a-priori defined minors/child
>> classes, where we can mux between ingress and egress classifier list
>> (dev->ingress_cl_list and dev->egress_cl_list, latter stored close to
>> dev->_tx to avoid extra cacheline miss for moderate loads). The egress
>> part is a bit similar modelled to handle_ing() and patched to a noop in
>> case the functionality is not used. Both handlers are now called
>> sch_handle_ingress() and sch_handle_egress(), code sharing among the two
>> doesn't seem practical as there are various minor differences in both
>> paths, so that making them conditional in a single handler would rather
>> slow things down.
>
> I think we need to keep them separate. Over time very likely there'll
> be subtle differences.
> major 0xffff is reserved - so should be free to use different minor ids.
> They were intended to be hooks for different places for plugging in
> qdiscs.

Yeah, agreed, kept them separate.

>> Full compatibility to ingress qdisc is provided as well. Since both
>> piggyback on TC_H_CLSACT, only one of them (ingress/clsact) can exist
>> per netdevice, and thus ingress qdisc specific behaviour can be retained
>> for user space. This means, either a user does 'tc qdisc add dev foo ingress'
>> and configures ingress qdisc as usual, or the 'tc qdisc add dev foo clsact'
>> alternative, where both, ingress and egress classifier can be configured
>> as in the below example. ingress qdisc supports attaching classifier to any
>> minor number whereas clsact has two fixed minors for muxing between the
>> lists, therefore to not break user space setups, they are better done as
>> two separate qdiscs.
>>
>> I decided to extend the sch_ingress module with clsact functionality so
>> that commonly used code can be reused, the module is being aliased with
>> sch_clsact so that it can be auto-loaded properly. Alternative would have been
>> to add a flag when initializing ingress to alter its behaviour plus aliasing
>> to a different name (as it's more than just ingress). However, the first would
>> end up, based on the flag, choosing the new/old behaviour by calling different
>> function implementations to handle each anyway, the latter would require to
>> register ingress qdisc once again under different alias. So, this really begs
>> to provide a minimal, cleaner approach to have Qdisc_ops and Qdisc_class_ops
>> by its own that share callbacks used by both.
>>
>> Example, adding qdisc:
>>
>>     # tc qdisc add dev foo clsact
>>     # tc qdisc show dev foo
>>     qdisc mq 0: root
>
> mq i am assuming is a leftover from something?

Just the leftover default setup for egress, nothing more.

>>     qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>     qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>     qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>     qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
>>     qdisc clsact ffff: parent ffff:fff1
>
> Is there any reason this is not just tc qdisc add dev foo ingress ?
> I doubt things will break..

Actually I already tried to explain that in the commit message, since one can
use any possible minor with ingress qdisc, I would like to have a hard guarantee
that setups suddenly don't break and unexpected things happen even if likelihood
is rather small (but not zero). The option would have been to add a 'mode' setting
over netlink on initialization for ingress and deal with the details in each callback
based on the mode (plus aliasing ingress qdisc to something generic, otherwise why
adding ingress qdisc to add filters to egress? ;)). Eventually, it was more straight
forward and cleaner, imho, to just have their own handlers where they both differ.

>> Adding filters (deleting, etc works analogous by specifying ingress/egress):
>>
>>     # tc filter add dev foo ingress bpf da obj bar.o sec ingress
>>     # tc filter add dev foo egress  bpf da obj bar.o sec egress
>>     # tc filter show dev foo ingress
>
> Yep, as above... I think that is cleaner syntax.
>
>> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
>> ---
>>   v1 -> v2:
>>    - Moved qdisc_pkt_len_init(), thanks Eric!
>>
[...]
>>   static struct static_key netstamp_needed __read_mostly;
>>   #ifdef HAVE_JUMP_LABEL
>>   /* We are not allowed to call static_key_slow_dec() from irq context
>> @@ -3007,7 +3023,6 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
>>       bool contended;
>>       int rc;
>>
>> -    qdisc_pkt_len_init(skb);
>
> That was intentional above?

Yes, as per Eric's previous feedback.

>>       qdisc_calculate_pkt_len(skb, q);
>>       /*
>>        * Heuristic to force contended enqueues to serialize on a
>> @@ -3100,6 +3115,49 @@ int dev_loopback_xmit(struct net *net, struct sock *sk, struct sk_buff *skb)
>>   }
>>   EXPORT_SYMBOL(dev_loopback_xmit);
>>
>> +#ifdef CONFIG_NET_EGRESS
>> +static struct sk_buff *
>> +sch_handle_egress(struct sk_buff *skb, int *ret, struct net_device *dev)
>> +{
>> +    struct tcf_proto *cl = rcu_dereference_bh(dev->egress_cl_list);
>> +    struct tcf_result cl_res;
>> +
>> +    if (!cl)
>> +        return skb;
>> +
>> +    /* skb->tc_verd and qdisc_skb_cb(skb)->pkt_len were already set
>> +     * earlier by the caller.
>> +     */
>> +    qdisc_bstats_cpu_update(cl->q, skb);
>> +
>> +    switch (tc_classify(skb, cl, &cl_res, false)) {
>> +    case TC_ACT_OK:
>> +    case TC_ACT_RECLASSIFY:
>> +        skb->tc_index = TC_H_MIN(cl_res.classid);
>> +        break;
>> +    case TC_ACT_SHOT:
>> +        qdisc_qstats_cpu_drop(cl->q);
>> +        *ret = NET_XMIT_DROP;
>> +        goto drop;
>> +    case TC_ACT_STOLEN:
>> +    case TC_ACT_QUEUED:
>> +        *ret = NET_XMIT_SUCCESS;
>> +drop:
>> +        kfree_skb(skb);
>> +        return NULL;
>> +    case TC_ACT_REDIRECT:
>> +        /* No need to push/pop skb's mac_header here on egress! */
>> +        skb_do_redirect(skb);
>
> Dont understand this part. Why is this not an action? The return code
> for redirect is iirc STOLEN..

Longer time ago, clone-less redirect was added to ingress via 27b29f63058d,
this just adds support for it here as well, so both options are possible.

>> +        *ret = NET_XMIT_SUCCESS;
>> +        return NULL;
>> +    default:
>> +        break;
>> +    }
>> +
>> +    return skb;
>> +}
[...]
>
> You can add my ACK ;-> I would like to run it through some tests before
> netdev11.

Thanks, Jamal!

Cheers,
Daniel
