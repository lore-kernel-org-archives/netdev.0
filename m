From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 16/27] sctp: add rfc6525 section 5.1.5-5.1.6 and 6.3.4
Date: Sun,  1 Jan 2017 19:20:33 +0800
Message-ID: <86b68f131d286ee20781cb04ce9d09d477aa5232.1483269426.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34802 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:01 -0500
In-Reply-To: <ef7d01cf1d5826e694a08303ee0b36c00201c666.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Sender-Side Procedures for the Add
Outgoing and Incoming Streams Request Parameter described in
5.1.5-5.1.6.

It is also to add sockopt SCTP_ADD_STREAMS in section 6.3.4
for users.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/uapi/linux/sctp.h |   7 +++
 net/sctp/socket.c         | 114 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+)

diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index c1c77c8..4401a40 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -119,6 +119,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
 #define SCTP_RESET_ASSOC	120
+#define SCTP_ADD_STREAMS	121
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -1028,4 +1029,10 @@ struct sctp_reset_streams {
 	uint16_t srs_stream_list[];	/* list if srs_num_streams is not 0 */
 };
 
+struct sctp_add_streams {
+	sctp_assoc_t sas_assoc_id;
+	uint16_t sas_instrms;
+	uint16_t sas_outstrms;
+};
+
 #endif /* _UAPI_SCTP_H */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bcefc55..a4e8aac 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3968,6 +3968,117 @@ static int sctp_setsockopt_reset_assoc(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_add_streams(struct sock *sk,
+				       char __user *optval,
+				       unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	struct sctp_chunk *chunk = NULL;
+	struct sctp_add_streams params;
+	int retval = -EINVAL;
+	__u16 out, in;
+
+	if (optlen != sizeof(params))
+		goto out;
+
+	if (copy_from_user(&params, optval, optlen)) {
+		retval = -EFAULT;
+		goto out;
+	}
+
+	asoc = sctp_id2assoc(sk, params.sas_assoc_id);
+	if (!asoc)
+		goto out;
+
+	if (!asoc->peer.reconf_capable ||
+	    !(asoc->strreset_enable & SCTP_ENABLE_CHANGE_ASSOC_REQ)) {
+		retval = -ENOPROTOOPT;
+		goto out;
+	}
+
+	if (asoc->strreset_outstanding) {
+		retval = -EINPROGRESS;
+		goto out;
+	}
+
+	out = params.sas_outstrms;
+	in  = params.sas_instrms;
+
+	if (!out && !in)
+		goto out;
+
+	if (out) {
+		__u16 nums = asoc->streamoutcnt + out;
+
+		/* Check for overflow, can't use nums here */
+		if (asoc->streamoutcnt + out > SCTP_MAX_STREAM)
+			goto out;
+
+		/* Use ksize to check if stream array really needs to realloc */
+		if (ksize(asoc->streamout) / sizeof(*asoc->streamout) < nums) {
+			struct sctp_stream_out *streamout;
+
+			streamout = kcalloc(nums, sizeof(*streamout),
+					    GFP_KERNEL);
+			if (!streamout) {
+				retval = -ENOMEM;
+				goto out;
+			}
+
+			memcpy(streamout, asoc->streamout,
+			       sizeof(*streamout) * asoc->streamoutcnt);
+
+			kfree(asoc->streamout);
+			asoc->streamout = streamout;
+		}
+
+		asoc->streamoutcnt = nums;
+	}
+
+	if (in) {
+		__u16 nums = asoc->streamincnt + in;
+
+		if (asoc->streamincnt + in > SCTP_MAX_STREAM)
+			goto out;
+
+		if (ksize(asoc->streamin) / sizeof(*asoc->streamin) < nums) {
+			struct sctp_stream_in *streamin;
+
+			streamin = kcalloc(nums, sizeof(*streamin),
+					   GFP_KERNEL);
+			if (!streamin) {
+				retval = -ENOMEM;
+				goto out;
+			}
+
+			memcpy(streamin, asoc->streamin,
+			       sizeof(*streamin) * asoc->streamincnt);
+
+			kfree(asoc->streamin);
+			asoc->streamin = streamin;
+		}
+
+		asoc->streamincnt = nums;
+	}
+
+	chunk = sctp_make_strreset_addstrm(asoc, out, in);
+	if (!chunk)
+		goto out;
+
+	asoc->strreset_outstanding = !!out + !!in;
+	asoc->strreset_chunk = chunk;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	retval = sctp_send_reconf(asoc, chunk);
+	if (retval) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+	}
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -4146,6 +4257,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RESET_ASSOC:
 		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
 		break;
+	case SCTP_ADD_STREAMS:
+		retval = sctp_setsockopt_add_streams(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
