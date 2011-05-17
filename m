From: Shirley Ma <mashirle@us.ibm.com>
Subject: [TEST PATCH net-next] vhost: accumulate multiple used and sigal in
 vhost TX test
Date: Tue, 17 May 2011 13:46:21 -0700
Message-ID: <1305665181.10756.29.camel@localhost.localdomain>
References: <1305574484.3456.30.camel@localhost.localdomain>
	 <20110516204540.GD18148@redhat.com>
	 <1305579414.3456.49.camel@localhost.localdomain>
	 <20110516212401.GF18148@redhat.com>
	 <1305606683.10756.3.camel@localhost.localdomain>
	 <20110517055503.GA26989@redhat.com>
	 <1305645734.10756.14.camel@localhost.localdomain>
	 <20110517152840.GA2389@redhat.com>
	 <1305646444.10756.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1305646444.10756.16.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Michael,

Here is the patch I used to test out of order before: add used in a pend
array, and swap the last two ids. 

I used to hit an issue, but now it seems working well.

This won't impact zero-copy patch since we need to maintain the pend
used ids anyway.

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/vhost/net.c   |   24 +++++++++++++++++++++++-
 drivers/vhost/vhost.c |   11 +++++++++++
 drivers/vhost/vhost.h |    1 +
 3 files changed, 35 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 2f7c76a..19e1baa 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -32,6 +32,8 @@
  * Using this limit prevents one virtqueue from starving others. */
 #define VHOST_NET_WEIGHT 0x80000
 
+#define VHOST_MAX_PEND	128
+
 enum {
 	VHOST_NET_VQ_RX = 0,
 	VHOST_NET_VQ_TX = 1,
@@ -198,13 +200,33 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		vq->heads[vq->pend_idx].id = head;
+		vq->heads[vq->pend_idx].len = 0;
+		++vq->pend_idx;
+		if (vq->pend_idx >= VHOST_MAX_PEND) {
+			int id;
+			id = vq->heads[vq->pend_idx-1].id;
+			vq->heads[vq->pend_idx-1].id = vq->heads[vq->pend_idx-2].id; 
+			vq->heads[vq->pend_idx-2].id = id;
+			vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
+						    vq->pend_idx);
+			vq->pend_idx = 0;
+		}
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
 			break;
 		}
 	}
+	if (vq->pend_idx >= VHOST_MAX_PEND) {
+		int id;
+		id = vq->heads[vq->pend_idx-1].id;
+		vq->heads[vq->pend_idx-1].id = vq->heads[vq->pend_idx-2].id;
+		vq->heads[vq->pend_idx-2].id = id;
+		vhost_add_used_and_signal_n(&net->dev, vq, vq->heads,
+					    vq->pend_idx);
+		vq->pend_idx = 0;
+	}
 
 	mutex_unlock(&vq->mutex);
 }
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 2ab2912..7eea6b3 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -174,6 +174,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	vq->pend_idx = 0;
 }
 
 static int vhost_worker(void *data)
@@ -395,6 +396,11 @@ void vhost_dev_cleanup(struct vhost_dev *dev)
 			vhost_poll_stop(&dev->vqs[i].poll);
 			vhost_poll_flush(&dev->vqs[i].poll);
 		}
+		if (dev->vqs[i].pend_idx != 0) {
+			vhost_add_used_and_signal_n(dev, &dev->vqs[i],
+				dev->vqs[i].heads, dev->vqs[i].pend_idx);
+			dev->vqs[i].pend_idx = 0;
+		}
 		if (dev->vqs[i].error_ctx)
 			eventfd_ctx_put(dev->vqs[i].error_ctx);
 		if (dev->vqs[i].error)
@@ -603,6 +609,11 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 
 	mutex_lock(&vq->mutex);
 
+	if (vq->pend_idx != 0) {
+		vhost_add_used_and_signal_n(d, vq, vq->heads, vq->pend_idx);
+		vq->pend_idx = 0;
+	}
+
 	switch (ioctl) {
 	case VHOST_SET_VRING_NUM:
 		/* Resizing ring with an active backend?
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index b3363ae..44a412d 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -108,6 +108,7 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	int pend_idx;
 };
 
 struct vhost_dev {
