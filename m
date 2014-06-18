From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCH 1/2] xen-netfront: fix oops when disconnected
	from backend
Date: Wed, 18 Jun 2014 10:47:27 +0100
Message-ID: <1403084848-12872-2-git-send-email-david.vrabel@citrix.com>
References: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1403084848-12872-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

xennet_disconnect_backend() was not correctly iterating over all the
queues.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netfront.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 5a7872a..daaf1e5 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1287,7 +1287,7 @@ static irqreturn_t xennet_rx_interrupt(int irq, void *dev_id)
 
 	if (likely(netif_carrier_ok(dev) &&
 		   RING_HAS_UNCONSUMED_RESPONSES(&queue->rx)))
-			napi_schedule(&queue->napi);
+		napi_schedule(&queue->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1437,10 +1437,11 @@ static void xennet_end_access(int ref, void *page)
 static void xennet_disconnect_backend(struct netfront_info *info)
 {
 	unsigned int i = 0;
-	struct netfront_queue *queue = NULL;
 	unsigned int num_queues = info->netdev->real_num_tx_queues;
 
 	for (i = 0; i < num_queues; ++i) {
+		struct netfront_queue *queue = &info->queues[i];
+
 		/* Stop old i/f to prevent errors whilst we rebuild the state. */
 		spin_lock_bh(&queue->rx_lock);
 		spin_lock_irq(&queue->tx_lock);
-- 
1.7.10.4
