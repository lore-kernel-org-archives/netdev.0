From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 1/7] sctp: add support for generating stream reconf resp chunk
Date: Fri, 17 Feb 2017 12:45:37 +0800
Message-ID: <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35834 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754965AbdBQEqF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:05 -0500
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
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
index b055788..7a4804c 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -749,4 +749,28 @@ struct sctp_strreset_addstrm {
 	__u16 reserved;
 };
 
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
+};
+
+struct sctp_strreset_resptsn {
+	sctp_paramhdr_t param_hdr;
+	__u32 response_seq;
+	__u32 result;
+	__u32 senders_next_tsn;
+	__u32 receivers_next_tsn;
+};
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 3675fde..8a85dd7 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -270,6 +270,13 @@ struct sctp_chunk *sctp_make_strreset_tsnreq(
 struct sctp_chunk *sctp_make_strreset_addstrm(
 				const struct sctp_association *asoc,
 				__u16 out, __u16 in);
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
index 7f8dbf2..9680c58 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3733,3 +3733,77 @@ struct sctp_chunk *sctp_make_strreset_addstrm(
 
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
