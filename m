From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 5/5] sctp: implement sender-side procedures for Add Incoming/Outgoing Streams Request Parameter
Date: Sat, 21 Jan 2017 02:00:39 +0800
Message-ID: <5fc351de55b7996d3252b74831c5717e40b7c6e1.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
 <162aa3d0e82a2224ea08f2adc8bf4c0eb99b5cac.1484934853.git.lucien.xin@gmail.com>
 <94a2321ec900105a1e4822a2489dd4fd20a37ca4.1484934853.git.lucien.xin@gmail.com>
 <ae54d06e442d8fba6a5983fb81fb4c8ae4bee3ef.1484934853.git.lucien.xin@gmail.com>
 <6de1d6c151813c84f3dcb56dbb45bf533a43fc90.1484934853.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33420 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752854AbdATSB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 13:01:27 -0500
In-Reply-To: <6de1d6c151813c84f3dcb56dbb45bf533a43fc90.1484934853.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484934853.git.lucien.xin@gmail.com>
References: <cover.1484934853.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Sender-Side Procedures for the Add
Outgoing and Incoming Streams Request Parameter described in
rfc6525 section 5.1.5-5.1.6.

It is also to add sockopt SCTP_ADD_STREAMS in rfc6525 section
6.3.4 for users.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h   |  2 ++
 include/uapi/linux/sctp.h |  7 ++++
 net/sctp/socket.c         | 29 +++++++++++++++++
 net/sctp/stream.c         | 81 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 119 insertions(+)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b93820f..68ee1a6 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -199,6 +199,8 @@ int sctp_offload_init(void);
 int sctp_send_reset_streams(struct sctp_association *asoc,
 			    struct sctp_reset_streams *params);
 int sctp_send_reset_assoc(struct sctp_association *asoc);
+int sctp_send_add_streams(struct sctp_association *asoc,
+			  struct sctp_add_streams *params);
 
 /*
  * Module global variables
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index c0bd8c3..a91a9cc 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -118,6 +118,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_ENABLE_STREAM_RESET	118
 #define SCTP_RESET_STREAMS	119
 #define SCTP_RESET_ASSOC	120
+#define SCTP_ADD_STREAMS	121
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -1027,4 +1028,10 @@ struct sctp_reset_streams {
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
index 2c5c9ca..ae0a99e 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3838,6 +3838,32 @@ static int sctp_setsockopt_reset_assoc(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_add_streams(struct sock *sk,
+				       char __user *optval,
+				       unsigned int optlen)
+{
+	struct sctp_association *asoc;
+	struct sctp_add_streams params;
+	int retval = -EINVAL;
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
+	retval = sctp_send_add_streams(asoc, &params);
+
+out:
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -4013,6 +4039,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_RESET_ASSOC:
 		retval = sctp_setsockopt_reset_assoc(sk, optval, optlen);
 		break;
+	case SCTP_ADD_STREAMS:
+		retval = sctp_setsockopt_add_streams(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index 3b872a8..cb255e6 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -203,3 +203,84 @@ int sctp_send_reset_assoc(struct sctp_association *asoc)
 
 	return 0;
 }
+
+int sctp_send_add_streams(struct sctp_association *asoc,
+			  struct sctp_add_streams *params)
+{
+	struct sctp_stream *stream = asoc->stream;
+	struct sctp_chunk *chunk = NULL;
+	int retval = -ENOMEM;
+	__u16 out, in, nums;
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
+	out = params->sas_outstrms;
+	in  = params->sas_instrms;
+	if (stream->outcnt + out > SCTP_MAX_STREAM ||
+	    stream->incnt + in > SCTP_MAX_STREAM || (!out && !in)) {
+		retval = -EINVAL;
+		goto out;
+	}
+
+	nums = stream->outcnt + out;
+	/* Use ksize to check if stream array really needs to realloc */
+	if (out && ksize(stream->out) < nums * sizeof(*stream->out)) {
+		struct sctp_stream_out *streamout;
+
+		streamout = kcalloc(nums, sizeof(*streamout), GFP_KERNEL);
+		if (!streamout)
+			goto out;
+
+		memcpy(streamout, stream->out,
+		       sizeof(*streamout) * stream->outcnt);
+
+		kfree(stream->out);
+		stream->out = streamout;
+	}
+
+	nums = stream->incnt + in;
+	if (in && ksize(stream->in) < nums * sizeof(*stream->in)) {
+		struct sctp_stream_in *streamin;
+
+		streamin = kcalloc(nums, sizeof(*streamin), GFP_KERNEL);
+		if (!streamin)
+			goto out;
+
+		memcpy(streamin, stream->in,
+		       sizeof(*streamin) * stream->incnt);
+
+		kfree(stream->in);
+		stream->in = streamin;
+	}
+
+	chunk = sctp_make_strreset_addstrm(asoc, out, in);
+	if (!chunk)
+		goto out;
+
+	asoc->strreset_chunk = chunk;
+	sctp_chunk_hold(asoc->strreset_chunk);
+
+	retval = sctp_send_reconf(asoc, chunk);
+	if (retval) {
+		sctp_chunk_put(asoc->strreset_chunk);
+		asoc->strreset_chunk = NULL;
+		goto out;
+	}
+
+	stream->incnt += in;
+	stream->outcnt += out;
+
+	asoc->strreset_outstanding = !!out + !!in;
+
+out:
+	return retval;
+}
-- 
2.1.0
