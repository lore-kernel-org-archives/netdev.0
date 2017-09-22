From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net v2] net: orphan frags on stand-alone ptype in dev_queue_xmit_nit
Date: Fri, 22 Sep 2017 19:42:37 -0400
Message-ID: <20170922234237.43174-1-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f181.google.com ([209.85.216.181]:47851 "EHLO
        mail-qt0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751974AbdIVXms (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 19:42:48 -0400
Received: by mail-qt0-f181.google.com with SMTP id b1so2560757qtc.4
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 16:42:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zerocopy skbs frags are copied when the skb is looped to a local sock.
Commit 1080e512d44d ("net: orphan frags on receive") introduced calls
to skb_orphan_frags to deliver_skb and __netif_receive_skb for this.

With msg_zerocopy, these skbs can also exist in the tx path and thus
loop from dev_queue_xmit_nit. This already calls deliver_skb in its
loop. But it does not orphan before a separate pt_prev->func().

Add the missing skb_orphan_frags_rx.

Changes
  v1->v2: handle skb_orphan_frags_rx failure

Fixes: 1f8b977ab32d ("sock: enable MSG_ZEROCOPY")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9a2254f9802f..588b473194a8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1948,8 +1948,12 @@ void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		goto again;
 	}
 out_unlock:
-	if (pt_prev)
-		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+	if (pt_prev) {
+		if (!skb_orphan_frags_rx(skb2, GFP_ATOMIC))
+			pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
+		else
+			kfree_skb(skb2);
+	}
 	rcu_read_unlock();
 }
 EXPORT_SYMBOL_GPL(dev_queue_xmit_nit);
-- 
2.14.1.821.g8fa685d3b7-goog
