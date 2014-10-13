From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: [PATCH stable 3.2 3.4] ipv4: disable bh while doing route gc
Date: Mon, 13 Oct 2014 13:20:38 -0300
Message-ID: <6c3d6eca5d6a15c01393b010f2116bd169477c5a.1413215324.git.mleitner@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54312 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100AbaJMQU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Oct 2014 12:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further tests revealed that after moving the garbage collector to a work
queue and protecting it with a spinlock may leave the system prone to
soft lockups if bottom half gets very busy.

It was reproced with a set of firewall rules that REJECTed packets. If
the NIC bottom half handler ends up running on the same CPU that is
running the garbage collector on a very large cache, the garbage
collector will not be able to do its job due to the amount of work
needed for handling the REJECTs and also won't reschedule.

The fix is to disable bottom half during the garbage collecting, as it
already was in the first place (most calls to it came from softirqs).

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Notes:
    Hi Dave,
    
    This is needed for stables 3.2 and 3.4, as those are the ones that we
    applied the previous patches:
        ipv4: move route garbage collector to work queue
        ipv4: avoid parallel route cache gc executions
    
    Thanks.

 net/ipv4/route.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9e7909eef8d10107008f8d629f9f2d75fde52eb2..6c34bc98bce7147cf6c242439f2afeb9adf28c72 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -998,7 +998,7 @@ static void __do_rt_garbage_collect(int elasticity, int min_interval)
 	 * do not make it too frequently.
 	 */
 
-	spin_lock(&rt_gc_lock);
+	spin_lock_bh(&rt_gc_lock);
 
 	RT_CACHE_STAT_INC(gc_total);
 
@@ -1101,7 +1101,7 @@ work_done:
 	    dst_entries_get_slow(&ipv4_dst_ops) < ipv4_dst_ops.gc_thresh)
 		expire = ip_rt_gc_timeout;
 out:
-	spin_unlock(&rt_gc_lock);
+	spin_unlock_bh(&rt_gc_lock);
 }
 
 static void __rt_garbage_collect(struct work_struct *w)
-- 
1.9.3
