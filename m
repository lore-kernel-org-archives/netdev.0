From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH v2] net: check for refcount if pop a stacked dst_entry
Date: Fri, 4 Jun 2010 13:57:38 +0200
Message-ID: <20100604115737.GA5570@secunet.com>
References: <20100604104012.GA13408@secunet.com>
 <20100604104115.GB13408@secunet.com>
 <1275648679.2482.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44499 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753253Ab0FDL6M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 07:58:12 -0400
Content-Disposition: inline
In-Reply-To: <1275648679.2482.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm triggers a warning if dst_pop() drops a refcount
on a noref dst. This patch changes dst_pop() to
skb_dst_pop(). skb_dst_pop() drops the refcnt only
on a refcounted dst. Also we don't clone the child
dst_entry, so it is not refcounted and we can use
skb_dst_set_noref() in xfrm_output_one().

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    6 +++---
 net/xfrm/xfrm_output.c |    4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 612069b..81d1413 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -250,11 +250,11 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
  * Linux networking.  Thus, destinations are stackable.
  */
 
-static inline struct dst_entry *dst_pop(struct dst_entry *dst)
+static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 {
-	struct dst_entry *child = dst_clone(dst->child);
+	struct dst_entry *child = skb_dst(skb)->child;
 
-	dst_release(dst);
+	skb_dst_drop(skb);
 	return child;
 }
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 6a32915..a3cca0a 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -95,13 +95,13 @@ resume:
 			goto error_nolock;
 		}
 
-		dst = dst_pop(dst);
+		dst = skb_dst_pop(skb);
 		if (!dst) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			err = -EHOSTUNREACH;
 			goto error_nolock;
 		}
-		skb_dst_set(skb, dst);
+		skb_dst_set_noref(skb, dst);
 		x = dst->xfrm;
 	} while (x && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL));
 
-- 
1.5.6.5

