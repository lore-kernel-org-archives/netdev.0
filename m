From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/17] tipc: Eliminate support for tipc_mode global variable
Date: Wed, 29 Feb 2012 18:18:40 -0500
Message-ID: <1330557523-2024-15-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53994 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965311Ab2B2XTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:19:08 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Removes all references to the global variable that records whether
TIPC is running in "single node" mode or "network" mode, since this
information can be easily deduced from the global variable that
records TIPC's network address. (i.e. a non-zero network address
means that TIPC is running in network mode.)

The changes made update most existing mode-based checks to use the
network address global variable. A few checks that are no longer
needed are removed entirely, along with any associated code lying on
non-executable control paths.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |    2 +-
 net/tipc/config.c |    4 ++--
 net/tipc/core.c   |    2 --
 net/tipc/core.h   |    8 --------
 net/tipc/net.c    |    7 +------
 net/tipc/node.c   |    2 +-
 6 files changed, 5 insertions(+), 20 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 5f5e89e..5dfd89c 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -435,7 +435,7 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 	u32 i;
 	int res = -EINVAL;
 
-	if (tipc_mode != TIPC_NET_MODE) {
+	if (!tipc_own_addr) {
 		warn("Bearer <%s> rejected, not supported in standalone mode\n",
 		     name);
 		return -ENOPROTOOPT;
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 7ca3854..f76d3b1 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -179,7 +179,7 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (!tipc_addr_node_valid(addr))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (node address)");
-	if (tipc_mode == TIPC_NET_MODE)
+	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
 
@@ -268,7 +268,7 @@ static struct sk_buff *cfg_set_netid(void)
 	if (value < 1 || value > 9999)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network id must be 1-9999)");
-	if (tipc_mode == TIPC_NET_MODE)
+	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 			" (cannot change network id once TIPC has joined a network)");
 	tipc_net_id = value;
diff --git a/net/tipc/core.c b/net/tipc/core.c
index ec381d4..68eba03 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -53,7 +53,6 @@
 
 /* global variables used by multiple sub-systems within TIPC */
 
-int tipc_mode;
 int tipc_random;
 
 const char tipc_alphabet[] =
@@ -144,7 +143,6 @@ static int tipc_core_start(void)
 	int res;
 
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
-	tipc_mode = TIPC_NODE_MODE;
 
 	res = tipc_handler_start();
 	if (!res)
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 9842ec0..13837e0 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -130,13 +130,6 @@ void tipc_msg_dbg(struct print_buf *, struct tipc_msg *, const char *);
 #define ELINKCONG EAGAIN	/* link congestion <=> resource unavailable */
 
 /*
- * TIPC operating mode routines
- */
-
-#define TIPC_NODE_MODE    1
-#define TIPC_NET_MODE     2
-
-/*
  * Global configuration variables
  */
 
@@ -151,7 +144,6 @@ extern int tipc_remote_management;
  * Other global variables
  */
 
-extern int tipc_mode;
 extern int tipc_random;
 extern const char tipc_alphabet[];
 
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 2abd4be..d4531b0 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -175,14 +175,10 @@ int tipc_net_start(u32 addr)
 {
 	char addr_string[16];
 
-	if (tipc_mode != TIPC_NODE_MODE)
-		return -ENOPROTOOPT;
-
 	tipc_subscr_stop();
 	tipc_cfg_stop();
 
 	tipc_own_addr = addr;
-	tipc_mode = TIPC_NET_MODE;
 	tipc_named_reinit();
 	tipc_port_reinit();
 
@@ -201,10 +197,9 @@ void tipc_net_stop(void)
 {
 	struct tipc_node *node, *t_node;
 
-	if (tipc_mode != TIPC_NET_MODE)
+	if (!tipc_own_addr)
 		return;
 	write_lock_bh(&tipc_net_lock);
-	tipc_mode = TIPC_NODE_MODE;
 	tipc_bearer_stop();
 	tipc_bclink_stop();
 	list_for_each_entry_safe(node, t_node, &tipc_node_list, list)
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 12ddc65..a34cabc 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -406,7 +406,7 @@ struct sk_buff *tipc_node_get_links(const void *req_tlv_area, int req_tlv_space)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-	if (tipc_mode != TIPC_NET_MODE)
+	if (!tipc_own_addr)
 		return tipc_cfg_reply_none();
 
 	read_lock_bh(&tipc_net_lock);
-- 
1.7.9.1
