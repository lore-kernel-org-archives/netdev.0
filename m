From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 4/7] ipv6: addrconf: do not block BH in ipv6_chk_addr_and_flags()
Date: Mon, 23 Oct 2017 16:17:48 -0700
Message-ID: <20171023231751.29530-5-edumazet@google.com>
References: <20171023231751.29530-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:53473 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751344AbdJWXSF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:18:05 -0400
Received: by mail-io0-f195.google.com with SMTP id 189so21925089iow.10
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:18:05 -0700 (PDT)
In-Reply-To: <20171023231751.29530-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rcu_read_lock() is enough here, as inet6_ifa_finish_destroy()
uses kfree_rcu()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/addrconf.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d70d98122053652b4f4420786de8788c6c9385ff..a6cf37b7e34c461e204153078be92c3e297b3ec2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1844,7 +1844,7 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 	struct inet6_ifaddr *ifp;
 	u32 ifp_flags;
 
-	rcu_read_lock_bh();
+	rcu_read_lock();
 	hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
 		if (!net_eq(dev_net(ifp->idev->dev), net))
 			continue;
@@ -1858,12 +1858,12 @@ int ipv6_chk_addr_and_flags(struct net *net, const struct in6_addr *addr,
 		    !(ifp_flags&banned_flags) &&
 		    (!dev || ifp->idev->dev == dev ||
 		     !(ifp->scope&(IFA_LINK|IFA_HOST) || strict))) {
-			rcu_read_unlock_bh();
+			rcu_read_unlock();
 			return 1;
 		}
 	}
 
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
 	return 0;
 }
 EXPORT_SYMBOL(ipv6_chk_addr_and_flags);
-- 
2.15.0.rc0.271.g36b669edcc-goog
