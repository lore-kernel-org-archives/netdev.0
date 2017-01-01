From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/27] sctp: add stream arrays in asoc
Date: Sun,  1 Jan 2017 19:20:18 +0800
Message-ID: <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34311 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755040AbdAALVA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:21:00 -0500
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add streamout and streamin arrays in asoc, initialize
them in sctp_process_init and free them in sctp_association_free.

Stream arrays are used to replace ssnmap to save more stream things in
the next patch.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h | 18 ++++++++++++++++++
 net/sctp/associola.c       | 19 +++++++++++++++++++
 net/sctp/sm_make_chunk.c   | 17 ++++++++++++++++-
 3 files changed, 53 insertions(+), 1 deletion(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 87d56cc..549f17d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1331,6 +1331,18 @@ struct sctp_inithdr_host {
 	__u32 initial_tsn;
 };
 
+struct sctp_stream_out {
+	__u16	ssn;
+	__u8	state;
+};
+
+struct sctp_stream_in {
+	__u16	ssn;
+};
+
+#define SCTP_STREAM_CLOSED		0x00
+#define SCTP_STREAM_OPEN		0x01
+
 /* SCTP_GET_ASSOC_STATS counters */
 struct sctp_priv_assoc_stats {
 	/* Maximum observed rto in the association during subsequent
@@ -1879,6 +1891,12 @@ struct sctp_association {
 	     temp:1,		/* Is it a temporary association? */
 	     prsctp_enable:1;
 
+	/* stream arrays */
+	struct sctp_stream_out *streamout;
+	struct sctp_stream_in *streamin;
+	__u16 streamoutcnt;
+	__u16 streamincnt;
+
 	struct sctp_priv_assoc_stats stats;
 
 	int sent_cnt_removable;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index d3cc30c..290ec4d 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -361,6 +361,10 @@ void sctp_association_free(struct sctp_association *asoc)
 	/* Free ssnmap storage. */
 	sctp_ssnmap_free(asoc->ssnmap);
 
+	/* Free stream information. */
+	kfree(asoc->streamout);
+	kfree(asoc->streamin);
+
 	/* Clean up the bound address list. */
 	sctp_bind_addr_free(&asoc->base.bind_addr);
 
@@ -1130,6 +1134,8 @@ void sctp_assoc_update(struct sctp_association *asoc,
 	 * has been discarded and needs retransmission.
 	 */
 	if (asoc->state >= SCTP_STATE_ESTABLISHED) {
+		int i;
+
 		asoc->next_tsn = new->next_tsn;
 		asoc->ctsn_ack_point = new->ctsn_ack_point;
 		asoc->adv_peer_ack_point = new->adv_peer_ack_point;
@@ -1139,6 +1145,12 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		 */
 		sctp_ssnmap_clear(asoc->ssnmap);
 
+		for (i = 0; i < asoc->streamoutcnt; i++)
+			asoc->streamout[i].ssn = 0;
+
+		for (i = 0; i < asoc->streamincnt; i++)
+			asoc->streamin[i].ssn = 0;
+
 		/* Flush the ULP reassembly and ordered queue.
 		 * Any data there will now be stale and will
 		 * cause problems.
@@ -1168,6 +1180,13 @@ void sctp_assoc_update(struct sctp_association *asoc,
 			new->ssnmap = NULL;
 		}
 
+		if (!asoc->streamin && !asoc->streamout) {
+			asoc->streamout = new->streamout;
+			asoc->streamin = new->streamin;
+			new->streamout = NULL;
+			new->streamin = NULL;
+		}
+
 		if (!asoc->assoc_id) {
 			/* get a new association id since we don't have one
 			 * yet.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9e9690b..eeadeef 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -2442,13 +2442,28 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	 * association.
 	 */
 	if (!asoc->temp) {
-		int error;
+		int error, i;
+
+		asoc->streamoutcnt = asoc->c.sinit_num_ostreams;
+		asoc->streamincnt = asoc->c.sinit_max_instreams;
 
 		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
 					       asoc->c.sinit_num_ostreams, gfp);
 		if (!asoc->ssnmap)
 			goto clean_up;
 
+		asoc->streamout = kcalloc(asoc->streamoutcnt,
+					  sizeof(*asoc->streamout), gfp);
+		if (!asoc->streamout)
+			goto clean_up;
+		for (i = 0; i < asoc->streamoutcnt; i++)
+			asoc->streamout[i].state = SCTP_STREAM_OPEN;
+
+		asoc->streamin = kcalloc(asoc->streamincnt,
+					 sizeof(*asoc->streamin), gfp);
+		if (!asoc->streamin)
+			goto clean_up;
+
 		error = sctp_assoc_set_id(asoc, gfp);
 		if (error)
 			goto clean_up;
-- 
2.1.0
