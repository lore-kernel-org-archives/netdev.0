From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 18/21] net: thunderx: Use napi_consume_skb for bulk free
Date: Fri, 12 Aug 2016 16:51:41 +0530
Message-ID: <1471000904-21715-19-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch enables bulk freeing on the Tx side.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 0b68f2b..eb48d33 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -521,7 +521,8 @@ static int nicvf_init_resources(struct nicvf *nic)
 
 static void nicvf_snd_pkt_handler(struct net_device *netdev,
 				  struct cmp_queue *cq,
-				  struct cqe_send_t *cqe_tx, int cqe_type)
+				  struct cqe_send_t *cqe_tx,
+				  int cqe_type, int budget)
 {
 	struct sk_buff *skb = NULL;
 	struct nicvf *nic = netdev_priv(netdev);
@@ -545,7 +546,7 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 	if (skb) {
 		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 		prefetch(skb);
-		dev_consume_skb_any(skb);
+		napi_consume_skb(skb, budget);
 		sq->skbuff[cqe_tx->sqe_ptr] = (u64)NULL;
 	} else {
 		/* In case of HW TSO, HW sends a CQE for each segment of a TSO
@@ -700,7 +701,8 @@ loop:
 		break;
 		case CQE_TYPE_SEND:
 			nicvf_snd_pkt_handler(netdev, cq,
-					      (void *)cq_desc, CQE_TYPE_SEND);
+					      (void *)cq_desc, CQE_TYPE_SEND,
+					      budget);
 			tx_done++;
 		break;
 		case CQE_TYPE_INVALID:
-- 
2.7.4
