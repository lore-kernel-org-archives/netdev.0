From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH 2/2] sctp: check src addr when processing SACK to update transport state
Date: Wed,  3 Oct 2012 17:43:22 +0200
Message-ID: <1349279002-4008-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: linux-sctp@vger.kernel.org, vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:40497 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964811Ab2JCPjJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 11:39:09 -0400
In-Reply-To: <1349279002-4008-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Suppose we have an SCTP connection with two paths. After connection is
established, path1 is not available, thus this path is marked as inactive. Then
traffic goes through path2, but for some reasons packets are delayed (after
rto.max). Because packets are delayed, the retransmit mechanism will switch
again to path1. At this time, we receive a delayed SACK from path2. When we
update the state of the path in sctp_check_transmitted(), we do not take into
account the source address of the SACK, hence we update the wrong path.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/sctp/structs.h |  2 +-
 net/sctp/outqueue.c        | 15 ++++++++++-----
 net/sctp/sm_sideeffect.c   |  4 ++--
 net/sctp/sm_statefuns.c    |  2 +-
 4 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 0fef00f..64158aa 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1068,7 +1068,7 @@ void sctp_outq_init(struct sctp_association *, struct sctp_outq *);
 void sctp_outq_teardown(struct sctp_outq *);
 void sctp_outq_free(struct sctp_outq*);
 int sctp_outq_tail(struct sctp_outq *, struct sctp_chunk *chunk);
-int sctp_outq_sack(struct sctp_outq *, struct sctp_sackhdr *);
+int sctp_outq_sack(struct sctp_outq *, struct sctp_chunk *);
 int sctp_outq_is_empty(const struct sctp_outq *);
 void sctp_outq_restart(struct sctp_outq *);
 
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index d16632e..1b4a7f8 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -63,6 +63,7 @@ static int sctp_acked(struct sctp_sackhdr *sack, __u32 tsn);
 static void sctp_check_transmitted(struct sctp_outq *q,
 				   struct list_head *transmitted_queue,
 				   struct sctp_transport *transport,
+				   union sctp_addr *saddr,
 				   struct sctp_sackhdr *sack,
 				   __u32 *highest_new_tsn);
 
@@ -1139,9 +1140,10 @@ static void sctp_sack_update_unack_data(struct sctp_association *assoc,
  * Process the SACK against the outqueue.  Mostly, this just frees
  * things off the transmitted queue.
  */
-int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
+int sctp_outq_sack(struct sctp_outq *q, struct sctp_chunk *chunk)
 {
 	struct sctp_association *asoc = q->asoc;
+	struct sctp_sackhdr *sack = chunk->subh.sack_hdr;
 	struct sctp_transport *transport;
 	struct sctp_chunk *tchunk = NULL;
 	struct list_head *lchunk, *transport_list, *temp;
@@ -1210,7 +1212,7 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	/* Run through the retransmit queue.  Credit bytes received
 	 * and free those chunks that we can.
 	 */
-	sctp_check_transmitted(q, &q->retransmit, NULL, sack, &highest_new_tsn);
+	sctp_check_transmitted(q, &q->retransmit, NULL, NULL, sack, &highest_new_tsn);
 
 	/* Run through the transmitted queue.
 	 * Credit bytes received and free those chunks which we can.
@@ -1219,7 +1221,8 @@ int sctp_outq_sack(struct sctp_outq *q, struct sctp_sackhdr *sack)
 	 */
 	list_for_each_entry(transport, transport_list, transports) {
 		sctp_check_transmitted(q, &transport->transmitted,
-				       transport, sack, &highest_new_tsn);
+				       transport, &chunk->source, sack,
+				       &highest_new_tsn);
 		/*
 		 * SFR-CACC algorithm:
 		 * C) Let count_of_newacks be the number of
@@ -1326,6 +1329,7 @@ int sctp_outq_is_empty(const struct sctp_outq *q)
 static void sctp_check_transmitted(struct sctp_outq *q,
 				   struct list_head *transmitted_queue,
 				   struct sctp_transport *transport,
+				   union sctp_addr *saddr,
 				   struct sctp_sackhdr *sack,
 				   __u32 *highest_new_tsn_in_sack)
 {
@@ -1633,8 +1637,9 @@ static void sctp_check_transmitted(struct sctp_outq *q,
 			/* Mark the destination transport address as
 			 * active if it is not so marked.
 			 */
-			if ((transport->state == SCTP_INACTIVE) ||
-			    (transport->state == SCTP_UNCONFIRMED)) {
+			if ((transport->state == SCTP_INACTIVE ||
+			     transport->state == SCTP_UNCONFIRMED) &&
+			    sctp_cmp_addr_exact(&transport->ipaddr, saddr)) {
 				sctp_assoc_control_transport(
 					transport->asoc,
 					transport,
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index bcfebb9..57f7de8 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -752,11 +752,11 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 /* Helper function to process the process SACK command.  */
 static int sctp_cmd_process_sack(sctp_cmd_seq_t *cmds,
 				 struct sctp_association *asoc,
-				 struct sctp_sackhdr *sackh)
+				 struct sctp_chunk *chunk)
 {
 	int err = 0;
 
-	if (sctp_outq_sack(&asoc->outqueue, sackh)) {
+	if (sctp_outq_sack(&asoc->outqueue, chunk)) {
 		struct net *net = sock_net(asoc->base.sk);
 
 		/* There are no more TSNs awaiting SACK.  */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 094813b..b6adef8 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3179,7 +3179,7 @@ sctp_disposition_t sctp_sf_eat_sack_6_2(struct net *net,
 		return sctp_sf_violation_ctsn(net, ep, asoc, type, arg, commands);
 
 	/* Return this SACK for further processing.  */
-	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_SACKH(sackh));
+	sctp_add_cmd_sf(commands, SCTP_CMD_PROCESS_SACK, SCTP_CHUNK(chunk));
 
 	/* Note: We do the rest of the work on the PROCESS_SACK
 	 * sideeffect.
-- 
1.7.12
