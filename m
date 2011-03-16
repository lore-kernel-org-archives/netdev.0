From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] dst: Clone child entry in skb_dst_pop
Date: Wed, 16 Mar 2011 08:09:32 +0100
Message-ID: <20110316070932.GR31402@secunet.com>
References: <20110316070828.GQ31402@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50334 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751920Ab1CPHJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 03:09:35 -0400
Content-Disposition: inline
In-Reply-To: <20110316070828.GQ31402@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We clone the child entry in skb_dst_pop before we call
skb_dst_drop(). Otherwise we might kill the child right
before we return it to the caller.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    2 +-
 net/xfrm/xfrm_output.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 2a46cba..75b95df 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -345,7 +345,7 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
 
 static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 {
-	struct dst_entry *child = skb_dst(skb)->child;
+	struct dst_entry *child = dst_clone(skb_dst(skb)->child);
 
 	skb_dst_drop(skb);
 	return child;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 8f3f0ee..47bacd8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -96,7 +96,7 @@ resume:
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
-		skb_dst_set(skb, dst_clone(dst));
+		skb_dst_set(skb, dst);
 		x = dst->xfrm;
 	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
-- 
1.7.0.4

