From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next 7/7] sctp: implement sender-side procedures for SSN Reset Request Parameter
Date: Sat, 14 Jan 2017 03:15:41 +0800
Message-ID: <8946e750e4097c5017bb28dff0914a38e703c29f.1484334002.git.lucien.xin@gmail.com>
References: <cover.1484334002.git.lucien.xin@gmail.com>
 <5f8a7d818b5db99f2ff2a791a451b311c09fad7f.1484334002.git.lucien.xin@gmail.com>
 <6c991b81f4a92cec3da773bae9b19e878e810c88.1484334002.git.lucien.xin@gmail.com>
 <c0d647fad638de6623db1d1277f63dd4a52d28c4.1484334002.git.lucien.xin@gmail.com>
 <05371aa8e63a160f467f3463749431dadcd30a8b.1484334002.git.lucien.xin@gmail.com>
 <1277c93e5816c40893ceb6441b7c8151de48bf31.1484334002.git.lucien.xin@gmail.com>
 <d2cae903bc3512af1ff9a993b156e3d08973af87.1484334002.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35668 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdAMTQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 14:16:45 -0500
In-Reply-To: <d2cae903bc3512af1ff9a993b156e3d08973af87.1484334002.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484334002.git.lucien.xin@gmail.com>
References: <cover.1484334002.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement sender-side procedures for the Outgoing
and Incoming SSN Reset Request Parameter described in rfc6525 section
5.1.2 and 5.1.3.

It is also add sockopt SCTP_RESET_STREAMS in rfc6525 section 6.3.2
for users.

