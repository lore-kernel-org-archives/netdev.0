From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 23/27] sctp: add rfc6525 section 5.2.5
Date: Sun,  1 Jan 2017 19:20:40 +0800
Message-ID: <105630d2f9a54de9c3ce49988452d2b111c71b3d.1483269426.git.lucien.xin@gmail.com>
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
 <c59df697bb54348de10f8418a23e9d14bce30135.1483269426.git.lucien.xin@gmail.com>
 <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35530 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALX4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:56 -0500
In-Reply-To: <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add Receiver-Side Procedures for the Add Outgoing
Streams Request Parameter described in section 5.2.5.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |  4 ++++
 net/sctp/stream.c     | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index e1b2509..5624b52 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -293,6 +293,10 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 				struct sctp_association *asoc,
 				union sctp_params param,
 				struct sctp_ulpevent **evp);
+struct sctp_chunk *sctp_process_strreset_addstrm_out(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
 
 /* Prototypes for statetable processing. */
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index fce4317..b51a037 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -283,3 +283,59 @@ struct sctp_chunk *sctp_process_strreset_tsnreq(
 	return sctp_make_strreset_tsnresp(asoc, result, request_seq,
 					  asoc->next_tsn, initial_tsn);
 }
+
+struct sctp_chunk *sctp_process_strreset_addstrm_out(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_addstrm *addstrm = param.v;
+	__u32 result = SCTP_STRRESET_DENIED;
+	__u32 request_seq;
+	__u16 nums;
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
+	nums = ntohs(addstrm->number_of_streams);
+	if (!nums || nums + asoc->streamincnt > SCTP_MAX_STREAM)
+		goto out;
+
+	nums = nums + asoc->streamincnt;
+	if (ksize(asoc->streamin) / sizeof(*asoc->streamin) < nums) {
+		struct sctp_stream_in *streamin;
+
+		streamin = kcalloc(nums, sizeof(*streamin), GFP_ATOMIC);
+		if (!streamin)
+			goto out;
+
+		memcpy(streamin, asoc->streamin,
+		       sizeof(*streamin) * asoc->streamincnt);
+
+		kfree(asoc->streamin);
+		asoc->streamin = streamin;
+	}
+
+	asoc->streamincnt = nums;
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_stream_change_event(asoc,
+		0, ntohs(addstrm->number_of_streams), 0, GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_resp(asoc, result, request_seq);
+}
-- 
2.1.0
