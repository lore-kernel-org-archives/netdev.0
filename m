From: David Miller <davem@davemloft.net>
Subject: dst->obsolete has become pointless
Date: Fri, 04 Nov 2011 23:09:10 -0400 (EDT)
Message-ID: <20111104.230910.520924516201406800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: steffen.klassert@secunet.com, timo.teras@iki.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752454Ab1KEDJc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 23:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


While researching the things unearthed by Steffen Klassert wrt. PMTU
handling in the current tree I went to do some research on what the
real story is wrt. dst->obsolete.

And sure enough EVERY SINGLE ipv4 and ipv6 route is created with
obsolete set to -1, so we unconditionally always invoke ->dst_check().

This makes it completely pointless as an optimization to avoid calling
the dst_ops->dst_check() method.  It never triggers.

This stems from Timo's change to make route expiry properly visible
to IPSEC stacked routes:

--
commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92
Author: Timo Ter=E4s <timo.teras@iki.fi>
Date:   Thu Mar 18 23:20:20 2010 +0000

    ipv4: check rt_genid in dst_check
=2E..
--

Only DecNET creates routes with obsolete initially set to zero, and
therefore only hits ->dst_check() when dst_free is invoked on the route
during a flush of the decnet routing tables.

And actually this is how ipv4 operated before we started using
generation counts instead of flushing the entire table.  IPV6 seems to
always have used the FIB6 tree serial numbers for expiration checking
and therefore always set obsolete to -1 on new routes.

So we can't just get rid of the dst->obsolete check in dst_check() and
__sk_dst_check() because that will break DecNET because DecNET's
->dst_check() handler assumes that if it was called then the route
is obsolete and it just plainly returns NULL to tell the caller the
route is in fact invalid.

The current situation looks quite terrible, because these functions loo=
k
like they optimize away the check op call, but in reality for ipv4 and
ipv6 they do not.
