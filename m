From: Joe Perches <joe@perches.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Mon, 25 Feb 2008 11:58:22 -0800
Message-ID: <1203969502.19319.279.camel@localhost>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <47C2AAC8.8020202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1132 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1756236AbYBYT76 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 14:59:58 -0500
In-Reply-To: <47C2AAC8.8020202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-25 at 12:47 +0100, Patrick McHardy wrote: 
> It would be good if Joe could go through the remaining print_mac users
> and convert the remaining unintended function calls in fastpaths back
> to MAC_FMT. Grepping for "start_xmit" in commit 0795af5729b shows that
> at least 10 hard_start_xmit functions are affected and I expect that
> some of the changes in the wireless code affect fastpaths as well.

I don't mind doing that, as calling print_mac in these fastpaths in
unintentional and undesirable.  But wouldn't it be better to find a
solution that removes all debug printk function calls that should
be optimized away?

I have not seen any response to a suggestion to convert debug printk
macros (dprintk, pr_debug, dev_dbg, etc) to:

#define pr_debug(fmt, arg...) \
do { if (0) printk(KERN_DEBUG fmt, ##arg); } while (0)

This preserves argument verification and gives the compiler the
capability to optimize out the printk and any functions the printk
might call.

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


