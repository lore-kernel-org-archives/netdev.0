From: "Chris Friesen" <cfriesen@nortel.com>
Subject: bug in bonding driver
Date: Wed, 24 Mar 2010 12:23:47 -0600
Message-ID: <4BAA58B3.2040504@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:36312 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119Ab0CXSZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 14:25:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

One of our guys pointed out what appears to be a bug in
bond_ab_arp_inspect().  There's a chunk of code that looks like this:

	/*
	 * Give slaves 2*delta after being enslaved or made
	 * active.  This avoids bouncing, as the last receive
	 * times need a full ARP monitor cycle to be updated.
	 */
	if (!time_after_eq(jiffies, slave->jiffies +
			   2 * delta_in_ticks))
		continue;

The catch here is that slave->jiffies may not ever get updated after
being set initially, and on long-running systems jiffies will overflow.
 That could cause this check to be true for a substantial amount of time
rather than for just a short period.

One way to fix it would be a boolean which tracks whether or not we've
gone past the time, and if we have then we don't bother actually
checking the time anymore.

Chris
