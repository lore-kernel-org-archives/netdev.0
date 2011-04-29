From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCHv2 2/2] macvlan: Send frames to AF_PACKET sockets attached to lowerdev
Date: Thu, 28 Apr 2011 20:22:32 -0400
Message-ID: <1304036552-1589-3-git-send-email-david.ward@ll.mit.edu>
References: <1304036552-1589-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:45059 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757223Ab1D2Azq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 20:55:46 -0400
In-Reply-To: <1304036552-1589-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In bridge mode, unicast frames can be forwarded directly between macvlan
interfaces attached to the same lowerdev without calling dev_queue_xmit.
These frames should still be sent to any AF_PACKET sockets (network taps)
attached to the lowerdev.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/macvlan.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3ad5425..25c7632 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -238,7 +238,10 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
 			unsigned int length = skb->len + ETH_HLEN;
-			int ret = dest->forward(dest->dev, skb);
+			int ret = NET_RX_DROP;
+
+			dev_queue_xmit_nit(skb, vlan->lowerdev);
+			ret = dest->forward(dest->dev, skb);
 			macvlan_count_rx(dest, length,
 					 ret == NET_RX_SUCCESS, 0);
 
-- 
1.7.4.4

