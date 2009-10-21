From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: pktgen and spin_lock_bh in xmit path
Date: Wed, 21 Oct 2009 10:42:41 +0530
Message-ID: <OFE19FAAE4.E89690B3-ON65257656.001B6B90-65257656.001CA0C0@in.ibm.com>
References: <4ADD309B.1040505@candelatech.com> <4ADD32FA.6030409@gmail.com> <4ADD41F5.5080707@candelatech.com> <4ADDF560.1020509@candelatech.com> <4ADDF6E5.4070509@gmail.com> <4ADDF948.1050208@candelatech.com> <4ADE0306.6060101@gmail.com> <4ADE0770.8060708@gmail.com> <4ADE2735.9000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>, netdev-owner@vger.kernel.org,
	robert@herjulf.net
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:38910 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbZJUFOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 01:14:04 -0400
In-Reply-To: <4ADE2735.9000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Greear <greearb@candelatech.com>  wrote on 10/21/2009 02:40:13 AM:

Coming back a bit to this post:

> > -   queue_map = skb_get_queue_mapping(pkt_dev->skb);
> > +   queue_map = pkt_dev->cur_queue_map;
> > +   /*
> > +    * tells skb_tx_hash() to use this tx queue.
> > +    * We should reset skb->mapping before each xmit() because
> > +    * xmit() might change it.
> > +    */
> > +   skb_record_rx_queue(pkt_dev->skb, queue_map);
> >      txq = netdev_get_tx_queue(odev, queue_map);
>
> I think that must be wrong.  The record_rx_queue sets it to queue_map +
1,
> but the hard-start-xmit method (in ixgbe/ixgbe_main.c, at least), takes
the
> skb->queue_map and uses it as an index with no subtraction.

But that should work fine. record_rx_q sets queue_mapping to +1,
but skb_tx_hash calls skb_get_rx_queue, which does a -1 on this
value, and updates that value into queue_mapping. Hence it will
not cross the txq boundary. Drivers can use the queue_map value
directly without requiring to subtract.

Thanks,

- KK

>
> This causes watchdog timeouts because we are calling txq_trans_update in
pktgen on
> queue 0, for instance, but sending pkts on queue 1.  If queue 1 is ever
> busy when the WD fires, link is reset.

