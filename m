From: Michel Machado <michel@digirati.com.br>
Subject: [PATCH 1/1] neighbour: Fixed race condition at tbl->nht
Date: Tue, 21 Feb 2012 16:04:13 -0500
Message-ID: <1329858253.2563.51.camel@Thor>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta115.f1.k8.com.br ([187.73.32.187]:49048 "EHLO
	mta115.f1.k8.com.br" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752022Ab2BUV1v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:27:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the fixed race condition happens:

1. While function neigh_periodic_work scans the neighbor hash table
pointed by field tbl->nht, it unlocks and locks tbl->lock between
buckets in order to call cond_resched.

2. Assume that function neigh_periodic_work calls cond_resched, that is,
the lock tbl->lock is available, and function neigh_hash_grow runs.

3. Once function neigh_hash_grow finishes, and RCU calls
neigh_hash_free_rcu, the original struct neigh_hash_table that function
neigh_periodic_work was using doesn't exist anymore.

4. Once back at neigh_periodic_work, whenever the old struct
neigh_hash_table is accessed, things can go badly.

Signed-off-by: Michel Machado <michel@digirati.com.br>
CC: "David S. Miller" <davem@davemloft.net>
CC: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index e287346..2a83914 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -826,6 +826,8 @@ next_elt:
 		write_unlock_bh(&tbl->lock);
 		cond_resched();
 		write_lock_bh(&tbl->lock);
+		nht = rcu_dereference_protected(tbl->nht,
+						lockdep_is_held(&tbl->lock));
 	}
 	/* Cycle through all hash buckets every base_reachable_time/2 ticks.
 	 * ARP entry timeouts range from 1/2 base_reachable_time to 3/2
