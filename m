From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next v2] tipc: remove two indentation levels in tipc_recv_msg routine
Date: Wed, 30 Oct 2013 11:26:57 +0800
Message-ID: <1383103617-28813-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Paul.Gortmaker@windriver.com>, <jon.maloy@ericsson.com>,
	<erik.hugne@ericsson.com>, <andreas.bofjall@ericsson.com>,
	<ying.xue@windriver.com>, <tipc-discussion@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
To: <davem@davemloft.net>, <David.Laight@aculab.com>,
	<maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:55845 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab3J3D1Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 23:27:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The message dispatching part of tipc_recv_msg() is wrapped layers of
while/if/if/switch, causing out-of-control indentation and does not
look very good. We reduce two indentation levels by separating the
message dispatching from the blocks that checks link state and
sequence numbers, allowing longer function and arg names to be
consistently indented without wrapping. Additionally we also rename
"cont" label to "discard" and add one new label called "unlock_discard"
to make code clearer. In all, these are cosmetic changes that do not
alter the operation of TIPC in any way.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Cc: David Laight <david.laight@aculab.com>
Cc: Andreas Bofj=C3=A4ll <andreas.bofjall@ericsson.com>
---
v2: Incorporated comments from David Laight and Andreas Bofj=C3=A4ll

 net/tipc/link.c |  173 +++++++++++++++++++++++++++--------------------=
--------
 1 file changed, 84 insertions(+), 89 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index e8153f6..54163f9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1507,15 +1507,15 @@ void tipc_recv_msg(struct sk_buff *head, struct=
 tipc_bearer *b_ptr)
=20
 		/* Ensure bearer is still enabled */
 		if (unlikely(!b_ptr->active))
-			goto cont;
+			goto discard;
=20
 		/* Ensure message is well-formed */
 		if (unlikely(!link_recv_buf_validate(buf)))
-			goto cont;
+			goto discard;
=20
 		/* Ensure message data is a single contiguous unit */
 		if (unlikely(skb_linearize(buf)))
-			goto cont;
+			goto discard;
=20
 		/* Handle arrival of a non-unicast link message */
 		msg =3D buf_msg(buf);
@@ -1531,20 +1531,18 @@ void tipc_recv_msg(struct sk_buff *head, struct=
 tipc_bearer *b_ptr)
 		/* Discard unicast link messages destined for another node */
 		if (unlikely(!msg_short(msg) &&
 			     (msg_destnode(msg) !=3D tipc_own_addr)))
-			goto cont;
+			goto discard;
=20
 		/* Locate neighboring node that sent message */
 		n_ptr =3D tipc_node_find(msg_prevnode(msg));
 		if (unlikely(!n_ptr))
-			goto cont;
+			goto discard;
 		tipc_node_lock(n_ptr);
=20
 		/* Locate unicast link endpoint that should handle message */
 		l_ptr =3D n_ptr->links[b_ptr->identity];
-		if (unlikely(!l_ptr)) {
-			tipc_node_unlock(n_ptr);
-			goto cont;
-		}
+		if (unlikely(!l_ptr))
+			goto unlock_discard;
=20
 		/* Verify that communication with node is currently allowed */
 		if ((n_ptr->block_setup & WAIT_PEER_DOWN) &&
@@ -1554,10 +1552,8 @@ void tipc_recv_msg(struct sk_buff *head, struct =
tipc_bearer *b_ptr)
 			!msg_redundant_link(msg))
 			n_ptr->block_setup &=3D ~WAIT_PEER_DOWN;
=20
-		if (n_ptr->block_setup) {
-			tipc_node_unlock(n_ptr);
-			goto cont;
-		}
+		if (n_ptr->block_setup)
+			goto unlock_discard;
=20
 		/* Validate message sequence number info */
 		seq_no =3D msg_seqno(msg);
@@ -1593,98 +1589,97 @@ void tipc_recv_msg(struct sk_buff *head, struct=
 tipc_bearer *b_ptr)
=20
 		/* Now (finally!) process the incoming message */
 protocol_check:
