From: David Miller <davem@davemloft.net>
Subject: inetpeer with create==0
Date: Wed, 02 Mar 2011 20:45:45 -0800 (PST)
Message-ID: <20110302.204545.193730647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49786
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932144Ab1CCEpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 23:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric, I was profiling the non-routing-cache case and something that stuck
out is the case of calling inet_getpeer() with create==0.

If an entry is not found, we have to redo the lookup under a spinlock
to make certain that a concurrent writer rebalancing the tree does
not "hide" an existing entry from us.

This makes the case of a create==0 lookup for a not-present entry
really expensive.  It is on the order of 600 cpu cycles on my
Niagara2.

I added a hack to not do the relookup under the lock when create==0
and it now costs less than 300 cycles.

This is now a pretty common operation with the way we handle COW'd
metrics, so I think it's definitely worth optimizing.

I looked at the generic radix tree implementation, and it supports
full RCU lookups in parallel with insert/delete.  It handles the race
case without the relookup under lock because it creates fixed paths
to "slots" where nodes live using shifts and masks.  So if a path
to a slot ever existed, it will always exist.

Take a look at lib/radix-tree.c and include/linux/radix-tree.h if
you are curious.

I think we should do something similar for inetpeer.  Currently we
cannot just use the existing generic radix-tree code because it only
supports indexes as large as "unsigned long" and we need to handle
128-bit ipv6 addresses.
