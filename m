From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bug in bonding driver
Date: Wed, 24 Mar 2010 12:13:20 -0700
Message-ID: <21160.1269458000@death.nxdomain.ibm.com>
References: <4BAA58B3.2040504@nortel.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: "Chris Friesen" <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:47440 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754933Ab0CXTNa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 15:13:30 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e7.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2OJ4rWc001935
	for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 15:04:53 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2OJDSrc152046
	for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 15:13:29 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2OJDLAO011817
	for <netdev@vger.kernel.org>; Wed, 24 Mar 2010 13:13:22 -0600
In-reply-to: <4BAA58B3.2040504@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen <cfriesen@nortel.com> wrote:
>One of our guys pointed out what appears to be a bug in
>bond_ab_arp_inspect().  There's a chunk of code that looks like this:
>
>	/*
>	 * Give slaves 2*delta after being enslaved or made
>	 * active.  This avoids bouncing, as the last receive
>	 * times need a full ARP monitor cycle to be updated.
>	 */
>	if (!time_after_eq(jiffies, slave->jiffies +
>			   2 * delta_in_ticks))
>		continue;
>
>The catch here is that slave->jiffies may not ever get updated after
>being set initially, and on long-running systems jiffies will overflow.
> That could cause this check to be true for a substantial amount of time
>rather than for just a short period.

	The definition for time_after in include/linux/jiffies.h claims
to handle timer wrapping, but even so, there presumably has to be a
cutoff at which "after" becomes "before" again.  

	Some quick fooling around suggests that if, for example,
slave->jiffies is near the top of the range (ULONG_MAX - a few hundred),
when jiffies gets up to around ULONG_MAX / 2 time_after_eq will flip
from "after" to "before."

	I don't think this is a particularly farfetched example, since
jiffies is intentionally started near the top of the range, so
slave->jiffies is likely to be high in the range after bonding is
configured at boot.

>One way to fix it would be a boolean which tracks whether or not we've
>gone past the time, and if we have then we don't bother actually
>checking the time anymore.

	It might be clearer to make the slave->jiffies some kind of
countdown instead, perhaps reusing the slave->delay used for
updelay/downdelay and eliminating slave->jiffies entirely.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
