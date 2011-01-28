From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] ipv4: If fib metrics are default, no need to grab ref
 to FIB info.
Date: Fri, 28 Jan 2011 14:35:12 -0800 (PST)
Message-ID: <20110128.143512.102553352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47169
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753631Ab1A1Weh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Jan 2011 17:34:37 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 0B73B24C089
	for <netdev@vger.kernel.org>; Fri, 28 Jan 2011 14:35:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The fib metric memory in this case is static in the kernel image,
so we don't need to reference count it since it's never going
to go away on us.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index dd57f48..b1e5d3a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1861,8 +1861,10 @@ static void rt_init_metrics(struct rtable *rt, struct fib_info *fi)
 {
 	if (!(rt->fl.flags & FLOWI_FLAG_PRECOW_METRICS)) {
 	no_cow:
-		rt->fi = fi;
-		atomic_inc(&fi->fib_clntref);
+		if (fi->fib_metrics != (u32 *) dst_default_metrics) {
+			rt->fi = fi;
+			atomic_inc(&fi->fib_clntref);
+		}
 		dst_init_metrics(&rt->dst, fi->fib_metrics, true);
 	} else {
 		struct inet_peer *peer;
-- 
1.7.3.4

