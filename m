From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Make simple TX hash little endian safe.
Date: Mon, 21 Jul 2008 10:48:07 +0200
Message-ID: <1216630088-10328-1-git-send-email-andi@firstfloor.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:28337 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbYGUIsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 04:48:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@basil.nowhere.org>

Currently it will not use the lower
bits at all on big endian system, mapping e.g. all connections to a single
queue on a local network which only differs in the low bits.

Also fold the upper 16 bits always in the lower 16bits.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 net/core/dev.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 2eed17b..c35fefc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1694,8 +1694,11 @@ static u16 simple_tx_hash(struct net_device *dev, struct sk_buff *skb)
 	ports = (u32 *) (skb_network_header(skb) + (ihl * 4));
 
 	hash = 0;
-	while (alen--)
-		hash ^= *addr++;
+	while (alen--) {
+		hash ^= ntohl(*addr); 
+		addr++;
+	}
+	hash ^= hash >> 16; /* More folding needed? */
 
 	switch (ip_proto) {
 	case IPPROTO_TCP:
-- 
1.5.6

