From: David Miller <davem@davemloft.net>
Subject: [PATCH 0/5] Long term PMTU/redirect storage in ipv4.
Date: Tue, 17 Jul 2012 06:14:18 -0700 (PDT)
Message-ID: <20120717.061418.1893307699868826531.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab2GQNOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 09:14:18 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 886615837B5
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 06:14:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


These patches implement the final mechanism necessary to really allow
us to go without the route cache in ipv4.

We need a place to have long-term storage of PMTU/redirect information
which is independent of the routes themselves, yet does not get us
back into a situation where we have to write to metrics or anything
like that.

For this we use an "next-hop exception" table in the FIB nexthops.

Currently it is a simple linked list and uses a single global lock
for synchronization, but that can be easily adjusted as-needed.

The one thing I desperately want to avoid is having to create clone
routes in the FIB trie for this purpose, because that is very
expensive.   However, I'm willing to entertain such an idea later
if this current scheme proves to have downsides that the FIB trie
variant would not have.

In order to accomodate this any such scheme, we need to be able to
produce a full flow key at PMTU/redirect time.  That required an
adjustment of the interface call-sites used to propagate these events.

For a PMTU/redirect with a fully specified socket, we pass that socket
and use it to produce the flow key.

Otherwise we use a passed in SKB to formulate the key.  There are two
cases that need to be distinguished, ICMP message processing (in which
case the IP header is at skb->data) and output packet processing
(mostly tunnels, and in all such cases the IP header is at ip_hdr(skb)).

We also have to make the code able to handle the case where the dst
itself passed into the dst_ops->{update_pmtu,redirect} method is
invalidated.  This matters for calls from sockets that have cached
that route.  We provide a inet{,6} helper function for this purpose,
and edit SCTP specially since it caches routes at the transport rather
than socket level.

Signed-off-by: David S. Miller <davem@davemloft.net>
