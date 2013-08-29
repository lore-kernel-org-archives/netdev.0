From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: revert 8728c544a9c ("net: dev_pick_tx() fix")
Date: Wed, 28 Aug 2013 18:10:43 -0700
Message-ID: <1377738643.8277.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Xi Wang <xii@google.com>, Tom Herbert <therbert@google.com>,
	Denys Fedorysychenko <nuclearcat@nuclearcat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:37542 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753044Ab3H2BKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 21:10:46 -0400
Received: by mail-pa0-f50.google.com with SMTP id fb10so189638pad.37
        for <netdev@vger.kernel.org>; Wed, 28 Aug 2013 18:10:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 8728c544a9cbdc ("net: dev_pick_tx() fix") and commit
b6fe83e9525a ("bonding: refine IFF_XMIT_DST_RELEASE capability")
are quite incompatible : Queue selection is disabled because skb
dst was dropped before entering bonding device.

This causes major performance regression, mainly because TCP packets
for a given flow can be sent to multiple queues.

This is particularly visible when using the new FQ packet scheduler
with MQ + FQ setup on the slaves.

We can safely revert the first commit now that 416186fbf8c5b
("net: Split core bits of netdev_pick_tx into __netdev_pick_tx")
properly caps the queue_index.

Reported-by: Xi Wang <xii@google.com>
Diagnosed-by: Xi Wang <xii@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
Cc: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
---
Google-Bug-Id: 10230478

 net/core/flow_dissector.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 159737c..0ff42f0 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -350,14 +350,9 @@ u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 		if (new_index < 0)
 			new_index = skb_tx_hash(dev, skb);
 
-		if (queue_index != new_index && sk) {
-			struct dst_entry *dst =
-				    rcu_dereference_check(sk->sk_dst_cache, 1);
-
-			if (dst && skb_dst(skb) == dst)
-				sk_tx_queue_set(sk, queue_index);
-
-		}
+		if (queue_index != new_index && sk &&
+		    rcu_access_pointer(sk->sk_dst_cache))
+			sk_tx_queue_set(sk, queue_index);
 
 		queue_index = new_index;
 	}
