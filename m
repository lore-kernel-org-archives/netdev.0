From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/27] sctp: add rfc6525 section 4.3
Date: Sun,  1 Jan 2017 19:20:23 +0800
Message-ID: <31abc54d31ef0714322f137bff43458014d7c276.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
 <684ad8ddd79f23844883dede4c34360ce744dfc3.1483269426.git.lucien.xin@gmail.com>
 <c752879a5af358c08da949b391416452f1322c43.1483269426.git.lucien.xin@gmail.com>
 <be8a2770ddc2381266050c9f168add9802b90a49.1483269426.git.lucien.xin@gmail.com>
 <fc046afdda34c9b262ce57400c4256b14fd1a0fb.1483269426.git.lucien.xin@gmail.com>
 <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36711 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755131AbdAALVl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:21:41 -0500
In-Reply-To: <d4f1b2a4fa19457e9867b0a1f84764a7a509459a.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to define SSN/TSN Reset Request Parameter described
in section 4.3.

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
index 6420714..4b29965 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3655,3 +3655,32 @@ struct sctp_chunk *sctp_make_strreset_req(
 
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
