From: Joe Perches <joe@perches.com>
Subject: Re: New sparse warning in net/mac80211/debugfs_sta.c
Date: Tue, 08 Apr 2008 14:02:29 -0700
Message-ID: <1207688549.1020.90.camel@localhost>
References: <1203589042.17534.145.camel@johannes.berg>
	 <1203616486.7181.269.camel@localhost>	<47BDBC23.5080007@trash.net>
	 <20080223.200202.255773165.davem@davemloft.net>
	 <47C2AAC8.8020202@trash.net> <1203969502.19319.279.camel@localhost>
	 <47FBD30A.1010003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, johannes@sipsolutions.net,
	harvey.harrison@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4537 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbYDHVD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 17:03:58 -0400
In-Reply-To: <47FBD30A.1010003@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-04-08 at 22:18 +0200, Patrick McHardy wrote:
> Joe Perches wrote:
> > On Mon, 2008-02-25 at 12:47 +0100, Patrick McHardy wrote: 
> >> It would be good if Joe could go through the remaining print_mac users
> >> and convert the remaining unintended function calls in fastpaths back
> >> to MAC_FMT. Grepping for "start_xmit" in commit 0795af5729b shows that
> >> at least 10 hard_start_xmit functions are affected and I expect that
> >> some of the changes in the wireless code affect fastpaths as well.
> > I don't mind doing that, as calling print_mac in these fastpaths in
> > unintentional and undesirable.
> Unfortunately the current tree still includes all the fallout,
> are you planning on cleaning this up again any time soon?
> I've attached a codiff of a tree with and without this change
> (might not include all drivers, but I think I enabled all that
> build on x86_64). The _probe and _init_one functions should
> be harmless, but there are lots of functions that look like
> they would prefer to avoid useless overhead. A small sample:
> 
> drivers/net/starfire.c:
>    netdev_poll       |  +50
> 
> drivers/net/tokenring/olympic.c:
>    olympic_interrupt |  +10

[]

I also think this should be cleaned up before 2.6.25 is released.

I think that the changes to pr_debug, dev_dbg, and dev_vdbg
to use an "if (0) printk" macro rather than an empty inline
I posted a few times without any reply or comment should work
for most all cases.

These changes should allow gcc to eliminate unused functions
called as arguments to those debugging logging functions
while maintaining the printf argument validation.

I'll check out codiff as I haven't used it.
Is this the latest codiff tool?
http://git.kernel.org/?p=linux/kernel/git/acme/pahole.git;a=summary

cheers, Joe

Here is the patch again:

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/include/linux/device.h b/include/linux/device.h
index 2258d89..12bb248 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -608,21 +608,21 @@ extern const char *dev_driver_string(struct device *dev);
 #define dev_dbg(dev, format, arg...)		\
 	dev_printk(KERN_DEBUG , dev , format , ## arg)
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-dev_dbg(struct device *dev, const char *fmt, ...)
-{
-	return 0;
-}
+#define dev_dbg(dev, format, arg...)				\
+do {								\
+	if (0)							\
+		dev_printk(KERN_DEBUG , dev , format , ## arg);	\
+} while (0)
 #endif
 
 #ifdef VERBOSE_DEBUG
 #define dev_vdbg	dev_dbg
 #else
-static inline int __attribute__ ((format (printf, 2, 3)))
-dev_vdbg(struct device *dev, const char *fmt, ...)
-{
-	return 0;
-}
+#define dev_vdbg(dev, format, arg...)				\
+do {								\
+	if (0)							\
+		dev_printk(KERN_DEBUG , dev , format , ## arg);	\
+} while (0)
 #endif
 
 /* Create alias, so I can be autoloaded. */
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 2df44e7..80be070 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -293,10 +293,11 @@ extern void print_hex_dump_bytes(const char *prefix_str, int prefix_type,
 #define pr_debug(fmt, arg...) \
 	printk(KERN_DEBUG fmt, ##arg)
 #else
-static inline int __attribute__ ((format (printf, 1, 2))) pr_debug(const char * fmt, ...)
-{
-	return 0;
-}
+#define pr_debug(fmt, arg...)			\
+do {						\
+	if (0)					\
+		printk(KERN_DEBUG fmt, ##arg);	\
+} while (0)
 #endif
 
 /*


