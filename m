From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net 8/9] virtio-net: remove big packet XDP codes
Date: Fri, 23 Dec 2016 22:37:31 +0800
Message-ID: <1482503852-12438-9-git-send-email-jasowang@redhat.com>
References: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com
To: mst@redhat.com, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1482503852-12438-1-git-send-email-jasowang@redhat.com>
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

Now we in fact don't allow XDP for big packets, remove its codes.

Cc: John Fastabend <john.r.fastabend@intel.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/virtio_net.c | 44 +++-----------------------------------------
 1 file changed, 3 insertions(+), 41 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index c1f66d8..e53365a8 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -344,11 +344,7 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 	/* Free up any pending old buffers before queueing new ones. */
 	while ((xdp_sent = virtqueue_get_buf(sq->vq, &len)) != NULL) {
 		struct page *sent_page = virt_to_head_page(xdp_sent);
-
-		if (vi->mergeable_rx_bufs)
-			put_page(sent_page);
-		else
-			give_pages(rq, sent_page);
+		put_page(sent_page);
 	}
 
 	/* Zero header and leave csum up to XDP layers */
@@ -360,15 +356,8 @@ static void virtnet_xdp_xmit(struct virtnet_info *vi,
 	err = virtqueue_add_outbuf(sq->vq, sq->sg, num_sg,
 				   xdp->data, GFP_ATOMIC);
 	if (unlikely(err)) {
-		if (vi->mergeable_rx_bufs)
-			put_page(page);
-		else
-			give_pages(rq, page);
+		put_page(page);
 		return; // On error abort to avoid unnecessary kick
-	} else if (!vi->mergeable_rx_bufs) {
-		/* If not mergeable bufs must be big packets so cleanup pages */
-		give_pages(rq, (struct page *)page->private);
-		page->private = 0;
 	}
 
 	virtqueue_kick(sq->vq);
@@ -430,44 +419,17 @@ static struct sk_buff *receive_big(struct net_device *dev,
 				   void *buf,
 				   unsigned int len)
 {
-	struct bpf_prog *xdp_prog;
 	struct page *page = buf;
-	struct sk_buff *skb;
-
-	rcu_read_lock();
-	xdp_prog = rcu_dereference(rq->xdp_prog);
-	if (xdp_prog) {
-		struct virtio_net_hdr_mrg_rxbuf *hdr = buf;
-		u32 act;
-
-		if (unlikely(hdr->hdr.gso_type))
-			goto err_xdp;
-		act = do_xdp_prog(vi, rq, xdp_prog, page, 0, len);
-		switch (act) {
-		case XDP_PASS:
-			break;
-		case XDP_TX:
-			rcu_read_unlock();
-			goto xdp_xmit;
-		case XDP_DROP:
-		default:
-			goto err_xdp;
-		}
-	}
-	rcu_read_unlock();
+	struct sk_buff *skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 
-	skb = page_to_skb(vi, rq, page, 0, len, PAGE_SIZE);
 	if (unlikely(!skb))
 		goto err;
 
 	return skb;
 
-err_xdp:
-	rcu_read_unlock();
 err:
 	dev->stats.rx_dropped++;
 	give_pages(rq, page);
-xdp_xmit:
 	return NULL;
 }
 
-- 
2.7.4
