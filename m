From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 4/4] net/sched: act_mirred: Implement ingress
 actions
Date: Fri, 23 Sep 2016 18:40:30 +0300
Message-ID: <20160923184030.75124289@halley>
References: <1474550512-7552-1-git-send-email-shmulik.ladkani@gmail.com>
        <1474550512-7552-5-git-send-email-shmulik.ladkani@gmail.com>
        <4387324a-de66-aa1b-86f0-1a9a2f8294f5@mojatatu.com>
        <20160923081106.73fb48df@halley>
        <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36453 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965902AbcIWPkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 11:40:39 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so3401515wma.3
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 08:40:39 -0700 (PDT)
In-Reply-To: <0037729a-a3fc-c1c9-a620-905c73e0b9d4@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 23 Sep 2016 08:48:33 -0400 Jamal Hadi Salim <jhs@mojatatu.com> wrote:
> > Even today, one may create loops using existing 'egress redirect',
> > e.g. this rediculously errorneous construct:
> >
> >  # ip l add v0 type veth peer name v0p
> >  # tc filter add dev v0p parent ffff: basic \
> >     action mirred egress redirect dev v0
> 
> I think we actually recover from this one by eventually
> dropping (theres a ttl field).

[off topic]

Don't know about that :) cpu fan got very noisy, 3 of 4 cores at 100%,
and after one second I got:

# ip -s l show type veth
16: v0p@v0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether a2:64:ff:10:dd:85 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    71660305923 469890864 0       0       0       0       
    TX: bytes  packets  errors  dropped carrier collsns 
    3509       24       0       0       0       0       
17: v0@v0p: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default qlen 1000
    link/ether 52:a2:34:f6:7c:ec brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast   
    3509       24       0       0       0       0       
    TX: bytes  packets  errors  dropped carrier collsns 
    71660713017 469893555 0       0       0       0

> The other question is what to set skb->dev and skb->iif?
> Some information will be lost if you move around netdevs a
> bit.

[back to topic]

Good point.

Similarly to all constructs injecting skbs to device rx (bond/team,
vlan, macvlan, tunnels, ifb, __dev_forward_skb callers, etc..), we are
obligated to assign 'skb2->dev' as the new rx device.

Regarding 'skb2->skb_iif', original act_mirred code already has:

 	skb2->skb_iif = skb->dev->ifindex;   <--- THIS IS ORIG DEV IIF
 	skb2->dev = dev;                     <--- THIS IS TARGET DEV
	err = dev_queue_xmit(skb2);

I'm preserving this; OTOH the suggested modification in the patch is

-	err = dev_queue_xmit(skb2);
+	if (tcf_mirred_act_direction(m->tcfm_eaction) & AT_EGRESS)
+		err = dev_queue_xmit(skb2);
+	else
+		netif_receive_skb(skb2);

now, the call to 'netif_receive_skb' will eventually override skb_iif to
the target RX dev's index, upon entry to __netif_receive_skb_core.

I think this IS the expected behavior - as done by other "rx injection"
constructs.

My doubts were around whether we should call 'dev_forward_skb' instead
of 'netif_receive_skb'.
The former does some things I assumed we're not interested of, like
testing 'is_skb_forwardable' and re-running 'eth_type_trans'.
OTOH, it DOES scrub the skb.
Maybe we should scrub it as well prior the netif_receive_skb call?

Thanks,
Shmulik
