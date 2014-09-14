From: David L Stevens <david.stevens@oracle.com>
Subject: Re: [PATCHv3 net-next 2/3] sunvnet: allow admin to set sunvnet MTU
Date: Sat, 13 Sep 2014 22:15:41 -0400
Message-ID: <5414FA4D.6030504@oracle.com>
References: <54146A37.5010108@oracle.com> <20140913.162101.515634682549373073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:29980 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235AbaINCPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 22:15:46 -0400
In-Reply-To: <20140913.162101.515634682549373073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 09/13/2014 04:21 PM, David Miller wrote:

> I personally find this scheme where we pretend that the device can
> have an arbitrary MTU, when in fact the effective MTU is a product of
> the sub-ports, quite ugly.

I wouldn't say I like it, either, but the problem is that without it, we
are tied to the least common denominator. Anything that doesn't support
v1.6 of the VIO protocol is stuck at the low MTU and low throughput, and
since Solaris itself is limited to 16000, Linux, which can do 64K-1, is
also limited to 16000. On my hardware, the original we'd be tied to is
about 1Gbps, the 16000 is about 5.4Gbps, and the full linux-linux is about
8Gbps. So, a big penalty.

I think of it as an Ethernet connected to a virtual switch, and the ICMP
errors are for PMTUD are analogous to IGMP snooping. This is not an Ethernet
device alone-- those don't negotiate per-destination link MTUs. But nothing forces
anyone to mix MTUs; the ICMP errors simply allow it.

> In fact, that ugly ICMP stuff in the next patch is absolutely required
> to avoid bogus behavior possible after this patch.  You have to
> combine #2 and #3 otherwise you are adding an intermediate regression.

I disagree here. It's not any more bogus for the admin to set an MTU value
of what s/he wants when the others have not been. It *always* happens that
way. Ordinary Ethernet comes up at 1500 and one of them must be increased
first. At that time, the others don't match, and it is the admin's responsibility
to make sure they match.

> Logic wise, at the very least you should limit the MTU setting to the
> largest MTU of all of the individual ports.

We can't directly do that, because the MTU for the port is negotiated at
probe time. That'll be 1500 IP data (always) and we have to raise one of them
first, so one of them has to be set at a higher value than the negotiated
MTU at some point, at least until it is reset and re-negotiated. But we
don't know until we try a higher value if all the links can use it, and we
can't prevent another link from joining later that has a lower MTU, but we
can't then lower our on MTU for the whole device.

I think in ordinary Ethernet, there is nothing at all enforcing a particular
MTU-- it is set to what the admin wants, regardless of what other hosts use.
That's the effect we ought to have here, despite the one-to-many p2p links
where we can know in advance what the link MTUs are, and that's what patch #2
does. I don't think we should try too hard to prevent a value an admin wants --
it will just get in the way of the admin, where it doesn't in ordinary Ethernet.

On the other hand, if the link MTU is lower, we shouldn't quietly drop packets, thus the ICMP
errors that allow both.

							+-DLS
