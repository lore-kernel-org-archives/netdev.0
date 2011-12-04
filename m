From: Michal Soltys <soltys@ziu.info>
Subject: Re: Understanding HFSC
Date: Sun, 04 Dec 2011 13:38:31 +0100
Message-ID: <4EDB69C7.6080209@ziu.info>
References: <1322974639.3347.72.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3648 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751756Ab1LDMie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 07:38:34 -0500
In-Reply-To: <1322974639.3347.72.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11-12-04 05:57, John A. Sullivan III wrote:
> Hello, all.  I hope I am in the right place as this seems to be the
> place to ask questions formerly asked on lartc.  For the last three
> days, I've been banging my head against the wall trying to understand
> HFSC and it's finally starting to crack (the wall, not my head
> although that's close, too!).  It seems to be wonderful, powerful,
> mysterious, and poorly understood.
> 
> I'm not sure I understand it either but it also seems much of what is
> written about it is written by people who don't fully grasp it, e.g.,
> mostly focusing on guaranteed bandwidth and hierarchical sharing but
> not spending much time explaining the important concept of decoupling
> latency requirements and bandwidth - the part most interesting to us.
> So I'm hoping you'll indulge my questions and my attempt to articulate
> my understanding to see if I get it or if I've completely missed the
> plot!
> 
> One of the most confusing bits to me is, does the m1 rate apply to
> each flow handled by the class or only to the entire class once it
> becomes active?

Where a packet lands is (generally) determined by tc filters and/or
iptables' mark/classify targets. All the packets that end in some leaf
node, are governed by that node's realtime service curve, and at times
when that criterion is not used - at the ratio of virtual times (coming
from linkshare service curves) between that node and its siblings.
Regardless of curve used - smallest vt (linkshare criterion) or smallest
dt from all eligible (realtime criterion) wins, and the leaf with one
will fulfill the dequeue call.

If you need more fine grained control "below" such leaf node - you need
to either use deeper hierarchy with presumably "simpler" qdiscs attached
(but more complex marking setup), or shallower hierarchy with more
elaborate qdiscs attached. Think of work conserving qdiscs such as: sfq,
drr - paired with appropriate tc filters (tc-flow perhaps ?) as needed.

Btw - check out the very latest iproute2 tree - there're fresh
tc-hfsc(7) and tc-stab(8) manuals added. I tried to make them as
detailed as possible, but I might have overshot a bit - so opinion of
someone getting into hfsc territory is invaluable. You can read them (if
installing fresh iproute2 is out of question) with simple:

nroff -mandoc -rLL=<width>n <page> | less

http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob_plain;f=man/man7/tc-hfsc.7;hb=HEAD
http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=blob_plain;f=man/man8/tc-stab.8;hb=HEAD

> Second, what must go into the umax size? Let's assume we want umax to
> be a single maximum sized packet on a non-jumbo frame Ethernet
> network.
> Should umax be:
> 1500
> 1514 (add Ethernet)
> 1518 (add CRC)
> 1526 (add preamble)
> 1538 (add interframe gap)?
> 
> To keep this email from growing any longer, I'll put the rest in a
> separate email? Thanks - John
> 

Note: umax/dmax/rate and m1/d/m2 are just alternative ways to specify
the very same thing.

As for your question - in that particular case, assuming no vlan tags
either, that would be 1514, afaik. You can cover for the rest though
with tc-stab (and also for other layers, such as atm). Keep in mind,
that if you don't disable send offloading (usually enabled by default
these days), qdiscs might be dealing with e.g. massive tcp segments with
typical side effects.

I'll go through your other questions a bit later.
