From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 2/4] [SCTP]: Verify some mandatory parameters.
Date: Thu, 11 Jan 2007 11:41:27 -0800
Message-ID: <1168544487.22592.19.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57069 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751449AbXAKTlp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jan 2007 14:41:45 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id l0BJfZOx000314
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:35 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id l0BJfZHV280138
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:35 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0BJfYjH002556
	for <netdev@vger.kernel.org>; Thu, 11 Jan 2007 14:41:34 -0500
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Verify some mandatory parameters.

Verify init_tag and a_rwnd mandatory parameters in INIT and
INIT-ACK chunks.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>

---
 net/sctp/sm_make_chunk.c |    4 +++-
 net/sctp/sm_statefuns.c  |   19 -------------------
 2 files changed, 3 insertions(+), 20 deletions(-)

diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index ea0f8fa..12c0e17 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1775,7 +1775,9 @@ int sctp_verify_init(const struct sctp_association *asoc,

 	/* Verify stream values are non-zero. */
 	if ((0 == peer_init->init_hdr.num_outbound_streams) ||
-	    (0 == peer_init->init_hdr.num_inbound_streams)) {
+	    (0 == peer_init->init_hdr.num_inbound_streams) ||
+	    (0 == peer_init->init_hdr.init_tag) ||
+	    (SCTP_DEFAULT_MINWINDOW > ntohl(peer_init->init_hdr.a_rwnd))) {

 		sctp_process_inv_mandatory(asoc, chunk, errp);
 		return 0;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index aa51d19..2c165dc 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -440,7 +440,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 {
 	struct sctp_chunk *chunk = arg;
 	sctp_init_chunk_t *initchunk;
-	__u32 init_tag;
 	struct sctp_chunk *err_chunk;
 	struct sctp_packet *packet;
 	sctp_error_t error;
@@ -462,24 +461,6 @@ sctp_disposition_t sctp_sf_do_5_1C_ack(const struct sctp_endpoint *ep,
 	/* Grab the INIT header.  */
 	chunk->subh.init_hdr = (sctp_inithdr_t *) chunk->skb->data;

-	init_tag = ntohl(chunk->subh.init_hdr->init_tag);
-
-	/* Verification Tag: 3.3.3
-	 *   If the value of the Initiate Tag in a received INIT ACK
-	 *   chunk is found to be 0, the receiver MUST treat it as an
-	 *   error and close the association by transmitting an ABORT.
-	 */
-	if (!init_tag) {
-		struct sctp_chunk *reply = sctp_make_abort(asoc, chunk, 0);
-		if (!reply)
-			goto nomem;
-
-		sctp_add_cmd_sf(commands, SCTP_CMD_REPLY, SCTP_CHUNK(reply));
-		return sctp_stop_t1_and_abort(commands, SCTP_ERROR_INV_PARAM,
-					      ECONNREFUSED, asoc,
-					      chunk->transport);
-	}
-
 	/* Verify the INIT chunk before processing it. */
 	err_chunk = NULL;
 	if (!sctp_verify_init(asoc, chunk->chunk_hdr->type,
--

