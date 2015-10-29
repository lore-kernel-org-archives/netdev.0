From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next rfc V2 2/2] vhost_net: basic polling support
Date: Thu, 29 Oct 2015 04:45:26 -0400
Message-ID: <1446108326-37765-3-git-send-email-jasowang@redhat.com>
References: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446108326-37765-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch tries to poll for new added tx buffer for a while at the
end of tx processing. The maximum time spent on polling were limited
through a module parameter. To avoid block rx, the loop will end it
there's new other works queued on vhost so in fact socket receive
queue is also be polled.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 50 insertions(+), 4 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9eda69e..30e6d3d 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -31,9 +31,13 @@
 #include "vhost.h"
 
 static int experimental_zcopytx = 1;
+static int busyloop_timeout = 50;
 module_param(experimental_zcopytx, int, 0444);
 MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 		                       " 1 -Enable; 0 - Disable");
+module_param(busyloop_timeout, int, 0444);
+MODULE_PARM_DESC(busyloop_timeout, "Maximum number of time (in us) "
+		                   "could be spend on busy polling");
 
 /* Max number of bytes transferred before requeueing the job.
  * Using this limit prevents one virtqueue from starving others. */
@@ -287,6 +291,49 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	rcu_read_unlock_bh();
 }
 
+static inline unsigned long busy_clock(void)
+{
+	return local_clock() >> 10;
+}
+
+static bool tx_can_busy_poll(struct vhost_dev *dev,
+			     unsigned long endtime)
+{
+	return likely(!need_resched()) &&
+	       likely(!time_after(busy_clock(), endtime)) &&
+	       likely(!signal_pending(current)) &&
+	       !vhost_has_work(dev) &&
+	       single_task_running();
+}
+
+static int vhost_net_tx_get_vq_desc(struct vhost_virtqueue *vq,
+				    struct iovec iov[], unsigned int iov_size,
+				    unsigned int *out_num, unsigned int *in_num)
+{
+	unsigned long uninitialized_var(endtime);
+	int head;
+
+	if (busyloop_timeout) {
+		preempt_disable();
+		endtime = busy_clock() + busyloop_timeout;
+	}
+
+again:
+	head = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
+				 out_num, in_num, NULL, NULL);
+
+	if (head == vq->num && busyloop_timeout &&
+	    tx_can_busy_poll(vq->dev, endtime)) {
+		cpu_relax();
+		goto again;
+	}
+
+	if (busyloop_timeout)
+		preempt_enable();
+
+	return head;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
@@ -331,10 +378,9 @@ static void handle_tx(struct vhost_net *net)
 			      % UIO_MAXIOV == nvq->done_idx))
 			break;
 
-		head = vhost_get_vq_desc(vq, vq->iov,
-					 ARRAY_SIZE(vq->iov),
-					 &out, &in,
-					 NULL, NULL);
+		head = vhost_net_tx_get_vq_desc(vq, vq->iov,
+						ARRAY_SIZE(vq->iov),
+						&out, &in);
 		/* On error, stop handling until the next kick. */
 		if (unlikely(head < 0))
 			break;
-- 
1.8.3.1
