From: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
Subject: [PATCH net 02/11] net: thunderx: Fix memory leak while tearing down
 interface
Date: Wed, 29 Jul 2015 16:49:37 +0300
Message-ID: <1438177787-20940-3-git-send-email-aleksey.makarov@caviumnetworks.com>
References: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Robert Richter <rric@kernel.org>, David Daney <david.daney@cavium.com>,
 Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
 Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
 linux-kernel@vger.kernel.org,
 Robert Richter <robert.richter@caviumnetworks.com>,
 Sunil Goutham <sgoutham@cavium.com>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1438177787-20940-1-git-send-email-aleksey.makarov@caviumnetworks.com>
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

Fixed 'tso_hdrs' memory not being freed properly.
Also fixed SQ skbuff maintenance issues.

Signed-off-by: Sunil Goutham <sgoutham@cavium.com>
Signed-off-by: Aleksey Makarov <aleksey.makarov@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 1 +
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 8b119a0..2890cd6 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -425,6 +425,7 @@ static void nicvf_snd_pkt_handler(struct net_device *netdev,
 	if (skb) {
 		prefetch(skb);
 		dev_consume_skb_any(skb);
+		sq->skbuff[cqe_tx->sqe_ptr] = (u64)NULL;
 	}
 }
 
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 4dae6aa..4c91959 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -382,7 +382,8 @@ static void nicvf_free_snd_queue(struct nicvf *nic, struct snd_queue *sq)
 		return;
 
 	if (sq->tso_hdrs)
-		dma_free_coherent(&nic->pdev->dev, sq->dmem.q_len,
+		dma_free_coherent(&nic->pdev->dev,
+				  sq->dmem.q_len * TSO_HEADER_SIZE,
 				  sq->tso_hdrs, sq->tso_hdrs_phys);
 
 	kfree(sq->skbuff);
@@ -863,10 +864,11 @@ void nicvf_sq_free_used_descs(struct net_device *netdev, struct snd_queue *sq,
 			continue;
 		}
 		skb = (struct sk_buff *)sq->skbuff[sq->head];
+		if (skb)
+			dev_kfree_skb_any(skb);
 		atomic64_add(1, (atomic64_t *)&netdev->stats.tx_packets);
 		atomic64_add(hdr->tot_len,
 			     (atomic64_t *)&netdev->stats.tx_bytes);
-		dev_kfree_skb_any(skb);
 		nicvf_put_sq_desc(sq, hdr->subdesc_cnt + 1);
 	}
 }
@@ -1048,7 +1050,7 @@ static int nicvf_sq_append_tso(struct nicvf *nic, struct snd_queue *sq,
 		}
 		nicvf_sq_add_hdr_subdesc(sq, hdr_qentry,
 					 seg_subdescs - 1, skb, seg_len);
-		sq->skbuff[hdr_qentry] = 0;
+		sq->skbuff[hdr_qentry] = (u64)NULL;
 		qentry = nicvf_get_nxt_sqentry(sq, qentry);
 
 		desc_cnt += seg_subdescs;
-- 
2.4.6
