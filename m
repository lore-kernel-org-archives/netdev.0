From: sunil.kovvuri@gmail.com
Subject: [PATCH 18/21] net: thunderx: Use napi_consume_skb for bulk free
Date: Wed, 10 Aug 2016 12:12:50 +0530
Message-ID: <1470811373-28277-19-git-send-email-sunil.kovvuri@gmail.com>
References: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Sunil Goutham <sgoutham@cavium.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1470811373-28277-1-git-send-email-sunil.kovvuri@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

This patch enables bulk freeing on the Tx side.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 4a084ab..e73e6df 100644
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
