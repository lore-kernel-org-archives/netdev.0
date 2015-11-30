From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 11/13] net: thunderx: HW errata workaround for non-tunneled TSO pkts
Date: Mon, 30 Nov 2015 23:49:07 +0530
Message-ID: <1448907549-5296-12-git-send-email-sunil.kovvuri@gmail.com>
References: <y>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <y>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

A HW errata mandates inner layer3 offset field of send header for a non-tunneled 
TSO packet to point to L2 ethertype in the payload. Also added counter for HW 
TSO packets.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 5855828..4e9709e 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -943,8 +943,8 @@ static int nicvf_sq_subdesc_required(struct nicvf *nic, struct sk_buff *skb)
  * First subdescriptor for every send descriptor.
  */
 static inline void
-nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry, int subdesc_cnt,
-			 struct sk_buff *skb, int len, bool hw_tso)
+nicvf_sq_add_hdr_subdesc(struct nicvf *nic, struct snd_queue *sq, int qentry,
+			 int subdesc_cnt, struct sk_buff *skb, int len)
 {
 	int proto;
 	struct sq_hdr_subdesc *hdr;
@@ -980,10 +980,13 @@ nicvf_sq_add_hdr_subdesc(struct snd_queue *sq, int qentry, int subdesc_cnt,
 		}
 	}
 
-	if (hw_tso && skb_shinfo(skb)->gso_size) {
+	if (nic->hw_tso && skb_shinfo(skb)->gso_size) {
 		hdr->tso = 1;
 		hdr->tso_start = skb_transport_offset(skb) + tcp_hdrlen(skb);
 		hdr->tso_max_paysize = skb_shinfo(skb)->gso_size;
+		/* For non-tunneled pkts, point this to L2 ethertype */
+		hdr->inner_l3_offset = skb_network_offset(skb) - 2;
+		nic->drv_stats.tx_tso++;
 	}
 }
 
@@ -1054,8 +1057,8 @@ static int nicvf_sq_append_tso(struct nicvf *nic, struct snd_queue *sq,
 			data_left -= size;
 			tso_build_data(skb, &tso, size);
 		}
-		nicvf_sq_add_hdr_subdesc(sq, hdr_qentry,
-					 seg_subdescs - 1, skb, seg_len, false);
+		nicvf_sq_add_hdr_subdesc(nic, sq, hdr_qentry,
+					 seg_subdescs - 1, skb, seg_len);
 		sq->skbuff[hdr_qentry] = (u64)NULL;
 		qentry = nicvf_get_nxt_sqentry(sq, qentry);
 
@@ -1111,8 +1114,8 @@ int nicvf_sq_append_skb(struct nicvf *nic, struct sk_buff *skb)
 		return nicvf_sq_append_tso(nic, sq, sq_num, qentry, skb);
 
 	/* Add SQ header subdesc */
-	nicvf_sq_add_hdr_subdesc(sq, qentry, subdesc_cnt - 1, skb,
-				 skb->len, nic->hw_tso);
+	nicvf_sq_add_hdr_subdesc(nic, sq, qentry, subdesc_cnt - 1,
+				 skb, skb->len);
 
 	/* Add SQ gather subdescs */
 	qentry = nicvf_get_nxt_sqentry(sq, qentry);
-- 
1.7.1
