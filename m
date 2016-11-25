From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 3/3] flowcache: Increase threshold for refusing new allocations
Date: Fri, 25 Nov 2016 07:58:00 +0100
Message-ID: <1480057080-20177-4-git-send-email-steffen.klassert@secunet.com>
References: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mx.secunet.com ([62.96.220.56]:45290 "EHLO c.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752756AbcKYHHW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 02:07:22 -0500
In-Reply-To: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miroslav Urbanek <mu@miroslavurbanek.com>

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
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1
