From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 5/7] sctp: add a function to verify the sctp reconf chunk
Date: Fri, 17 Feb 2017 12:45:41 +0800
Message-ID: <c90e5eac92a42c0d9ab69f7362fc6debf5512bad.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
 <f01759c2f5ab1be572d95480d6d4e7e94431d2b8.1487306585.git.lucien.xin@gmail.com>
 <3ee883ca4dd0ef75baa9ca5bfd9642d28160c10b.1487306585.git.lucien.xin@gmail.com>
 <07abdfdccbb39c94418b7a7887e82c5c12adf0c7.1487306585.git.lucien.xin@gmail.com>
 <3b70615422bf6d43013332d4b37c70160a0c1d32.1487306585.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34440 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbdBQEqd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 23:46:33 -0500
In-Reply-To: <3b70615422bf6d43013332d4b37c70160a0c1d32.1487306585.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1487306585.git.lucien.xin@gmail.com>
References: <cover.1487306585.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add a function sctp_verify_reconf to do some length
check and multi-params check for sctp stream reconf according to rfc6525
section 3.1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h    |  3 +++
 net/sctp/sm_make_chunk.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 62 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index f6a828d..ca9fbfb 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -277,6 +277,9 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 				struct sctp_association *asoc,
 				__u32 result, __u32 sn,
 				__u32 sender_tsn, __u32 receiver_tsn);
+bool sctp_verify_reconf(const struct sctp_association *asoc,
+			struct sctp_chunk *chunk,
+			struct sctp_paramhdr **errp);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 60d9fdc..969a30c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -3801,3 +3801,62 @@ struct sctp_chunk *sctp_make_strreset_tsnresp(
 
 	return retval;
 }
+
+bool sctp_verify_reconf(const struct sctp_association *asoc,
+			struct sctp_chunk *chunk,
+			struct sctp_paramhdr **errp)
+{
+	struct sctp_reconf_chunk *hdr;
+	union sctp_params param;
+	__u16 last = 0, cnt = 0;
+
+	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
+	sctp_walk_params(param, hdr, params) {
+		__u16 length = ntohs(param.p->length);
+
+		*errp = param.p;
+		if (cnt++ > 2)
+			return false;
+		switch (param.p->type) {
+		case SCTP_PARAM_RESET_OUT_REQUEST:
+			if (length < sizeof(struct sctp_strreset_outreq) ||
+			    (last && last != SCTP_PARAM_RESET_RESPONSE &&
+			     last != SCTP_PARAM_RESET_IN_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_IN_REQUEST:
+			if (length < sizeof(struct sctp_strreset_inreq) ||
+			    (last && last != SCTP_PARAM_RESET_OUT_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_RESPONSE:
+			if ((length != sizeof(struct sctp_strreset_resp) &&
+			     length != sizeof(struct sctp_strreset_resptsn)) ||
+			    (last && last != SCTP_PARAM_RESET_RESPONSE &&
+			     last != SCTP_PARAM_RESET_OUT_REQUEST))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_TSN_REQUEST:
+			if (length !=
+			    sizeof(struct sctp_strreset_tsnreq) || last)
+				return false;
+			break;
+		case SCTP_PARAM_RESET_ADD_IN_STREAMS:
+			if (length != sizeof(struct sctp_strreset_addstrm) ||
+			    (last && last != SCTP_PARAM_RESET_ADD_OUT_STREAMS))
+				return false;
+			break;
+		case SCTP_PARAM_RESET_ADD_OUT_STREAMS:
+			if (length != sizeof(struct sctp_strreset_addstrm) ||
+			    (last && last != SCTP_PARAM_RESET_ADD_IN_STREAMS))
+				return false;
+			break;
+		default:
+			return false;
+		}
+
+		last = param.p->type;
+	}
+
+	return true;
+}
-- 
2.1.0
