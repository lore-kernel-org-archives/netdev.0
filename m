From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 13:04:33 +1000
Message-ID: <20090427030433.GA17454@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42780 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbZD0DEj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Apr 2009 23:04:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now we have no upper limit on the size of the route cache hash table.
On a 128GB POWER6 box it ends up as 32MB:

    IP route cache hash table entries: 4194304 (order: 9, 33554432 bytes)

It would be nice to cap this just for memory consumption reasons, but this
massive hashtable also causes a significant spike when measuring OS
jitter.

With a 32MB hashtable and 4 million entries, rt_worker_func is taking
5 ms to complete. On another system with more memory it's taking 14 ms.
Even though rt_worker_func does call cond_sched() to limit its impact,
in an HPC environment we want to keep all sources of OS jitter to a minimum.

With the patch applied we limit the number of entries to 64k which
can still be overriden by using the rt_entries boot option:

    IP route cache hash table entries: 65536 (order: 3, 524288 bytes)

With this patch rt_worker_func takes 0.060 ms on the same system.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Is 64k a reasonable default for the limit?

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c40debe..5064c26 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -3397,7 +3397,7 @@ int __init ip_rt_init(void)
 					0,
 					&rt_hash_log,
 					&rt_hash_mask,
-					0);
+					rhash_entries ? 0 : 64 * 1024);
 	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
 	rt_hash_lock_init();
 

