From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCHv2 net-next 4/4] macvtap: Perform GSO on forwarding path.
Date: Tue, 25 Jun 2013 16:04:22 -0400
Message-ID: <1372190662-30815-5-git-send-email-vyasevic@redhat.com>
References: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Cc: mst@redhat.com, eric.dumazet@gmail.com, davem@davemloft.net,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34516 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752240Ab3FYUEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 16:04:33 -0400
In-Reply-To: <1372190662-30815-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When macvtap forwards skb to its tap, it needs to check
if GSO needs to be performed.  This is sometimes necessary
when the HW device performed GRO, but the guest reading
from the tap does not support it (ex: Windows 7).

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/macvtap.c | 31 ++++++++++++++++++++++++++++++-
 1 file changed, 30 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 7eab019..e370b79 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -276,14 +276,43 @@ static void macvtap_del_queues(struct net_device *dev)
  */
 static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 {
+	struct macvlan_dev *vlan = netdev_priv(dev);
 	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
+	netdev_features_t features;
 	if (!q)
 		goto drop;
 
 	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
 		goto drop;
 
-	skb_queue_tail(&q->sk.sk_receive_queue, skb);
+	skb->dev = dev;
+	/* Apply the forward feature mask so that we perform segmentation
+	 * according to users wishes.
+	 */
+	features = netif_skb_features(skb) & vlan->tap_features;
+	if (netif_needs_gso(skb, features)) {
+		struct sk_buff *segs = __skb_gso_segment(skb, features, false);
+
+		if (IS_ERR(segs))
+			goto drop;
+
+		if (!segs) {
+			skb_queue_tail(&q->sk.sk_receive_queue, skb);
+			goto wake_up;
+		}
+
+		kfree_skb(skb);
+		while (segs) {
+			struct sk_buff *nskb = segs->next;
+
+			segs->next = NULL;
+			skb_queue_tail(&q->sk.sk_receive_queue, segs);
+			segs = nskb;
+		}
+	} else
+		skb_queue_tail(&q->sk.sk_receive_queue, skb);
+
+wake_up:
 	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
 	return NET_RX_SUCCESS;
 
-- 
1.8.1.4
