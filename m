From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/14] sctp: remove the typedef sctp_cwrhdr_t
Date: Thu,  3 Aug 2017 15:42:16 +0800
Message-ID: <cd4fd6410dd3ee98ea8462b2b9eb8af3b39d536a.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
 <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
 <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35467 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:59 -0400
In-Reply-To: <a5a3e5ce57d84377d2426a010f92d2afb5ca346d.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_cwrhdr_t, and
replace with struct sctp_cwrhdr in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 6 +++---
 net/sctp/sm_make_chunk.c | 4 ++--
 net/sctp/sm_statefuns.c  | 6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index 026bbdf..3c8c418 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -531,13 +531,13 @@ struct sctp_ecne_chunk {
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Congestion Window Reduced (CWR) (13)
  */
-typedef struct sctp_cwrhdr {
+struct sctp_cwrhdr {
 	__be32 lowest_tsn;
-} sctp_cwrhdr_t;
+};
 
 typedef struct sctp_cwr_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_cwrhdr_t cwr_hdr;
+	struct sctp_cwrhdr cwr_hdr;
 } sctp_cwr_chunk_t;
 
 /* PR-SCTP
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 1c7cc6a..e8e5065 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -663,11 +663,11 @@ struct sctp_chunk *sctp_make_cwr(const struct sctp_association *asoc,
 			    const struct sctp_chunk *chunk)
 {
 	struct sctp_chunk *retval;
-	sctp_cwrhdr_t cwr;
+	struct sctp_cwrhdr cwr;
 
 	cwr.lowest_tsn = htonl(lowest_tsn);
 	retval = sctp_make_control(asoc, SCTP_CID_ECN_CWR, 0,
-				   sizeof(sctp_cwrhdr_t), GFP_ATOMIC);
+				   sizeof(cwr), GFP_ATOMIC);
 
 	if (!retval)
 		goto nodata;
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 286dce1..e13c83f 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2862,8 +2862,8 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 				      void *arg,
 				      sctp_cmd_seq_t *commands)
 {
-	sctp_cwrhdr_t *cwr;
 	struct sctp_chunk *chunk = arg;
+	struct sctp_cwrhdr *cwr;
 	u32 lowest_tsn;
 
 	if (!sctp_vtag_verify(chunk, asoc))
@@ -2873,8 +2873,8 @@ sctp_disposition_t sctp_sf_do_ecn_cwr(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	cwr = (sctp_cwrhdr_t *) chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_cwrhdr_t));
+	cwr = (struct sctp_cwrhdr *)chunk->skb->data;
+	skb_pull(chunk->skb, sizeof(*cwr));
 
 	lowest_tsn = ntohl(cwr->lowest_tsn);
 
-- 
2.1.0
