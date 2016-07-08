From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: do not abuse GFP_ATOMIC in
 inet6_netconf_notify_devconf()
Date: Fri, 08 Jul 2016 05:46:04 +0200
Message-ID: <1467949564.1273.61.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1467764916-4983-1-git-send-email-masashi.honma@gmail.com>
	 <1467764916-4983-6-git-send-email-masashi.honma@gmail.com>
	 <1467946591.1273.45.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Masashi Honma <masashi.honma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33818 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbcGHDqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 23:46:13 -0400
Received: by mail-wm0-f66.google.com with SMTP id w75so1127947wmd.1
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2016 20:46:13 -0700 (PDT)
In-Reply-To: <1467947904.1273.56.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

All inet6_netconf_notify_devconf() callers are in process context,
so we can use GFP_KERNEL allocations if we take care of not holding
a rwlock while not needed in ip6mr (we hold RTNL there)


Fixes: d67b8c616b48 ("netconf: advertise mc_forwarding status")
Fixes: f3a1bfb11ccb ("rtnl/ipv6: use netconf msg to advertise forwarding status")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/addrconf.c |    4 ++--
 net/ipv6/ip6mr.c    |   13 +++++++------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index a1f6b7b315317f811cafbf386cf21dfc510c2010..24f1b0898e4013a45ce21cc73090607f9578131a 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -547,7 +547,7 @@ void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 	struct sk_buff *skb;
 	int err = -ENOBUFS;
 
-	skb = nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_ATOMIC);
+	skb = nlmsg_new(inet6_netconf_msgsize_devconf(type), GFP_KERNEL);
 	if (!skb)
 		goto errout;
 
@@ -559,7 +559,7 @@ void inet6_netconf_notify_devconf(struct net *net, int type, int ifindex,
 		kfree_skb(skb);
 		goto errout;
 	}
-	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_NETCONF, NULL, GFP_ATOMIC);
+	rtnl_notify(skb, net, 0, RTNLGRP_IPV6_NETCONF, NULL, GFP_KERNEL);
 	return;
 errout:
 	rtnl_set_sk_err(net, RTNLGRP_IPV6_NETCONF, err);
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 487ef3bc7bbcde7f3509b76b3a68aee9d2ab7e8b..c7ca0f5d1a3b7114abbf87db884ecb9c0fcfa8c6 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1592,14 +1592,15 @@ static int ip6mr_sk_init(struct mr6_table *mrt, struct sock *sk)
 	if (likely(mrt->mroute6_sk == NULL)) {
 		mrt->mroute6_sk = sk;
 		net->ipv6.devconf_all->mc_forwarding++;
-		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
-					     NETCONFA_IFINDEX_ALL,
-					     net->ipv6.devconf_all);
-	}
-	else
+	} else {
 		err = -EADDRINUSE;
+	}
 	write_unlock_bh(&mrt_lock);
 
+	if (!err)
+		inet6_netconf_notify_devconf(net, NETCONFA_MC_FORWARDING,
+					     NETCONFA_IFINDEX_ALL,
+					     net->ipv6.devconf_all);
 	rtnl_unlock();
 
 	return err;
@@ -1617,11 +1618,11 @@ int ip6mr_sk_done(struct sock *sk)
 			write_lock_bh(&mrt_lock);
 			mrt->mroute6_sk = NULL;
 			net->ipv6.devconf_all->mc_forwarding--;
+			write_unlock_bh(&mrt_lock);
 			inet6_netconf_notify_devconf(net,
 						     NETCONFA_MC_FORWARDING,
 						     NETCONFA_IFINDEX_ALL,
 						     net->ipv6.devconf_all);
-			write_unlock_bh(&mrt_lock);
 
 			mroute_clean_tables(mrt, false);
 			err = 0;
