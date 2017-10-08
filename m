From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 6/6] ipv6: avoid cache line dirtying in ipv6_dev_get_saddr()
Date: Sat,  7 Oct 2017 19:30:28 -0700
Message-ID: <20171008023028.32071-7-edumazet@google.com>
References: <20171008023028.32071-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:47733 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdJHCau (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 22:30:50 -0400
Received: by mail-pg0-f52.google.com with SMTP id r25so9243765pgn.4
        for <netdev@vger.kernel.org>; Sat, 07 Oct 2017 19:30:50 -0700 (PDT)
In-Reply-To: <20171008023028.32071-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By extending the rcu section a bit, we can avoid these
very expensive in6_ifa_put()/in6_ifa_hold() calls
done in __ipv6_dev_get_saddr() and ipv6_dev_get_saddr()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 20c3ca777529fc49ebf749ca6f7d8c2451258d55..cab3faad2bf1354c1241a11ac27178ea675aed55 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1608,11 +1608,6 @@ static int __ipv6_dev_get_saddr(struct net *net,
 				}
 				break;
 			} else if (minihiscore < miniscore) {
-				if (hiscore->ifa)
-					in6_ifa_put(hiscore->ifa);
-
-				in6_ifa_hold(score->ifa);
-
 				swap(hiscore, score);
 				hiscore_idx = 1 - hiscore_idx;
 
@@ -1660,6 +1655,7 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	int dst_type;
 	bool use_oif_addr = false;
 	int hiscore_idx = 0;
+	int ret = 0;
 
 	dst_type = __ipv6_addr_type(daddr);
 	dst.addr = daddr;
@@ -1735,15 +1731,14 @@ int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst_dev,
 	}
 
 out:
-	rcu_read_unlock();
-
 	hiscore = &scores[hiscore_idx];
 	if (!hiscore->ifa)
-		return -EADDRNOTAVAIL;
+		ret = -EADDRNOTAVAIL;
+	else
+		*saddr = hiscore->ifa->addr;
 
-	*saddr = hiscore->ifa->addr;
-	in6_ifa_put(hiscore->ifa);
-	return 0;
+	rcu_read_unlock();
+	return ret;
 }
 EXPORT_SYMBOL(ipv6_dev_get_saddr);
 
-- 
2.14.2.920.gcf0c67979c-goog
