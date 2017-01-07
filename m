From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 5/5] sctp: add support for generating stream reconf add streams request chunk
Date: Sat,  7 Jan 2017 17:43:02 +0800
Message-ID: <10e93a2d60d92fdda0357ba4f958c1c8b4e6f5fb.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
 <f1875fdb7c77e5f7a7fe33a1e1d2554da24901bb.1483781759.git.lucien.xin@gmail.com>
 <d218ad72dbbffebe5926c86c2e7dd04eddbd905d.1483781759.git.lucien.xin@gmail.com>
 <01d610742b62da93ccd79581e407b0aec7bc488c.1483781759.git.lucien.xin@gmail.com>
 <be9631328644431b88ba998d6234485578957156.1483781759.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33129 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941323AbdAGJnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2017 04:43:51 -0500
In-Reply-To: <be9631328644431b88ba998d6234485578957156.1483781759.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483781759.git.lucien.xin@gmail.com>
References: <cover.1483781759.git.lucien.xin@gmail.com>
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
index c4fcc7d..3a9f234 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -771,4 +771,11 @@ struct sctp_strreset_resptsn {
 	__u32 receivers_next_tsn;
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
index 013d69f..35986d0 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -272,6 +272,9 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 				struct sctp_association *asoc,
 				__u32 result, __u32 sn,
 				__u32 sender_tsn, __u32 receiver_tsn);
+struct sctp_chunk *sctp_make_strreset_addstrm(
+				const struct sctp_association *asoc,
+				__u16 out, __u16 in);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 34edb30..e6a5530 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3750,3 +3750,49 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 
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
+	__u16 length = sizeof(addstrm);
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_reconf(asoc, (!!out + !!in) * length);
+	if (!retval)
+		return NULL;
+
+	if (out) {
+		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_OUT_STREAMS;
+		addstrm.param_hdr.length = htons(length);
+		addstrm.number_of_streams = htons(out);
+		addstrm.request_seq = htonl(asoc->strreset_outseq);
+		addstrm.reserved = 0;
+
+		sctp_addto_chunk(retval, length, &addstrm);
+	}
+
+	if (in) {
+		addstrm.param_hdr.type = SCTP_PARAM_RESET_ADD_IN_STREAMS;
+		addstrm.param_hdr.length = htons(length);
+		addstrm.number_of_streams = htons(in);
+		addstrm.request_seq = htonl(asoc->strreset_outseq + !!out);
+		addstrm.reserved = 0;
+
+		sctp_addto_chunk(retval, length, &addstrm);
+	}
+
+	return retval;
+}
-- 
2.1.0
