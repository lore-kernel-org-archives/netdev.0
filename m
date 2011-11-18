From: Joe Perches <joe@perches.com>
Subject: [PATCH] iwl-debug: Shrink object by using dev_err and deduplicating
 formats
Date: Thu, 17 Nov 2011 17:46:15 -0800
Message-ID: <1321580775.22117.8.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:59985 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751415Ab1KRBqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 20:46:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using dev_err instead of dev_printk(KERN_ERR uses fewer
arguments and is a bit smaller.

Deduplicating formats used by IWL_DEBUG_QUIET_RFKILL also
makes the object a bit smaller.
 
Neatened the macros, used ##__VA_ARGS__.

$ size drivers/net/wireless/iwlwifi/built-in.o*
   text	   data	    bss	    dec	    hex	filename
 462652	   8646	  92576	 563874	  89aa2	drivers/net/wireless/iwlwifi/built-in.o.new
 467557	   8646	  92592	 568795	  8addb	drivers/net/wireless/iwlwifi/built-in.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlwifi/iwl-debug.h |   37 +++++++++++++++++-------------
 1 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-debug.h b/drivers/net/wireless/iwlwifi/iwl-debug.h
index 40ef97b..44a7bdd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-debug.h
@@ -47,20 +47,21 @@ do {									\
 } while (0)
 
 #ifdef CONFIG_IWLWIFI_DEBUG
-#define IWL_DEBUG(m, level, fmt, args...)				\
+#define IWL_DEBUG(m, level, fmt, ...)					\
 do {									\
 	if (iwl_get_debug_level((m)->shrd) & (level))			\
-		dev_printk(KERN_ERR, bus(m)->dev,			\
-			 "%c %s " fmt, in_interrupt() ? 'I' : 'U',	\
-			__func__ , ## args);				\
+		dev_err(bus(m)->dev, "%c %s " fmt,			\
+			in_interrupt() ? 'I' : 'U', __func__,		\
+			##__VA_ARGS__);					\
 } while (0)
 
-#define IWL_DEBUG_LIMIT(m, level, fmt, args...)				\
+#define IWL_DEBUG_LIMIT(m, level, fmt, ...)				\
 do {									\
-	if (iwl_get_debug_level((m)->shrd) & (level) && net_ratelimit())\
-		dev_printk(KERN_ERR, bus(m)->dev,			\
-			"%c %s " fmt, in_interrupt() ? 'I' : 'U',	\
-			 __func__ , ## args);				\
+	if (iwl_get_debug_level((m)->shrd) & (level) &&			\
+	    net_ratelimit())						\
+		dev_err(bus(m)->dev, "%c %s " fmt,			\
+			in_interrupt() ? 'I' : 'U', __func__,		\
+			##__VA_ARGS__);					\
 } while (0)
 
 #define iwl_print_hex_dump(m, level, p, len)				\
@@ -70,14 +71,18 @@ do {                                            			\
 			       DUMP_PREFIX_OFFSET, 16, 1, p, len, 1);	\
 } while (0)
 
-#define IWL_DEBUG_QUIET_RFKILL(p, fmt, args...)			\
+#define IWL_DEBUG_QUIET_RFKILL(p, fmt, ...)				\
 do {									\
-	if (!iwl_is_rfkill(p->shrd))				\
-		dev_printk(KERN_ERR, bus(p)->dev, "%c %s " fmt,	\
-		(in_interrupt() ? 'I' : 'U'), __func__ , ##args);	\
-	else if	(iwl_get_debug_level(p->shrd) & IWL_DL_RADIO)	\
-		dev_printk(KERN_ERR, bus(p)->dev, "(RFKILL) %c %s " fmt, \
-		(in_interrupt() ? 'I' : 'U'), __func__ , ##args);	\
+	if (!iwl_is_rfkill(p->shrd))					\
+		dev_err(bus(p)->dev, "%s%c %s " fmt,			\
+			"",						\
+			in_interrupt() ? 'I' : 'U', __func__,		\
+			##__VA_ARGS__);					\
+	else if	(iwl_get_debug_level(p->shrd) & IWL_DL_RADIO)		\
+		dev_err(bus(p)->dev, "%s%c %s " fmt,			\
+			"(RFKILL) ",					\
+			in_interrupt() ? 'I' : 'U', __func__,		\
+			##__VA_ARGS__);					\
 } while (0)
 
 #else