Note that the new asoc member strreset_outstanding is to make sure
only one reconf request chunk on the fly as rfc6525 section 5.1.1
demands.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    |  6 ++++
 include/net/sctp/structs.h |  1 +
 include/uapi/linux/sctp.h  | 11 +++++++
 net/sctp/outqueue.c        | 33 +++++++++++++------
 net/sctp/socket.c          | 29 +++++++++++++++++
 net/sctp/stream.c          | 79 ++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 149 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index bc0e049..3cfd365b 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -194,6 +194,12 @@ void sctp_remaddr_proc_exit(struct net *net);
 int sctp_offload_init(void);
 
 /*
+ * sctp/stream.c
+ */
+int sctp_send_reset_streams(struct sctp_association *asoc,
+			    struct sctp_reset_streams *params);
+
+/*
  * Module global variables
  */
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index d99b76e..231fa9ac 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1875,6 +1875,7 @@ struct sctp_association {
 	     reconf_enable:1;
 
 	__u8 strreset_enable;
+	__u8 strreset_outstanding; /* request param count on the fly */
 
 	__u32 strreset_outseq; /* Update after receiving response */
 	__u32 strreset_inseq; /* Update after receiving request */
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 867be0f..03c27ce 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -116,6 +116,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_DEFAULT_PRINFO	114
 #define SCTP_PR_ASSOC_STATUS	115
 #define SCTP_ENABLE_STREAM_RESET	118
+#define SCTP_RESET_STREAMS	119
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -145,6 +146,9 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_ENABLE_CHANGE_ASSOC_REQ	0x04
 #define SCTP_ENABLE_STRRESET_MASK	0x07
 
+#define SCTP_STREAM_RESET_INCOMING	0x01
+#define SCTP_STREAM_RESET_OUTGOING	0x02
+
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
 enum sctp_msg_flags {
@@ -1015,4 +1019,11 @@ struct sctp_info {
 	__u32	__reserved3;
 };
 
+struct sctp_reset_streams {
+	sctp_assoc_t srs_assoc_id;
+	uint16_t srs_flags;
+	uint16_t srs_number_streams;	/* 0 == ALL */
+	uint16_t srs_stream_list[];	/* list if srs_num_streams is not 0 */
+};
+
 #endif /* _UAPI_SCTP_H */
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index 34efaa4..65abe22 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -915,22 +915,28 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 		case SCTP_CID_ECN_ECNE:
 		case SCTP_CID_ASCONF:
 		case SCTP_CID_FWD_TSN:
+		case SCTP_CID_RECONF:
 			status = sctp_packet_transmit_chunk(packet, chunk,
 							    one_packet, gfp);
 			if (status  != SCTP_XMIT_OK) {
 				/* put the chunk back */
 				list_add(&chunk->list, &q->control_chunk_list);
-			} else {
-				asoc->stats.octrlchunks++;
-				/* PR-SCTP C5) If a FORWARD TSN is sent, the
-				 * sender MUST assure that at least one T3-rtx
-				 * timer is running.
-				 */
-				if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN) {
-					sctp_transport_reset_t3_rtx(transport);
-					transport->last_time_sent = jiffies;
-				}
+				break;
+			}
+
+			asoc->stats.octrlchunks++;
+			/* PR-SCTP C5) If a FORWARD TSN is sent, the
+			 * sender MUST assure that at least one T3-rtx
+			 * timer is running.
+			 */
+			if (chunk->chunk_hdr->type == SCTP_CID_FWD_TSN) {
+				sctp_transport_reset_t3_rtx(transport);
+				transport->last_time_sent = jiffies;
 			}
+
+			if (chunk == asoc->strreset_chunk)
+				sctp_transport_reset_reconf_timer(transport);
+
 			break;
 
 		default:
@@ -1016,6 +1022,8 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 
 		/* Finally, transmit new packets.  */
 		while ((chunk = sctp_outq_dequeue_data(q)) != NULL) {
+			__u32 sid = ntohs(chunk->subh.data_hdr->stream);
+
 			/* RFC 2960 6.5 Every DATA chunk MUST carry a valid
 			 * stream identifier.
 			 */
@@ -1038,6 +1046,11 @@ static void sctp_outq_flush(struct sctp_outq *q, int rtx_timeout, gfp_t gfp)
 				continue;
 			}
 
+			if (asoc->stream->out[sid].state == SCTP_STREAM_CLOSED) {
+				sctp_outq_head_data(q, chunk);
+				goto sctp_flush_out;
+			}
+
 			/* If there is a specified transport, use it.
 			 * Otherwise, we want to use the active path.
 			 */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index ae07db4..e072bf7 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3787,6 +3787,32 @@ static int sctp_setsockopt_enable_strreset(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_reset_streams(struct sock *sk,
+					 char __user *optval,
+					 unsigned int optlen)
+{
+	struct sctp_reset_streams *params;
+	struct sctp_association *asoc;
+	int retval = -EINVAL;
+
+	if (optlen < sizeof(struct sctp_reset_streams))
+		return -EINVAL;
+
+	params = memdup_user(optval, optlen);
+	if (IS_ERR(params))
+		return PTR_ERR(params);
+
+	asoc = sctp_id2assoc(sk, params->srs_assoc_id);
+	if (!asoc)
+		goto out;
+
+	retval = sctp_send_reset_streams(asoc, params);
+
+out:
+	kfree(params);
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3956,6 +3982,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_ENABLE_STREAM_RESET:
 		retval = sctp_setsockopt_enable_strreset(sk, optval, optlen);
 		break;
+	case SCTP_RESET_STREAMS:
+		retval = sctp_setsockopt_reset_streams(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
index f86de43..13d5e07 100644
--- a/net/sctp/stream.c
+++ b/net/sctp/stream.c
@@ -33,6 +33,7 @@
  */
 
 #include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
 
 struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp)
 {
@@ -83,3 +84,81 @@ void sctp_stream_clear(struct sctp_stream *stream)
 	for (i = 0; i < stream->incnt; i++)
 		stream->in[i].ssn = 0;
 }
+
+static int sctp_send_reconf(struct sctp_association *asoc,
+			    struct sctp_chunk *chunk)
+{
+	struct net *net = sock_net(asoc->base.sk);
+	int retval = 0;
+
+	retval = sctp_primitive_RECONF(net, asoc, chunk);
+	if (retval)
+		sctp_chunk_free(chunk);
+
+	return retval;
+}
+
+int sctp_send_reset_streams(struct sctp_association *asoc,
+			    struct sctp_reset_streams *params)
+{
+	struct sctp_stream *stream = asoc->stream;
+	__u16 i, str_nums, *str_list;
+	struct sctp_chunk *chunk;
+	int retval = -EINVAL;
+	bool out, in;
+
+	if (!asoc->peer.reconf_capable ||
+	    !(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ)) {
+		retval = -ENOPROTOOPT;
+		goto out;
+	}
+
+	if (asoc->strreset_outstanding) {
+		retval = -EINPROGRESS;
+		goto out;
+	}
+
+	out = params->srs_flags & SCTP_STREAM_RESET_OUTGOING;
+	in  = params->srs_flags & SCTP_STREAM_RESET_INCOMING;
+	if (!out && !in)
+		goto out;
+
+	str_nums = params->srs_number_streams;
+	str_list = params->srs_stream_list;
+	if (out && str_nums)
+		for (i = 0; i < str_nums; i++)
+			if (str_list[i] >= stream->outcnt)
+				goto out;
+
+	if (in && str_nums)
+		for (i = 0; i < str_nums; i++)
+			if (str_list[i] >= stream->incnt)
+				goto out;
+
+	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
+	if (!chunk)
+		goto out;
+
+	if (out) {
+		if (str_nums)
+			for (i = 0; i < str_nums; i++)
+				stream->out[str_list[i]].state =
+						       SCTP_STREAM_CLOSED;
+		else
+			for (i = 0; i < stream->outcnt; i++)
+				stream->out[i].state = SCTP_STREAM_CLOSED;
+	}
+
+	asoc->strreset_outstanding = out + in;
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
-- 
2.1.0
