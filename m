From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] tun: Fix csum_start with VLAN acceleration
Date: Mon, 03 Nov 2014 04:30:13 +0800
Message-ID: <E1Xl1mv-0006Ux-VP@gondolin.me.apana.org.au>
References: <20141102202929.GA24935@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55933 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751206AbaKBUaQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Nov 2014 15:30:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VLAN acceleration is in use on the xmit path, we end up
setting csum_start to the wrong place.  The result is that the
whoever ends up doing the checksum setting will corrupt the packet
instead of writing the checksum to the expected location, usually
this means writing the checksum with an offset of -4.

This patch fixes this by adjusting csum_start when VLAN acceleration
is detected.

Fixes: 6680ec68eff4 ("tuntap: hardware vlan tx support")
Cc: stable@vger.kernel.org
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/net/tun.c |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7302398..57e6bf7 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1235,6 +1235,10 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
 	int vlan_offset = 0, copied;
+	int vlan_hlen = 0;
+
+	if (vlan_tx_tag_present(skb))
+		vlan_hlen = VLAN_HLEN;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
@@ -1284,7 +1288,8 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			gso.flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
-			gso.csum_start = skb_checksum_start_offset(skb);
+			gso.csum_start = skb_checksum_start_offset(skb) +
+					 vlan_hlen;
 			gso.csum_offset = skb->csum_offset;
 		} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 			gso.flags = VIRTIO_NET_HDR_F_DATA_VALID;
@@ -1297,10 +1302,9 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 	}
 
 	copied = total;
-	total += skb->len;
-	if (!vlan_tx_tag_present(skb)) {
-		len = min_t(int, skb->len, len);
-	} else {
+	len = min_t(int, skb->len + vlan_hlen, len);
+	total += skb->len + vlan_hlen;
+	if (vlan_hlen) {
 		int copy, ret;
 		struct {
 			__be16 h_vlan_proto;
@@ -1311,8 +1315,6 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
 
 		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
-		len = min_t(int, skb->len + VLAN_HLEN, len);
-		total += VLAN_HLEN;
 
 		copy = min_t(int, vlan_offset, len);
 		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
