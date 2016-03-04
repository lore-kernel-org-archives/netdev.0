From: David Howells <dhowells@redhat.com>
Subject: [PATCH 04/13] rxrpc: Keep the skb private record of the Rx header
 in host byte order
Date: Fri, 04 Mar 2016 16:37:33 +0000
Message-ID: <20160304163733.31057.23304.stgit@warthog.procyon.org.uk>
References: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-afs@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38696 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759698AbcCDQhg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 11:37:36 -0500
In-Reply-To: <20160304163705.31057.60831.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, a copy of the Rx packet header is copied into the the sk_buff
private data so that we can advance the pointer into the buffer,
potentially discarding the original.  At the moment, this copy is held in
network byte order, but this means we're doing a lot of unnecessary
translations.

The reasons it was done this way are that we need the values in network
byte order occasionally and we can use the copy, slightly modified, as part
of an iov array when sending an ack or an abort packet.

However, it seems more reasonable on review that it would be better kept in
host byte order and that we make up a new header when we want to send
another packet.

To this end, rename the original header struct to rxrpc_wire_header (with
BE fields) and institute a variant called rxrpc_host_header that has host
order fields.  Change the struct in the sk_buff private data into an
rxrpc_host_header and translate the values when filling it in.

This further allows us to keep values kept in various structures in host
byte order rather than network byte order and allows removal of some fields
that are byteswapped duplicates.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/rxrpc/packet.h    |    4 -
 net/rxrpc/af_rxrpc.c      |   20 ++-----
 net/rxrpc/ar-accept.c     |   40 ++++++++-----
 net/rxrpc/ar-ack.c        |  108 +++++++++++++++++------------------
 net/rxrpc/ar-call.c       |   68 ++++++++++------------
 net/rxrpc/ar-connection.c |   83 +++++++++++++--------------
 net/rxrpc/ar-connevent.c  |   73 ++++++++++++------------
 net/rxrpc/ar-input.c      |   95 ++++++++++++++++++-------------
 net/rxrpc/ar-internal.h   |   65 +++++++++++++--------
 net/rxrpc/ar-local.c      |   29 ++++++---
 net/rxrpc/ar-output.c     |   54 ++++++++++++------
 net/rxrpc/ar-peer.c       |    2 -
 net/rxrpc/ar-proc.c       |   10 ++-
 net/rxrpc/ar-recvmsg.c    |   18 +++---
 net/rxrpc/ar-security.c   |    4 +
 net/rxrpc/ar-skbuff.c     |    4 +
 net/rxrpc/ar-transport.c  |    1 
 net/rxrpc/rxkad.c         |  138 +++++++++++++++++++++++----------------------
 18 files changed, 432 insertions(+), 384 deletions(-)

diff --git a/include/rxrpc/packet.h b/include/rxrpc/packet.h
index 4dce116bfd80..de1e67988ada 100644
--- a/include/rxrpc/packet.h
+++ b/include/rxrpc/packet.h
@@ -22,7 +22,7 @@ typedef __be32	rxrpc_serial_net_t; /* on-the-wire Rx message serial number */
  * on-the-wire Rx packet header
  * - all multibyte fields should be in network byte order
  */
