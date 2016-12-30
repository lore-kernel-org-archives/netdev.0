From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 2/3] vhost_net: tx batching
Date: Fri, 30 Dec 2016 13:20:50 +0800
Message-ID: <1483075251-6889-3-git-send-email-jasowang@redhat.com>
References: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
Cc: wexu@redhat.com, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, kvm@vger.kernel.org,
        virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1483075251-6889-1-git-send-email-jasowang@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch tries to utilize tuntap rx batching by peeking the tx
virtqueue during transmission, if there's more available buffers in
the virtqueue, set MSG_MORE flag for a hint for backend (e.g tuntap)
to batch the packets.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 23 ++++++++++++++++++++---
 1 file changed, 20 insertions(+), 3 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 5dc3465..c42e9c3 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -351,6 +351,15 @@ static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
 	return r;
 }
 
+static bool vhost_exceeds_maxpend(struct vhost_net *net)
+{
+	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
+	struct vhost_virtqueue *vq = &nvq->vq;
+
+	return (nvq->upend_idx + vq->num - VHOST_MAX_PEND) % UIO_MAXIOV
+		== nvq->done_idx;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
@@ -394,8 +403,7 @@ static void handle_tx(struct vhost_net *net)
 		/* If more outstanding DMAs, queue the work.
 		 * Handle upend_idx wrap around
 		 */
-		if (unlikely((nvq->upend_idx + vq->num - VHOST_MAX_PEND)
-			      % UIO_MAXIOV == nvq->done_idx))
+		if (unlikely(vhost_exceeds_maxpend(net)))
 			break;
 
 		head = vhost_net_tx_get_vq_desc(net, vq, vq->iov,
@@ -454,6 +462,16 @@ static void handle_tx(struct vhost_net *net)
 			msg.msg_control = NULL;
 			ubufs = NULL;
 		}
+
+		total_len += len;
+		if (total_len < VHOST_NET_WEIGHT &&
+		    !vhost_vq_avail_empty(&net->dev, vq) &&
+		    likely(!vhost_exceeds_maxpend(net))) {
+			msg.msg_flags |= MSG_MORE;
+		} else {
+			msg.msg_flags &= ~MSG_MORE;
+		}
+
 		/* TODO: Check specific error and bomb out unless ENOBUFS? */
 		err = sock->ops->sendmsg(sock, &msg, len);
 		if (unlikely(err < 0)) {
@@ -472,7 +490,6 @@ static void handle_tx(struct vhost_net *net)
 			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		else
 			vhost_zerocopy_signal_used(net, vq);
-		total_len += len;
 		vhost_net_tx_packet(net);
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
-- 
2.7.4

