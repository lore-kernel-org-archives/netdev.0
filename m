From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Sun, 25 Sep 2016 18:26:47 +0200
Message-ID: <57E7FAC7.6090904@iogearbox.net>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com> <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com> <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com> <20160923081106.73fb48df@halley> <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com> <20160923184030.75124289@halley> <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
        Florian Westphal <fw@strlen.de>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50971 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939795AbcIYQ0x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 12:26:53 -0400
In-Reply-To: <6d2bd45a-a8a0-846d-5934-5e246522cab8@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2016 03:05 PM, Jamal Hadi Salim wrote:
> On 16-09-23 11:40 AM, Shmulik Ladkani wrote:
>> On Fri, 23 Sep 2016 08:48:33 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>>>> Even today, one may create loops using existing 'egress redirect',
>>>> e.g. this rediculously errorneous construct:
>>>>
>>>>  # ip l add v0 type veth peer name v0p
>>>>  # tc filter add dev v0p parent ffff: basic \
>>>>     action mirred egress redirect dev v0
>>>
>>> I think we actually recover from this one by eventually
>>> dropping (theres a ttl field).
>>
>> [off topic]
>>
>> Don't know about that :) cpu fan got very noisy, 3 of 4 cores at 100%,
>> and after one second I got:
>>
>> # ip -s l show type veth
>> 16: v0p@v0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
>>     link/ether a2:64:ff:10:dd:85 brd ff:ff:ff:ff:ff:ff
>>     RX: bytes  packets  errors  dropped overrun mcast
>>     71660305923 469890864 0       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     3509       24       0       0       0       0
>> 17: v0@v0p: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
>>     link/ether 52:a2:34:f6:7c:ec brd ff:ff:ff:ff:ff:ff
>>     RX: bytes  packets  errors  dropped overrun mcast
>>     3509       24       0       0       0       0
>>     TX: bytes  packets  errors  dropped carrier collsns
>>     71660713017 469893555 0       0       0       0
>>
>
> I think this is still on topic!
>
> Now I realize that code we took out around 4.2.x is still useful
> for such a use case (I wasnt thinking about veth when Florian was
> slimming the skb);
> +Cc Florian W.
>
> This snippet from 4.2:
> -------------
> 3525 static int ing_filter(struct sk_buff *skb, struct netdev_queue *rxq)
> 3526 {
> 3527         struct net_device *dev = skb->dev;
> 3528         u32 ttl = G_TC_RTTL(skb->tc_verd);
> 3529         int result = TC_ACT_OK;
> 3530         struct Qdisc *q;
> 3531
> 3532         if (unlikely(MAX_RED_LOOP < ttl++)) {
> 3533                 net_warn_ratelimited("Redir loop detected Dropping packet (%d->%d)\n",
> 3534                                      skb->skb_iif, dev->ifindex);
> 3535                 return TC_ACT_SHOT;
> 3536         }
> 3537
> 3538         skb->tc_verd = SET_TC_RTTL(skb->tc_verd, ttl);
> 3539         skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
> 3540
> 3541         q = rcu_dereference(rxq->qdisc);
> 3542         if (q != &noop_qdisc) {
> 3543                 spin_lock(qdisc_lock(q));
> 3544                 if (likely(!test_bit(__QDISC_STATE_DEACTIVATED, &q->state)))
> 3545                         result = qdisc_enqueue_root(skb, q);
> 3546                 spin_unlock(qdisc_lock(q));
> 3547         }
> 3548
> 3549         return result;
> 3550 }
> --------------------
>
> MAX_RED_LOOP (stands for "Maximum Redirect loop") still exists in
> current code. The idea above was that we would increment the rttl
> counter  once and if we saw it again upto MAX_RED_LOOP we would assume
> a loop and drop the packet (at the time i didnt think it was wise to
> let the actions be in charge of setting the RTTL; it had to be central
> core code - but it may not be neccessary)
>
> Florian, when we discussed I said it was fine to reclaim those 3 bits
> on tc verdict for RTTL at the time because i had taken out the
> feature and never added it back. Your comment at the time was we can
> add it back when someone shows up with the feature.
> Shmulik is looking to add it.

Why not just reuse xmit_recursion, which is what we did in tc cls_bpf
programs f.e. see __bpf_tx_skb()? Would be a pity to waste 3 bits on
this in the skb.

>> Similarly to all constructs injecting skbs to device rx (bond/team,
>> vlan, macvlan, tunnels, ifb, __dev_forward_skb callers, etc..), we are
>> obligated to assign 'skb2->dev' as the new rx device.
>>
>> Regarding 'skb2->skb_iif', original act_mirred code already has:
>>
>>      skb2->skb_iif = skb->dev->ifindex;   <--- THIS IS ORIG DEV IIF
>>      skb2->dev = dev;                     <--- THIS IS TARGET DEV
>>     err = dev_queue_xmit(skb2);
>>
>> I'm preserving this; OTOH the suggested modification in the patch is
>>
>> -    err = dev_queue_xmit(skb2);
>> +    if (tcf_mirred_act_direction(m->tcfm_eaction) & AT_EGRESS)
>> +        err = dev_queue_xmit(skb2);
>> +    else
>> +        netif_receive_skb(skb2);
>>
>> now, the call to 'netif_receive_skb' will eventually override skb_iif to
>> the target RX dev's index, upon entry to __netif_receive_skb_core.
>>
>> I think this IS the expected behavior - as done by other "rx injection"
>> constructs.
>
> Sounds fine.
> I am wondering if we can have a tracing feature to show the lifetime of
> the packet as it is being cycled around the kernel? It would help
> debugging if some policy misbehaves.
>
>> My doubts were around whether we should call 'dev_forward_skb' instead
>> of 'netif_receive_skb'.
>> The former does some things I assumed we're not interested of, like
>> testing 'is_skb_forwardable' and re-running 'eth_type_trans'.
>> OTOH, it DOES scrub the skb.
>> Maybe we should scrub it as well prior the netif_receive_skb call?
>
> Scrubbing the skb could be a bad idea if it gets rid of global state
> like the RTTL if you add it back.
>
> cheers,
> jamal
>
