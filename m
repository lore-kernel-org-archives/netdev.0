From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next RFC 0/3] virtio-net: Conditionally enable tx
	interrupt
Date: Wed, 15 Oct 2014 02:06:27 +0300
Message-ID: <20141014230627.GA23715@redhat.com>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
	<20141014.145327.365091739350390288.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-api@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20141014.145327.365091739350390288.davem@davemloft.net>
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

On Tue, Oct 14, 2014 at 02:53:27PM -0400, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Sat, 11 Oct 2014 15:16:43 +0800
> 
> > We free old transmitted packets in ndo_start_xmit() currently, so any
> > packet must be orphaned also there. This was used to reduce the overhead of
> > tx interrupt to achieve better performance. But this may not work for some
> > protocols such as TCP stream. TCP depends on the value of sk_wmem_alloc to
> > implement various optimization for small packets stream such as TCP small
> > queue and auto corking. But orphaning packets early in ndo_start_xmit()
> > disable such things more or less since sk_wmem_alloc was not accurate. This
> > lead extra low throughput for TCP stream of small writes.
> > 
> > This series tries to solve this issue by enable tx interrupts for all TCP
> > packets other than the ones with push bit or pure ACK. This is done through
> > the support of urgent descriptor which can force an interrupt for a
> > specified packet. If tx interrupt was enabled for a packet, there's no need
> > to orphan it in ndo_start_xmit(), we can free it tx napi which is scheduled
> > by tx interrupt. Then sk_wmem_alloc was more accurate than before and TCP
> > can batch more for small write. More larger skb was produced by TCP in this
> > case to improve both throughput and cpu utilization.
> > 
> > Test shows great improvements on small write tcp streams. For most of the
> > other cases, the throughput and cpu utilization are the same in the
> > past. Only few cases, more cpu utilization was noticed which needs more
> > investigation.
> > 
> > Review and comments are welcomed.
> 
> I think proper accounting and queueing (at all levels, not just TCP
> sockets) is more important than trying to skim a bunch of cycles by
> avoiding TX interrupts.
> 
> Having an event to free the SKB is absolutely essential for the stack
> to operate correctly.
> 
> And with virtio-net you don't even have the excuse of "the HW
> unfortunately doesn't have an appropriate TX event."
> 
> So please don't play games, and instead use TX interrupts all the
> time.  You can mitigate them in various ways, but don't turn them on
> selectively based upon traffic type, that's terrible.
> 
> You can even use ->xmit_more to defer the TX interrupt indication to
> the final TX packet in the chain.

I guess we can just defer the kick, interrupt will naturally be
deferred as well.
This should solve the problem for old hosts as well.

We'll also need to implement bql for this.
Something like the below?
Completely untested - posting here to see if I figured the
API out correctly. Has to be applied on top of the previous patch.

---

virtio_net: bql + xmit_more

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 62c059d..c245047 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -213,13 +213,15 @@ static struct page *get_a_page(struct receive_queue *rq, gfp_t gfp_mask)
 	return p;
 }
 
-static int free_old_xmit_skbs(struct send_queue *sq, int budget)
+static int free_old_xmit_skbs(struct netdev_queue *txq,
+			      struct send_queue *sq, int budget)
 {
 	struct sk_buff *skb;
 	unsigned int len;
 	struct virtnet_info *vi = sq->vq->vdev->priv;
 	struct virtnet_stats *stats = this_cpu_ptr(vi->stats);
 	int sent = 0;
+	unsigned int bytes = 0;
 
 	while (sent < budget &&
 	       (skb = virtqueue_get_buf(sq->vq, &len)) != NULL) {
@@ -227,6 +229,7 @@ static int free_old_xmit_skbs(struct send_queue *sq, int budget)
 
 		u64_stats_update_begin(&stats->tx_syncp);
 		stats->tx_bytes += skb->len;
+		bytes += skb->len;
 		stats->tx_packets++;
 		u64_stats_update_end(&stats->tx_syncp);
 
@@ -234,6 +237,8 @@ static int free_old_xmit_skbs(struct send_queue *sq, int budget)
 		sent++;
 	}
 
+	netdev_tx_completed_queue(txq, sent, bytes);
+
 	return sent;
 }
 
@@ -802,7 +807,7 @@ static int virtnet_poll_tx(struct napi_struct *napi, int budget)
 again:
 	__netif_tx_lock(txq, smp_processor_id());
 	virtqueue_disable_cb(sq->vq);
-	sent += free_old_xmit_skbs(sq, budget - sent);
+	sent += free_old_xmit_skbs(txq, sq, budget - sent);
 
 	if (sent < budget) {
 		r = virtqueue_enable_cb_prepare(sq->vq);
@@ -951,6 +956,9 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int qnum = skb_get_queue_mapping(skb);
 	struct send_queue *sq = &vi->sq[qnum];
 	int err, qsize = virtqueue_get_vring_size(sq->vq);
+	struct netdev_queue *txq = netdev_get_tx_queue(dev, qnum);
+	bool kick = !skb->xmit_more || netif_xmit_stopped(txq);
+	unsigned int bytes = skb->len;
 
 	virtqueue_disable_cb(sq->vq);
 
@@ -967,7 +975,11 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
-	virtqueue_kick(sq->vq);
+
+	netdev_tx_sent_queue(txq, bytes);
+
+	if (kick)
+		virtqueue_kick(sq->vq);
 
 	/* Apparently nice girls don't return TX_BUSY; stop the queue
 	 * before it gets out of hand.  Naturally, this wastes entries. */
@@ -975,14 +987,14 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 		netif_stop_subqueue(dev, qnum);
 		if (unlikely(!virtqueue_enable_cb_delayed(sq->vq))) {
 			/* More just got used, free them then recheck. */
-			free_old_xmit_skbs(sq, qsize);
+			free_old_xmit_skbs(txq, sq, qsize);
 			if (sq->vq->num_free >= 2+MAX_SKB_FRAGS) {
 				netif_start_subqueue(dev, qnum);
 				virtqueue_disable_cb(sq->vq);
 			}
 		}
 	} else if (virtqueue_enable_cb_delayed(sq->vq)) {
-		free_old_xmit_skbs(sq, qsize);
+		free_old_xmit_skbs(txq, sq, qsize);
 	}
 
 	return NETDEV_TX_OK;
