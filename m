From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net v3] macvtap: fix network header pointer for VLAN tagged pkts
Date: Thu, 23 Jul 2015 16:37:43 +0200
Message-ID: <1437662263-2733-1-git-send-email-ivecera@redhat.com>
Cc: vyasevich@gmail.com, toshiaki.makita1@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613AbbGWOgz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 10:36:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Network header is set with offset ETH_HLEN but it is not true for VLAN
(multiple-)tagged and results in checksum issues in lower devices.

v2: leave skb->protocol untouched (thx Vlad), comment added
v3: moved after skb_probe_transport_header() call (thx Toshiaki)

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/macvtap.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 3b933bb..edd7734 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -719,6 +719,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	struct virtio_net_hdr vnet_hdr = { 0 };
 	int vnet_hdr_len = 0;
 	int copylen = 0;
+	int depth;
 	bool zerocopy = false;
 	size_t linear;
 	ssize_t n;
@@ -804,6 +805,12 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 
 	skb_probe_transport_header(skb, ETH_HLEN);
 
+	/* Move network header to the right position for VLAN tagged packets */
+	if ((skb->protocol == htons(ETH_P_8021Q) ||
+	     skb->protocol == htons(ETH_P_8021AD)) &&
+	    __vlan_get_protocol(skb, skb->protocol, &depth) != 0)
+		skb_set_network_header(skb, depth);
+
 	rcu_read_lock();
 	vlan = rcu_dereference(q->vlan);
 	/* copy skb_ubuf_info for callback when skb has no error */
-- 
2.3.6
