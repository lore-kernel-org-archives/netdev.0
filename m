From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 6/8] iproute2: Add support for the RTA_VIA attribute
Date: Tue, 07 Apr 2015 14:38:09 -0500
Message-ID: <87mw2jg25a.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
	<c3ad7d77783046d38e5b23b5e1fe0f71@BRMWP-EXMB11.corp.brocade.com>
	<20150315123337.2694183a@urahara>
	<87lhiyoxnw.fsf@x220.int.ebiederm.org>
	<87bnjuoxe8.fsf_-_@x220.int.ebiederm.org>
	<87d24animx.fsf_-_@x220.int.ebiederm.org>
	<552310E6.5060503@cumulusnetworks.com> <20150406232713.GR1051@gospo>
	<5523EFEB.1030205@cumulusnetworks.com>
	<87pp7for7v.fsf@x220.int.ebiederm.org>
	<CAMs_D182V7LW1Onxzz5ENbqF2TQQFm0Ly0wiXfntZP91zeT5xA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: roopa <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Stephen Hemminger <shemming@brocade.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	Robert Shearman <rshearma@brocade.com>
To: Vivek Venkatraman <vivek@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41067 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753833AbbDGTmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 15:42:14 -0400
In-Reply-To: <CAMs_D182V7LW1Onxzz5ENbqF2TQQFm0Ly0wiXfntZP91zeT5xA@mail.gmail.com>
	(Vivek Venkatraman's message of "Tue, 7 Apr 2015 09:58:45 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vivek Venkatraman <vivek@cumulusnetworks.com> writes:

> At the edge, when doing IPoMPLS, we'll be imposing a set of labels on
> top of the packet rather than replacing, but the same semantics can be
> applied because the destination address is now different and becomes a
> label stack.

Exactly how this will happen is an open question.  The hard part is we
need something light weight enough that we can scale to 1 million
routes, aka a full routing table. 

Network devices consume much too much memory to contemplate having a
different network device for each of 1 million different routes.

The transform infrastructure (xfrm) that is used for ipsec looks
attractive for imposing tunnels but it is clumsy, and does not map well
to the kinds of tunnels IPoMPLS traffic needs.

Having something in the ipv4 and ipv6 fib entry say a pointer or a 32bit
key that refers to a struct mpls_route to impose looks like what we want
int he abstract.  What the userspace interface for that implemenation is
something that I do not see clearly.  Ideally we build a userspace
interface that works not only for MPLS but also for other tunnel types
like IPIP, GRE, etc.   This would allow not only MPLS tunnels but other
tunnel types to be supported up to the full routing table size.

Perhaps a new attribute RTA_ENCAP that encodes a structure with
a tunnel type and enough information to encode the tunnel header.
I would have to make a survey of the existing tunnel types to see
if there is enough of a pattern an option that works for multiple
protocols could actually be achieved.

Using a tunnel that is not a network device and as such does not need
to keep packet counters looks like it will scale much better than our
other options, even with the best memory usage simplications I can
imagine for network devices.  Maintenance of per cpu counters (which are
necessary for performance) requires a non-trivial amount of memory and
as such are much harder to scale.

> One thing to note is that the destination address replaced/imposed
> could change based on the path selected, when there is ECMP. So, I
> propose that the iproute2 syntax of "as [to]" be reconsidered for
> MPLS, otherwise we'll end up with something like the following when
> this is extended to setup IPoMPLS direct forwarding with ECMP:
>
> ip route add 147.1.1.0/24 nexthop as to 400/2230 via inet 192.168.1.1
> dev eth0 nexthop as to 600/2400 via inet 192.168.2.1 dev eth1

That does not work with the semantics of the RTA_NEWDST message require
the new address to be in the same address family as the old address.
So it is useful for NATing IPv4 or IPv6 with routes (if you are
so inclined) but it is not useful for imposing an mpls header.

> Instead, if we use the specifier "label", we'll get:
>
> ip route add 147.1.1.0/24 nexthop via inet 192.168.1.1 dev eth0 label
> 400/2230 nexthop via inet 192.168.2.1 dev eth1 label 600/2400
>
> The transit case (label swapping) would look like:
>
> ip -f mpls route add 400 via inet 192.168.1.10 dev eth0 label 500
>
> The syntax can then be better extended to specify a label operation
> such as "pop" which would be needed when performing ultimate hop pop
> (UHP) and then lookup/forward based on underlying label stack or IP
> header.

Pop is the case where where the RTA_NEWDST attribute is empty (or
unspecified).

>From an mpls perspective the RTA_DST label is always popped (if it
matches) and the RTA_NEWDST label stack is always pushed.

> A new application besides MPLS that needs to modify the destination
> address would use its own keyword but encode using the RTA_NEWDST
> attribute.

Eric
