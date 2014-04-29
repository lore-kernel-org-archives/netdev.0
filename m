From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Subject: [PATCH V7 net-next 4/7] xen-netback: Correctly clean up
	after queue initialisation error.
Date: Tue, 29 Apr 2014 14:27:12 +0100
Message-ID: <1398778035-26233-5-git-send-email-andrew.bennieston@citrix.com>
References: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, ian.campbell@citrix.com, netdev@vger.kernel.org,
	paul.durrant@citrix.com, david.vrabel@citrix.com, zoltan.kiss@citrix.com,
	"Andrew J. Bennieston" <andrew.bennieston@citrix.com>
To: <xen-devel@lists.xenproject.org>, <davem@davemloft.net>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1398778035-26233-1-git-send-email-andrew.bennieston@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>

Multiple queues were introduced in the previous patch, but if the
initialisation of a queue failed, earlier queues would not be cleaned
up. This patch adds cleanup logic for this scenario, making use of code
from the regular teardown sequence.

Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
---
 drivers/net/xen-netback/common.h    |    1 +
 drivers/net/xen-netback/interface.c |   15 +++++++++++----
 drivers/net/xen-netback/xenbus.c    |   25 +++++++++++++++++++++++--
 3 files changed, 35 insertions(+), 6 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 50efc29..16d6a05 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -237,6 +237,7 @@ struct xenvif *xenvif_alloc(struct device *parent,
 			    unsigned int handle);
 
 int xenvif_init_queue(struct xenvif_queue *queue);
+void xenvif_deinit_queue(struct xenvif_queue *queue);
 
 int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
 		   unsigned long rx_ring_ref, unsigned int tx_evtchn,
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 0eb6941..3ded8e5 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -733,6 +733,16 @@ void xenvif_disconnect(struct xenvif *vif)
 	}
 }
 
+/* Reverse the relevant parts of xenvif_init_queue().
+ * Used for queue teardown from xenvif_free(), and on the
+ * error handling paths in xenbus.c:connect().
+ */
+void xenvif_deinit_queue(struct xenvif_queue *queue)
+{
+	free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
+	netif_napi_del(&queue->napi);
+}
+
 void xenvif_free(struct xenvif *vif)
 {
 	struct xenvif_queue *queue = NULL;
@@ -756,11 +766,8 @@ void xenvif_free(struct xenvif *vif)
 
 	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
 		queue = &vif->queues[queue_index];
-
 		xenvif_wait_unmap_timeout(queue, worst_case_skb_lifetime);
-		free_xenballooned_pages(MAX_PENDING_REQS, queue->mmap_pages);
-
-		netif_napi_del(&queue->napi);
+		xenvif_deinit_queue(queue);
 	}
 
 	/* Free the array of queues. The call below does not require
diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 9632e7a..96c63dc2 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -539,14 +539,33 @@ static void connect(struct backend_info *be)
 				be->vif->dev->name, queue->id);
 
 		err = xenvif_init_queue(queue);
-		if (err)
+		if (err) {
+			/* xenvif_init_queue() cleans up after itself on
+			 * failure, but we need to clean up any previously
+			 * initialised queues. Set num_queues to i so that
+			 * earlier queues can be destroyed using the regular
+			 * disconnect logic.
+			 */
+			rtnl_lock();
+			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
+			rtnl_unlock();
 			goto err;
+		}
 
 		queue->remaining_credit = credit_bytes;
 
 		err = connect_rings(be, queue);
-		if (err)
+		if (err) {
+			/* connect_rings() cleans up after itself on failure,
+			 * but we need to clean up after xenvif_init_queue() here,
+			 * and also clean up any previously initialised queues.
+			 */
+			xenvif_deinit_queue(queue);
+			rtnl_lock();
+			netif_set_real_num_tx_queues(be->vif->dev, queue_index);
+			rtnl_unlock();
 			goto err;
+		}
 	}
 
 	xenvif_carrier_on(be->vif);
@@ -563,6 +582,8 @@ static void connect(struct backend_info *be)
 	return;
 
 err:
+	if (be->vif->dev->real_num_tx_queues > 0)
+		xenvif_disconnect(be->vif); /* Clean up existing queues */
 	vfree(be->vif->queues);
 	be->vif->queues = NULL;
 	rtnl_lock();
-- 
1.7.10.4
