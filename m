From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: RCU changes in ipv6_get_mtu() and
 ip6_dst_hoplimit()
Date: Mon, 14 Jun 2010 16:46:20 +0200
Message-ID: <1276526780.2478.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:38247 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab0FNOqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 10:46:25 -0400
Received: by wwb18 with SMTP id 18so3903708wwb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 07:46:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU to avoid atomic ops on idev refcnt in ipv6_get_mtu()
and ip6_dst_hoplimit() 

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/route.c |   19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index f770285..8f2d040 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1084,11 +1084,11 @@ static int ipv6_get_mtu(struct net_device *dev)
 	int mtu = IPV6_MIN_MTU;
 	struct inet6_dev *idev;
 
-	idev = in6_dev_get(dev);
-	if (idev) {
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
+	if (idev)
 		mtu = idev->cnf.mtu6;
-		in6_dev_put(idev);
-	}
+	rcu_read_unlock();
 	return mtu;
 }
 
@@ -1097,12 +1097,15 @@ int ip6_dst_hoplimit(struct dst_entry *dst)
 	int hoplimit = dst_metric(dst, RTAX_HOPLIMIT);
 	if (hoplimit < 0) {
 		struct net_device *dev = dst->dev;
-		struct inet6_dev *idev = in6_dev_get(dev);
-		if (idev) {
+		struct inet6_dev *idev;
+
+		rcu_read_lock();
+		idev = __in6_dev_get(dev);
+		if (idev)
 			hoplimit = idev->cnf.hop_limit;
-			in6_dev_put(idev);
-		} else
+		else
 			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
+		rcu_read_unlock();
 	}
 	return hoplimit;
 }


