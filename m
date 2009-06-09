From: David Miller <davem@davemloft.net>
Subject: [PATCH 15/15]: be2net: Remove unnecessary frag list traversing.
Date: Tue, 09 Jun 2009 05:02:34 -0700 (PDT)
Message-ID: <20090609.050234.266955391.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760115AbZFIMCc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:32 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6056AC8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This driver does not indicate support for frag lists.

Furthermore, even if it did, the code is walking the frag
lists incorrectly.  The idiom is:

	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)

but it's doing:

	for (iter = skb_shinfo(skb)->frag_list; iter;
	     iter = skb_shinfo(iter)->frag_list)

which would never work.  And this proves that this driver never
saw an SKB with active frag lists.

So just remove the code altogether and the driver TX path becomes
much simpler.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/benet/be_main.c |   56 +++++++++++++++++++-----------------------
 1 files changed, 25 insertions(+), 31 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 5f17d80..347d002 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -337,13 +337,10 @@ static void be_tx_stats_update(struct be_adapter *adapter,
 /* Determine number of WRB entries needed to xmit data in an skb */
 static u32 wrb_cnt_for_skb(struct sk_buff *skb, bool *dummy)
 {
-	int cnt = 0;
-	while (skb) {
-		if (skb->len > skb->data_len)
-			cnt++;
-		cnt += skb_shinfo(skb)->nr_frags;
-		skb = skb_shinfo(skb)->frag_list;
-	}
+	int cnt = (skb->len > skb->data_len);
+
+	cnt += skb_shinfo(skb)->nr_frags;
+
 	/* to account for hdr wrb */
 	cnt++;
 	if (cnt & 1) {
@@ -409,31 +406,28 @@ static int make_tx_wrbs(struct be_adapter *adapter,
 	hdr = queue_head_node(txq);
 	queue_head_inc(txq);
 
-	while (skb) {
-		if (skb->len > skb->data_len) {
-			int len = skb->len - skb->data_len;
-			busaddr = pci_map_single(pdev, skb->data, len,
-					PCI_DMA_TODEVICE);
-			wrb = queue_head_node(txq);
-			wrb_fill(wrb, busaddr, len);
-			be_dws_cpu_to_le(wrb, sizeof(*wrb));
-			queue_head_inc(txq);
-			copied += len;
-		}
+	if (skb->len > skb->data_len) {
+		int len = skb->len - skb->data_len;
+		busaddr = pci_map_single(pdev, skb->data, len,
+					 PCI_DMA_TODEVICE);
+		wrb = queue_head_node(txq);
+		wrb_fill(wrb, busaddr, len);
+		be_dws_cpu_to_le(wrb, sizeof(*wrb));
+		queue_head_inc(txq);
+		copied += len;
+	}
 
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			struct skb_frag_struct *frag =
-				&skb_shinfo(skb)->frags[i];
-			busaddr = pci_map_page(pdev, frag->page,
-					frag->page_offset,
-					frag->size, PCI_DMA_TODEVICE);
-			wrb = queue_head_node(txq);
-			wrb_fill(wrb, busaddr, frag->size);
-			be_dws_cpu_to_le(wrb, sizeof(*wrb));
-			queue_head_inc(txq);
-			copied += frag->size;
-		}
-		skb = skb_shinfo(skb)->frag_list;
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		struct skb_frag_struct *frag =
+			&skb_shinfo(skb)->frags[i];
+		busaddr = pci_map_page(pdev, frag->page,
+				       frag->page_offset,
+				       frag->size, PCI_DMA_TODEVICE);
+		wrb = queue_head_node(txq);
+		wrb_fill(wrb, busaddr, frag->size);
+		be_dws_cpu_to_le(wrb, sizeof(*wrb));
+		queue_head_inc(txq);
+		copied += frag->size;
 	}
 
 	if (dummy_wrb) {
-- 
1.6.3.2

