From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 09/11] sctp: remove the typedef sctp_data_chunk_t
Date: Fri, 30 Jun 2017 11:52:20 +0800
Message-ID: <029bbe69851dfbdc58ffa19e9712fa84d54eb9b5.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
 <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
 <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
 <81c68360c17817528e46216d9d48168b35e44434.1498794482.git.lucien.xin@gmail.com>
 <e33aff0cf96df1a50ec1ead7a4d5101492df9aac.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35139 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbdF3Dx6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:58 -0400
In-Reply-To: <e33aff0cf96df1a50ec1ead7a4d5101492df9aac.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_data_chunk_t, and replace
with struct sctp_data_chunk in the places where it's using this
typedef.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h         | 4 ++--
 include/net/sctp/constants.h | 2 +-
 include/net/sctp/sm.h        | 2 +-
 net/sctp/output.c            | 4 ++--
 net/sctp/sm_statefuns.c      | 6 +++---
 net/sctp/ulpqueue.c          | 2 +-
 6 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 55d84c1..91c888f 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -235,10 +235,10 @@ struct sctp_datahdr {
 	__u8  payload[0];
 };
 
-typedef struct sctp_data_chunk {
+struct sctp_data_chunk {
 	struct sctp_chunkhdr chunk_hdr;
 	struct sctp_datahdr data_hdr;
-} sctp_data_chunk_t;
+};
 
 /* DATA Chuck Specific Flags */
 enum {
diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
index 02e867b..9b18044 100644
--- a/include/net/sctp/constants.h
+++ b/include/net/sctp/constants.h
@@ -152,7 +152,7 @@ SCTP_SUBTYPE_CONSTRUCTOR(PRIMITIVE,	sctp_event_primitive_t,	primitive)
 /* Calculate the actual data size in a data chunk */
 #define SCTP_DATA_SNDSIZE(c) ((int)((unsigned long)(c->chunk_end)\
 		       		- (unsigned long)(c->chunk_hdr)\
-				- sizeof(sctp_data_chunk_t)))
+				- sizeof(struct sctp_data_chunk)))
 
 /* Internal error codes */
 typedef enum {
diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index 245eb22..860f378 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -347,7 +347,7 @@ static inline __u16 sctp_data_size(struct sctp_chunk *chunk)
 	__u16 size;
 
 	size = ntohs(chunk->chunk_hdr->length);
-	size -= sizeof(sctp_data_chunk_t);
+	size -= sizeof(struct sctp_data_chunk);
 
 	return size;
 }
diff --git a/net/sctp/output.c b/net/sctp/output.c
index 89cee14..977ab5d 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -723,8 +723,8 @@ static sctp_xmit_t sctp_packet_can_append_data(struct sctp_packet *packet,
 	/* Check whether this chunk and all the rest of pending data will fit
 	 * or delay in hopes of bundling a full sized packet.
 	 */
-	if (chunk->skb->len + q->out_qlen >
-		transport->pathmtu - packet->overhead - sizeof(sctp_data_chunk_t) - 4)
+	if (chunk->skb->len + q->out_qlen > transport->pathmtu -
+		packet->overhead - sizeof(struct sctp_data_chunk) - 4)
 		/* Enough data queued to fill a packet */
 		return SCTP_XMIT_OK;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 1ba9a9b..212fe76 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2990,7 +2990,7 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 	}
 
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_data_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_data_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -3109,7 +3109,7 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
 	}
 
-	if (!sctp_chunk_length_valid(chunk, sizeof(sctp_data_chunk_t)))
+	if (!sctp_chunk_length_valid(chunk, sizeof(struct sctp_data_chunk)))
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
@@ -6262,7 +6262,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * Actually, allow a little bit of overflow (up to a MTU).
 	 */
 	datalen = ntohs(chunk->chunk_hdr->length);
-	datalen -= sizeof(sctp_data_chunk_t);
+	datalen -= sizeof(struct sctp_data_chunk);
 
 	deliver = SCTP_CMD_CHUNK_ULP;
 
diff --git a/net/sctp/ulpqueue.c b/net/sctp/ulpqueue.c
index 25f7e41..0225d62 100644
--- a/net/sctp/ulpqueue.c
+++ b/net/sctp/ulpqueue.c
@@ -1090,7 +1090,7 @@ void sctp_ulpq_renege(struct sctp_ulpq *ulpq, struct sctp_chunk *chunk,
 
 	if (chunk) {
 		needed = ntohs(chunk->chunk_hdr->length);
-		needed -= sizeof(sctp_data_chunk_t);
+		needed -= sizeof(struct sctp_data_chunk);
 	} else
 		needed = SCTP_DEFAULT_MAXWINDOW;
 
-- 
2.1.0
