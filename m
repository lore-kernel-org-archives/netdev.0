From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net] Revert "ipv6: ndisc: inherit metadata dst when creating ndisc requests"
Date: Fri, 27 Nov 2015 18:17:05 +0100
Message-ID: <1448644625-29345-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Benc <jbenc@redhat.com>, Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:44187 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754796AbbK0RXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 12:23:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit ab450605b35caa768ca33e86db9403229bf42be4.

In IPv6, we cannot inherit the dst of the original dst. ndisc packets
are IPv6 packets and may take another route than the original packet.

This patch breaks the following scenario: a packet comes from eth0 and
is forwarded through vxlan1. The encapsulated packet triggers an NS
which cannot be sent because of the wrong route.

CC: Jiri Benc <jbenc@redhat.com>
CC: Thomas Graf <tgraf@suug.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

I know that this is not the right fix, it's why I've put RFC ;-)
Should the right fix only do a copy of dst metadata in the new dst?
Feedback is welcomed.

 include/net/ndisc.h |  3 +--
 net/ipv6/addrconf.c |  2 +-
 net/ipv6/ndisc.c    | 10 +++-------
 net/ipv6/route.c    |  2 +-
 4 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index bf3937431030..2d8edaad29cb 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -181,8 +181,7 @@ void ndisc_cleanup(void);
 int ndisc_rcv(struct sk_buff *skb);
 
 void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr,
-		   struct sk_buff *oskb);
+		   const struct in6_addr *daddr, const struct in6_addr *saddr);
 
 void ndisc_send_rs(struct net_device *dev,
 		   const struct in6_addr *saddr, const struct in6_addr *daddr);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index d84742f003a9..61f26851655c 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3642,7 +3642,7 @@ static void addrconf_dad_work(struct work_struct *w)
 
 	/* send a neighbour solicitation for our addr */
 	addrconf_addr_solict_mult(&ifp->addr, &mcaddr);
-	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any, NULL);
+	ndisc_send_ns(ifp->idev->dev, &ifp->addr, &mcaddr, &in6addr_any);
 out:
 	in6_ifa_put(ifp);
 	rtnl_unlock();
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 3e0f855e1bea..d6161e1c48c8 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -556,8 +556,7 @@ static void ndisc_send_unsol_na(struct net_device *dev)
 }
 
 void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
-		   const struct in6_addr *daddr, const struct in6_addr *saddr,
-		   struct sk_buff *oskb)
+		   const struct in6_addr *daddr, const struct in6_addr *saddr)
 {
 	struct sk_buff *skb;
 	struct in6_addr addr_buf;
@@ -593,9 +592,6 @@ void ndisc_send_ns(struct net_device *dev, const struct in6_addr *solicit,
 		ndisc_fill_addr_option(skb, ND_OPT_SOURCE_LL_ADDR,
 				       dev->dev_addr);
 
-	if (!(dev->priv_flags & IFF_XMIT_DST_RELEASE) && oskb)
-		skb_dst_copy(skb, oskb);
-
 	ndisc_send_skb(skb, daddr, saddr);
 }
 
@@ -682,12 +678,12 @@ static void ndisc_solicit(struct neighbour *neigh, struct sk_buff *skb)
 				  "%s: trying to ucast probe in NUD_INVALID: %pI6\n",
 				  __func__, target);
 		}
-		ndisc_send_ns(dev, target, target, saddr, skb);
+		ndisc_send_ns(dev, target, target, saddr);
 	} else if ((probes -= NEIGH_VAR(neigh->parms, APP_PROBES)) < 0) {
 		neigh_app_ns(neigh);
 	} else {
 		addrconf_addr_solict_mult(target, &mcaddr);
-		ndisc_send_ns(dev, target, &mcaddr, saddr, skb);
+		ndisc_send_ns(dev, target, &mcaddr, saddr);
 	}
 }
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 6f01fe122abd..826e6aa44f8d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -523,7 +523,7 @@ static void rt6_probe_deferred(struct work_struct *w)
 		container_of(w, struct __rt6_probe_work, work);
 
 	addrconf_addr_solict_mult(&work->target, &mcaddr);
-	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL, NULL);
+	ndisc_send_ns(work->dev, &work->target, &mcaddr, NULL);
 	dev_put(work->dev);
 	kfree(work);
 }
-- 
2.4.2
