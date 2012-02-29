From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 13/17] tipc: Eliminate obsolete support for "not running" mode
Date: Wed, 29 Feb 2012 18:18:39 -0500
Message-ID: <1330557523-2024-14-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53990 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965379Ab2B2XTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:07 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes all references to TIPC's "not running" mode, since the
removal of support for the native API means that there is no longer
any way to interact with TIPC if it has not been initialized.

The changes made consist of removing mode-based checks that are no
longer needed, along with any associated code lying on non-executable
control paths.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/config.c |    7 ++-----
 net/tipc/core.c   |   10 +---------
 net/tipc/core.h   |    2 +-
 3 files changed, 4 insertions(+), 15 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 69cca4f..7ca3854 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -252,11 +252,8 @@ static struct sk_buff *cfg_set_max_ports(void)
 	if (value < 127 || value > 65535)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max ports must be 127-65535)");
-	if (tipc_mode != TIPC_NOT_RUNNING)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-			" (cannot change max ports while TIPC is active)");
-	tipc_max_ports = value;
-	return tipc_cfg_reply_none();
+	return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+		" (cannot change max ports while TIPC is active)");
 }
 
 static struct sk_buff *cfg_set_netid(void)
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 2691cd5..ec381d4 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -53,7 +53,7 @@
 
 /* global variables used by multiple sub-systems within TIPC */
 
-int tipc_mode = TIPC_NOT_RUNNING;
+int tipc_mode;
 int tipc_random;
 
 const char tipc_alphabet[] =
@@ -125,11 +125,6 @@ int tipc_core_start_net(unsigned long addr)
 
 static void tipc_core_stop(void)
 {
-	if (tipc_mode != TIPC_NODE_MODE)
-		return;
-
-	tipc_mode = TIPC_NOT_RUNNING;
-
 	tipc_netlink_stop();
 	tipc_handler_stop();
 	tipc_cfg_stop();
@@ -148,9 +143,6 @@ static int tipc_core_start(void)
 {
 	int res;
 
-	if (tipc_mode != TIPC_NOT_RUNNING)
-		return -ENOPROTOOPT;
-
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 	tipc_mode = TIPC_NODE_MODE;
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index aefe186..9842ec0 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -132,7 +132,7 @@ void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 /*
  * TIPC operating mode routines
  */
-#define TIPC_NOT_RUNNING  0
+
 #define TIPC_NODE_MODE    1
 #define TIPC_NET_MODE     2
 
-- 
1.7.9.1
