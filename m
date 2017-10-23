From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/7] ipv6: addrconf: move ipv6_chk_same_addr() to avoid forward declaration
Date: Mon, 23 Oct 2017 16:17:45 -0700
Message-ID: <20171023231751.29530-2-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:51677 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751113AbdJWXR6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:17:58 -0400
Received: by mail-it0-f65.google.com with SMTP id o135so7929193itb.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:17:58 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_chk_same_addr() is only used by ipv6_add_addr_hash(),
so moving it avoids a forward declaration.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 35 +++++++++++++++++------------------
 1 file changed, 17 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 93f9c0a619119f0520363206fbdc1aae49fbb1e6..9228030e34970c1d6380e95e8c193496448ea8ac 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -192,8 +192,6 @@ static void ipv6_ifa_notify(int event, struct inet6_ifaddr *ifa);
 
 static void inet6_prefix_notify(int event, struct inet6_dev *idev,
 				struct prefix_info *pinfo);
-static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
-			       struct net_device *dev);
 
 static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
@@ -957,6 +955,23 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 	return hash_32(ipv6_addr_hash(addr), IN6_ADDR_HSIZE_SHIFT);
 }
 
+static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
+			       struct net_device *dev)
+{
+	unsigned int hash = inet6_addr_hash(addr);
+	struct inet6_ifaddr *ifp;
+
+	hlist_for_each_entry(ifp, &inet6_addr_lst[hash], addr_lst) {
+		if (!net_eq(dev_net(ifp->idev->dev), net))
+			continue;
+		if (ipv6_addr_equal(&ifp->addr, addr)) {
+			if (!dev || ifp->idev->dev == dev)
+				return true;
+		}
+	}
+	return false;
+}
+
 static int ipv6_add_addr_hash(struct net_device *dev, struct inet6_ifaddr *ifa)
 {
 	unsigned int hash;
@@ -1856,22 +1871,6 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 }
 EXPORT_SYMBOL(ipv6_chk_addr_and_flags);
 
-static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
-			       struct net_device *dev)
-{
-	unsigned int hash = inet6_addr_hash(addr);
-	struct inet6_ifaddr *ifp;
-
-	hlist_for_each_entry(ifp, &inet6_addr_lst[hash], addr_lst) {
-		if (!net_eq(dev_net(ifp->idev->dev), net))
-			continue;
-		if (ipv6_addr_equal(&ifp->addr, addr)) {
-			if (!dev || ifp->idev->dev == dev)
-				return true;
-		}
-	}
-	return false;
-}
 
 /* Compares an address/prefix_len with addresses on device @dev.
  * If one is found it returns true.
-- 
2.15.0.rc0.271.g36b669edcc-goog
