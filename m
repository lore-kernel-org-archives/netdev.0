From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: VRFs and the scalability of namespaces
Date: Sat, 27 Sep 2014 15:29:58 +0200
Message-ID: <1411824598.2136890.172383085.705271DD@webmail.messagingengine.com>
References: <5425EAA6.7040302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:58223 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751783AbaI0N37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Sep 2014 09:29:59 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id C27B520731
	for <netdev@vger.kernel.org>; Sat, 27 Sep 2014 09:29:58 -0400 (EDT)
In-Reply-To: <5425EAA6.7040302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sat, Sep 27, 2014, at 00:37, David Ahern wrote:
> The Linux kernel needs proper VRF support -- as an L3 concept. A 
> capability to run a process in a "VRF any" context provides a resource 
> efficient solution where a single process with a single listen socket 
> works across all VRFs in a namespace and then connected sockets have a 
> specific VRF context.

In case you want to have full blown VRF support as in BGP-MPLS-VRF
setups I agree that namespaces seem to be not the right tool for the
job, even not closely. Although if those namespaces get split up in a
more lightweight routing/forwarding namespace and the normal full blown
network namespace it seems to be too cumbersome for user space to manage
those.

Did you already did an investigation how maybe the rule and table
features could be exploited to suite your needs? Some time back I
suggested something like "ip route table foo exec ....", keep an default
routing lookup indicator in task_struct which gets implicitly propagated
to rtnetlink routing table requests/modification for the requested
table. Tables already can be specified via rtnetlink, so no change would
be needed here.

For sockets something like SO_BINDTOTABLE might work, maybe even we can
by default use the task_struct information to also bind the sockets to
the per-process table. We certainly need to preserve the routing
information on the socket as we need those in icmp error handling (e.g.
where to apply ipv4/ipv6 redirects too). Directing incoming packets to
specific table also works via ip-rule-iif match.

Advantage with the ip route table foo exec... method would be, that
conversion of some unmodified routing management daemons might be
easier, others can either use rtnetlink extended attributes which are
already available, and we only need to have per-process context routing
table control, which seems not too hard to implement in ip-rule
subsystem, but I haven't checked.

The problem I see with rules is that some of those tables already work
hand in hand, they already have a implicit semantics, e.g. local, main,
default and unspec (this is even worse for IPv6, where addrconf already
uses hardcoded tables). Working around this might be very tricky and
even more problematic to do from user space.

I think I am not yet sure what features you want from VRFs, some things
seem to match the rule/table features but others I think are pretty hard
to implement.

I worry a bit about icmp error handling and updates of the routing
table, but this is a detail we can look into later if all needed
features are known.

Bye,
Hannes
