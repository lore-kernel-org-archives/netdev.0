From: Christoph Lameter <cl@linux.com>
Subject: [PERCPU] Remove & in front of this_cpu_ptr
Date: Wed, 3 Apr 2013 20:42:33 +0000
Message-ID: <0000013dd1a300fb-1fbb26a9-77a7-4c24-95ff-f088309206d9-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com> <1364833887.5113.161.camel@edumazet-glaptop> <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Tejun Heo <htejun@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a9-50.smtp-out.amazonses.com ([54.240.9.50]:47668 "EHLO
	a9-50.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761357Ab3DCUtp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 16:49:45 -0400
In-Reply-To: <alpine.DEB.2.02.1304031540110.3444@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: percpu: Remove & in front of this_cpu_ptr

Both

	this_cpu_ptr(&percpu_pointer->field)


[Add Offset in percpu pointer to the field offset in the struct
and then add to the local percpu base]

as well as

	 &this_cpu_ptr(percpu_pointer)->field

[Add percpu variable offset to local percpu base to form an address
and then add the field offset to the address].

are correct. However, the latter looks a bit more complicated.
The first one is easier to understand. The second one may be
more difficult for the compiler to optimize as well.

Convert all of them to this_cpu_ptr(&percpu_pointer->field).

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/fs/gfs2/rgrp.c
===================================================================
--- linux.orig/fs/gfs2/rgrp.c	2013-04-03 15:25:22.576562629 -0500
+++ linux/fs/gfs2/rgrp.c	2013-04-03 15:26:43.045773676 -0500
@@ -1726,7 +1726,7 @@ static bool gfs2_rgrp_congested(const st
 	s64 var;

 	preempt_disable();
-	st = &this_cpu_ptr(sdp->sd_lkstats)->lkstats[LM_TYPE_RGRP];
+	st = this_cpu_ptr(&sdp->sd_lkstats->lkstats[LM_TYPE_RGRP]);
 	r_srttb = st->stats[GFS2_LKS_SRTTB];
 	r_dcount = st->stats[GFS2_LKS_DCOUNT];
 	var = st->stats[GFS2_LKS_SRTTVARB] +
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c	2013-04-03 15:25:22.576562629 -0500
+++ linux/mm/page_alloc.c	2013-04-03 15:30:02.124769119 -0500
@@ -1342,7 +1342,7 @@ void free_hot_cold_page(struct page *pag
 		migratetype = MIGRATE_MOVABLE;
 	}

-	pcp = &this_cpu_ptr(zone->pageset)->pcp;
+	pcp = this_cpu_ptr(&zone->pageset->pcp);
 	if (cold)
 		list_add_tail(&page->lru, &pcp->lists[migratetype]);
 	else
@@ -1484,7 +1484,7 @@ again:
 		struct list_head *list;

 		local_irq_save(flags);
-		pcp = &this_cpu_ptr(zone->pageset)->pcp;
+		pcp = this_cpu_ptr(&zone->pageset->pcp);
 		list = &pcp->lists[migratetype];
 		if (list_empty(list)) {
 			pcp->count += rmqueue_bulk(zone, 0,
Index: linux/net/core/flow.c
===================================================================
--- linux.orig/net/core/flow.c	2013-04-03 15:25:22.576562629 -0500
+++ linux/net/core/flow.c	2013-04-03 15:26:43.045773676 -0500
@@ -328,7 +328,7 @@ static void flow_cache_flush_per_cpu(voi
 	struct flow_flush_info *info = data;
 	struct tasklet_struct *tasklet;

-	tasklet = &this_cpu_ptr(info->cache->percpu)->flush_tasklet;
+	tasklet = this_cpu_ptr(&info->cache->percpu->flush_tasklet);
 	tasklet->data = (unsigned long)info;
 	tasklet_schedule(tasklet);
 }
