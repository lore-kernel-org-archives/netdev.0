From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net] net: orphan frags on stand-alone ptype in dev_queue_xmit_nit
Date: Fri, 22 Sep 2017 18:51:41 -0400
Message-ID: <20170922225141.126435-1-willemb@google.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:57295 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdIVWvp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 18:51:45 -0400
Received: by mail-qk0-f172.google.com with SMTP id g128so2392915qke.13
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 15:51:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zerocopy skbs frags are copied when the skb is looped to a local sock.
Commit 1080e512d44d ("net: orphan frags on receive") introduced calls
to skb_orphan_frags to deliver_skb and __netif_receive_skb.

With msg_zerocopy, these skbs can also exist in the tx path and thus
loop from dev_queue_xmit_nit. This already calls deliver_skb in its
loop. But it does not orphan before a separate pt_prev->func().

Add the missing skb_orphan_frags_rx.

Fixes: 1f8b977ab32d ("sock: enable MSG_ZEROCOPY")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 9a2254f9802f..3f5b26ff4f74 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1948,7 +1948,7 @@ void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		goto again;
 	}
 out_unlock:
-	if (pt_prev)
+	if (pt_prev && !skb_orphan_frags_rx(skb2, GFP_ATOMIC))
 		pt_prev->func(skb2, skb->dev, pt_prev, skb->dev);
 	rcu_read_unlock();
 }
-- 
2.14.1.821.g8fa685d3b7-goog