-struct rxrpc_header {
+struct rxrpc_wire_header {
 	__be32		epoch;		/* client boot timestamp */
 
 	__be32		cid;		/* connection and channel ID */
@@ -68,8 +68,6 @@ struct rxrpc_header {
 
 } __packed;
 
-#define __rxrpc_header_off(X) offsetof(struct rxrpc_header,X)
-
 extern const char *rxrpc_pkts[];
 
 /*****************************************************************************/
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 7e2d1057d8bc..7bb5cca0ae32 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -37,7 +37,7 @@ static struct proto rxrpc_proto;
 static const struct proto_ops rxrpc_rpc_ops;
 
 /* local epoch for detecting local-end reset */
-__be32 rxrpc_epoch;
+u32 rxrpc_epoch;
 
 /* current debugging ID */
 atomic_t rxrpc_debug_id;
@@ -125,7 +125,6 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 	struct sock *sk = sock->sk;
 	struct rxrpc_local *local;
 	struct rxrpc_sock *rx = rxrpc_sk(sk), *prx;
-	__be16 service_id;
 	int ret;
 
 	_enter("%p,%p,%d", rx, saddr, len);
@@ -152,14 +151,12 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	rx->local = local;
 	if (srx->srx_service) {
-		service_id = htons(srx->srx_service);
 		write_lock_bh(&local->services_lock);
 		list_for_each_entry(prx, &local->services, listen_link) {
-			if (prx->service_id == service_id)
+			if (prx->srx.srx_service == srx->srx_service)
 				goto service_in_use;
 		}
 
-		rx->service_id = service_id;
 		list_add_tail(&rx->listen_link, &local->services);
 		write_unlock_bh(&local->services_lock);
 
@@ -276,7 +273,6 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 	struct rxrpc_transport *trans;
 	struct rxrpc_call *call;
 	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
-	__be16 service_id;
 
 	_enter(",,%x,%lx", key_serial(key), user_call_ID);
 
@@ -299,16 +295,15 @@ struct rxrpc_call *rxrpc_kernel_begin_call(struct socket *sock,
 		atomic_inc(&trans->usage);
 	}
 
-	service_id = rx->service_id;
-	if (srx)
-		service_id = htons(srx->srx_service);
+	if (!srx)
+		srx = &rx->srx;
 
 	if (!key)
 		key = rx->key;
 	if (key && !key->payload.data[0])
 		key = NULL; /* a no-security key */
 
-	bundle = rxrpc_get_bundle(rx, trans, key, service_id, gfp);
+	bundle = rxrpc_get_bundle(rx, trans, key, srx->srx_service, gfp);
 	if (IS_ERR(bundle)) {
 		call = ERR_CAST(bundle);
 		goto out;
@@ -425,7 +420,6 @@ static int rxrpc_connect(struct socket *sock, struct sockaddr *addr,
 	}
 
 	rx->trans = trans;
-	rx->service_id = htons(srx->srx_service);
 	rx->sk.sk_state = RXRPC_CLIENT_CONNECTED;
 
 	release_sock(&rx->sk);
@@ -778,7 +772,7 @@ static struct proto rxrpc_proto = {
 	.name		= "RXRPC",
 	.owner		= THIS_MODULE,
 	.obj_size	= sizeof(struct rxrpc_sock),
-	.max_header	= sizeof(struct rxrpc_header),
+	.max_header	= sizeof(struct rxrpc_wire_header),
 };
 
 static const struct net_proto_family rxrpc_family_ops = {
@@ -796,7 +790,7 @@ static int __init af_rxrpc_init(void)
 
 	BUILD_BUG_ON(sizeof(struct rxrpc_skb_priv) > FIELD_SIZEOF(struct sk_buff, cb));
 
-	rxrpc_epoch = htonl(get_seconds());
+	rxrpc_epoch = get_seconds();
 
 	ret = -ENOMEM;
 	rxrpc_call_jar = kmem_cache_create(
diff --git a/net/rxrpc/ar-accept.c b/net/rxrpc/ar-accept.c
index 9a49f32e9e1e..73c905416271 100644
--- a/net/rxrpc/ar-accept.c
+++ b/net/rxrpc/ar-accept.c
@@ -27,7 +27,7 @@
  * generate a connection-level abort
  */
 static int rxrpc_busy(struct rxrpc_local *local, struct sockaddr_rxrpc *srx,
-		      struct rxrpc_header *hdr)
+		      struct rxrpc_wire_header *whdr)
 {
 	struct msghdr msg;
 	struct kvec iov[1];
@@ -36,25 +36,21 @@ static int rxrpc_busy(struct rxrpc_local *local, struct sockaddr_rxrpc *srx,
 
 	_enter("%d,,", local->debug_id);
 
+	whdr->type	= RXRPC_PACKET_TYPE_BUSY;
+	whdr->serial	= htonl(1);
+
 	msg.msg_name	= &srx->transport.sin;
 	msg.msg_namelen	= sizeof(srx->transport.sin);
 	msg.msg_control	= NULL;
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr->seq	= 0;
-	hdr->type	= RXRPC_PACKET_TYPE_BUSY;
-	hdr->flags	= 0;
-	hdr->userStatus	= 0;
-	hdr->_rsvd	= 0;
-
-	iov[0].iov_base	= hdr;
-	iov[0].iov_len	= sizeof(*hdr);
+	iov[0].iov_base	= whdr;
+	iov[0].iov_len	= sizeof(*whdr);
 
 	len = iov[0].iov_len;
 
-	hdr->serial = htonl(1);
-	_proto("Tx BUSY %%%u", ntohl(hdr->serial));
+	_proto("Tx BUSY %%1");
 
 	ret = kernel_sendmsg(local->socket, &msg, iov, 1, len);
 	if (ret < 0) {
@@ -211,8 +207,8 @@ void rxrpc_accept_incoming_calls(struct work_struct *work)
 	struct rxrpc_skb_priv *sp;
 	struct sockaddr_rxrpc srx;
 	struct rxrpc_sock *rx;
+	struct rxrpc_wire_header whdr;
 	struct sk_buff *skb;
-	__be16 service_id;
 	int ret;
 
 	_enter("%d", local->debug_id);
@@ -240,6 +236,19 @@ process_next_packet:
 
 	sp = rxrpc_skb(skb);
 
+	/* Set up a response packet header in case we need it */
+	whdr.epoch	= htonl(sp->hdr.epoch);
+	whdr.cid	= htonl(sp->hdr.cid);
+	whdr.callNumber	= htonl(sp->hdr.callNumber);
+	whdr.seq	= htonl(sp->hdr.seq);
+	whdr.serial	= 0;
+	whdr.flags	= 0;
+	whdr.type	= 0;
+	whdr.userStatus	= 0;
+	whdr.securityIndex = sp->hdr.securityIndex;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(sp->hdr.serviceId);
+
 	/* determine the remote address */
 	memset(&srx, 0, sizeof(srx));
 	srx.srx_family = AF_RXRPC;
@@ -256,10 +265,9 @@ process_next_packet:
 	}
 
 	/* get the socket providing the service */
-	service_id = sp->hdr.serviceId;
 	read_lock_bh(&local->services_lock);
 	list_for_each_entry(rx, &local->services, listen_link) {
-		if (rx->service_id == service_id &&
+		if (rx->srx.srx_service == sp->hdr.serviceId &&
 		    rx->sk.sk_state != RXRPC_CLOSE)
 			goto found_service;
 	}
@@ -267,7 +275,7 @@ process_next_packet:
 	goto invalid_service;
 
 found_service:
-	_debug("found service %hd", ntohs(rx->service_id));
+	_debug("found service %hd", rx->srx.srx_service);
 	if (sk_acceptq_is_full(&rx->sk))
 		goto backlog_full;
 	sk_acceptq_added(&rx->sk);
@@ -296,7 +304,7 @@ found_service:
 backlog_full:
 	read_unlock_bh(&local->services_lock);
 busy:
-	rxrpc_busy(local, &srx, &sp->hdr);
+	rxrpc_busy(local, &srx, &whdr);
 	rxrpc_free_skb(skb);
 	goto process_next_packet;
 
diff --git a/net/rxrpc/ar-ack.c b/net/rxrpc/ar-ack.c
index 9183da740600..20f3f001694e 100644
--- a/net/rxrpc/ar-ack.c
+++ b/net/rxrpc/ar-ack.c
@@ -91,7 +91,7 @@ static const s8 rxrpc_ack_priority[] = {
  * propose an ACK be sent
  */
 void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-			 __be32 serial, bool immediate)
+			 u32 serial, bool immediate)
 {
 	unsigned long expiry;
 	s8 prior = rxrpc_ack_priority[ack_reason];
@@ -99,8 +99,7 @@ void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 	ASSERTCMP(prior, >, 0);
 
 	_enter("{%d},%s,%%%x,%u",
-	       call->debug_id, rxrpc_acks(ack_reason), ntohl(serial),
-	       immediate);
+	       call->debug_id, rxrpc_acks(ack_reason), serial, immediate);
 
 	if (prior < rxrpc_ack_priority[call->ackr_reason]) {
 		if (immediate)
@@ -139,7 +138,7 @@ void __rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
 		expiry = rxrpc_requested_ack_delay;
 		if (!expiry)
 			goto cancel_timer;
-		if (!immediate || serial == cpu_to_be32(1)) {
+		if (!immediate || serial == 1) {
 			_debug("run defer timer");
 			goto run_timer;
 		}
@@ -157,7 +156,7 @@ run_timer:
 	return;
 
 cancel_timer:
-	_debug("cancel timer %%%u", ntohl(serial));
+	_debug("cancel timer %%%u", serial);
 	try_to_del_timer_sync(&call->ack_timer);
 	read_lock_bh(&call->state_lock);
 	if (call->state <= RXRPC_CALL_COMPLETE &&
@@ -170,7 +169,7 @@ cancel_timer:
  * propose an ACK be sent, locking the call structure
  */
 void rxrpc_propose_ACK(struct rxrpc_call *call, u8 ack_reason,
-		       __be32 serial, bool immediate)
+		       u32 serial, bool immediate)
 {
 	s8 prior = rxrpc_ack_priority[ack_reason];
 
@@ -214,8 +213,8 @@ static void rxrpc_set_resend(struct rxrpc_call *call, u8 resend,
  */
 static void rxrpc_resend(struct rxrpc_call *call)
 {
+	struct rxrpc_wire_header *whdr;
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_header *hdr;
 	struct sk_buff *txb;
 	unsigned long *p_txb, resend_at;
 	bool stop;
@@ -247,14 +246,13 @@ static void rxrpc_resend(struct rxrpc_call *call)
 			sp->need_resend = false;
 
 			/* each Tx packet has a new serial number */
-			sp->hdr.serial =
-				htonl(atomic_inc_return(&call->conn->serial));
+			sp->hdr.serial = atomic_inc_return(&call->conn->serial);
 
-			hdr = (struct rxrpc_header *) txb->head;
-			hdr->serial = sp->hdr.serial;
+			whdr = (struct rxrpc_wire_header *)txb->head;
+			whdr->serial = htonl(sp->hdr.serial);
 
 			_proto("Tx DATA %%%u { #%d }",
-			       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+			       sp->hdr.serial, sp->hdr.seq);
 			if (rxrpc_send_packet(call->conn->trans, txb) < 0) {
 				stop = true;
 				sp->resend_at = jiffies + 3;
@@ -428,7 +426,7 @@ static void rxrpc_rotate_tx_window(struct rxrpc_call *call, u32 hard)
 	int tail = call->acks_tail, old_tail;
 	int win = CIRC_CNT(call->acks_head, tail, call->acks_winsz);
 
-	_enter("{%u,%u},%u", call->acks_hard, win, hard);
+	kenter("{%u,%u},%u", call->acks_hard, win, hard);
 
 	ASSERTCMP(hard - call->acks_hard, <=, win);
 
@@ -478,11 +476,11 @@ static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
 		sp = rxrpc_skb(skb);
 
 		_debug("drain OOS packet %d [%d]",
-		       ntohl(sp->hdr.seq), call->rx_first_oos);
+		       sp->hdr.seq, call->rx_first_oos);
 
-		if (ntohl(sp->hdr.seq) != call->rx_first_oos) {
+		if (sp->hdr.seq != call->rx_first_oos) {
 			skb_queue_head(&call->rx_oos_queue, skb);
-			call->rx_first_oos = ntohl(rxrpc_skb(skb)->hdr.seq);
+			call->rx_first_oos = rxrpc_skb(skb)->hdr.seq;
 			_debug("requeue %p {%u}", skb, call->rx_first_oos);
 		} else {
 			skb->mark = RXRPC_SKB_MARK_DATA;
@@ -496,8 +494,7 @@ static int rxrpc_drain_rx_oos_queue(struct rxrpc_call *call)
 			/* find out what the next packet is */
 			skb = skb_peek(&call->rx_oos_queue);
 			if (skb)
-				call->rx_first_oos =
-					ntohl(rxrpc_skb(skb)->hdr.seq);
+				call->rx_first_oos = rxrpc_skb(skb)->hdr.seq;
 			else
 				call->rx_first_oos = 0;
 			_debug("peek %p {%u}", skb, call->rx_first_oos);
@@ -522,7 +519,7 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 	u32 seq;
 
 	sp = rxrpc_skb(skb);
-	seq = ntohl(sp->hdr.seq);
+	seq = sp->hdr.seq;
 	_enter(",,{%u}", seq);
 
 	skb->destructor = rxrpc_packet_destructor;
@@ -535,9 +532,8 @@ static void rxrpc_insert_oos_packet(struct rxrpc_call *call,
 
 	skb_queue_walk(&call->rx_oos_queue, p) {
 		psp = rxrpc_skb(p);
-		if (ntohl(psp->hdr.seq) > seq) {
-			_debug("insert oos #%u before #%u",
-			       seq, ntohl(psp->hdr.seq));
+		if (psp->hdr.seq > seq) {
+			_debug("insert oos #%u before #%u", seq, psp->hdr.seq);
 			skb_insert(p, skb, &call->rx_oos_queue);
 			goto inserted;
 		}
@@ -586,7 +582,7 @@ static void rxrpc_zap_tx_window(struct rxrpc_call *call)
 
 		skb = (struct sk_buff *) _skb;
 		sp = rxrpc_skb(skb);
-		_debug("+++ clear Tx %u", ntohl(sp->hdr.seq));
+		_debug("+++ clear Tx %u", sp->hdr.seq);
 		rxrpc_free_skb(skb);
 	}
 
@@ -657,8 +653,7 @@ process_further:
 		/* data packets that wind up here have been received out of
 		 * order, need security processing or are jumbo packets */
 	case RXRPC_PACKET_TYPE_DATA:
-		_proto("OOSQ DATA %%%u { #%u }",
-		       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+		_proto("OOSQ DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
 
 		/* secured packets must be verified and possibly decrypted */
 		if (rxrpc_verify_packet(call, skb, _abort_code) < 0)
@@ -676,7 +671,7 @@ process_further:
 		if (!skb_pull(skb, sizeof(ack)))
 			BUG();
 
-		latest = ntohl(sp->hdr.serial);
+		latest = sp->hdr.serial;
 		hard = ntohl(ack.firstPacket);
 		tx = atomic_read(&call->sequence);
 
@@ -881,9 +876,9 @@ void rxrpc_process_call(struct work_struct *work)
 {
 	struct rxrpc_call *call =
 		container_of(work, struct rxrpc_call, processor);
+	struct rxrpc_wire_header whdr;
 	struct rxrpc_ackpacket ack;
 	struct rxrpc_ackinfo ackinfo;
-	struct rxrpc_header hdr;
 	struct msghdr msg;
 	struct kvec iov[5];
 	enum rxrpc_call_event genbit;
@@ -891,7 +886,7 @@ void rxrpc_process_call(struct work_struct *work)
 	__be32 data, pad;
 	size_t len;
 	int loop, nbit, ioc, ret, mtu;
-	u32 abort_code = RX_PROTOCOL_ERROR;
+	u32 serial, abort_code = RX_PROTOCOL_ERROR;
 	u8 *acks = NULL;
 
 	//printk("\n--------------------\n");
@@ -912,20 +907,20 @@ void rxrpc_process_call(struct work_struct *work)
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr.epoch	= call->conn->epoch;
-	hdr.cid		= call->cid;
-	hdr.callNumber	= call->call_id;
-	hdr.seq		= 0;
-	hdr.type	= RXRPC_PACKET_TYPE_ACK;
-	hdr.flags	= call->conn->out_clientflag;
-	hdr.userStatus	= 0;
-	hdr.securityIndex = call->conn->security_ix;
-	hdr._rsvd	= 0;
-	hdr.serviceId	= call->conn->service_id;
+	whdr.epoch	= htonl(call->conn->epoch);
+	whdr.cid	= htonl(call->cid);
+	whdr.callNumber	= htonl(call->call_id);
+	whdr.seq	= 0;
+	whdr.type	= RXRPC_PACKET_TYPE_ACK;
+	whdr.flags	= call->conn->out_clientflag;
+	whdr.userStatus	= 0;
+	whdr.securityIndex = call->conn->security_ix;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(call->service_id);
 
 	memset(iov, 0, sizeof(iov));
-	iov[0].iov_base	= &hdr;
-	iov[0].iov_len	= sizeof(hdr);
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
 
 	/* deal with events of a final nature */
 	if (test_bit(RXRPC_CALL_EV_RELEASE, &call->events)) {
@@ -966,7 +961,7 @@ void rxrpc_process_call(struct work_struct *work)
 	}
 
 	if (test_bit(RXRPC_CALL_EV_REJECT_BUSY, &call->events)) {
-		hdr.type = RXRPC_PACKET_TYPE_BUSY;
+		whdr.type = RXRPC_PACKET_TYPE_BUSY;
 		genbit = RXRPC_CALL_EV_REJECT_BUSY;
 		goto send_message;
 	}
@@ -977,7 +972,7 @@ void rxrpc_process_call(struct work_struct *work)
 		if (rxrpc_post_message(call, RXRPC_SKB_MARK_LOCAL_ERROR,
 				       ECONNABORTED, true) < 0)
 			goto no_mem;
-		hdr.type = RXRPC_PACKET_TYPE_ABORT;
+		whdr.type = RXRPC_PACKET_TYPE_ABORT;
 		data = htonl(call->abort_code);
 		iov[1].iov_base = &data;
 		iov[1].iov_len = sizeof(data);
@@ -996,9 +991,9 @@ void rxrpc_process_call(struct work_struct *work)
 		call->ackr_reason = 0;
 
 		spin_lock_bh(&call->lock);
-		ack.serial = call->ackr_serial;
-		ack.previousPacket = call->ackr_prev_seq;
-		ack.firstPacket = htonl(call->rx_data_eaten + 1);
+		ack.serial	= htonl(call->ackr_serial);
+		ack.previousPacket = htonl(call->ackr_prev_seq);
+		ack.firstPacket	= htonl(call->rx_data_eaten + 1);
 		spin_unlock_bh(&call->lock);
 
 		pad = 0;
@@ -1100,13 +1095,11 @@ void rxrpc_process_call(struct work_struct *work)
 		//hdr.flags	= RXRPC_SLOW_START_OK;
 		ack.bufferSpace	= htons(8);
 		ack.maxSkew	= 0;
-		ack.serial	= 0;
-		ack.reason	= 0;
 
 		spin_lock_bh(&call->lock);
-		ack.reason = call->ackr_reason;
-		ack.serial = call->ackr_serial;
-		ack.previousPacket = call->ackr_prev_seq;
+		ack.reason	= call->ackr_reason;
+		ack.serial	= htonl(call->ackr_serial);
+		ack.previousPacket = htonl(call->ackr_prev_seq);
 		ack.firstPacket = htonl(call->rx_data_eaten + 1);
 
 		ack.nAcks = 0;
@@ -1225,9 +1218,10 @@ send_ACK:
 	ackinfo.rxMTU	= htonl(rxrpc_rx_mtu);
 	ackinfo.jumbo_max = htonl(rxrpc_rx_jumbo_max);
 
-	hdr.serial = htonl(atomic_inc_return(&call->conn->serial));
+	serial = atomic_inc_return(&call->conn->serial);
+	whdr.serial = htonl(serial);
 	_proto("Tx ACK %%%u { m=%hu f=#%u p=#%u s=%%%u r=%s n=%u }",
-	       ntohl(hdr.serial),
+	       serial,
 	       ntohs(ack.maxSkew),
 	       ntohl(ack.firstPacket),
 	       ntohl(ack.previousPacket),
@@ -1243,8 +1237,9 @@ send_ACK:
 send_message:
 	_debug("send message");
 
-	hdr.serial = htonl(atomic_inc_return(&call->conn->serial));
-	_proto("Tx %s %%%u", rxrpc_pkts[hdr.type], ntohl(hdr.serial));
+	serial = atomic_inc_return(&call->conn->serial);
+	whdr.serial = htonl(serial);
+	_proto("Tx %s %%%u", rxrpc_pkts[whdr.type], serial);
 send_message_2:
 
 	len = iov[0].iov_len;
@@ -1327,8 +1322,7 @@ maybe_reschedule:
 	if (call->state >= RXRPC_CALL_COMPLETE &&
 	    !list_empty(&call->accept_link)) {
 		_debug("X unlinking once-pending call %p { e=%lx f=%lx c=%x }",
-		       call, call->events, call->flags,
-		       ntohl(call->conn->cid));
+		       call, call->events, call->flags, call->conn->cid);
 
 		read_lock_bh(&call->state_lock);
 		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
@@ -1346,7 +1340,7 @@ error:
 	 * this means there's a race between clearing the flag and setting the
 	 * work pending bit and the work item being processed again */
 	if (call->events && !work_pending(&call->processor)) {
-		_debug("jumpstart %x", ntohl(call->conn->cid));
+		_debug("jumpstart %x", call->conn->cid);
 		rxrpc_queue_call(call);
 	}
 
diff --git a/net/rxrpc/ar-call.c b/net/rxrpc/ar-call.c
index 3468a0705ab7..4a499e0100f1 100644
--- a/net/rxrpc/ar-call.c
+++ b/net/rxrpc/ar-call.c
@@ -64,11 +64,11 @@ static DEFINE_HASHTABLE(rxrpc_call_hash, 10);
  * Hash function for rxrpc_call_hash
  */
 static unsigned long rxrpc_call_hashfunc(
-	u8		clientflag,
-	__be32		cid,
-	__be32		call_id,
-	__be32		epoch,
-	__be16		service_id,
+	u8		in_clientflag,
+	u32		cid,
+	u32		call_id,
+	u32		epoch,
+	u16		service_id,
 	sa_family_t	proto,
 	void		*localptr,
 	unsigned int	addr_size,
@@ -77,7 +77,6 @@ static unsigned long rxrpc_call_hashfunc(
 	const u16 *p;
 	unsigned int i;
 	unsigned long key;
-	u32 hcid = ntohl(cid);
 
 	_enter("");
 
@@ -85,12 +84,12 @@ static unsigned long rxrpc_call_hashfunc(
 	/* We just want to add up the __be32 values, so forcing the
 	 * cast should be okay.
 	 */
-	key += (__force u32)epoch;
-	key += (__force u16)service_id;
-	key += (__force u32)call_id;
-	key += (hcid & RXRPC_CIDMASK) >> RXRPC_CIDSHIFT;
-	key += hcid & RXRPC_CHANNELMASK;
-	key += clientflag;
+	key += epoch;
+	key += service_id;
+	key += call_id;
+	key += (cid & RXRPC_CIDMASK) >> RXRPC_CIDSHIFT;
+	key += cid & RXRPC_CHANNELMASK;
+	key += in_clientflag;
 	key += proto;
 	/* Step through the peer address in 16-bit portions for speed */
 	for (i = 0, p = (const u16 *)peer_addr; i < addr_size >> 1; i++, p++)
@@ -148,19 +147,16 @@ static void rxrpc_call_hash_del(struct rxrpc_call *call)
  * isn't there.
  */
 struct rxrpc_call *rxrpc_find_call_hash(
-	u8		clientflag,
-	__be32		cid,
-	__be32		call_id,
-	__be32		epoch,
-	__be16		service_id,
+	struct rxrpc_host_header *hdr,
 	void		*localptr,
 	sa_family_t	proto,
-	const u8	*peer_addr)
+	const void	*peer_addr)
 {
 	unsigned long key;
 	unsigned int addr_size = 0;
 	struct rxrpc_call *call = NULL;
 	struct rxrpc_call *ret = NULL;
+	u8 in_clientflag = hdr->flags & RXRPC_CLIENT_INITIATED;
 
 	_enter("");
 	switch (proto) {
@@ -174,20 +170,21 @@ struct rxrpc_call *rxrpc_find_call_hash(
 		break;
 	}
 
-	key = rxrpc_call_hashfunc(clientflag, cid, call_id, epoch,
-				  service_id, proto, localptr, addr_size,
+	key = rxrpc_call_hashfunc(in_clientflag, hdr->cid, hdr->callNumber,
+				  hdr->epoch, hdr->serviceId,
+				  proto, localptr, addr_size,
 				  peer_addr);
 	hash_for_each_possible_rcu(rxrpc_call_hash, call, hash_node, key) {
 		if (call->hash_key == key &&
-		    call->call_id == call_id &&
-		    call->cid == cid &&
-		    call->in_clientflag == clientflag &&
-		    call->service_id == service_id &&
+		    call->call_id == hdr->callNumber &&
+		    call->cid == hdr->cid &&
+		    call->in_clientflag == in_clientflag &&
+		    call->service_id == hdr->serviceId &&
 		    call->proto == proto &&
 		    call->local == localptr &&
 		    memcmp(call->peer_ip.ipv6_addr, peer_addr,
-			      addr_size) == 0 &&
-		    call->epoch == epoch) {
+			   addr_size) == 0 &&
+		    call->epoch == hdr->epoch) {
 			ret = call;
 			break;
 		}
@@ -414,12 +411,12 @@ found_extant_second:
  */
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 				       struct rxrpc_connection *conn,
-				       struct rxrpc_header *hdr,
+				       struct rxrpc_host_header *hdr,
 				       gfp_t gfp)
 {
 	struct rxrpc_call *call, *candidate;
 	struct rb_node **p, *parent;
-	__be32 call_id;
+	u32 call_id;
 
 	_enter(",%d,,%x", conn->debug_id, gfp);
 
@@ -433,7 +430,7 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 	candidate->conn = conn;
 	candidate->cid = hdr->cid;
 	candidate->call_id = hdr->callNumber;
-	candidate->channel = ntohl(hdr->cid) & RXRPC_CHANNELMASK;
+	candidate->channel = hdr->cid & RXRPC_CHANNELMASK;
 	candidate->rx_data_post = 0;
 	candidate->state = RXRPC_CALL_SERVER_ACCEPTING;
 	if (conn->security_ix > 0)
@@ -492,9 +489,9 @@ struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *rx,
 		/* The tree is sorted in order of the __be32 value without
 		 * turning it into host order.
 		 */
-		if ((__force u32)call_id < (__force u32)call->call_id)
+		if (call_id < call->call_id)
 			p = &(*p)->rb_left;
-		else if ((__force u32)call_id > (__force u32)call->call_id)
+		else if (call_id > call->call_id)
 			p = &(*p)->rb_right;
 		else
 			goto old_call;
@@ -714,8 +711,7 @@ void rxrpc_release_call(struct rxrpc_call *call)
 
 			_debug("- zap %s %%%u #%u",
 			       rxrpc_pkts[sp->hdr.type],
-			       ntohl(sp->hdr.serial),
-			       ntohl(sp->hdr.seq));
+			       sp->hdr.serial, sp->hdr.seq);
 			rxrpc_free_skb(skb);
 			spin_lock_bh(&call->lock);
 		}
@@ -873,9 +869,9 @@ static void rxrpc_cleanup_call(struct rxrpc_call *call)
 			unsigned long _skb;
 
 			_skb = call->acks_window[call->acks_tail] & ~1;
-			sp = rxrpc_skb((struct sk_buff *) _skb);
-			_debug("+++ clear Tx %u", ntohl(sp->hdr.seq));
-			rxrpc_free_skb((struct sk_buff *) _skb);
+			sp = rxrpc_skb((struct sk_buff *)_skb);
+			_debug("+++ clear Tx %u", sp->hdr.seq);
+			rxrpc_free_skb((struct sk_buff *)_skb);
 			call->acks_tail =
 				(call->acks_tail + 1) & (call->acks_winsz - 1);
 		}
diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 6c71ed1caf16..53df14cb8d25 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -57,10 +57,10 @@ static struct rxrpc_conn_bundle *rxrpc_alloc_bundle(gfp_t gfp)
  */
 static inline
 int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
-		     struct key *key, __be16 service_id)
+		     struct key *key, u16 service_id)
 {
 	return (bundle->service_id - service_id) ?:
-		((unsigned long) bundle->key - (unsigned long) key);
+		((unsigned long)bundle->key - (unsigned long)key);
 }
 
 /*
@@ -69,14 +69,14 @@ int rxrpc_cmp_bundle(const struct rxrpc_conn_bundle *bundle,
 struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *rx,
 					   struct rxrpc_transport *trans,
 					   struct key *key,
-					   __be16 service_id,
+					   u16 service_id,
 					   gfp_t gfp)
 {
 	struct rxrpc_conn_bundle *bundle, *candidate;
 	struct rb_node *p, *parent, **pp;
 
 	_enter("%p{%x},%x,%hx,",
-	       rx, key_serial(key), trans->debug_id, ntohs(service_id));
+	       rx, key_serial(key), trans->debug_id, service_id);
 
 	if (rx->trans == trans && rx->bundle) {
 		atomic_inc(&rx->bundle->usage);
@@ -213,7 +213,7 @@ static struct rxrpc_connection *rxrpc_alloc_connection(gfp_t gfp)
 		conn->debug_id = atomic_inc_return(&rxrpc_debug_id);
 		conn->avail_calls = RXRPC_MAXCALLS;
 		conn->size_align = 4;
-		conn->header_size = sizeof(struct rxrpc_header);
+		conn->header_size = sizeof(struct rxrpc_wire_header);
 	}
 
 	_leave(" = %p{%d}", conn, conn ? conn->debug_id : 0);
@@ -230,7 +230,7 @@ static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
 	struct rxrpc_connection *xconn;
 	struct rb_node *parent, **p;
 	__be32 epoch;
-	u32 real_conn_id;
+	u32 cid;
 
 	_enter("");
 
@@ -241,7 +241,7 @@ static void rxrpc_assign_connection_id(struct rxrpc_connection *conn)
 	conn->trans->conn_idcounter += RXRPC_CID_INC;
 	if (conn->trans->conn_idcounter < RXRPC_CID_INC)
 		conn->trans->conn_idcounter = RXRPC_CID_INC;
-	real_conn_id = conn->trans->conn_idcounter;
+	cid = conn->trans->conn_idcounter;
 
 attempt_insertion:
 	parent = NULL;
@@ -255,9 +255,9 @@ attempt_insertion:
 			p = &(*p)->rb_left;
 		else if (epoch > xconn->epoch)
 			p = &(*p)->rb_right;
-		else if (real_conn_id < xconn->real_conn_id)
+		else if (cid < xconn->cid)
 			p = &(*p)->rb_left;
-		else if (real_conn_id > xconn->real_conn_id)
+		else if (cid > xconn->cid)
 			p = &(*p)->rb_right;
 		else
 			goto id_exists;
@@ -268,20 +268,19 @@ attempt_insertion:
 	rb_link_node(&conn->node, parent, p);
 	rb_insert_color(&conn->node, &conn->trans->client_conns);
 
-	conn->real_conn_id = real_conn_id;
-	conn->cid = htonl(real_conn_id);
+	conn->cid = cid;
 	write_unlock_bh(&conn->trans->conn_lock);
-	_leave(" [CONNID %x CID %x]", real_conn_id, ntohl(conn->cid));
+	_leave(" [CID %x]", cid);
 	return;
 
 	/* we found a connection with the proposed ID - walk the tree from that
 	 * point looking for the next unused ID */
 id_exists:
 	for (;;) {
-		real_conn_id += RXRPC_CID_INC;
-		if (real_conn_id < RXRPC_CID_INC) {
-			real_conn_id = RXRPC_CID_INC;
-			conn->trans->conn_idcounter = real_conn_id;
+		cid += RXRPC_CID_INC;
+		if (cid < RXRPC_CID_INC) {
+			cid = RXRPC_CID_INC;
+			conn->trans->conn_idcounter = cid;
 			goto attempt_insertion;
 		}
 
@@ -291,7 +290,7 @@ id_exists:
 
 		xconn = rb_entry(parent, struct rxrpc_connection, node);
 		if (epoch < xconn->epoch ||
-		    real_conn_id < xconn->real_conn_id)
+		    cid < xconn->cid)
 			goto attempt_insertion;
 	}
 }
@@ -334,7 +333,7 @@ static void rxrpc_add_call_ID_to_conn(struct rxrpc_connection *conn,
  */
 static int rxrpc_connect_exclusive(struct rxrpc_sock *rx,
 				   struct rxrpc_transport *trans,
-				   __be16 service_id,
+				   u16 service_id,
 				   struct rxrpc_call *call,
 				   gfp_t gfp)
 {
@@ -404,11 +403,11 @@ found_channel:
 	conn->channels[chan] = call;
 	call->conn = conn;
 	call->channel = chan;
-	call->cid = conn->cid | htonl(chan);
-	call->call_id = htonl(++conn->call_counter);
+	call->cid = conn->cid | chan;
+	call->call_id = ++conn->call_counter;
 
 	_net("CONNECT client on conn %d chan %d as call %x",
-	     conn->debug_id, chan, ntohl(call->call_id));
+	     conn->debug_id, chan, call->call_id);
 
 	spin_unlock(&trans->client_lock);
 
@@ -593,11 +592,11 @@ found_channel:
 	conn->channels[chan] = call;
 	call->conn = conn;
 	call->channel = chan;
-	call->cid = conn->cid | htonl(chan);
-	call->call_id = htonl(++conn->call_counter);
+	call->cid = conn->cid | chan;
+	call->call_id = ++conn->call_counter;
 
 	_net("CONNECT client on conn %d chan %d as call %x",
-	     conn->debug_id, chan, ntohl(call->call_id));
+	     conn->debug_id, chan, call->call_id);
 
 	ASSERTCMP(conn->avail_calls, <, RXRPC_MAXCALLS);
 	spin_unlock(&trans->client_lock);
@@ -620,21 +619,21 @@ interrupted:
  */
 struct rxrpc_connection *
 rxrpc_incoming_connection(struct rxrpc_transport *trans,
-			  struct rxrpc_header *hdr,
+			  struct rxrpc_host_header *hdr,
 			  gfp_t gfp)
 {
 	struct rxrpc_connection *conn, *candidate = NULL;
 	struct rb_node *p, **pp;
 	const char *new = "old";
 	__be32 epoch;
-	u32 conn_id;
+	u32 cid;
 
 	_enter("");
 
 	ASSERT(hdr->flags & RXRPC_CLIENT_INITIATED);
 
 	epoch = hdr->epoch;
-	conn_id = ntohl(hdr->cid) & RXRPC_CIDMASK;
+	cid = hdr->cid & RXRPC_CIDMASK;
 
 	/* search the connection list first */
 	read_lock_bh(&trans->conn_lock);
@@ -643,15 +642,15 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 	while (p) {
 		conn = rb_entry(p, struct rxrpc_connection, node);
 
-		_debug("maybe %x", conn->real_conn_id);
+		_debug("maybe %x", conn->cid);
 
 		if (epoch < conn->epoch)
 			p = p->rb_left;
 		else if (epoch > conn->epoch)
 			p = p->rb_right;
-		else if (conn_id < conn->real_conn_id)
+		else if (cid < conn->cid)
 			p = p->rb_left;
-		else if (conn_id > conn->real_conn_id)
+		else if (cid > conn->cid)
 			p = p->rb_right;
 		else
 			goto found_extant_connection;
@@ -668,12 +667,11 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 
 	candidate->trans = trans;
 	candidate->epoch = hdr->epoch;
-	candidate->cid = hdr->cid & cpu_to_be32(RXRPC_CIDMASK);
+	candidate->cid = hdr->cid & RXRPC_CIDMASK;
 	candidate->service_id = hdr->serviceId;
 	candidate->security_ix = hdr->securityIndex;
 	candidate->in_clientflag = RXRPC_CLIENT_INITIATED;
 	candidate->out_clientflag = 0;
-	candidate->real_conn_id = conn_id;
 	candidate->state = RXRPC_CONN_SERVER;
 	if (candidate->service_id)
 		candidate->state = RXRPC_CONN_SERVER_UNSECURED;
@@ -690,9 +688,9 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 			pp = &(*pp)->rb_left;
 		else if (epoch > conn->epoch)
 			pp = &(*pp)->rb_right;
-		else if (conn_id < conn->real_conn_id)
+		else if (cid < conn->cid)
 			pp = &(*pp)->rb_left;
-		else if (conn_id > conn->real_conn_id)
+		else if (cid > conn->cid)
 			pp = &(*pp)->rb_right;
 		else
 			goto found_extant_second;
@@ -714,7 +712,7 @@ rxrpc_incoming_connection(struct rxrpc_transport *trans,
 	new = "new";
 
 success:
-	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->real_conn_id);
+	_net("CONNECTION %s %d {%x}", new, conn->debug_id, conn->cid);
 
 	_leave(" = %p {u=%d}", conn, atomic_read(&conn->usage));
 	return conn;
@@ -751,18 +749,17 @@ security_mismatch:
  * packet
  */
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
-					       struct rxrpc_header *hdr)
+					       struct rxrpc_host_header *hdr)
 {
 	struct rxrpc_connection *conn;
 	struct rb_node *p;
-	__be32 epoch;
-	u32 conn_id;
+	u32 epoch, cid;
 
-	_enter(",{%x,%x}", ntohl(hdr->cid), hdr->flags);
+	_enter(",{%x,%x}", hdr->cid, hdr->flags);
 
 	read_lock_bh(&trans->conn_lock);
 
-	conn_id = ntohl(hdr->cid) & RXRPC_CIDMASK;
+	cid = hdr->cid & RXRPC_CIDMASK;
 	epoch = hdr->epoch;
 
 	if (hdr->flags & RXRPC_CLIENT_INITIATED)
@@ -773,15 +770,15 @@ struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *trans,
 	while (p) {
 		conn = rb_entry(p, struct rxrpc_connection, node);
 
-		_debug("maybe %x", conn->real_conn_id);
+		_debug("maybe %x", conn->cid);
 
 		if (epoch < conn->epoch)
 			p = p->rb_left;
 		else if (epoch > conn->epoch)
 			p = p->rb_right;
-		else if (conn_id < conn->real_conn_id)
+		else if (cid < conn->cid)
 			p = p->rb_left;
-		else if (conn_id > conn->real_conn_id)
+		else if (cid > conn->cid)
 			p = p->rb_right;
 		else
 			goto found;
diff --git a/net/rxrpc/ar-connevent.c b/net/rxrpc/ar-connevent.c
index 45e81b7e96ae..1bdaaed8cdc4 100644
--- a/net/rxrpc/ar-connevent.c
+++ b/net/rxrpc/ar-connevent.c
@@ -60,11 +60,12 @@ static void rxrpc_abort_calls(struct rxrpc_connection *conn, int state,
 static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 				  u32 error, u32 abort_code)
 {
-	struct rxrpc_header hdr;
+	struct rxrpc_wire_header whdr;
 	struct msghdr msg;
 	struct kvec iov[2];
 	__be32 word;
 	size_t len;
+	u32 serial;
 	int ret;
 
 	_enter("%d,,%u,%u", conn->debug_id, error, abort_code);
@@ -89,28 +90,29 @@ static int rxrpc_abort_connection(struct rxrpc_connection *conn,
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr.epoch	= conn->epoch;
-	hdr.cid		= conn->cid;
-	hdr.callNumber	= 0;
-	hdr.seq		= 0;
-	hdr.type	= RXRPC_PACKET_TYPE_ABORT;
-	hdr.flags	= conn->out_clientflag;
-	hdr.userStatus	= 0;
-	hdr.securityIndex = conn->security_ix;
-	hdr._rsvd	= 0;
-	hdr.serviceId	= conn->service_id;
+	whdr.epoch	= htonl(conn->epoch);
+	whdr.cid	= htonl(conn->cid);
+	whdr.callNumber	= 0;
+	whdr.seq	= 0;
+	whdr.type	= RXRPC_PACKET_TYPE_ABORT;
+	whdr.flags	= conn->out_clientflag;
+	whdr.userStatus	= 0;
+	whdr.securityIndex = conn->security_ix;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(conn->service_id);
 
 	word = htonl(abort_code);
 
-	iov[0].iov_base	= &hdr;
-	iov[0].iov_len	= sizeof(hdr);
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
 	iov[1].iov_base	= &word;
 	iov[1].iov_len	= sizeof(word);
 
 	len = iov[0].iov_len + iov[1].iov_len;
 
-	hdr.serial = htonl(atomic_inc_return(&conn->serial));
-	_proto("Tx CONN ABORT %%%u { %d }", ntohl(hdr.serial), abort_code);
+	serial = atomic_inc_return(&conn->serial);
+	whdr.serial = htonl(serial);
+	_proto("Tx CONN ABORT %%%u { %d }", serial, abort_code);
 
 	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
 	if (ret < 0) {
@@ -146,8 +148,8 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 			       u32 *_abort_code)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	__be32 tmp;
-	u32 serial;
+	__be32 wtmp;
+	u32 abort_code;
 	int loop, ret;
 
 	if (conn->state >= RXRPC_CONN_REMOTELY_ABORTED) {
@@ -155,19 +157,18 @@ static int rxrpc_process_event(struct rxrpc_connection *conn,
 		return -ECONNABORTED;
 	}
 
-	serial = ntohl(sp->hdr.serial);
-
-	_enter("{%d},{%u,%%%u},", conn->debug_id, sp->hdr.type, serial);
+	_enter("{%d},{%u,%%%u},", conn->debug_id, sp->hdr.type, sp->hdr.serial);
 
 	switch (sp->hdr.type) {
 	case RXRPC_PACKET_TYPE_ABORT:
-		if (skb_copy_bits(skb, 0, &tmp, sizeof(tmp)) < 0)
+		if (skb_copy_bits(skb, 0, &wtmp, sizeof(wtmp)) < 0)
 			return -EPROTO;
-		_proto("Rx ABORT %%%u { ac=%d }", serial, ntohl(tmp));
+		abort_code = ntohl(wtmp);
+		_proto("Rx ABORT %%%u { ac=%d }", sp->hdr.serial, abort_code);
 
 		conn->state = RXRPC_CONN_REMOTELY_ABORTED;
 		rxrpc_abort_calls(conn, RXRPC_CALL_REMOTELY_ABORTED,
-				  ntohl(tmp));
+				  abort_code);
 		return -ECONNABORTED;
 
 	case RXRPC_PACKET_TYPE_CHALLENGE:
@@ -335,7 +336,7 @@ void rxrpc_reject_packets(struct work_struct *work)
 		struct sockaddr_in sin;
 	} sa;
 	struct rxrpc_skb_priv *sp;
-	struct rxrpc_header hdr;
+	struct rxrpc_wire_header whdr;
 	struct rxrpc_local *local;
 	struct sk_buff *skb;
 	struct msghdr msg;
@@ -348,11 +349,11 @@ void rxrpc_reject_packets(struct work_struct *work)
 
 	_enter("%d", local->debug_id);
 
-	iov[0].iov_base = &hdr;
-	iov[0].iov_len = sizeof(hdr);
+	iov[0].iov_base = &whdr;
+	iov[0].iov_len = sizeof(whdr);
 	iov[1].iov_base = &code;
 	iov[1].iov_len = sizeof(code);
-	size = sizeof(hdr) + sizeof(code);
+	size = sizeof(whdr) + sizeof(code);
 
 	msg.msg_name = &sa;
 	msg.msg_control = NULL;
@@ -370,8 +371,8 @@ void rxrpc_reject_packets(struct work_struct *work)
 		break;
 	}
 
-	memset(&hdr, 0, sizeof(hdr));
-	hdr.type = RXRPC_PACKET_TYPE_ABORT;
+	memset(&whdr, 0, sizeof(whdr));
+	whdr.type = RXRPC_PACKET_TYPE_ABORT;
 
 	while ((skb = skb_dequeue(&local->reject_queue))) {
 		sp = rxrpc_skb(skb);
@@ -381,13 +382,13 @@ void rxrpc_reject_packets(struct work_struct *work)
 			sa.sin.sin_addr.s_addr = ip_hdr(skb)->saddr;
 			code = htonl(skb->priority);
 
-			hdr.epoch = sp->hdr.epoch;
-			hdr.cid = sp->hdr.cid;
-			hdr.callNumber = sp->hdr.callNumber;
-			hdr.serviceId = sp->hdr.serviceId;
-			hdr.flags = sp->hdr.flags;
-			hdr.flags ^= RXRPC_CLIENT_INITIATED;
-			hdr.flags &= RXRPC_CLIENT_INITIATED;
+			whdr.epoch	= htonl(sp->hdr.epoch);
+			whdr.cid	= htonl(sp->hdr.cid);
+			whdr.callNumber	= htonl(sp->hdr.callNumber);
+			whdr.serviceId	= htons(sp->hdr.serviceId);
+			whdr.flags	= sp->hdr.flags;
+			whdr.flags	^= RXRPC_CLIENT_INITIATED;
+			whdr.flags	&= RXRPC_CLIENT_INITIATED;
 
 			kernel_sendmsg(local->socket, &msg, iov, 2, size);
 			break;
diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 9185535af5f5..e6396a8c969f 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -310,8 +310,8 @@ static void rxrpc_assume_implicit_ackall(struct rxrpc_call *call, u32 serial)
 void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
-	__be32 _abort_code;
-	u32 serial, hi_serial, seq, abort_code;
+	__be32 wtmp;
+	u32 hi_serial, abort_code;
 
 	_enter("%p,%p", call, skb);
 
@@ -330,16 +330,15 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 
 	/* track the latest serial number on this connection for ACK packet
 	 * information */
-	serial = ntohl(sp->hdr.serial);
 	hi_serial = atomic_read(&call->conn->hi_serial);
-	while (serial > hi_serial)
+	while (sp->hdr.serial > hi_serial)
 		hi_serial = atomic_cmpxchg(&call->conn->hi_serial, hi_serial,
-					   serial);
+					   sp->hdr.serial);
 
 	/* request ACK generation for any ACK or DATA packet that requests
 	 * it */
 	if (sp->hdr.flags & RXRPC_REQUEST_ACK) {
-		_proto("ACK Requested on %%%u", serial);
+		_proto("ACK Requested on %%%u", sp->hdr.serial);
 		rxrpc_propose_ACK(call, RXRPC_ACK_REQUESTED, sp->hdr.serial, false);
 	}
 
@@ -347,12 +346,11 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 	case RXRPC_PACKET_TYPE_ABORT:
 		_debug("abort");
 
-		if (skb_copy_bits(skb, 0, &_abort_code,
-				  sizeof(_abort_code)) < 0)
+		if (skb_copy_bits(skb, 0, &wtmp, sizeof(wtmp)) < 0)
 			goto protocol_error;
 
-		abort_code = ntohl(_abort_code);
-		_proto("Rx ABORT %%%u { %x }", serial, abort_code);
+		abort_code = ntohl(wtmp);
+		_proto("Rx ABORT %%%u { %x }", sp->hdr.serial, abort_code);
 
 		write_lock_bh(&call->state_lock);
 		if (call->state < RXRPC_CALL_COMPLETE) {
@@ -364,7 +362,7 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		goto free_packet_unlock;
 
 	case RXRPC_PACKET_TYPE_BUSY:
-		_proto("Rx BUSY %%%u", serial);
+		_proto("Rx BUSY %%%u", sp->hdr.serial);
 
 		if (call->conn->out_clientflag)
 			goto protocol_error;
@@ -382,15 +380,13 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		}
 
 	default:
-		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], serial);
+		_proto("Rx %s %%%u", rxrpc_pkts[sp->hdr.type], sp->hdr.serial);
 		goto protocol_error;
 
 	case RXRPC_PACKET_TYPE_DATA:
-		seq = ntohl(sp->hdr.seq);
+		_proto("Rx DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
 
-		_proto("Rx DATA %%%u { #%u }", serial, seq);
-
-		if (seq == 0)
+		if (sp->hdr.seq == 0)
 			goto protocol_error;
 
 		call->ackr_prev_seq = sp->hdr.seq;
@@ -398,9 +394,9 @@ void rxrpc_fast_process_packet(struct rxrpc_call *call, struct sk_buff *skb)
 		/* received data implicitly ACKs all of the request packets we
 		 * sent when we're acting as a client */
 		if (call->state == RXRPC_CALL_CLIENT_AWAIT_REPLY)
-			rxrpc_assume_implicit_ackall(call, serial);
+			rxrpc_assume_implicit_ackall(call, sp->hdr.serial);
 
-		switch (rxrpc_fast_process_data(call, skb, seq)) {
+		switch (rxrpc_fast_process_data(call, skb, sp->hdr.seq)) {
 		case 0:
 			skb = NULL;
 			goto done;
@@ -481,12 +477,12 @@ static void rxrpc_process_jumbo_packet(struct rxrpc_call *call,
 		if (!pskb_pull(jumbo, sizeof(jhdr)))
 			BUG();
 
-		sp->hdr.seq	= htonl(ntohl(sp->hdr.seq) + 1);
-		sp->hdr.serial	= htonl(ntohl(sp->hdr.serial) + 1);
+		sp->hdr.seq	+= 1;
+		sp->hdr.serial	+= 1;
 		sp->hdr.flags	= jhdr.flags;
 		sp->hdr._rsvd	= jhdr._rsvd;
 
-		_proto("Rx DATA Jumbo %%%u", ntohl(sp->hdr.serial) - 1);
+		_proto("Rx DATA Jumbo %%%u", sp->hdr.serial - 1);
 
 		rxrpc_fast_process_packet(call, part);
 		part = NULL;
@@ -607,6 +603,35 @@ static void rxrpc_post_packet_to_local(struct rxrpc_local *local,
 	rxrpc_queue_work(&local->event_processor);
 }
 
+/*
+ * Extract the wire header from a packet and translate the byte order.
+ */
+static noinline
+int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
+{
+	struct rxrpc_wire_header whdr;
+
+	/* dig out the RxRPC connection details */
+	if (skb_copy_bits(skb, sizeof(struct udphdr), &whdr, sizeof(whdr)) < 0)
+		return -EBADMSG;
+	if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(whdr)))
+		BUG();
+
+	memset(sp, 0, sizeof(*sp));
+	sp->hdr.epoch		= ntohl(whdr.epoch);
+	sp->hdr.cid		= ntohl(whdr.cid);
+	sp->hdr.callNumber	= ntohl(whdr.callNumber);
+	sp->hdr.seq		= ntohl(whdr.seq);
+	sp->hdr.serial		= ntohl(whdr.serial);
+	sp->hdr.flags		= whdr.flags;
+	sp->hdr.type		= whdr.type;
+	sp->hdr.userStatus	= whdr.userStatus;
+	sp->hdr.securityIndex	= whdr.securityIndex;
+	sp->hdr._rsvd		= ntohs(whdr._rsvd);
+	sp->hdr.serviceId	= ntohs(whdr.serviceId);
+	return 0;
+}
+
 static struct rxrpc_connection *rxrpc_conn_from_local(struct rxrpc_local *local,
 					       struct sk_buff *skb,
 					       struct rxrpc_skb_priv *sp)
@@ -686,27 +711,22 @@ void rxrpc_data_ready(struct sock *sk)
 
 	UDP_INC_STATS_BH(&init_net, UDP_MIB_INDATAGRAMS, 0);
 
-	/* the socket buffer we have is owned by UDP, with UDP's data all over
-	 * it, but we really want our own */
+	/* The socket buffer we have is owned by UDP, with UDP's data all over
+	 * it, but we really want our own data there.
+	 */
 	skb_orphan(skb);
 	sp = rxrpc_skb(skb);
-	memset(sp, 0, sizeof(*sp));
 
 	_net("Rx UDP packet from %08x:%04hu",
 	     ntohl(ip_hdr(skb)->saddr), ntohs(udp_hdr(skb)->source));
 
 	/* dig out the RxRPC connection details */
-	if (skb_copy_bits(skb, sizeof(struct udphdr), &sp->hdr,
-			  sizeof(sp->hdr)) < 0)
+	if (rxrpc_extract_header(sp, skb) < 0)
 		goto bad_message;
-	if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(sp->hdr)))
-		BUG();
 
 	_net("Rx RxRPC %s ep=%x call=%x:%x",
 	     sp->hdr.flags & RXRPC_CLIENT_INITIATED ? "ToServer" : "ToClient",
-	     ntohl(sp->hdr.epoch),
-	     ntohl(sp->hdr.cid),
-	     ntohl(sp->hdr.callNumber));
+	     sp->hdr.epoch, sp->hdr.cid, sp->hdr.callNumber);
 
 	if (sp->hdr.type == 0 || sp->hdr.type >= RXRPC_N_PACKET_TYPES) {
 		_proto("Rx Bad Packet Type %u", sp->hdr.type);
@@ -737,14 +757,9 @@ void rxrpc_data_ready(struct sock *sk)
 		rxrpc_put_connection(conn);
 	} else {
 		struct rxrpc_call *call;
-		u8 in_clientflag = 0;
-
-		if (sp->hdr.flags & RXRPC_CLIENT_INITIATED)
-			in_clientflag = RXRPC_CLIENT_INITIATED;
-		call = rxrpc_find_call_hash(in_clientflag, sp->hdr.cid,
-					    sp->hdr.callNumber, sp->hdr.epoch,
-					    sp->hdr.serviceId, local, AF_INET,
-					    (u8 *)&ip_hdr(skb)->saddr);
+
+		call = rxrpc_find_call_hash(&sp->hdr, local,
+					    AF_INET, &ip_hdr(skb)->saddr);
 		if (call)
 			rxrpc_post_packet_to_call(call, skb);
 		else
@@ -759,7 +774,7 @@ cant_route_call:
 	_debug("can't route call");
 	if (sp->hdr.flags & RXRPC_CLIENT_INITIATED &&
 	    sp->hdr.type == RXRPC_PACKET_TYPE_DATA) {
-		if (sp->hdr.seq == cpu_to_be32(1)) {
+		if (sp->hdr.seq == 1) {
 			_debug("first packet");
 			skb_queue_tail(&local->accept_queue, skb);
 			rxrpc_queue_work(&local->acceptor);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 3f2940626569..06bf5abd920d 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -70,12 +70,31 @@ struct rxrpc_sock {
 #define RXRPC_SECURITY_MAX	RXRPC_SECURITY_ENCRYPT
 	struct sockaddr_rxrpc	srx;		/* local address */
 	sa_family_t		proto;		/* protocol created with */
-	__be16			service_id;	/* service ID of local/remote service */
 };
 
 #define rxrpc_sk(__sk) container_of((__sk), struct rxrpc_sock, sk)
 
 /*
+ * CPU-byteorder normalised Rx packet header.
+ */
+struct rxrpc_host_header {
+	u32		epoch;		/* client boot timestamp */
+	u32		cid;		/* connection and channel ID */
+	u32		callNumber;	/* call ID (0 for connection-level packets) */
+	u32		seq;		/* sequence number of pkt in call stream */
+	u32		serial;		/* serial number of pkt sent to network */
+	u8		type;		/* packet type */
+	u8		flags;		/* packet flags */
+	u8		userStatus;	/* app-layer defined status */
+	u8		securityIndex;	/* security protocol ID */
+	union {
+		u16	_rsvd;		/* reserved */
+		u16	cksum;		/* kerberos security checksum */
+	};
+	u16		serviceId;	/* service ID */
+} __packed;
+
+/*
  * RxRPC socket buffer private variables
  * - max 48 bytes (struct sk_buff::cb)
  */
@@ -89,7 +108,7 @@ struct rxrpc_skb_priv {
 		bool		need_resend;	/* T if needs resending */
 	};
 
-	struct rxrpc_header	hdr;		/* RxRPC packet header from this packet */
+	struct rxrpc_host_header hdr;		/* RxRPC packet header from this packet */
 };
 
 #define rxrpc_skb(__skb) ((struct rxrpc_skb_priv *) &(__skb)->cb)
@@ -230,7 +249,7 @@ struct rxrpc_conn_bundle {
 	atomic_t		usage;
 	int			debug_id;	/* debug ID for printks */
 	unsigned short		num_conns;	/* number of connections in this bundle */
-	__be16			service_id;	/* service ID */
+	u16			service_id;	/* Service ID for this bundle */
 	u8			security_ix;	/* security type */
 };
 
@@ -260,7 +279,6 @@ struct rxrpc_connection {
 	rwlock_t		lock;		/* access lock */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
-	u32			real_conn_id;	/* connection ID (host-endian) */
 	enum {					/* current state of connection */
 		RXRPC_CONN_UNUSED,		/* - connection not yet attempted */
 		RXRPC_CONN_CLIENT,		/* - client connection */
@@ -282,11 +300,9 @@ struct rxrpc_connection {
 	u8			security_size;	/* security header size */
 	u32			security_level;	/* security level negotiated */
 	u32			security_nonce;	/* response re-use preventer */
-
-	/* the following are all in net order */
-	__be32			epoch;		/* epoch of this connection */
-	__be32			cid;		/* connection ID */
-	__be16			service_id;	/* service ID */
+	u32			epoch;		/* epoch of this connection */
+	u32			cid;		/* connection ID */
+	u16			service_id;	/* service ID for this connection */
 	u8			security_ix;	/* security type */
 	u8			in_clientflag;	/* RXRPC_CLIENT_INITIATED if we are server */
 	u8			out_clientflag;	/* RXRPC_CLIENT_INITIATED if we are client */
@@ -406,9 +422,9 @@ struct rxrpc_call {
 	rxrpc_seq_t		rx_data_eaten;	/* last data seq ID consumed by recvmsg */
 	rxrpc_seq_t		rx_first_oos;	/* first packet in rx_oos_queue (or 0) */
 	rxrpc_seq_t		ackr_win_top;	/* top of ACK window (rx_data_eaten is bottom) */
-	rxrpc_seq_net_t		ackr_prev_seq;	/* previous sequence number received */
+	rxrpc_seq_t		ackr_prev_seq;	/* previous sequence number received */
 	u8			ackr_reason;	/* reason to ACK */
-	__be32			ackr_serial;	/* serial of packet being ACK'd */
+	rxrpc_serial_t		ackr_serial;	/* serial of packet being ACK'd */
 	atomic_t		ackr_not_idle;	/* number of packets in Rx queue */
 
 	/* received packet records, 1 bit per record */
@@ -420,11 +436,10 @@ struct rxrpc_call {
 	u8			in_clientflag;	/* Copy of conn->in_clientflag for hashing */
 	struct rxrpc_local	*local;		/* Local endpoint. Used for hashing. */
 	sa_family_t		proto;		/* Frame protocol */
-	/* the following should all be in net order */
-	__be32			cid;		/* connection ID + channel index  */
-	__be32			call_id;	/* call ID on connection  */
-	__be32			epoch;		/* epoch of this connection */
-	__be16			service_id;	/* service ID */
+	u32			call_id;	/* call ID on connection  */
+	u32			cid;		/* connection ID plus channel index */
+	u32			epoch;		/* epoch of this connection */
+	u16			service_id;	/* service ID */
 	union {					/* Peer IP address for hashing */
 		__be32	ipv4_addr;
 		__u8	ipv6_addr[16];		/* Anticipates eventual IPv6 support */
@@ -449,7 +464,7 @@ static inline void rxrpc_abort_call(struct rxrpc_call *call, u32 abort_code)
  * af_rxrpc.c
  */
 extern atomic_t rxrpc_n_skbs;
-extern __be32 rxrpc_epoch;
+extern u32 rxrpc_epoch;
 extern atomic_t rxrpc_debug_id;
 extern struct workqueue_struct *rxrpc_workqueue;
 
@@ -470,8 +485,8 @@ extern unsigned rxrpc_rx_window_size;
 extern unsigned rxrpc_rx_mtu;
 extern unsigned rxrpc_rx_jumbo_max;
 
-void __rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
-void rxrpc_propose_ACK(struct rxrpc_call *, u8, __be32, bool);
+void __rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
+void rxrpc_propose_ACK(struct rxrpc_call *, u8, u32, bool);
 void rxrpc_process_call(struct work_struct *);
 
 /*
@@ -483,15 +498,15 @@ extern struct kmem_cache *rxrpc_call_jar;
 extern struct list_head rxrpc_calls;
 extern rwlock_t rxrpc_call_lock;
 
-struct rxrpc_call *rxrpc_find_call_hash(u8,  __be32, __be32, __be32,
-					__be16, void *, sa_family_t, const u8 *);
+struct rxrpc_call *rxrpc_find_call_hash(struct rxrpc_host_header *,
+					void *, sa_family_t, const void *);
 struct rxrpc_call *rxrpc_get_client_call(struct rxrpc_sock *,
 					 struct rxrpc_transport *,
 					 struct rxrpc_conn_bundle *,
 					 unsigned long, int, gfp_t);
 struct rxrpc_call *rxrpc_incoming_call(struct rxrpc_sock *,
 				       struct rxrpc_connection *,
-				       struct rxrpc_header *, gfp_t);
+				       struct rxrpc_host_header *, gfp_t);
 struct rxrpc_call *rxrpc_find_server_call(struct rxrpc_sock *, unsigned long);
 void rxrpc_release_call(struct rxrpc_call *);
 void rxrpc_release_calls_on_socket(struct rxrpc_sock *);
@@ -507,16 +522,16 @@ extern rwlock_t rxrpc_connection_lock;
 
 struct rxrpc_conn_bundle *rxrpc_get_bundle(struct rxrpc_sock *,
 					   struct rxrpc_transport *,
-					   struct key *, __be16, gfp_t);
+					   struct key *, u16, gfp_t);
 void rxrpc_put_bundle(struct rxrpc_transport *, struct rxrpc_conn_bundle *);
 int rxrpc_connect_call(struct rxrpc_sock *, struct rxrpc_transport *,
 		       struct rxrpc_conn_bundle *, struct rxrpc_call *, gfp_t);
 void rxrpc_put_connection(struct rxrpc_connection *);
 void __exit rxrpc_destroy_all_connections(void);
 struct rxrpc_connection *rxrpc_find_connection(struct rxrpc_transport *,
-					       struct rxrpc_header *);
+					       struct rxrpc_host_header *);
 extern struct rxrpc_connection *
-rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_header *,
+rxrpc_incoming_connection(struct rxrpc_transport *, struct rxrpc_host_header *,
 			  gfp_t);
 
 /*
diff --git a/net/rxrpc/ar-local.c b/net/rxrpc/ar-local.c
index 78483b4602bf..4e1e6db0050b 100644
--- a/net/rxrpc/ar-local.c
+++ b/net/rxrpc/ar-local.c
@@ -323,9 +323,11 @@ void __exit rxrpc_destroy_all_locals(void)
  * Reply to a version request
  */
 static void rxrpc_send_version_request(struct rxrpc_local *local,
-				       struct rxrpc_header *hdr,
+				       struct rxrpc_host_header *hdr,
 				       struct sk_buff *skb)
 {
+	struct rxrpc_wire_header whdr;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct sockaddr_in sin;
 	struct msghdr msg;
 	struct kvec iov[2];
@@ -344,15 +346,20 @@ static void rxrpc_send_version_request(struct rxrpc_local *local,
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr->seq	= 0;
-	hdr->serial	= 0;
-	hdr->type	= RXRPC_PACKET_TYPE_VERSION;
-	hdr->flags	= RXRPC_LAST_PACKET | (~hdr->flags & RXRPC_CLIENT_INITIATED);
-	hdr->userStatus	= 0;
-	hdr->_rsvd	= 0;
-
-	iov[0].iov_base	= hdr;
-	iov[0].iov_len	= sizeof(*hdr);
+	whdr.epoch	= htonl(sp->hdr.epoch);
+	whdr.cid	= htonl(sp->hdr.cid);
+	whdr.callNumber	= htonl(sp->hdr.callNumber);
+	whdr.seq	= 0;
+	whdr.serial	= 0;
+	whdr.type	= RXRPC_PACKET_TYPE_VERSION;
+	whdr.flags	= RXRPC_LAST_PACKET | (~hdr->flags & RXRPC_CLIENT_INITIATED);
+	whdr.userStatus	= 0;
+	whdr.securityIndex = 0;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(sp->hdr.serviceId);
+
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
 	iov[1].iov_base	= (char *)rxrpc_version_string;
 	iov[1].iov_len	= sizeof(rxrpc_version_string);
 
@@ -383,7 +390,7 @@ static void rxrpc_process_local_events(struct work_struct *work)
 	while ((skb = skb_dequeue(&local->event_queue))) {
 		struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 
-		kdebug("{%d},{%u}", local->debug_id, sp->hdr.type);
+		_debug("{%d},{%u}", local->debug_id, sp->hdr.type);
 
 		switch (sp->hdr.type) {
 		case RXRPC_PACKET_TYPE_VERSION:
diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 9e1527a6d026..353f5c9141ea 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -136,7 +136,7 @@ int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
 	struct rxrpc_call *call;
 	unsigned long user_call_ID = 0;
 	struct key *key;
-	__be16 service_id;
+	u16 service_id;
 	u32 abort_code = 0;
 	int ret;
 
@@ -151,11 +151,11 @@ int rxrpc_client_sendmsg(struct rxrpc_sock *rx, struct rxrpc_transport *trans,
 
 	bundle = NULL;
 	if (trans) {
-		service_id = rx->service_id;
+		service_id = rx->srx.srx_service;
 		if (msg->msg_name) {
 			DECLARE_SOCKADDR(struct sockaddr_rxrpc *, srx,
 					 msg->msg_name);
-			service_id = htons(srx->srx_service);
+			service_id = srx->srx_service;
 		}
 		key = rx->key;
 		if (key && !rx->key->payload.data[0])
@@ -348,7 +348,7 @@ int rxrpc_send_packet(struct rxrpc_transport *trans, struct sk_buff *skb)
 
 	/* send the packet with the don't fragment bit set if we currently
 	 * think it's small enough */
-	if (skb->len - sizeof(struct rxrpc_header) < trans->peer->maxdata) {
+	if (skb->len - sizeof(struct rxrpc_wire_header) < trans->peer->maxdata) {
 		down_read(&trans->local->defrag_sem);
 		/* send the packet by UDP
 		 * - returns -EMSGSIZE if UDP would have to fragment the packet
@@ -480,8 +480,7 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 		write_unlock_bh(&call->state_lock);
 	}
 
-	_proto("Tx DATA %%%u { #%u }",
-	       ntohl(sp->hdr.serial), ntohl(sp->hdr.seq));
+	_proto("Tx DATA %%%u { #%u }", sp->hdr.serial, sp->hdr.seq);
 
 	sp->need_resend = false;
 	sp->resend_at = jiffies + rxrpc_resend_timeout;
@@ -513,6 +512,29 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 }
 
 /*
+ * Convert a host-endian header into a network-endian header.
+ */
+static void rxrpc_insert_header(struct sk_buff *skb)
+{
+	struct rxrpc_wire_header whdr;
+	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+
+	whdr.epoch	= htonl(sp->hdr.epoch);
+	whdr.cid	= htonl(sp->hdr.cid);
+	whdr.callNumber	= htonl(sp->hdr.callNumber);
+	whdr.seq	= htonl(sp->hdr.seq);
+	whdr.serial	= htonl(sp->hdr.serial);
+	whdr.type	= sp->hdr.type;
+	whdr.flags	= sp->hdr.flags;
+	whdr.userStatus	= sp->hdr.userStatus;
+	whdr.securityIndex = sp->hdr.securityIndex;
+	whdr._rsvd	= htons(sp->hdr._rsvd);
+	whdr.serviceId	= htons(sp->hdr.serviceId);
+
+	memcpy(skb->head, &whdr, sizeof(whdr));
+}
+
+/*
  * send data through a socket
  * - must be called in process context
  * - caller holds the socket locked
@@ -650,17 +672,16 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			seq = atomic_inc_return(&call->sequence);
 
-			sp->hdr.epoch = conn->epoch;
-			sp->hdr.cid = call->cid;
+			sp->hdr.epoch	= conn->epoch;
+			sp->hdr.cid	= call->cid;
 			sp->hdr.callNumber = call->call_id;
-			sp->hdr.seq = htonl(seq);
-			sp->hdr.serial =
-				htonl(atomic_inc_return(&conn->serial));
-			sp->hdr.type = RXRPC_PACKET_TYPE_DATA;
+			sp->hdr.seq	= seq;
+			sp->hdr.serial	= atomic_inc_return(&conn->serial);
+			sp->hdr.type	= RXRPC_PACKET_TYPE_DATA;
 			sp->hdr.userStatus = 0;
 			sp->hdr.securityIndex = conn->security_ix;
-			sp->hdr._rsvd = 0;
-			sp->hdr.serviceId = conn->service_id;
+			sp->hdr._rsvd	= 0;
+			sp->hdr.serviceId = call->service_id;
 
 			sp->hdr.flags = conn->out_clientflag;
 			if (msg_data_left(msg) == 0 && !more)
@@ -673,12 +694,11 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 
 			ret = rxrpc_secure_packet(
 				call, skb, skb->mark,
-				skb->head + sizeof(struct rxrpc_header));
+				skb->head + sizeof(struct rxrpc_wire_header));
 			if (ret < 0)
 				goto out;
 
-			memcpy(skb->head, &sp->hdr,
-			       sizeof(struct rxrpc_header));
+			rxrpc_insert_header(skb);
 			rxrpc_queue_packet(call, skb, !msg_data_left(msg) && !more);
 			skb = NULL;
 		}
diff --git a/net/rxrpc/ar-peer.c b/net/rxrpc/ar-peer.c
index bebaa43484bc..dc089b1976aa 100644
--- a/net/rxrpc/ar-peer.c
+++ b/net/rxrpc/ar-peer.c
@@ -92,7 +92,7 @@ static struct rxrpc_peer *rxrpc_alloc_peer(struct sockaddr_rxrpc *srx,
 			BUG();
 		}
 
-		peer->hdrsize += sizeof(struct rxrpc_header);
+		peer->hdrsize += sizeof(struct rxrpc_wire_header);
 		peer->maxdata = peer->mtu - peer->hdrsize;
 	}
 
diff --git a/net/rxrpc/ar-proc.c b/net/rxrpc/ar-proc.c
index 38047f713f2c..525b2ba5a8f4 100644
--- a/net/rxrpc/ar-proc.c
+++ b/net/rxrpc/ar-proc.c
@@ -74,9 +74,9 @@ static int rxrpc_call_seq_show(struct seq_file *seq, void *v)
 		   " %-8.8s %08x %lx\n",
 		   lbuff,
 		   rbuff,
-		   ntohs(call->conn->service_id),
-		   ntohl(call->conn->cid),
-		   ntohl(call->call_id),
+		   call->conn->service_id,
+		   call->cid,
+		   call->call_id,
 		   call->conn->in_clientflag ? "Svc" : "Clt",
 		   atomic_read(&call->usage),
 		   rxrpc_call_states[call->state],
@@ -157,8 +157,8 @@ static int rxrpc_connection_seq_show(struct seq_file *seq, void *v)
 		   " %s %08x %08x %08x\n",
 		   lbuff,
 		   rbuff,
-		   ntohs(conn->service_id),
-		   ntohl(conn->cid),
+		   conn->service_id,
+		   conn->cid,
 		   conn->call_counter,
 		   conn->in_clientflag ? "Svc" : "Clt",
 		   atomic_read(&conn->usage),
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
index 70f47033ff2f..64facba24a45 100644
--- a/net/rxrpc/ar-recvmsg.c
+++ b/net/rxrpc/ar-recvmsg.c
@@ -158,7 +158,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			goto receive_non_data_message;
 
 		_debug("recvmsg DATA #%u { %d, %d }",
-		       ntohl(sp->hdr.seq), skb->len, sp->offset);
+		       sp->hdr.seq, skb->len, sp->offset);
 
 		if (!continue_call) {
 			/* only set the control data once per recvmsg() */
@@ -169,11 +169,11 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 			ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
 		}
 
-		ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
-		ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
-		call->rx_data_recv = ntohl(sp->hdr.seq);
+		ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
+		ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
+		call->rx_data_recv = sp->hdr.seq;
 
-		ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
+		ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
 
 		offset = sp->offset;
 		copy = skb->len - offset;
@@ -364,11 +364,11 @@ void rxrpc_kernel_data_delivered(struct sk_buff *skb)
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_call *call = sp->call;
 
-	ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
-	ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
-	call->rx_data_recv = ntohl(sp->hdr.seq);
+	ASSERTCMP(sp->hdr.seq, >=, call->rx_data_recv);
+	ASSERTCMP(sp->hdr.seq, <=, call->rx_data_recv + 1);
+	call->rx_data_recv = sp->hdr.seq;
 
-	ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
+	ASSERTCMP(sp->hdr.seq, >, call->rx_data_eaten);
 	rxrpc_free_skb(skb);
 }
 
diff --git a/net/rxrpc/ar-security.c b/net/rxrpc/ar-security.c
index 8334474eb26c..e2f4c49a9246 100644
--- a/net/rxrpc/ar-security.c
+++ b/net/rxrpc/ar-security.c
@@ -171,7 +171,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	_enter("");
 
-	sprintf(kdesc, "%u:%u", ntohs(conn->service_id), conn->security_ix);
+	sprintf(kdesc, "%u:%u", conn->service_id, conn->security_ix);
 
 	sec = rxrpc_security_lookup(conn->security_ix);
 	if (!sec) {
@@ -182,7 +182,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 	/* find the service */
 	read_lock_bh(&local->services_lock);
 	list_for_each_entry(rx, &local->services, listen_link) {
-		if (rx->service_id == conn->service_id)
+		if (rx->srx.srx_service == conn->service_id)
 			goto found_service;
 	}
 
diff --git a/net/rxrpc/ar-skbuff.c b/net/rxrpc/ar-skbuff.c
index 81f3c0238b9a..ae9f93f94ed2 100644
--- a/net/rxrpc/ar-skbuff.c
+++ b/net/rxrpc/ar-skbuff.c
@@ -59,7 +59,7 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 
 	spin_lock_bh(&call->lock);
 
-	_debug("hard ACK #%u", ntohl(sp->hdr.seq));
+	_debug("hard ACK #%u", sp->hdr.seq);
 
 	for (loop = 0; loop < RXRPC_ACKR_WINDOW_ASZ; loop++) {
 		call->ackr_window[loop] >>= 1;
@@ -67,7 +67,7 @@ static void rxrpc_hard_ACK_data(struct rxrpc_call *call,
 			call->ackr_window[loop + 1] << (BITS_PER_LONG - 1);
 	}
 
-	seq = ntohl(sp->hdr.seq);
+	seq = sp->hdr.seq;
 	ASSERTCMP(seq, ==, call->rx_data_eaten + 1);
 	call->rx_data_eaten = seq;
 
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 9946467f16b4..5f9b9d462f53 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -51,6 +51,7 @@ static struct rxrpc_transport *rxrpc_alloc_transport(struct rxrpc_local *local,
 		spin_lock_init(&trans->client_lock);
 		rwlock_init(&trans->conn_lock);
 		atomic_set(&trans->usage, 1);
+		trans->conn_idcounter = peer->srx.srx_service << 16;
 		trans->debug_id = atomic_inc_return(&rxrpc_debug_id);
 
 		if (peer->srx.transport.family == AF_INET) {
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index d7a9ab5a9d9c..160480221224 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -132,8 +132,8 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	desc.info = iv.x;
 	desc.flags = 0;
 
-	tmpbuf.x[0] = conn->epoch;
-	tmpbuf.x[1] = conn->cid;
+	tmpbuf.x[0] = htonl(conn->epoch);
+	tmpbuf.x[1] = htonl(conn->cid);
 	tmpbuf.x[2] = 0;
 	tmpbuf.x[3] = htonl(conn->security_ix);
 
@@ -169,8 +169,8 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 
 	_enter("");
 
-	check = ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
-	data_size |= (u32) check << 16;
+	check = sp->hdr.seq ^ sp->hdr.callNumber;
+	data_size |= (u32)check << 16;
 
 	tmpbuf.hdr.data_size = htonl(data_size);
 	memcpy(&tmpbuf.first, sechdr + 4, sizeof(tmpbuf.first));
@@ -215,9 +215,9 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 
 	_enter("");
 
-	check = ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	check = sp->hdr.seq ^ sp->hdr.callNumber;
 
-	rxkhdr.data_size = htonl(data_size | (u32) check << 16);
+	rxkhdr.data_size = htonl(data_size | (u32)check << 16);
 	rxkhdr.checksum = 0;
 
 	/* encrypt from the session key */
@@ -262,14 +262,13 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	struct {
 		__be32 x[2];
 	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
-	__be32 x;
-	u32 y;
+	u32 x, y;
 	int ret;
 
 	sp = rxrpc_skb(skb);
 
 	_enter("{%d{%x}},{#%u},%zu,",
-	       call->debug_id, key_serial(call->conn->key), ntohl(sp->hdr.seq),
+	       call->debug_id, key_serial(call->conn->key), sp->hdr.seq,
 	       data_size);
 
 	if (!call->conn->cipher)
@@ -286,10 +285,10 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	desc.flags = 0;
 
 	/* calculate the security checksum */
-	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
-	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
-	tmpbuf.x[0] = sp->hdr.callNumber;
-	tmpbuf.x[1] = x;
+	x = call->channel << (32 - RXRPC_CIDSHIFT);
+	x |= sp->hdr.seq & 0x3fffffff;
+	tmpbuf.x[0] = htonl(sp->hdr.callNumber);
+	tmpbuf.x[1] = htonl(x);
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
@@ -299,7 +298,7 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 	y = (y >> 16) & 0xffff;
 	if (y == 0)
 		y = 1; /* zero checksums are not permitted */
-	sp->hdr.cksum = htons(y);
+	sp->hdr.cksum = y;
 
 	switch (call->conn->security_level) {
 	case RXRPC_SECURITY_PLAIN:
@@ -368,7 +367,7 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 	data_size = buf & 0xffff;
 
 	check = buf >> 16;
-	check ^= ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	check ^= sp->hdr.seq ^ sp->hdr.callNumber;
 	check &= 0xffff;
 	if (check != 0) {
 		*_abort_code = RXKADSEALEDINCON;
@@ -453,7 +452,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	data_size = buf & 0xffff;
 
 	check = buf >> 16;
-	check ^= ntohl(sp->hdr.seq ^ sp->hdr.callNumber);
+	check ^= sp->hdr.seq ^ sp->hdr.callNumber;
 	check &= 0xffff;
 	if (check != 0) {
 		*_abort_code = RXKADSEALEDINCON;
@@ -494,16 +493,14 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	struct {
 		__be32 x[2];
 	} tmpbuf __attribute__((aligned(8))); /* must all be in same page */
-	__be32 x;
-	__be16 cksum;
-	u32 y;
+	u16 cksum;
+	u32 x, y;
 	int ret;
 
 	sp = rxrpc_skb(skb);
 
 	_enter("{%d{%x}},{#%u}",
-	       call->debug_id, key_serial(call->conn->key),
-	       ntohl(sp->hdr.seq));
+	       call->debug_id, key_serial(call->conn->key), sp->hdr.seq);
 
 	if (!call->conn->cipher)
 		return 0;
@@ -521,21 +518,20 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 	desc.flags = 0;
 
 	/* validate the security checksum */
-	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
-	x |= sp->hdr.seq & cpu_to_be32(0x3fffffff);
-	tmpbuf.x[0] = call->call_id;
-	tmpbuf.x[1] = x;
+	x = call->channel << (32 - RXRPC_CIDSHIFT);
+	x |= sp->hdr.seq & 0x3fffffff;
+	tmpbuf.x[0] = htonl(call->call_id);
+	tmpbuf.x[1] = htonl(x);
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
 	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
 
 	y = ntohl(tmpbuf.x[1]);
-	y = (y >> 16) & 0xffff;
-	if (y == 0)
-		y = 1; /* zero checksums are not permitted */
+	cksum = (y >> 16) & 0xffff;
+	if (cksum == 0)
+		cksum = 1; /* zero checksums are not permitted */
 
-	cksum = htons(y);
 	if (sp->hdr.cksum != cksum) {
 		*_abort_code = RXKADSEALEDINCON;
 		_leave(" = -EPROTO [csum failed]");
@@ -567,10 +563,11 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 {
 	struct rxkad_challenge challenge;
-	struct rxrpc_header hdr;
+	struct rxrpc_wire_header whdr;
 	struct msghdr msg;
 	struct kvec iov[2];
 	size_t len;
+	u32 serial;
 	int ret;
 
 	_enter("{%d,%x}", conn->debug_id, key_serial(conn->key));
@@ -592,26 +589,27 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr.epoch	= conn->epoch;
-	hdr.cid		= conn->cid;
-	hdr.callNumber	= 0;
-	hdr.seq		= 0;
-	hdr.type	= RXRPC_PACKET_TYPE_CHALLENGE;
-	hdr.flags	= conn->out_clientflag;
-	hdr.userStatus	= 0;
-	hdr.securityIndex = conn->security_ix;
-	hdr._rsvd	= 0;
-	hdr.serviceId	= conn->service_id;
-
-	iov[0].iov_base	= &hdr;
-	iov[0].iov_len	= sizeof(hdr);
+	whdr.epoch	= htonl(conn->epoch);
+	whdr.cid	= htonl(conn->cid);
+	whdr.callNumber	= 0;
+	whdr.seq	= 0;
+	whdr.type	= RXRPC_PACKET_TYPE_CHALLENGE;
+	whdr.flags	= conn->out_clientflag;
+	whdr.userStatus	= 0;
+	whdr.securityIndex = conn->security_ix;
+	whdr._rsvd	= 0;
+	whdr.serviceId	= htons(conn->service_id);
+
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
 	iov[1].iov_base	= &challenge;
 	iov[1].iov_len	= sizeof(challenge);
 
 	len = iov[0].iov_len + iov[1].iov_len;
 
-	hdr.serial = htonl(atomic_inc_return(&conn->serial));
-	_proto("Tx CHALLENGE %%%u", ntohl(hdr.serial));
+	serial = atomic_inc_return(&conn->serial);
+	whdr.serial = htonl(serial);
+	_proto("Tx CHALLENGE %%%u", serial);
 
 	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 2, len);
 	if (ret < 0) {
@@ -627,13 +625,15 @@ static int rxkad_issue_challenge(struct rxrpc_connection *conn)
  * send a Kerberos security response
  */
 static int rxkad_send_response(struct rxrpc_connection *conn,
-			       struct rxrpc_header *hdr,
+			       struct rxrpc_host_header *hdr,
 			       struct rxkad_response *resp,
 			       const struct rxkad_key *s2)
 {
+	struct rxrpc_wire_header whdr;
 	struct msghdr msg;
 	struct kvec iov[3];
 	size_t len;
+	u32 serial;
 	int ret;
 
 	_enter("");
@@ -644,24 +644,26 @@ static int rxkad_send_response(struct rxrpc_connection *conn,
 	msg.msg_controllen = 0;
 	msg.msg_flags	= 0;
 
-	hdr->epoch	= conn->epoch;
-	hdr->seq	= 0;
-	hdr->type	= RXRPC_PACKET_TYPE_RESPONSE;
-	hdr->flags	= conn->out_clientflag;
-	hdr->userStatus	= 0;
-	hdr->_rsvd	= 0;
+	memset(&whdr, 0, sizeof(whdr));
+	whdr.epoch	= htonl(hdr->epoch);
+	whdr.cid	= htonl(hdr->cid);
+	whdr.type	= RXRPC_PACKET_TYPE_RESPONSE;
+	whdr.flags	= conn->out_clientflag;
+	whdr.securityIndex = hdr->securityIndex;
+	whdr.serviceId	= htons(hdr->serviceId);
 
-	iov[0].iov_base	= hdr;
-	iov[0].iov_len	= sizeof(*hdr);
+	iov[0].iov_base	= &whdr;
+	iov[0].iov_len	= sizeof(whdr);
 	iov[1].iov_base	= resp;
 	iov[1].iov_len	= sizeof(*resp);
-	iov[2].iov_base	= (void *) s2->ticket;
+	iov[2].iov_base	= (void *)s2->ticket;
 	iov[2].iov_len	= s2->ticket_len;
 
 	len = iov[0].iov_len + iov[1].iov_len + iov[2].iov_len;
 
-	hdr->serial = htonl(atomic_inc_return(&conn->serial));
-	_proto("Tx RESPONSE %%%u", ntohl(hdr->serial));
+	serial = atomic_inc_return(&conn->serial);
+	whdr.serial = htonl(serial);
+	_proto("Tx RESPONSE %%%u", serial);
 
 	ret = kernel_sendmsg(conn->trans->local->socket, &msg, iov, 3, len);
 	if (ret < 0) {
@@ -770,7 +772,7 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	min_level = ntohl(challenge.min_level);
 
 	_proto("Rx CHALLENGE %%%u { v=%u n=%u ml=%u }",
-	       ntohl(sp->hdr.serial), version, nonce, min_level);
+	       sp->hdr.serial, version, nonce, min_level);
 
 	abort_code = RXKADINCONSISTENCY;
 	if (version != RXKAD_VERSION)
@@ -786,17 +788,17 @@ static int rxkad_respond_to_challenge(struct rxrpc_connection *conn,
 	memset(&resp, 0, sizeof(resp));
 
 	resp.version = RXKAD_VERSION;
-	resp.encrypted.epoch = conn->epoch;
-	resp.encrypted.cid = conn->cid;
+	resp.encrypted.epoch = htonl(conn->epoch);
+	resp.encrypted.cid = htonl(conn->cid);
 	resp.encrypted.securityIndex = htonl(conn->security_ix);
 	resp.encrypted.call_id[0] =
-		(conn->channels[0] ? conn->channels[0]->call_id : 0);
+		htonl(conn->channels[0] ? conn->channels[0]->call_id : 0);
 	resp.encrypted.call_id[1] =
-		(conn->channels[1] ? conn->channels[1]->call_id : 0);
+		htonl(conn->channels[1] ? conn->channels[1]->call_id : 0);
 	resp.encrypted.call_id[2] =
-		(conn->channels[2] ? conn->channels[2]->call_id : 0);
+		htonl(conn->channels[2] ? conn->channels[2]->call_id : 0);
 	resp.encrypted.call_id[3] =
-		(conn->channels[3] ? conn->channels[3]->call_id : 0);
+		htonl(conn->channels[3] ? conn->channels[3]->call_id : 0);
 	resp.encrypted.inc_nonce = htonl(nonce + 1);
 	resp.encrypted.level = htonl(conn->security_level);
 	resp.kvno = htonl(token->kad->kvno);
@@ -1022,7 +1024,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	kvno = ntohl(response.kvno);
 	sp = rxrpc_skb(skb);
 	_proto("Rx RESPONSE %%%u { v=%u kv=%u tl=%u }",
-	       ntohl(sp->hdr.serial), version, kvno, ticket_len);
+	       sp->hdr.serial, version, kvno, ticket_len);
 
 	abort_code = RXKADINCONSISTENCY;
 	if (version != RXKAD_VERSION)
@@ -1058,9 +1060,9 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 	rxkad_decrypt_response(conn, &response, &session_key);
 
 	abort_code = RXKADSEALEDINCON;
-	if (response.encrypted.epoch != conn->epoch)
+	if (ntohl(response.encrypted.epoch) != conn->epoch)
 		goto protocol_error_free;
-	if (response.encrypted.cid != conn->cid)
+	if (ntohl(response.encrypted.cid) != conn->cid)
 		goto protocol_error_free;
 	if (ntohl(response.encrypted.securityIndex) != conn->security_ix)
 		goto protocol_error_free;
@@ -1077,7 +1079,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 		goto protocol_error_free;
 
 	abort_code = RXKADOUTOFSEQUENCE;
-	if (response.encrypted.inc_nonce != htonl(conn->security_nonce + 1))
+	if (ntohl(response.encrypted.inc_nonce) != conn->security_nonce + 1)
 		goto protocol_error_free;
 
 	abort_code = RXKADLEVELFAIL;
