From: greearb@candelatech.com
Subject: [PATCH] ath9k:  Add wiphy name to log messages.
Date: Wed,  7 Mar 2012 16:05:06 -0800
Message-ID: <1331165106-10359-1-git-send-email-greearb@candelatech.com>
Cc: netdev@vger.kernel.org, Ben Greear <greearb@candelatech.com>
To: ath9k-devel@venema.h4ckr.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55045 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756993Ab2CHAFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 19:05:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

On systems with multiple NICs, it's nice to know which
one is producing warnings.  Here is an example of the
new ouput:

ath: wiphy0: Failed to stop TX DMA, queues=0x005!

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 efc0111... 54f255d... M	drivers/net/wireless/ath/ath.h
:100644 100644 d9218fe... ea2c737... M	drivers/net/wireless/ath/main.c
 drivers/net/wireless/ath/ath.h  |    7 ++++---
 drivers/net/wireless/ath/main.c |    9 +++++++--
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index efc0111..54f255d 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -174,12 +174,13 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
-extern __printf(2, 3) void ath_printk(const char *level, const char *fmt, ...);
+extern __printf(3, 4) void ath_printk(const char *level,
+				      const struct ath_common *common,
+				      const char *fmt, ...);
 
 #define _ath_printk(level, common, fmt, ...)			\
 do {								\
-	__always_unused struct ath_common *unused = common;	\
-	ath_printk(level, fmt, ##__VA_ARGS__);			\
+	ath_printk(level, common, fmt, ##__VA_ARGS__);		\
 } while (0)
 
 #define ath_emerg(common, fmt, ...)				\
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
