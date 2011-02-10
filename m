From: David Miller <davem@davemloft.net>
Subject: [RFC PATCH 0/5] Cache PMTU/redirects in inetpeer
Date: Wed, 09 Feb 2011 22:12:49 -0800 (PST)
Message-ID: <20110209.221249.112596220.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750840Ab1BJGMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 01:12:13 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id BC3DE24C08A
	for <netdev@vger.kernel.org>; Wed,  9 Feb 2011 22:12:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is what I've been working on for the past several days.

Right now if the routing cache is turned off (by setting
rt_cache_rebuild_count to "0") several things stop working.

We never make use of any PMTU or redirect information we learn
via ICMP packets.  This is because when the routing cache is
off, we can't "find" the existing cached routes that match
the ICMP because we don't add them to the hash table.

This functionality loss is also a blocker for eliminating the
routing cache entirely.

Solve this by remembering this state in the inetpeer entries.

PMTU information now self-expires.  It gets validated when
cached routes are sanity checked via dst_ops->check().  At
expiration, the original RTAX_MTU metric value is restored.
So we don't have to invalidate the entire cached route just
because it's PMTU learned value has expired.

Similarly, we store redirect information in inetpeer too.
Except that currently my patches don't remember the "original"
gateway the route had, so we have to kill the route off when
we get a dst_ops->negative_advice() call on a redirected route.

Avoid this is easy to fix and I might do that soon.

These patches implement the PMTU/redirect bits in ipv4 only at the
moment, but I do have ipv6 patches I'm in the process of finishing
up.  I just wanted people to see this as soon as possible so that
I can start getting feedback.

And hey if people can test this stuff out that'd be awesome!  If
you've used these changes in an environment where you did hit PMTU
and redirects, please do let me know.
