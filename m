From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 4/4] wireless: Convert wiphy_debug macro to function
Date: Mon, 26 Jul 2010 14:40:00 -0700
Message-ID: <8e7aa541ec8fb92e1166920a4eb704aa5f851b71.1280177971.git.joe@perches.com>
References: <cover.1280177971.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1280177971.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Save a few bytes of text

(allyesconfig)
$ size drivers/net/wireless/built-in.o*
   text	   data	    bss	    dec	    hex	filename
3924568	 100548	 871056	4896172	 4ab5ac	drivers/net/wireless/built-in.o.new
3926520	 100548	 871464	4898532	 4abee4	drivers/net/wireless/built-in.o.old

$ size net/wireless/core.o*
   text	   data	    bss	    dec	    hex	filename
  12843	    216	   3768	  16827	   41bb	net/wireless/core.o.new
  12328	    216	   3656	  16200	   3f48	net/wireless/core.o

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cfg80211.h |    5 ++-
 net/wireless/core.c    |   53 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 7fe774c..ae80f8f 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2442,8 +2442,9 @@ void cfg80211_cqm_rssi_notify(struct net_device *dev,
 	wiphy_printk(KERN_NOTICE, wiphy, format, ##args)
 #define wiphy_info(wiphy, format, args...)			\
 	wiphy_printk(KERN_INFO, wiphy, format, ##args)
-#define wiphy_debug(wiphy, format, args...)			\
-	wiphy_printk(KERN_DEBUG, wiphy, format, ##args)
+
+int wiphy_debug(const struct wiphy *wiphy, const char *format, ...)
+	__attribute__ ((format (printf, 2, 3)));
 
 #if defined(DEBUG)
 #define wiphy_dbg(wiphy, format, args...)			\
diff --git a/net/wireless/core.c b/net/wireless/core.c
index f65c649..1f9de8a 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -907,3 +907,56 @@ static void __exit cfg80211_exit(void)
 	destroy_workqueue(cfg80211_wq);
 }
 module_exit(cfg80211_exit);
+
+#ifdef __KERNEL__
+
+static int ___wiphy_printk(const char *level, const struct wiphy *wiphy,
+			   struct va_format *vaf)
+{
+	if (!wiphy)
+		return printk("%s(NULL wiphy *): %pV", level, vaf);
+
+	return printk("%s%s: %pV", level, wiphy_name(wiphy), vaf);
+}
+
+int __wiphy_printk(const char *level, const struct wiphy *wiphy,
+		   const char *fmt, ...)
+{
+	struct va_format vaf;
+	va_list args;
+	int r;
+
+	va_start(args, fmt);
+
+	vaf.fmt = fmt;
+	vaf.va = &args;
+
+	r = ___wiphy_printk(level, wiphy, &vaf);
+	va_end(args);
+
+	return r;
+}
+EXPORT_SYMBOL(__wiphy_printk);
+
+#define define_wiphy_printk_level(func, kern_level)		\
+int func(const struct wiphy *wiphy, const char *fmt, ...)	\
+{								\
+	struct va_format vaf;					\
+	va_list args;						\
+	int r;							\
+								\
+	va_start(args, fmt);					\
+								\
+	vaf.fmt = fmt;						\
+	vaf.va = &args;						\
+								\
+	r = ___wiphy_printk(kern_level, wiphy, &vaf);		\
+	va_end(args);						\
+								\
+	return r;						\
+}								\
+EXPORT_SYMBOL(func);
+
+define_wiphy_printk_level(wiphy_debug, KERN_DEBUG);
+
+#endif
-- 
1.7.1
