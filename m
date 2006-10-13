From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 6/14] [TIPC] Remove code bloat introduced by print buffer rework
Date: Fri, 13 Oct 2006 13:37:47 +0200
Message-ID: <1160739475673-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw4.ericsson.se ([193.180.251.62]:41888 "EHLO
	mailgw4.ericsson.se") by vger.kernel.org with ESMTP
	id S1751385AbWJMLiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This patch allows the compiler to optimize out any code that tries to
send debugging output to the null print buffer (TIPC_NULL), a capability
that was unintentionally broken during the recent print buffer rework.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/core.h |    6 +++---
 net/tipc/link.c |    8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/tipc/core.h b/net/tipc/core.h
index 31331e8..e3a74a3 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -83,9 +83,9 @@ #define err(fmt, arg...)  tipc_printf(TI
 #define warn(fmt, arg...) tipc_printf(TIPC_OUTPUT, KERN_WARNING "TIPC: " fmt, ## arg)
 #define info(fmt, arg...) tipc_printf(TIPC_OUTPUT, KERN_NOTICE "TIPC: " fmt, ## arg)
 
-#define dbg(fmt, arg...)  do {if (DBG_OUTPUT) tipc_printf(DBG_OUTPUT, fmt, ## arg);} while(0)
-#define msg_dbg(msg, txt) do {if (DBG_OUTPUT) tipc_msg_print(DBG_OUTPUT, msg, txt);} while(0)
-#define dump(fmt, arg...) do {if (DBG_OUTPUT) tipc_dump(DBG_OUTPUT, fmt, ##arg);} while(0)
+#define dbg(fmt, arg...)  do {if (DBG_OUTPUT != TIPC_NULL) tipc_printf(DBG_OUTPUT, fmt, ## arg);} while(0)
+#define msg_dbg(msg, txt) do {if (DBG_OUTPUT != TIPC_NULL) tipc_msg_print(DBG_OUTPUT, msg, txt);} while(0)
+#define dump(fmt, arg...) do {if (DBG_OUTPUT != TIPC_NULL) tipc_dump(DBG_OUTPUT, fmt, ##arg);} while(0)
 
 
 /*	
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 53bc8cb..1bb983c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -132,7 +132,7 @@ static void link_print(struct link *l_pt
  * allow the output from multiple links to be intermixed.  For this reason
  * routines of the form "dbg_link_XXX()" have been created that will capture
  * debug info into a link's personal print buffer, which can then be dumped
- * into the TIPC system log (LOG) upon request.
+ * into the TIPC system log (TIPC_LOG) upon request.
  *
  * To enable per-link debugging, use LINK_LOG_BUF_SIZE to specify the size
  * of the print buffer used by each link.  If LINK_LOG_BUF_SIZE is set to 0,
@@ -141,7 +141,7 @@ static void link_print(struct link *l_pt
  * when there is only a single link in the system being debugged.
  *
  * Notes:
- * - When enabled, LINK_LOG_BUF_SIZE should be set to at least 1000 (bytes)
+ * - When enabled, LINK_LOG_BUF_SIZE should be set to at least TIPC_PB_MIN_SIZE
  * - "l_ptr" must be valid when using dbg_link_XXX() macros  
  */
 
@@ -159,13 +159,13 @@ #define dbg_link_dump() do { \
 
 static void dbg_print_link(struct link *l_ptr, const char *str)
 {
-	if (DBG_OUTPUT)
+	if (DBG_OUTPUT != TIPC_NULL)
 		link_print(l_ptr, DBG_OUTPUT, str);
 }
 
 static void dbg_print_buf_chain(struct sk_buff *root_buf)
 {
-	if (DBG_OUTPUT) {
+	if (DBG_OUTPUT != TIPC_NULL) {
 		struct sk_buff *buf = root_buf;
 
 		while (buf) {
-- 
1.4.1

