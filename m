From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 1/3] wimax: fix '#ifdef CONFIG_BUG' layout to avoid warning
Date: Tue,  6 Jan 2009 23:58:20 -0800
Message-ID: <8baeb9679011f4f01a5f9709c725c4d829cb28bd.1231314782.git.inaky@linux.intel.com>
References: <cover.1231314782.git.inaky@linux.intel.com>
Cc: wimax@linuxwimax.org, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:42314 "EHLO gocho"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752822AbZAGH60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 02:58:26 -0500
In-Reply-To: <cover.1231314782.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported by Randy Dunlap:

> Also, this warning needs to be fixed:
>
> linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> forbids mixed declarations and code

Move the return on #defined(CONFIG_BUG) below the variable
declarations so it doesn't violate ISO C90.

On wimax_id_table_release() we want to do a debug check if CONFIG_BUG
is enabled. However, we also want the debug code to be always compiled
to ensure there is no bitrot. It will be optimized out by the compiler
when CONFIG_BUG is disabled.

Added a note to the function header stating this.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/id-table.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/wimax/id-table.c b/net/wimax/id-table.c
index d3b8855..d6e0e8f 100644
--- a/net/wimax/id-table.c
+++ b/net/wimax/id-table.c
@@ -123,15 +123,17 @@ void wimax_id_table_rm(struct wimax_dev *wimax_dev)
 /*
  * Release the gennetlink family id / mapping table
  *
- * On debug, verify that the table is empty upon removal.
+ * On debug, verify that the table is empty upon removal. We want the
+ * code always compiled, to ensure it doesn't bit rot. It will be
+ * compiled out if CONFIG_BUG is disabled.
  */
 void wimax_id_table_release(void)
 {
-#ifndef CONFIG_BUG
-	return;
-#endif
 	struct wimax_dev *wimax_dev;
 
+#ifdef CONFIG_BUG
+	return;
+#endif
 	spin_lock(&wimax_id_table_lock);
 	list_for_each_entry(wimax_dev, &wimax_id_table, id_table_node) {
 		printk(KERN_ERR "BUG: %s wimax_dev %p ifindex %d not cleared\n",
-- 
1.5.6.5

