From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 17/23] tipc: Eliminate dynamic allocation of broadcast link data structures
Date: Tue, 27 Dec 2011 12:39:36 -0500
Message-ID: <1325007582-31610-18-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39484 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754828Ab1L0RkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:40:08 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Creates global variables to hold the broadcast link's pseudo-bearer and
pseudo-link structures, rather than allocating them dynamically. There
is only a single instance of each structure, and changing over to static
allocation allows elimination of code to handle the cases where dynamic
allocation was unsuccessful.

The memset in the teardown code may look like they aren't used, but
the same teardown code is run when there is a non-fatal error at
init-time, so that stale data isn't present when the user fixes the
cause of the soft error.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   37 +++++++++++--------------------------
 net/tipc/bcast.h |    2 +-
 net/tipc/net.c   |    5 +----
 3 files changed, 13 insertions(+), 31 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 28908f5..738cb64 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -98,10 +98,13 @@ struct bclink {
 	struct tipc_node *retransmit_to;
 };
 
+static struct bcbearer bcast_bearer;
+static struct bclink bcast_link;
+
+static struct bcbearer *bcbearer = &bcast_bearer;
+static struct bclink *bclink = &bcast_link;
+static struct link *bcl = &bcast_link.link;
 
-static struct bcbearer *bcbearer;
-static struct bclink *bclink;
-static struct link *bcl;
 static DEFINE_SPINLOCK(bc_lock);
 
 /* broadcast-capable node map */
@@ -752,25 +755,13 @@ int tipc_bclink_set_queue_limits(u32 limit)
 	return 0;
 }
 
-int tipc_bclink_init(void)
+void tipc_bclink_init(void)
 {
-	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
-	bclink = kzalloc(sizeof(*bclink), GFP_ATOMIC);
-	if (!bcbearer || !bclink) {
-		warn("Broadcast link creation failed, no memory\n");
-		kfree(bcbearer);
-		bcbearer = NULL;
-		kfree(bclink);
-		bclink = NULL;
-		return -ENOMEM;
-	}
-
 	INIT_LIST_HEAD(&bcbearer->bearer.cong_links);
 	bcbearer->bearer.media = &bcbearer->media;
 	bcbearer->media.send_msg = tipc_bcbearer_send;
 	sprintf(bcbearer->media.name, "tipc-broadcast");
 
-	bcl = &bclink->link;
 	INIT_LIST_HEAD(&bcl->waiting_ports);
 	bcl->next_out_no = 1;
 	spin_lock_init(&bclink->node.lock);
@@ -780,22 +771,16 @@ int tipc_bclink_init(void)
 	bcl->b_ptr = &bcbearer->bearer;
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
-
-	return 0;
 }
 
 void tipc_bclink_stop(void)
 {
 	spin_lock_bh(&bc_lock);
-	if (bcbearer) {
-		tipc_link_stop(bcl);
-		bcl = NULL;
-		kfree(bclink);
-		bclink = NULL;
-		kfree(bcbearer);
-		bcbearer = NULL;
-	}
+	tipc_link_stop(bcl);
 	spin_unlock_bh(&bc_lock);
+
+	memset(bclink, 0, sizeof(*bclink));
+	memset(bcbearer, 0, sizeof(*bcbearer));
 }
 
 
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 06740da..0b04443 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -88,7 +88,7 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a, struct tipc_node_m
 void tipc_port_list_add(struct port_list *pl_ptr, u32 port);
 void tipc_port_list_free(struct port_list *pl_ptr);
 
-int  tipc_bclink_init(void);
+void tipc_bclink_init(void);
 void tipc_bclink_stop(void);
 struct tipc_node *tipc_bclink_retransmit_to(void);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index e13162f..61afee7 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -174,7 +174,6 @@ void tipc_net_route_msg(struct sk_buff *buf)
 int tipc_net_start(u32 addr)
 {
 	char addr_string[16];
-	int res;
 
 	if (tipc_mode != TIPC_NODE_MODE)
 		return -ENOPROTOOPT;
@@ -187,9 +186,7 @@ int tipc_net_start(u32 addr)
 	tipc_named_reinit();
 	tipc_port_reinit();
 
-	res = tipc_bclink_init();
-	if (res)
-		return res;
+	tipc_bclink_init();
 
 	tipc_k_signal((Handler)tipc_subscr_start, 0);
 	tipc_k_signal((Handler)tipc_cfg_init, 0);
-- 
1.7.4.4
