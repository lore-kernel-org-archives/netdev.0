From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] sctp: send abort chunk when max_retrans exceeded
Date: Tue, 20 Nov 2012 12:59:04 -0500
Message-ID: <1353434344-17864-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53261 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751613Ab2KTR7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 12:59:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the event that an association exceeds its max_retrans attempts, we should
send an ABORT chunk indicating that we are closing the assocation as a result.
Because of the nature of the error, its unlikely to be received, but its a nice
clean way to close the association if it does make it through, and it will give
anyone watching via tcpdump a clue as to what happened.

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Vlad Yasevich <vyasevich@gmail.com>
CC: "David S. Miller" <davem@davemloft.net>
CC: linux-sctp@vger.kernel.org
---
 include/net/sctp/sm.h    |  2 ++
 net/sctp/sm_make_chunk.c | 26 +++++++++++++++++++++-----
 net/sctp/sm_sideeffect.c |  9 ++++++++-
 3 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index b5887e1..2a82d13 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -234,6 +234,8 @@ struct sctp_chunk *sctp_make_abort_violation(const struct sctp_association *,
 struct sctp_chunk *sctp_make_violation_paramlen(const struct sctp_association *,
 				   const struct sctp_chunk *,
 				   struct sctp_paramhdr *);
+struct sctp_chunk *sctp_make_violation_max_retrans(const struct sctp_association *,
+						   const struct sctp_chunk *);
 struct sctp_chunk *sctp_make_heartbeat(const struct sctp_association *,
 				  const struct sctp_transport *);
 struct sctp_chunk *sctp_make_heartbeat_ack(const struct sctp_association *,
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index fbe1636..d6a8c80 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1074,17 +1074,33 @@ struct sctp_chunk *sctp_make_violation_paramlen(
 {
 	struct sctp_chunk *retval;
 	static const char error[] = "The following parameter had invalid length:";
-	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t) +
-				sizeof(sctp_paramhdr_t);
+	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t);
 
 	retval = sctp_make_abort(asoc, chunk, payload_len);
 	if (!retval)
 		goto nodata;
 
-	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION,
-			sizeof(error) + sizeof(sctp_paramhdr_t));
+	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION, sizeof(error));
+	sctp_addto_chunk(retval, sizeof(error), error);
+
+nodata:
+	return retval;
+}
+
+struct sctp_chunk *sctp_make_violation_max_retrans(
+	const struct sctp_association *asoc,
+	const struct sctp_chunk *chunk)
+{
+	struct sctp_chunk *retval;
+	static const char error[] = "Association exceeded its max_retans count";
+	size_t payload_len = sizeof(error) + sizeof(sctp_errhdr_t);
+
+	retval = sctp_make_abort(asoc, chunk, payload_len);
+	if (!retval)
+		goto nodata;
+
+	sctp_init_cause(retval, SCTP_ERROR_PROTO_VIOLATION, sizeof(error));
 	sctp_addto_chunk(retval, sizeof(error), error);
-	sctp_addto_param(retval, sizeof(sctp_paramhdr_t), param);
 
 nodata:
 	return retval;
diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 6eecf7e..c076956 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -577,7 +577,7 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 				  unsigned int error)
 {
 	struct sctp_ulpevent *event;
-
+	struct sctp_chunk *abort;
 	/* Cancel any partial delivery in progress. */
 	sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
 
@@ -593,6 +593,13 @@ static void sctp_cmd_assoc_failed(sctp_cmd_seq_t *commands,
 		sctp_add_cmd_sf(commands, SCTP_CMD_EVENT_ULP,
 				SCTP_ULPEVENT(event));
 
+	if (asoc->overall_error_count >= asoc->max_retrans) {
+		abort = sctp_make_violation_max_retrans(asoc, chunk);
+		if (abort)
+			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
+					SCTP_CHUNK(abort));
+	}
+
 	sctp_add_cmd_sf(commands, SCTP_CMD_NEW_STATE,
 			SCTP_STATE(SCTP_STATE_CLOSED));
 
-- 
1.7.11.7
