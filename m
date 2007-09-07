From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: error(s) in 2.6.23-rc5 bonding.txt ?
Date: Fri, 07 Sep 2007 16:31:01 -0700
Message-ID: <32121.1189207861@death>
References: <46E1CA81.6050808@hp.com>
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:38895 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751170AbXIGXbE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Sep 2007 19:31:04 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l87NV4PL007332
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 19:31:04 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l87NV4Qb472264
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 19:31:04 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l87NV3H5026527
	for <netdev@vger.kernel.org>; Fri, 7 Sep 2007 19:31:03 -0400
In-reply-to: <46E1CA81.6050808@hp.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones <rick.jones2@hp.com> wrote:
[...]
>>         Note that this out of order delivery occurs when both the
>>         sending and receiving systems are utilizing a multiple
>>         interface bond.  Consider a configuration in which a
>>         balance-rr bond feeds into a single higher capacity network
>>         channel (e.g., multiple 100Mb/sec ethernets feeding a single
>>         gigabit ethernet via an etherchannel capable switch).  In this
>>         configuration, traffic sent from the multiple 100Mb devices to
>>         a destination connected to the gigabit device will not see
>>         packets out of order.  
>
>My first reaction was that this was incorrect - it didn't matter if the
>receiver was using a single link or not because the packets flowing across
>the multiple 100Mb links could hit the intermediate device out of order
>and so stay that way across the GbE link.

	Usually it does matter, at least at the time I tested this.

	Usually, the even striping of traffic from the balance-rr mode
will deliver in-order to a single higher speed link (e.g., N 100Mb
feeding a single 1Gb).  I say "usually" because, although I don't see it
happen with the equipment I have, I'm willing to believe that there are
gizmos that would "bundle" packets arriving on the switch ports.

	The reordering (usually) occurs when packet coalescing stuff
(either interrupt mitigation on the device, or NAPI) happens at the
receiver end, after the packets are striped evenly into the interfaces,
e.g.,

	eth0	eth1	eth2
	P1	P2	P3
	P4	P5	P6
	P7	P8	P9

	and then eth0 goes and grabs a bunch of its packets, then eth1,
and eth2 do the same afterwards, so the received order ends up something
like P1, P4, P7, P2, P5, P8, P3, P6, P9.  In Ye Olde Dayes Of Yore, with
one packet per interrupt at 10 Mb/sec, this type of configuration
wouldn't reorder (or at least not as badly).

	The text probably is lacking in some detail, though.  The real
key is that the last sender before getting to the destination system has
to do the round-robin striping.  Most switches that I'm familiar with
(again, never seen one, but willing to believe there is one) don't have
round-robin as a load balance option for etherchannel, and thus won't
evenly stripe traffic, but instead do some math on the packets so that a
given "connection" isn't split across ports.

	That said, it's certainly plausible that, for a given set of N
ethernets all enslaved to a single bonding balance-rr, the individual
ethernets could get out of sync, as it were (e.g., one running a fuller
tx ring, and thus running "behind" the others).  If bonding is the only
feeder of the devices, then for a continuous flow of traffic, all the
slaves will generally receive packets (from the kernel, for
transmission) at pretty much the same rate, and so they won't tend to
get ahead or behind.

	I haven't investigated into this deeply for a few years, but
this is my recollection of what happened with the tests I did then.  I
did testing with multiple 100Mb devices feeding either other sets of
100Mb devices or single gigabit devices.  I'm willing to believe that
things have changed, and an N feeding into one configuration can
reorder, but I haven't seen it (or really looked for it; balance-rr
isn't much the rage these days).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
