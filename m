From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] macvtap: fix network header pointer for VLAN tagged pkts
Date: Mon, 20 Jul 2015 17:44:21 +0200
Message-ID: <1437407061-8698-1-git-send-email-ivecera@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35490 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754142AbbGTPnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 11:43:35 -0400
Received: from int-mx13.intmail.prod.int.phx2.redhat.com (int-mx13.intmail.prod.int.phx2.redhat.com [10.5.11.26])
	by mx1.redhat.com (Postfix) with ESMTPS id CF30635B8A2
	for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 15:43:35 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network header is set with offset ETH_HLEN but it is not true for VLAN
(multiple-)tagged and results in checksum issues in lower devices.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/macvtap.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3b933bb..cdcbab4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -796,6 +796,12 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_hdr(skb)->h_proto;
 
+	if (skb_vlan_tagged(skb)) {
+		int depth;
+		skb->protocol = __vlan_get_protocol(skb, skb->protocol, &depth);
+		skb_set_network_header(skb, depth);
+	}
+
 	if (vnet_hdr_len) {
 		err = macvtap_skb_from_vnet_hdr(q, skb, &vnet_hdr);
 		if (err)
-- 
2.3.6
