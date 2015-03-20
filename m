From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] net: clear skb->priority when forwarding to another netns
Date: Fri, 20 Mar 2015 14:29:09 -0700
Message-ID: <1426886949-12447-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33644 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbbCTV3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:29:32 -0400
Received: by pabxg6 with SMTP id xg6so107711159pab.0
        for <netdev@vger.kernel.org>; Fri, 20 Mar 2015 14:29:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->priority can be set for two purposes:

1) With respect to IP TOS field, which is computed by a mask.
Ususally used for priority qdisc's (pfifo, prio etc.), on TX
side (we only have ingress qdisc on RX side).

2) Used as a classid or flowid, works in the same way with tc
classid. What's more, this can even override the classid
of tc filters.

For case 1), it has been respected within its netns, I don't
see any point of keeping it for another netns, especially
when packets will be forwarded to Rx path (no matter from TX
path or RX path).

For case 2) we care, our applications run inside a netns,
and we classify the packets by our own filters outside,
If some application sets this priority, it could bypass
our filters, therefore clear it when moving out of a netns,
it makes no sense to bypass tc filters out of its netns.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5d43e01..a0408d4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1696,6 +1696,7 @@ int __dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	}
 
 	skb_scrub_packet(skb, true);
+	skb->priority = 0;
 	skb->protocol = eth_type_trans(skb, dev);
 	skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 
-- 
1.8.3.1
