From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 14/27] sctp: add rfc6525 section 5.1.2-5.1.3 and 6.3.2
Date: Sun,  1 Jan 2017 19:20:31 +0800
Message-ID: <6a74f5a3ac408f20816a8c79edd6b9922ed3b573.1483269426.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35251 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALWp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:22:45 -0500
In-Reply-To: <d5fb0969ea5d055dea5bdc257569530b6d2fc7c2.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement sender-side procedures for the Outgoing
and Incoming SSN Reset Request Parameter described in section 5.1.2
and 5.1.3.

It is also add sockopt SCTP_RESET_STREAMS in section 6.3.2 for users.

Note that the new asoc member strreset_outstanding is to make sure
only one reconf request chunk on the fly as section 5.1.1 demands.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/structs.h |  1 +
 include/uapi/linux/sctp.h  | 11 ++++++
 net/sctp/outqueue.c        | 33 +++++++++++-----
 net/sctp/socket.c          | 97 ++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 132 insertions(+), 10 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 56282a3..ce8985f 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1861,6 +1861,7 @@ struct sctp_association {
 	     reconf_enable:1;
 
 	__u8 strreset_enable;
+	__u8 strreset_outstanding; /* request param count on the fly */
 
 	/* stream arrays */
 	struct sctp_stream_out *streamout;
diff --git a/include/uapi/linux/sctp.h b/include/uapi/linux/sctp.h
index 950d76a..1f4518b 100644
--- a/include/uapi/linux/sctp.h
+++ b/include/uapi/linux/sctp.h
@@ -117,6 +117,7 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_PR_ASSOC_STATUS	115
 #define SCTP_RECONFIG_SUPPORTED	117
 #define SCTP_ENABLE_STREAM_RESET	118
+#define SCTP_RESET_STREAMS	119
 
 /* PR-SCTP policies */
 #define SCTP_PR_SCTP_NONE	0x0000
@@ -146,6 +147,9 @@ typedef __s32 sctp_assoc_t;
 #define SCTP_ENABLE_CHANGE_ASSOC_REQ	0x04
 #define SCTP_ENABLE_STRRESET_MASK	0x07
 
+#define SCTP_STREAM_RESET_INCOMING	0x01
+#define SCTP_STREAM_RESET_OUTGOING	0x02
+
 /* These are bit fields for msghdr->msg_flags.  See section 5.1.  */
 /* On user space Linux, these live in <bits/socket.h> as an enum.  */
 enum sctp_msg_flags {
@@ -1016,4 +1020,11 @@ struct sctp_info {
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
index e540826..5d668c9 100644
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
 
+			if (asoc->streamout[sid].state == SCTP_STREAM_CLOSED) {
+				sctp_outq_head_data(q, chunk);
+				goto sctp_flush_out;
+			}
+
 			/* If there is a specified transport, use it.
 			 * Otherwise, we want to use the active path.
 			 */
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 3cae585..e62872c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -434,6 +434,19 @@ static int sctp_send_asconf(struct sctp_association *asoc,
 	return retval;
 }
 
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
 /* Add a list of addresses as bind addresses to local endpoint or
  * association.
  *
@@ -3820,6 +3833,87 @@ static int sctp_setsockopt_enable_strreset(struct sock *sk,
 	return retval;
 }
 
+static int sctp_setsockopt_reset_streams(struct sock *sk,
+					 char __user *optval,
+					 unsigned int optlen)
+{
+	struct sctp_reset_streams *params;
+	struct sctp_association *asoc;
+	struct sctp_chunk *chunk = NULL;
+	__u16 i, str_nums, *str_list;
+	int retval = -EINVAL;
+	bool out, in;
+
+	if (optlen < sizeof(struct sctp_reset_streams))
+		return -EINVAL;
+
+	params = memdup_user(optval, optlen);
+	if (IS_ERR(params)) {
+		retval = PTR_ERR(params);
+		goto out;
+	}
+
+	asoc = sctp_id2assoc(sk, params->srs_assoc_id);
+	if (!asoc)
+		goto out;
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
+			if (str_list[i] >= asoc->streamoutcnt)
+				goto out;
+
+	if (in && str_nums)
+		for (i = 0; i < str_nums; i++)
+			if (str_list[i] >= asoc->streamincnt)
+				goto out;
+
+	chunk = sctp_make_strreset_req(asoc, str_nums, str_list, out, in);
+	if (!chunk)
+		goto out;
+
+	if (out) {
+		if (str_nums)
+			for (i = 0; i < str_nums; i++)
+				asoc->streamout[str_list[i]].state =
+							   SCTP_STREAM_CLOSED;
+		else
+			for (i = 0; i < asoc->streamoutcnt; i++)
+				asoc->streamout[i].state = SCTP_STREAM_CLOSED;
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
+	kfree(params);
+	return retval;
+}
+
 /* API 6.2 setsockopt(), getsockopt()
  *
  * Applications use setsockopt() and getsockopt() to set or retrieve
@@ -3992,6 +4086,9 @@ static int sctp_setsockopt(struct sock *sk, int level, int optname,
 	case SCTP_ENABLE_STREAM_RESET:
 		retval = sctp_setsockopt_enable_strreset(sk, optval, optlen);
 		break;
+	case SCTP_RESET_STREAMS:
+		retval = sctp_setsockopt_reset_streams(sk, optval, optlen);
+		break;
 	default:
 		retval = -ENOPROTOOPT;
 		break;
-- 
2.1.0
