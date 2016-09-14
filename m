From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Modification to skb->queue_mapping affecting performance
Date: Tue, 13 Sep 2016 17:09:09 -0700
Message-ID: <1473811749.18970.259.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAAmHdhxyrwJXHysUU6KoXeTaRHK8Mxr5PH9j4drR_87T+Wnypg@mail.gmail.com>
         <1473808021.18970.246.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Michael Ma <make0818@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36064 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932160AbcINAJO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 20:09:14 -0400
Received: by mail-pf0-f181.google.com with SMTP id 128so513725pfb.3
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 17:09:14 -0700 (PDT)
In-Reply-To: <CAAmHdhw6JXYtYNjcJchieW-KcwRkNnFmXTRTXrLQS_Kh+rfP2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-09-13 at 16:30 -0700, Michael Ma wrote:

> The RX queue number I found from "ls /sys/class/net/eth0/queues" is
> 64. (is this the correct way of identifying the queue number on NIC?)
> I setup ifb with 24 queues which is equal to the TX queue number of
> eth0 and also the number of CPU cores.

Please do not drop netdev@ from this mail exchange.

ethtool -l eth0

> 
> > There is no qdisc lock contention anymore AFAIK, since each cpu will use
> > a dedicate IFB queue and tasklet.
> >
> How is this achieved? I thought qdisc on ifb will still be protected
> by the qdisc root lock in __dev_xmit_skb() so essentially all threads
> processing qdisc are still serialized without using MQ?

You have to properly setup ifb/mq like in :

# netem based setup, installed at receiver side only
ETH=eth0
IFB=ifb10
#DELAY="delay 100ms"
EST="est 1sec 4sec"
#REORDER=1000us
#LOSS="loss 2.0"
TXQ=24  # change this to number of TX queues on the physical NIC

ip link add $IFB numtxqueues $TXQ type ifb
ip link set dev $IFB up

tc qdisc del dev $ETH ingress 2>/dev/null
tc qdisc add dev $ETH ingress 2>/dev/null

tc filter add dev $ETH parent ffff: \
   protocol ip u32 match u32 0 0 flowid 1:1 \
	action mirred egress redirect dev $IFB

tc qdisc del dev $IFB root 2>/dev/null

tc qdisc add dev $IFB root handle 1: mq
for i in `seq 1 $TXQ`
do
 slot=$( printf %x $(( i )) )
 tc qd add dev $IFB parent 1:$slot $EST netem \
	limit 100000 $DELAY $REORDER $LOSS
done
