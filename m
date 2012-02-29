From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/17] tipc: Remove duplicate check of message destination node
Date: Wed, 29 Feb 2012 18:18:29 -0500
Message-ID: <1330557523-2024-4-git-send-email-paul.gortmaker@windriver.com>
References: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:53931 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965134Ab2B2XS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Feb 2012 18:18:58 -0500
In-Reply-To: <1330557523-2024-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Eliminates a check in the processing of TIPC messages arriving from
off node that ensures the message is destined for this node, since this
check duplicates an earlier check. (The check would be necessary if TIPC
needed to be able to route incoming messages to another node, but the
elimination of multi-cluster support means that this never happens and
all incoming messages are consumed by the receiving node.)

Note: This change involves the elimination of a single "if" statement
with a large "then" clause; consequently, a significant number of lines
end up getting re-indented. In addition, a simple message header access
routine that is no longer referenced is eliminated. However, the only
functional change is the elimination of the single check described above.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c |   93 +++++++++++++++++++++++++++----------------------------
 net/tipc/msg.h  |    5 ---
 2 files changed, 46 insertions(+), 52 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index d8b0a22..6cc78a9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1773,57 +1773,56 @@ protocol_check:
 				if (unlikely(l_ptr->oldest_deferred_in))
 					head = link_insert_deferred_queue(l_ptr,
 									  head);
-				if (likely(msg_is_dest(msg, tipc_own_addr))) {
-					int ret;
 deliver:
-					if (likely(msg_isdata(msg))) {
-						tipc_node_unlock(n_ptr);
-						tipc_port_recv_msg(buf);
-						continue;
+				if (likely(msg_isdata(msg))) {
+					tipc_node_unlock(n_ptr);
+					tipc_port_recv_msg(buf);
+					continue;
+				}
+				switch (msg_user(msg)) {
+					int ret;
+				case MSG_BUNDLER:
+					l_ptr->stats.recv_bundles++;
+					l_ptr->stats.recv_bundled +=
+						msg_msgcnt(msg);
+					tipc_node_unlock(n_ptr);
+					tipc_link_recv_bundle(buf);
+					continue;
+				case NAME_DISTRIBUTOR:
+					tipc_node_unlock(n_ptr);
+					tipc_named_recv(buf);
+					continue;
+				case CONN_MANAGER:
+					tipc_node_unlock(n_ptr);
+					tipc_port_recv_proto_msg(buf);
+					continue;
+				case MSG_FRAGMENTER:
+					l_ptr->stats.recv_fragments++;
+					ret = tipc_link_recv_fragment(
+						&l_ptr->defragm_buf,
+						&buf, &msg);
+					if (ret == 1) {
+						l_ptr->stats.recv_fragmented++;
+						goto deliver;
 					}
-					switch (msg_user(msg)) {
-					case MSG_BUNDLER:
-						l_ptr->stats.recv_bundles++;
-						l_ptr->stats.recv_bundled +=
-							msg_msgcnt(msg);
-						tipc_node_unlock(n_ptr);
-						tipc_link_recv_bundle(buf);
-						continue;
-					case NAME_DISTRIBUTOR:
-						tipc_node_unlock(n_ptr);
-						tipc_named_recv(buf);
-						continue;
-					case CONN_MANAGER:
-						tipc_node_unlock(n_ptr);
-						tipc_port_recv_proto_msg(buf);
-						continue;
-					case MSG_FRAGMENTER:
-						l_ptr->stats.recv_fragments++;
-						ret = tipc_link_recv_fragment(
-							&l_ptr->defragm_buf,
-							&buf, &msg);
-						if (ret == 1) {
-							l_ptr->stats.recv_fragmented++;
+					if (ret == -1)
+						l_ptr->next_in_no--;
+					break;
+				case CHANGEOVER_PROTOCOL:
+					type = msg_type(msg);
+					if (link_recv_changeover_msg(&l_ptr,
+								     &buf)) {
+						msg = buf_msg(buf);
+						seq_no = msg_seqno(msg);
+						if (type == ORIGINAL_MSG)
 							goto deliver;
-						}
-						if (ret == -1)
-							l_ptr->next_in_no--;
-						break;
-					case CHANGEOVER_PROTOCOL:
-						type = msg_type(msg);
-						if (link_recv_changeover_msg(&l_ptr, &buf)) {
-							msg = buf_msg(buf);
-							seq_no = msg_seqno(msg);
-							if (type == ORIGINAL_MSG)
-								goto deliver;
-							goto protocol_check;
-						}
-						break;
-					default:
-						buf_discard(buf);
-						buf = NULL;
-						break;
+						goto protocol_check;
 					}
+					break;
+				default:
+					buf_discard(buf);
+					buf = NULL;
+					break;
 				}
 				tipc_node_unlock(n_ptr);
 				tipc_net_route_msg(buf);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 2ec13b7..eba524e3 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -384,11 +384,6 @@ static inline void msg_set_destnode(struct tipc_msg *m, u32 a)
 	msg_set_word(m, 7, a);
 }
 
-static inline int msg_is_dest(struct tipc_msg *m, u32 d)
-{
-	return msg_short(m) || (msg_destnode(m) == d);
-}
-
 static inline u32 msg_nametype(struct tipc_msg *m)
 {
 	return msg_word(m, 8);
-- 
1.7.9.1
