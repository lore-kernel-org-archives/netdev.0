From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next 7/8] vhost-net: select tx zero copy dynamically
Date: Mon, 29 Oct 2012 17:50:13 +0200
Message-ID: <e0df8921daaae56df726a426fc99c49efd607a13.1351524502.git.mst@redhat.com>
References: <cover.1351524501.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Ian Campbell <Ian.Campbell@citrix.com>, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1351524501.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Even when vhost-net is in zero-copy transmit mode,
net core might still decide to copy the skb later
which is somewhat slower than a copy in user
context: data copy overhead is added to the cost of
page pin/unpin. The result is that enabling tx zero copy
option leads to higher CPU utilization for guest to guest
and guest to host traffic.

To fix this, suppress zero copy tx after a given number of
packets triggered late data copy. Re-enable periodically
to detect workload changes.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c | 55 ++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 50 insertions(+), 5 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 532fc88..8e9de79 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -42,6 +42,21 @@ MODULE_PARM_DESC(experimental_zcopytx, "Enable Experimental Zero Copy TX");
 #define VHOST_MAX_PEND 128
 #define VHOST_GOODCOPY_LEN 256
 
+/*
+ * For transmit, used buffer len is unused; we override it to track buffer
+ * status internally; used for zerocopy tx only.
+ */
+/* Lower device DMA failed */
+#define VHOST_DMA_FAILED_LEN	3
+/* Lower device DMA done */
+#define VHOST_DMA_DONE_LEN	2
+/* Lower device DMA in progress */
+#define VHOST_DMA_IN_PROGRESS	1
+/* Buffer unused */
+#define VHOST_DMA_CLEAR_LEN	0
+
+#define VHOST_DMA_IS_DONE(len) ((len) >= VHOST_DMA_DONE_LEN)
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -62,8 +77,33 @@ struct vhost_net {
 	 * We only do this when socket buffer fills up.
 	 * Protected by tx vq lock. */
 	enum vhost_net_poll_state tx_poll_state;
+	/* Number of TX recently submitted.
+	 * Protected by tx vq lock. */
+	unsigned tx_packets;
+	/* Number of times zerocopy TX recently failed.
+	 * Protected by tx vq lock. */
+	unsigned tx_zcopy_err;
 };
 
+static void vhost_net_tx_packet(struct vhost_net *net)
+{
+	++net->tx_packets;
+	if (net->tx_packets < 1024)
+		return;
+	net->tx_packets = 0;
+	net->tx_zcopy_err = 0;
+}
+
+static void vhost_net_tx_err(struct vhost_net *net)
+{
+	++net->tx_zcopy_err;
+}
+
+static bool vhost_net_tx_select_zcopy(struct vhost_net *net)
+{
+	return net->tx_packets / 64 >= net->tx_zcopy_err;
+}
+
 static bool vhost_sock_zcopy(struct socket *sock)
 {
 	return unlikely(experimental_zcopytx) &&
@@ -131,12 +171,15 @@ static void tx_poll_start(struct vhost_net *net, struct socket *sock)
  * of used idx. Once lower device DMA done contiguously, we will signal KVM
  * guest used idx.
  */
-int vhost_zerocopy_signal_used(struct vhost_virtqueue *vq)
+static int vhost_zerocopy_signal_used(struct vhost_net *net,
+				      struct vhost_virtqueue *vq)
 {
 	int i;
 	int j = 0;
 
 	for (i = vq->done_idx; i != vq->upend_idx; i = (i + 1) % UIO_MAXIOV) {
+		if (vq->heads[i].len == VHOST_DMA_FAILED_LEN)
+			vhost_net_tx_err(net);
 		if (VHOST_DMA_IS_DONE(vq->heads[i].len)) {
 			vq->heads[i].len = VHOST_DMA_CLEAR_LEN;
 			vhost_add_used_and_signal(vq->dev, vq,
@@ -208,7 +251,7 @@ static void handle_tx(struct vhost_net *net)
 	for (;;) {
 		/* Release DMAs done buffers first */
 		if (zcopy)
-			vhost_zerocopy_signal_used(vq);
+			vhost_zerocopy_signal_used(net, vq);
 
 		head = vhost_get_vq_desc(&net->dev, vq, vq->iov,
 					 ARRAY_SIZE(vq->iov),
@@ -263,7 +306,8 @@ static void handle_tx(struct vhost_net *net)
 		/* use msg_control to pass vhost zerocopy ubuf info to skb */
 		if (zcopy) {
 			vq->heads[vq->upend_idx].id = head;
-			if (len < VHOST_GOODCOPY_LEN) {
+			if (!vhost_net_tx_select_zcopy(net) ||
+			    len < VHOST_GOODCOPY_LEN) {
 				/* copy don't need to wait for DMA done */
 				vq->heads[vq->upend_idx].len =
 							VHOST_DMA_DONE_LEN;
@@ -305,8 +349,9 @@ static void handle_tx(struct vhost_net *net)
 		if (!zcopy)
 			vhost_add_used_and_signal(&net->dev, vq, head, 0);
 		else
-			vhost_zerocopy_signal_used(vq);
+			vhost_zerocopy_signal_used(net, vq);
 		total_len += len;
+		vhost_net_tx_packet(net);
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
 			break;
@@ -774,7 +819,7 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
 	if (oldubufs) {
 		vhost_ubuf_put_and_wait(oldubufs);
 		mutex_lock(&vq->mutex);
-		vhost_zerocopy_signal_used(vq);
+		vhost_zerocopy_signal_used(n, vq);
 		mutex_unlock(&vq->mutex);
 	}
 
-- 
MST
