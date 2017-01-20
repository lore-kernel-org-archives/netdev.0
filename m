From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 4/5] sctp: add support for generating stream reconf add incoming/outgoing streams request chunk
Date: Sat, 21 Jan 2017 02:00:38 +0800
Message-ID: <6de1d6c151813c84f3dcb56dbb45bf533a43fc90.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
 <162aa3d0e82a2224ea08f2adc8bf4c0eb99b5cac.1484934853.git.lucien.xin@gmail.com>
 <94a2321ec900105a1e4822a2489dd4fd20a37ca4.1484934853.git.lucien.xin@gmail.com>
 <ae54d06e442d8fba6a5983fb81fb4c8ae4bee3ef.1484934853.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35517 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752670AbdATSBT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:01:19 -0500
In-Reply-To: <ae54d06e442d8fba6a5983fb81fb4c8ae4bee3ef.1484934853.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to define Add Incoming/Outgoing Streams Request
Parameter described in rfc6525 section 4.5 and 4.6. They can
be in one same chunk trunk as rfc6525 section 3.1-7 describes,
so make them in one function.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  7 +++++++
 include/net/sctp/sm.h    |  3 +++
 net/sctp/sm_make_chunk.c | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 56 insertions(+)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 95b8ed3..f1f494f 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -742,4 +742,11 @@ struct sctp_strreset_tsnreq {
 	__u32 request_seq;
 } __packed;
 
+struct sctp_strreset_addstrm {
+	sctp_paramhdr_t param_hdr;
+	__u32 request_seq;
+	__u16 number_of_streams;
+	__u16 reserved;
+} __packed;
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ac37c17..3675fde 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -267,6 +267,9 @@ struct sctp_chunk *sctp_make_strreset_req(
 				bool out, bool in);
 struct sctp_chunk *sctp_make_strreset_tsnreq(
 				const struct sctp_association *asoc);
+struct sctp_chunk *sctp_make_strreset_addstrm(
+				const struct sctp_association *asoc,
+				__u16 out, __u16 in);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 801450c..a44546d 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3689,3 +3689,49 @@ struct sctp_chunk *sctp_make_strreset_tsnreq(
 
 	return retval;
 }
+
+/* RE-CONFIG 4.5/4.6 (ADD STREAM)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 17       |      Parameter Length = 12    |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |          Re-configuration Request Sequence Number             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |      Number of new streams    |         Reserved              |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct sctp_chunk *sctp_make_strreset_addstrm(
+				const struct sctp_association *asoc,
+				__u16 out, __u16 in)
+{
+	struct sctp_strreset_addstrm addstrm;
+	__u16 size = sizeof(addstrm);
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_reconf(asoc, (!!out + !!in) * size);
+	if (!retval)
+		return NULL;
+
+	if (out) {
+		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_OUT_STREAMS;
+		addstrm.param_hdr.length = htons(size);
+		addstrm.number_of_streams = htons(out);
+		addstrm.request_seq = htonl(asoc->strreset_outseq);
+		addstrm.reserved = 0;
+
+		sctp_addto_chunk(retval, size, &addstrm);
+	}
+
+	if (in) {
+		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_IN_STREAMS;
+		addstrm.param_hdr.length = htons(size);
+		addstrm.number_of_streams = htons(in);
+		addstrm.request_seq = htonl(asoc->strreset_outseq + !!out);
+		addstrm.reserved = 0;
+
+		sctp_addto_chunk(retval, size, &addstrm);
+	}
+
+	return retval;
+}
-- 
2.1.0
