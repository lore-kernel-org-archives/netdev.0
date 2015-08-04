From: Ross Lagerwall <ross.lagerwall@citrix.com>
Subject: [PATCH v2] xen/netback: Wake dealloc thread after
	completing zerocopy work
Date: Tue, 4 Aug 2015 15:40:59 +0100
Message-ID: <1438699259-28508-1-git-send-email-ross.lagerwall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>, Ian
	Campbell <ian.campbell@citrix.com>,
	Ross Lagerwall <ross.lagerwall@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <http://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <http://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Sender: xen-devel-bounces@lists.xen.org
Errors-To: xen-devel-bounces@lists.xen.org
List-Id: netdev.vger.kernel.org

Waking the dealloc thread before decrementing inflight_packets is racy
because it means the thread may go to sleep before inflight_packets is
decremented. If kthread_stop() has already been called, the dealloc
thread may wait forever with nothing to wake it. Instead, wake the
thread only after decrementing inflight_packets.

Signed-off-by: Ross Lagerwall <ross.lagerwall@citrix.com>
---
Changed in V2: Move wakeup into zerocopy_complete function.

 drivers/net/xen-netback/interface.c | 6 ++++++
 drivers/net/xen-netback/netback.c   | 1 -
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 1a83e19..28577a3 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -61,6 +61,12 @@ void xenvif_skb_zerocopy_prepare(struct xenvif_queue *queue,
 void xenvif_skb_zerocopy_complete(struct xenvif_queue *queue)
 {
 	atomic_dec(&queue->inflight_packets);
+
+	/* Wake the dealloc thread _after_ decrementing inflight_packets so
+	 * that if kthread_stop() has already been called, the dealloc thread
+	 * does not wait forever with nothing to wake it.
+	 */
+	wake_up(&queue->dealloc_wq);
 }
 
 int xenvif_schedulable(struct xenvif *vif)
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 7d50711..09ffda4 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -1536,7 +1536,6 @@ void xenvif_zerocopy_callback(struct ubuf_info *ubuf, bool zerocopy_success)
 		smp_wmb();
 		queue->dealloc_prod++;
 	} while (ubuf);
-	wake_up(&queue->dealloc_wq);
 	spin_unlock_irqrestore(&queue->callback_lock, flags);
 
 	if (likely(zerocopy_success))
-- 
2.1.0
