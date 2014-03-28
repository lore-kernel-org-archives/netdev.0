From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH v3 net 3/3] xen-netback: BUG_ON in xenvif_rx_action() not catching overflow
Date: Fri, 28 Mar 2014 11:39:07 +0000
Message-ID: <1396006747-9113-4-git-send-email-paul.durrant@citrix.com>
References: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:44316 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751000AbaC1LjL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 07:39:11 -0400
In-Reply-To: <1396006747-9113-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BUG_ON to catch ring overflow in xenvif_rx_action() makes the assumption
that meta_slots_used == ring slots used. This is not necessarily the case
for GSO packets, because the non-prefix GSO protocol consumes one more ring
slot than meta-slot for the 'extra_info'. This patch changes the test to
actually check ring slots.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Sander Eikelenboom <linux@eikelenboom.it>
---
 drivers/net/xen-netback/netback.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 573f3e8..cd0bd95 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -482,6 +482,8 @@ static void xenvif_rx_action(struct xenvif *vif)
 
 	while ((skb = skb_dequeue(&vif->rx_queue)) != NULL) {
 		RING_IDX max_slots_needed;
+		RING_IDX old_req_cons;
+		RING_IDX ring_slots_used;
 		int i;
 
 		/* We need a cheap worse case estimate for the number of
@@ -530,8 +532,12 @@ static void xenvif_rx_action(struct xenvif *vif)
 			vif->rx_last_skb_slots = 0;
 
 		sco = (struct skb_cb_overlay *)skb->cb;
+
+		old_req_cons = vif->rx.req_cons;
 		sco->meta_slots_used = xenvif_gop_skb(skb, &npo);
-		BUG_ON(sco->meta_slots_used > max_slots_needed);
+		ring_slots_used = vif->rx.req_cons - old_req_cons;
+
+		BUG_ON(ring_slots_used > max_slots_needed);
 
 		__skb_queue_tail(&rxq, skb);
 	}
-- 
1.7.10.4
