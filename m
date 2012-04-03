From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] marvell sky2 driver: fix so it works without unaligned accesses
Date: Tue, 3 Apr 2012 11:13:56 -0400
Message-ID: <201204031527.q33FR04i031747@farm-0027.internal.tilera.com>
To: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver uses a receive_new() routine that ends up requiring unaligned
accesses in IP header processing.  If the architecture doesn't support
efficient unaligned accesses, just copy all ingress packets to the bounce
buffers instead.

This allows the driver to be used on the Tilera TILEmpower-Gx, since
the tile architecture doesn't currently handle kernel unaligned accesses,
just userspace.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/ethernet/marvell/sky2.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 879b0a4..7a15482 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2490,6 +2490,7 @@ static struct sk_buff *receive_copy(struct sky2_port *sky2,
 	return skb;
 }
 
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
 /* Adjust length of skb with fragments to match received data */
 static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
 			  unsigned int length)
@@ -2555,6 +2556,7 @@ nomap:
 nobuf:
 	return NULL;
 }
+#endif /* CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS */
 
 /*
  * Receive one packet.
@@ -2598,10 +2600,12 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 		goto error;
 
 okay:
-	if (length < copybreak)
-		skb = receive_copy(sky2, re, length);
-	else
+#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (length >= copybreak)
 		skb = receive_new(sky2, re, length);
+	else
+#endif
+		skb = receive_copy(sky2, re, length);
 
 	dev->stats.rx_dropped += (skb == NULL);
 
-- 
1.6.5.2
