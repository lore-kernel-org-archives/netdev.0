From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 27/32] [TIPC] Disallow config operations that aren't supported in certain modes.
Date: Thu, 22 Jun 2006 15:59:40 +0200
Message-ID: <11509847872189-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:57018 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1030663AbWFVN7x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 09:59:53 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0606221233570.15853@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

This change provides user-friendly feedback when TIPC is unable to perform
certain configuration operations that don't work properly in certain modes.
(In particular, any reconfiguration request that would temporarily take TIPC
from network mode to standalone mode, or from standalone mode to not running
mode, is disallowed.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/config.c |   83 ++++++++++++++++++++++++-----------------------------
 1 files changed, 38 insertions(+), 45 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 48b5de2..41c8447 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -291,13 +291,22 @@ static struct sk_buff *cfg_set_own_addr(
 	if (!tipc_addr_node_valid(addr))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (node address)");
-	if (tipc_own_addr)
+	if (tipc_mode == TIPC_NET_MODE)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
+	tipc_own_addr = addr;
+
+	/* 
+	 * Must release all spinlocks before calling start_net() because
+	 * Linux version of TIPC calls eth_media_start() which calls
+	 * register_netdevice_notifier() which may block!
+	 *
+	 * Temporarily releasing the lock should be harmless for non-Linux TIPC,
+	 * but Linux version of eth_media_start() should really be reworked
+	 * so that it can be called with spinlocks held.
+	 */
 
 	spin_unlock_bh(&config_lock);
-	tipc_core_stop_net();
-	tipc_own_addr = addr;
 	tipc_core_start_net();
 	spin_lock_bh(&config_lock);
 	return tipc_cfg_reply_none();
@@ -350,50 +359,21 @@ static struct sk_buff *cfg_set_max_subsc
 
 static struct sk_buff *cfg_set_max_ports(void)
 {
-	int orig_mode;
 	u32 value;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = *(u32 *)TLV_DATA(req_tlv_area);
 	value = ntohl(value);
+	if (value == tipc_max_ports)
+		return tipc_cfg_reply_none();
 	if (value != delimit(value, 127, 65535))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max ports must be 127-65535)");
-
-	if (value == tipc_max_ports)
-		return tipc_cfg_reply_none();
-
-	if (atomic_read(&tipc_user_count) > 2)
+	if (tipc_mode != TIPC_NOT_RUNNING)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change max ports while TIPC users exist)");
-
-	spin_unlock_bh(&config_lock);
-	orig_mode = tipc_get_mode();
-	if (orig_mode == TIPC_NET_MODE)
-		tipc_core_stop_net();
-	tipc_core_stop();
+			" (cannot change max ports while TIPC is active)");
 	tipc_max_ports = value;
-	tipc_core_start();
-	if (orig_mode == TIPC_NET_MODE)
-		tipc_core_start_net();
-	spin_lock_bh(&config_lock);
-	return tipc_cfg_reply_none();
-}
-
-static struct sk_buff *set_net_max(int value, int *parameter)
-{
-	int orig_mode;
-
-	if (value != *parameter) {
-		orig_mode = tipc_get_mode();
-		if (orig_mode == TIPC_NET_MODE)
-			tipc_core_stop_net();
-		*parameter = value;
-		if (orig_mode == TIPC_NET_MODE)
-			tipc_core_start_net();
-	}
-
 	return tipc_cfg_reply_none();
 }
 
@@ -405,10 +385,16 @@ static struct sk_buff *cfg_set_max_zones
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = *(u32 *)TLV_DATA(req_tlv_area);
 	value = ntohl(value);
+	if (value == tipc_max_zones)
+		return tipc_cfg_reply_none();
 	if (value != delimit(value, 1, 255))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max zones must be 1-255)");
-	return set_net_max(value, &tipc_max_zones);
+	if (tipc_mode == TIPC_NET_MODE)
+		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+			" (cannot change max zones once TIPC has joined a network)");
+	tipc_max_zones = value;
+	return tipc_cfg_reply_none();
 }
 
 static struct sk_buff *cfg_set_max_clusters(void)
@@ -419,8 +405,8 @@ static struct sk_buff *cfg_set_max_clust
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = *(u32 *)TLV_DATA(req_tlv_area);
 	value = ntohl(value);
-	if (value != 1)
-		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+	if (value != delimit(value, 1, 1))
+		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max clusters fixed at 1)");
 	return tipc_cfg_reply_none();
 }
@@ -433,10 +419,16 @@ static struct sk_buff *cfg_set_max_nodes
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = *(u32 *)TLV_DATA(req_tlv_area);
 	value = ntohl(value);
+	if (value == tipc_max_nodes)
+		return tipc_cfg_reply_none();
 	if (value != delimit(value, 8, 2047))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (max nodes must be 8-2047)");
-	return set_net_max(value, &tipc_max_nodes);
+	if (tipc_mode == TIPC_NET_MODE)
+		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
+			" (cannot change max nodes once TIPC has joined a network)");
+	tipc_max_nodes = value;
+	return tipc_cfg_reply_none();
 }
 
 static struct sk_buff *cfg_set_max_slaves(void)
@@ -461,15 +453,16 @@ static struct sk_buff *cfg_set_netid(voi
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = *(u32 *)TLV_DATA(req_tlv_area);
 	value = ntohl(value);
+	if (value == tipc_net_id)
+		return tipc_cfg_reply_none();
 	if (value != delimit(value, 1, 9999))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network id must be 1-9999)");
-
-	if (tipc_own_addr)
+	if (tipc_mode == TIPC_NET_MODE)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
-						   " (cannot change network id once part of network)");
-	
-	return set_net_max(value, &tipc_net_id);
+			" (cannot change network id once TIPC has joined a network)");
+	tipc_net_id = value;
+	return tipc_cfg_reply_none();
 }
 
 struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area,
-- 
1.4.0

