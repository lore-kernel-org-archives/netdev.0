From: David Miller <davem@davemloft.net>
Subject: inetpeer in fib tables...
Date: Thu, 07 Jun 2012 15:12:19 -0700 (PDT)
Message-ID: <20120607.151219.870388144120010595.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933161Ab2FGWMT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 18:12:19 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id B3333583C45
	for <netdev@vger.kernel.org>; Thu,  7 Jun 2012 15:12:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just a heads up on what I'm doing to fix the bug Stephen Hemminger
forwarded.

Essentially I'm going to put inetpeer roots into the FIB tables.
Since each FIB table is essentially a realm of destinations, this will
fix all of the problems like the one in the bugzilla report.

We still need Gao's per-ns inetpeer root patches because there are
situations where we don't have a FIB table context by which to select
an inetpeer root, so we need a global inetpeer tree to fallback onto.

Several kinds of routing lookups do not use a FIB lookup.  Also,
another case is the inetpeer lookup done for IPv4 fragmentation ID
wraparound avoidance.

Much of my changes have to do with handling the fact that we often
need to do the inetpeer lookup long after the route lookup.  And we
don't want to waste a whole pointer just to store the inetpeer root.

So I change the rt->peer to be rt->_peer and of type unsigned long.
Then we encode the pointer with the low bit signifying that the
value is actually a pointer to an inetpeer base.  Similar changes are
made for ipv6.

And similar handling is needed for TCP timewait sockets, to propagate
the inetpeer root to use for lookups or the fully resolved inetpeer.

The next problem is inetpeer tree invalidation.  Now that we'll have
multiple trees per address family, we can't just flush all inetpeers
for a given address family so easily as we can now.  The way this will
be handled is to give each peer a sequence number, and there is a
per-AF sequence number which will be bumped by the current
invalidation code.  Lookups check the sequence number of the inetpeer
root they are using and flush if necessary.

Anyways, once Gao properly respins his patches I'll merge net into
net-next and start submitting the inetpeer FIB table changes.
