From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH next v2 1/2] sctp: rename WORD_TRUNC/ROUND macros
Date: Tue, 20 Sep 2016 18:25:01 -0300
Message-ID: <29722e8df218640ef977cb125c77613a5225f6d3.1474406484.git.marcelo.leitner@gmail.com>
References: <cover.1474406484.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44176 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753742AbcITVZM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 17:25:12 -0400
In-Reply-To: <cover.1474406484.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To something more meaningful these days, specially because this is
working on packet headers or lengths and which are not tied to any CPU
arch but to the protocol itself.

So, WORD_TRUNC becomes SCTP_TRUNC4 and WORD_ROUND becomes SCTP_ALIGN4.

Reported-by: David Laight <David.Laight@ACULAB.COM>
Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sctp.h  | 10 +++++-----
 net/netfilter/xt_sctp.c  |  2 +-
 net/sctp/associola.c     |  2 +-
 net/sctp/chunk.c         |  6 +++---
 net/sctp/input.c         |  8 ++++----
 net/sctp/inqueue.c       |  2 +-
 net/sctp/output.c        | 12 ++++++------
 net/sctp/sm_make_chunk.c | 26 +++++++++++++-------------
 net/sctp/sm_statefuns.c  |  6 +++---
 net/sctp/transport.c     |  4 ++--
 net/sctp/ulpevent.c      |  4 ++--
 11 files changed, 41 insertions(+), 41 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 632e205ca54bfe85124753e09445251056e19aa7..bfc97d28a857c338403bda81ee8ef6897257bf9f 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -83,9 +83,9 @@
 #endif
 
 /* Round an int up to the next multiple of 4.  */
-#define WORD_ROUND(s) (((s)+3)&~3)
+#define SCTP_ALIGN4(s) (((s)+3)&~3)
 /* Truncate to the previous multiple of 4.  */
-#define WORD_TRUNC(s) ((s)&~3)
+#define SCTP_TRUNC4(s) ((s)&~3)
 
 /*
  * Function declarations.
@@ -433,7 +433,7 @@ static inline int sctp_frag_point(const struct sctp_association *asoc, int pmtu)
 	if (asoc->user_frag)
 		frag = min_t(int, frag, asoc->user_frag);
 
-	frag = WORD_TRUNC(min_t(int, frag, SCTP_MAX_CHUNK_LEN));
+	frag = SCTP_TRUNC4(min_t(int, frag, SCTP_MAX_CHUNK_LEN));
 
 	return frag;
 }
@@ -462,7 +462,7 @@ _sctp_walk_params((pos), (chunk), ntohs((chunk)->chunk_hdr.length), member)
 for (pos.v = chunk->member;\
      pos.v <= (void *)chunk + end - ntohs(pos.p->length) &&\
      ntohs(pos.p->length) >= sizeof(sctp_paramhdr_t);\
-     pos.v += WORD_ROUND(ntohs(pos.p->length)))
+     pos.v += SCTP_ALIGN4(ntohs(pos.p->length)))
 
 #define sctp_walk_errors(err, chunk_hdr)\
 _sctp_walk_errors((err), (chunk_hdr), ntohs((chunk_hdr)->length))
@@ -472,7 +472,7 @@ for (err = (sctp_errhdr_t *)((void *)chunk_hdr + \
 	    sizeof(sctp_chunkhdr_t));\
      (void *)err <= (void *)chunk_hdr + end - ntohs(err->length) &&\
      ntohs(err->length) >= sizeof(sctp_errhdr_t); \
-     err = (sctp_errhdr_t *)((void *)err + WORD_ROUND(ntohs(err->length))))
+     err = (sctp_errhdr_t *)((void *)err + SCTP_ALIGN4(ntohs(err->length))))
 
 #define sctp_walk_fwdtsn(pos, chunk)\
 _sctp_walk_fwdtsn((pos), (chunk), ntohs((chunk)->chunk_hdr->length) - sizeof(struct sctp_fwdtsn_chunk))
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index ef36a56a02c6881c58296b2bf45c4b99d3836456..3d23ee5e72a93157ab8bd84d41aa14aa5acf5c4c 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -68,7 +68,7 @@ match_packet(const struct sk_buff *skb,
 			 ++i, offset, sch->type, htons(sch->length),
 			 sch->flags);
 #endif
-		offset += WORD_ROUND(ntohs(sch->length));
+		offset += SCTP_ALIGN4(ntohs(sch->length));
 
 		pr_debug("skb->len: %d\toffset: %d\n", skb->len, offset);
 
diff --git a/net/sctp/associola.c b/net/sctp/associola.c
index 1c23060c41a669f38f4e2d244cfb61c85a522be6..f10d3397f917986d25240fc42f6a33ae8049e7b7 100644
--- a/net/sctp/associola.c
+++ b/net/sctp/associola.c
@@ -1408,7 +1408,7 @@ void sctp_assoc_sync_pmtu(struct sock *sk, struct sctp_association *asoc)
 				transports) {
 		if (t->pmtu_pending && t->dst) {
 			sctp_transport_update_pmtu(sk, t,
-						   WORD_TRUNC(dst_mtu(t->dst)));
+						   SCTP_TRUNC4(dst_mtu(t->dst)));
 			t->pmtu_pending = 0;
 		}
 		if (!pmtu || (t->pathmtu < pmtu))
diff --git a/net/sctp/chunk.c b/net/sctp/chunk.c
index af9cc8055465b18e9754a5542fc7bd43f9dad240..86be257c9881a9bf404a1be010fdcd1c55c8b89a 100644
--- a/net/sctp/chunk.c
+++ b/net/sctp/chunk.c
@@ -208,8 +208,8 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 		struct sctp_hmac *hmac_desc = sctp_auth_asoc_get_hmac(asoc);
 
 		if (hmac_desc)
-			max_data -= WORD_ROUND(sizeof(sctp_auth_chunk_t) +
-					    hmac_desc->hmac_len);
+			max_data -= SCTP_ALIGN4(sizeof(sctp_auth_chunk_t) +
+						hmac_desc->hmac_len);
 	}
 
 	/* Now, check if we need to reduce our max */
