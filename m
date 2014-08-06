From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: [PATCH net-next] xen-netback: Fix vif->disable handling
Date: Wed, 6 Aug 2014 20:33:18 +0100
Message-ID: <1407353598-14185-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the patch called "xen-netback: Turn off the carrier if the guest is not able
to receive" new branches were introduced to this if statement, risking that a
queue with non-zero id can reenable the disabled interface.

Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: xen-devel@lists.xenproject.org

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index aa20933..f84516f 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -2027,7 +2027,13 @@ int xenvif_kthread_guest_rx(void *data)
 		 */
 		if (unlikely(queue->vif->disabled && queue->id == 0))
 			xenvif_carrier_off(queue->vif);
-		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
+		else if (unlikely(queue->vif->disabled)) {
+			/* kthread_stop() would be called upon this thread soon,
+			 * be a bit proactive
+			 */
+			skb_queue_purge(&queue->rx_queue);
+			queue->rx_last_skb_slots = 0;
+		} else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
 						     &queue->status))) {
 			xenvif_rx_purge_event(queue);
 		} else if (!netif_carrier_ok(queue->vif->dev)) {
