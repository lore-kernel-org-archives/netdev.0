From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH] net: check for refcount if pop a stacked dst_entry
Date: Fri, 4 Jun 2010 12:41:15 +0200
Message-ID: <20100604104115.GB13408@secunet.com>
References: <20100604104012.GA13408@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51033 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753961Ab0FDKlt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jun 2010 06:41:49 -0400
Content-Disposition: inline
In-Reply-To: <20100604104012.GA13408@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm triggers a warning if dst_pop() drops a refcount
on a noref dst. This patch changes dst_pop() to
skb_dst_pop(). skb_dst_pop() drops the refcnt only
on a refcounted dst.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/dst.h      |    6 +++---
 net/xfrm/xfrm_output.c |    2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 612069b..acd1538 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -250,11 +250,11 @@ static inline void skb_tunnel_rx(struct sk_buff *skb, struct net_device *dev)
  * Linux networking.  Thus, destinations are stackable.
  */
 
-static inline struct dst_entry *dst_pop(struct dst_entry *dst)
+static inline struct dst_entry *skb_dst_pop(struct sk_buff *skb)
 {
-	struct dst_entry *child = dst_clone(dst->child);
+	struct dst_entry *child = dst_clone(skb_dst(skb)->child);
 
-	dst_release(dst);
+	skb_dst_drop(skb);
 	return child;
 }
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 6a32915..db62a06 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -95,7 +95,7 @@ resume:
 			goto error_nolock;
 		}
 
-		dst = dst_pop(dst);
+		dst = skb_dst_pop(skb);
 		if (!dst) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMOUTERROR);
 			err = -EHOSTUNREACH;
-- 
1.5.6.5

