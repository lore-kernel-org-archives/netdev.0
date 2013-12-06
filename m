From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [PATCH v4 net-next 1/4] vhost: remove the dead branch
Date: Sat,  7 Dec 2013 04:13:03 +0800
Message-ID: <1386360786-17687-2-git-send-email-zwu.kernel@gmail.com>
References: <1386360786-17687-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386360786-17687-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Since vhost_dev_init() forever return 0, some branches are never run,
therefore need to be removed.

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
Acked-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c   |    9 ++-------
 drivers/vhost/scsi.c  |    7 +------
 drivers/vhost/test.c  |    8 +-------
 drivers/vhost/vhost.c |    4 +---
 drivers/vhost/vhost.h |    2 +-
 5 files changed, 6 insertions(+), 24 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 831eb4f..9a68409 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -683,7 +683,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 	struct vhost_net *n = kmalloc(sizeof *n, GFP_KERNEL);
 	struct vhost_dev *dev;
 	struct vhost_virtqueue **vqs;
-	int r, i;
+	int i;
 
 	if (!n)
 		return -ENOMEM;
@@ -706,12 +706,7 @@ static int vhost_net_open(struct inode *inode, struct file *f)
 		n->vqs[i].vhost_hlen = 0;
 		n->vqs[i].sock_hlen = 0;
 	}
-	r = vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
-	if (r < 0) {
-		kfree(n);
-		kfree(vqs);
-		return r;
-	}
+	vhost_dev_init(dev, vqs, VHOST_NET_VQ_MAX);
 
 	vhost_poll_init(n->poll + VHOST_NET_VQ_TX, handle_tx_net, POLLOUT, dev);
 	vhost_poll_init(n->poll + VHOST_NET_VQ_RX, handle_rx_net, POLLIN, dev);
diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index f175629..1e4c75c 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1417,18 +1417,13 @@ static int vhost_scsi_open(struct inode *inode, struct file *f)
 		vqs[i] = &vs->vqs[i].vq;
 		vs->vqs[i].vq.handle_kick = vhost_scsi_handle_kick;
 	}
-	r = vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ);
+	vhost_dev_init(&vs->dev, vqs, VHOST_SCSI_MAX_VQ);
 
 	tcm_vhost_init_inflight(vs, NULL);
 
-	if (r < 0)
-		goto err_init;
-
 	f->private_data = vs;
 	return 0;
 
-err_init:
-	kfree(vqs);
 err_vqs:
 	vhost_scsi_free(vs);
 err_vs:
diff --git a/drivers/vhost/test.c b/drivers/vhost/test.c
index 339eae8..c2a54fb 100644
--- a/drivers/vhost/test.c
+++ b/drivers/vhost/test.c
@@ -104,7 +104,6 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 	struct vhost_test *n = kmalloc(sizeof *n, GFP_KERNEL);
 	struct vhost_dev *dev;
 	struct vhost_virtqueue **vqs;
-	int r;
 
 	if (!n)
 		return -ENOMEM;
@@ -117,12 +116,7 @@ static int vhost_test_open(struct inode *inode, struct file *f)
 	dev = &n->dev;
 	vqs[VHOST_TEST_VQ] = &n->vqs[VHOST_TEST_VQ];
 	n->vqs[VHOST_TEST_VQ].handle_kick = handle_vq_kick;
-	r = vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
-	if (r < 0) {
-		kfree(vqs);
-		kfree(n);
-		return r;
-	}
+	vhost_dev_init(dev, vqs, VHOST_TEST_VQ_MAX);
 
 	f->private_data = n;
 
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 69068e0..78987e4 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -290,7 +290,7 @@ static void vhost_dev_free_iovecs(struct vhost_dev *dev)
 		vhost_vq_free_iovecs(dev->vqs[i]);
 }
 
-long vhost_dev_init(struct vhost_dev *dev,
+void vhost_dev_init(struct vhost_dev *dev,
 		    struct vhost_virtqueue **vqs, int nvqs)
 {
 	struct vhost_virtqueue *vq;
@@ -319,8 +319,6 @@ long vhost_dev_init(struct vhost_dev *dev,
 			vhost_poll_init(&vq->poll, vq->handle_kick,
 					POLLIN, dev);
 	}
-
-	return 0;
 }
 EXPORT_SYMBOL_GPL(vhost_dev_init);
 
diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
index 4465ed5..35eeb2a 100644
--- a/drivers/vhost/vhost.h
+++ b/drivers/vhost/vhost.h
@@ -127,7 +127,7 @@ struct vhost_dev {
 	struct task_struct *worker;
 };
 
-long vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
+void vhost_dev_init(struct vhost_dev *, struct vhost_virtqueue **vqs, int nvqs);
 long vhost_dev_set_owner(struct vhost_dev *dev);
 bool vhost_dev_has_owner(struct vhost_dev *dev);
 long vhost_dev_check_owner(struct vhost_dev *);
-- 
1.7.6.5
