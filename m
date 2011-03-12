From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/25] Kill stack space gaps due to flowi layout.
Date: Sat, 12 Mar 2011 15:23:51 -0800 (PST)
Message-ID: <20110312.152351.189687538.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37554
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756175Ab1CLXXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2011 18:23:15 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 54E5C24C088
	for <netdev@vger.kernel.org>; Sat, 12 Mar 2011 15:23:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


One thing we got wrong from the beginning was the layout of
struct flowi.  It's suboptimal by design.

For ipv4, for example, huge gaps exist between the addressing
information and the "ports".  This is because we put the
addressing information for all AF types side-by-side in a
union so there is a gap because the ipv6 addresses take up
more space.

There were also completely unused portions of struct flowi due
to padding.

So as a result we get less dense data accesses, and therefore
less successful store buffer compression and less cache locality.

Lucky for us, all code paths that touch the AF dependent portions
do so in an AF dependent context.  Therefore we can lay things out
any way we like.

So these changes pack things together as tightly as possible for
each AF variant.  And AF independent code is only allowed to
make references to the "common" area at the beginning of each
AF instance.

Performance improvement is measurable, even a routing cache hit
output route lookup is ~20 cycles faster on Niagara2.  udpflood
tests are also faster by several seconds.

I tried to minimize the noise and churn by making ipv4 helpers
for various common cases of route lookups.  But some code paths
want to do something very special (f.e. icmp) and I did not work
on such helpers for ipv6.  That can be done at a later time.

And in fact, ipv6 is really an area ripe for consolidation of routing
lookups.  The same flowlabel resolution sequence probably occurs 10
times in the tree.

And hey, even decnet got some love here.

What I'll do tonight is push this to net-next-2.6 and then respin
the routing cache deletion patches, since those obviously won't
apply any longer. :)
