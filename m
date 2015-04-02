From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net-next] virtio: document queue state logic
Date: Thu, 2 Apr 2015 13:05:47 +0200
Message-ID: <20150402125743-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

commit d631b94e7a15277858ec5f88d674d93080506999
    virtio: change comment in transmit

started clarifying the logic behind queue state management,
but introduced an inaccuracy: TX_BUSY does not cause
a BUG message.

Clean this up some more, explaining the tradeoffs in detail.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index a829930..63c7810 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -939,11 +939,15 @@ static netdev_tx_t start_xmit(struct sk_buff *skb, struct net_device *dev)
 	skb_orphan(skb);
 	nf_reset(skb);
 
-	/* It is better to stop queue if running out of space
-	 * instead of forcing queuing layer to requeue the skb
-	 * by returning TX_BUSY (and cause a BUG message).
-	 * Since most packets only take 1 or 2 ring slots
-	 * this means 16 slots are typically wasted.
+	/* If running out of space, stop queue to avoid getting packets that we
+	 * are then unable to transmit.
+	 * An alternative would be to force queuing layer to requeue the skb by
+	 * returning NETDEV_TX_BUSY. However, NETDEV_TX_BUSY should not be
+	 * returned in a normal path of operation: it means that driver is not
+	 * maintaining the TX queue stop/start state properly, and causes
+	 * the stack to do a non-trivial amount of useless work.
+	 * Since most packets only take 1 or 2 ring slots, stopping the queue
+	 * early means 16 slots are typically wasted.
 	 */
 	if (sq->vq->num_free < 2+MAX_SKB_FRAGS) {
 		netif_stop_subqueue(dev, qnum);
