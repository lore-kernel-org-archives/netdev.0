From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 08/11] sctp: remove the typedef sctp_datahdr_t
Date: Fri, 30 Jun 2017 11:52:19 +0800
Message-ID: <e33aff0cf96df1a50ec1ead7a4d5101492df9aac.1498794482.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
 <d99d14fbe257b7d7b290296646772c6df35a36c8.1498794482.git.lucien.xin@gmail.com>
 <9b26ac600c9c3f9426b370ecd69261c25d220b2b.1498794482.git.lucien.xin@gmail.com>
 <d522a5f819078da037df984f9fa1897b0cf57433.1498794482.git.lucien.xin@gmail.com>
 <bd4d24bbff8ff402d30c8a148f6ea4332beb5005.1498794482.git.lucien.xin@gmail.com>
 <2ae031641ce87e8fa77af7d3ea31b163f6c25f3d.1498794482.git.lucien.xin@gmail.com>
 <794094c6a1a0fdbf5374c983b2558e1316a51fd4.1498794482.git.lucien.xin@gmail.com>
 <81c68360c17817528e46216d9d48168b35e44434.1498794482.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34687 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbdF3Dxz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 23:53:55 -0400
In-Reply-To: <81c68360c17817528e46216d9d48168b35e44434.1498794482.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1498794481.git.lucien.xin@gmail.com>
References: <cover.1498794481.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to remove the typedef sctp_datahdr_t, and replace with
struct sctp_datahdr in the places where it's using this typedef.

It is also to use izeof(variable) instead of sizeof(type).

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/sctp.h    |  6 +++---
 net/sctp/sm_statefuns.c | 13 ++++++++-----
 2 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/sctp.h b/include/linux/sctp.h
index d5c0dda..55d84c1 100644
--- a/include/linux/sctp.h
+++ b/include/linux/sctp.h
@@ -227,17 +227,17 @@ enum { SCTP_PARAM_ACTION_MASK = cpu_to_be16(0xc000), };
 
 /* RFC 2960 Section 3.3.1 Payload Data (DATA) (0) */
 
-typedef struct sctp_datahdr {
+struct sctp_datahdr {
 	__be32 tsn;
 	__be16 stream;
 	__be16 ssn;
 	__be32 ppid;
 	__u8  payload[0];
-} sctp_datahdr_t;
+};
 
 typedef struct sctp_data_chunk {
 	struct sctp_chunkhdr chunk_hdr;
-	sctp_datahdr_t  data_hdr;
+	struct sctp_datahdr data_hdr;
 } sctp_data_chunk_t;
 
 /* DATA Chuck Specific Flags */
diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index 0a01c68..1ba9a9b 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -3010,7 +3010,8 @@ sctp_disposition_t sctp_sf_eat_data_6_2(struct net *net,
 		return SCTP_DISPOSITION_ABORT;
 	case SCTP_IERROR_PROTO_VIOLATION:
 		return sctp_sf_abort_violation(net, ep, asoc, chunk, commands,
-			(u8 *)chunk->subh.data_hdr, sizeof(sctp_datahdr_t));
+					       (u8 *)chunk->subh.data_hdr,
+					       sizeof(struct sctp_datahdr));
 	default:
 		BUG();
 	}
@@ -3124,7 +3125,8 @@ sctp_disposition_t sctp_sf_eat_data_fast_4_4(struct net *net,
 		return SCTP_DISPOSITION_ABORT;
 	case SCTP_IERROR_PROTO_VIOLATION:
 		return sctp_sf_abort_violation(net, ep, asoc, chunk, commands,
-			(u8 *)chunk->subh.data_hdr, sizeof(sctp_datahdr_t));
+					       (u8 *)chunk->subh.data_hdr,
+					       sizeof(struct sctp_datahdr));
 	default:
 		BUG();
 	}
@@ -6197,7 +6199,7 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 			 struct sctp_chunk *chunk,
 			 sctp_cmd_seq_t *commands)
 {
-	sctp_datahdr_t *data_hdr;
+	struct sctp_datahdr *data_hdr;
 	struct sctp_chunk *err;
 	size_t datalen;
 	sctp_verb_t deliver;
@@ -6210,8 +6212,9 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	u16 sid;
 	u8 ordered = 0;
 
-	data_hdr = chunk->subh.data_hdr = (sctp_datahdr_t *)chunk->skb->data;
-	skb_pull(chunk->skb, sizeof(sctp_datahdr_t));
+	data_hdr = (struct sctp_datahdr *)chunk->skb->data;
+	chunk->subh.data_hdr = data_hdr;
+	skb_pull(chunk->skb, sizeof(*data_hdr));
 
 	tsn = ntohl(data_hdr->tsn);
 	pr_debug("%s: TSN 0x%x\n", __func__, tsn);
-- 
2.1.0
