From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next 5/7] xen-netback: process guest rx packets in batches
Date: Mon, 3 Oct 2016 08:31:10 +0100
Message-ID: <1475479872-23717-6-git-send-email-paul.durrant@citrix.com>
References: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
        Paul Durrant <paul.durrant@citrix.com>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:41213 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751140AbcJCHuz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Oct 2016 03:50:55 -0400
In-Reply-To: <1475479872-23717-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Vrabel <david.vrabel@citrix.com>

Instead of only placing one skb on the guest rx ring at a time, process
a batch of up-to 64.  This improves performance by ~10% in some tests.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
[re-based]
Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
---
Cc: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/rx.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/rx.c b/drivers/net/xen-netback/rx.c
index 9548709..ae822b8 100644
--- a/drivers/net/xen-netback/rx.c
+++ b/drivers/net/xen-netback/rx.c
@@ -399,7 +399,7 @@ static void xenvif_rx_extra_slot(struct xenvif_queue *queue,
 	BUG();
 }
 
-void xenvif_rx_action(struct xenvif_queue *queue)
+void xenvif_rx_skb(struct xenvif_queue *queue)
 {
 	struct xenvif_pkt_state pkt;
 
@@ -425,6 +425,19 @@ void xenvif_rx_action(struct xenvif_queue *queue)
 	xenvif_rx_complete(queue, &pkt);
 }
 
+#define RX_BATCH_SIZE 64
+
+void xenvif_rx_action(struct xenvif_queue *queue)
+{
+	unsigned int work_done = 0;
+
+	while (xenvif_rx_ring_slots_available(queue) &&
+	       work_done < RX_BATCH_SIZE) {
+		xenvif_rx_skb(queue);
+		work_done++;
+	}
+}
+
 static bool xenvif_rx_queue_stalled(struct xenvif_queue *queue)
 {
 	RING_IDX prod, cons;
-- 
2.1.4
