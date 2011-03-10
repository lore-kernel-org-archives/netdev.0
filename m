From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Optimize flow initialization in
 fib_validate_source().
Date: Wed, 09 Mar 2011 20:58:31 -0800 (PST)
Message-ID: <20110309.205831.189701125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40451
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751166Ab1CJE5x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 23:57:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 4185424C089
	for <netdev@vger.kernel.org>; Wed,  9 Mar 2011 20:58:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like in commit 44713b67db10c774f14280c129b0d5fd13c70cf2
("ipv4: Optimize flow initialization in output route lookup."
we can optimize the on-stack flow setup to only initialize
the members which are actually used.

Otherwise we bzero the entire structure, then initialize
explicitly the first half of it.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/fib_frontend.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 1d2233c..fe10bcd 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -193,19 +193,21 @@ int fib_validate_source(__be32 src, __be32 dst, u8 tos, int oif,
 			u32 *itag, u32 mark)
 {
 	struct in_device *in_dev;
-	struct flowi fl = {
-		.fl4_dst = src,
-		.fl4_src = dst,
-		.fl4_tos = tos,
-		.mark = mark,
-		.iif = oif
-	};
+	struct flowi fl;
 	struct fib_result res;
 	int no_addr, rpf, accept_local;
 	bool dev_match;
 	int ret;
 	struct net *net;
 
+	fl.oif = 0;
+	fl.iif = oif;
+	fl.mark = mark;
+	fl.fl4_dst = src;
+	fl.fl4_src = dst;
+	fl.fl4_tos = tos;
+	fl.fl4_scope = RT_SCOPE_UNIVERSE;
+
 	no_addr = rpf = accept_local = 0;
 	in_dev = __in_dev_get_rcu(dev);
 	if (in_dev) {
-- 
1.7.4.1

