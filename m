From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Socket buffer sizes with autotuning
Date: Fri, 25 Apr 2008 09:06:48 +0200
Message-ID: <48118308.1090407@firstfloor.org>
References: <d1c2719f0804241829s1bc3f41ejf7ebbff73ed96578@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Jerry Chu <hkchu@google.com>, davem@davemloft.net,
	johnwheffner@gmail.com, rick.jones2@hp.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55953 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752794AbYDYHGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 03:06:51 -0400
In-Reply-To: <d1c2719f0804241829s1bc3f41ejf7ebbff73ed96578@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[fixed cc and subject]

Jerry Chu wrote:
> On Thu, Apr 24, 2008 at 3:21 PM, Andi Kleen <andi@firstfloor.org> wrote:
>> David Miller <davem@davemloft.net> writes:
>>
>>>> What is your interface txqueuelen and mtu?  If you have a very large
>>>> interface queue, TCP will happily fill it up unless you are using a
>>>> delay-based congestion controller.
>>> Yes, that's the fundamental problem with loss based congestion
>>> control.  If there are any queues in the path, TCP will fill them up.
>> That just means Linux does too much queueing by default.  Perhaps that
>> should be fixed. On Ethernet hardware the NIC TX queue should be
>> usually sufficient anyways I would guess. Do we really need the long
>> qdisc queue too?
> 
> I think we really need the large xmit queue, especially when the CPU speed,
> or the aggregated CPU bandwidth in the case of multi-cores, is >> NIC speed
> for the following reason:
> 
> If the qdisc and/or NIC queue is not large enough, it may not absorb the high
> burst rate from the much faster CPU xmit threads, hence causing pkts to
> be dropped before they hit the wire. 

sendmsg should just be a little smarter on when to block depending on
the state of the interface. There is already some minor code for tnat
as you'll have noted. Then the bursts would be much less of a problem.

We already had this discussion recently together with better behaviour
on bounding.

The only big problem then would be if there are more submitting threads
than packets in the TX queue, but I would consider that unlikely for
GB+ NICs at least (might be an issue for older designs with smaller queues)

> Here the CPU/NIC relation is much like
> a router

It doesn't need to be. Unlike a true network it is very cheap here
to do direct feedback.

> Removing the unnecessary cwnd growth by counting out those pkts that are
> still stuck in the host queue may be a simpler solution. I'll find out
> how well it
> works soon.

I think that's a great start, but probably not enough.

-Andi



