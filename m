From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next] sctp: prepare asoc stream for stream reconf
Date: Fri,  6 Jan 2017 22:18:33 +0800
Message-ID: <efd6462731ca0b18a3039f9537dda61e0ed72430.1483712313.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36179 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdAFOSl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 09:18:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp stream reconf, described in RFC 6525, needs a structure to
save per stream information in assoc, like stream state.

In the future, sctp stream scheduler also needs it to save some
stream scheduler params and queues.

This patchset is to prepare the stream array in assoc for stream
reconf. It defines sctp_stream that includes stream arrays inside
to replace ssnmap.

Note that we use different structures for IN and OUT streams, as
the members in per OUT stream will get more and more different
from per IN stream.

v1->v2:
  - put these patches into a smaller group.
v2->v3:
  - define sctp_stream to contain stream arrays, and create stream.c
    to put stream-related functions.
  - merge 3 patches into 1, as new sctp_stream has the same name
    with before.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/net/sctp/sctp.h    |   1 -
 include/net/sctp/structs.h |  76 +++++++++++----------------
 net/sctp/Makefile          |   2 +-
 net/sctp/associola.c       |  13 +++--
 net/sctp/objcnt.c          |   2 -
 net/sctp/sm_make_chunk.c   |  10 ++--
 net/sctp/sm_statefuns.c    |   3 +-
 net/sctp/ssnmap.c          | 125 ---------------------------------------------
 net/sctp/stream.c          |  85 ++++++++++++++++++++++++++++++
 net/sctp/ulpqueue.c        |  36 ++++++-------
 10 files changed, 147 insertions(+), 206 deletions(-)
 delete mode 100644 net/sctp/ssnmap.c
 create mode 100644 net/sctp/stream.c

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index d8833a8..598d938 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -283,7 +283,6 @@ extern atomic_t sctp_dbg_objcnt_chunk;
 extern atomic_t sctp_dbg_objcnt_bind_addr;
 extern atomic_t sctp_dbg_objcnt_bind_bucket;
 extern atomic_t sctp_dbg_objcnt_addr;
-extern atomic_t sctp_dbg_objcnt_ssnmap;
 extern atomic_t sctp_dbg_objcnt_datamsg;
 extern atomic_t sctp_dbg_objcnt_keys;
 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 87d56cc..4741ec2 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -82,7 +82,6 @@ struct sctp_outq;
 struct sctp_bind_addr;
 struct sctp_ulpq;
 struct sctp_ep_common;
-struct sctp_ssnmap;
 struct crypto_shash;
 
 
@@ -377,54 +376,22 @@ typedef struct sctp_sender_hb_info {
 	__u64 hb_nonce;
 } __packed sctp_sender_hb_info_t;
 
-/*
- *  RFC 2960 1.3.2 Sequenced Delivery within Streams
- *
- *  The term "stream" is used in SCTP to refer to a sequence of user
- *  messages that are to be delivered to the upper-layer protocol in
- *  order with respect to other messages within the same stream.  This is
- *  in contrast to its usage in TCP, where it refers to a sequence of
- *  bytes (in this document a byte is assumed to be eight bits).
- *  ...
- *
- *  This is the structure we use to track both our outbound and inbound
- *  SSN, or Stream Sequence Numbers.
- */
-
-struct sctp_stream {
-	__u16 *ssn;
-	unsigned int len;
-};
-
-struct sctp_ssnmap {
-	struct sctp_stream in;
-	struct sctp_stream out;
-};
-
-struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
-				    gfp_t gfp);
-void sctp_ssnmap_free(struct sctp_ssnmap *map);
-void sctp_ssnmap_clear(struct sctp_ssnmap *map);
+struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp);
+void sctp_stream_free(struct sctp_stream *stream);
+void sctp_stream_clear(struct sctp_stream *stream);
 
 /* What is the current SSN number for this stream? */
-static inline __u16 sctp_ssn_peek(struct sctp_stream *stream, __u16 id)
-{
-	return stream->ssn[id];
-}
+#define sctp_ssn_peek(stream, type, sid) \
+	((stream)->type[sid].ssn)
 
 /* Return the next SSN number for this stream.	*/
-static inline __u16 sctp_ssn_next(struct sctp_stream *stream, __u16 id)
-{
-	return stream->ssn[id]++;
-}
+#define sctp_ssn_next(stream, type, sid) \
+	((stream)->type[sid].ssn++)
 
 /* Skip over this ssn and all below. */
