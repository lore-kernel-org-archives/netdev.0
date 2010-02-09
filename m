From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-2.6] cxgb3: fix GRO checksum check
Date: Mon, 08 Feb 2010 16:55:44 -0800
Message-ID: <20100209005544.12679.3987.stgit@speedy5.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Verify the HW checksum state for frames handed to GRO processing.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)


diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index bdbd147..318a018 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2079,6 +2079,7 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 			 struct sge_fl *fl, int len, int complete)
 {
 	struct rx_sw_desc *sd = &fl->sdesc[fl->cidx];
+	struct port_info *pi = netdev_priv(qs->netdev);
 	struct sk_buff *skb = NULL;
 	struct cpl_rx_pkt *cpl;
 	struct skb_frag_struct *rx_frag;
@@ -2116,11 +2117,18 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 
 	if (!nr_frags) {
 		offset = 2 + sizeof(struct cpl_rx_pkt);
-		qs->lro_va = sd->pg_chunk.va + 2;
-	}
-	len -= offset;
+		cpl = qs->lro_va = sd->pg_chunk.va + 2;
 
-	prefetch(qs->lro_va);
+		if ((pi->rx_offload & T3_RX_CSUM) &&
+		     cpl->csum_valid && cpl->csum == htons(0xffff)) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
+		} else
+			skb->ip_summed = CHECKSUM_NONE;
+	} else
+		cpl = qs->lro_va;
+
+	len -= offset;
 
 	rx_frag += nr_frags;
 	rx_frag->page = sd->pg_chunk.page;
@@ -2136,12 +2144,8 @@ static void lro_add_page(struct adapter *adap, struct sge_qset *qs,
 		return;
 
 	skb_record_rx_queue(skb, qs - &adap->sge.qs[0]);
-	skb->ip_summed = CHECKSUM_UNNECESSARY;
-	cpl = qs->lro_va;
 
 	if (unlikely(cpl->vlan_valid)) {
-		struct net_device *dev = qs->netdev;
-		struct port_info *pi = netdev_priv(dev);
 		struct vlan_group *grp = pi->vlan_grp;
 
 		if (likely(grp != NULL)) {
