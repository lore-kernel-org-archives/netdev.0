From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 01/14] sctp: remove the typedef sctp_shutdownhdr_t
Date: Thu,  3 Aug 2017 15:42:09 +0800
Message-ID: <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34787 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751083AbdHCHmk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:42:40 -0400
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_shutdownhdr_t, and
replace with struct sctp_shutdownhdr in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     |  6 +++---
 net/sctp/sm_make_chunk.c |  4 ++--
 net/sctp/sm_statefuns.c  | 10 +++++-----
 3 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index ba00716..7a586ba 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -416,13 +416,13 @@ struct sctp_abort_chunk {
 /* For the graceful shutdown we must carry the tag (in common header)
  * and the highest consecutive acking value.
  */
-typedef struct sctp_shutdownhdr {
+struct sctp_shutdownhdr {
 	__be32 cum_tsn_ack;
-} sctp_shutdownhdr_t;
+};
 
 struct sctp_shutdown_chunk_t {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_shutdownhdr_t shutdown_hdr;
+	struct sctp_shutdownhdr shutdown_hdr;
 };
 
 /* RFC 2960.  Section 3.3.10 Operation Error (ERROR) (9) */
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 163004e..8f1c6b6 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -857,15 +857,15 @@ struct sctp_chunk *sctp_make_sack(const struct sctp_association *asoc)
 struct sctp_chunk *sctp_make_shutdown(const struct sctp_association *asoc,
 				      const struct sctp_chunk *chunk)
 {
+	struct sctp_shutdownhdr shut;
 	struct sctp_chunk *retval;
-	sctp_shutdownhdr_t shut;
 	__u32 ctsn;
 
 	ctsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map);
 	shut.cum_tsn_ack = htonl(ctsn);
 
 	retval = sctp_make_control(asoc, SCTP_CID_SHUTDOWN, 0,
-				   sizeof(sctp_shutdownhdr_t), GFP_ATOMIC);
+				   sizeof(shut), GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index dc0c2c4..5b95e2d 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2656,8 +2656,8 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 					   sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_shutdownhdr_t *sdh;
 	sctp_disposition_t disposition;
+	struct sctp_shutdownhdr *sdh;
 	struct sctp_ulpevent *ev;
 	__u32 ctsn;
 
@@ -2671,8 +2671,8 @@ sctp_disposition_t sctp_sf_do_9_2_shutdown(struct net *net,
 						  commands);
 
 	/* Convert the elaborate header.  */
-	sdh = (sctp_shutdownhdr_t *)chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_shutdownhdr_t));
+	sdh = (struct sctp_shutdownhdr *)chunk->skb->data;
+	skb_pull(chunk->skb, sizeof(*sdh));
 	chunk->subh.shutdown_hdr = sdh;
 	ctsn = ntohl(sdh->cum_tsn_ack);
 
@@ -2746,7 +2746,7 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 					   sctp_cmd_seq_t *commands)
 {
 	struct sctp_chunk *chunk = arg;
-	sctp_shutdownhdr_t *sdh;
+	struct sctp_shutdownhdr *sdh;
 	__u32 ctsn;
 
 	if (!sctp_vtag_verify(chunk, asoc))
@@ -2758,7 +2758,7 @@ sctp_disposition_t sctp_sf_do_9_2_shut_ctsn(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	sdh = (sctp_shutdownhdr_t *)chunk->skb->data;
+	sdh = (struct sctp_shutdownhdr *)chunk->skb->data;
 	ctsn = ntohl(sdh->cum_tsn_ack);
 
 	if (TSN_lt(ctsn, asoc->ctsn_ack_point)) {
-- 
2.1.0
