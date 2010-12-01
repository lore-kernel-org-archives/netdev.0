From: Joe Perches <joe@perches.com>
Subject: [PATCH] ath: Add and use ath_printk and ath_<level>
Date: Wed,  1 Dec 2010 09:44:18 -0800
Message-ID: <d2a73495a7295cbd01ffd820761f538bc301f6aa.1291224405.git.joe@perches.com>
References: <4CF65DB9.3050007@openwrt.org>
Cc: ath9k-devel@lists.ath9k.org, Peter Stuge <peter@stuge.se>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Felix Fietkau <nbd@openwrt.org>,
	"Luis R. Rodriguez" <lrodriguez@atheros.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CF65DB9.3050007@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add ath_printk and ath_<level> similar to
dev_printk and dev_<level> from device.h

This allows a more gradual rename of ath_print
to to ath_dbg or perhaps ath_debug.

This basically removes debug.h leaving
only an #define ath_printk ath_dbg
there and moving all the ATH_DBG_<foo>
enums to ath.h

I do not think there's much purpose for struct
ath_common * being passed to the ath_printk
functions, but perhaps there might be.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath.h   |  103 ++++++++++++++++++++++++++++++++++++++
 drivers/net/wireless/ath/debug.c |   20 -------
 drivers/net/wireless/ath/debug.h |   72 +--------------------------
 drivers/net/wireless/ath/main.c  |   20 +++++++
 4 files changed, 124 insertions(+), 91 deletions(-)

diff --git a/drivers/net/wireless/ath/ath.h b/drivers/net/wireless/ath/ath.h
index 26bdbee..5a598b9 100644
--- a/drivers/net/wireless/ath/ath.h
+++ b/drivers/net/wireless/ath/ath.h
@@ -186,4 +186,107 @@ bool ath_hw_keyreset(struct ath_common *common, u16 entry);
 void ath_hw_cycle_counters_update(struct ath_common *common);
 int32_t ath_hw_get_listen_time(struct ath_common *common);
 
