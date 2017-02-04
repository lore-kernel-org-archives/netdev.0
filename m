From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 12/12] net: remove __napi_complete()
Date: Sat,  4 Feb 2017 15:25:02 -0800
Message-ID: <20170204232502.22361-13-edumazet@google.com>
References: <20170204232502.22361-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:33915 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751821AbdBDXZn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 18:25:43 -0500
Received: by mail-pg0-f48.google.com with SMTP id 14so17061637pgg.1
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2017 15:25:42 -0800 (PST)
In-Reply-To: <20170204232502.22361-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All __napi_complete() callers have been converted to
use the more standard napi_complete_done(),
we can now remove this NAPI method for good.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |  1 -
 net/core/dev.c            | 24 +++---------------------
 2 files changed, 3 insertions(+), 22 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6f18b509fb2f473029561d85646713c149df..014fbe256d55f843b72595e881d646dd5762 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -463,7 +463,6 @@ static inline bool napi_reschedule(struct napi_struct *napi)
 	return false;
 }
 
-bool __napi_complete(struct napi_struct *n);
 bool napi_complete_done(struct napi_struct *n, int work_done);
 /**
  *	napi_complete - NAPI processing complete
diff --git a/net/core/dev.c b/net/core/dev.c
index 42ba0379575a28525052a36620bfb30d38af..404d2e6d5d3233ad95edee18581276841573 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4883,23 +4883,6 @@ void __napi_schedule_irqoff(struct napi_struct *n)
 }
 EXPORT_SYMBOL(__napi_schedule_irqoff);
 
-bool __napi_complete(struct napi_struct *n)
-{
-	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
-
-	/* Some drivers call us directly, instead of calling
-	 * napi_complete_done().
-	 */
-	if (unlikely(test_bit(NAPI_STATE_IN_BUSY_POLL, &n->state)))
-		return false;
-
-	list_del_init(&n->poll_list);
-	smp_mb__before_atomic();
-	clear_bit(NAPI_STATE_SCHED, &n->state);
-	return true;
-}
-EXPORT_SYMBOL(__napi_complete);
-
 bool napi_complete_done(struct napi_struct *n, int work_done)
 {
 	unsigned long flags;
@@ -4926,14 +4909,13 @@ bool napi_complete_done(struct napi_struct *n, int work_done)
 		else
 			napi_gro_flush(n, false);
 	}
-	if (likely(list_empty(&n->poll_list))) {
-		WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
-	} else {
+	if (unlikely(!list_empty(&n->poll_list))) {
 		/* If n->poll_list is not empty, we need to mask irqs */
 		local_irq_save(flags);
-		__napi_complete(n);
+		list_del_init(&n->poll_list);
 		local_irq_restore(flags);
 	}
+	WARN_ON_ONCE(!test_and_clear_bit(NAPI_STATE_SCHED, &n->state));
 	return true;
 }
 EXPORT_SYMBOL(napi_complete_done);
-- 
2.11.0.483.g087da7b7c-goog
