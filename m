From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 4/5] sctp: add support for generating stream reconf response chunk
Date: Sat,  7 Jan 2017 17:43:01 +0800
Message-ID: <be9631328644431b88ba998d6234485578957156.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
 <f1875fdb7c77e5f7a7fe33a1e1d2554da24901bb.1483781759.git.lucien.xin@gmail.com>
 <d218ad72dbbffebe5926c86c2e7dd04eddbd905d.1483781759.git.lucien.xin@gmail.com>
 <01d610742b62da93ccd79581e407b0aec7bc488c.1483781759.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33103 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941320AbdAGJnm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 04:43:42 -0500
In-Reply-To: <01d610742b62da93ccd79581e407b0aec7bc488c.1483781759.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to define Re-configuration Response Parameter described
in rfc6525 section 4.4. As optional fields are only for SSN/TSN Reset
Request Parameter, it uses another function to make that.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 24 ++++++++++++++++
 include/net/sctp/sm.h    |  7 +++++
 net/sctp/sm_make_chunk.c | 74 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 105 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index cc4c74d..c4fcc7d 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -747,4 +747,28 @@ struct sctp_strreset_tsnreq {
 	__u32 request_seq;
 } __packed;
 
+enum {
+	SCTP_STRRESET_NOTHING_TO_DO	= 0x00,
+	SCTP_STRRESET_PERFORMED		= 0x01,
+	SCTP_STRRESET_DENIED		= 0x02,
+	SCTP_STRRESET_ERR_WRONG_SSN	= 0x03,
+	SCTP_STRRESET_ERR_IN_PROGRESS	= 0x04,
+	SCTP_STRRESET_ERR_BAD_SEQNO	= 0x05,
+	SCTP_STRRESET_IN_PROGRESS	= 0x06,
+};
+
+struct sctp_strreset_resp {
+	sctp_paramhdr_t param_hdr;
+	__u32 response_seq;
+	__u32 result;
+} __packed;
+
+struct sctp_strreset_resptsn {
+	sctp_paramhdr_t param_hdr;
+	__u32 response_seq;
+	__u32 result;
+	__u32 senders_next_tsn;
+	__u32 receivers_next_tsn;
+} __packed;
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index c658700..013d69f 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -265,6 +265,13 @@ struct sctp_chunk *sctp_make_strreset_req(
 				bool out, bool in);
 struct sctp_chunk *sctp_make_strreset_tsnreq(
 				const struct sctp_association *asoc);
+struct sctp_chunk *sctp_make_strreset_resp(
+				const struct sctp_association *asoc,
+				__u32 result, __u32 sn);
+struct sctp_chunk *sctp_make_strreset_tsnresp(
+				struct sctp_association *asoc,
+				__u32 result, __u32 sn,
+				__u32 sender_tsn, __u32 receiver_tsn);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index f1d8f07..34edb30 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3676,3 +3676,77 @@ struct sctp_chunk *sctp_make_strreset_tsnreq(
 
 	return retval;
 }
+
+/* RE-CONFIG 4.4 (RESP)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 16       |      Parameter Length         |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |         Re-configuration Response Sequence Number             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                            Result                             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct sctp_chunk *sctp_make_strreset_resp(
+				const struct sctp_association *asoc,
+				__u32 result, __u32 sn)
+{
+	struct sctp_strreset_resp resp;
+	__u16 length = sizeof(resp);
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_reconf(asoc, length);
+	if (!retval)
+		return NULL;
+
+	resp.param_hdr.type = SCTP_PARAM_RESET_RESPONSE;
+	resp.param_hdr.length = htons(length);
+	resp.response_seq = htonl(sn);
+	resp.result = htonl(result);
+
+	sctp_addto_chunk(retval, sizeof(resp), &resp);
+
+	return retval;
+}
+
+/* RE-CONFIG 4.4 OPTIONAL (TSNRESP)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 16       |      Parameter Length         |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |         Re-configuration Response Sequence Number             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                            Result                             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                   Sender's Next TSN (optional)                |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                  Receiver's Next TSN (optional)               |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct sctp_chunk *sctp_make_strreset_tsnresp(
+					struct sctp_association *asoc,
+					__u32 result, __u32 sn,
+					__u32 sender_tsn, __u32 receiver_tsn)
+{
+	struct sctp_strreset_resptsn tsnresp;
+	__u16 length = sizeof(tsnresp);
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_reconf(asoc, length);
+	if (!retval)
+		return NULL;
+
+	tsnresp.param_hdr.type = SCTP_PARAM_RESET_RESPONSE;
+	tsnresp.param_hdr.length = htons(length);
+
+	tsnresp.response_seq = htonl(sn);
+	tsnresp.result = htonl(result);
+	tsnresp.senders_next_tsn = htonl(sender_tsn);
+	tsnresp.receivers_next_tsn = htonl(receiver_tsn);
+
+	sctp_addto_chunk(retval, sizeof(tsnresp), &tsnresp);
+
+	return retval;
+}
-- 
2.1.0