-static inline void sctp_ssn_skip(struct sctp_stream *stream, __u16 id, 
-				 __u16 ssn)
-{
-	stream->ssn[id] = ssn+1;
-}
-              
+#define sctp_ssn_skip(stream, type, sid, ssn) \
+	((stream)->type[sid].ssn = ssn + 1)
+
 /*
  * Pointers to address related SCTP functions.
  * (i.e. things that depend on the address family.)
@@ -1331,6 +1298,25 @@ struct sctp_inithdr_host {
 	__u32 initial_tsn;
 };
 
+struct sctp_stream_out {
+	__u16	ssn;
+	__u8	state;
+};
+
+struct sctp_stream_in {
+	__u16	ssn;
+};
+
+struct sctp_stream {
+	struct sctp_stream_out *out;
+	struct sctp_stream_in *in;
+	__u16 outcnt;
+	__u16 incnt;
+};
+
+#define SCTP_STREAM_CLOSED		0x00
+#define SCTP_STREAM_OPEN		0x01
+
 /* SCTP_GET_ASSOC_STATS counters */
 struct sctp_priv_assoc_stats {
 	/* Maximum observed rto in the association during subsequent
@@ -1746,8 +1732,8 @@ struct sctp_association {
 	/* Default receive parameters */
 	__u32 default_rcv_context;
 
-	/* This tracks outbound ssn for a given stream.	 */
-	struct sctp_ssnmap *ssnmap;
+	/* Stream arrays */
+	struct sctp_stream *stream;
 
 	/* All outbound chunks go through this structure.  */
 	struct sctp_outq outqueue;
diff --git a/net/sctp/Makefile b/net/sctp/Makefile
index 6c4f749..70f1b57 100644
--- a/net/sctp/Makefile
+++ b/net/sctp/Makefile
@@ -11,7 +11,7 @@ sctp-y := sm_statetable.o sm_statefuns.o sm_sideeffect.o \
 	  transport.o chunk.o sm_make_chunk.o ulpevent.o \
 	  inqueue.o outqueue.o ulpqueue.o \
 	  tsnmap.o bind_addr.o socket.o primitive.o \
-	  output.o input.o debug.o ssnmap.o auth.o \
+	  output.o input.o debug.o stream.o auth.o \
 	  offload.o
 
 sctp_probe-y := probe.o
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index d3cc30c..36294f7 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -358,8 +358,8 @@ void sctp_association_free(struct sctp_association *asoc)
 
 	sctp_tsnmap_free(&asoc->peer.tsn_map);
 
-	/* Free ssnmap storage. */
-	sctp_ssnmap_free(asoc->ssnmap);
+	/* Free stream information. */
+	sctp_stream_free(asoc->stream);
 
 	/* Clean up the bound address list. */
 	sctp_bind_addr_free(&asoc->base.bind_addr);
@@ -1137,7 +1137,7 @@ void sctp_assoc_update(struct sctp_association *asoc,
 		/* Reinitialize SSN for both local streams
 		 * and peer's streams.
 		 */
-		sctp_ssnmap_clear(asoc->ssnmap);
+		sctp_stream_clear(asoc->stream);
 
 		/* Flush the ULP reassembly and ordered queue.
 		 * Any data there will now be stale and will
@@ -1162,10 +1162,9 @@ void sctp_assoc_update(struct sctp_association *asoc,
 
 		asoc->ctsn_ack_point = asoc->next_tsn - 1;
 		asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
-		if (!asoc->ssnmap) {
-			/* Move the ssnmap. */
-			asoc->ssnmap = new->ssnmap;
-			new->ssnmap = NULL;
+		if (!asoc->stream) {
+			asoc->stream = new->stream;
+			new->stream = NULL;
 		}
 
 		if (!asoc->assoc_id) {
diff --git a/net/sctp/objcnt.c b/net/sctp/objcnt.c
index 40e7fac..105ac33 100644
--- a/net/sctp/objcnt.c
+++ b/net/sctp/objcnt.c
@@ -51,7 +51,6 @@ SCTP_DBG_OBJCNT(bind_addr);
 SCTP_DBG_OBJCNT(bind_bucket);
 SCTP_DBG_OBJCNT(chunk);
 SCTP_DBG_OBJCNT(addr);
-SCTP_DBG_OBJCNT(ssnmap);
 SCTP_DBG_OBJCNT(datamsg);
 SCTP_DBG_OBJCNT(keys);
 
@@ -67,7 +66,6 @@ static sctp_dbg_objcnt_entry_t sctp_dbg_objcnt[] = {
 	SCTP_DBG_OBJCNT_ENTRY(bind_addr),
 	SCTP_DBG_OBJCNT_ENTRY(bind_bucket),
 	SCTP_DBG_OBJCNT_ENTRY(addr),
-	SCTP_DBG_OBJCNT_ENTRY(ssnmap),
 	SCTP_DBG_OBJCNT_ENTRY(datamsg),
 	SCTP_DBG_OBJCNT_ENTRY(keys),
 };
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 9e9690b..a15d824 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1536,7 +1536,7 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 
 	/* All fragments will be on the same stream */
 	sid = ntohs(chunk->subh.data_hdr->stream);
-	stream = &chunk->asoc->ssnmap->out;
+	stream = chunk->asoc->stream;
 
 	/* Now assign the sequence number to the entire message.
 	 * All fragments must have the same stream sequence number.
@@ -1547,9 +1547,9 @@ void sctp_chunk_assign_ssn(struct sctp_chunk *chunk)
 			ssn = 0;
 		} else {
 			if (lchunk->chunk_hdr->flags & SCTP_DATA_LAST_FRAG)
-				ssn = sctp_ssn_next(stream, sid);
+				ssn = sctp_ssn_next(stream, out, sid);
 			else
-				ssn = sctp_ssn_peek(stream, sid);
+				ssn = sctp_ssn_peek(stream, out, sid);
 		}
 
 		lchunk->subh.data_hdr->ssn = htons(ssn);
@@ -2444,9 +2444,9 @@ int sctp_process_init(struct sctp_association *asoc, struct sctp_chunk *chunk,
 	if (!asoc->temp) {
 		int error;
 
-		asoc->ssnmap = sctp_ssnmap_new(asoc->c.sinit_max_instreams,
+		asoc->stream = sctp_stream_new(asoc->c.sinit_max_instreams,
 					       asoc->c.sinit_num_ostreams, gfp);
-		if (!asoc->ssnmap)
+		if (!asoc->stream)
 			goto clean_up;
 
 		error = sctp_assoc_set_id(asoc, gfp);
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 3382ef2..0ceded3 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6274,9 +6274,8 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * and is invalid.
 	 */
 	ssn = ntohs(data_hdr->ssn);
-	if (ordered && SSN_lt(ssn, sctp_ssn_peek(&asoc->ssnmap->in, sid))) {
+	if (ordered && SSN_lt(ssn, sctp_ssn_peek(asoc->stream, in, sid)))
 		return SCTP_IERROR_PROTO_VIOLATION;
-	}
 
 	/* Send the data up to the user.  Note:  Schedule  the
 	 * SCTP_CMD_CHUNK_ULP cmd before the SCTP_CMD_GEN_SACK, as the SACK
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
deleted file mode 100644
index b9c8521..0000000
--- a/net/sctp/ssnmap.c
+++ /dev/null
@@ -1,125 +0,0 @@
-/* SCTP kernel implementation
- * Copyright (c) 2003 International Business Machines, Corp.
- *
- * This file is part of the SCTP kernel implementation
- *
- * These functions manipulate sctp SSN tracker.
- *
- * This SCTP implementation is free software;
- * you can redistribute it and/or modify it under the terms of
- * the GNU General Public License as published by
- * the Free Software Foundation; either version 2, or (at your option)
- * any later version.
- *
- * This SCTP implementation is distributed in the hope that it
- * will be useful, but WITHOUT ANY WARRANTY; without even the implied
- *                 ************************
- * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
- * See the GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with GNU CC; see the file COPYING.  If not, see
- * <http://www.gnu.org/licenses/>.
- *
- * Please send any bug reports or fixes you make to the
- * email address(es):
- *    lksctp developers <linux-sctp@vger.kernel.org>
- *
- * Written or modified by:
- *    Jon Grimm             <jgrimm@us.ibm.com>
- */
-
-#include <linux/types.h>
-#include <linux/slab.h>
-#include <net/sctp/sctp.h>
-#include <net/sctp/sm.h>
-
-static struct sctp_ssnmap *sctp_ssnmap_init(struct sctp_ssnmap *map, __u16 in,
-					    __u16 out);
-
-/* Storage size needed for map includes 2 headers and then the
- * specific needs of in or out streams.
- */
-static inline size_t sctp_ssnmap_size(__u16 in, __u16 out)
-{
-	return sizeof(struct sctp_ssnmap) + (in + out) * sizeof(__u16);
-}
-
-
-/* Create a new sctp_ssnmap.
- * Allocate room to store at least 'len' contiguous TSNs.
- */
-struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
-				    gfp_t gfp)
-{
-	struct sctp_ssnmap *retval;
-	int size;
-
-	size = sctp_ssnmap_size(in, out);
-	if (size <= KMALLOC_MAX_SIZE)
-		retval = kmalloc(size, gfp);
-	else
-		retval = (struct sctp_ssnmap *)
-			  __get_free_pages(gfp, get_order(size));
-	if (!retval)
-		goto fail;
-
-	if (!sctp_ssnmap_init(retval, in, out))
-		goto fail_map;
-
-	SCTP_DBG_OBJCNT_INC(ssnmap);
-
-	return retval;
-
-fail_map:
-	if (size <= KMALLOC_MAX_SIZE)
-		kfree(retval);
-	else
-		free_pages((unsigned long)retval, get_order(size));
-fail:
-	return NULL;
-}
-
-
-/* Initialize a block of memory as a ssnmap.  */
-static struct sctp_ssnmap *sctp_ssnmap_init(struct sctp_ssnmap *map, __u16 in,
-					    __u16 out)
-{
-	memset(map, 0x00, sctp_ssnmap_size(in, out));
-
-	/* Start 'in' stream just after the map header. */
-	map->in.ssn = (__u16 *)&map[1];
-	map->in.len = in;
-
-	/* Start 'out' stream just after 'in'. */
-	map->out.ssn = &map->in.ssn[in];
-	map->out.len = out;
-
-	return map;
-}
-
-/* Clear out the ssnmap streams.  */
-void sctp_ssnmap_clear(struct sctp_ssnmap *map)
-{
-	size_t size;
-
-	size = (map->in.len + map->out.len) * sizeof(__u16);
-	memset(map->in.ssn, 0x00, size);
-}
-
-/* Dispose of a ssnmap.  */
-void sctp_ssnmap_free(struct sctp_ssnmap *map)
-{
-	int size;
-
-	if (unlikely(!map))
-		return;
-
-	size = sctp_ssnmap_size(map->in.len, map->out.len);
-	if (size <= KMALLOC_MAX_SIZE)
-		kfree(map);
-	else
-		free_pages((unsigned long)map, get_order(size));
-
-	SCTP_DBG_OBJCNT_DEC(ssnmap);
-}
diff --git a/net/sctp/stream.c b/net/sctp/stream.c
new file mode 100644
index 0000000..f86de43
--- /dev/null
+++ b/net/sctp/stream.c
@@ -0,0 +1,85 @@
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
+
+struct sctp_stream *sctp_stream_new(__u16 incnt, __u16 outcnt, gfp_t gfp)
+{
+	struct sctp_stream *stream;
+	int i;
+
+	stream = kzalloc(sizeof(*stream), gfp);
+	if (!stream)
+		return NULL;
+
+	stream->outcnt = outcnt;
+	stream->out = kcalloc(stream->outcnt, sizeof(*stream->out), gfp);
+	if (!stream->out) {
+		kfree(stream);
+		return NULL;
+	}
+	for (i = 0; i < stream->outcnt; i++)
+		stream->out[i].state = SCTP_STREAM_OPEN;
+
+	stream->incnt = incnt;
+	stream->in = kcalloc(stream->incnt, sizeof(*stream->in), gfp);
+	if (!stream->in) {
+		kfree(stream->out);
+		kfree(stream);
+		return NULL;
+	}
+
+	return stream;
+}
+
+void sctp_stream_free(struct sctp_stream *stream)
+{
+	if (unlikely(!stream))
+		return;
+
+	kfree(stream->out);
+	kfree(stream->in);
+	kfree(stream);
+}
+
+void sctp_stream_clear(struct sctp_stream *stream)
+{
+	int i;
+
+	for (i = 0; i < stream->outcnt; i++)
+		stream->out[i].ssn = 0;
+
+	for (i = 0; i < stream->incnt; i++)
+		stream->in[i].ssn = 0;
+}
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 84d0fda..aa3624d 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -760,11 +760,11 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 	struct sk_buff_head *event_list;
 	struct sk_buff *pos, *tmp;
 	struct sctp_ulpevent *cevent;
-	struct sctp_stream *in;
+	struct sctp_stream *stream;
 	__u16 sid, csid, cssn;
 
 	sid = event->stream;
-	in  = &ulpq->asoc->ssnmap->in;
+	stream  = ulpq->asoc->stream;
 
 	event_list = (struct sk_buff_head *) sctp_event2skb(event)->prev;
 
@@ -782,11 +782,11 @@ static void sctp_ulpq_retrieve_ordered(struct sctp_ulpq *ulpq,
 		if (csid < sid)
 			continue;
 
-		if (cssn != sctp_ssn_peek(in, sid))
+		if (cssn != sctp_ssn_peek(stream, in, sid))
 			break;
 
-		/* Found it, so mark in the ssnmap. */
-		sctp_ssn_next(in, sid);
+		/* Found it, so mark in the stream. */
+		sctp_ssn_next(stream, in, sid);
 
 		__skb_unlink(pos, &ulpq->lobby);
 
@@ -849,7 +849,7 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 					     struct sctp_ulpevent *event)
 {
 	__u16 sid, ssn;
-	struct sctp_stream *in;
+	struct sctp_stream *stream;
 
 	/* Check if this message needs ordering.  */
 	if (SCTP_DATA_UNORDERED & event->msg_flags)
@@ -858,10 +858,10 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 	/* Note: The stream ID must be verified before this routine.  */
 	sid = event->stream;
 	ssn = event->ssn;
-	in  = &ulpq->asoc->ssnmap->in;
+	stream  = ulpq->asoc->stream;
 
 	/* Is this the expected SSN for this stream ID?  */
-	if (ssn != sctp_ssn_peek(in, sid)) {
+	if (ssn != sctp_ssn_peek(stream, in, sid)) {
 		/* We've received something out of order, so find where it
 		 * needs to be placed.  We order by stream and then by SSN.
 		 */
@@ -870,7 +870,7 @@ static struct sctp_ulpevent *sctp_ulpq_order(struct sctp_ulpq *ulpq,
 	}
 
 	/* Mark that the next chunk has been found.  */
-	sctp_ssn_next(in, sid);
+	sctp_ssn_next(stream, in, sid);
 
 	/* Go find any other chunks that were waiting for
 	 * ordering.
@@ -888,12 +888,12 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 	struct sk_buff *pos, *tmp;
 	struct sctp_ulpevent *cevent;
 	struct sctp_ulpevent *event;
-	struct sctp_stream *in;
+	struct sctp_stream *stream;
 	struct sk_buff_head temp;
 	struct sk_buff_head *lobby = &ulpq->lobby;
 	__u16 csid, cssn;
 
-	in  = &ulpq->asoc->ssnmap->in;
+	stream = ulpq->asoc->stream;
 
 	/* We are holding the chunks by stream, by SSN.  */
 	skb_queue_head_init(&temp);
@@ -912,7 +912,7 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 			continue;
 
 		/* see if this ssn has been marked by skipping */
-		if (!SSN_lt(cssn, sctp_ssn_peek(in, csid)))
+		if (!SSN_lt(cssn, sctp_ssn_peek(stream, in, csid)))
 			break;
 
 		__skb_unlink(pos, lobby);
@@ -932,8 +932,8 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
 		csid = cevent->stream;
 		cssn = cevent->ssn;
 
-		if (csid == sid && cssn == sctp_ssn_peek(in, csid)) {
-			sctp_ssn_next(in, csid);
+		if (csid == sid && cssn == sctp_ssn_peek(stream, in, csid)) {
+			sctp_ssn_next(stream, in, csid);
 			__skb_unlink(pos, lobby);
 			__skb_queue_tail(&temp, pos);
 			event = sctp_skb2event(pos);
@@ -955,17 +955,17 @@ static void sctp_ulpq_reap_ordered(struct sctp_ulpq *ulpq, __u16 sid)
  */
 void sctp_ulpq_skip(struct sctp_ulpq *ulpq, __u16 sid, __u16 ssn)
 {
-	struct sctp_stream *in;
+	struct sctp_stream *stream;
 
 	/* Note: The stream ID must be verified before this routine.  */
-	in  = &ulpq->asoc->ssnmap->in;
+	stream  = ulpq->asoc->stream;
 
 	/* Is this an old SSN?  If so ignore. */
-	if (SSN_lt(ssn, sctp_ssn_peek(in, sid)))
+	if (SSN_lt(ssn, sctp_ssn_peek(stream, in, sid)))
 		return;
 
 	/* Mark that we are no longer expecting this SSN or lower. */
-	sctp_ssn_skip(in, sid, ssn);
+	sctp_ssn_skip(stream, in, sid, ssn);
 
 	/* Go find any other chunks that were waiting for
 	 * ordering and deliver them if needed.
-- 
2.1.0
