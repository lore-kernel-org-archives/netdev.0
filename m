From: joonwpark81@gmail.com
Subject: Re: [PATCH] [IPV4] route: fix locking in rt_run_flush()
Date: Wed, 23 Jan 2008 16:43:20 +0900
Message-ID: <20080123074320.GB9017@ehus.geninetworks.com>
References: <12009281372201-git-send-email-joonwpark81@gmail.com> <20080121.024043.105024413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:56978 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752421AbYAWHnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 02:43:24 -0500
Received: by py-out-1112.google.com with SMTP id u52so4017179pyb.10
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2008 23:43:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.024043.105024413.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 21, 2008 at 02:40:43AM -0800, David Miller wrote:
> From: Joonwoo Park <joonwpark81@gmail.com>
> Date: Tue, 22 Jan 2008 00:08:57 +0900
> 
> > The rt_run_flush() can be stucked if it was called while netdev is on the 
> > high load.
> > It's possible when pushing rtable to rt_hash is faster than pulling
> > from it.
> > 
> > Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> 
> I agree with the analysis of the problem, however not the solution.
> 
> This will absolutely kill software interrupt latency.
> 
> In fact, we have moved much of the flush work into a workqueue in
> net-2.6.25 because of how important that is
> 
> We need to find some other way to solve this.
> 

Dave, Eric,
Thanks so much for comments.

I did stress tests and I found that the real problem was not consumer & supplier
issue.
It was the problem for me to innumerable enabling & disabling the softirq.
But I'm still thinking need of considering issue 'faster caching than flush'. :) 

ifconfig up on heavy loaded interface.
Before patching:
 time ifconfig eth1 up
 BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
 ...

After patching:
 time ifconfig eth1 up
real	0m0.007s
user	0m0.000s
sys	0m0.004s

Thanks!
Joonwoo


>From 87c29506de967e811ad5b57cd2e1a002134e878f Mon Sep 17 00:00:00 2001
From: Joonwoo Park <joonwpark81@gmail.com>
Date: Wed, 23 Jan 2008 15:16:54 +0900
Subject: [PATCH] [IPV4] route: reduce locking/unlocking in rt_run_flush

The rt_run_flush does spin_lock_bh/spin_unlock_bh for rt_hash_mask + 1
times.
The rt_hash_mask takes from 32767 to 65535, so it's big overhead.
In addition, disable_bh/enable_bh for many times in the rt_run_flush
can cause stuck on a machine with heavily pended softirqs.

This patch reduces locking/unlocking as doing it with jumping the lock
slots.

ifconfig up on heavy loaded interface.
Before:
 time ifconfig eth1 up
 BUG: soft lockup - CPU#0 stuck for 11s! [events/0:9]
 ...

After:
 time ifconfig eth1 up
real	0m0.007s
user	0m0.000s
sys	0m0.004s

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
---
 net/ipv4/route.c |   38 +++++++++++++++++++++++++++-----------
 1 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 28484f3..79a401f 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -239,9 +239,20 @@ static spinlock_t	*rt_hash_locks;
 		for (i = 0; i < RT_HASH_LOCK_SZ; i++) \
 			spin_lock_init(&rt_hash_locks[i]); \
 		}
+# define rt_hash_lock(lock) &rt_hash_locks[lock]
+# define rt_hash_for_each_lock(lock) \
+	for (lock = 0; lock < RT_HASH_LOCK_SZ; lock++)
+# define rt_hash_for_each_slot(slot, lock, mask) \
+	for (slot = 0, mask = lock; \
+		slot < ((int)rt_hash_mask + 1) / RT_HASH_LOCK_SZ; \
+		slot++, mask = (slot * RT_HASH_LOCK_SZ) + lock)
 #else
 # define rt_hash_lock_addr(slot) NULL
 # define rt_hash_lock_init()
+# define rt_hash_lock(lock) NULL
+# define rt_hash_for_each_lock(lock) do { lock = 0; } while (0);
+# define rt_hash_for_each_slot(slot, lock, mask) \
+	for (slot = 0, lock = 0, mask = 0; mask <= rt_hash_mask; mask++)
 #endif
 
 static struct rt_hash_bucket 	*rt_hash_table;
@@ -613,24 +624,29 @@ static void rt_check_expire(struct work_struct *work)
  */
 static void rt_run_flush(unsigned long dummy)
 {
-	int i;
+	int slot, lock, mask;
 	struct rtable *rth, *next;
 
 	rt_deadline = 0;
 
 	get_random_bytes(&rt_hash_rnd, 4);
 
-	for (i = rt_hash_mask; i >= 0; i--) {
-		spin_lock_bh(rt_hash_lock_addr(i));
-		rth = rt_hash_table[i].chain;
-		if (rth)
-			rt_hash_table[i].chain = NULL;
-		spin_unlock_bh(rt_hash_lock_addr(i));
-
-		for (; rth; rth = next) {
-			next = rth->u.dst.rt_next;
-			rt_free(rth);
+	rt_hash_for_each_lock(lock) {
+		spin_lock_bh(rt_hash_lock(lock));
+		rt_hash_for_each_slot(slot, lock, mask) {
+			rth = rt_hash_table[mask].chain;
+
+			if (rth) {
+				rt_hash_table[mask].chain = NULL;
+				spin_unlock_bh(rt_hash_lock(lock));
+				for (; rth; rth = next) {
+					next = rth->u.dst.rt_next;
+					rt_free(rth);
+				}
+				spin_lock_bh(rt_hash_lock(lock));
+			}
 		}
+		spin_unlock_bh(rt_hash_lock(lock));
 	}
 }
 
-- 
1.5.3.rc5

