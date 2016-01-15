From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 3/3] xen-netback: free queues after freeing
	the net device
Date: Fri, 15 Jan 2016 14:55:36 +0000
Message-ID: <1452869736-20282-4-git-send-email-david.vrabel@citrix.com>
References: <1452869736-20282-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1452869736-20282-1-git-send-email-david.vrabel@citrix.com>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

If a queue still has a NAPI instance added to the net device, freeing
the queues early results in a use-after-free.

The shouldn't ever happen because we disconnect and tear down all queues
before freeing the net device, but doing this makes it obviously safe.

Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/interface.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 3bba6ce..f5231a2 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -685,22 +685,16 @@ void xenvif_deinit_queue(struct xenvif_queue *queue)
 
 void xenvif_free(struct xenvif *vif)
 {
-	struct xenvif_queue *queue = NULL;
+	struct xenvif_queue *queues = vif->queues;
 	unsigned int num_queues = vif->num_queues;
 	unsigned int queue_index;
 
 	unregister_netdev(vif->dev);
-
-	for (queue_index = 0; queue_index < num_queues; ++queue_index) {
-		queue = &vif->queues[queue_index];
-		xenvif_deinit_queue(queue);
-	}
-
-	vfree(vif->queues);
-	vif->queues = NULL;
-	vif->num_queues = 0;
-
 	free_netdev(vif->dev);
 
+	for (queue_index = 0; queue_index < num_queues; ++queue_index)
+		xenvif_deinit_queue(&queues[queue_index]);
+	vfree(queues);
+
 	module_put(THIS_MODULE);
 }
-- 
2.1.4
