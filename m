From: Sunil Goutham <sunil.kovvuri@gmail.com>
Subject: [PATCH 12/13] net: thunderx: Fix for duplicate CQEs by HW for TSO packets
Date: Mon, 30 Nov 2015 23:49:08 +0530
Message-ID: <1448907549-5296-13-git-send-email-sunil.kovvuri@gmail.com>
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

HW sends a CQE for each segment of a TSO packet instead of a single CQE
for whole TSO packet transmitted. Each of this CQE points to the same SQE.
SW should takecare of not freeing same SQE multiple times.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 51bbe67..a75f21f 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -525,14 +525,20 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 		   __func__, cqe_tx->sq_qs, cqe_tx->sq_idx,
 		   cqe_tx->sqe_ptr, hdr->subdesc_cnt);
 
-	nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 	nicvf_check_cqe_tx_errs(nic, cq, cqe_tx);
 	skb = (struct sk_buff *)sq->skbuff[cqe_tx->sqe_ptr];
-	/* For TSO offloaded packets only one head SKB needs to be freed */
+	/* For SW TSO offloaded packets only one head SKB needs to be freed */
 	if (skb) {
+		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 		prefetch(skb);
 		dev_consume_skb_any(skb);
 		sq->skbuff[cqe_tx->sqe_ptr] = (u64)NULL;
+	} else {
+		/* In case of HW TSO, a CQE_TX is added by HW for each segment.
+		 * Free SQEs only once.
+		 */
+		if (!nic->hw_tso)
+			nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 	}
 }
 
-- 
1.7.1
