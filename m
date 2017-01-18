From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V5 2/3] vhost_net: tx batching
Date: Wed, 18 Jan 2017 15:02:02 +0800
Message-ID: <1484722923-7698-3-git-send-email-jasowang@redhat.com>
References: <1484722923-7698-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: wexu@redhat.com, stefanha@redhat.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, kvm@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1484722923-7698-1-git-send-email-jasowang@redhat.com>
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

This patch tries to utilize tuntap rx batching by peeking the tx
virtqueue during transmission, if there's more available buffers in
the virtqueue, set MSG_MORE flag for a hint for backend (e.g tuntap)
to batch the packets.

Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
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