-		if (likely(link_working_working(l_ptr))) {
-			if (likely(seq_no =3D=3D mod(l_ptr->next_in_no))) {
-				l_ptr->next_in_no++;
-				if (unlikely(l_ptr->oldest_deferred_in))
-					head =3D link_insert_deferred_queue(l_ptr,
-									  head);
-deliver:
-				if (likely(msg_isdata(msg))) {
-					tipc_node_unlock(n_ptr);
-					tipc_port_recv_msg(buf);
-					continue;
-				}
-				switch (msg_user(msg)) {
-					int ret;
-				case MSG_BUNDLER:
-					l_ptr->stats.recv_bundles++;
-					l_ptr->stats.recv_bundled +=3D
-						msg_msgcnt(msg);
-					tipc_node_unlock(n_ptr);
-					tipc_link_recv_bundle(buf);
-					continue;
-				case NAME_DISTRIBUTOR:
-					n_ptr->bclink.recv_permitted =3D true;
-					tipc_node_unlock(n_ptr);
-					tipc_named_recv(buf);
-					continue;
-				case BCAST_PROTOCOL:
-					tipc_link_recv_sync(n_ptr, buf);
-					tipc_node_unlock(n_ptr);
-					continue;
-				case CONN_MANAGER:
-					tipc_node_unlock(n_ptr);
-					tipc_port_recv_proto_msg(buf);
-					continue;
-				case MSG_FRAGMENTER:
-					l_ptr->stats.recv_fragments++;
-					ret =3D tipc_link_recv_fragment(
-						&l_ptr->defragm_buf,
-						&buf, &msg);
-					if (ret =3D=3D 1) {
-						l_ptr->stats.recv_fragmented++;
-						goto deliver;
-					}
-					if (ret =3D=3D -1)
-						l_ptr->next_in_no--;
-					break;
-				case CHANGEOVER_PROTOCOL:
-					type =3D msg_type(msg);
-					if (link_recv_changeover_msg(&l_ptr,
-								     &buf)) {
-						msg =3D buf_msg(buf);
-						seq_no =3D msg_seqno(msg);
-						if (type =3D=3D ORIGINAL_MSG)
-							goto deliver;
-						goto protocol_check;
-					}
-					break;
-				default:
-					kfree_skb(buf);
-					buf =3D NULL;
-					break;
-				}
+		if (unlikely(!link_working_working(l_ptr))) {
+			if (msg_user(msg) =3D=3D LINK_PROTOCOL) {
+				link_recv_proto_msg(l_ptr, buf);
+				head =3D link_insert_deferred_queue(l_ptr, head);
+				tipc_node_unlock(n_ptr);
+				continue;
+			}
+
+			/* Traffic message. Conditionally activate link */
+			link_state_event(l_ptr, TRAFFIC_MSG_EVT);
+
+			if (link_working_working(l_ptr)) {
+				/* Re-insert buffer in front of queue */
+				buf->next =3D head;
+				head =3D buf;
 				tipc_node_unlock(n_ptr);
-				tipc_net_route_msg(buf);
 				continue;
 			}
+			goto unlock_discard;
+		}
+
+		/* Link is now in state WORKING_WORKING */
+		if (unlikely(seq_no !=3D mod(l_ptr->next_in_no))) {
 			link_handle_out_of_seq_msg(l_ptr, buf);
 			head =3D link_insert_deferred_queue(l_ptr, head);
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
-
-		/* Link is not in state WORKING_WORKING */
-		if (msg_user(msg) =3D=3D LINK_PROTOCOL) {
-			link_recv_proto_msg(l_ptr, buf);
+		l_ptr->next_in_no++;
+		if (unlikely(l_ptr->oldest_deferred_in))
 			head =3D link_insert_deferred_queue(l_ptr, head);
+deliver:
+		if (likely(msg_isdata(msg))) {
 			tipc_node_unlock(n_ptr);
+			tipc_port_recv_msg(buf);
 			continue;
 		}
-
-		/* Traffic message. Conditionally activate link */
-		link_state_event(l_ptr, TRAFFIC_MSG_EVT);
-
-		if (link_working_working(l_ptr)) {
-			/* Re-insert buffer in front of queue */
-			buf->next =3D head;
-			head =3D buf;
+		switch (msg_user(msg)) {
+			int ret;
+		case MSG_BUNDLER:
+			l_ptr->stats.recv_bundles++;
+			l_ptr->stats.recv_bundled +=3D msg_msgcnt(msg);
+			tipc_node_unlock(n_ptr);
+			tipc_link_recv_bundle(buf);
+			continue;
+		case NAME_DISTRIBUTOR:
+			n_ptr->bclink.recv_permitted =3D true;
+			tipc_node_unlock(n_ptr);
+			tipc_named_recv(buf);
+			continue;
+		case BCAST_PROTOCOL:
+			tipc_link_recv_sync(n_ptr, buf);
 			tipc_node_unlock(n_ptr);
 			continue;
+		case CONN_MANAGER:
+			tipc_node_unlock(n_ptr);
+			tipc_port_recv_proto_msg(buf);
+			continue;
+		case MSG_FRAGMENTER:
+			l_ptr->stats.recv_fragments++;
+			ret =3D tipc_link_recv_fragment(&l_ptr->defragm_buf,
+						      &buf, &msg);
+			if (ret =3D=3D 1) {
+				l_ptr->stats.recv_fragmented++;
+				goto deliver;
+			}
+			if (ret =3D=3D -1)
+				l_ptr->next_in_no--;
+			break;
+		case CHANGEOVER_PROTOCOL:
+			type =3D msg_type(msg);
+			if (link_recv_changeover_msg(&l_ptr, &buf)) {
+				msg =3D buf_msg(buf);
+				seq_no =3D msg_seqno(msg);
+				if (type =3D=3D ORIGINAL_MSG)
+					goto deliver;
+				goto protocol_check;
+			}
+			break;
+		default:
+			kfree_skb(buf);
+			buf =3D NULL;
+			break;
 		}
 		tipc_node_unlock(n_ptr);
-cont:
+		tipc_net_route_msg(buf);
+		continue;
+unlock_discard:
+
+		tipc_node_unlock(n_ptr);
+discard:
 		kfree_skb(buf);
 	}
 	read_unlock_bh(&tipc_net_lock);
--=20
1.7.9.5
