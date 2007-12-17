From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2.6.25 4/9] SCTP: Update association lookup to look at ASCONF chunks as well
Date: Mon, 17 Dec 2007 16:32:44 -0500
Message-ID: <1197927169-5106-5-git-send-email-vladislav.yasevich@hp.com>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Cc: lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:15310 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759931AbXLQVcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 16:32:53 -0500
In-Reply-To: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ADD-IP draft section 5.2 specifies that if an association can not
be found using the source and destination of the IP packet,
then, if the packet contains ASCONF chunks, the Address Parameter
TLV should be used to lookup an association.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/input.c |  124 ++++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 103 insertions(+), 21 deletions(-)

diff --git a/net/sctp/input.c b/net/sctp/input.c
index b08c7cb..d695f71 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -891,14 +891,6 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 
 	ch = (sctp_chunkhdr_t *) skb->data;
 
-	/* The code below will attempt to walk the chunk and extract
-	 * parameter information.  Before we do that, we need to verify
-	 * that the chunk length doesn't cause overflow.  Otherwise, we'll
-	 * walk off the end.
-	 */
-	if (WORD_ROUND(ntohs(ch->length)) > skb->len)
-		return NULL;
-
 	/*
 	 * This code will NOT touch anything inside the chunk--it is
 	 * strictly READ-ONLY.
@@ -935,6 +927,44 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 	return NULL;
 }
 
+/* ADD-IP, Section 5.2
+ * When an endpoint receives an ASCONF Chunk from the remote peer
+ * special procedures may be needed to identify the association the
+ * ASCONF Chunk is associated with. To properly find the association
+ * the following procedures SHOULD be followed:
+ *
+ * D2) If the association is not found, use the address found in the
+ * Address Parameter TLV combined with the port number found in the
+ * SCTP common header. If found proceed to rule D4.
+ *
+ * D2-ext) If more than one ASCONF Chunks are packed together, use the
+ * address found in the ASCONF Address Parameter TLV of each of the
+ * subsequent ASCONF Chunks. If found, proceed to rule D4.
+ */
+static struct sctp_association *__sctp_rcv_asconf_lookup(
+					sctp_chunkhdr_t *ch,
+					const union sctp_addr *laddr,
+					__be32 peer_port,
+					struct sctp_transport **transportp)
+{
+	sctp_addip_chunk_t *asconf = (struct sctp_addip_chunk *)ch;
+	struct sctp_af *af;
+	union sctp_addr_param *param;
+	union sctp_addr paddr;
+
+	/* Skip over the ADDIP header and find the Address parameter */
+	param = (union sctp_addr_param *)(asconf + 1);
+
+	af = sctp_get_af_specific(param_type2af(param->v4.param_hdr.type));
+	if (unlikely(!af))
+		return NULL;
+
+	af->from_addr_param(&paddr, param, peer_port, 0);
+
+	return __sctp_lookup_association(laddr, &paddr, transportp);
+}
+
+
 /* SCTP-AUTH, Section 6.3:
 *    If the receiver does not find a STCB for a packet containing an AUTH
 *    chunk as the first chunk and not a COOKIE-ECHO chunk as the second
@@ -943,20 +973,64 @@ static struct sctp_association *__sctp_rcv_init_lookup(struct sk_buff *skb,
 *
 * This means that any chunks that can help us identify the association need
 * to be looked at to find this assocation.
-*
-* TODO: The only chunk currently defined that can do that is ASCONF, but we
-* don't support that functionality yet.
 */
-static struct sctp_association *__sctp_rcv_auth_lookup(struct sk_buff *skb,
-				      const union sctp_addr *paddr,
+static struct sctp_association *__sctp_rcv_walk_lookup(struct sk_buff *skb,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
-	/* XXX - walk through the chunks looking for something that can
-	 * help us find the association.  INIT, and INIT-ACK are not permitted.
-	 * That leaves ASCONF, but we don't support that yet.
+	struct sctp_association *asoc = NULL;
+	sctp_chunkhdr_t *ch;
+	int have_auth = 0;
+	unsigned int chunk_num = 1;
+	__u8 *ch_end;
+
+	/* Walk through the chunks looking for AUTH or ASCONF chunks
+	 * to help us find the association.
 	 */
-	return NULL;
+	ch = (sctp_chunkhdr_t *) skb->data;
+	do {
+		/* Break out if chunk length is less then minimal. */
+		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
+			break;
+
+		ch_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
+		if (ch_end > skb_tail_pointer(skb))
+			break;
+
+		switch(ch->type) {
+		    case SCTP_CID_AUTH:
+			    have_auth = chunk_num;
+			    break;
+
+		    case SCTP_CID_COOKIE_ECHO:
+			    /* If a packet arrives containing an AUTH chunk as
+			     * a first chunk, a COOKIE-ECHO chunk as the second
+			     * chunk, and possibly more chunks after them, and
+			     * the receiver does not have an STCB for that
+			     * packet, then authentication is based on
+			     * the contents of the COOKIE- ECHO chunk.
+			     */
+			    if (have_auth == 1 && chunk_num == 2)
+				    return NULL;
+			    break;
+
+		    case SCTP_CID_ASCONF:
+			    if (have_auth || sctp_addip_noauth)
+				    asoc = __sctp_rcv_asconf_lookup(ch, laddr,
+							sctp_hdr(skb)->source,
+							transportp);
+		    default:
+			    break;
+		}
+
+		if (asoc)
+			break;
+
+		ch = (sctp_chunkhdr_t *) ch_end;
+		chunk_num++;
+	} while (ch_end < skb_tail_pointer(skb));
+
+	return asoc;
 }
 
 /*
@@ -966,7 +1040,6 @@ static struct sctp_association *__sctp_rcv_auth_lookup(struct sk_buff *skb,
  * chunks.
  */
 static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
-				      const union sctp_addr *paddr,
 				      const union sctp_addr *laddr,
 				      struct sctp_transport **transportp)
 {
@@ -974,6 +1047,14 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
 
 	ch = (sctp_chunkhdr_t *) skb->data;
 
+	/* The code below will attempt to walk the chunk and extract
+	 * parameter information.  Before we do that, we need to verify
+	 * that the chunk length doesn't cause overflow.  Otherwise, we'll
+	 * walk off the end.
+	 */
+	if (WORD_ROUND(ntohs(ch->length)) > skb->len)
+		return NULL;
+
 	/* If this is INIT/INIT-ACK look inside the chunk too. */
 	switch (ch->type) {
 	case SCTP_CID_INIT:
@@ -981,11 +1062,12 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct sk_buff *skb,
 		return __sctp_rcv_init_lookup(skb, laddr, transportp);
 		break;
 
-	case SCTP_CID_AUTH:
-		return __sctp_rcv_auth_lookup(skb, paddr, laddr, transportp);
+	default:
+		return __sctp_rcv_walk_lookup(skb, laddr, transportp);
 		break;
 	}
 
+
 	return NULL;
 }
 
@@ -1004,7 +1086,7 @@ static struct sctp_association *__sctp_rcv_lookup(struct sk_buff *skb,
 	 * parameters within the INIT or INIT-ACK.
 	 */
 	if (!asoc)
-		asoc = __sctp_rcv_lookup_harder(skb, paddr, laddr, transportp);
+		asoc = __sctp_rcv_lookup_harder(skb, laddr, transportp);
 
 	return asoc;
 }
-- 
1.5.3.5

