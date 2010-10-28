From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 1/1] vhost: TX used buffer guest signal accumulation
Date: Wed, 27 Oct 2010 21:40:04 -0700
Message-ID: <1288240804.14342.1.camel@localhost.localdomain>
References: <1288216693.17571.38.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, linux-kernel@vger.kernel.org
To: "mst@redhat.com" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:59630 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707Ab0J1Eke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Oct 2010 00:40:34 -0400
In-Reply-To: <1288216693.17571.38.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resubmit this patch for fixing some minor error (white space, typo).

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---
 drivers/vhost/net.c   |   20 +++++++++++++++++++-
 drivers/vhost/vhost.c |   32 ++++++++++++++++++++++++++++++++
 drivers/vhost/vhost.h |    3 +++
 3 files changed, 54 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 4b4da5b..3eb8016 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -128,6 +128,7 @@ static void handle_tx(struct vhost_net *net)
 	int err, wmem;
 	size_t hdr_size;
 	struct socket *sock;
+	int max_pend = vq->num - (vq->num >> 2);
 
 	sock = rcu_dereference_check(vq->private_data,
 				     lockdep_is_held(&vq->mutex));
@@ -198,7 +199,24 @@ static void handle_tx(struct vhost_net *net)
 		if (err != len)
 			pr_debug("Truncated TX packet: "
 				 " len %d != %zd\n", err, len);
-		vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		/*
+		 * if no pending buffer size allocate, signal used buffer
+		 * one by one, otherwise, signal used buffer when reaching
+		 * 3/4 ring size to reduce CPU utilization.
+		 */
+		if (unlikely(vq->pend))
+			vhost_add_used_and_signal(&net->dev, vq, head, 0);
+		else {
+			vq->pend[vq->num_pend].id = head;
+			vq->pend[vq->num_pend].len = 0;
+			++vq->num_pend;
+			if (vq->num_pend == max_pend) {
+				vhost_add_used_and_signal_n(&net->dev, vq,
+							    vq->pend,
+							    vq->num_pend);
+				vq->num_pend = 0;
+			}
+		}
 		total_len += len;
 		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
 			vhost_poll_queue(&vq->poll);
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 94701ff..f2f3288 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -170,6 +170,16 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->call_ctx = NULL;
 	vq->call = NULL;
 	vq->log_ctx = NULL;
+	/* signal pending used buffers */
+	if (vq->pend) {
+		if (vq->num_pend != 0) {
+			vhost_add_used_and_signal_n(dev, vq, vq->pend,
+						    vq->num_pend);
+			vq->num_pend = 0;
+		}
+		kfree(vq->pend);
+	}
+	vq->pend = NULL;
 }
 
 static int vhost_worker(void *data)
@@ -273,7 +283,14 @@ long vhost_dev_init(struct vhost_dev *dev,
 		dev->vqs[i].heads = NULL;
 		dev->vqs[i].dev = dev;
 		mutex_init(&dev->vqs[i].mutex);
+		dev->vqs[i].num_pend = 0;
+		dev->vqs[i].pend = NULL;
 		vhost_vq_reset(dev, dev->vqs + i);
+		/* signal 3/4 of ring size used buffers */
+		dev->vqs[i].pend = kmalloc((dev->vqs[i].num -
+					   (dev->vqs[i].num >> 2)) *
+					   sizeof *dev->vqs[i].pend,
+					   GFP_KERNEL);
 		if (dev->vqs[i].handle_kick)
 			vhost_poll_init(&dev->vqs[i].poll,
 					dev->vqs[i].handle_kick, POLLIN, dev);
@@ -599,6 +616,21 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
 			r = -EINVAL;
 			break;
 		}
+		if (vq->num != s.num) {
+			/* signal used buffers first */
+			if (vq->pend) {
+				if (vq->num_pend != 0) {
+					vhost_add_used_and_signal_n(vq->dev, vq,
+								    vq->pend,
+								    vq->num_pend);
+					vq->num_pend = 0;
+				}
+				kfree(vq->pend);
+			}
+			/* realloc pending used buffers size */
+			vq->pend = kmalloc((s.num - (s.num >> 2)) *
+					   sizeof *vq->pend, GFP_KERNEL);
+		}
 		vq->num = s.num;
 		break;
 	case VHOST_SET_VRING_BASE:
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 073d06a..78949c0 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -108,6 +108,9 @@ struct vhost_virtqueue {
 	/* Log write descriptors */
 	void __user *log_base;
 	struct vhost_log *log;
+	/* delay multiple used buffers to signal once */
+	int num_pend;
+	struct vring_used_elem *pend;
 };
 
 struct vhost_dev {


