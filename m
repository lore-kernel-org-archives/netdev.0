From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 13/14] qlge: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:05 +0100
Message-ID: <1314787626-12273-13-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754713Ab1HaKrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:24 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index 39360c4..ce6c6fe 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1431,10 +1431,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 			map_idx++;
 		}
 
-		map =
-		    pci_map_page(qdev->pdev, frag->page,
-				 frag->page_offset, frag->size,
-				 PCI_DMA_TODEVICE);
+		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
 
 		err = pci_dma_mapping_error(qdev->pdev, map);
 		if (err) {
@@ -1477,8 +1475,6 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 {
 	struct sk_buff *skb;
 	struct bq_desc *lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
-	struct skb_frag_struct *rx_frag;
-	int nr_frags;
 	struct napi_struct *napi = &rx_ring->napi;
 
 	napi->dev = qdev->ndev;
@@ -1492,12 +1488,10 @@ static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 		return;
 	}
 	prefetch(lbq_desc->p.pg_chunk.va);
-	rx_frag = skb_shinfo(skb)->frags;
-	nr_frags = skb_shinfo(skb)->nr_frags;
-	rx_frag += nr_frags;
-	rx_frag->page = lbq_desc->p.pg_chunk.page;
-	rx_frag->page_offset = lbq_desc->p.pg_chunk.offset;
-	rx_frag->size = length;
+	__skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
+			     lbq_desc->p.pg_chunk.page,
+			     lbq_desc->p.pg_chunk.offset,
+			     length);
 
 	skb->len += length;
 	skb->data_len += length;
-- 
1.7.2.5
