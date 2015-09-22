From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next] ipv6: remove unused neigh parameter from ndisc functions
Date: Tue, 22 Sep 2015 18:57:13 +0200
Message-ID: <90e3945ff85b61be6d2ddf579ba02c45a20456a7.1442941029.git.jbenc@redhat.com>
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43746 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758072AbbIVQ5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 12:57:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 12fd84f4383b1 ("ipv6: Remove unused neigh argument for
icmp6_dst_alloc() and its callers."), the neigh parameter of ndisc_send_na
and ndisc_send_ns is unused.

CC: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/usb/cdc_mbim.c |  2 +-
 include/net/addrconf.h     |  3 +--
 include/net/ndisc.h        |  6 ++----
 net/ipv6/addrconf.c        |  2 +-
 net/ipv6/ndisc.c           | 17 +++++++----------
 net/ipv6/route.c           |  2 +-
 6 files changed, 13 insertions(+), 19 deletions(-)

diff --git a/drivers/net/usb/cdc_mbim.c b/drivers/net/usb/cdc_mbim.c
index efc18e05af0a..bbde9884ab8a 100644
--- a/drivers/net/usb/cdc_mbim.c
+++ b/drivers/net/usb/cdc_mbim.c
@@ -342,7 +342,7 @@ static void do_neigh_solicit(struct usbnet *dev, u8 *buf, u16 tci)
 	in6_dev_put(in6_dev);
 
 	/* ipv6_stub != NULL if in6_dev_get returned an inet6_dev */
-	ipv6_stub->ndisc_send_na(netdev, NULL, &iph->saddr, &msg->target,
+	ipv6_stub->ndisc_send_na(netdev, &iph->saddr, &msg->target,
 				 is_router /* router */,
 				 true /* solicited */,
 				 false /* override */,
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index b5474b1fcd83..78003dfb8539 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -192,8 +192,7 @@ struct ipv6_stub {
 	int (*ipv6_dst_lookup)(struct net *net, struct sock *sk,
 			       struct dst_entry **dst, struct flowi6 *fl6);
 	void (*udpv6_encap_enable)(void);
-	void (*ndisc_send_na)(struct net_device *dev, struct neighbour *neigh,
-			      const struct in6_addr *daddr,
+	void (*ndisc_send_na)(struct net_device *dev, const struct in6_addr *daddr,
 			      const struct in6_addr *solicited_addr,
 			      bool router, bool solicited, bool override, bool inc_opt);
 	struct neigh_table *nd_tbl;
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index aba5695fadb0..bf3937431030 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -180,15 +180,13 @@ void ndisc_cleanup(void);
 
 int ndisc_rcv(struct sk_buff *skb);
 
-void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *solicit,
+void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr,
 		   struct sk_buff *oskb);
 
 void ndisc_send_rs(struct net_device *dev,
 		   const struct in6_addr *saddr, const struct in6_addr *daddr);
-void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *daddr,
+void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 		   const struct in6_addr *solicited_addr,
 		   bool router, bool solicited, bool override, bool inc_opt);
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 75d3dde32c69..759d28ad16b7 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3625,7 +3625,7 @@ static void addrconf_dad_work(struct work_struct *w)
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any, NULL);
+	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any, NULL);
 out:
 	in6_ifa_put(ifp);
 	rtnl_unlock();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index dde5a1e5875a..7089c305245c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -474,8 +474,7 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	rcu_read_unlock();
 }
 
-void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *daddr,
+void ndisc_send_na(struct net_device *dev, const struct in6_addr *daddr,
 		   const struct in6_addr *solicited_addr,
 		   bool router, bool solicited, bool override, bool inc_opt)
 {
@@ -541,7 +540,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 
 	read_lock_bh(&idev->lock);
 	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &ifa->addr,
+		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &ifa->addr,
 			      /*router=*/ !!idev->cnf.forwarding,
 			      /*solicited=*/ false, /*override=*/ true,
 			      /*inc_opt=*/ true);
@@ -551,8 +550,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 	in6_dev_put(idev);
 }
 
-void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
-		   const struct in6_addr *solicit,
+void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		   const struct in6_addr *daddr, const struct in6_addr *saddr,
 		   struct sk_buff *oskb)
 {
@@ -679,12 +677,12 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
-		ndisc_send_ns(dev, neigh, target, target, saddr, skb);
+		ndisc_send_ns(dev, target, target, saddr, skb);
 	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr, skb);
+		ndisc_send_ns(dev, target, &mcaddr, saddr, skb);
 	}
 }
 
@@ -828,7 +826,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		is_router = idev->cnf.forwarding;
 
 	if (dad) {
-		ndisc_send_na(dev, NULL, &in6addr_linklocal_allnodes, &msg->target,
+		ndisc_send_na(dev, &in6addr_linklocal_allnodes, &msg->target,
 			      !!is_router, false, (ifp != NULL), true);
 		goto out;
 	}
@@ -849,8 +847,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
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
index 53617d715188..c97e1764c65e 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -538,7 +538,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 		container_of(w, struct __rt6_probe_work, work);
 
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
-	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL, NULL);
+	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL, NULL);
 	dev_put(work->dev);
 	kfree(work);
 }
-- 
1.8.3.1
