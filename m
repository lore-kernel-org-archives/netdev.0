From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 3/5] net: busy-poll: return busypolling status to drivers
Date: Tue, 15 Nov 2016 10:15:13 -0800
Message-ID: <1479233715-9905-4-git-send-email-edumazet@google.com>
References: <1479233715-9905-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Adam Belay <abelay@google.com>, Zach Brown <zach.brown@ni.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <ariel.elior@cavium.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:36162 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933639AbcKOSQC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 13:16:02 -0500
Received: by mail-pg0-f53.google.com with SMTP id f188so69002525pgc.3
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 10:16:01 -0800 (PST)
In-Reply-To: <1479233715-9905-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NAPI drivers use napi_complete_done() or napi_complete() when
they drained RX ring and right before re-enabling device interrupts.

In busy polling, we can avoid interrupts being delivered since
we are polling RX ring in a controlled loop.

Drivers can chose to use napi_complete_done() return value
to reduce interrupts overhead while busy polling is active.

This is optional, legacy drivers should work fine even
if not updated.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Willem de Bruijn <willemb@google.com>
Cc: Adam Belay <abelay@google.com>
Cc: Tariq Toukan <tariqt@mellanox.com>
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
Cc: Ariel Elior <ariel.elior@cavium.com>
---
 include/linux/netdevice.h |  7 ++++---
 net/core/dev.c            | 10 ++++++----
 2 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e71de66e3792..bcddf951ccee 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -463,16 +463,17 @@ static inline bool napi_reschedule(struct napi_struct *napi)
 	return false;
 }
 
-void __napi_complete(struct napi_struct *n);
-void napi_complete_done(struct napi_struct *n, int work_done);
+bool __napi_complete(struct napi_struct *n);
+bool napi_complete_done(struct napi_struct *n, int work_done);
 /**
  *	napi_complete - NAPI processing complete
  *	@n: NAPI context
  *
  * Mark NAPI processing as complete.
  * Consider using napi_complete_done() instead.
+ * Return false if device should avoid rearming interrupts.
  */
-static inline void napi_complete(struct napi_struct *n)
+static inline bool napi_complete(struct napi_struct *n)
 {
 	return napi_complete_done(n, 0);
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 369dcc8efc01..edba9efeb2e9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4898,7 +4898,7 @@ void __napi_schedule_irqoff(struct napi_struct *n)
 }
 EXPORT_SYMBOL(__napi_schedule_irqoff);
 
-void __napi_complete(struct napi_struct *n)
+bool __napi_complete(struct napi_struct *n)
 {
 	BUG_ON(!test_bit(NAPI_STATE_SCHED, &n->state));
 
@@ -4906,15 +4906,16 @@ void __napi_complete(struct napi_struct *n)
 	 * napi_complete_done().
 	 */
 	if (unlikely(test_bit(NAPI_STATE_IN_BUSY_POLL, &n->state)))
-		return;
+		return false;
 
 	list_del_init(&n->poll_list);
 	smp_mb__before_atomic();
 	clear_bit(NAPI_STATE_SCHED, &n->state);
+	return true;
 }
 EXPORT_SYMBOL(__napi_complete);
 
-void napi_complete_done(struct napi_struct *n, int work_done)
+bool napi_complete_done(struct napi_struct *n, int work_done)
 {
 	unsigned long flags;
 
@@ -4926,7 +4927,7 @@ void napi_complete_done(struct napi_struct *n, int work_done)
 	 */
 	if (unlikely(n->state & (NAPIF_STATE_NPSVC |
 				 NAPIF_STATE_IN_BUSY_POLL)))
-		return;
+		return false;
 
 	if (n->gro_list) {
 		unsigned long timeout = 0;
@@ -4948,6 +4949,7 @@ void napi_complete_done(struct napi_struct *n, int work_done)
 		__napi_complete(n);
 		local_irq_restore(flags);
 	}
+	return true;
 }
 EXPORT_SYMBOL(napi_complete_done);
 
-- 
2.8.0.rc3.226.g39d4020
