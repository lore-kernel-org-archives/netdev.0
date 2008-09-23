From: David Miller <davem@davemloft.net>
Subject: [PATCH 5/7]: bluetooth: hci_bcsp: Use SKB list interfaces instead
 of home-grown stuff.
Date: Mon, 22 Sep 2008 19:12:41 -0700 (PDT)
Message-ID: <20080922.191241.229288039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37179
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754131AbYIWCMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 22:12:53 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id E6EB1C8C181
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 19:12:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


bluetooth: hci_bcsp: Use SKB list interfaces instead of home-grown stuff.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/bluetooth/hci_bcsp.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/bluetooth/hci_bcsp.c b/drivers/bluetooth/hci_bcsp.c
index 4d37bb3..7938062 100644
--- a/drivers/bluetooth/hci_bcsp.c
+++ b/drivers/bluetooth/hci_bcsp.c
@@ -352,14 +352,14 @@ static int bcsp_flush(struct hci_uart *hu)
 /* Remove ack'ed packets */
 static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 {
+	struct sk_buff *skb, *tmp;
 	unsigned long flags;
-	struct sk_buff *skb;
 	int i, pkts_to_be_removed;
 	u8 seqno;
 
 	spin_lock_irqsave(&bcsp->unack.lock, flags);
 
-	pkts_to_be_removed = bcsp->unack.qlen;
+	pkts_to_be_removed = skb_queue_len(&bcsp->unack);
 	seqno = bcsp->msgq_txseq;
 
 	while (pkts_to_be_removed) {
@@ -373,19 +373,19 @@ static void bcsp_pkt_cull(struct bcsp_struct *bcsp)
 		BT_ERR("Peer acked invalid packet");
 
 	BT_DBG("Removing %u pkts out of %u, up to seqno %u",
-		pkts_to_be_removed, bcsp->unack.qlen, (seqno - 1) & 0x07);
+	       pkts_to_be_removed, skb_queue_len(&bcsp->unack),
+	       (seqno - 1) & 0x07);
 
-	for (i = 0, skb = ((struct sk_buff *) &bcsp->unack)->next; i < pkts_to_be_removed
-			&& skb != (struct sk_buff *) &bcsp->unack; i++) {
-		struct sk_buff *nskb;
+	i = 0;
+	skb_queue_walk_safe(&bcsp->unack, skb, tmp) {
+		if (i++ >= pkts_to_be_removed)
+			break;
 
-		nskb = skb->next;
 		__skb_unlink(skb, &bcsp->unack);
 		kfree_skb(skb);
-		skb = nskb;
 	}
 
-	if (bcsp->unack.qlen == 0)
+	if (skb_queue_empty(&bcsp->unack))
 		del_timer(&bcsp->tbcsp);
 
 	spin_unlock_irqrestore(&bcsp->unack.lock, flags);
-- 
1.5.6.5

