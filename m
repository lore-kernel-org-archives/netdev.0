From: Bob Gilligan <gilligan@aristanetworks.com>
Subject: [PATCH] neigh: Netlink notification for administrative NUD state
 change
Date: Sun, 15 Dec 2013 13:39:56 -0800
Message-ID: <52ae21ac.oFg7QoGcVg2CCThY%gilligan@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [162.210.130.3] ([162.210.130.3]:15783 "EHLO
	prod-mx.aristanetworks.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751964Ab3LOVpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Dec 2013 16:45:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The neighbour code sends up an RTM_NEWNEIGH netlink notification if
the NUD state of a neighbour cache entry is changed by a timer (e.g.
from REACHABLE to STALE), even if the lladdr of the entry has not
changed.

But an administrative change to the the NUD state of a neighbour cache
entry that does not change the lladdr (e.g. via "ip -4 neigh change
...  nud ...") does not trigger a netlink notification.  This means
that netlink listeners will not hear about administrative NUD state
changes such as from a resolved state to PERMANENT.

This patch changes the neighbor code to generate an RTM_NEWNEIGH
message when the NUD state of an entry is changed administratively.

Signed-off-by: Bob Gilligan <gilligan@aristanetworks.com>
---

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 6072610..7f0e838 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1161,6 +1161,7 @@ int neigh_update(struct neighbour *neigh, const u8 *lladdr, u8 new,
 						 neigh->parms->reachable_time :
 						 0)));
 		neigh->nud_state = new;
+		notify = 1;
 	}
 
 	if (lladdr != neigh->ha) {
