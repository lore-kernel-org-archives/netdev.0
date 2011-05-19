From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH net-next-2.6] macvlan: Forward unicast frames in bridge mode to lowerdev
Date: Thu, 19 May 2011 08:53:20 -0400
Message-ID: <1305809600-1371-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>,
	Patrick McHardy <kaber@trash.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:54978 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757138Ab1ESOnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 10:43:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unicast frames between macvlan interfaces in bridge mode are not otherwise
sent to network taps on the lowerdev (as all other macvlan frames are), so
forward the frames to the receive queue of the lowerdev first.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/macvlan.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index d7c0bc62..e7de3b3 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -237,10 +237,8 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		dest = macvlan_hash_lookup(port, eth->h_dest);
 		if (dest && dest->mode == MACVLAN_MODE_BRIDGE) {
-			unsigned int length = skb->len + ETH_HLEN;
-			int ret = dest->forward(dest->dev, skb);
-			macvlan_count_rx(dest, length,
-					 ret == NET_RX_SUCCESS, 0);
+			/* send to lowerdev first for its network taps */
+			vlan->forward(vlan->lowerdev, skb);
 
 			return NET_XMIT_SUCCESS;
 		}
-- 
1.7.4.4

