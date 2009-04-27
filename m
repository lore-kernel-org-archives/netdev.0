From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH] Limit size of route cache hash table
Date: Mon, 27 Apr 2009 21:50:07 +1000
Message-ID: <20090427115007.GC15891@kryten>
References: <49F53FF6.2040603@cosmosbay.com> <20090427054702.GA15891@kryten> <49F54CC5.7020600@cosmosbay.com> <20090426.233638.83897914.davem@davemloft.net> <49F5550A.1050805@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36116 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751152AbZD0Lv1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 07:51:27 -0400
Content-Disposition: inline
In-Reply-To: <49F5550A.1050805@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Right now we have no upper limit on the size of the route cache hash table.
On a 128GB POWER6 box it ends up as 32MB:

    IP route cache hash table entries: 4194304 (order: 9, 33554432 bytes)

It would be nice to cap this for memory consumption reasons, but a massive
hashtable also causes a significant spike when measuring OS jitter.

With a 32MB hashtable and 4 million entries, rt_worker_func is taking
5 ms to complete. On another system with more memory it's taking 14 ms.
Even though rt_worker_func does call cond_sched() to limit its impact,
in an HPC environment we want to keep all sources of OS jitter to a minimum.

With the patch applied we limit the number of entries to 512k which
can still be overriden by using the rt_entries boot option:

    IP route cache hash table entries: 524288 (order: 6, 4194304 bytes)

With this patch rt_worker_func now takes 0.460 ms on the same system.

Signed-off-by: Anton Blanchard <anton@samba.org>
Acked-by: Eric Dumazet <dada1@cosmosbay.com>
---

Index: linux-2.6/net/ipv4/route.c
===================================================================
--- linux-2.6.orig/net/ipv4/route.c	2009-04-27 12:48:18.000000000 +1000
+++ linux-2.6/net/ipv4/route.c	2009-04-27 17:05:46.000000000 +1000
@@ -3397,7 +3397,7 @@
 					0,
 					&rt_hash_log,
 					&rt_hash_mask,
-					0);
+					rhash_entries ? 0 : 512 * 1024);
 	memset(rt_hash_table, 0, (rt_hash_mask + 1) * sizeof(struct rt_hash_bucket));
 	rt_hash_lock_init();
 
