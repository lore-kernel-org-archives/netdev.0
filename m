From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V3 3/3] vhost_net: basic polling support
Date: Fri, 26 Feb 2016 16:42:44 +0800
Message-ID: <1456476164-17242-4-git-send-email-jasowang@redhat.com>
References: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: yang.zhang.wz@gmail.com, RAPOPORT@il.ibm.com
To: kvm@vger.kernel.org, mst@redhat.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1456476164-17242-1-git-send-email-jasowang@redhat.com>
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

This patch tries to poll for new added tx buffer or socket receive
queue for a while at the end of tx/rx processing. The maximum time
spent on polling were specified through a new kind of vring ioctl.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c        | 79 +++++++++++++++++++++++++++++++++++++++++++---
 drivers/vhost/vhost.c      | 14 ++++++++
 drivers/vhost/vhost.h      |  1 +
 include/uapi/linux/vhost.h |  6 ++++
 4 files changed, 95 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 9eda69e..c91af93 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -287,6 +287,44 @@ static void vhost_zerocopy_callback(struct ubuf_info *ubuf, bool success)
 	rcu_read_unlock_bh();
 }
 
+static inline unsigned long busy_clock(void)
+{
+	return local_clock() >> 10;
+}
+
+static bool vhost_can_busy_poll(struct vhost_dev *dev,
+				unsigned long endtime)
+{
+	return likely(!need_resched()) &&
+	       likely(!time_after(busy_clock(), endtime)) &&
+	       likely(!signal_pending(current)) &&
+	       !vhost_has_work(dev) &&
+	       single_task_running();
+}
+
+static int vhost_net_tx_get_vq_desc(struct vhost_net *net,
+				    struct vhost_virtqueue *vq,
+				    struct iovec iov[], unsigned int iov_size,
+				    unsigned int *out_num, unsigned int *in_num)
+{
+	unsigned long uninitialized_var(endtime);
+	int r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
+				    out_num, in_num, NULL, NULL);
+
+	if (r == vq->num && vq->busyloop_timeout) {
+		preempt_disable();
+		endtime = busy_clock() + vq->busyloop_timeout;
+		while (vhost_can_busy_poll(vq->dev, endtime) &&
+		       vhost_vq_avail_empty(vq->dev, vq))
+			cpu_relax();
+		preempt_enable();
+		r = vhost_get_vq_desc(vq, vq->iov, ARRAY_SIZE(vq->iov),
+					out_num, in_num, NULL, NULL);
+	}
+
+	return r;
+}
+
 /* Expects to be always run from workqueue - which acts as
  * read-size critical section for our kind of RCU. */
 static void handle_tx(struct vhost_net *net)
@@ -331,10 +369,9 @@ static void handle_tx(struct vhost_net *net)
 			      % UIO_MAXIOV == nvq->done_idx))
 			break;
 
-		head = vhost_get_vq_desc(vq, vq->iov,
-					 ARRAY_SIZE(vq->iov),
-					 &out, &in,
-					 NULL, NULL);
+		head = vhost_net_tx_get_vq_desc(net, vq, vq->iov,
+						ARRAY_SIZE(vq->iov),
+						&out, &in);
 		/* On error, stop handling until the next kick. */
 		if (unlikely(head < 0))
 			break;
@@ -435,6 +472,38 @@ static int peek_head_len(struct sock *sk)
 	return len;
 }
 
