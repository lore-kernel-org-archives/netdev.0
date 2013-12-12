From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net] xen-netback: fix gso_prefix check
Date: Thu, 12 Dec 2013 14:20:13 +0000
Message-ID: <1386858013-20544-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:64376 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395Ab3LLOUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 09:20:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a mistake in checking the gso_prefix mask when passing large
packets to a guest. The wrong shift is applied to the bit - the raw skb
gso type is used rather then the translated one. This leads to large packets
being handed to the guest without the GSO metadata. This patch fixes the
check.

The mistake manifested as errors whilst running Microsoft HCK large packet
offload tests between a pair of Windows 8 VMs. I have verified this patch
fixes those errors.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Cc: Wei Liu <wei.liu2@citrix.com>
Cc: Ian Campbell <ian.campbell@citrix.com>
Cc: David Vrabel <david.vrabel@citrix.com>
---
 drivers/net/xen-netback/netback.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 56c3e5a..999e290 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -452,7 +452,7 @@ static int xenvif_gop_skb(struct sk_buff *skb,
 	}
 
 	/* Set up a GSO prefix descriptor, if necessary */
-	if ((1 << skb_shinfo(skb)->gso_type) & vif->gso_prefix_mask) {
+	if ((1 << gso_type) & vif->gso_prefix_mask) {
 		req = RING_GET_REQUEST(&vif->rx, vif->rx.req_cons++);
 		meta = npo->meta + npo->meta_prod++;
 		meta->gso_type = gso_type;
-- 
1.7.10.4
