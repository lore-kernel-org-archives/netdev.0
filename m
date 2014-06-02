From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 1/2] 6lowpan_rtnl: fix fragmentation with two fragments
Date: Mon,  2 Jun 2014 13:21:57 +0200
Message-ID: <1401708118-16436-2-git-send-email-alex.aring@gmail.com>
References: <1401708118-16436-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	werner@almesberger.net, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:53555 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753237AbaFBLWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 07:22:14 -0400
Received: by mail-wg0-f49.google.com with SMTP id m15so4962646wgh.20
        for <netdev@vger.kernel.org>; Mon, 02 Jun 2014 04:22:13 -0700 (PDT)
In-Reply-To: <1401708118-16436-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fix the 6LoWPAN fragmentation for the case if we have exactly
two fragments. The problem is that the (skb_unprocessed >= frag_cap)
condition is always false on the second fragment after sending the first
fragment. A fragmentation with only one fragment doesn't make any sense.
The solution is that we use a do while loop here, that ensures we sending
always a minimum of two fragments if we need a fragmentation.

This issue was introduced by commit d4b2816d67d6e07b2f27037f282d8db03a5829d7
("6lowpan: fix fragmentation").

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ieee802154/6lowpan_rtnl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 1ae8a56..9d57026 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -312,7 +312,7 @@ lowpan_xmit_fragmented(struct sk_buff *skb, struct net_device *dev,
 	frag_hdr[0] |= LOWPAN_DISPATCH_FRAGN;
 	frag_cap = round_down(payload_cap - LOWPAN_FRAGN_HEAD_SIZE, 8);
 
-	while (skb_unprocessed >= frag_cap) {
+	do {
 		dgram_offset += frag_len;
 		skb_offset += frag_len;
 		skb_unprocessed -= frag_len;
@@ -328,7 +328,7 @@ lowpan_xmit_fragmented(struct sk_buff *skb, struct net_device *dev,
 				 __func__, frag_tag, skb_offset);
 			goto err;
 		}
-	}
+	} while (skb_unprocessed >= frag_cap);
 
 	consume_skb(skb);
 	return NET_XMIT_SUCCESS;
-- 
1.9.3
