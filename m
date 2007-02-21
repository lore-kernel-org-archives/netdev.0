From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 29/29] balance_dirty_pages() vs throttle_vm_writeout() deadlock
Date: Wed, 21 Feb 2007 15:43:33 +0100
Message-ID: <20070221144844.410363000@taijtu.programming.kicks-ass.net>
References: <20070221144304.512721000@taijtu.programming.kicks-ass.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:34546 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313AbXBUPFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Feb 2007 10:05:36 -0500
Content-Disposition: inline; filename=nfs_mm-throttle_vm_writeout.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If we have a lot of dirty memory and hit the throttle in balance_dirty_pages()
we (potentially) generate a lot of writeback and unstable pages, if however
during this writeback we need to reclaim a bit, we might hit
throttle_vm_writeout(), which might delay us until the combined total of
NR_UNSTABLE_NFS + NR_WRITEBACK falls below the dirty limit.

However unstable pages don't go away automagickally, they need a push. While
balance_dirty_pages() does this push, throttle_vm_writeout() doesn't. So we can
sit here ad infintum.

Hence I propose to remove the NR_UNSTABLE_NFS count from throttle_vm_writeout().

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 mm/page-writeback.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

Index: linux-2.6-git/mm/page-writeback.c
===================================================================
--- linux-2.6-git.orig/mm/page-writeback.c	2007-02-20 15:07:43.000000000 +0100
+++ linux-2.6-git/mm/page-writeback.c	2007-02-20 16:42:45.000000000 +0100
@@ -310,8 +310,7 @@ void throttle_vm_writeout(void)
                  */
                 dirty_thresh += dirty_thresh / 10;      /* wheeee... */
 
-                if (global_page_state(NR_UNSTABLE_NFS) +
-			global_page_state(NR_WRITEBACK) <= dirty_thresh)
+                if (global_page_state(NR_WRITEBACK) <= dirty_thresh)
                         	break;
                 congestion_wait(WRITE, HZ/10);
         }

-- 

