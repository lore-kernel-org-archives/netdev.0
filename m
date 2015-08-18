From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 08/13] ipv6: ndisc: inherit metadata dst when creating ndisc requests
Date: Tue, 18 Aug 2015 22:33:17 +0200
Message-ID: <62f8bc6dbdac541a96e3c63a9ea4e4f3be5df09a.1439929916.git.jbenc@redhat.com>
References: <cover.1439929916.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42430 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752356AbbHRUdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 16:33:50 -0400
In-Reply-To: <cover.1439929916.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If output device wants to see the dst, inherit the dst of the original skb
in the ndisc request.

This is an IPv6 counterpart of commit 0accfc268f4d ("arp: Inherit metadata
dst when creating ARP requests").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/ndisc.h |  3 ++-
 net/ipv6/addrconf.c |  2 +-
 net/ipv6/ndisc.c    | 10 +++++++---
 net/ipv6/route.c    |  2 +-
 4 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index b3a7751251b4..aba5695fadb0 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -182,7 +182,8 @@ int ndisc_rcv(struct sk_buff *skb);
 
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr);
+		   const struct in6_addr *daddr, const struct in6_addr *saddr,
+		   struct sk_buff *oskb);
 
 void ndisc_send_rs(struct net_device *dev,
 		   const struct in6_addr *saddr, const struct in6_addr *daddr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 59242399b0b5..0f08d3b9e238 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3656,7 +3656,7 @@ static void addrconf_dad_work(struct work_struct *w)
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any);
+	ndisc_send_ns(ifp->idev->dev, NULL, &ifp->addr, &mcaddr, &in6addr_any, NULL);
 out:
 	in6_ifa_put(ifp);
 	rtnl_unlock();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3054611f88a..13d3c2beb93e 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -553,7 +553,8 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 
 void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr)
+		   const struct in6_addr *daddr, const struct in6_addr *saddr,
+		   struct sk_buff *oskb)
 {
 	struct sk_buff *skb;
 	struct in6_addr addr_buf;
@@ -589,6 +590,9 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
 				       dev->dev_addr);
 
+	if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE) && oskb)
+		skb_dst_copy(skb, oskb);
+
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
@@ -675,12 +679,12 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
-		ndisc_send_ns(dev, neigh, target, target, saddr);
+		ndisc_send_ns(dev, neigh, target, target, saddr, skb);
 	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr);
+		ndisc_send_ns(dev, NULL, target, &mcaddr, saddr, skb);
 	}
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 0947ad0b3de8..c4f3b9fcca9d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -538,7 +538,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 		container_of(w, struct __rt6_probe_work, work);
 
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
-	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL);
+	ndisc_send_ns(work->dev, NULL, &work->target, &mcaddr, NULL, NULL);
 	dev_put(work->dev);
 	kfree(work);
 }
-- 
1.8.3.1
