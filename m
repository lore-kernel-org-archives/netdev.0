From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 21/27] sctp: add rfc6525 section 5.2.3
Date: Sun,  1 Jan 2017 19:20:38 +0800
Message-ID: <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
 <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
 <58860816816d6d51b062235fd54dae6540a4797a.1483269426.git.lucien.xin@gmail.com>
 <229608faf7af54c0bf908694ca8349205bbf6eab.1483269426.git.lucien.xin@gmail.com>
 <c4f16844620cd3a2aa76596df9eaadf1505fc8e6.1483269426.git.lucien.xin@gmail.com>
 <1d0b270084289945c4b42ae36d0556648a3f9b64.1483269426.git.lucien.xin@gmail.com>
 <1e4560205cff3c10868d5614b62a3db14e87ccf0.1483269426.git.lucien.xin@gmail.com>
 <91b9171cc57c0f322d103dfbbcce1b9706800805.1483269426.git.lucien.xin@gmail.com>
 <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
 <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
 <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
 <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
 <1e8e248c38fd3874cf80c4b88e4699c8a617066d.1483269426.git.lucien.xin@gmail.com>
 <3a60ce82edef82f329fe2cc4ac83e9ca21831d8b.1483269426.git.lucien.xin@gmail.com>
 <9be4c65c6bac7df0dbf51328af92727e5606dc5c.1483269426.git.lucien.xin@gmail.com>
 <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33926 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:40 -0500
In-Reply-To: <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Incoming
SSN Reset Request Parameter described in section 5.2.3.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |  4 ++++
 net/sctp/stream.c     | 63 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 1833215..180d017 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -285,6 +285,10 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_inreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 1d5b795..3053d06 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -144,3 +144,66 @@ struct sctp_chunk *sctp_process_strreset_outreq(
 out:
 	return sctp_make_strreset_resp(asoc, result, request_seq);
 }
+
+struct sctp_chunk *sctp_process_strreset_inreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_inreq *inreq = param.v;
+	__u32 result = SCTP_STRRESET_DENIED;
+	struct sctp_chunk *chunk = NULL;
+	__u16 i, nums, *str_p;
+	__u32 request_seq;
+
+	request_seq = ntohl(inreq->request_seq);
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
+		goto out;
+
+	if (asoc->strreset_outstanding) {
+		result = SCTP_STRRESET_ERR_IN_PROGRESS;
+		goto out;
+	}
+
+	nums = (ntohs(param.p->length) - sizeof(*inreq)) / 2;
+	str_p = inreq->list_of_streams;
+	for (i = 0; i < nums; i++) {
+		str_p[i] = ntohs(str_p[i]);
+		if (str_p[i] >= asoc->streamoutcnt) {
+			result = SCTP_STRRESET_ERR_WRONG_SSN;
+			goto out;
+		}
+	}
+
+	chunk = sctp_make_strreset_req(asoc, nums, str_p, 1, 0);
+	if (!chunk)
+		goto out;
+
+	if (nums)
+		for (i = 0; i < nums; i++)
+			asoc->streamout[str_p[i]].state =
+						   SCTP_STREAM_CLOSED;
+	else
+		for (i = 0; i < asoc->streamoutcnt; i++)
+			asoc->streamout[i].state = SCTP_STREAM_CLOSED;
+
+	asoc->strreset_chunk = chunk;
+	asoc->strreset_outstanding = 1;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	*evp = sctp_ulpevent_make_stream_reset_event(asoc,
+		SCTP_STREAM_RESET_INCOMING_SSN, nums, str_p, GFP_ATOMIC);
+
+out:
+	if (!chunk)
+		chunk =  sctp_make_strreset_resp(asoc, result, request_seq);
+
+	return chunk;
+}
-- 
2.1.0
