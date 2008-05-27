From: Mark McLoughlin <markmc@redhat.com>
Subject: [PATCH 3/3] virtio_net: Fix skb->csum_start computation
Date: Tue, 27 May 2008 12:20:47 +0100
Message-ID: <1211887247-31979-4-git-send-email-markmc@redhat.com>
References: <1211887247-31979-1-git-send-email-markmc@redhat.com>
 <1211887247-31979-2-git-send-email-markmc@redhat.com>
 <1211887247-31979-3-git-send-email-markmc@redhat.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Mark McLoughlin <markmc@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail14.svc.cra.dublin.eircom.net ([159.134.118.30]:46376 "HELO
	mail14.svc.cra.dublin.eircom.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756864AbYE0L1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 May 2008 07:27:30 -0400
In-Reply-To: <1211887247-31979-3-git-send-email-markmc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hdr->csum_start is the offset from the start of the ethernet
header to the transport layer checksum field. skb->csum_start
is the offset from skb->head.

skb_partial_csum_set() assumes that skb->data points to the
ethernet header - i.e. it computes skb->csum_start by adding
the headroom to hdr->csum_start.

Since eth_type_trans() skb_pull()s the ethernet header,
skb_partial_csum_set() should be called before
eth_type_trans().

Signed-off-by: Mark McLoughlin <markmc@redhat.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 drivers/net/virtio_net.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

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
-- 
1.5.4.1

