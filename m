From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/2] tun: Fix TUN_PKT_STRIP setting
Date: Mon, 03 Nov 2014 04:30:14 +0800
Message-ID: <E1Xl1mw-0006VA-L1@gondolin.me.apana.org.au>
References: <20141102202929.GA24935@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:44516 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaKBUaR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 15:30:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We set the flag TUN_PKT_STRIP if the user buffer provided is too
small to contain the entire packet plus meta-data.  However, this
has been broken ever since we added GSO meta-data.  VLAN acceleration
also has the same problem.

This patch fixes this by taking both into account when setting the
TUN_PKT_STRIP flag.

The fact that this has been broken for six years without anyone
realising means that nobody actually uses this flag.

Fixes: f43798c27684 ("tun: Allow GSO using virtio_net_hdr")
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/tun.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 57e6bf7..9dd3746 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1236,15 +1236,19 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	ssize_t total = 0;
 	int vlan_offset = 0, copied;
 	int vlan_hlen = 0;
+	int vnet_hdr_sz = 0;
 
 	if (vlan_tx_tag_present(skb))
 		vlan_hlen = VLAN_HLEN;
 
+	if (tun->flags & TUN_VNET_HDR)
+		vnet_hdr_sz = tun->vnet_hdr_sz;
+
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
 			return -EINVAL;
 
-		if (len < skb->len) {
+		if (len < skb->len + vlan_hlen + vnet_hdr_sz) {
 			/* Packet will be striped */
 			pi.flags |= TUN_PKT_STRIP;
 		}
@@ -1254,9 +1258,9 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += sizeof(pi);
 	}
 
-	if (tun->flags & TUN_VNET_HDR) {
+	if (vnet_hdr_sz) {
 		struct virtio_net_hdr gso = { 0 }; /* no info leak */
-		if ((len -= tun->vnet_hdr_sz) < 0)
+		if ((len -= vnet_hdr_sz) < 0)
 			return -EINVAL;
 
 		if (skb_is_gso(skb)) {
@@ -1298,7 +1302,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		if (unlikely(memcpy_toiovecend(iv, (void *)&gso, total,
 					       sizeof(gso))))
 			return -EFAULT;
-		total += tun->vnet_hdr_sz;
+		total += vnet_hdr_sz;
 	}
 
 	copied = total;
