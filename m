From: David Miller <davem@davemloft.net>
Subject: [PATCH] inet: Fix BUG triggered by __rt{,6}_get_peer().
Date: Mon, 11 Jun 2012 15:57:22 -0700 (PDT)
Message-ID: <20120611.155722.872336629515682610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035Ab2FKW5Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 18:57:25 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id ED3BB58438E
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 15:57:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If no peer actually gets attached (either because create is zero or
the peer allocation fails) we'll trigger a BUG because we
unconditionally do an rt{,6}_peer_ptr() afterwards.

Fix this by guarding it with the proper check.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip6_route.h |    2 +-
 include/net/route.h     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index f88a85c..a2cda24 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -61,7 +61,7 @@ static inline struct inet_peer *__rt6_get_peer(struct rt6_info *rt, int create)
 		return rt6_peer_ptr(rt);
 
 	rt6_bind_peer(rt, create);
-	return rt6_peer_ptr(rt);
+	return (rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL);
 }
 
 static inline struct inet_peer *rt6_get_peer(struct rt6_info *rt)
diff --git a/include/net/route.h b/include/net/route.h
index cc693a5..2bfbc93 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -334,7 +334,7 @@ static inline struct inet_peer *__rt_get_peer(struct rtable *rt, __be32 daddr, i
 		return rt_peer_ptr(rt);
 
 	rt_bind_peer(rt, daddr, create);
-	return rt_peer_ptr(rt);
+	return (rt_has_peer(rt) ? rt_peer_ptr(rt) : NULL);
 }
 
 static inline struct inet_peer *rt_get_peer(struct rtable *rt, __be32 daddr)
-- 
1.7.10
