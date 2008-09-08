From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] igmp: make /proc/net/{igmp,mcfilter} per netns
Date: Mon, 8 Sep 2008 11:17:48 -0700
Message-ID: <OFAF5F99D2.464B2693-ON882574BE.00630917-882574BE.0064824E@us.ibm.com>
References: <48C4F1C6.6080605@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	containers@lists.linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:52680 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752406AbYIHSSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 14:18:06 -0400
In-Reply-To: <48C4F1C6.6080605@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As I've said before, I really don't like the model you're
using for multicasting here (if I understand correctly, and
I shamelessly admit I haven't looked at this code in detail).

As I understand it, you're modelling the multiple virtual interfaces
as different pieces of hardware on the same physical network.
The implication is that apps joining the same group in multiple
containers will result in multiple advertisements for the same
group, from each of the multiple instances of IGMP & MLD.

In IPv4, that's just ineffecient. In IPv6, the question is: do you have
multiple link-local addresses-- one for each virtual device?
If not, then MLD will be sending multiple copies of everything in
violation of the spec (since they'll be from the same source, too).

I think IGMP and MLD both belong with the physical interface, since
they pretty much do exactly what you want already: glom all the
different filters and group memberships together into exactly the
minimal set of group memberships needed for everyone to hear
just the pieces they've requested.

If you do that at the interface, then you won't have any duplicated
traffic on the physical net and you can separate copies as needed
for the different virtual nets on the host. Perfect, and indistinguishable
externally from a non-container machine (and the code to do it is
already in IGMP and MLD).

If you treat them as separate physical devices all the way to the
wire, then you're just needlessly increasing the host processing
you need to do, as well as loading the multicast routers and network
that are unfortunate enough to be on the same network as you are.

I haven't been paying attention, so I'll be happy if you tell me you've
already addressed this. :-) Otherwise, I think it'd be wise to do so
before it's released into the wild and can't be easily changed.

                                                +-DLS

