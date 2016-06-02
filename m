From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v3 5/7] sctp: delay as much as possible skb_linearize
Date: Thu,  2 Jun 2016 15:05:42 -0300
Message-ID: <3e8e113c5166e958f63e618758413e82777c71e4.1464888549.git.marcelo.leitner@gmail.com>
References: <cover.1464888549.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53376 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161516AbcFBSGM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 14:06:12 -0400
In-Reply-To: <cover.1464888549.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is a preparation for the GSO one. In order to successfully
handle GSO packets on rx path we must not call skb_linearize, otherwise
it defeats any gain GSO may have had.

This patch thus delays as much as possible the call to skb_linearize,
leaving it to sctp_inq_pop() moment. For that the sanity checks
performed now know how to deal with fragments.

One positive side-effect of this is that if the socket is backlogged it
will have the chance of doing it on backlog processing instead of
during softirq.

With this move, it's evident that a check for non-linearity in
sctp_inq_pop was ineffective and is now removed. Note that a similar
check is performed a bit below this one.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/input.c   | 45 +++++++++++++++++++++++++--------------------
 net/sctp/inqueue.c | 29 ++++++++++++++++++-----------
 2 files changed, 43 insertions(+), 31 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index a701527a9480faff1b8d91257e1dbf3c0f09ed68..5cff2546c3dd6d3823b5a28bac1e72880cd57756 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -112,7 +112,6 @@ int sctp_rcv(struct sk_buff *skb)
 	struct sctp_ep_common *rcvr;
 	struct sctp_transport *transport = NULL;
 	struct sctp_chunk *chunk;
-	struct sctphdr *sh;
 	union sctp_addr src;
 	union sctp_addr dest;
 	int family;
@@ -124,15 +123,18 @@ int sctp_rcv(struct sk_buff *skb)
 
 	__SCTP_INC_STATS(net, SCTP_MIB_INSCTPPACKS);
 
-	if (skb_linearize(skb))
+	/* If packet is too small to contain a single chunk, let's not
+	 * waste time on it anymore.
+	 */
+	if (skb->len < sizeof(struct sctphdr) + sizeof(struct sctp_chunkhdr) +
+		       skb_transport_offset(skb))
 		goto discard_it;
 
-	sh = sctp_hdr(skb);
+	if (!pskb_may_pull(skb, sizeof(struct sctphdr)))
+		goto discard_it;
 
-	/* Pull up the IP and SCTP headers. */
+	/* Pull up the IP header. */
 	__skb_pull(skb, skb_transport_offset(skb));
-	if (skb->len < sizeof(struct sctphdr))
-		goto discard_it;
 
 	skb->csum_valid = 0; /* Previous value not applicable */
 	if (skb_csum_unnecessary(skb))
@@ -141,11 +143,7 @@ int sctp_rcv(struct sk_buff *skb)
 		goto discard_it;
 	skb->csum_valid = 1;
 
-	skb_pull(skb, sizeof(struct sctphdr));
-
-	/* Make sure we at least have chunk headers worth of data left. */
-	if (skb->len < sizeof(struct sctp_chunkhdr))
-		goto discard_it;
+	__skb_pull(skb, sizeof(struct sctphdr));
 
 	family = ipver2af(ip_hdr(skb)->version);
 	af = sctp_get_af_specific(family);
@@ -230,7 +228,7 @@ int sctp_rcv(struct sk_buff *skb)
 	chunk->rcvr = rcvr;
 
 	/* Remember the SCTP header. */
-	chunk->sctp_hdr = sh;
+	chunk->sctp_hdr = sctp_hdr(skb);
 
 	/* Set the source and destination addresses of the incoming chunk.  */
 	sctp_init_addrs(chunk, &src, &dest);
