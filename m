From: greearb@candelatech.com
Subject: [PATCH v2] ath9k:  Add wiphy name to log messages.
Date: Thu,  8 Mar 2012 10:20:55 -0800
Message-ID: <1331230855-1265-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: ath9k-devel@venema.h4ckr.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:37247 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194Ab2CHSVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 13:21:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

On systems with multiple NICs, it's nice to know which
one is producing warnings.  Here is an example of the
new ouput:

ath: wiphy0: Failed to stop TX DMA, queues=0x005!

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v2:  Remove _ath_printk macro, minor formatting changes.

:100644 100644 efc0111... c54b7d37.. M	drivers/net/wireless/ath/ath.h
:100644 100644 d9218fe... ea2c737... M	drivers/net/wireless/ath/main.c
 drivers/net/wireless/ath/ath.h  |   26 +++++++++++---------------
 drivers/net/wireless/ath/main.c |    9 +++++++--
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index efc0111..c54b7d37 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -174,28 +174,24 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
-extern __printf(2, 3) void ath_printk(const char *level, const char *fmt, ...);
-
-#define _ath_printk(level, common, fmt, ...)			\
-do {								\
-	__always_unused struct ath_common *unused = common;	\
-	ath_printk(level, fmt, ##__VA_ARGS__);			\
-} while (0)
+__printf(3, 4)
+void ath_printk(const char *level, const struct ath_common *common,
+		const char *fmt, ...);
 
 #define ath_emerg(common, fmt, ...)				\
-	_ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
 #define ath_alert(common, fmt, ...)				\
-	_ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
 #define ath_crit(common, fmt, ...)				\
-	_ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
 #define ath_err(common, fmt, ...)				\
-	_ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
 #define ath_warn(common, fmt, ...)				\
-	_ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
 #define ath_notice(common, fmt, ...)				\
-	_ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
 #define ath_info(common, fmt, ...)				\
-	_ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
+	ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
 
 /**
  * enum ath_debug_level - atheros wireless debug level
@@ -256,7 +252,7 @@ enum ATH_DEBUG {
 #define ath_dbg(common, dbg_mask, fmt, ...)				\
 do {									\
 	if ((common)->debug_mask & ATH_DBG_##dbg_mask)			\
-		_ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__);	\
+		ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__);	\
 } while (0)
 
 #define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
index d9218fe..ea2c737 100644
--- a/drivers/net/wireless/ath/main.c
+++ b/drivers/net/wireless/ath/main.c
@@ -57,7 +57,8 @@ struct sk_buff *ath_rxbuf_alloc(struct ath_common *common,
 }
 EXPORT_SYMBOL(ath_rxbuf_alloc);
 
-void ath_printk(const char *level, const char *fmt, ...)
+void ath_printk(const char *level, const struct ath_common* common,
+		const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
@@ -67,7 +68,11 @@ void ath_printk(const char *level, const char *fmt, ...)
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	printk("%sath: %pV", level, &vaf);
+	if (common && common->hw && common->hw->wiphy)
+		printk("%sath: %s: %pV",
+		       level, wiphy_name(common->hw->wiphy), &vaf);
+	else
+		printk("%sath: %pV", level, &vaf);
 
 	va_end(args);
 }
-- 
1.7.3.4
