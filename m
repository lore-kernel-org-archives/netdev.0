From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 1/2] vhost_net: stop polling socket during rx processing
Date: Wed,  1 Jun 2016 01:56:33 -0400
Message-ID: <1464760594-30326-2-git-send-email-jasowang@redhat.com>
References: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1464760594-30326-1-git-send-email-jasowang@redhat.com>
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

We don't stop rx polling socket during rx processing, this will lead
unnecessary wakeups from under layer net devices (E.g
sock_def_readable() form tun). Rx will be slowed down in this
way. This patch avoids this by stop polling socket during rx
processing. A small drawback is that this introduces some overheads in
light load case because of the extra start/stop polling, but single
netperf TCP_RR does not notice any change. In a super heavy load case,
e.g using pktgen to inject packet to guest, we get about ~8.8%
improvement on pps:

before: ~1240000 pkt/s
after:  ~1350000 pkt/s

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 64 +++++++++++++++++++++++++++--------------------------
 1 file changed, 33 insertions(+), 31 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f744eeb..1d3e45f 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -301,6 +301,32 @@ static bool vhost_can_busy_poll(struct vhost_dev *dev,
 	       !vhost_has_work(dev);
 }
 
+static void vhost_net_disable_vq(struct vhost_net *n,
+				 struct vhost_virtqueue *vq)
+{
+	struct vhost_net_virtqueue *nvq =
+		container_of(vq, struct vhost_net_virtqueue, vq);
+	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
+	if (!vq->private_data)
+		return;
+	vhost_poll_stop(poll);
+}
+
+static int vhost_net_enable_vq(struct vhost_net *n,
+				struct vhost_virtqueue *vq)
+{
+	struct vhost_net_virtqueue *nvq =
+		container_of(vq, struct vhost_net_virtqueue, vq);
+	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
+	struct socket *sock;
+
+	sock = vq->private_data;
+	if (!sock)
+		return 0;
+
+	return vhost_poll_start(poll, sock->file);
+}
+
 static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
 				    struct vhost_virtqueue *vq,
 				    struct iovec iov[], unsigned int iov_size,
@@ -613,6 +639,7 @@ static void handle_rx(struct vhost_net *net)
 	if (!sock)
 		goto out;
 	vhost_disable_notify(&net->dev, vq);
+	vhost_net_disable_vq(net, vq);
 
 	vhost_hlen = nvq->vhost_hlen;
 	sock_hlen = nvq->sock_hlen;
@@ -629,7 +656,7 @@ static void handle_rx(struct vhost_net *net)
 					likely(mergeable) ? UIO_MAXIOV : 1);
 		/* On error, stop handling until the next kick. */
 		if (unlikely(headcount < 0))
-			break;
+			goto out;
 		/* On overrun, truncate and discard */
 		if (unlikely(headcount > UIO_MAXIOV)) {
 			iov_iter_init(&msg.msg_iter, READ, vq->iov, 1, 1);
@@ -648,7 +675,7 @@ static void handle_rx(struct vhost_net *net)
 			}
 			/* Nothing new?  Wait for eventfd to tell us
 			 * they refilled. */
-			break;
+			goto out;
 		}
 		/* We don't need to be notified again. */
 		iov_iter_init(&msg.msg_iter, READ, vq->iov, in, vhost_len);
@@ -676,7 +703,7 @@ static void handle_rx(struct vhost_net *net)
 					 &fixup) != sizeof(hdr)) {
 				vq_err(vq, "Unable to write vnet_hdr "
 				       "at addr %p\n", vq->iov->iov_base);
-				break;
+				goto out;
 			}
 		} else {
 			/* Header came from socket; we'll need to patch
@@ -692,7 +719,7 @@ static void handle_rx(struct vhost_net *net)
 				 &fixup) != sizeof num_buffers) {
 			vq_err(vq, "Failed num_buffers write");
 			vhost_discard_vq_desc(vq, headcount);
-			break;
+			goto out;
 		}
 		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
 					    headcount);
@@ -701,9 +728,10 @@ static void handle_rx(struct vhost_net *net)
 		total_len += vhost_len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
-			break;
+			goto out;
 		}
 	}
+	vhost_net_enable_vq(net, vq);
 out:
 	mutex_unlock(&vq->mutex);
 }
@@ -782,32 +810,6 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	return 0;
 }
 
-static void vhost_net_disable_vq(struct vhost_net *n,
-				 struct vhost_virtqueue *vq)
-{
-	struct vhost_net_virtqueue *nvq =
-		container_of(vq, struct vhost_net_virtqueue, vq);
-	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
-	if (!vq->private_data)
-		return;
-	vhost_poll_stop(poll);
-}
-
-static int vhost_net_enable_vq(struct vhost_net *n,
-				struct vhost_virtqueue *vq)
-{
-	struct vhost_net_virtqueue *nvq =
-		container_of(vq, struct vhost_net_virtqueue, vq);
-	struct vhost_poll *poll = n->poll + (nvq - n->vqs);
-	struct socket *sock;
-
-	sock = vq->private_data;
-	if (!sock)
-		return 0;
-
-	return vhost_poll_start(poll, sock->file);
-}
-
 static struct socket *vhost_net_stop_vq(struct vhost_net *n,
 					struct vhost_virtqueue *vq)
 {
-- 
1.8.3.1