+static int vhost_net_rx_peek_head_len(struct vhost_net *net, struct sock *sk)
+{
+	struct vhost_net_virtqueue *nvq = &net->vqs[VHOST_NET_VQ_TX];
+	struct vhost_virtqueue *vq = &nvq->vq;
+	unsigned long uninitialized_var(endtime);
+	int len = peek_head_len(sk);
+
+	if (!len && vq->busyloop_timeout) {
+		/* Both tx vq and rx socket were polled here */
+		mutex_lock(&vq->mutex);
+		vhost_disable_notify(&net->dev, vq);
+
+		preempt_disable();
+		endtime = busy_clock() + vq->busyloop_timeout;
+
+		while (vhost_can_busy_poll(&net->dev, endtime) &&
+		       skb_queue_empty(&sk->sk_receive_queue) &&
+		       vhost_vq_avail_empty(&net->dev, vq))
+			cpu_relax();
+
+		preempt_enable();
+
+		if (vhost_enable_notify(&net->dev, vq))
+			vhost_poll_queue(&vq->poll);
+		mutex_unlock(&vq->mutex);
+
+		len = peek_head_len(sk);
+	}
+
+	return len;
+}
+
 /* This is a multi-buffer version of vhost_get_desc, that works if
  *	vq has read descriptors only.
  * @vq		- the relevant virtqueue
@@ -553,7 +622,7 @@ static void handle_rx(struct vhost_net *net)
 		vq->log : NULL;
 	mergeable = vhost_has_feature(vq, VIRTIO_NET_F_MRG_RXBUF);
 
-	while ((sock_len = peek_head_len(sock->sk))) {
+	while ((sock_len = vhost_net_rx_peek_head_len(net, sock->sk))) {
 		sock_len += sock_hlen;
 		vhost_len = sock_len + vhost_hlen;
 		headcount = get_rx_bufs(vq, vq->heads, vhost_len,
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c4ff9f2..5abfce9 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -285,6 +285,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->memory = NULL;
 	vq->is_le = virtio_legacy_is_little_endian();
 	vhost_vq_reset_user_be(vq);
+	vq->busyloop_timeout = 0;
 }
 
 static int vhost_worker(void *data)
@@ -919,6 +920,19 @@ long vhost_vring_ioctl(struct vhost_dev *d, int ioctl, void __user *argp)
 	case VHOST_GET_VRING_ENDIAN:
 		r = vhost_get_vring_endian(vq, idx, argp);
 		break;
+	case VHOST_SET_VRING_BUSYLOOP_TIMEOUT:
+		if (copy_from_user(&s, argp, sizeof(s))) {
+			r = -EFAULT;
+			break;
+		}
+		vq->busyloop_timeout = s.num;
+		break;
+	case VHOST_GET_VRING_BUSYLOOP_TIMEOUT:
+		s.index = idx;
+		s.num = vq->busyloop_timeout;
+		if (copy_to_user(argp, &s, sizeof(s)))
+			r = -EFAULT;
+		break;
 	default:
 		r = -ENOIOCTLCMD;
 	}
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index a7a43f0..9a02158 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -115,6 +115,7 @@ struct vhost_virtqueue {
 	/* Ring endianness requested by userspace for cross-endian support. */
 	bool user_be;
 #endif
+	u32 busyloop_timeout;
 };
 
 struct vhost_dev {
diff --git a/include/uapi/linux/vhost.h b/include/uapi/linux/vhost.h
index ab373191..61a8777 100644
--- a/include/uapi/linux/vhost.h
+++ b/include/uapi/linux/vhost.h
@@ -126,6 +126,12 @@ struct vhost_memory {
 #define VHOST_SET_VRING_CALL _IOW(VHOST_VIRTIO, 0x21, struct vhost_vring_file)
 /* Set eventfd to signal an error */
 #define VHOST_SET_VRING_ERR _IOW(VHOST_VIRTIO, 0x22, struct vhost_vring_file)
+/* Set busy loop timeout (in us) */
+#define VHOST_SET_VRING_BUSYLOOP_TIMEOUT _IOW(VHOST_VIRTIO, 0x23,	\
+					 struct vhost_vring_state)
+/* Get busy loop timeout (in us) */
+#define VHOST_GET_VRING_BUSYLOOP_TIMEOUT _IOW(VHOST_VIRTIO, 0x24,	\
+					 struct vhost_vring_state)
 
 /* VHOST_NET specific defines */
 
-- 
2.5.0
