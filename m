From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 2/2] inet: RCU changes in inetdev_by_index()
Date: Tue, 19 Oct 2010 12:39:26 +0200
Message-ID: <1287484766.2676.74.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37288 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758037Ab0JSKjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 06:39:31 -0400
Received: by mail-wy0-f174.google.com with SMTP id 28so2328789wyb.19
        for <netdev@vger.kernel.org>; Tue, 19 Oct 2010 03:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert inetdev_by_index() to not increment in_dev refcount.

Callers hold RCU or RTNL, and should not decrement in_dev refcount.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/devinet.c       |    7 ++++---
 net/ipv4/fib_semantics.c |   25 +++++++++++--------------
 net/ipv4/igmp.c          |    2 --
 net/ipv4/ip_gre.c        |    4 +---
 4 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index c2ff48f..dc94b03 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -403,6 +403,9 @@ static int inet_set_ifa(struct net_device *dev, struct in_ifaddr *ifa)
 	return inet_insert_ifa(ifa);
 }
 
+/* Caller must hold RCU or RTNL :
+ * We dont take a reference on found in_device
+ */
 struct in_device *inetdev_by_index(struct net *net, int ifindex)
 {
 	struct net_device *dev;
@@ -411,7 +414,7 @@ struct in_device *inetdev_by_index(struct net *net, int ifindex)
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(net, ifindex);
 	if (dev)
-		in_dev = in_dev_get(dev);
+		in_dev = rcu_dereference_rtnl(dev->ip_ptr);
 	rcu_read_unlock();
 	return in_dev;
 }
@@ -453,8 +456,6 @@ static int inet_rtm_deladdr(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg
 		goto errout;
 	}
 
-	__in_dev_put(in_dev);
-
 	for (ifap = &in_dev->ifa_list; (ifa = *ifap) != NULL;
 	     ifap = &ifa->ifa_next) {
 		if (tb[IFA_LOCAL] &&
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 0f80dfc..6734c9c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -590,32 +590,29 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
 		if (!dev)
 			goto out;
 		dev_hold(dev);
-		err = -ENETDOWN;
-		if (!(dev->flags & IFF_UP))
-			goto out;
-		err = 0;
-out:
-		rcu_read_unlock();
-		return err;
+		err = (dev->flags & IFF_UP) ? 0 : -ENETDOWN;
 	} else {
 		struct in_device *in_dev;
 
 		if (nh->nh_flags & (RTNH_F_PERVASIVE | RTNH_F_ONLINK))
 			return -EINVAL;
 
+		rcu_read_lock();
+		err = -ENODEV;
 		in_dev = inetdev_by_index(net, nh->nh_oif);
 		if (in_dev == NULL)
-			return -ENODEV;
-		if (!(in_dev->dev->flags & IFF_UP)) {
-			in_dev_put(in_dev);
-			return -ENETDOWN;
-		}
+			goto out;
+		err = -ENETDOWN;
+		if (!(in_dev->dev->flags & IFF_UP))
+			goto out;
 		nh->nh_dev = in_dev->dev;
 		dev_hold(nh->nh_dev);
 		nh->nh_scope = RT_SCOPE_HOST;
-		in_dev_put(in_dev);
+		err = 0;
 	}
-	return 0;
+out:
+	rcu_read_unlock();
+	return err;
 }
 
 static inline unsigned int fib_laddr_hashfn(__be32 val)
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index a525328..c8877c6 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1429,8 +1429,6 @@ static struct in_device *ip_mc_find_dev(struct net *net, struct ip_mreqn *imr)
 
 	if (imr->imr_ifindex) {
 		idev = inetdev_by_index(net, imr->imr_ifindex);
-		if (idev)
-			__in_dev_put(idev);
 		return idev;
 	}
 	if (imr->imr_address.s_addr) {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 9d421f4..d0ffcbe 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1245,10 +1245,8 @@ static int ipgre_close(struct net_device *dev)
 	if (ipv4_is_multicast(t->parms.iph.daddr) && t->mlink) {
 		struct in_device *in_dev;
 		in_dev = inetdev_by_index(dev_net(dev), t->mlink);
-		if (in_dev) {
+		if (in_dev)
 			ip_mc_dec_group(in_dev, t->parms.iph.daddr);
-			in_dev_put(in_dev);
-		}
 	}
 	return 0;
 }


