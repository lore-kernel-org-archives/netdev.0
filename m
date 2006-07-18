From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 3/6][SCTP]: Verify all the paths to a peer via heartbeat
	before using them.
Date: Mon, 17 Jul 2006 17:25:28 -0700
Message-ID: <1153182328.4282.45.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:31953 "EHLO e2.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751264AbWGRA2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2006 20:28:02 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6I0S1mP016028
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6I0S1Sa249820
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6I0S0Bd026785
	for <netdev@vger.kernel.org>; Mon, 17 Jul 2006 20:28:01 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Verify all the paths to a peer via heartbeat before using them.

This patch implements Path Initialization procedure as described in
Sec 2.36 of RFC4460.

Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 include/net/sctp/structs.h |    4 ++++
 include/net/sctp/user.h    |    9 +++++++++
 net/sctp/associola.c       |   27 +++++++++++++++++----------
 net/sctp/outqueue.c        |    9 ++++++---
 net/sctp/sm_make_chunk.c   |    4 ++--
 net/sctp/sm_sideeffect.c   |   12 ++++++++++--
 net/sctp/sm_statefuns.c    |    5 +++++
 net/sctp/transport.c       |    9 +++++++--
 8 files changed, 60 insertions(+), 19 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 5f69158..268f2e1 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -445,6 +445,7 @@ typedef struct sctp_sender_hb_info {
 	struct sctp_paramhdr param_hdr;
 	union sctp_addr daddr;
 	unsigned long sent_at;
+	__u64 hb_nonce;
 } __attribute__((packed)) sctp_sender_hb_info_t;
 
 /*
@@ -984,6 +985,9 @@ struct sctp_transport {
 		 */
 		char cacc_saw_newack;
 	} cacc;
