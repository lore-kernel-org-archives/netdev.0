From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH] rfkill: disentangle polling pause and suspend
Date: Wed, 20 Jan 2016 10:44:34 +0100
Message-ID: <1453283074-23925-1-git-send-email-johannes@sipsolutions.net>
Cc: jprvita-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

When suspended while polling is paused, polling will erroneously
resume at resume time. Fix this by tracking pause and suspend in
separate state variable and adding the necessary checks.

Clarify the documentation on this as well.

Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 include/linux/rfkill.h |  3 ++-
 net/rfkill/core.c      | 17 +++++++++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index d9010789b4e8..7af625f6d226 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -104,7 +104,8 @@ int __must_check rfkill_register(struct rfkill *rfkill);
  *
  * Pause polling -- say transmitter is off for other reasons.
  * NOTE: not necessary for suspend/resume -- in that case the
- * core stops polling anyway
+ * core stops polling anyway (but will also correctly handle
+ * the case of polling having been paused before suspend.)
  */
 void rfkill_pause_polling(struct rfkill *rfkill);
 
diff --git a/net/rfkill/core.c b/net/rfkill/core.c
index f53bf3b6558b..166439995f34 100644
--- a/net/rfkill/core.c
+++ b/net/rfkill/core.c
@@ -57,6 +57,8 @@ struct rfkill {
 
 	bool			registered;
 	bool			persistent;
+	bool			polling_paused;
+	bool			suspended;
 
 	const struct rfkill_ops	*ops;
 	void			*data;
@@ -786,6 +788,7 @@ void rfkill_pause_polling(struct rfkill *rfkill)
 	if (!rfkill->ops->poll)
 		return;
 
+	rfkill->polling_paused = true;
 	cancel_delayed_work_sync(&rfkill->poll_work);
 }
 EXPORT_SYMBOL(rfkill_pause_polling);
@@ -797,6 +800,11 @@ void rfkill_resume_polling(struct rfkill *rfkill)
 	if (!rfkill->ops->poll)
 		return;
 
+	rfkill->polling_paused = false;
+
+	if (rfkill->suspended)
+		return;
+
 	queue_delayed_work(system_power_efficient_wq,
 			   &rfkill->poll_work, 0);
 }
@@ -807,7 +815,8 @@ static int rfkill_suspend(struct device *dev)
 {
 	struct rfkill *rfkill = to_rfkill(dev);
 
-	rfkill_pause_polling(rfkill);
+	rfkill->suspended = true;
+	cancel_delayed_work_sync(&rfkill->poll_work);
 
 	return 0;
 }
@@ -817,12 +826,16 @@ static int rfkill_resume(struct device *dev)
 	struct rfkill *rfkill = to_rfkill(dev);
 	bool cur;
 
+	rfkill->suspended = false;
+
 	if (!rfkill->persistent) {
 		cur = !!(rfkill->state & RFKILL_BLOCK_SW);
 		rfkill_set_block(rfkill, cur);
 	}
 
-	rfkill_resume_polling(rfkill);
+	if (rfkill->ops->poll && !rfkill->polling_paused)
+		queue_delayed_work(system_power_efficient_wq,
+				   &rfkill->poll_work, 0);
 
 	return 0;
 }
-- 
2.6.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
