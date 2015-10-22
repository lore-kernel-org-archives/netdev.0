From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next RFC 2/2] vhost_net: basic polling support
Date: Thu, 22 Oct 2015 01:27:29 -0400
Message-ID: <1445491649-62614-2-git-send-email-jasowang@redhat.com>
References: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1445491649-62614-1-git-send-email-jasowang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

This patch tries to poll for new added tx buffer for a while at the
end of tx processing. The maximum time spent on polling were limited
through a module parameter. To avoid block rx, the loop will end it
there's new other works queued on vhost so in fact socket receive
queue is also be polled.

busyloop_timeout = 50 gives us following improvement on TCP_RR test:

size/session/+thu%/+normalize%
    1/     1/   +5%/  -20%
    1/    50/  +17%/   +3%

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9eda69e..bbb522a 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -31,7 +31,9 @@
 #include "vhost.h"
 
 static int experimental_zcopytx = 1;
+static int busyloop_timeout = 50;
 module_param(experimental_zcopytx, int, 0444);
+module_param(busyloop_timeout, int, 0444);
 MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 		                       " 1 -Enable; 0 - Disable");
 
@@ -287,12 +289,23 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	rcu_read_unlock_bh();
 }
 
+static bool tx_can_busy_poll(struct vhost_dev *dev,
+			     unsigned long endtime)
+{
+	unsigned long now = local_clock() >> 10;
+
+	return busyloop_timeout && !need_resched() &&
+	       !time_after(now, endtime) && !vhost_has_work(dev) &&
+	       single_task_running();
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
 {
 	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
 	struct vhost_virtqueue *vq = &nvq->vq;
+	unsigned long endtime;
 	unsigned out, in;
 	int head;
 	struct msghdr msg = {
@@ -331,6 +344,8 @@ static void handle_tx(struct vhost_net *net)
 			      % UIO_MAXIOV == nvq->done_idx))
 			break;
 
+		endtime  = (local_clock() >> 10) + busyloop_timeout;
+again:
 		head = vhost_get_vq_desc(vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
 					 &out, &in,
@@ -340,6 +355,10 @@ static void handle_tx(struct vhost_net *net)
 			break;
 		/* Nothing new?  Wait for eventfd to tell us they refilled. */
 		if (head == vq->num) {
+			if (tx_can_busy_poll(vq->dev, endtime)) {
+				cpu_relax();
+				goto again;
+			}
 			if (unlikely(vhost_enable_notify(&net->dev, vq))) {
 				vhost_disable_notify(&net->dev, vq);
 				continue;
-- 
1.8.3.1
