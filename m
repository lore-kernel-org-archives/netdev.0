From: Joe Perches <joe@perches.com>
Subject: [PATCH] rtlwifi: Create _rtl_dbg_trace function to reduce RT_TRACE code size
Date: Sat, 25 Jun 2016 15:46:45 -0700
Message-ID: <90cd7c8f12b51571db565fd496a2fcf610e2e484.1466894688.git.joe@perches.com>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This debugging macro can expand to a lot of code.
Make it a function to reduce code size.

(x86-64 defconfig w/ all rtlwifi drivers and allyesconfig)
$ size drivers/net/wireless/realtek/rtlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 900083	 200499	   1907	1102489	 10d299	drivers/net/wireless/realtek/rtlwifi/built-in.o.defconfig.new
1113597	 200499	   1907	1316003	 1414a3	drivers/net/wireless/realtek/rtlwifi/built-in.o.defconfig.old
1746879	 453503	   8512	2208894	 21b47e	drivers/net/wireless/realtek/rtlwifi/built-in.o.new
2051965	 503311	   8512	2563788	 271ecc	drivers/net/wireless/realtek/rtlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/realtek/rtlwifi/debug.c | 25 +++++++++++++++++++++++++
 drivers/net/wireless/realtek/rtlwifi/debug.h | 17 +++++++++--------
 2 files changed, 34 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/debug.c b/drivers/net/wireless/realtek/rtlwifi/debug.c
index fd25aba..33905bb 100644
--- a/drivers/net/wireless/realtek/rtlwifi/debug.c
+++ b/drivers/net/wireless/realtek/rtlwifi/debug.c
@@ -48,3 +48,28 @@ void rtl_dbgp_flag_init(struct ieee80211_hw *hw)
 	/*Init Debug flag enable condition */
 }
 EXPORT_SYMBOL_GPL(rtl_dbgp_flag_init);
+
+#ifdef CONFIG_RTLWIFI_DEBUG
+void _rtl_dbg_trace(struct rtl_priv *rtlpriv, int comp, int level,
+		    const char *modname, const char *fmt, ...)
+{
+	if (unlikely((comp & rtlpriv->dbg.global_debugcomponents) &&
+		     (level <= rtlpriv->dbg.global_debuglevel))) {
+		struct va_format vaf;
+		va_list args;
+
+		va_start(args, fmt);
+
+		vaf.fmt = fmt;
+		vaf.va = &args;
+
+		printk(KERN_DEBUG "%s:%ps:<%lx-%x> %pV",
+		       modname, __builtin_return_address(0),
+		       in_interrupt(), in_atomic(),
+		       &vaf);
+
+		va_end(args);
+	}
+}
+EXPORT_SYMBOL_GPL(_rtl_dbg_trace);
+#endif
diff --git a/drivers/net/wireless/realtek/rtlwifi/debug.h b/drivers/net/wireless/realtek/rtlwifi/debug.h
index fc794b3..6156a79 100644
--- a/drivers/net/wireless/realtek/rtlwifi/debug.h
+++ b/drivers/net/wireless/realtek/rtlwifi/debug.h
@@ -174,15 +174,16 @@ do {									\
 	}								\
 } while (0)
 
+
+struct rtl_priv;
+
+__printf(5, 6)
+void _rtl_dbg_trace(struct rtl_priv *rtlpriv, int comp, int level,
+		    const char *modname, const char *fmt, ...);
+
 #define RT_TRACE(rtlpriv, comp, level, fmt, ...)			\
-do {									\
-	if (unlikely(((comp) & rtlpriv->dbg.global_debugcomponents) &&	\
-		     ((level) <= rtlpriv->dbg.global_debuglevel))) {	\
-		printk(KERN_DEBUG KBUILD_MODNAME ":%s():<%lx-%x> " fmt,	\
-		       __func__, in_interrupt(), in_atomic(),		\
-		       ##__VA_ARGS__);					\
-	}								\
-} while (0)
+	_rtl_dbg_trace(rtlpriv, comp, level,				\
+		       KBUILD_MODNAME, fmt, ##__VA_ARGS__)
 
 #define RTPRINT(rtlpriv, dbgtype, dbgflag, fmt, ...)			\
 do {									\
-- 
2.8.0.rc4.16.g56331f8
