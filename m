From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 06/14] sctp: remove the typedef sctp_ecnehdr_t
Date: Thu,  3 Aug 2017 15:42:14 +0800
Message-ID: <bc49ca93eba1ba96461674afe5fadc441f8d288a.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
 <8149f8b0a190eb047abfe48a7fa79ba74e4e4544.1501745729.git.lucien.xin@gmail.com>
 <457c0c30e478f1ead75d3606e17519ca23daddfc.1501745729.git.lucien.xin@gmail.com>
 <ef0bf503017711311e9fc167c4b5bfd9de885d04.1501745729.git.lucien.xin@gmail.com>
 <61746e2a2efa75634ab632cf264ad902aa3f9685.1501745729.git.lucien.xin@gmail.com>
 <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35956 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751067AbdHCHnc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 03:43:32 -0400
In-Reply-To: <91fc6fd265b6623a2244f17a9e5581962a2183d0.1501745729.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1501745729.git.lucien.xin@gmail.com>
References: <cover.1501745729.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_ecnehdr_t, and
replace with struct sctp_ecnehdr in the places where it's
using this typedef.

It is also to use sizeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h     | 6 +++---
 net/sctp/sm_make_chunk.c | 4 ++--
 net/sctp/sm_statefuns.c  | 6 +++---
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index c74ea93..5ea739b 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -519,13 +519,13 @@ enum sctp_error {
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
  *   Explicit Congestion Notification Echo (ECNE) (12)
  */
-typedef struct sctp_ecnehdr {
+struct sctp_ecnehdr {
 	__be32 lowest_tsn;
-} sctp_ecnehdr_t;
+};
 
 typedef struct sctp_ecne_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_ecnehdr_t ence_hdr;
+	struct sctp_ecnehdr ence_hdr;
 } sctp_ecne_chunk_t;
 
 /* RFC 2960.  Appendix A.  Explicit Congestion Notification.
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 0b2298b..1c7cc6a 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -697,11 +697,11 @@ struct sctp_chunk *sctp_make_ecne(const struct sctp_association *asoc,
 			     const __u32 lowest_tsn)
 {
 	struct sctp_chunk *retval;
-	sctp_ecnehdr_t ecne;
+	struct sctp_ecnehdr ecne;
 
 	ecne.lowest_tsn = htonl(lowest_tsn);
 	retval = sctp_make_control(asoc, SCTP_CID_ECN_ECNE, 0,
-				   sizeof(sctp_ecnehdr_t), GFP_ATOMIC);
+				   sizeof(ecne), GFP_ATOMIC);
 	if (!retval)
 		goto nodata;
 	retval->subh.ecne_hdr =
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 1d12499..de3e5bf 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -2918,8 +2918,8 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 				   void *arg,
 				   sctp_cmd_seq_t *commands)
 {
-	sctp_ecnehdr_t *ecne;
 	struct sctp_chunk *chunk = arg;
+	struct sctp_ecnehdr *ecne;
 
 	if (!sctp_vtag_verify(chunk, asoc))
 		return sctp_sf_pdiscard(net, ep, asoc, type, arg, commands);
@@ -2928,8 +2928,8 @@ sctp_disposition_t sctp_sf_do_ecne(struct net *net,
 		return sctp_sf_violation_chunklen(net, ep, asoc, type, arg,
 						  commands);
 
-	ecne = (sctp_ecnehdr_t *) chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_ecnehdr_t));
+	ecne = (struct sctp_ecnehdr *)chunk->skb->data;
+	skb_pull(chunk->skb, sizeof(*ecne));
 
 	/* If this is a newer ECNE than the last CWR packet we sent out */
 	sctp_add_cmd_sf(commands, SCTP_CMD_ECN_ECNE,
-- 
2.1.0
