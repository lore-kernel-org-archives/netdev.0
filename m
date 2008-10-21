From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: on-link assumption in ipv4 routing cache
Date: Mon, 20 Oct 2008 21:02:44 -0400
Message-ID: <48FD2A34.7020702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:42831 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbYJUBCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 21:02:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All

Something that came as a surprise to me is that ipv4 implementation
seems to assume that a destination is on-link when there is
no explicit route to it.

A customer submitted an interesting problem where their SCTP associations
kept getting restarted.  The configuration was as follows:

host A: eth0: 17.17.17.17/24
	routing:
		17.17.17.0/24 dev eth0 on-link
		default dev eth1 10.0.0.1

host B: eth0: 18.18.18.18/24
		18.18.18.0/24 dev eth0 on-link
		default dev eth1 10.0.0.1

There were no routes to the "other" subnet on either host.

The application running on both hosts performed a bind to the specific
address as well as SO_BINDTODEVICE.

The result was that both hosts assumed that the peer was on-link, issued
ARP request/replies and successfully connected.  tcpdump showed only packets
on eth0.

This was somewhat of a surprise since I expected a EHOSTUNRACH error since
there were no routes to the destination and SO_DONTROUTE was not set.

I am really curious as to reason for this behavior?

Thanks
-vlad

p.s.  BTW, the solution to the association restart appeared to be
29e75252da20f3ab9e132c68c9aed156b87beae6 ([IPV4] route cache: Introduce rt_genid
for smooth cache invalidation).  There used to be some kind of a
race between cache flushing and SCTP bottom half attempting to recreate
a cache entry.  My guess is that there were rcu issues, since any
cache updated triggered by user application seem to have worked correctly.
Regardless, it appears to have been fixed in 2.6.25.
