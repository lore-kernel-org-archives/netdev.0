From: Joe Perches <joe@perches.com>
Subject: Re: [RFC patch (against wireless-next)] include/net/cfg80211.h:
 wiphy_<level> messages use dev_printk
Date: Fri, 20 Aug 2010 15:13:59 -0700
Message-ID: <1282342439.1960.84.camel@Joe-Laptop>
References: <1282245848.6724.261.camel@Joe-Laptop>
	 <1282246784.4507.14.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1282246784.4507.14.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-08-19 at 21:39 +0200, Johannes Berg wrote:
> On Thu, 2010-08-19 at 12:24 -0700, Joe Perches wrote:
> > Adding device to the wiphy logging messages could be useful.
> >  #define wiphy_printk(level, wiphy, format, args...)		\
> > -	printk(level "%s: " format, wiphy_name(wiphy), ##args)
> > +	dev_printk(level, &wiphy->dev, "%s: " format, wiphy_name(wiphy), ##args)
> what will that actually print?

As is, that'd print:

"<level>dev_driver_string(&wiphy->dev) dev_name(&wiphy->dev): wiphy_name(wiphy): " fmt, ##args

for instance:

[   41.261941] ieee80211 phy0: phy0: Selected rate control algorithm 'minstrel_ht'

ie: redundant.
wiphy_name(wiphy) is an inline for dev_name(&wiphy->dev)

So it's appropriate to use:

#define wiphy_<level>(wiphy, fmt, arg...) dev_<level>(&wiphy->dev, fmt, ##arg) 

and the output becomes:

[   41.261941] ieee80211 phy0: Selected rate control algorithm 'minstrel_ht'

Signed-off-by: Joe Perches <joe@perches.com>
---
 include/net/cfg80211.h |   37 +++++++++++------------------------
 net/wireless/core.c    |   49 ------------------------------------------------
 2 files changed, 12 insertions(+), 74 deletions(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index f274053..ab5c746 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -2548,49 +2548,36 @@ void cfg80211_cqm_rssi_notify(struct net_device *dev,
 /* wiphy_printk helpers, similar to dev_printk */
 
 #define wiphy_printk(level, wiphy, format, args...)		\
-	printk(level "%s: " format, wiphy_name(wiphy), ##args)
+	dev_printk(level, &(wiphy)->dev, format, ##args)
 #define wiphy_emerg(wiphy, format, args...)			\
-	wiphy_printk(KERN_EMERG, wiphy, format, ##args)
+	dev_emerg(&(wiphy)->dev, format, ##args)
 #define wiphy_alert(wiphy, format, args...)			\
-	wiphy_printk(KERN_ALERT, wiphy, format, ##args)
+	dev_alert(&(wiphy)->dev, format, ##args)
 #define wiphy_crit(wiphy, format, args...)			\
-	wiphy_printk(KERN_CRIT, wiphy, format, ##args)
+	dev_crit(&(wiphy)->dev, format, ##args)
 #define wiphy_err(wiphy, format, args...)			\
-	wiphy_printk(KERN_ERR, wiphy, format, ##args)
+	dev_err(&(wiphy)->dev, format, ##args)
 #define wiphy_warn(wiphy, format, args...)			\
-	wiphy_printk(KERN_WARNING, wiphy, format, ##args)
+	dev_warn(&(wiphy)->dev, format, ##args)
 #define wiphy_notice(wiphy, format, args...)			\
-	wiphy_printk(KERN_NOTICE, wiphy, format, ##args)
+	dev_notice(&(wiphy)->dev, format, ##args)
 #define wiphy_info(wiphy, format, args...)			\
-	wiphy_printk(KERN_INFO, wiphy, format, ##args)
+	dev_info(&(wiphy)->dev, format, ##args)
 
-int wiphy_debug(const struct wiphy *wiphy, const char *format, ...)
-	__attribute__ ((format (printf, 2, 3)));
-
-#if defined(DEBUG)
-#define wiphy_dbg(wiphy, format, args...)			\
+#define wiphy_debug(wiphy, format, args...)			\
 	wiphy_printk(KERN_DEBUG, wiphy, format, ##args)
-#elif defined(CONFIG_DYNAMIC_DEBUG)
+
 #define wiphy_dbg(wiphy, format, args...)			\
-	dynamic_pr_debug("%s: " format,	wiphy_name(wiphy), ##args)
-#else
-#define wiphy_dbg(wiphy, format, args...)				\
-({									\
-	if (0)								\
-		wiphy_printk(KERN_DEBUG, wiphy, format, ##args);	\
-	0;								\
-})
-#endif
+	dev_dbg(&(wiphy)->dev, format, ##args)
 
 #if defined(VERBOSE_DEBUG)
 #define wiphy_vdbg	wiphy_dbg
 #else
-
 #define wiphy_vdbg(wiphy, format, args...)				\
 ({									\
 	if (0)								\
 		wiphy_printk(KERN_DEBUG, wiphy, format, ##args);	\
-		0;							\
+	0;								\
 })
 #endif
 
diff --git a/net/wireless/core.c b/net/wireless/core.c
index d52630b..b8191cf 100644
--- a/net/wireless/core.c
+++ b/net/wireless/core.c
@@ -912,52 +912,3 @@ static void __exit cfg80211_exit(void)
 	destroy_workqueue(cfg80211_wq);
 }
 module_exit(cfg80211_exit);
-
-static int ___wiphy_printk(const char *level, const struct wiphy *wiphy,
-			   struct va_format *vaf)
-{
-	if (!wiphy)
-		return printk("%s(NULL wiphy *): %pV", level, vaf);
-
-	return printk("%s%s: %pV", level, wiphy_name(wiphy), vaf);
-}
-
-int __wiphy_printk(const char *level, const struct wiphy *wiphy,
-		   const char *fmt, ...)
-{
-	struct va_format vaf;
-	va_list args;
-	int r;
-
-	va_start(args, fmt);
-
-	vaf.fmt = fmt;
-	vaf.va = &args;
-
-	r = ___wiphy_printk(level, wiphy, &vaf);
-	va_end(args);
-
-	return r;
-}
-EXPORT_SYMBOL(__wiphy_printk);
-
-#define define_wiphy_printk_level(func, kern_level)		\
-int func(const struct wiphy *wiphy, const char *fmt, ...)	\
-{								\
-	struct va_format vaf;					\
-	va_list args;						\
-	int r;							\
-								\
-	va_start(args, fmt);					\
-								\
-	vaf.fmt = fmt;						\
-	vaf.va = &args;						\
-								\
-	r = ___wiphy_printk(kern_level, wiphy, &vaf);		\
-	va_end(args);						\
-								\
-	return r;						\
-}								\
-EXPORT_SYMBOL(func);
-
-define_wiphy_printk_level(wiphy_debug, KERN_DEBUG);
