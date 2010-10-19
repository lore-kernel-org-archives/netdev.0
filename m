From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: avoid a dev refcount in ip_mc_find_dev()
Date: Tue, 19 Oct 2010 12:39:18 +0200
Message-ID: <1287484758.2676.73.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37288 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030Ab0JSKjY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:39:24 -0400
Received: by wyb28 with SMTP id 28so2328789wyb.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 03:39:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We hold RTNL in ip_mc_find_dev(), no need to touch device refcount.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_frontend.c |    2 +-
 net/ipv4/igmp.c         |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 3df057e..36e27c2 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -153,7 +153,7 @@ static void fib_flush(struct net *net)
  * @addr: the source address
  * @devref: if true, take a reference on the found device
  *
- * If a caller uses devref=false, it should be protected by RCU
+ * If a caller uses devref=false, it should be protected by RCU, or RTNL
  */
 struct net_device *__ip_dev_find(struct net *net, __be32 addr, bool devref)
 {
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 25f3396..a525328 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1418,6 +1418,7 @@ void ip_mc_destroy_dev(struct in_device *in_dev)
 	write_unlock_bh(&in_dev->mc_list_lock);
 }
 
+/* RTNL is locked */
 static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 {
 	struct flowi fl = { .nl_u = { .ip4_u =
@@ -1433,10 +1434,9 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
-		dev = ip_dev_find(net, imr->imr_address.s_addr);
+		dev = __ip_dev_find(net, imr->imr_address.s_addr, false);
 		if (!dev)
 			return NULL;
-		dev_put(dev);
 	}
 
 	if (!dev && !ip_route_output_key(net, &rt, &fl)) {