+extern __attribute__ ((format (printf, 3, 4))) int
+ath_printk(const char *level, struct ath_common *common, const char *fmt, ...);
+
+#define ath_emerg(common, fmt, ...)				\
+	ath_printk(KERN_EMERG, common, fmt, ##__VA_ARGS)
+#define ath_alert(common, fmt, ...)				\
+	ath_printk(KERN_ALERT, common, fmt, ##__VA_ARGS)
+#define ath_crit(common, fmt, ...)				\
+	ath_printk(KERN_CRIT, common, fmt, ##__VA_ARGS)
+#define ath_err(common, fmt, ...)				\
+	ath_printk(KERN_ERR, common, fmt, ##__VA_ARGS)
+#define ath_warn(common, fmt, ...)				\
+	ath_printk(KERN_WARNING, common, fmt, ##__VA_ARGS)
+#define ath_notice(common, fmt, ...)				\
+	ath_printk(KERN_NOTICE, common, fmt, ##__VA_ARGS)
+#define ath_info(common, fmt, ...)				\
+	ath_printk(KERN_INFO, common, fmt, ##__VA_ARGS)
+
+/**
+ * enum ath_debug_level - atheros wireless debug level
+ *
+ * @ATH_DBG_RESET: reset processing
+ * @ATH_DBG_QUEUE: hardware queue management
+ * @ATH_DBG_EEPROM: eeprom processing
+ * @ATH_DBG_CALIBRATE: periodic calibration
+ * @ATH_DBG_INTERRUPT: interrupt processing
+ * @ATH_DBG_REGULATORY: regulatory processing
+ * @ATH_DBG_ANI: adaptive noise immunitive processing
+ * @ATH_DBG_XMIT: basic xmit operation
+ * @ATH_DBG_BEACON: beacon handling
+ * @ATH_DBG_CONFIG: configuration of the hardware
+ * @ATH_DBG_FATAL: fatal errors, this is the default, DBG_DEFAULT
+ * @ATH_DBG_PS: power save processing
+ * @ATH_DBG_HWTIMER: hardware timer handling
+ * @ATH_DBG_BTCOEX: bluetooth coexistance
+ * @ATH_DBG_BSTUCK: stuck beacons
+ * @ATH_DBG_ANY: enable all debugging
+ *
+ * The debug level is used to control the amount and type of debugging output
+ * we want to see. Each driver has its own method for enabling debugging and
+ * modifying debug level states -- but this is typically done through a
+ * module parameter 'debug' along with a respective 'debug' debugfs file
+ * entry.
+ */
+enum ATH_DEBUG {
+	ATH_DBG_RESET		= 0x00000001,
+	ATH_DBG_QUEUE		= 0x00000002,
+	ATH_DBG_EEPROM		= 0x00000004,
+	ATH_DBG_CALIBRATE	= 0x00000008,
+	ATH_DBG_INTERRUPT	= 0x00000010,
+	ATH_DBG_REGULATORY	= 0x00000020,
+	ATH_DBG_ANI		= 0x00000040,
+	ATH_DBG_XMIT		= 0x00000080,
+	ATH_DBG_BEACON		= 0x00000100,
+	ATH_DBG_CONFIG		= 0x00000200,
+	ATH_DBG_FATAL		= 0x00000400,
+	ATH_DBG_PS		= 0x00000800,
+	ATH_DBG_HWTIMER		= 0x00001000,
+	ATH_DBG_BTCOEX		= 0x00002000,
+	ATH_DBG_WMI		= 0x00004000,
+	ATH_DBG_BSTUCK		= 0x00008000,
+	ATH_DBG_ANY		= 0xffffffff
+};
+
+#define ATH_DBG_DEFAULT (ATH_DBG_FATAL)
+
+#ifdef CONFIG_ATH_DEBUG
+
+#define ath_dbg(common, dbg_mask, fmt, ...)			\
+({								\
+	int rtn;						\
+	if ((common)->debug_mask & dbg_mask)			\
+		rtn = ath_printk(KERN_DEBUG, common, fmt,	\
+				 ##__VA_ARGS__);		\
+	else							\
+		rtn = 0;					\
+								\
+	rtn;							\
+})
+#define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
+
+#else
+
+static inline  __attribute__ ((format (printf, 3, 4))) int
+ath_dbg(struct ath_common *common, enum ATH_DEBUG dbg_mask,
+	const char *fmt, ...)
+{
+	return 0;
+}
+#define ATH_DBG_WARN(foo, arg) do {} while (0)
+
+#endif /* CONFIG_ATH_DEBUG */
+
+/** Returns string describing opmode, or NULL if unknown mode. */
+#ifdef CONFIG_ATH_DEBUG
+const char *ath_opmode_to_string(enum nl80211_iftype opmode);
+#else
+static inline const char *ath_opmode_to_string(enum nl80211_iftype opmode)
+{
+	return "UNKNOWN";
+}
+#endif
+
 #endif /* ATH_H */
diff --git a/drivers/net/wireless/ath/debug.c b/drivers/net/wireless/ath/debug.c
index a9600ba..5367b10 100644
--- a/drivers/net/wireless/ath/debug.c
+++ b/drivers/net/wireless/ath/debug.c
@@ -15,26 +15,6 @@
  */
 
 #include "ath.h"
-#include "debug.h"
-
-void ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
-{
-	struct va_format vaf;
-	va_list args;
-
-	if (likely(!(common->debug_mask & dbg_mask)))
-		return;
-
-	va_start(args, fmt);
-
-	vaf.fmt = fmt;
-	vaf.va = &args;
-
-	printk(KERN_DEBUG "ath: %pV", &vaf);
-
-	va_end(args);
-}
-EXPORT_SYMBOL(ath_print);
 
 const char *ath_opmode_to_string(enum nl80211_iftype opmode)
 {
diff --git a/drivers/net/wireless/ath/debug.h b/drivers/net/wireless/ath/debug.h
index f207007..cec951c 100644
--- a/drivers/net/wireless/ath/debug.h
+++ b/drivers/net/wireless/ath/debug.h
@@ -17,76 +17,6 @@
 #ifndef ATH_DEBUG_H
 #define ATH_DEBUG_H
 
-#include "ath.h"
-
-/**
- * enum ath_debug_level - atheros wireless debug level
- *
- * @ATH_DBG_RESET: reset processing
- * @ATH_DBG_QUEUE: hardware queue management
- * @ATH_DBG_EEPROM: eeprom processing
- * @ATH_DBG_CALIBRATE: periodic calibration
- * @ATH_DBG_INTERRUPT: interrupt processing
- * @ATH_DBG_REGULATORY: regulatory processing
- * @ATH_DBG_ANI: adaptive noise immunitive processing
- * @ATH_DBG_XMIT: basic xmit operation
- * @ATH_DBG_BEACON: beacon handling
- * @ATH_DBG_CONFIG: configuration of the hardware
- * @ATH_DBG_FATAL: fatal errors, this is the default, DBG_DEFAULT
- * @ATH_DBG_PS: power save processing
- * @ATH_DBG_HWTIMER: hardware timer handling
- * @ATH_DBG_BTCOEX: bluetooth coexistance
- * @ATH_DBG_BSTUCK: stuck beacons
- * @ATH_DBG_ANY: enable all debugging
- *
- * The debug level is used to control the amount and type of debugging output
- * we want to see. Each driver has its own method for enabling debugging and
- * modifying debug level states -- but this is typically done through a
- * module parameter 'debug' along with a respective 'debug' debugfs file
- * entry.
- */
-enum ATH_DEBUG {
-	ATH_DBG_RESET		= 0x00000001,
-	ATH_DBG_QUEUE		= 0x00000002,
-	ATH_DBG_EEPROM		= 0x00000004,
-	ATH_DBG_CALIBRATE	= 0x00000008,
-	ATH_DBG_INTERRUPT	= 0x00000010,
-	ATH_DBG_REGULATORY	= 0x00000020,
-	ATH_DBG_ANI		= 0x00000040,
-	ATH_DBG_XMIT		= 0x00000080,
-	ATH_DBG_BEACON		= 0x00000100,
-	ATH_DBG_CONFIG		= 0x00000200,
-	ATH_DBG_FATAL		= 0x00000400,
-	ATH_DBG_PS		= 0x00000800,
-	ATH_DBG_HWTIMER		= 0x00001000,
-	ATH_DBG_BTCOEX		= 0x00002000,
-	ATH_DBG_WMI		= 0x00004000,
-	ATH_DBG_BSTUCK		= 0x00008000,
-	ATH_DBG_ANY		= 0xffffffff
-};
-
-#define ATH_DBG_DEFAULT (ATH_DBG_FATAL)
-
-#ifdef CONFIG_ATH_DEBUG
-void ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
-	__attribute__ ((format (printf, 3, 4)));
-#define ATH_DBG_WARN(foo, arg...) WARN(foo, arg)
-#else
-static inline void __attribute__ ((format (printf, 3, 4)))
-ath_print(struct ath_common *common, int dbg_mask, const char *fmt, ...)
-{
-}
-#define ATH_DBG_WARN(foo, arg)
-#endif /* CONFIG_ATH_DEBUG */
-
-/** Returns string describing opmode, or NULL if unknown mode. */
-#ifdef CONFIG_ATH_DEBUG
-const char *ath_opmode_to_string(enum nl80211_iftype opmode);
-#else
-static inline const char *ath_opmode_to_string(enum nl80211_iftype opmode)
-{
-	return "UNKNOWN";
-}
-#endif
+#define ath_print ath_dbg
 
 #endif /* ATH_DEBUG_H */
diff --git a/drivers/net/wireless/ath/main.c b/drivers/net/wireless/ath/main.c
index 487193f..c325202 100644
--- a/drivers/net/wireless/ath/main.c
+++ b/drivers/net/wireless/ath/main.c
@@ -56,3 +56,23 @@ struct sk_buff *ath_rxbuf_alloc(struct ath_common *common,
 	return skb;
 }
 EXPORT_SYMBOL(ath_rxbuf_alloc);
+
+int ath_printk(const char *level, struct ath_common *common,
+	       const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int rtn;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	rtn = printk("%sath: %pV", level, &vaf);
+
+	va_end(args);
+
+	return rtn;
+}
+EXPORT_SYMBOL(ath_printk);
-- 
1.7.3.2.245.g03276.dirty
