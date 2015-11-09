From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] inet: delay address promotion check until last request
 in message
Date: Mon, 9 Nov 2015 09:23:25 -0500
Message-ID: <20151109142325.GA27281@hmsreliant.think-freely.org>
References: <1446839495-32719-1-git-send-email-nhorman@tuxdriver.com>
 <alpine.LFD.2.11.1511062352270.1904@ja.home.ssi.bg>
 <20151108215641.GA16147@neilslaptop.think-freely.org>
 <20151109.073138.1861688515066155518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ja@ssi.bg, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53127 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbKIOXt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2015 09:23:49 -0500
Content-Disposition: inline
In-Reply-To: <20151109.073138.1861688515066155518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 09, 2015 at 07:31:38AM +0900, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Sun, 8 Nov 2015 16:56:41 -0500
> 
> > All I'm doing is, in effect masking the promote_secondaries sysctl
> > for an interface doing a flush operation.
> 
> Packets and other entities not controlled by RTNL can see an inconsistent
> state: no primary address on the interface.
> 
> You can argue that this happened already but usually the window is tiny.
> 
> For the case you are optimizing for, the window is now several seconds
> long.  That's not really something we can do.
> 

I agree with what you're saying in regards to the fact that an inconsistent
state exists during this operation, but the time frame during which it exists is
variable dependent on the number of addresses being removed, and is no different
than the inconsistent state we allow by setting the promote_secondaries sysctl
to 0.

In my view we have a range of conditions bounded by the following two extreemes:

a) User space is removing a single addresses from an arbitrarily sized set on an
interface.

b) User space is flushing every address from an arbitrarily sized set on an
interface

In extreeme condition (a), which is also the most common condition, my patch is
effectively a no-op, because the netlink message see no next rtm_deladdr
request, and so performs promotion as it currently does as part of that one
transaction

In extreeme condition (b), I would argue that the fact that our interface state
is inconsistent is irrelevant.  While its true that other applications may see
that an interface has no primary address, they will in the very near future see
that the interface has no address at all.  Given that the error handling path
for both conditions is often the same or very simmilar (tell the user to pick a
different interface), I would say this isn't something we need to worry about.

The only condition that we do need to worry about I think is the condition in
which an administrator is removing M addresses from a large set of N addresses
on an interface, where M < N but M and N are both sufficiently large to make the
inconsistent state window significant.  In that case we may encounter
applications that see transient errors when searching for an interfaces primary
address.  But my question would then be, so what?  Lots of administrative
operations result in transient errors on other applications while they are in
progress (an arbitrary sized set of iptables rules getting flushed and restored
can result in the same transient error behavior, as an example).

The bottom line in my mind is, given the condition described above, which is the
lesser of evils? Having a window of time where applications may see an
inconsistent state, and not be able to use an interface? Or having a much larger
window of time (recall this patch reduces run time from O(n^2) to O(n)), during
which no other rtnl aware operations can progress, leaving the interface and
several other subsystems unusable.

As a matter of philosophy, This can certainly be implemented in user space.
We could have user space disable promotion only during a flush (either by coding
it into iproute2 and simmilar applications, or by simply documenting the fact
that for large flush operations promotion should be disabled.  That opens us up
to other races however (if multiple users are toggling the value of promote
secondaries), and still gives rise to the issue you describe above, in which
interfaces may have an inconsistent state during the flush operation.

Regards
Neil
