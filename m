From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 3/3] net: ipv6: only invalidate previously tokenized addresses
Date: Tue,  9 Apr 2013 15:47:16 +0200
Message-ID: <1365515236-7154-4-git-send-email-dborkman@redhat.com>
References: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22184 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932799Ab3DINr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 09:47:26 -0400
In-Reply-To: <1365515236-7154-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of invalidating all IPv6 addresses with global scope
when one decides to use IPv6 tokens, we should only invalidate
previous tokens and leave the rest intact until they expire
eventually (or are intact forever). For doing this less greedy
approach, we're adding a bool at the end of inet6_ifaddr structure
instead, for two reasons: i) per-inet6_ifaddr flag space is
already used up, making it wider might not be a good idea,
since ii) also we do not necessarily need to export this
information into user space.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/if_inet6.h |    2 ++
 net/ipv6/addrconf.c    |    7 +++++--
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index f1063d6..100fb8c 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -71,6 +71,8 @@ struct inet6_ifaddr {
 	struct inet6_ifaddr	*ifpub;
 	int			regen_count;
 #endif
+	bool			tokenized;
+
 	struct rcu_head		rcu;
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 713ebe3..28b61e8 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -878,6 +878,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr, int pfxlen,
 	ifa->prefix_len = pfxlen;
 	ifa->flags = flags | IFA_F_TENTATIVE;
 	ifa->cstamp = ifa->tstamp = jiffies;
+	ifa->tokenized = false;
 
 	ifa->rt = rt;
 
@@ -2134,6 +2135,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 		struct inet6_ifaddr *ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
+		bool tokenized = false;
 
 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
@@ -2143,6 +2145,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 				memcpy(addr.s6_addr + 8,
 				       in6_dev->token.s6_addr + 8, 8);
 				read_unlock_bh(&in6_dev->lock);
+				tokenized = true;
 			} else if (ipv6_generate_eui64(addr.s6_addr + 8, dev) &&
 				   ipv6_inherit_eui64(addr.s6_addr + 8, in6_dev)) {
 				in6_dev_put(in6_dev);
@@ -2185,6 +2188,7 @@ ok:
 
 			update_lft = create = 1;
 			ifp->cstamp = jiffies;
+			ifp->tokenized = tokenized;
 			addrconf_dad_start(ifp);
 		}
 
@@ -4339,8 +4343,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev, struct in6_addr *token)
 	/* Well, that's kinda nasty ... */
 	list_for_each_entry(ifp, &idev->addr_list, if_list) {
 		spin_lock(&ifp->lock);
-		if (ipv6_addr_src_scope(&ifp->addr) ==
-		    IPV6_ADDR_SCOPE_GLOBAL) {
+		if (ifp->tokenized) {
 			ifp->valid_lft = 0;
 			ifp->prefered_lft = 0;
 		}
-- 
1.7.1
