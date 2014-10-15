From: Jason Wang <jasowang@redhat.com>
Subject: [RFC PATCH net-next 6/6] virtio-net: enable tx interrupt only for the final skb in the chain
Date: Wed, 15 Oct 2014 15:25:30 +0800
Message-ID: <1413357930-45302-7-git-send-email-jasowang@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	Jason Wang <jasowang@redhat.com>
To: rusty@rustcorp.com.au, mst@redhat.com,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the help of xmit_more and virtqueue_enable_cb_avail(), this patch
enable tx interrupt only for the final skb in the chain if
needed. This will help to mitigate tx interrupts.

Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 2afc2e2..5943f3f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -993,12 +993,16 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 				virtqueue_disable_cb(sq->vq);
 			}
 		}
-	} else if (virtqueue_enable_cb(sq->vq)) {
-		free_old_xmit_skbs(sq, qsize);
 	}
 
-	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more)
+	if (__netif_subqueue_stopped(dev, qnum) || !skb->xmit_more) {
 		virtqueue_kick(sq->vq);
+		if (sq->vq->num_free >= 2 +MAX_SKB_FRAGS &&
+		    unlikely(virtqueue_enable_cb_avail(sq->vq))) {
+			free_old_xmit_skbs(sq, qsize);
+			virtqueue_disable_cb(sq->vq);
+		}
+	}
 
 	return NETDEV_TX_OK;
 }
-- 
1.7.1
