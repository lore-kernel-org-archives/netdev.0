From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 08/10] tipc: convert allocations of global variables associated with bclink
Date: Mon, 5 May 2014 08:56:16 +0800
Message-ID: <1399251378-23842-9-git-send-email-ying.xue@windriver.com>
References: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Paul.Gortmaker@windriver.com>,
	<erik.hugne@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:59971 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbaEEA44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2014 20:56:56 -0400
In-Reply-To: <1399251378-23842-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert allocations of global variables associated with bclink from
static way to dynamical way for the convenience of bclink instance
initialisation. Meanwhile, this also helps TIPC support name space
in the future easily.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c  |   28 +++++++++++++++++++---------
 net/tipc/bcast.h  |    2 +-
 net/tipc/config.c |    6 ++++--
 net/tipc/net.c    |    9 +++++++--
 net/tipc/net.h    |    2 +-
 5 files changed, 32 insertions(+), 15 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 9eceaa7..ef8cff4 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -100,12 +100,9 @@ struct tipc_bclink {
 	struct tipc_node *retransmit_to;
 };
 
-static struct tipc_bcbearer bcast_bearer;
-static struct tipc_bclink bcast_link;
-
-static struct tipc_bcbearer *bcbearer = &bcast_bearer;
-static struct tipc_bclink *bclink = &bcast_link;
-static struct tipc_link *bcl = &bcast_link.link;
+static struct tipc_bcbearer *bcbearer;
+static struct tipc_bclink *bclink;
+static struct tipc_link *bcl;
 
 const char tipc_bclink_name[] = "broadcast-link";
 
@@ -788,8 +785,19 @@ int tipc_bclink_set_queue_limits(u32 limit)
 	return 0;
 }
 
-void tipc_bclink_init(void)
+int tipc_bclink_init(void)
 {
+	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
+	if (!bcbearer)
+		return -ENOMEM;
+
+	bclink = kzalloc(sizeof(*bclink), GFP_ATOMIC);
+	if (!bclink) {
+		kfree(bcbearer);
+		return -ENOMEM;
+	}
+
+	bcl = &bclink->link;
 	bcbearer->bearer.media = &bcbearer->media;
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-broadcast");
@@ -805,6 +813,7 @@ void tipc_bclink_init(void)
 	rcu_assign_pointer(bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
+	return 0;
 }
 
 void tipc_bclink_stop(void)
@@ -814,8 +823,9 @@ void tipc_bclink_stop(void)
 	tipc_bclink_unlock();
 
 	RCU_INIT_POINTER(bearer_list[BCBEARER], NULL);
-	memset(bclink, 0, sizeof(*bclink));
-	memset(bcbearer, 0, sizeof(*bcbearer));
+	synchronize_net();
+	kfree(bcbearer);
+	kfree(bclink);
 }
 
 /**
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 7c1ef1b..ea162c7 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -81,7 +81,7 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a,
 void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port);
 void tipc_port_list_free(struct tipc_port_list *pl_ptr);
 
-void tipc_bclink_init(void);
+int tipc_bclink_init(void);
 void tipc_bclink_stop(void);
 void tipc_bclink_add_node(u32 addr);
 void tipc_bclink_remove_node(u32 addr);
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 251f5a2..2b42403 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -177,8 +177,10 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
-	tipc_net_start(addr);
-	return tipc_cfg_reply_none();
+	if (!tipc_net_start(addr))
+		return tipc_cfg_reply_none();
+
+	return tipc_cfg_reply_error_string("cannot change to network mode");
 }
 
 static struct sk_buff *cfg_set_max_ports(void)
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 75bb390..f8fc95d 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -164,20 +164,25 @@ void tipc_net_route_msg(struct sk_buff *buf)
 	tipc_link_xmit(buf, dnode, msg_link_selector(msg));
 }
 
-void tipc_net_start(u32 addr)
+int tipc_net_start(u32 addr)
 {
 	char addr_string[16];
+	int res;
 
 	tipc_own_addr = addr;
 	tipc_named_reinit();
 	tipc_port_reinit();
-	tipc_bclink_init();
+	res = tipc_bclink_init();
+	if (res)
+		return res;
+
 	tipc_nametbl_publish(TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
 			     TIPC_ZONE_SCOPE, 0, tipc_own_addr);
 
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
 		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
+	return 0;
 }
 
 void tipc_net_stop(void)
diff --git a/net/tipc/net.h b/net/tipc/net.h
index f781cae..c6c2b46 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -39,7 +39,7 @@
 
 void tipc_net_route_msg(struct sk_buff *buf);
 
-void tipc_net_start(u32 addr);
+int tipc_net_start(u32 addr);
 void tipc_net_stop(void);
 
 #endif
-- 
1.7.9.5
