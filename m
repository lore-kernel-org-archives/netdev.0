From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next] ipv6: invert join/leave anycast  rtnl/socket locking order
Date: Fri, 20 Mar 2015 10:20:32 -0300
Message-ID: <1426857632-17879-1-git-send-email-marcelo.leitner@gmail.com>
Cc: hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305AbbCTNUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2015 09:20:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
missed to update two setsockopt options, IPV6_JOIN_ANYCAST and
IPV6_LEAVE_ANYCAST, causing a lock inverstion regarding the updated ones.

As ipv6_sock_ac_join and ipv6_sock_ac_leave are only called from
do_ipv6_setsockopt, we are good to just move the rtnl lock upper.

Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
Reported-by: Ying Huang <ying.huang@intel.com>
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/ipv6/anycast.c       | 9 ++++-----
 net/ipv6/ipv6_sockglue.c | 2 ++
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index baf2742d1ec47ee1b9cf62d087afb8b7d7195921..a1db95e863ffdd1aa1cb5112da11ccdef9e945fd 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -60,6 +60,8 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	int	ishost = !net->ipv6.devconf_all->forwarding;
 	int	err = 0;
 
+	ASSERT_RTNL();
+
 	if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 		return -EPERM;
 	if (ipv6_addr_is_multicast(addr))
@@ -73,7 +75,6 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	pac->acl_next = NULL;
 	pac->acl_addr = *addr;
 
-	rtnl_lock();
 	if (ifindex == 0) {
 		struct rt6_info *rt;
 
@@ -130,7 +131,6 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	}
 
 error:
-	rtnl_unlock();
 	if (pac)
 		sock_kfree_s(sk, pac, sizeof(*pac));
 	return err;
@@ -146,7 +146,8 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct ipv6_ac_socklist *pac, *prev_pac;
 	struct net *net = sock_net(sk);
 
-	rtnl_lock();
+	ASSERT_RTNL();
+
 	prev_pac = NULL;
 	for (pac = np->ipv6_ac_list; pac; pac = pac->acl_next) {
 		if ((ifindex == 0 || pac->acl_ifindex == ifindex) &&
@@ -155,7 +156,6 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		prev_pac = pac;
 	}
 	if (!pac) {
-		rtnl_unlock();
 		return -ENOENT;
 	}
 	if (prev_pac)
@@ -166,7 +166,6 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	dev = __dev_get_by_index(net, pac->acl_ifindex);
 	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
-	rtnl_unlock();
 
 	sock_kfree_s(sk, pac, sizeof(*pac));
 	return 0;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index cc5883791bac1b32e4bbf9c36ee30f4d078b7dde..9b2cb144423004a02d61373338f3216b6a955043 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -122,6 +122,8 @@ static bool setsockopt_needs_rtnl(int optname)
 	switch (optname) {
 	case IPV6_ADD_MEMBERSHIP:
 	case IPV6_DROP_MEMBERSHIP:
+	case IPV6_JOIN_ANYCAST:
+	case IPV6_LEAVE_ANYCAST:
 	case MCAST_JOIN_GROUP:
 	case MCAST_LEAVE_GROUP:
 	case MCAST_JOIN_SOURCE_GROUP:
-- 
2.1.0
