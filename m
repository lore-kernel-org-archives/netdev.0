From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 2/8] ipv6: remove ipv6_sk_ac_lock
Date: Thu, 11 Sep 2014 15:35:10 -0700
Message-ID: <1410474916-21873-3-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38573 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753246AbaIKWfk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:40 -0400
Received: by mail-pa0-f46.google.com with SMTP id kq14so7753159pab.33
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:40 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just move rtnl lock up, so that the anycast list can be protected
by rtnl lock now.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/anycast.c | 17 +++--------------
 1 file changed, 3 insertions(+), 14 deletions(-)

diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 3b0429b..d10f2e2 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -46,10 +46,6 @@
 
 static int ipv6_dev_ac_dec(struct net_device *dev, const struct in6_addr *addr);
 
-/* Big ac list lock for all the sockets */
-static DEFINE_SPINLOCK(ipv6_sk_ac_lock);
-
-
 /*
  *	socket join an anycast group
  */
@@ -128,10 +124,8 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 
 	err = ipv6_dev_ac_inc(dev, addr);
 	if (!err) {
-		spin_lock_bh(&ipv6_sk_ac_lock);
 		pac->acl_next = np->ipv6_ac_list;
 		np->ipv6_ac_list = pac;
-		spin_unlock_bh(&ipv6_sk_ac_lock);
 		pac = NULL;
 	}
 
@@ -152,7 +146,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	struct ipv6_ac_socklist *pac, *prev_pac;
 	struct net *net = sock_net(sk);
 
-	spin_lock_bh(&ipv6_sk_ac_lock);
+	rtnl_lock();
 	prev_pac = NULL;
 	for (pac = np->ipv6_ac_list; pac; pac = pac->acl_next) {
 		if ((ifindex == 0 || pac->acl_ifindex == ifindex) &&
@@ -161,7 +155,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 		prev_pac = pac;
 	}
 	if (!pac) {
-		spin_unlock_bh(&ipv6_sk_ac_lock);
+		rtnl_unlock();
 		return -ENOENT;
 	}
 	if (prev_pac)
@@ -169,9 +163,6 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex, const struct in6_addr *addr)
 	else
 		np->ipv6_ac_list = pac->acl_next;
 
-	spin_unlock_bh(&ipv6_sk_ac_lock);
-
-	rtnl_lock();
 	dev = __dev_get_by_index(net, pac->acl_ifindex);
 	if (dev)
 		ipv6_dev_ac_dec(dev, &pac->acl_addr);
@@ -192,13 +183,11 @@ void ipv6_sock_ac_close(struct sock *sk)
 	if (!np->ipv6_ac_list)
 		return;
 
-	spin_lock_bh(&ipv6_sk_ac_lock);
+	rtnl_lock();
 	pac = np->ipv6_ac_list;
 	np->ipv6_ac_list = NULL;
-	spin_unlock_bh(&ipv6_sk_ac_lock);
 
 	prev_index = 0;
-	rtnl_lock();
 	while (pac) {
 		struct ipv6_ac_socklist *next = pac->acl_next;
 
-- 
1.8.3.1
