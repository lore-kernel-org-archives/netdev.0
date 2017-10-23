From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/7] ipv6: addrconf: factorize inet6_addr_hash() call
Date: Mon, 23 Oct 2017 16:17:46 -0700
Message-ID: <20171023231751.29530-3-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:55846 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751242AbdJWXSB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:01 -0400
Received: by mail-io0-f193.google.com with SMTP id p186so21886053ioe.12
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:00 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_add_addr_hash() can compute the hash value outside of
locked section and pass it to ipv6_chk_same_addr().

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9228030e34970c1d6380e95e8c193496448ea8ac..c1a5028f394c75d347fe703573548fd617b5c142 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -956,9 +956,8 @@ static u32 inet6_addr_hash(const struct in6_addr *addr)
 }
 
 static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
-			       struct net_device *dev)
+			       struct net_device *dev, unsigned int hash)
 {
-	unsigned int hash = inet6_addr_hash(addr);
 	struct inet6_ifaddr *ifp;
 
 	hlist_for_each_entry(ifp, &inet6_addr_lst[hash], addr_lst) {
@@ -974,23 +973,19 @@ static bool ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 
 static int ipv6_add_addr_hash(struct net_device *dev, struct inet6_ifaddr *ifa)
 {
-	unsigned int hash;
+	unsigned int hash = inet6_addr_hash(&ifa->addr);
 	int err = 0;
 
 	spin_lock(&addrconf_hash_lock);
 
 	/* Ignore adding duplicate addresses on an interface */
-	if (ipv6_chk_same_addr(dev_net(dev), &ifa->addr, dev)) {
+	if (ipv6_chk_same_addr(dev_net(dev), &ifa->addr, dev, hash)) {
 		ADBG("ipv6_add_addr: already assigned\n");
 		err = -EEXIST;
-		goto out;
+	} else {
+		hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
 	}
 
-	/* Add to big hash table */
-	hash = inet6_addr_hash(&ifa->addr);
-	hlist_add_head_rcu(&ifa->addr_lst, &inet6_addr_lst[hash]);
-
-out:
 	spin_unlock(&addrconf_hash_lock);
 
 	return err;
-- 
2.15.0.rc0.271.g36b669edcc-goog
