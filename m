From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/7] ipv6: addrconf: do not block BH in ipv6_get_ifaddr()
Date: Mon, 23 Oct 2017 16:17:49 -0700
Message-ID: <20171023231751.29530-6-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:48006 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751383AbdJWXSH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:07 -0400
Received: by mail-io0-f196.google.com with SMTP id h70so21900332ioi.4
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:07 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu_read_lock() is enough here, no need to block BH.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a6cf37b7e34c461e204153078be92c3e297b3ec2..6c1e7ffb62ff2333d63b3c7639d99649d43b32fc 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1922,8 +1922,8 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 	unsigned int hash = inet6_addr_hash(net, addr);
 	struct inet6_ifaddr *ifp, *result = NULL;
 
-	rcu_read_lock_bh();
-	hlist_for_each_entry_rcu_bh(ifp, &inet6_addr_lst[hash], addr_lst) {
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
 		if (ipv6_addr_equal(&ifp->addr, addr)) {
@@ -1935,7 +1935,7 @@ struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, const struct in6_addr *add
 			}
 		}
 	}
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 
 	return result;
 }
-- 
2.15.0.rc0.271.g36b669edcc-goog
