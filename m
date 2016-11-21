From: Miroslav Urbanek <mu@miroslavurbanek.com>
Subject: [PATCH] flowcache: Increase threshold for refusing new allocations
Date: Mon, 21 Nov 2016 15:48:21 +0100
Message-ID: <20161121144820.GA4048@miroslavurbanek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: NetDev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.smtp.cz ([81.95.97.115]:42873 "EHLO relay.smtp.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754228AbcKUOy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Nov 2016 09:54:27 -0500
Received: from antirelay02.smtp.cz (antirelay02.smtp.cz [81.95.105.132])
        by relay.smtp.cz (Postfix) with ESMTPS id EB9DB20BA99
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2016 15:48:27 +0100 (CET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The threshold for OOM protection is too small for systems with large
number of CPUs. Applications report ENOBUFs on connect() every 10
minutes.

The problem is that the variable net->xfrm.flow_cache_gc_count is a
global counter while the variable fc->high_watermark is a per-CPU
constant. Take the number of CPUs into account as well.

Fixes: 6ad3122a08e3 ("flowcache: Avoid OOM condition under preasure")
Reported-by: Lukáš Koldrt <lk@excello.cz>
Tested-by: Jan Hejl <jh@excello.cz>
Signed-off-by: Miroslav Urbanek <mu@miroslavurbanek.com>
---
 net/core/flow.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 3937b1b..18e8893 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -95,7 +95,6 @@ static void flow_cache_gc_task(struct work_struct *work)
 	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list) {
 		flow_entry_kill(fce, xfrm);
 		atomic_dec(&xfrm->flow_cache_gc_count);
-		WARN_ON(atomic_read(&xfrm->flow_cache_gc_count) < 0);
 	}
 }
 
@@ -236,9 +235,8 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fcp->hash_count > fc->high_watermark)
 			flow_cache_shrink(fc, fcp);
 
-		if (fcp->hash_count > 2 * fc->high_watermark ||
-		    atomic_read(&net->xfrm.flow_cache_gc_count) > fc->high_watermark) {
-			atomic_inc(&net->xfrm.flow_cache_genid);
+		if (atomic_read(&net->xfrm.flow_cache_gc_count) >
+		    2 * num_online_cpus() * fc->high_watermark) {
 			flo = ERR_PTR(-ENOBUFS);
 			goto ret_object;
 		}
-- 
2.7.3