+
+	/* 64-bit random number sent with heartbeat. */
+	__u64 hb_nonce;
 };
 
 struct sctp_transport *sctp_transport_new(const union sctp_addr *,
diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
index 8a6bef6..f037313 100644
--- a/include/net/sctp/user.h
+++ b/include/net/sctp/user.h
@@ -560,9 +560,18 @@ struct sctp_paddrinfo {
 } __attribute__((packed, aligned(4)));
 
 /* Peer addresses's state. */
+/* UNKNOWN: Peer address passed by the upper layer in sendmsg or connect[x]
+ * calls.
+ * UNCONFIRMED: Peer address received in INIT/INIT-ACK address parameters.
+ *              Not yet confirmed by a heartbeat and not available for data
+ *		transfers.
+ * ACTIVE : Peer address confirmed, active and available for data transfers.
+ * INACTIVE: Peer address inactive and not available for data transfers.
+ */
 enum sctp_spinfo_state {
 	SCTP_INACTIVE,
 	SCTP_ACTIVE,
+	SCTP_UNCONFIRMED,
 	SCTP_UNKNOWN = 0xffff  /* Value used for transport state unknown */
 };
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 9d05e13..98cff10 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -441,7 +441,8 @@ void sctp_assoc_set_primary(struct sctp_
 	/* If the primary path is changing, assume that the
 	 * user wants to use this new path.
 	 */
-	if (transport->state != SCTP_INACTIVE)
+	if ((transport->state == SCTP_ACTIVE) ||
+	    (transport->state == SCTP_UNKNOWN))
 		asoc->peer.active_path = transport;
 
 	/*
@@ -532,11 +533,11 @@ struct sctp_transport *sctp_assoc_add_pe
 	port = addr->v4.sin_port;
 
 	SCTP_DEBUG_PRINTK_IPADDR("sctp_assoc_add_peer:association %p addr: ",
-				 " port: %d state:%s\n",
+				 " port: %d state:%d\n",
 				 asoc,
 				 addr,
 				 addr->v4.sin_port,
-				 peer_state == SCTP_UNKNOWN?"UNKNOWN":"ACTIVE");
+				 peer_state);
 
 	/* Set the port if it has not been set yet.  */
 	if (0 == asoc->peer.port)
@@ -545,9 +546,12 @@ struct sctp_transport *sctp_assoc_add_pe
 	/* Check to see if this is a duplicate. */
 	peer = sctp_assoc_lookup_paddr(asoc, addr);
 	if (peer) {
-		if (peer_state == SCTP_ACTIVE &&
-		    peer->state == SCTP_UNKNOWN)
-		     peer->state = SCTP_ACTIVE;
+		if (peer->state == SCTP_UNKNOWN) {
+			if (peer_state == SCTP_ACTIVE)
+				peer->state = SCTP_ACTIVE;
+			if (peer_state == SCTP_UNCONFIRMED)
+				peer->state = SCTP_UNCONFIRMED;
+		}
 		return peer;
 	}
 
@@ -739,7 +743,8 @@ void sctp_assoc_control_transport(struct
 	list_for_each(pos, &asoc->peer.transport_addr_list) {
 		t = list_entry(pos, struct sctp_transport, transports);
 
-		if (t->state == SCTP_INACTIVE)
+		if ((t->state == SCTP_INACTIVE) ||
+		    (t->state == SCTP_UNCONFIRMED))
 			continue;
 		if (!first || t->last_time_heard > first->last_time_heard) {
 			second = first;
@@ -759,7 +764,8 @@ void sctp_assoc_control_transport(struct
 	 * [If the primary is active but not most recent, bump the most
 	 * recently used transport.]
 	 */
-	if (asoc->peer.primary_path->state != SCTP_INACTIVE &&
+	if (((asoc->peer.primary_path->state == SCTP_ACTIVE) ||
+	     (asoc->peer.primary_path->state == SCTP_UNKNOWN)) &&
 	    first != asoc->peer.primary_path) {
 		second = first;
 		first = asoc->peer.primary_path;
@@ -1054,7 +1060,7 @@ void sctp_assoc_update(struct sctp_assoc
 					   transports);
 			if (!sctp_assoc_lookup_paddr(asoc, &trans->ipaddr))
 				sctp_assoc_add_peer(asoc, &trans->ipaddr,
-						    GFP_ATOMIC, SCTP_ACTIVE);
+						    GFP_ATOMIC, trans->state);
 		}
 
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
@@ -1094,7 +1100,8 @@ void sctp_assoc_update_retran_path(struc
 
 		/* Try to find an active transport. */
 
-		if (t->state != SCTP_INACTIVE) {
+		if ((t->state == SCTP_ACTIVE) ||
+		    (t->state == SCTP_UNKNOWN)) {
 			break;
 		} else {
 			/* Keep track of the next transport in case
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index e5faa35..30b710c 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -691,7 +691,8 @@ int sctp_outq_flush(struct sctp_outq *q,
 
 		if (!new_transport) {
 			new_transport = asoc->peer.active_path;
-		} else if (new_transport->state == SCTP_INACTIVE) {
+		} else if ((new_transport->state == SCTP_INACTIVE) ||
+			   (new_transport->state == SCTP_UNCONFIRMED)) {
 			/* If the chunk is Heartbeat or Heartbeat Ack,
 			 * send it to chunk->transport, even if it's
 			 * inactive.
@@ -848,7 +849,8 @@ int sctp_outq_flush(struct sctp_outq *q,
 			 */
 			new_transport = chunk->transport;
 			if (!new_transport ||
-			    new_transport->state == SCTP_INACTIVE)
+			    ((new_transport->state == SCTP_INACTIVE) ||
+			     (new_transport->state == SCTP_UNCONFIRMED)))
 				new_transport = asoc->peer.active_path;
 
 			/* Change packets if necessary.  */
@@ -1464,7 +1466,8 @@ #endif /* SCTP_DEBUG */
 			/* Mark the destination transport address as
 			 * active if it is not so marked.
 			 */
-			if (transport->state == SCTP_INACTIVE) {
+			if ((transport->state == SCTP_INACTIVE) ||
+			    (transport->state == SCTP_UNCONFIRMED)) {
 				sctp_assoc_control_transport(
 					transport->asoc,
 					transport,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2a87736..8134e8b 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2017,7 +2017,7 @@ static int sctp_process_param(struct sct
 		af->from_addr_param(&addr, param.addr, asoc->peer.port, 0);
 		scope = sctp_scope(peer_addr);
 		if (sctp_in_scope(&addr, scope))
-			if (!sctp_assoc_add_peer(asoc, &addr, gfp, SCTP_ACTIVE))
+			if (!sctp_assoc_add_peer(asoc, &addr, gfp, SCTP_UNCONFIRMED))
 				return 0;
 		break;
 
@@ -2418,7 +2418,7 @@ static __u16 sctp_process_asconf_param(s
 	 	 * Due to Resource Shortage'.
 	 	 */
 
-		peer = sctp_assoc_add_peer(asoc, &addr, GFP_ATOMIC, SCTP_ACTIVE);
+		peer = sctp_assoc_add_peer(asoc, &addr, GFP_ATOMIC, SCTP_UNCONFIRMED);
 		if (!peer)
 			return SCTP_ERROR_RSRC_LOW;
 
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index c5beb2a..9c10bde 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -430,7 +430,11 @@ static void sctp_do_8_2_transport_strike
 	/* The check for association's overall error counter exceeding the
 	 * threshold is done in the state function.
 	 */
-	asoc->overall_error_count++;
+	/* When probing UNCONFIRMED addresses, the association overall
+	 * error count is NOT incremented
+	 */
+	if (transport->state != SCTP_UNCONFIRMED)
+		asoc->overall_error_count++;
 
 	if (transport->state != SCTP_INACTIVE &&
 	    (transport->error_count++ >= transport->pathmaxrxt)) {
@@ -610,7 +614,7 @@ static void sctp_cmd_transport_on(sctp_c
 	/* Mark the destination transport address as active if it is not so
 	 * marked.
 	 */
-	if (t->state == SCTP_INACTIVE)
+	if ((t->state == SCTP_INACTIVE) || (t->state == SCTP_UNCONFIRMED))
 		sctp_assoc_control_transport(asoc, t, SCTP_TRANSPORT_UP,
 					     SCTP_HEARTBEAT_SUCCESS);
 
@@ -620,6 +624,10 @@ static void sctp_cmd_transport_on(sctp_c
 	 */
 	hbinfo = (sctp_sender_hb_info_t *) chunk->skb->data;
 	sctp_transport_update_rto(t, (jiffies - hbinfo->sent_at));
+
+	/* Update the heartbeat timer.  */
+	if (!mod_timer(&t->hb_timer, sctp_transport_timeout(t)))
+		sctp_transport_hold(t);
 }
 
 /* Helper function to do a transport reset at the expiry of the hearbeat
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 9e58144..e8498dc 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -846,6 +846,7 @@ static sctp_disposition_t sctp_sf_heartb
 	hbinfo.param_hdr.length = htons(sizeof(sctp_sender_hb_info_t));
 	hbinfo.daddr = transport->ipaddr;
 	hbinfo.sent_at = jiffies;
+	hbinfo.hb_nonce = transport->hb_nonce;
 
 	/* Send a heartbeat to our peer.  */
 	paylen = sizeof(sctp_sender_hb_info_t);
@@ -1048,6 +1049,10 @@ sctp_disposition_t sctp_sf_backbeat_8_3(
 		return SCTP_DISPOSITION_DISCARD;
 	}
 
+	/* Validate the 64-bit random nonce. */
+	if (hbinfo->hb_nonce != link->hb_nonce)
+		return SCTP_DISPOSITION_DISCARD;
+
 	max_interval = link->hbinterval + link->rto;
 
 	/* Check if the timestamp looks valid.  */
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 160f62a..2763aa9 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -49,6 +49,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/random.h>
 #include <net/sctp/sctp.h>
 #include <net/sctp/sm.h>
 
@@ -85,7 +86,6 @@ static struct sctp_transport *sctp_trans
 
 	peer->init_sent_count = 0;
 
-	peer->state = SCTP_ACTIVE;
 	peer->param_flags = SPP_HB_DISABLE |
 			    SPP_PMTUD_ENABLE |
 			    SPP_SACKDELAY_ENABLE;
@@ -109,6 +109,9 @@ static struct sctp_transport *sctp_trans
 	peer->hb_timer.function = sctp_generate_heartbeat_event;
 	peer->hb_timer.data = (unsigned long)peer;
 
+	/* Initialize the 64-bit random nonce sent with heartbeat. */
+	get_random_bytes(&peer->hb_nonce, sizeof(peer->hb_nonce));
+
 	atomic_set(&peer->refcnt, 1);
 	peer->dead = 0;
 
@@ -517,7 +520,9 @@ void sctp_transport_lower_cwnd(struct sc
 unsigned long sctp_transport_timeout(struct sctp_transport *t)
 {
 	unsigned long timeout;
-	timeout = t->hbinterval + t->rto + sctp_jitter(t->rto);
+	timeout = t->rto + sctp_jitter(t->rto);
+	if (t->state != SCTP_UNCONFIRMED)
+		timeout += t->hbinterval;
 	timeout += jiffies;
 	return timeout;
 }


