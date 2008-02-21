From: Joe Perches <joe@perches.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Thu, 21 Feb 2008 09:17:13 -0800
Message-ID: <1203614233.7181.262.camel@localhost>
References: <1203586467.20345.14.camel@brick>
	 <20080221.015743.222059206.davem@davemloft.net>
	 <1203588079.20345.15.camel@brick>
	 <20080221.020554.259219477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: harvey.harrison@gmail.com, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:2384 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1755328AbYBURRr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2008 12:17:47 -0500
In-Reply-To: <20080221.020554.259219477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-02-21 at 02:05 -0800, David Miller wrote:
> >From another perspective adding that __pure attribute to print_mac()
> might not have been the best idea.  But I can't think of another
> way to eliminate the "passing print_mac() args to pr_debug()
> still generates calls to print_mac() even when DEBUG is not
> defined" problem :-/

Philip Craig made a suggestion:
http://marc.info/?l=linux-wireless&m=120338413108120&w=2

to use this:

If not debugging, guard #define wrapper_printks with if (0).
The gcc optimizer removes the printk but gcc still does
printf argument verification.

There are many other debug printk wrappers

	#ifdef DEBUG
	#define printk_wrapper 
	#else
	#define printk_wrapper printk
	#endif

that should be converted as well.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/device.h b/include/linux/device.h
index 2258d89..79601b1 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -608,21 +608,15 @@ extern const char *dev_driver_string(struct device *dev);
 #define dev_dbg(dev, format, arg...)		\
 	dev_printk(KERN_DEBUG , dev , format , ## arg)
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-dev_dbg(struct device *dev, const char *fmt, ...)
-{
-	return 0;
-}
+#define dev_dbg(dev, format, arg...) \
+	do { if (0) dev_printk(KERN_DEBUG , dev , format, ## arg); } while (0)
 #endif
 
 #ifdef VERBOSE_DEBUG
 #define dev_vdbg	dev_dbg
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-dev_vdbg(struct device *dev, const char *fmt, ...)
-{
-	return 0;
-}
+#define dev_vdbg(dev, format, arg...) \
+	do { if (0) dev_printk(KERN_DEBUG , dev , format, ## arg); } while (0)
 #endif
 
 /* Create alias, so I can be autoloaded. */
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 2df44e7..cd24112 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -293,10 +293,8 @@ extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
 #define pr_debug(fmt, arg...) \
 	printk(KERN_DEBUG fmt, ##arg)
 #else
-static inline int __attribute__ ((format (printf, 1, 2))) pr_debug(const char * fmt, ...)
-{
-	return 0;
-}
+#define pr_debug(fmt, arg...) \
+	do { if (0) printk(KERN_DEBUG fmt, ##arg); } while (0)
 #endif
 
 /*


