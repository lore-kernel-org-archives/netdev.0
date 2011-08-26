From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/2] ath: Make ath_printk void not int and remove unused struct ath_common *
Date: Fri, 26 Aug 2011 01:56:39 -0700
Message-ID: <78869fcd8172cd02266b66a71aadbd0c0efbdebc.1314347556.git.joe@perches.com>
References: <cover.1314347556.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1314347556.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changing the return type and removing the unused argument from
ath_printk reduces code size.

Add an __always_unused struct ath_common * to the macros
that call ath_printk to avoid unused variable warnings.

$ size drivers/net/wireless/ath/built-in.o*
   text	   data	    bss	    dec	    hex	filename
1159859	  16235	 212000	1388094	 152e3e	drivers/net/wireless/ath/built-in.o.new
1164175	  16235	 212032	1392442	 153f3a	drivers/net/wireless/ath/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath.h  |   27 ++++++++++++++++-----------
 drivers/net/wireless/ath/main.c |    8 ++------
 2 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index a3f8505..9891fb6 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -178,24 +178,29 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
-extern __attribute__((format (printf, 3, 4)))
-int ath_printk(const char *level, struct ath_common *common,
-	       const char *fmt, ...);
+extern __attribute__((format (printf, 2, 3)))
+void ath_printk(const char *level, const char *fmt, ...);
+
+#define _ath_printk(level, common, fmt, ...)			\
+do {								\
+	__always_unused struct ath_common *unused = common;	\
+	ath_printk(level, fmt, ##__VA_ARGS__);			\
+} while (0)
 
 #define ath_emerg(common, fmt, ...)				\
-	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS__)
 #define ath_alert(common, fmt, ...)				\
-	ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS__)
 #define ath_crit(common, fmt, ...)				\
-	ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS__)
 #define ath_err(common, fmt, ...)				\
-	ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS__)
 #define ath_warn(common, fmt, ...)				\
-	ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS__)
 #define ath_notice(common, fmt, ...)				\
-	ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS__)
 #define ath_info(common, fmt, ...)				\
-	ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
+	_ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS__)
 
 /**
  * enum ath_debug_level - atheros wireless debug level
@@ -250,7 +255,7 @@ enum ATH_DEBUG {
 #define ath_dbg(common, dbg_mask, fmt, ...)				\
 do {									\
 	if ((common)->debug_mask & dbg_mask)				\
-		ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__);	\
+		_ath_printk(KERN_DEBUG, common, fmt, ##__VA_ARGS__);	\
 } while (0)
 
 #define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
index c325202..d9218fe 100644
--- a/drivers/net/wireless/ath/main.c
+++ b/drivers/net/wireless/ath/main.c
@@ -57,22 +57,18 @@ struct sk_buff *ath_rxbuf_alloc(struct ath_common *common,
 }
 EXPORT_SYMBOL(ath_rxbuf_alloc);
 
-int ath_printk(const char *level, struct ath_common *common,
-	       const char *fmt, ...)
+void ath_printk(const char *level, const char *fmt, ...)
 {
 	struct va_format vaf;
 	va_list args;
-	int rtn;
 
 	va_start(args, fmt);
 
 	vaf.fmt = fmt;
 	vaf.va = &args;
 
-	rtn = printk("%sath: %pV", level, &vaf);
+	printk("%sath: %pV", level, &vaf);
 
 	va_end(args);
-
-	return rtn;
 }
 EXPORT_SYMBOL(ath_printk);
-- 
1.7.6.405.gc1be0
