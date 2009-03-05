From: =?ISO-8859-1?B?SmVucyBM5eVz?= <jelaas@gmail.com>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper layer
Date: Thu, 5 Mar 2009 08:32:11 +0100
Message-ID: <96ff3930903042332n233ee3ddte23210f988019dec@mail.gmail.com>
References: <1235546423.2604.556.camel@ymzhang>
	 <20090224.233115.240823417.davem@davemloft.net>
	 <1236158868.2567.93.camel@ymzhang>
	 <20090304.013937.129768263.davem@davemloft.net>
	 <1236215076.2567.105.camel@ymzhang>
	 <1236220827.2567.136.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:50173 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbZCEHcN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:32:13 -0500
In-Reply-To: <1236220827.2567.136.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/3/5, Zhang, Yanmin <yanmin_zhang@linux.intel.com>:
> On Thu, 2009-03-05 at 09:04 +0800, Zhang, Yanmin wrote:
>  > On Wed, 2009-03-04 at 01:39 -0800, David Miller wrote:
>  > > From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
>  > > Date: Wed, 04 Mar 2009 17:27:48 +0800
>  > >
>  > > > Both the new skb_record_rx_queue and current kernel have an
>  > > > assumption on multi-queue. The assumption is it's best to send=
 out
>  > > > packets from the TX of the same number of queue like the one o=
f RX
>  > > > if the receved packets are related to the out packets. Or more
>  > > > direct speaking is we need send packets on the same cpu on whi=
ch we
>  > > > receive them. The start point is that could reduce skb and dat=
a
>  > > > cache miss.
>  > >
>  > > We have to use the same TX queue for all packets for the same
>  > > connection flow (same src/dst IP address and ports) otherwise
>  > > we introduce reordering.
>  > > Herbert brought this up, now I have explicitly brought this up,
>  > > and you cannot ignore this issue.
>  > Thanks. =EF=BB=BFStephen Hemminger brought it up and explained wha=
t reorder
>  > is. I answered in a reply (sorry for not clear) that mostly we nee=
d spread
>  > packets among RX/TX in a 1:1 mapping or N:1 mapping. For example, =
all packets
>  > received from RX 8 will be spreaded to TX 0 always.
>
> To make it clearer, I used 1:1 mapping binding when running testing
>  on bensley (4*2 cores) and Nehalem (2*4*2 logical cpu). So there is =
no reorder
>  issue. I also worked out a new patch on the failover path to just dr=
op
>  packets when qlen is bigger than netdev_max_backlog, so the failover=
 path wouldn't
>  cause reorder.
>

We have not seen this problem in our testing.
We do keep the skb processing with the same CPU from RX to TX.
This is done via setting affinity for queues and using custom select_qu=
eue.

+static u16 select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+       if( dev->real_num_tx_queues && skb_rx_queue_recorded(skb) )
+               return  skb_get_rx_queue(skb) % dev->real_num_tx_queues=
;
+
+       return  smp_processor_id() %  dev->real_num_tx_queues;
+}
+

The hash based default for selecting TX-queue generates an uneven
spread that is hard to follow with correct affinity.

We have not been able to generate quite as much traffic from the sender=
=2E

Sender: (64 byte pkts)
eth5            4.5 k bit/s        3   pps   1233.9 M bit/s    2.632 M =
pps

Router:
eth0         1077.2 M bit/s    2.298 M pps      1.7 k bit/s        1   =
pps
eth1            744   bit/s        1   pps   1076.3 M bit/s    2.296 M =
pps

Im not sure I like the proposed concept since it decouples RX
processing from receiving.
There is no point collecting lots of packets just to drop them later
in the qdisc.
Infact this is bad for performance, we just consume cpu for nothing.

It is important to have as strong correlation as possible between RX
and TX so we dont receive more pkts than we can handle. Better to drop
on the interface.

We might start thinking of a way for userland to set the policy for
multiq mapping.

Cheers,
Jens L=C3=A5=C3=A5s


>  > >
>  > > You must not knowingly reorder packets, and using different TX
>  > > queues for packets within the same flow does that.
>  > Thanks for you rexplanation which is really consistent with =EF=BB=
=BFStephen's speaking.
>
>
>  --
>  To unsubscribe from this list: send the line "unsubscribe netdev" in
>  the body of a message to majordomo@vger.kernel.org
>  More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
