From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 16:10:27 +0100
Message-ID: <4AFC2563.1020902@trash.net>
References: <4AFA8911.7050204@gmail.com> <4AFADF64.8070601@trash.net> <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59345 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752750AbZKLPHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 10:07:03 -0500
In-Reply-To: <412e6f7f0911111912q27f2b0aate56c637349292c3f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> On Wed, Nov 11, 2009 at 11:59 PM, Patrick McHardy <kaber@trash.net> wrote:
>>> +static int numtxqs = 1;
>>> +module_param(numtxqs, int, 0444);
>>> +MODULE_PARM_DESC(numtxqs, "Number of TX queues per ifb");
>> unsigned?
> 
> Yea, unsigned is better, and I need to check whether its value is
> smaller than 1 somewhere. The same will be done with IFLA_NTXQ.

Good point.

>>> +                     rcu_read_lock();
>>> +                     skb->dev = dev_get_by_index_rcu(&init_net, skb->iif);
>>> +                     if (!skb->dev) {
>>> +                             rcu_read_unlock();
>>> +                             dev_kfree_skb(skb);
>>> +                             txq->tx_dropped++;
>>> +                             break;
>>> +                     }
>>> +                     rcu_read_unlock();
>>> +                     skb->iif = dev->ifindex;
>> What protects the device from disappearing here and below during
>> dev_queue_xmit() and netif_rx_ni()?
> 
> For dev_queue_xmit(), dev is holded by skb->_dst, so there is no
> problem. But for netif_rx_ni(), I don't know how to prevent the device
> disappearing, and it seems that all the NIC drivers have this problem.
> Maybe there was the assumption about the execution context of
> netif_rx() before. Now softirq can't be executed by softirqd, so the
> packet receiving path maybe interleaved. I don't know how to prevent
> it happening.

You can either take a reference of move the rcu_read_unlock()
after the skb submission.

>>> +             break;
>>> +     case __constant_htons(ETH_P_IPV6):
>>> +             ip_proto = ipv6_hdr(skb)->nexthdr;
>>> +             addr1 = ipv6_hdr(skb)->saddr.s6_addr32[3];
>>> +             addr2 = ipv6_hdr(skb)->daddr.s6_addr32[3];
>>> +             ihl = 10;
>> Where does 10 come from?
> 
> It should be 40, after reviewing IPV6, I found that I need to loop
> until finding the right protocol value.

There is a helper for this (ipv6_skip_exthdr).

>>> +static int ifb_get_tx_queues(struct net *net, struct nlattr *tb[],
>>> +                          unsigned int *num_tx_queues,
>>> +                          unsigned int *real_num_tx_queues)
>>> +{
>>> +     if (tb[IFLA_NTXQ]) {
>>> +             *num_tx_queues = nla_get_u16(tb[IFLA_NTXQ]);
>> We currently use unsigned ints for the queue number, so please
>> use an u32 for the attribute as well.
>>
>>> +             *real_num_tx_queues = *num_tx_queues;
>>> +     } else {
>>> +             *num_tx_queues = numtxqs;
>>> +             *real_num_tx_queues = numtxqs;
>>> +     }
>>> +
>>> +     return 0;
>>> +}
>>> +
>         u16                     (*ndo_select_queue)(struct net_device *dev,
>                                                     struct sk_buff *skb);
> use u16 as the return value so ..., and I think u16 is big enough. If
> you insist on this, I'll use u32 instead.

Well, get_tx_queues() uses unsigned int, as does struct net_device.
I agree that it probably won't ever be needed, but there's no harm
in using the correct type, the attribute encoding doesn't even need
more room.
