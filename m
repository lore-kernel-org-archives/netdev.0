From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding inactive slaves vs rx_dropped
Date: Thu, 14 Feb 2013 15:43:08 -0800
Message-ID: <6330.1360885388@death.nxdomain>
References: <20130214.160657.1394358701071068786.davem@davemloft.net> <4606.1360878661@death.nxdomain> <20130214.171821.186191007478674738.davem@davemloft.net>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, andy@greyhouse.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:56960 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932106Ab3BNXnj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 18:43:39 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Thu, 14 Feb 2013 18:43:38 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id C67FDC90023
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 18:43:36 -0500 (EST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1ENha75197258
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 18:43:36 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1ENhACu002807
	for <netdev@vger.kernel.org>; Thu, 14 Feb 2013 16:43:12 -0700
In-reply-to: <20130214.171821.186191007478674738.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: Jay Vosburgh <fubar@us.ibm.com>
>Date: Thu, 14 Feb 2013 13:51:01 -0800
>
>> David Miller <davem@davemloft.net> wrote:
>> 
>>>People are starting to notice that rx_dropped now increments on every
>>>packet received on an bond's inactive slave.
>>>
>>>I'm actually fine with rx_dropped incrementing in this situation.
>>>
>>>The problem I want to address is that rx_dropped is encompassing
>>>several unrelated situations and thus has become less useful for
>>>diagnosis.
>>>
>>>I think we should add some new RX stats such that we can get at
>>>least a small amount of granularity for rx_dropped.
>>>
>>>This way team, bond, etc. can increment a new netdev_stats->rx_foo in
>>>this situation, and then someone doing diagnosis can see that
>>>rx_dropped and rx_foo are incrementing at similar rates.
>> 
>> 	This drop isn't really happening in bonding, though.  From
>> looking at the code, it comes about because, for the inactive slave, the
>> rx_handler call returns EXACT, and there aren't any exact match ptype
>> bindings, so __netif_receive_skb throws it away.  This isn't always the
>> case; sometimes there is an exact match, for things like iSCSI or FCoE
>> that are really determined to get the packet.
>
>This isn't even the whole story, it won't return 'exact' if the packet
>from the inactive slave is broadcast or multicast.

	It should; it returns EXACT if the packet is on an inactive
slave, with one exception: for a balance-alb mode inactive slave,
broadcast and multicast return EXACT, but unicast (technically, not
broadcast and not multicast) returns ANOTHER after assigning skb->dev to
the bond.

	This permits unicast traffic to pass on the inactive slave(s) in
alb mode, because its inactive slaves are really "mostly active," and we
only need to suppress broadcasts and multicasts.

	The 802.3ad LACPDU protocol handler will return CONSUME for the
skbs it handles, but that doesn't confuse any drop statistics.

>My general rule is that every special case increments a special
>'absurdity' statistic counter for the code :-)

	Gonna need a whole lot of those for bonding, then.  Maybe it
should have its own ethtool -S stats to handle all of the
bonding-internal absurdity.

>> 	We could probably add an, oh, rx_dropped_inactive, or some
>> variation on that theme, that is incremented at the end of
>> __netif_receive_skb if deliver_exact is set, e.g., something like:
>
>Yes, that looks fine to me.
>
>> 	There's the separate questions of whether there should be more
>> counters (e.g., drops in dev_skb_forward or enqueue_to_backlog), and how
>> to deliver the counter(s) to user space.
>
>Since there is some pain in adding counters, I think we should try to
>find a nice (very small) set of cases to cover all at once.

	There aren't a lot of places that increment rx_dropped outside
of the hardware device driver.  There's this case (__netif_receive_skb),
plus dev_forward_skb, enqueue_to_backlog and one other in
gro_cells_receive.  The dev_forward_skb case has two reasons:
skb_copy_ubufs failure, or !is_skb_forwardable.  Leaving both of the
dev_forward_skb reasons as one new counter, that leaves approximately:

	rx_dropped_inactive, rx_dropped_forward, rx_dropped_backlog and
rx_dropped_gro

	Is four too many?  Am I missing a case somewhere?

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
