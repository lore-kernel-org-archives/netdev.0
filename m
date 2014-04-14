From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: [PATCH] net IPv6: Remove unnecessary argument of ndisc_send_ns and
 ndisc_send_na
Date: Mon, 14 Apr 2014 09:10:26 +0530
Message-ID: <534B58AA.80704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:60907 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750826AbaDNDke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2014 23:40:34 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so7685906pab.41
        for <netdev@vger.kernel.org>; Sun, 13 Apr 2014 20:40:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'neigh' argument of 'ndisc_send_ns' and 'ndisc_send_na' are not used in
these functions. So this could be removed.

And a minor change of 'optlen' assignment in those functions. the compound
addition and assignment operator is not needed as 'optlen' value is always
zero.

Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
---
I am not sure whether 'neigh' argument is intentional or planned for any
future use. If you find this is unnecessary, this patch could be considered.

And ndisc_send_na is used as a function pointer in ipv6_stub. This may affect anybody
using this structure. But with default configuration built, I didn't get any error or
warning. Kindly consider this scenario also. 
---
 include/net/addrconf.h |    3 +--
 include/net/ndisc.h    |    6 ++----
 net/ipv6/addrconf.c    |    2 +-
 net/ipv6/ndisc.c       |   19 ++++++++-----------
 net/ipv6/route.c       |    2 +-
 5 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 933a9f2..778a78f 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -157,8 +157,7 @@ struct ipv6_stub {
 	int (*ipv6_dst_lookup)(struct sock *sk, struct dst_entry **dst,
 				struct flowi6 *fl6);
 	void (*udpv6_encap_enable)(void);
-	void (*ndisc_send_na)(struct net_device *dev, struct neighbour *neigh,
-			      const struct in6_addr *daddr,
+	void (*ndisc_send_na)(struct net_device *dev, const struct in6_addr *daddr,
 			      const struct in6_addr *solicited_addr,
 			      bool router, bool solicited, bool override, bool inc_opt);
 	struct neigh_table *nd_tbl;
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 6bbda34..2e3e611 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -197,14 +197,12 @@ void ndisc_cleanup(void);
 
 int ndisc_rcv(struct sk_buff *skb);
 
-void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *solicit,
+void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr);
 
 void ndisc_send_rs(struct net_device *dev,
 		   const struct in6_addr *saddr, const struct in6_addr *daddr);
-void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *daddr,
+void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 		   const struct in6_addr *solicited_addr,
 		   bool router, bool solicited, bool override, bool inc_opt);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c7fa08..68d0a92 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3312,7 +3312,7 @@ static void addrconf_dad_work(struct work_struct *w)
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any);
+	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any);
 out:
 	in6_ifa_put(ifp);
 	rtnl_unlock();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 09a22f4..ec4faa7 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -465,8 +465,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
-void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *daddr,
+void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 		   const struct in6_addr *solicited_addr,
 		   bool router, bool solicited, bool override, bool inc_opt)
 {
@@ -532,7 +531,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &ifa->addr,
+		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &ifa->addr,
 			      /*router=*/ !!idev->cnf.forwarding,
 			      /*solicited=*/ false, /*override=*/ true,
 			      /*inc_opt=*/ true);
@@ -542,8 +541,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 	in6_dev_put(idev);
 }
 
-void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *solicit,
+void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr)
 {
 	struct sk_buff *skb;
@@ -562,7 +560,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	if (ipv6_addr_any(saddr))
 		inc_opt = false;
 	if (inc_opt)
-		optlen += ndisc_opt_addr_space(dev);
+		optlen = ndisc_opt_addr_space(dev);
 
 	skb = ndisc_alloc_skb(dev, sizeof(*msg) + optlen);
 	if (!skb)
@@ -664,12 +662,12 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
-		ndisc_send_ns(dev, neigh, target, target, saddr);
+		ndisc_send_ns(dev, target, target, saddr);
 	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr);
+		ndisc_send_ns(dev, target, &mcaddr, saddr);
 	}
 }
 
@@ -813,7 +811,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		is_router = idev->cnf.forwarding;
 
 	if (dad) {
-		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &msg->target,
+		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &msg->target,
 			      !!is_router, false, (ifp != NULL), true);
 		goto out;
 	}
@@ -834,8 +832,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 			     NEIGH_UPDATE_F_WEAK_OVERRIDE|
 			     NEIGH_UPDATE_F_OVERRIDE);
 	if (neigh || !dev->header_ops) {
-		ndisc_send_na(dev, neigh, saddr, &msg->target,
-			      !!is_router,
+		ndisc_send_na(dev, saddr, &msg->target, !!is_router,
 			      true, (ifp != NULL && inc), inc);
 		if (neigh)
 			neigh_release(neigh);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 5015c50..d0b4fc2 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -498,7 +498,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 		container_of(w, struct __rt6_probe_work, work);
 
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
-	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL);
+	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL);
 	dev_put(work->dev);
 	kfree(w);
 }
-- 
1.7.9.5
