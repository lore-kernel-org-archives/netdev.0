From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 20/27] sctp: add rfc6525 section 5.2.2
Date: Sun,  1 Jan 2017 19:20:37 +0800
Message-ID: <b5eb3a199dded2efe517b19b5cac6ae498a6c0c8.1483269426.git.lucien.xin@gmail.com>
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
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33899 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932079AbdAALXc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 06:23:32 -0500
In-Reply-To: <9be4c65c6bac7df0dbf51328af92727e5606dc5c.1483269426.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1483269426.git.lucien.xin@gmail.com>
References: <cover.1483269426.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to implement Receiver-Side Procedures for the Outgoing
SSN Reset Request Parameter described in section 5.2.2.

Note that some checks must be after request_seq check, as even those
checks fail, strreset_inseq still has to be increase by 1.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sm.h |   6 +++
 net/sctp/Makefile     |   3 +-
 net/sctp/stream.c     | 146 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 154 insertions(+), 1 deletion(-)
 create mode 100644 net/sctp/stream.c

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index bcca913..1833215 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -280,6 +280,12 @@ struct sctp_chunk *sctp_make_strreset_addstrm(
 void sctp_chunk_assign_tsn(struct sctp_chunk *);
 void sctp_chunk_assign_ssn(struct sctp_chunk *);
 
+/* Prototypes for stream-processing functions.  */
+struct sctp_chunk *sctp_process_strreset_outreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp);
+
 /* Prototypes for statetable processing. */
 
 int sctp_do_sm(struct net *net, sctp_event_t event_type, sctp_subtype_t subtype,
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 48bfc74..02d8d01 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -11,7 +11,8 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o auth.o offload.o
+	  output.o input.o debug.o auth.o offload.o \
+	  stream.o
 
 sctp_probe-y := probe.o
 
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
new file mode 100644
index 0000000..1d5b795
--- /dev/null
+++ b/net/sctp/stream.c
@@ -0,0 +1,146 @@
+/* SCTP kernel implementation
+ * (C) Copyright IBM Corp. 2001, 2004
+ * Copyright (c) 1999-2000 Cisco, Inc.
+ * Copyright (c) 1999-2001 Motorola, Inc.
+ * Copyright (c) 2001 Intel Corp.
+ *
+ * This file is part of the SCTP kernel implementation
+ *
+ * These functions manipulate sctp tsn mapping array.
+ *
+ * This SCTP implementation is free software;
+ * you can redistribute it and/or modify it under the terms of
+ * the GNU General Public License as published by
+ * the Free Software Foundation; either version 2, or (at your option)
+ * any later version.
+ *
+ * This SCTP implementation is distributed in the hope that it
+ * will be useful, but WITHOUT ANY WARRANTY; without even the implied
+ *                 ************************
+ * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
+ * See the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with GNU CC; see the file COPYING.  If not, see
+ * <http://www.gnu.org/licenses/>.
+ *
+ * Please send any bug reports or fixes you make to the
+ * email address(es):
+ *    lksctp developers <linux-sctp@vger.kernel.org>
+ *
+ * Written or modified by:
+ *    Xin Long <lucien.xin@gmail.com>
+ */
+
+#include <net/sctp/sctp.h>
+#include <net/sctp/sm.h>
+
+static struct sctp_strreset_req *sctp_chunk_lookup_strreset_param(
+			struct sctp_association *asoc, __u32 resp_seq)
+{
+	struct sctp_chunk *chunk = asoc->strreset_chunk;
+	struct sctp_reconf_chunk *hdr;
+	union sctp_params param;
+
+	if (resp_seq != asoc->strreset_outseq || !chunk)
+		return NULL;
+
+	hdr = (struct sctp_reconf_chunk *)chunk->chunk_hdr;
+	sctp_walk_params(param, hdr, params) {
+		struct sctp_strreset_req *req = param.v;
+
+		if (ntohl(req->request_seq) == resp_seq)
+			return req;
+	}
+
+	return NULL;
+}
+
+struct sctp_chunk *sctp_process_strreset_outreq(
+				struct sctp_association *asoc,
+				union sctp_params param,
+				struct sctp_ulpevent **evp)
+{
+	struct sctp_strreset_outreq *outreq = param.v;
+	__u32 result = SCTP_STRRESET_DENIED;
+	__u16 i, nums, *str_p, flags = 0;
+	__u32 request_seq;
+
+	request_seq = ntohl(outreq->request_seq);
+
+	if (ntohl(outreq->send_reset_at_tsn) >
+	    sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map)) {
+		result = SCTP_STRRESET_IN_PROGRESS;
+		goto out;
+	}
+
+	if (request_seq > asoc->strreset_inseq) {
+		result = SCTP_STRRESET_ERR_BAD_SEQNO;
+		goto out;
+	} else if (request_seq == asoc->strreset_inseq) {
+		asoc->strreset_inseq++;
+	}
+
+	/* Check strreset_enable after inseq inc, as sender cannot tell
+	 * the peer doesn't enable strreset after receiving response with
+	 * result denied, as well as to keep consistent with bsd.
+	 */
+	if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
+		goto out;
+
+	if (asoc->strreset_chunk) {
+		struct sctp_strreset_req *inreq;
+		struct sctp_transport *t;
+
+		inreq = sctp_chunk_lookup_strreset_param(
+					asoc, ntohl(outreq->response_seq));
+		if (!inreq || inreq->param_hdr.type !=
+					SCTP_PARAM_RESET_IN_REQUEST) {
+			/* same process with outstanding isn't 0 */
+			result = SCTP_STRRESET_ERR_IN_PROGRESS;
+			goto out;
+		}
+
+		asoc->strreset_outstanding--;
+		asoc->strreset_outseq++;
+
+		if (!asoc->strreset_outstanding) {
+			t = asoc->strreset_chunk->transport;
+			if (del_timer(&t->reconf_timer))
+				sctp_transport_put(t);
+
+			sctp_chunk_put(asoc->strreset_chunk);
+			asoc->strreset_chunk = NULL;
+		}
+
+		flags = SCTP_STREAM_RESET_INCOMING_SSN;
+	}
+
+	nums = (ntohs(param.p->length) - sizeof(*outreq)) / 2;
+	if (nums) {
+		str_p = outreq->list_of_streams;
+		for (i = 0; i < nums; i++) {
+			str_p[i] = ntohs(str_p[i]);
+			if (str_p[i] >= asoc->streamincnt) {
+				result = SCTP_STRRESET_ERR_WRONG_SSN;
+				goto out;
+			}
+		}
+
+		str_p = outreq->list_of_streams;
+		for (i = 0; i < nums; i++, str_p++)
+			asoc->streamin[*str_p].ssn = 0;
+	} else {
+		for (i = 0; i < asoc->streamincnt; i++)
+			asoc->streamin[i].ssn = 0;
+	}
+
+	result = SCTP_STRRESET_PERFORMED;
+
+	*evp = sctp_ulpevent_make_stream_reset_event(asoc,
+		flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
+		GFP_ATOMIC);
+
+out:
+	return sctp_make_strreset_resp(asoc, result, request_seq);
+}
-- 
2.1.0