@@ -660,19 +658,23 @@ out_unlock:
  */
 static int sctp_rcv_ootb(struct sk_buff *skb)
 {
-	sctp_chunkhdr_t *ch;
-	__u8 *ch_end;
-
-	ch = (sctp_chunkhdr_t *) skb->data;
+	sctp_chunkhdr_t *ch, _ch;
+	int ch_end, offset = 0;
 
 	/* Scan through all the chunks in the packet.  */
 	do {
+		/* Make sure we have at least the header there */
+		if (offset + sizeof(sctp_chunkhdr_t) > skb->len)
+			break;
+
+		ch = skb_header_pointer(skb, offset, sizeof(*ch), &_ch);
+
 		/* Break out if chunk length is less then minimal. */
 		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
 			break;
 
-		ch_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
-		if (ch_end > skb_tail_pointer(skb))
+		ch_end = offset + WORD_ROUND(ntohs(ch->length));
+		if (ch_end > skb->len)
 			break;
 
 		/* RFC 8.4, 2) If the OOTB packet contains an ABORT chunk, the
@@ -697,8 +699,8 @@ static int sctp_rcv_ootb(struct sk_buff *skb)
 		if (SCTP_CID_INIT == ch->type && (void *)ch != skb->data)
 			goto discard;
 
-		ch = (sctp_chunkhdr_t *) ch_end;
-	} while (ch_end < skb_tail_pointer(skb));
+		offset = ch_end;
+	} while (ch_end < skb->len);
 
 	return 0;
 
@@ -1173,6 +1175,9 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 {
 	sctp_chunkhdr_t *ch;
 
+	if (skb_linearize(skb))
+		return NULL;
+
 	ch = (sctp_chunkhdr_t *) skb->data;
 
 	/* The code below will attempt to walk the chunk and extract
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 9d87bba0ff1d34134093f34e4db3dc1b7e3dafd6..5ba08ceda3ab6cf61eb64c58bffb9ccd589e8664 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -130,7 +130,8 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 	 * at this time.
 	 */
 
-	if ((chunk = queue->in_progress)) {
+	chunk = queue->in_progress;
+	if (chunk) {
 		/* There is a packet that we have been working on.
 		 * Any post processing work to do before we move on?
 		 */
@@ -152,15 +153,29 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 	if (!chunk) {
 		struct list_head *entry;
 
+next_chunk:
 		/* Is the queue empty?  */
 		if (list_empty(&queue->in_chunk_list))
 			return NULL;
 
 		entry = queue->in_chunk_list.next;
-		chunk = queue->in_progress =
-			list_entry(entry, struct sctp_chunk, list);
+		chunk = list_entry(entry, struct sctp_chunk, list);
 		list_del_init(entry);
 
+		/* Linearize if it's not GSO */
+		if (skb_is_nonlinear(chunk->skb)) {
+			if (skb_linearize(chunk->skb)) {
+				__SCTP_INC_STATS(dev_net(chunk->skb->dev), SCTP_MIB_IN_PKT_DISCARDS);
+				sctp_chunk_free(chunk);
+				goto next_chunk;
+			}
+
+			/* Update sctp_hdr as it probably changed */
+			chunk->sctp_hdr = sctp_hdr(chunk->skb);
+		}
+
+		queue->in_progress = chunk;
+
 		/* This is the first chunk in the packet.  */
 		chunk->singleton = 1;
 		ch = (sctp_chunkhdr_t *) chunk->skb->data;
@@ -172,14 +187,6 @@ struct sctp_chunk *sctp_inq_pop(struct sctp_inq *queue)
 
 	chunk->chunk_hdr = ch;
 	chunk->chunk_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
-	/* In the unlikely case of an IP reassembly, the skb could be
-	 * non-linear. If so, update chunk_end so that it doesn't go past
-	 * the skb->tail.
-	 */
-	if (unlikely(skb_is_nonlinear(chunk->skb))) {
-		if (chunk->chunk_end > skb_tail_pointer(chunk->skb))
-			chunk->chunk_end = skb_tail_pointer(chunk->skb);
-	}
 	skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
 	chunk->subh.v = NULL; /* Subheader is no longer valid.  */
 
-- 
2.5.5
