From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 5/5 net-next-2.6] [TIPC]: Fix initialization sequence problems when entering network mode
Date: Tue, 20 May 2008 17:08:32 -0400
Message-ID: <1211317712-13596-6-git-send-email-allan.stephens@windriver.com>
References: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:41810 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760057AbYETVJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 17:09:56 -0400
In-Reply-To: <1211317712-13596-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch ensures that TIPC's topology service and configuration
service are shut down before switching into "network mode".  This
ensures that TIPC does not mistakenly try to send unnecessary
"publication withdraw" messages to other nodes before it is fully
initialized for sending off-node messages.  Note that the node's
current network address is now updated only after the two services
are shut down; this ensures that any existing connections to the
topology server are terminated correctly using the old address.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/config.c |    3 +--
 net/tipc/core.c   |    4 ++--
 net/tipc/core.h   |    2 +-
 net/tipc/net.c    |   10 +++++++---
 net/tipc/net.h    |    2 +-
 5 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 16e7cb7..ca3544d 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -293,7 +293,6 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (tipc_mode == TIPC_NET_MODE)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
-	tipc_own_addr = addr;
 
 	/*
 	 * Must release all spinlocks before calling start_net() because
@@ -306,7 +305,7 @@ static struct sk_buff *cfg_set_own_addr(void)
 	 */
 
 	spin_unlock_bh(&config_lock);
-	tipc_core_start_net();
+	tipc_core_start_net(addr);
 	spin_lock_bh(&config_lock);
 	return tipc_cfg_reply_none();
 }
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 3d97386..3256bd7 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -117,11 +117,11 @@ void tipc_core_stop_net(void)
  * start_net - start TIPC networking sub-systems
  */
 
-int tipc_core_start_net(void)
+int tipc_core_start_net(unsigned long addr)
 {
 	int res;
 
-	if ((res = tipc_net_start()) ||
+	if ((res = tipc_net_start(addr)) ||
 	    (res = tipc_eth_media_start())) {
 		tipc_core_stop_net();
 	}
diff --git a/net/tipc/core.h b/net/tipc/core.h
index bd78d17..a881f92 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -202,7 +202,7 @@ extern atomic_t tipc_user_count;
 
 extern int  tipc_core_start(void);
 extern void tipc_core_stop(void);
-extern int  tipc_core_start_net(void);
+extern int  tipc_core_start_net(unsigned long addr);
 extern void tipc_core_stop_net(void);
 extern int  tipc_handler_start(void);
 extern void tipc_handler_stop(void);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index c39c762..cc51fa4 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -266,7 +266,7 @@ void tipc_net_route_msg(struct sk_buff *buf)
 	tipc_link_send(buf, dnode, msg_link_selector(msg));
 }
 
-int tipc_net_start(void)
+int tipc_net_start(u32 addr)
 {
 	char addr_string[16];
 	int res;
@@ -274,6 +274,10 @@ int tipc_net_start(void)
 	if (tipc_mode != TIPC_NODE_MODE)
 		return -ENOPROTOOPT;
 
+	tipc_subscr_stop();
+	tipc_cfg_stop();
+
+	tipc_own_addr = addr;
 	tipc_mode = TIPC_NET_MODE;
 	tipc_named_reinit();
 	tipc_port_reinit();
@@ -284,10 +288,10 @@ int tipc_net_start(void)
 	    (res = tipc_bclink_init())) {
 		return res;
 	}
-	tipc_subscr_stop();
-	tipc_cfg_stop();
+
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_k_signal((Handler)tipc_cfg_init, 0);
+
 	info("Started in network mode\n");
 	info("Own node address %s, network identity %u\n",
 	     addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
diff --git a/net/tipc/net.h b/net/tipc/net.h
index a6a0e99..d154ac2 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -58,7 +58,7 @@ void tipc_net_route_msg(struct sk_buff *buf);
 struct node *tipc_net_select_remote_node(u32 addr, u32 ref);
 u32 tipc_net_select_router(u32 addr, u32 ref);
 
-int tipc_net_start(void);
+int tipc_net_start(u32 addr);
 void tipc_net_stop(void);
 
 #endif
-- 
1.5.3.2

