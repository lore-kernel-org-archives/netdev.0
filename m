From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH] rebalance locks by converting write_lock_bh to
	write_lock+local_bh_disable
Date: Fri, 22 Nov 2013 00:54:02 +0100
Message-ID: <20131121235402.GA11774@opentech.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pedro Roque <roque@di.fc.ul.pt>,
	Peter Zijlstra <peterz@infradead.org>, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hofr.at ([212.69.189.236]:57820 "EHLO mail.hofr.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab3KVABe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 19:01:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 2c8e669b691b825c0ed2a02bd7a698d8ed5c6d29 Mon Sep 17 00:00:00 2001
From: Nicholas Mc Guire <der.herr@hofr.at>
Date: Thu, 21 Nov 2013 18:22:55 -0500
Subject: [PATCH] rebalance locks by converting write_lock_bh to write_lock+local_bh_disable
 

 in __neigh_event_send write_lock_bh(&neigh->lock) is implicitly balanced by
 write_unlock(&neigh->lock)+local_bh_disable() - while this is equivalent with
 respect to the effective low level locking primitives it breaks balancing
 in the locking api. This makes automatic lock-checking trigger false 
 positives, creates an implicit dependency between *_lock_bh and *_lock 
 functions as well as making the extremly simply locking of net core even
 easier to understand.

 The api inbalance was introduced in:
 commit cd28ca0a3dd17c68d24b839602a0e6268ad28b5d
 Author: Eric Dumazet <eric.dumazet@gmail.com>
 This patch just rebalances the lock api

 No change of functionality

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---
 net/core/neighbour.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index ca15f32..d681c75 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -966,7 +966,8 @@ int __neigh_event_send(struct neighbour *neigh, struct sk_buff *skb)
 	int rc;
 	bool immediate_probe = false;
 
-	write_lock_bh(&neigh->lock);
+	local_bh_disable();
+	write_lock(&neigh->lock);
 
 	rc = 0;
 	if (neigh->nud_state & (NUD_CONNECTED | NUD_DELAY | NUD_PROBE))
-- 
1.7.2.5
