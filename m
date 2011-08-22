From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] net: vlan: goto another_round instead of calling __netif_receive_skb
Date: Mon, 22 Aug 2011 21:08:55 +0200
Message-ID: <1314040135-3414-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, mirqus@gmail.com, jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38432 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246Ab1HVTJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 15:09:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, when vlan tag on untagged in non-accelerated path is stripped from
skb, headers are reset right away. Benefit from that and avoid calling
__netif_receive_skb recursivelly and just use another_round.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/core/dev.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c2442b4..a4306f7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3236,10 +3236,9 @@ ncls:
 			ret = deliver_skb(skb, pt_prev, orig_dev);
 			pt_prev = NULL;
 		}
-		if (vlan_do_receive(&skb)) {
-			ret = __netif_receive_skb(skb);
-			goto out;
-		} else if (unlikely(!skb))
+		if (vlan_do_receive(&skb))
+			goto another_round;
+		else if (unlikely(!skb))
 			goto out;
 	}
 
-- 
1.7.6

