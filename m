From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv4 net-next 1/6] sctp: add support for generating stream reconf ssn reset request chunk
Date: Wed, 18 Jan 2017 00:44:42 +0800
Message-ID: <eff824eb34c55a83e35334597e6d510a5dde3ce6.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34140 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdAQQph (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 11:45:37 -0500
In-Reply-To: <cover.1484670664.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1484670664.git.lucien.xin@gmail.com>
References: <cover.1484670664.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add asoc strreset_outseq and strreset_inseq for
saving the reconf request sequence, initialize them when create
assoc and process init, and also to define Incoming and Outgoing
SSN Reset Request Parameter described in rfc6525 section 4.1 and
4.2, As they can be in one same chunk as section rfc6525 3.1-3
describes, it makes them in one function.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h       |  27 ++++++++++
 include/net/sctp/sm.h      |   5 +-
 include/net/sctp/structs.h |   3 ++
 net/sctp/associola.c       |   1 +
 net/sctp/sm_make_chunk.c   | 121 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 156 insertions(+), 1 deletion(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index fcb4c36..a9e7906 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -108,6 +108,7 @@ typedef enum {
 	/* Use hex, as defined in ADDIP sec. 3.1 */
 	SCTP_CID_ASCONF			= 0xC1,
 	SCTP_CID_ASCONF_ACK		= 0x80,
+	SCTP_CID_RECONF			= 0x82,
 } sctp_cid_t; /* enum */
 
 
@@ -199,6 +200,13 @@ typedef enum {
 	SCTP_PARAM_SUCCESS_REPORT	= cpu_to_be16(0xc005),
 	SCTP_PARAM_ADAPTATION_LAYER_IND = cpu_to_be16(0xc006),
 
+	/* RE-CONFIG. Section 4 */
+	SCTP_PARAM_RESET_OUT_REQUEST		= cpu_to_be16(0x000d),
+	SCTP_PARAM_RESET_IN_REQUEST		= cpu_to_be16(0x000e),
+	SCTP_PARAM_RESET_TSN_REQUEST		= cpu_to_be16(0x000f),
+	SCTP_PARAM_RESET_RESPONSE		= cpu_to_be16(0x0010),
+	SCTP_PARAM_RESET_ADD_OUT_STREAMS	= cpu_to_be16(0x0011),
+	SCTP_PARAM_RESET_ADD_IN_STREAMS		= cpu_to_be16(0x0012),
 } sctp_param_t; /* enum */
 
 
@@ -710,4 +718,23 @@ struct sctp_infox {
 	struct sctp_association *asoc;
 };
 
+struct sctp_reconf_chunk {
+	sctp_chunkhdr_t chunk_hdr;
+	__u8 params[0];
+} __packed;
+
+struct sctp_strreset_outreq {
+	sctp_paramhdr_t param_hdr;
+	__u32 request_seq;
+	__u32 response_seq;
+	__u32 send_reset_at_tsn;
+	__u16 list_of_streams[0];
+} __packed;
+
+struct sctp_strreset_inreq {
+	sctp_paramhdr_t param_hdr;
+	__u32 request_seq;
+	__u16 list_of_streams[0];
+} __packed;
+
 #endif /* __LINUX_SCTP_H__ */
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index ca6c971..3462cb0 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -259,7 +259,10 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 				    __u32 new_cum_tsn, size_t nstreams,
 				    struct sctp_fwdtsn_skip *skiplist);
 struct sctp_chunk *sctp_make_auth(const struct sctp_association *asoc);
-
+struct sctp_chunk *sctp_make_strreset_req(
+				const struct sctp_association *asoc,
+				__u16 stream_num, __u16 *stream_list,
+				bool out, bool in);
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 4741ec2..3dc983e 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -1865,6 +1865,9 @@ struct sctp_association {
 	     temp:1,		/* Is it a temporary association? */
 	     prsctp_enable:1;
 
+	__u32 strreset_outseq; /* Update after receiving response */
+	__u32 strreset_inseq; /* Update after receiving request */
+
 	struct sctp_priv_assoc_stats stats;
 
 	int sent_cnt_removable;
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 36294f7..42ece6f 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -207,6 +207,7 @@ static struct sctp_association *sctp_association_init(struct sctp_association *a
 	 * association to the same value as the initial TSN.
 	 */
 	asoc->addip_serial = asoc->c.initial_tsn;
+	asoc->strreset_outseq = asoc->c.initial_tsn;
 
 	INIT_LIST_HEAD(&asoc->addip_chunk_list);
 	INIT_LIST_HEAD(&asoc->asconf_ack_list);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index a15d824..172385c 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1844,6 +1844,7 @@ struct sctp_association *sctp_unpack_cookie(
 	retval->next_tsn = retval->c.initial_tsn;
 	retval->ctsn_ack_point = retval->next_tsn - 1;
 	retval->addip_serial = retval->c.initial_tsn;
+	retval->strreset_outseq = retval->c.initial_tsn;
 	retval->adv_peer_ack_point = retval->ctsn_ack_point;
 	retval->peer.prsctp_capable = retval->c.prsctp_capable;
 	retval->peer.adaptation_ind = retval->c.adaptation_ind;
@@ -2387,6 +2388,8 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	asoc->peer.i.initial_tsn =
 		ntohl(peer_init->init_hdr.initial_tsn);
 
+	asoc->strreset_inseq = asoc->peer.i.initial_tsn;
+
 	/* Apply the upper bounds for output streams based on peer's
 	 * number of inbound streams.
 	 */
@@ -3526,3 +3529,121 @@ struct sctp_chunk *sctp_make_fwdtsn(const struct sctp_association *asoc,
 
 	return retval;
 }
+
+/* RE-CONFIG 3.1 (RE-CONFIG chunk)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  | Type = 130    |  Chunk Flags  |      Chunk Length             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  \                                                               \
+ *  /                  Re-configuration Parameter                   /
+ *  \                                                               \
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  \                                                               \
+ *  /             Re-configuration Parameter (optional)             /
+ *  \                                                               \
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+static struct sctp_chunk *sctp_make_reconf(
+				const struct sctp_association *asoc,
+				int length)
+{
+	struct sctp_reconf_chunk *reconf;
+	struct sctp_chunk *retval;
+
+	retval = sctp_make_control(asoc, SCTP_CID_RECONF, 0, length,
+				   GFP_ATOMIC);
+	if (!retval)
+		return NULL;
+
+	reconf = (struct sctp_reconf_chunk *)retval->chunk_hdr;
+	retval->param_hdr.v = reconf->params;
+
+	return retval;
+}
+
+/* RE-CONFIG 4.1 (STREAM OUT RESET)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 13       | Parameter Length = 16 + 2 * N |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |           Re-configuration Request Sequence Number            |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |           Re-configuration Response Sequence Number           |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |                Sender's Last Assigned TSN                     |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |  Stream Number 1 (optional)   |    Stream Number 2 (optional) |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  /                            ......                             /
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |  Stream Number N-1 (optional) |    Stream Number N (optional) |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ * RE-CONFIG 4.2 (STREAM IN RESET)
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |     Parameter Type = 14       |  Parameter Length = 8 + 2 * N |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |          Re-configuration Request Sequence Number             |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |  Stream Number 1 (optional)   |    Stream Number 2 (optional) |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  /                            ......                             /
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |  Stream Number N-1 (optional) |    Stream Number N (optional) |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct sctp_chunk *sctp_make_strreset_req(
+				const struct sctp_association *asoc,
+				__u16 stream_num, __u16 *stream_list,
+				bool out, bool in)
+{
+	struct sctp_strreset_outreq outreq;
+	__u16 stream_len = stream_num * 2;
+	struct sctp_strreset_inreq inreq;
+	struct sctp_chunk *retval;
+	__u16 outlen, inlen, i;
+
+	outlen = (sizeof(outreq) + stream_len) * out;
+	inlen = (sizeof(inreq) + stream_len) * in;
+
+	retval = sctp_make_reconf(asoc, outlen + inlen);
+	if (!retval)
+		return NULL;
+
+	for (i = 0; i < stream_num; i++)
+		stream_list[i] = htons(stream_list[i]);
+
+	if (outlen) {
+		outreq.param_hdr.type = SCTP_PARAM_RESET_OUT_REQUEST;
+		outreq.param_hdr.length = htons(outlen);
+		outreq.request_seq = htonl(asoc->strreset_outseq);
+		outreq.response_seq = htonl(asoc->strreset_inseq - 1);
+		outreq.send_reset_at_tsn = htonl(asoc->next_tsn - 1);
+
+		sctp_addto_chunk(retval, sizeof(outreq), &outreq);
+
+		if (stream_len)
+			sctp_addto_chunk(retval, stream_len, stream_list);
+	}
+
+	if (inlen) {
+		inreq.param_hdr.type = SCTP_PARAM_RESET_IN_REQUEST;
+		inreq.param_hdr.length = htons(inlen);
+		inreq.request_seq = htonl(asoc->strreset_outseq + out);
+
+		sctp_addto_chunk(retval, sizeof(inreq), &inreq);
+
+		if (stream_len)
+			sctp_addto_chunk(retval, stream_len, stream_list);
+	}
+
+	for (i = 0; i < stream_num; i++)
+		stream_list[i] = ntohs(stream_list[i]);
+
+	return retval;
+}
-- 
2.1.0
