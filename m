From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 5/7] sctp: implement receiver-side procedures for the Add Incoming Streams Request Parameter
Date: Fri, 10 Mar 2017 12:11:10 +0800
Message-ID: <7def0879be34d7e8a8bc1f11cc62ae8570bfcf26.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
 <7bf94990cf77044e0286adc2f393af4c9010213c.1489118815.git.lucien.xin@gmail.com>
 <f224235b4621ea3a182e959873f6fe0ba78e5416.1489118815.git.lucien.xin@gmail.com>
 <70b0da1e9de612702d0ddcdeab67e56b6d11fd78.1489118815.git.lucien.xin@gmail.com>
 <f73e5ede81d0eeccdf955eb7d77eadcda5166c9e.1489118815.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33654 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdCJEMC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 23:12:02 -0500
In-Reply-To: <f73e5ede81d0eeccdf955eb7d77eadcda5166c9e.1489118815.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1489118815.git.lucien.xin@gmail.com>
References: <cover.1489118815.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Add Incoming
Streams Request Parameter described in rfc6525 section 5.2.6.

It is also to fix that it shouldn't have add streams when sending addstrm
in request, as the process in peer will handle it by sending a addstrm out
request back.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h   |  4 +++
 net/sctp/sm_statefuns.c |  3 ++
 net/sctp/stream.c       | 74 +++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 69 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 93ae50b..e0d9825 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -301,6 +301,10 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_addstrm_in(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 881122b..a8687a7 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3878,6 +3878,9 @@ sctp_disposition_t sctp_sf_do_reconf(struct net *net,
 		else if (param.p->type == SCTP_PARAM_RESET_ADD_OUT_STREAMS)
 			reply = sctp_process_strreset_addstrm_out(
 				(struct sctp_association *)asoc, param, &ev);
+		else if (param.p->type == SCTP_PARAM_RESET_ADD_IN_STREAMS)
+			reply = sctp_process_strreset_addstrm_in(
+				(struct sctp_association *)asoc, param, &ev);
 		/* More handles for other types will be added here, by now it
 		 * just ignores other types.
 		 */
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index df2794d..1c925db 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -267,18 +267,6 @@ int sctp_send_add_streams(struct sctp_association *asoc,
 		stream->out = streamout;
 	}
 
-	if (in) {
-		struct sctp_stream_in *streamin;
-
-		streamin = krealloc(stream->in, incnt * sizeof(*streamin),
-				    GFP_KERNEL);
-		if (!streamin)
-			goto out;
-
-		memset(streamin + stream->incnt, 0, in * sizeof(*streamin));
-		stream->in = streamin;
-	}
-
 	chunk = sctp_make_strreset_addstrm(asoc, out, in);
 	if (!chunk)
 		goto out;
@@ -625,3 +613,65 @@ struct sctp_chunk *sctp_process_strreset_addstrm_out(
 out:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
+
+struct sctp_chunk *sctp_process_strreset_addstrm_in(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_addstrm *addstrm = param.v;
+	struct sctp_stream *stream = asoc->stream;
+	__u32 result = SCTP_STRRESET_DENIED;
+	struct sctp_stream_out *streamout;
+	struct sctp_chunk *chunk = NULL;
+	__u32 request_seq, outcnt;
+	__u16 out;
+
+	request_seq = ntohl(addstrm->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ))
+		goto out;
+
+	if (asoc->strreset_outstanding) {
+		result = SCTP_STRRESET_ERR_IN_PROGRESS;
+		goto out;
+	}
+
+	out = ntohs(addstrm->number_of_streams);
+	outcnt = stream->outcnt + out;
+	if (!out || outcnt > SCTP_MAX_STREAM)
+		goto out;
+
+	streamout = krealloc(stream->out, outcnt * sizeof(*streamout),
+			     GFP_ATOMIC);
+	if (!streamout)
+		goto out;
+
+	memset(streamout + stream->outcnt, 0, out * sizeof(*streamout));
+	stream->out = streamout;
+
+	chunk = sctp_make_strreset_addstrm(asoc, out, 0);
+	if (!chunk)
+		goto out;
+
+	asoc->strreset_chunk = chunk;
+	asoc->strreset_outstanding = 1;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	stream->outcnt = outcnt;
+
+	*evp = sctp_ulpevent_make_stream_change_event(asoc,
+		0, 0, ntohs(addstrm->number_of_streams), GFP_ATOMIC);
+
+out:
+	if (!chunk)
+		chunk = sctp_make_strreset_resp(asoc, result, request_seq);
+
+	return chunk;
+}
-- 
2.1.0
