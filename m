From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: macvtap: Limit packet queue length
Date: Thu, 22 Jul 2010 14:41:57 +0800
Message-ID: <20100722064157.GA25913@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mark Wagner <mwagner@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47929 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564Ab0GVGmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 02:42:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

macvtap: Limit packet queue length

Mark Wagner reported OOM symptoms when sending UDP traffic over
a macvtap link to a kvm receiver.

This appears to be caused by the fact that macvtap packet queues
are unlimited in length.  This means that if the receiver can't
keep up with the rate of flow, then we will hit OOM. Of course
it gets worse if the OOM killer then decides to kill the receiver.

This patch imposes a cap on the packet queue length, in the same
way as the tuntap driver, using the device TX queue length.

Please note that macvtap currently has no way of giving congestion
notification, that means the software device TX queue cannot be
used and packets will always be dropped once the macvtap driver
queue fills up.

This shouldn't be a great problem for the scenario where macvtap
is used to feed a kvm receiver, as the traffic is most likely
external in origin so congestion notification can't be applied
anyway.

Of course, if anybody decides to complain about guest-to-guest
UDP packet loss down the track, then we may have to revisit this.

Incidentally, this patch also fixes a real memory leak when
macvtap_get_queue fails.

Reported-by: Mark Wagner <mwagner@redhat.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a8a94e2..488d3b9 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -180,11 +180,18 @@ static int macvtap_forward(struct net_device *dev, struct sk_buff *skb)
 {
 	struct macvtap_queue *q = macvtap_get_queue(dev, skb);
 	if (!q)
-		return -ENOLINK;
+		goto drop;
+
+	if (skb_queue_len(&q->sk.sk_receive_queue) >= dev->tx_queue_len)
+		goto drop;
 
 	skb_queue_tail(&q->sk.sk_receive_queue, skb);
 	wake_up_interruptible_poll(sk_sleep(&q->sk), POLLIN | POLLRDNORM | POLLRDBAND);
-	return 0;
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
 }
 
 /*

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
