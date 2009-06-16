From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] net/netfilter: Convert printk uses to pr_<level>
Date: Tue, 16 Jun 2009 10:58:45 -0700
Message-ID: <1245175125.28596.100.camel@Joe-Laptop.home>
References: <cover.1244705154.git.joe@perches.com>
	 <835d5482f92aa00f571b2775b96e0e555c31bcf8.1244705154.git.joe@perches.com>
	 <4A33833B.4080609@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.LABridge.com ([206.117.136.22]:2636 "EHLO
	mail.perches.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751239AbZFPR6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 13:58:47 -0400
In-Reply-To: <4A33833B.4080609@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2009-06-13 at 12:45 +0200, Patrick McHardy wrote:
> Joe Perches wrote:
> > Remove function names from format strings
> > Add #define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
> 
> For non-debugging messages that should provide enough information
> to make sense of them without function names, this change does not
> make much sense in my opinion.
> 
> Instead of a half-way readable message, we now would get:
> 
> nf_conntrack: nf_conntrack_acct_init: CONFIG_NF_CT_ACCT is deprecated ...
> 
> which is not an improvement at all. So unless we can limit this
> to debugging message, I'll pass on this change.

Good point.

Maybe there should be a #define pr_dbg_fmt(fmt) <foo>

Perhaps:

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 883cd44..adda97d 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -360,6 +360,10 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 #define pr_fmt(fmt) fmt
 #endif
 
+#ifndef pr_dbg_fmt
+#define pr_dbg_fmt(fmt) pr_fmt(fmt)
+#endif
+
 #define pr_emerg(fmt, ...) \
         printk(KERN_EMERG pr_fmt(fmt), ##__VA_ARGS__)
 #define pr_alert(fmt, ...) \
@@ -380,16 +384,16 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 /* pr_devel() should produce zero code unless DEBUG is defined */
 #ifdef DEBUG
 #define pr_devel(fmt, ...) \
-	printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
+	printk(KERN_DEBUG pr_dbg_fmt(fmt), ##__VA_ARGS__)
 #else
 #define pr_devel(fmt, ...) \
-	({ if (0) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); 0; })
+	({ if (0) printk(KERN_DEBUG pr_dbg_fmt(fmt), ##__VA_ARGS__); 0; })
 #endif
 
 /* If you are writing a driver, please use dev_dbg instead */
 #if defined(DEBUG)
 #define pr_debug(fmt, ...) \
-	printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__)
+	printk(KERN_DEBUG pr_dbg_fmt(fmt), ##__VA_ARGS__)
 #elif defined(CONFIG_DYNAMIC_DEBUG)
 /* dynamic_pr_debug() uses pr_fmt() internally so we don't need it here */
 #define pr_debug(fmt, ...) do { \
@@ -397,7 +401,7 @@ static inline char *pack_hex_byte(char *buf, u8 byte)
 	} while (0)
 #else
 #define pr_debug(fmt, ...) \
-	({ if (0) printk(KERN_DEBUG pr_fmt(fmt), ##__VA_ARGS__); 0; })
+	({ if (0) printk(KERN_DEBUG pr_dbg_fmt(fmt), ##__VA_ARGS__); 0; })
 #endif
 
 /*


