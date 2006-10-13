From: Per Liden <per.liden@ericsson.com>
Subject: [PATCH 4/14] [TIPC] Added duplicate node address detection capability
Date: Fri, 13 Oct 2006 13:37:45 +0200
Message-ID: <11607394752476-git-send-email-per.liden@ericsson.com>
References: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Reply-To: Per Liden <per.liden@ericsson.com>
Cc: netdev@vger.kernel.org,
	Allan Stephens <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw3.ericsson.se ([193.180.251.60]:51596 "EHLO
	mailgw3.ericsson.se") by vger.kernel.org with ESMTP
	id S1751381AbWJMLiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 07:38:00 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0610131330350.30166@ulinpc219.uab.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Allan Stephens <allan.stephens@windriver.com>

TIPC now rejects and logs link setup requests from node <Z.C.N> if the
receiving node already has a functional link to that node on the associated
interface, or if the requestor is using the same <Z.C.N> as the receiver.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Per Liden <per.liden@ericsson.com>
---
 net/tipc/bearer.c   |    8 ++++----
 net/tipc/discover.c |   32 +++++++++++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 5 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 75a5968..fc85a12 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -2,7 +2,7 @@
  * net/tipc/bearer.c: TIPC bearer code
  * 
  * Copyright (c) 1996-2006, Ericsson AB
- * Copyright (c) 2004-2005, Wind River Systems
+ * Copyright (c) 2004-2006, Wind River Systems
  * All rights reserved.
  *
  * Redistribution and use in source and binary forms, with or without
@@ -191,14 +191,14 @@ void tipc_media_addr_printf(struct print
 	if ((i < media_count) && (m_ptr->addr2str != NULL)) {
 		char addr_str[MAX_ADDR_STR];
 
-		tipc_printf(pb, "%s(%s) ", m_ptr->name, 
+		tipc_printf(pb, "%s(%s)", m_ptr->name, 
 			    m_ptr->addr2str(a, addr_str, sizeof(addr_str)));
 	} else {
 		unchar *addr = (unchar *)&a->dev_addr;
 
-		tipc_printf(pb, "UNKNOWN(%u):", media_type);
+		tipc_printf(pb, "UNKNOWN(%u)", media_type);
 		for (i = 0; i < (sizeof(*a) - sizeof(a->type)); i++) {
-			tipc_printf(pb, "%02x ", addr[i]);
+			tipc_printf(pb, "-%02x", addr[i]);
 		}
 	}
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ee94de9..f58cc3c 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -132,6 +132,28 @@ static struct sk_buff *tipc_disc_init_ms
 }
 
 /**
+ * disc_dupl_alert - issue node address duplication alert
+ * @b_ptr: pointer to bearer detecting duplication
+ * @node_addr: duplicated node address
+ * @media_addr: media address advertised by duplicated node
+ */
+
+static void disc_dupl_alert(struct bearer *b_ptr, u32 node_addr, 
+			    struct tipc_media_addr *media_addr)
+{
+	char node_addr_str[16];
+	char media_addr_str[64];
+	struct print_buf pb;
+
+	addr_string_fill(node_addr_str, node_addr);
+	tipc_printbuf_init(&pb, media_addr_str, sizeof(media_addr_str));
+	tipc_media_addr_printf(&pb, media_addr);
+	tipc_printbuf_validate(&pb);
+	warn("Duplicate %s using %s seen on <%s>\n",
+	     node_addr_str, media_addr_str, b_ptr->publ.name);
+}
+
+/**
  * tipc_disc_recv_msg - handle incoming link setup message (request or response)
  * @buf: buffer containing message
  */
@@ -157,8 +179,11 @@ void tipc_disc_recv_msg(struct sk_buff *
 		return;
 	if (!tipc_addr_node_valid(orig))
 		return;
-	if (orig == tipc_own_addr)
+	if (orig == tipc_own_addr) {
+		if (memcmp(&media_addr, &b_ptr->publ.addr, sizeof(media_addr)))
+			disc_dupl_alert(b_ptr, tipc_own_addr, &media_addr);
 		return;
+	}
 	if (!in_scope(dest, tipc_own_addr))
 		return;
 	if (is_slave(tipc_own_addr) && is_slave(orig))
@@ -190,6 +215,11 @@ void tipc_disc_recv_msg(struct sk_buff *
 		}
 		addr = &link->media_addr;
 		if (memcmp(addr, &media_addr, sizeof(*addr))) {
+			if (tipc_link_is_up(link) || (!link->started)) {
+				disc_dupl_alert(b_ptr, orig, &media_addr);
+				spin_unlock_bh(&n_ptr->lock);                
+				return;
+			}
 			warn("Resetting link <%s>, peer interface address changed\n",
 			     link->name);
 			memcpy(addr, &media_addr, sizeof(*addr));
-- 
1.4.1

