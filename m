From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: macvtap: Fix csum_start when VLAN tags are present
Date: Mon, 3 Nov 2014 14:01:25 +0800
Message-ID: <20141103060125.GA28295@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60037 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaKCGB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 01:01:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When VLAN is in use in macvtap_put_user, we end up setting
csum_start to the wrong place.  The result is that the whoever
ends up doing the checksum setting will corrupt the packet instead
of writing the checksum to the expected location, usually this
means writing the checksum with an offset of -4.

This patch fixes this by adjusting csum_start when VLAN tags are
detected.

Fixes: f09e2249c4f5 ("macvtap: restore vlan header on user read")
Cc: stable@vger.kernel.org
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index d830e25..d2b8268 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -629,6 +629,8 @@ static void macvtap_skb_to_vnet_hdr(const struct sk_buff *skb,
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_NEEDS_CSUM;
 		vnet_hdr->csum_start = skb_checksum_start_offset(skb);
+		if (vlan_tx_tag_present(skb))
+			vnet_hdr->csum_start += VLAN_HLEN;
 		vnet_hdr->csum_offset = skb->csum_offset;
 	} else if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		vnet_hdr->flags = VIRTIO_NET_HDR_F_DATA_VALID;

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
