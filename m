From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 8/8] tipc: simplify the link lookup routine
Date: Fri, 18 Oct 2013 07:23:21 +0200
Message-ID: <1382073801-22128-9-git-send-email-jon.maloy@ericsson.com>
References: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:46748 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750943Ab3JRFac (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 01:30:32 -0400
In-Reply-To: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

When checking statistics or changing parameters on a link, the
link_find_link function is used to locate the link with a given
name. The complex method of deconstructing the name into local
and remote address/interface is error prone and may fail if the
interface names contains special characters. We change the lookup
method to iterate over the list of nodes and compare the link
names.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c |  110 +++++++------------------------------------------------
 1 file changed, 13 insertions(+), 97 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 223bbc8..e8153f6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -75,20 +75,6 @@ static const char *link_unk_evt = "Unknown link event ";
  */
 #define START_CHANGEOVER 100000u
 
-/**
- * struct tipc_link_name - deconstructed link name
- * @addr_local: network address of node at this end
- * @if_local: name of interface at this end
- * @addr_peer: network address of node at far end
- * @if_peer: name of interface at far end
- */
-struct tipc_link_name {
-	u32 addr_local;
-	char if_local[TIPC_MAX_IF_NAME];
-	u32 addr_peer;
-	char if_peer[TIPC_MAX_IF_NAME];
-};
-
 static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 				       struct sk_buff *buf);
 static void link_recv_proto_msg(struct tipc_link *l_ptr, struct sk_buff *buf);
@@ -160,72 +146,6 @@ int tipc_link_is_active(struct tipc_link *l_ptr)
 }
 
 /**
- * link_name_validate - validate & (optionally) deconstruct tipc_link name
- * @name: ptr to link name string
- * @name_parts: ptr to area for link name components (or NULL if not needed)
- *
- * Returns 1 if link name is valid, otherwise 0.
- */
-static int link_name_validate(const char *name,
-				struct tipc_link_name *name_parts)
-{
-	char name_copy[TIPC_MAX_LINK_NAME];
-	char *addr_local;
-	char *if_local;
-	char *addr_peer;
-	char *if_peer;
-	char dummy;
-	u32 z_local, c_local, n_local;
-	u32 z_peer, c_peer, n_peer;
-	u32 if_local_len;
-	u32 if_peer_len;
-
-	/* copy link name & ensure length is OK */
-	name_copy[TIPC_MAX_LINK_NAME - 1] = 0;
-	/* need above in case non-Posix strncpy() doesn't pad with nulls */
-	strncpy(name_copy, name, TIPC_MAX_LINK_NAME);
-	if (name_copy[TIPC_MAX_LINK_NAME - 1] != 0)
-		return 0;
-
-	/* ensure all component parts of link name are present */
-	addr_local = name_copy;
-	if_local = strchr(addr_local, ':');
-	if (if_local == NULL)
-		return 0;
-	*(if_local++) = 0;
-	addr_peer = strchr(if_local, '-');
-	if (addr_peer == NULL)
-		return 0;
-	*(addr_peer++) = 0;
-	if_local_len = addr_peer - if_local;
-	if_peer = strchr(addr_peer, ':');
-	if (if_peer == NULL)
-		return 0;
-	*(if_peer++) = 0;
-	if_peer_len = strlen(if_peer) + 1;
-
-	/* validate component parts of link name */
-	if ((sscanf(addr_local, "%u.%u.%u%c",
-		    &z_local, &c_local, &n_local, &dummy) != 3) ||
-	    (sscanf(addr_peer, "%u.%u.%u%c",
-		    &z_peer, &c_peer, &n_peer, &dummy) != 3) ||
-	    (z_local > 255) || (c_local > 4095) || (n_local > 4095) ||
-	    (z_peer  > 255) || (c_peer  > 4095) || (n_peer  > 4095) ||
-	    (if_local_len <= 1) || (if_local_len > TIPC_MAX_IF_NAME) ||
-	    (if_peer_len  <= 1) || (if_peer_len  > TIPC_MAX_IF_NAME))
-		return 0;
-
-	/* return link name components, if necessary */
-	if (name_parts) {
-		name_parts->addr_local = tipc_addr(z_local, c_local, n_local);
-		strcpy(name_parts->if_local, if_local);
-		name_parts->addr_peer = tipc_addr(z_peer, c_peer, n_peer);
-		strcpy(name_parts->if_peer, if_peer);
-	}
-	return 1;
-}
-
-/**
  * link_timeout - handle expiration of link timer
  * @l_ptr: pointer to link
  *
@@ -2580,25 +2500,21 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window)
 static struct tipc_link *link_find_link(const char *name,
 					struct tipc_node **node)
 {
-	struct tipc_link_name link_name_parts;
-	struct tipc_bearer *b_ptr;
 	struct tipc_link *l_ptr;
+	struct tipc_node *n_ptr;
+	int i;
 
-	if (!link_name_validate(name, &link_name_parts))
-		return NULL;
-
-	b_ptr = tipc_bearer_find_interface(link_name_parts.if_local);
-	if (!b_ptr)
-		return NULL;
-
-	*node = tipc_node_find(link_name_parts.addr_peer);
-	if (!*node)
-		return NULL;
-
-	l_ptr = (*node)->links[b_ptr->identity];
-	if (!l_ptr || strcmp(l_ptr->name, name))
-		return NULL;
-
+	list_for_each_entry(n_ptr, &tipc_node_list, list) {
+		for (i = 0; i < MAX_BEARERS; i++) {
+			l_ptr = n_ptr->links[i];
+			if (l_ptr && !strcmp(l_ptr->name, name))
+				goto found;
+		}
+	}
+	l_ptr = NULL;
+	n_ptr = NULL;
+found:
+	*node = n_ptr;
 	return l_ptr;
 }
 
-- 
1.7.9.5
