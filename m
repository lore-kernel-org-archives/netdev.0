From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next v2 3/8] ipv6: clean up ipv6_dev_ac_inc()
Date: Thu, 11 Sep 2014 15:35:11 -0700
Message-ID: <1410474916-21873-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:62562 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753347AbaIKWfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 18:35:42 -0400
Received: by mail-pd0-f175.google.com with SMTP id z10so14234382pdj.20
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 15:35:41 -0700 (PDT)
In-Reply-To: <1410474916-21873-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it accept inet6_dev, and rename it to __ipv6_dev_ac_inc()
to reflect this change.

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/addrconf.h |  2 +-
 net/ipv6/addrconf.c    |  2 +-
 net/ipv6/anycast.c     | 13 ++++---------
 3 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f679877..9b1d42e 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -202,7 +202,7 @@ int ipv6_sock_ac_drop(struct sock *sk, int ifindex,
 		      const struct in6_addr *addr);
 void ipv6_sock_ac_close(struct sock *sk);
 
-int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
+int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr);
 int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
 bool ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 			 const struct in6_addr *addr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index ad4598f..6b6a373 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1725,7 +1725,7 @@ static void addrconf_join_anycast(struct inet6_ifaddr *ifp)
 	ipv6_addr_prefix(&addr, &ifp->addr, ifp->prefix_len);
 	if (ipv6_addr_any(&addr))
 		return;
-	ipv6_dev_ac_inc(ifp->idev->dev, &addr);
+	__ipv6_dev_ac_inc(ifp->idev, &addr);
 }
 
 /* caller must hold RTNL */
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index d10f2e2..66c1932 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -122,7 +122,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, const struct in6_addr *addr)
 			goto error;
 	}
 
-	err = ipv6_dev_ac_inc(dev, addr);
+	err = __ipv6_dev_ac_inc(idev, addr);
 	if (!err) {
 		pac->acl_next = np->ipv6_ac_list;
 		np->ipv6_ac_list = pac;
@@ -215,20 +215,15 @@ static void aca_put(struct ifacaddr6 *ac)
 /*
  *	device anycast group inc (add if not found)
  */
-int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
+int __ipv6_dev_ac_inc(struct inet6_dev *idev, const struct in6_addr *addr)
 {
 	struct ifacaddr6 *aca;
-	struct inet6_dev *idev;
 	struct rt6_info *rt;
 	int err;
 
 	ASSERT_RTNL();
 
-	idev = in6_dev_get(dev);
-
-	if (idev == NULL)
-		return -EINVAL;
-
+	in6_dev_hold(idev);
 	write_lock_bh(&idev->lock);
 	if (idev->dead) {
 		err = -ENODEV;
@@ -276,7 +271,7 @@ int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr)
 
 	ip6_ins_rt(rt);
 
-	addrconf_join_solict(dev, &aca->aca_addr);
+	addrconf_join_solict(idev->dev, &aca->aca_addr);
 
 	aca_put(aca);
 	return 0;
-- 
1.8.3.1
