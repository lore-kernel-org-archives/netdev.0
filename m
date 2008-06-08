From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 1/4] virtio_net: Fix skb->csum_start computation
Date: Sun, 8 Jun 2008 20:49:00 +1000
Message-ID: <200806082049.00641.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:33193 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759423AbYFHKtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jun 2008 06:49:15 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark McLoughlin <markmc@redhat.com>

hdr->csum_start is the offset from the start of the ethernet
header to the transport layer checksum field. skb->csum_start
is the offset from skb->head.

skb_partial_csum_set() assumes that skb->data points to the
ethernet header - i.e. it computes skb->csum_start by adding
the headroom to hdr->csum_start.

Since eth_type_trans() skb_pull()s the ethernet header,
skb_partial_csum_set() should be called before
eth_type_trans().

(Without this patch, GSO packets from a guest to the world outside the
host are corrupted).

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 50e6e59..503486f 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -86,9 +86,7 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 	BUG_ON(len > MAX_PACKET_LEN);
 
 	skb_trim(skb, len);
-	skb->protocol = eth_type_trans(skb, dev);
-	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
-		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+
 	dev->stats.rx_bytes += skb->len;
 	dev->stats.rx_packets++;
 
@@ -98,6 +96,10 @@ static void receive_skb(struct net_device *dev, struct sk_buff *skb,
 			goto frame_err;
 	}
 
+	skb->protocol = eth_type_trans(skb, dev);
+	pr_debug("Receiving skb proto 0x%04x len %i type %i\n",
+		 ntohs(skb->protocol), skb->len, skb->pkt_type);
+
 	if (hdr->gso_type != VIRTIO_NET_HDR_GSO_NONE) {
 		pr_debug("GSO!\n");
 		switch (hdr->gso_type & ~VIRTIO_NET_HDR_GSO_ECN) {
