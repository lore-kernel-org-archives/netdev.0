From: Jason Wang <jasowang@redhat.com>
Subject: [RFC V7 PATCH 7/7] vhost_net: add interrupt coalescing support
Date: Mon, 25 May 2015 01:24:04 -0400
Message-ID: <1432531444-50193-8-git-send-email-jasowang@redhat.com>
References: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Cc: rusty@rustcorp.com.au, Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1432531444-50193-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/vhost/net.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index 7d137a4..5ee28b7 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -320,6 +320,9 @@ static void handle_tx(struct vhost_net *net)
 	hdr_size = nvq->vhost_hlen;
 	zcopy = nvq->ubufs;
 
+	/* Finish pending interrupts first */
+	vhost_check_coalesce_and_signal(vq->dev, vq, false);
+
 	for (;;) {
 		/* Release DMAs done buffers first */
 		if (zcopy)
@@ -415,6 +418,7 @@ static void handle_tx(struct vhost_net *net)
 		}
 	}
 out:
+	vhost_check_coalesce_and_signal(vq->dev, vq, true);
 	mutex_unlock(&vq->mutex);
 }
 
@@ -554,6 +558,9 @@ static void handle_rx(struct vhost_net *net)
 		vq->log : NULL;
 	mergeable = vhost_has_feature(vq, VIRTIO_NET_F_MRG_RXBUF);
 
+	/* Finish pending interrupts first */
+	vhost_check_coalesce_and_signal(vq->dev, vq, false);
+
 	while ((sock_len = peek_head_len(sock->sk))) {
 		sock_len += sock_hlen;
 		vhost_len = sock_len + vhost_hlen;
@@ -638,6 +645,7 @@ static void handle_rx(struct vhost_net *net)
 		}
 	}
 out:
+	vhost_check_coalesce_and_signal(vq->dev, vq, true);
 	mutex_unlock(&vq->mutex);
 }
 
-- 
1.8.3.1
