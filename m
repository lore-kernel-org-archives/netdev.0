From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v2] macvtap: fix network header pointer for VLAN tagged pkts
Date: Tue, 21 Jul 2015 09:18:35 +0200
Message-ID: <1437463115-2881-1-git-send-email-ivecera@redhat.com>
Cc: vyasevich@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41324 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751940AbbGUHRt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Jul 2015 03:17:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network header is set with offset ETH_HLEN but it is not true for VLAN
(multiple-)tagged and results in checksum issues in lower devices.

v2: leave skb->protocol untouched (thx Vlad), comment added

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/macvtap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3b933bb..b75776b 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -796,6 +796,13 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_hdr(skb)->h_proto;
 
+	/* Move network header to the right position for VLAN tagged packets */
+	if (skb_vlan_tagged(skb)) {
+		int depth;
+		__vlan_get_protocol(skb, skb->protocol, &depth);
+		skb_set_network_header(skb, depth);
+	}
+
 	if (vnet_hdr_len) {
 		err = macvtap_skb_from_vnet_hdr(q, skb, &vnet_hdr);
 		if (err)
-- 
2.3.6
