From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH 02/14] sctp: use list_for_each_entry*
Date: Fri, 18 Dec 2015 23:33:26 +0800
Message-ID: <e7b5bfc4a114ea85e85e4038199d3e5a76040148.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Cc: Geliang Tang <geliangtang@163.com>, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
In-Reply-To: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
References: <ab66a344512e064000357c6d3c2a6f3d0e948ddb.1450451516.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use list_for_each_entry*() instead of list_for_each*() to simplify
the code.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 net/sctp/associola.c     | 24 +++++++++------------
 net/sctp/chunk.c         | 16 ++++++--------
 net/sctp/outqueue.c      | 56 +++++++++++++++++++-----------------------------
 net/sctp/protocol.c      | 12 ++++-------
 net/sctp/sm_make_chunk.c | 11 +++++-----
 net/sctp/sm_sideeffect.c |  8 +++----
 net/sctp/socket.c        |  7 ++----
 7 files changed, 52 insertions(+), 82 deletions(-)

diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 559afd0..a7065ca 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -324,8 +324,7 @@ fail:
 void sctp_association_free(struct sctp_association *asoc)
 {
 	struct sock *sk = asoc->base.sk;
-	struct sctp_transport *transport;
-	struct list_head *pos, *temp;
+	struct sctp_transport *transport, *temp;
 	int i;
 
 	/* Only real associations count against the endpoint, so
@@ -380,9 +379,9 @@ void sctp_association_free(struct sctp_association *asoc)
 	kfree(asoc->peer.peer_hmacs);
 
 	/* Release the transport structures. */
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
-		list_del_rcu(pos);
+	list_for_each_entry_safe(transport, temp,
+				 &asoc->peer.transport_addr_list, transports) {
+		list_del_rcu(&transport->transports);
 		sctp_transport_free(transport);
 	}
 
@@ -718,12 +717,10 @@ struct sctp_transport *sctp_assoc_add_peer(struct sctp_association *asoc,
 void sctp_assoc_del_peer(struct sctp_association *asoc,
 			 const union sctp_addr *addr)
 {
-	struct list_head	*pos;
-	struct list_head	*temp;
-	struct sctp_transport	*transport;
+	struct sctp_transport	*transport, *temp;
 
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry_safe(transport, temp,
+				 &asoc->peer.transport_addr_list, transports) {
 		if (sctp_cmp_addr_exact(addr, &transport->ipaddr)) {
 			/* Do book keeping for removing the peer and free it. */
 			sctp_assoc_rm_peer(asoc, transport);
@@ -1090,8 +1087,7 @@ void sctp_assoc_migrate(struct sctp_association *assoc, struct sock *newsk)
 void sctp_assoc_update(struct sctp_association *asoc,
 		       struct sctp_association *new)
 {
-	struct sctp_transport *trans;
-	struct list_head *pos, *temp;
+	struct sctp_transport *trans, *temp;
 
 	/* Copy in new parameters of peer. */
 	asoc->c = new->c;
@@ -1103,8 +1099,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			 asoc->peer.i.initial_tsn, GFP_ATOMIC);
 
 	/* Remove any peer addresses not present in the new association. */
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		trans = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry_safe(trans, temp,
+				 &asoc->peer.transport_addr_list, transports) {
 		if (!sctp_assoc_lookup_paddr(new, &trans->ipaddr)) {
 			sctp_assoc_rm_peer(asoc, trans);
 			continue;
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index a338091..b024109 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -86,8 +86,7 @@ void sctp_datamsg_free(struct sctp_datamsg *msg)
 /* Final destructruction of datamsg memory. */
 static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 {
-	struct list_head *pos, *temp;
-	struct sctp_chunk *chunk;
+	struct sctp_chunk *chunk, *temp;
 	struct sctp_sock *sp;
 	struct sctp_ulpevent *ev;
 	struct sctp_association *asoc = NULL;
@@ -97,9 +96,8 @@ static void sctp_datamsg_destroy(struct sctp_datamsg *msg)
 	notify = msg->send_failed ? -1 : 0;
 
 	/* Release all references. */
-	list_for_each_safe(pos, temp, &msg->chunks) {
-		list_del_init(pos);
-		chunk = list_entry(pos, struct sctp_chunk, frag_list);
+	list_for_each_entry_safe(chunk, temp, &msg->chunks, frag_list) {
+		list_del_init(&chunk->frag_list);
 		/* Check whether we _really_ need to notify. */
 		if (notify < 0) {
 			asoc = chunk->asoc;
@@ -169,9 +167,8 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	int max, whole, i, offset, over, err;
 	int len, first_len;
 	int max_data;
-	struct sctp_chunk *chunk;
+	struct sctp_chunk *chunk, *temp;
 	struct sctp_datamsg *msg;
-	struct list_head *pos, *temp;
 	size_t msg_len = iov_iter_count(from);
 	__u8 frag;
 
@@ -334,9 +331,8 @@ errout_chunk_free:
 	sctp_chunk_free(chunk);
 
 errout:
-	list_for_each_safe(pos, temp, &msg->chunks) {
-		list_del_init(pos);
-		chunk = list_entry(pos, struct sctp_chunk, frag_list);
+	list_for_each_entry_safe(chunk, temp, &msg->chunks, frag_list) {
+		list_del_init(&chunk->frag_list);
 		sctp_chunk_free(chunk);
 	}
 	sctp_datamsg_put(msg);
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 7e8f0a1..f72a443 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -214,7 +214,7 @@ void sctp_outq_init(struct sctp_association *asoc, struct sctp_outq *q)
 static void __sctp_outq_teardown(struct sctp_outq *q)
 {
 	struct sctp_transport *transport;
-	struct list_head *lchunk, *temp;
+	struct list_head *lchunk;
 	struct sctp_chunk *chunk, *tmp;
 
 	/* Throw away unacknowledged chunks. */
@@ -230,28 +230,22 @@ static void __sctp_outq_teardown(struct sctp_outq *q)
 	}
 
 	/* Throw away chunks that have been gap ACKed.  */
-	list_for_each_safe(lchunk, temp, &q->sacked) {
-		list_del_init(lchunk);
-		chunk = list_entry(lchunk, struct sctp_chunk,
-				   transmitted_list);
+	list_for_each_entry_safe(chunk, tmp, &q->sacked, transmitted_list) {
+		list_del_init(&chunk->transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
 		sctp_chunk_free(chunk);
 	}
 
 	/* Throw away any chunks in the retransmit queue. */
-	list_for_each_safe(lchunk, temp, &q->retransmit) {
-		list_del_init(lchunk);
-		chunk = list_entry(lchunk, struct sctp_chunk,
-				   transmitted_list);
+	list_for_each_entry_safe(chunk, tmp, &q->retransmit, transmitted_list) {
+		list_del_init(&chunk->transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
 		sctp_chunk_free(chunk);
 	}
 
 	/* Throw away any chunks that are in the abandoned queue. */
-	list_for_each_safe(lchunk, temp, &q->abandoned) {
-		list_del_init(lchunk);
-		chunk = list_entry(lchunk, struct sctp_chunk,
-				   transmitted_list);
+	list_for_each_entry_safe(chunk, tmp, &q->abandoned, transmitted_list) {
+		list_del_init(&chunk->transmitted_list);
 		sctp_chunk_fail(chunk, q->error);
 		sctp_chunk_free(chunk);
 	}
@@ -376,18 +370,16 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 			  struct sctp_transport *transport,
 			  __u8 reason)
 {
-	struct list_head *lchunk, *ltemp;
-	struct sctp_chunk *chunk;
+	struct sctp_chunk *chunk, *temp;
 
 	/* Walk through the specified transmitted queue.  */
-	list_for_each_safe(lchunk, ltemp, &transport->transmitted) {
-		chunk = list_entry(lchunk, struct sctp_chunk,
-				   transmitted_list);
-
+	list_for_each_entry_safe(chunk, temp, &transport->transmitted,
+				 transmitted_list) {
 		/* If the chunk is abandoned, move it to abandoned list. */
 		if (sctp_chunk_abandoned(chunk)) {
-			list_del_init(lchunk);
-			sctp_insert_list(&q->abandoned, lchunk);
+			list_del_init(&chunk->transmitted_list);
+			sctp_insert_list(&q->abandoned,
+					 &chunk->transmitted_list);
 
 			/* If this chunk has not been previousely acked,
 			 * stop considering it 'outstanding'.  Our peer
@@ -447,8 +439,9 @@ void sctp_retransmit_mark(struct sctp_outq *q,
 			/* Move the chunk to the retransmit queue. The chunks
 			 * on the retransmit queue are always kept in order.
 			 */
-			list_del_init(lchunk);
-			sctp_insert_list(&q->retransmit, lchunk);
+			list_del_init(&chunk->transmitted_list);
+			sctp_insert_list(&q->retransmit,
+					 &chunk->transmitted_list);
 		}
 	}
 
@@ -1125,8 +1118,8 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 	struct sctp_association *asoc = q->asoc;
 	struct sctp_sackhdr *sack = chunk->subh.sack_hdr;
 	struct sctp_transport *transport;
-	struct sctp_chunk *tchunk = NULL;
-	struct list_head *lchunk, *transport_list, *temp;
+	struct sctp_chunk *tchunk = NULL, *temp;
+	struct list_head *transport_list;
 	sctp_sack_variable_t *frags = sack->variable;
 	__u32 sack_ctsn, ctsn, tsn;
 	__u32 highest_tsn, highest_new_tsn;
@@ -1235,9 +1228,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 	ctsn = asoc->ctsn_ack_point;
 
 	/* Throw away stuff rotting on the sack queue.  */
-	list_for_each_safe(lchunk, temp, &q->sacked) {
-		tchunk = list_entry(lchunk, struct sctp_chunk,
-				    transmitted_list);
+	list_for_each_entry_safe(tchunk, temp, &q->sacked, transmitted_list) {
 		tsn = ntohl(tchunk->subh.data_hdr->tsn);
 		if (TSN_lte(tsn, ctsn)) {
 			list_del_init(&tchunk->transmitted_list);
@@ -1689,8 +1680,7 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 	int nskips = 0;
 	int skip_pos = 0;
 	__u32 tsn;
-	struct sctp_chunk *chunk;
-	struct list_head *lchunk, *temp;
+	struct sctp_chunk *chunk, *temp;
 
 	if (!asoc->peer.prsctp_capable)
 		return;
@@ -1725,16 +1715,14 @@ static void sctp_generate_fwdtsn(struct sctp_outq *q, __u32 ctsn)
 	 * In this example, the data sender successfully advanced the
 	 * "Advanced.Peer.Ack.Point" from 102 to 104 locally.
 	 */
-	list_for_each_safe(lchunk, temp, &q->abandoned) {
-		chunk = list_entry(lchunk, struct sctp_chunk,
-					transmitted_list);
+	list_for_each_entry_safe(chunk, temp, &q->abandoned, transmitted_list) {
 		tsn = ntohl(chunk->subh.data_hdr->tsn);
 
 		/* Remove any chunks in the abandoned queue that are acked by
 		 * the ctsn.
 		 */
 		if (TSN_lte(tsn, ctsn)) {
-			list_del_init(lchunk);
+			list_del_init(&chunk->transmitted_list);
 			sctp_chunk_free(chunk);
 		} else {
 			if (TSN_lte(tsn, asoc->adv_peer_ack_point+1)) {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 010aced..bd41095 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -166,13 +166,11 @@ static void sctp_v4_copy_addrlist(struct list_head *addrlist,
 static void sctp_get_local_addr_list(struct net *net)
 {
 	struct net_device *dev;
-	struct list_head *pos;
 	struct sctp_af *af;
 
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
-		list_for_each(pos, &sctp_address_families) {
-			af = list_entry(pos, struct sctp_af, list);
+		list_for_each_entry(af, &sctp_address_families, list) {
 			af->copy_addrlist(&net->sctp.local_addr_list, dev);
 		}
 	}
@@ -182,12 +180,10 @@ static void sctp_get_local_addr_list(struct net *net)
 /* Free the existing local addresses.  */
 static void sctp_free_local_addr_list(struct net *net)
 {
-	struct sctp_sockaddr_entry *addr;
-	struct list_head *pos, *temp;
+	struct sctp_sockaddr_entry *addr, *temp;
 
-	list_for_each_safe(pos, temp, &net->sctp.local_addr_list) {
-		addr = list_entry(pos, struct sctp_sockaddr_entry, list);
-		list_del(pos);
+	list_for_each_entry_safe(addr, temp, &net->sctp.local_addr_list, list) {
+		list_del(&addr->list);
 		kfree(addr);
 	}
 }
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 763e06a..819bbc4 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2293,8 +2293,7 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 {
 	struct net *net = sock_net(asoc->base.sk);
 	union sctp_params param;
-	struct sctp_transport *transport;
-	struct list_head *pos, *temp;
+	struct sctp_transport *transport, *temp;
 	struct sctp_af *af;
 	union sctp_addr addr;
 	char *cookie;
@@ -2358,8 +2357,8 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	}
 
 	/* Walk list of transports, removing transports in the UNKNOWN state. */
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry_safe(transport, temp,
+				 &asoc->peer.transport_addr_list, transports) {
 		if (transport->state == SCTP_UNKNOWN) {
 			sctp_assoc_rm_peer(asoc, transport);
 		}
@@ -2461,8 +2460,8 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 
 clean_up:
 	/* Release the transport structures. */
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		transport = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry_safe(transport, temp,
+				 &asoc->peer.transport_addr_list, transports) {
 		if (transport->state != SCTP_ACTIVE)
 			sctp_assoc_rm_peer(asoc, transport);
 	}
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 05cd164..7521e56 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -953,12 +953,10 @@ static void sctp_cmd_process_fwdtsn(struct sctp_ulpq *ulpq,
  */
 static void sctp_cmd_del_non_primary(struct sctp_association *asoc)
 {
-	struct sctp_transport *t;
-	struct list_head *pos;
-	struct list_head *temp;
+	struct sctp_transport *t, *temp;
 
-	list_for_each_safe(pos, temp, &asoc->peer.transport_addr_list) {
-		t = list_entry(pos, struct sctp_transport, transports);
+	list_for_each_entry_safe(t, temp, &asoc->peer.transport_addr_list,
+				 transports) {
 		if (!sctp_cmp_addr_exact(&t->ipaddr,
 					 &asoc->peer.primary_addr)) {
 			sctp_assoc_rm_peer(asoc, t);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 106bb09..9272e7b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1474,8 +1474,7 @@ static void sctp_close(struct sock *sk, long timeout)
 {
 	struct net *net = sock_net(sk);
 	struct sctp_endpoint *ep;
-	struct sctp_association *asoc;
-	struct list_head *pos, *temp;
+	struct sctp_association *asoc, *temp;
 	unsigned int data_was_unread;
 
 	pr_debug("%s: sk:%p, timeout:%ld\n", __func__, sk, timeout);
@@ -1491,9 +1490,7 @@ static void sctp_close(struct sock *sk, long timeout)
 	data_was_unread += sctp_queue_purge_ulpevents(&sctp_sk(sk)->pd_lobby);
 
 	/* Walk all associations on an endpoint.  */
-	list_for_each_safe(pos, temp, &ep->asocs) {
-		asoc = list_entry(pos, struct sctp_association, asocs);
-
+	list_for_each_entry_safe(asoc, temp, &ep->asocs, asocs) {
 		if (sctp_style(sk, TCP)) {
 			/* A closed association can still be in the list if
 			 * it belongs to a TCP-style listening socket that is
-- 
2.5.0