@@ -229,7 +229,7 @@ struct sctp_datamsg *sctp_datamsg_from_user(struct sctp_association *asoc,
 	    asoc->outqueue.out_qlen == 0 &&
 	    list_empty(&asoc->outqueue.retransmit) &&
 	    msg_len > max)
-		max_data -= WORD_ROUND(sizeof(sctp_sack_chunk_t));
+		max_data -= SCTP_ALIGN4(sizeof(sctp_sack_chunk_t));
 
 	/* Encourage Cookie-ECHO bundling. */
 	if (asoc->state < SCTP_STATE_COOKIE_ECHOED)
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 69444d32ecda6cd1a4924911172feba89c5ae976..2614319c4f71b2eafffe4ed35ce2b2de36aa225c 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -605,7 +605,7 @@ void sctp_v4_err(struct sk_buff *skb, __u32 info)
 		/* PMTU discovery (RFC1191) */
 		if (ICMP_FRAG_NEEDED == code) {
 			sctp_icmp_frag_needed(sk, asoc, transport,
-					      WORD_TRUNC(info));
+					      SCTP_TRUNC4(info));
 			goto out_unlock;
 		} else {
 			if (ICMP_PROT_UNREACH == code) {
@@ -673,7 +673,7 @@ static int sctp_rcv_ootb(struct sk_buff *skb)
 		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
 			break;
 
-		ch_end = offset + WORD_ROUND(ntohs(ch->length));
+		ch_end = offset + SCTP_ALIGN4(ntohs(ch->length));
 		if (ch_end > skb->len)
 			break;
 
@@ -1121,7 +1121,7 @@ static struct sctp_association *__sctp_rcv_walk_lookup(struct net *net,
 		if (ntohs(ch->length) < sizeof(sctp_chunkhdr_t))
 			break;
 
-		ch_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
+		ch_end = ((__u8 *)ch) + SCTP_ALIGN4(ntohs(ch->length));
 		if (ch_end > skb_tail_pointer(skb))
 			break;
 
@@ -1190,7 +1190,7 @@ static struct sctp_association *__sctp_rcv_lookup_harder(struct net *net,
 	 * that the chunk length doesn't cause overflow.  Otherwise, we'll
 	 * walk off the end.
 	 */
-	if (WORD_ROUND(ntohs(ch->length)) > skb->len)
+	if (SCTP_ALIGN4(ntohs(ch->length)) > skb->len)
 		return NULL;
 
 	/* If this is INIT/INIT-ACK look inside the chunk too. */
diff --git a/net/sctp/inqueue.c b/net/sctp/inqueue.c
index 6437aa97cfd79f14c633499c2b131389204c435b..8e46d72713d945e89d91d93754bfdda0a1a68c4d 100644
--- a/net/sctp/inqueue.c
+++ b/net/sctp/inqueue.c
@@ -213,7 +213,7 @@ new_skb:
 	}
 
 	chunk->chunk_hdr = ch;
-	chunk->chunk_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
+	chunk->chunk_end = ((__u8 *)ch) + SCTP_ALIGN4(ntohs(ch->length));
 	skb_pull(chunk->skb, sizeof(sctp_chunkhdr_t));
 	chunk->subh.v = NULL; /* Subheader is no longer valid.  */
 
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0c605ec74dc4ac2b300d7e52107597bb1be5fefd..e9012a4c5b903b767e98cae22dd62751c3abd56a 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -297,7 +297,7 @@ static sctp_xmit_t __sctp_packet_append_chunk(struct sctp_packet *packet,
 					      struct sctp_chunk *chunk)
 {
 	sctp_xmit_t retval = SCTP_XMIT_OK;
-	__u16 chunk_len = WORD_ROUND(ntohs(chunk->chunk_hdr->length));
+	__u16 chunk_len = SCTP_ALIGN4(ntohs(chunk->chunk_hdr->length));
 
 	/* Check to see if this chunk will fit into the packet */
 	retval = sctp_packet_will_fit(packet, chunk, chunk_len);
@@ -508,7 +508,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 		if (gso) {
 			pkt_size = packet->overhead;
 			list_for_each_entry(chunk, &packet->chunk_list, list) {
-				int padded = WORD_ROUND(chunk->skb->len);
+				int padded = SCTP_ALIGN4(chunk->skb->len);
 
 				if (pkt_size + padded > tp->pathmtu)
 					break;
@@ -538,7 +538,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 		 * included in the chunk length field.  The sender should
 		 * never pad with more than 3 bytes.
 		 *
-		 * [This whole comment explains WORD_ROUND() below.]
+		 * [This whole comment explains SCTP_ALIGN4() below.]
 		 */
 
 		pkt_size -= packet->overhead;
@@ -560,7 +560,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 				has_data = 1;
 			}
 
-			padding = WORD_ROUND(chunk->skb->len) - chunk->skb->len;
+			padding = SCTP_ALIGN4(chunk->skb->len) - chunk->skb->len;
 			if (padding)
 				memset(skb_put(chunk->skb, padding), 0, padding);
 
@@ -587,7 +587,7 @@ int sctp_packet_transmit(struct sctp_packet *packet, gfp_t gfp)
 			 * acknowledged or have failed.
 			 * Re-queue auth chunks if needed.
 			 */
-			pkt_size -= WORD_ROUND(chunk->skb->len);
+			pkt_size -= SCTP_ALIGN4(chunk->skb->len);
 
 			if (!sctp_chunk_is_data(chunk) && chunk != packet->auth)
 				sctp_chunk_free(chunk);
@@ -911,7 +911,7 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 		 */
 		maxsize = pmtu - packet->overhead;
 		if (packet->auth)
-			maxsize -= WORD_ROUND(packet->auth->skb->len);
+			maxsize -= SCTP_ALIGN4(packet->auth->skb->len);
 		if (chunk_len > maxsize)
 			retval = SCTP_XMIT_PMTU_FULL;
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 8c77b87a8565cb4f82c09cea65557dc9c8d1138f..67660bc25e7d2714551d1f1a8664941c32f240e1 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -253,7 +253,7 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 	num_types = sp->pf->supported_addrs(sp, types);
 
 	chunksize = sizeof(init) + addrs_len;
-	chunksize += WORD_ROUND(SCTP_SAT_LEN(num_types));
+	chunksize += SCTP_ALIGN4(SCTP_SAT_LEN(num_types));
 	chunksize += sizeof(ecap_param);
 
 	if (asoc->prsctp_enable)
@@ -283,14 +283,14 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 		/* Add HMACS parameter length if any were defined */
 		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
 		if (auth_hmacs->length)
-			chunksize += WORD_ROUND(ntohs(auth_hmacs->length));
+			chunksize += SCTP_ALIGN4(ntohs(auth_hmacs->length));
 		else
 			auth_hmacs = NULL;
 
 		/* Add CHUNKS parameter length */
 		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
 		if (auth_chunks->length)
-			chunksize += WORD_ROUND(ntohs(auth_chunks->length));
+			chunksize += SCTP_ALIGN4(ntohs(auth_chunks->length));
 		else
 			auth_chunks = NULL;
 
@@ -300,8 +300,8 @@ struct sctp_chunk *sctp_make_init(const struct sctp_association *asoc,
 
 	/* If we have any extensions to report, account for that */
 	if (num_ext)
-		chunksize += WORD_ROUND(sizeof(sctp_supported_ext_param_t) +
-					num_ext);
+		chunksize += SCTP_ALIGN4(sizeof(sctp_supported_ext_param_t) +
+					 num_ext);
 
 	/* RFC 2960 3.3.2 Initiation (INIT) (1)
 	 *
@@ -443,13 +443,13 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 
 		auth_hmacs = (sctp_paramhdr_t *)asoc->c.auth_hmacs;
 		if (auth_hmacs->length)
-			chunksize += WORD_ROUND(ntohs(auth_hmacs->length));
+			chunksize += SCTP_ALIGN4(ntohs(auth_hmacs->length));
 		else
 			auth_hmacs = NULL;
 
 		auth_chunks = (sctp_paramhdr_t *)asoc->c.auth_chunks;
 		if (auth_chunks->length)
-			chunksize += WORD_ROUND(ntohs(auth_chunks->length));
+			chunksize += SCTP_ALIGN4(ntohs(auth_chunks->length));
 		else
 			auth_chunks = NULL;
 
@@ -458,7 +458,7 @@ struct sctp_chunk *sctp_make_init_ack(const struct sctp_association *asoc,
 	}
 
 	if (num_ext)
-		chunksize += WORD_ROUND(sizeof(sctp_supported_ext_param_t) +
+		chunksize += SCTP_ALIGN4(sizeof(sctp_supported_ext_param_t) +
 					num_ext);
 
 	/* Now allocate and fill out the chunk.  */
@@ -1390,7 +1390,7 @@ static struct sctp_chunk *_sctp_make_chunk(const struct sctp_association *asoc,
 	struct sock *sk;
 
 	/* No need to allocate LL here, as this is only a chunk. */
-	skb = alloc_skb(WORD_ROUND(sizeof(sctp_chunkhdr_t) + paylen), gfp);
+	skb = alloc_skb(SCTP_ALIGN4(sizeof(sctp_chunkhdr_t) + paylen), gfp);
 	if (!skb)
 		goto nodata;
 
@@ -1482,7 +1482,7 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
 	void *target;
 	void *padding;
 	int chunklen = ntohs(chunk->chunk_hdr->length);
-	int padlen = WORD_ROUND(chunklen) - chunklen;
+	int padlen = SCTP_ALIGN4(chunklen) - chunklen;
 
 	padding = skb_put(chunk->skb, padlen);
 	target = skb_put(chunk->skb, len);
@@ -1900,7 +1900,7 @@ static int sctp_process_missing_param(const struct sctp_association *asoc,
 	struct __sctp_missing report;
 	__u16 len;
 
-	len = WORD_ROUND(sizeof(report));
+	len = SCTP_ALIGN4(sizeof(report));
 
 	/* Make an ERROR chunk, preparing enough room for
 	 * returning multiple unknown parameters.
@@ -2098,9 +2098,9 @@ static sctp_ierror_t sctp_process_unk_param(const struct sctp_association *asoc,
 
 		if (*errp) {
 			if (!sctp_init_cause_fixed(*errp, SCTP_ERROR_UNKNOWN_PARAM,
-					WORD_ROUND(ntohs(param.p->length))))
+					SCTP_ALIGN4(ntohs(param.p->length))))
 				sctp_addto_chunk_fixed(*errp,
-						WORD_ROUND(ntohs(param.p->length)),
+						SCTP_ALIGN4(ntohs(param.p->length)),
 						param.v);
 		} else {
 			/* If there is no memory for generating the ERROR
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index d88bb2b0b69913ad5962f9a5655d413f2c210ed0..35413f114e567ebdfe1b05b2eb1d74634e27317b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3454,7 +3454,7 @@ sctp_disposition_t sctp_sf_ootb(struct net *net,
 		}
 
 		/* Report violation if chunk len overflows */
-		ch_end = ((__u8 *)ch) + WORD_ROUND(ntohs(ch->length));
+		ch_end = ((__u8 *)ch) + SCTP_ALIGN4(ntohs(ch->length));
 		if (ch_end > skb_tail_pointer(skb))
 			return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
@@ -4185,7 +4185,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 		hdr = unk_chunk->chunk_hdr;
 		err_chunk = sctp_make_op_error(asoc, unk_chunk,
 					       SCTP_ERROR_UNKNOWN_CHUNK, hdr,
-					       WORD_ROUND(ntohs(hdr->length)),
+					       SCTP_ALIGN4(ntohs(hdr->length)),
 					       0);
 		if (err_chunk) {
 			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
@@ -4203,7 +4203,7 @@ sctp_disposition_t sctp_sf_unk_chunk(struct net *net,
 		hdr = unk_chunk->chunk_hdr;
 		err_chunk = sctp_make_op_error(asoc, unk_chunk,
 					       SCTP_ERROR_UNKNOWN_CHUNK, hdr,
-					       WORD_ROUND(ntohs(hdr->length)),
+					       SCTP_ALIGN4(ntohs(hdr->length)),
 					       0);
 		if (err_chunk) {
 			sctp_add_cmd_sf(commands, SCTP_CMD_REPLY,
diff --git a/net/sctp/transport.c b/net/sctp/transport.c
index 81b86678be4d6fccc527d3c3e509c12576b2194c..ce54dce13ddb2cba959bca080b06f9285f2fe16d 100644
--- a/net/sctp/transport.c
+++ b/net/sctp/transport.c
@@ -233,7 +233,7 @@ void sctp_transport_pmtu(struct sctp_transport *transport, struct sock *sk)
 	}
 
 	if (transport->dst) {
-		transport->pathmtu = WORD_TRUNC(dst_mtu(transport->dst));
+		transport->pathmtu = SCTP_TRUNC4(dst_mtu(transport->dst));
 	} else
 		transport->pathmtu = SCTP_DEFAULT_MAXSEGMENT;
 }
@@ -287,7 +287,7 @@ void sctp_transport_route(struct sctp_transport *transport,
 		return;
 	}
 	if (transport->dst) {
-		transport->pathmtu = WORD_TRUNC(dst_mtu(transport->dst));
+		transport->pathmtu = SCTP_TRUNC4(dst_mtu(transport->dst));
 
 		/* Initialize sk->sk_rcv_saddr, if the transport is the
 		 * association's active path for getsockname().
diff --git a/net/sctp/ulpevent.c b/net/sctp/ulpevent.c
index d85b803da11d21202d876c95811bcab4e1fb507e..ca0607458fc25eefaf017c034465410febe1ca7a 100644
--- a/net/sctp/ulpevent.c
+++ b/net/sctp/ulpevent.c
@@ -383,7 +383,7 @@ sctp_ulpevent_make_remote_error(const struct sctp_association *asoc,
 
 	ch = (sctp_errhdr_t *)(chunk->skb->data);
 	cause = ch->cause;
-	elen = WORD_ROUND(ntohs(ch->length)) - sizeof(sctp_errhdr_t);
+	elen = SCTP_ALIGN4(ntohs(ch->length)) - sizeof(sctp_errhdr_t);
 
 	/* Pull off the ERROR header.  */
 	skb_pull(chunk->skb, sizeof(sctp_errhdr_t));
@@ -688,7 +688,7 @@ struct sctp_ulpevent *sctp_ulpevent_make_rcvmsg(struct sctp_association *asoc,
 	 * MUST ignore the padding bytes.
 	 */
 	len = ntohs(chunk->chunk_hdr->length);
-	padding = WORD_ROUND(len) - len;
+	padding = SCTP_ALIGN4(len) - len;
 
 	/* Fixup cloned skb with just this chunks data.  */
 	skb_trim(skb, chunk->chunk_end - padding - skb->data);
-- 
2.7.4
