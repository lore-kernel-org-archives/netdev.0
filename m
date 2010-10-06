From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/2] vhost-net: batch use/unuse mm
Date: Wed, 6 Oct 2010 15:34:45 +0200
Message-ID: <b0a7ae98999e0f4c844cf0ff1c6c2d2b1ea8c092.1286372006.git.mst@redhat.com>
References: <cover.1286372004.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rusty@rustcorp.com.au, davem@davemloft.net, kvm@vger.kernel.org,
	arnd@arndb.de, netdev@vger.kernel.org, avi@redhat.com,
	anthony@codemonkey.ws
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28308 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932343Ab0JFNlX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Oct 2010 09:41:23 -0400
Content-Disposition: inline
In-Reply-To: <cover.1286372004.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move use/unuse mm to vhost.c which makes it possible to batch these
operations.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/net.c   |    7 -------
 drivers/vhost/vhost.c |    7 ++++++-
 2 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 271678e..ff02ea4 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -10,7 +10,6 @@
 #include <linux/eventfd.h>
 #include <linux/vhost.h>
 #include <linux/virtio_net.h>
-#include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
 #include <linux/module.h>
 #include <linux/mutex.h>
@@ -136,7 +135,6 @@ static void handle_tx(struct vhost_net *net)
 		return;
 	}
 
-	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(vq);
 
@@ -197,7 +195,6 @@ static void handle_tx(struct vhost_net *net)
 	}
 
 	mutex_unlock(&vq->mutex);
-	unuse_mm(net->dev.mm);
 }
 
 static int peek_head_len(struct sock *sk)
@@ -302,7 +299,6 @@ static void handle_rx_big(struct vhost_net *net)
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
-	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(vq);
 	hdr_size = vq->vhost_hlen;
@@ -381,7 +377,6 @@ static void handle_rx_big(struct vhost_net *net)
 	}
 
 	mutex_unlock(&vq->mutex);
-	unuse_mm(net->dev.mm);
 }
 
 /* Expects to be always run from workqueue - which acts as
@@ -413,7 +408,6 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	if (!sock || skb_queue_empty(&sock->sk->sk_receive_queue))
 		return;
 
-	use_mm(net->dev.mm);
 	mutex_lock(&vq->mutex);
 	vhost_disable_notify(vq);
 	vhost_hlen = vq->vhost_hlen;
@@ -490,7 +484,6 @@ static void handle_rx_mergeable(struct vhost_net *net)
 	}
 
 	mutex_unlock(&vq->mutex);
-	unuse_mm(net->dev.mm);
 }
 
 static void handle_rx(struct vhost_net *net)
diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 8b9d474..c83d1c2 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -15,6 +15,7 @@
 #include <linux/vhost.h>
 #include <linux/virtio_net.h>
 #include <linux/mm.h>
+#include <linux/mmu_context.h>
 #include <linux/miscdevice.h>
 #include <linux/mutex.h>
 #include <linux/rcupdate.h>
@@ -179,6 +180,8 @@ static int vhost_worker(void *data)
 	unsigned uninitialized_var(seq);
 	int n = 0;
 
+	use_mm(dev->mm);
+
 	for (;;) {
 		/* mb paired w/ kthread_stop */
 		set_current_state(TASK_INTERRUPTIBLE);
@@ -193,7 +196,7 @@ static int vhost_worker(void *data)
 		if (kthread_should_stop()) {
 			spin_unlock_irq(&dev->work_lock);
 			__set_current_state(TASK_RUNNING);
-			return 0;
+			break;
 		}
 		if (!list_empty(&dev->work_list)) {
 			work = list_first_entry(&dev->work_list,
@@ -218,6 +221,8 @@ static int vhost_worker(void *data)
 		}
 
 	}
+	unuse_mm(dev->mm);
+	return 0;
 }
 
 /* Helper to allocate iovec buffers for all vqs. */
-- 
1.7.3-rc1
