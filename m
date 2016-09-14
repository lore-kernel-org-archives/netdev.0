From: Michael Ma <make0818@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 17:23:17 -0700
Message-ID: <CAAmHdhy_=GJKBE9=YD2n8MZOaBzD_JJrk4i8Rq43ob2HbWqbCA@mail.gmail.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
 <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com> <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f54.google.com ([209.85.214.54]:37050 "EHLO
        mail-it0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932550AbcINAXT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 20:23:19 -0400
Received: by mail-it0-f54.google.com with SMTP id 186so1241163itf.0
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 17:23:18 -0700 (PDT)
In-Reply-To: <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-09-13 17:09 GMT-07:00 Eric Dumazet <eric.dumazet@gmail.com>:
> On Tue, 2016-09-13 at 16:30 -0700, Michael Ma wrote:
>
>> The RX queue number I found from "ls /sys/class/net/eth0/queues" is
>> 64. (is this the correct way of identifying the queue number on NIC?)
>> I setup ifb with 24 queues which is equal to the TX queue number of
>> eth0 and also the number of CPU cores.
>
> Please do not drop netdev@ from this mail exchange.

Sorry that I accidentally dropped that.
>
> ethtool -l eth0
>
>>
>> > There is no qdisc lock contention anymore AFAIK, since each cpu will use
>> > a dedicate IFB queue and tasklet.
>> >
>> How is this achieved? I thought qdisc on ifb will still be protected
>> by the qdisc root lock in __dev_xmit_skb() so essentially all threads
>> processing qdisc are still serialized without using MQ?
>
> You have to properly setup ifb/mq like in :
>
> # netem based setup, installed at receiver side only
> ETH=eth0
> IFB=ifb10
> #DELAY="delay 100ms"
> EST="est 1sec 4sec"
> #REORDER=1000us
> #LOSS="loss 2.0"
> TXQ=24  # change this to number of TX queues on the physical NIC
>
> ip link add $IFB numtxqueues $TXQ type ifb
> ip link set dev $IFB up
>
> tc qdisc del dev $ETH ingress 2>/dev/null
> tc qdisc add dev $ETH ingress 2>/dev/null
>
> tc filter add dev $ETH parent ffff: \
>    protocol ip u32 match u32 0 0 flowid 1:1 \
>         action mirred egress redirect dev $IFB
>
> tc qdisc del dev $IFB root 2>/dev/null
>
> tc qdisc add dev $IFB root handle 1: mq
> for i in `seq 1 $TXQ`
> do
>  slot=$( printf %x $(( i )) )
>  tc qd add dev $IFB parent 1:$slot $EST netem \
>         limit 100000 $DELAY $REORDER $LOSS
> done
>
>
If I understand correctly this is still to associate a qdisc with each
ifb TXQ. How should I do this if I want to use HTB? I guess I'll need
to divide the bandwidth of each class in HTB by the number of TX
queues for each individual HTB qdisc associated?

My original idea was to attach a HTB qdisc for each ifb queue
representing a set of flows not sharing bandwidth with others so that
root lock contention still happens but only affects flows in the same
HTB. Did I understand the root lock contention issue incorrectly for
ifb? I do see some comments in __dev_queue_xmit() about using a
different code path for software devices which bypasses
__dev_xmit_skb(). Does this mean ifb won't go through
__dev_xmit_skb()?
