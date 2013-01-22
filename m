From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] neigh: Keep neighbour cache entries if number of
 them is small enough.
Date: Wed, 23 Jan 2013 00:09:13 +0900
Message-ID: <50FEAB99.5060408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51752 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753474Ab3AVPJP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:09:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we have removed NCE (Neighbour Cache Entry) reference from
routing entries, the only refcnt holders of an NCE are timer (if run)
and the entry's owner table.  As a result, neigh_periodic_timer()
purges NCEs over and over even for gateways.

It does not make sense to purge NCEs even if number of them is
very small.

The number of entries can be specified by gc_thresh1.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 Documentation/networking/ip-sysctl.txt |    5 +++++
 net/core/neighbour.c                   |    4 ++++
 2 files changed, 9 insertions(+)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 4976564..19ac180 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -26,6 +26,11 @@ route/max_size - INTEGER
 	Maximum number of routes allowed in the kernel.  Increase
 	this when using large numbers of interfaces and/or routes.
 
+neigh/default/gc_thresh1 - INTEGER
+	Minimum number of entries to keep.  Garbage collector will not
+	purge entries if there are fewer than this number.
+	Default: 256
+
 neigh/default/gc_thresh3 - INTEGER
 	Maximum number of neighbor entries allowed.  Increase this
 	when using large numbers of interfaces and when communicating
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index c815f28..7bd0eed 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -778,6 +778,9 @@ static void neigh_periodic_work(struct work_struct *work)
 	nht = rcu_dereference_protected(tbl->nht,
 					lockdep_is_held(&tbl->lock));
 
+	if (atomic_read(&tbl->entries) < tbl->gc_thresh1)
+		goto out;
+
 	/*
 	 *	periodically recompute ReachableTime from random function
 	 */
@@ -832,6 +835,7 @@ next_elt:
 		nht = rcu_dereference_protected(tbl->nht,
 						lockdep_is_held(&tbl->lock));
 	}
+out:
 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
 	 * base_reachable_time.
-- 
1.7.9.5
