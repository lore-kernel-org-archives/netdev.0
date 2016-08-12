From: sunil.kovvuri@gmail.com
Subject: [PATCH v2 14/21] net: thunderx: Use skb_add_rx_frag() for split buffer Rx pkts
Date: Fri, 12 Aug 2016 16:51:37 +0530
Message-ID: <1471000904-21715-15-git-send-email-sunil.kovvuri@gmail.com>
References: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil Goutham <sgoutham@cavium.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471000904-21715-1-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sunil Goutham <sgoutham@cavium.com>

Instead of a round about way of converting buffers to SKBs and
combining them into a frag list, use standard skb_add_rx_frag()
API to merge page fragments. This code is useful when incoming
packets are of size more than RCV_FRAG_LEN which is currently
set to 2048bytes.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 24 ++++++----------------
 1 file changed, 6 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index ca223aa..ed2fe72 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -1184,8 +1184,8 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 	int frag;
 	int payload_len = 0;
 	struct sk_buff *skb = NULL;
-	struct sk_buff *skb_frag = NULL;
-	struct sk_buff *prev_frag = NULL;
+	struct page *page;
+	int offset;
 	u16 *rb_lens = NULL;
 	u64 *rb_ptrs = NULL;
 
@@ -1218,22 +1218,10 @@ struct sk_buff *nicvf_get_rcv_skb(struct nicvf *nic, struct cqe_rx_t *cqe_rx)
 			skb_put(skb, payload_len);
 		} else {
 			/* Add fragments */
-			skb_frag = nicvf_rb_ptr_to_skb(nic, *rb_ptrs,
-						       payload_len);
-			if (!skb_frag) {
-				dev_kfree_skb(skb);
-				return NULL;
-			}
-
-			if (!skb_shinfo(skb)->frag_list)
-				skb_shinfo(skb)->frag_list = skb_frag;
-			else
-				prev_frag->next = skb_frag;
-
-			prev_frag = skb_frag;
-			skb->len += payload_len;
-			skb->data_len += payload_len;
-			skb_frag->len = payload_len;
+			page = virt_to_page(phys_to_virt(*rb_ptrs));
+			offset = phys_to_virt(*rb_ptrs) - page_address(page);
+			skb_add_rx_frag(skb, skb_shinfo(skb)->nr_frags, page,
+					offset, payload_len, RCV_FRAG_LEN);
 		}
 		/* Next buffer pointer */
 		rb_ptrs++;
-- 
2.7.4
