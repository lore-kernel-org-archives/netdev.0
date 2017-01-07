From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/5] sctp: add support for generating stream reconf ssn/tsn reset request chunk
Date: Sat,  7 Jan 2017 17:43:00 +0800
Message-ID: <01d610742b62da93ccd79581e407b0aec7bc488c.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
 <f1875fdb7c77e5f7a7fe33a1e1d2554da24901bb.1483781759.git.lucien.xin@gmail.com>
 <d218ad72dbbffebe5926c86c2e7dd04eddbd905d.1483781759.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34292 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941316AbdAGJne (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 04:43:34 -0500
In-Reply-To: <d218ad72dbbffebe5926c86c2e7dd04eddbd905d.1483781759.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to define SSN/TSN Reset Request Parameter described
in rfc6525 section 4.3.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  5 +++++
 include/net/sctp/sm.h    |  2 ++
 net/sctp/sm_make_chunk.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index d5da19c..cc4c74d 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -742,4 +742,9 @@ struct sctp_strreset_inreq {
 	__u16 list_of_streams[0];
 } __packed;
 
+struct sctp_strreset_tsnreq {
+	sctp_paramhdr_t param_hdr;
+	__u32 request_seq;
+} __packed;
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 3462cb0..c658700 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -263,6 +263,8 @@ struct sctp_chunk *sctp_make_strreset_req(
 				const struct sctp_association *asoc,
 				__u16 stream_num, __u16 *stream_list,
 				bool out, bool in);
+struct sctp_chunk *sctp_make_strreset_tsnreq(
+				const struct sctp_association *asoc);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 172385c..f1d8f07 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3647,3 +3647,32 @@ struct sctp_chunk *sctp_make_strreset_req(
 
 	return retval;
 }
+
+/* RE-CONFIG 4.3 (SSN/TSN RESET ALL)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 15       |      Parameter Length = 8     |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |         Re-configuration Request Sequence Number              |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct sctp_chunk *sctp_make_strreset_tsnreq(
+				const struct sctp_association *asoc)
+{
+	struct sctp_strreset_tsnreq tsnreq;
+	__u16 length = sizeof(tsnreq);
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_reconf(asoc, length);
+	if (!retval)
+		return NULL;
+
+	tsnreq.param_hdr.type = SCTP_PARAM_RESET_TSN_REQUEST;
+	tsnreq.param_hdr.length = htons(length);
+	tsnreq.request_seq = htonl(asoc->strreset_outseq);
+
+	sctp_addto_chunk(retval, sizeof(tsnreq), &tsnreq);
+
+	return retval;
+}
-- 
2.1.0
