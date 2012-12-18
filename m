From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 05/17] ndisc: Rename and break up __ndisc_send().
Date: Tue, 18 Dec 2012 19:54:10 +0900
Message-ID: <50D04B52.3000507@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56610 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754349Ab2LRKyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:54:12 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename (old) __ndisc_send() to ndisc_send() and create new
__ndisc_send() for more trivial work without dst_entry allocation.
Use new __ndisc_send() for redirect.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   81 ++++++++++++++++++++++--------------------------------
 1 file changed, 33 insertions(+), 48 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a4f3a9..a293676 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -430,28 +430,13 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	return skb;
 }
 
-static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
-			   struct neighbour *neigh,
-			   const struct in6_addr *daddr,
-			   const struct in6_addr *saddr,
-			   struct icmp6hdr *icmp6h)
+static void __ndisc_send(struct sk_buff *skb, struct dst_entry *dst)
 {
-	struct flowi6 fl6;
-	struct dst_entry *dst;
-	struct net *net = dev_net(dev);
-	struct sock *sk = net->ipv6.ndisc_sk;
+	struct net *net = dev_net(dst->dev);
 	struct inet6_dev *idev;
+	struct icmp6hdr *icmp6h = icmp6_hdr(skb);
+	u8 type = icmp6h->icmp6_type;
 	int err;
-	u8 type;
-
-	type = icmp6h->icmp6_type;
-
-	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
-	dst = icmp6_dst_alloc(dev, neigh, &fl6);
-	if (IS_ERR(dst)) {
-		kfree_skb(skb);
-		return;
-	}
 
 	skb_dst_set(skb, dst);
 
@@ -472,20 +457,32 @@ static void ndisc_send_skb(struct sk_buff *skb, struct net_device *dev,
 /*
  *	Send a Neighbour Discover packet
  */
-static void __ndisc_send(struct net_device *dev,
-			 struct neighbour *neigh,
-			 const struct in6_addr *daddr,
-			 const struct in6_addr *saddr,
-			 struct icmp6hdr *icmp6h, const struct in6_addr *target,
-			 int llinfo)
+static void ndisc_send(struct net_device *dev,
+		       struct neighbour *neigh,
+		       const struct in6_addr *daddr,
+		       const struct in6_addr *saddr,
+		       struct icmp6hdr *icmp6h, const struct in6_addr *target,
+		       int llinfo)
 {
+	struct flowi6 fl6;
+	struct dst_entry *dst;
+	struct net *net = dev_net(dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
+	u8 type = icmp6h->icmp6_type;
 
 	skb = ndisc_build_skb(dev, daddr, saddr, icmp6h, target, llinfo);
 	if (!skb)
 		return;
 
-	ndisc_send_skb(skb, dev, neigh, daddr, saddr, icmp6h);
+	icmpv6_flow_init(sk, &fl6, type, saddr, daddr, dev->ifindex);
+	dst = icmp6_dst_alloc(dev, neigh, &fl6);
+	if (IS_ERR(dst)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	__ndisc_send(skb, dst);
 }
 
 static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
@@ -520,9 +517,9 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	icmp6h.icmp6_solicited = solicited;
 	icmp6h.icmp6_override = override;
 
-	__ndisc_send(dev, neigh, daddr, src_addr,
-		     &icmp6h, solicited_addr,
-		     inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
+	ndisc_send(dev, neigh, daddr, src_addr,
+		   &icmp6h, solicited_addr,
+		   inc_opt ? ND_OPT_TARGET_LL_ADDR : 0);
 }
 
 static void ndisc_send_unsol_na(struct net_device *dev)
@@ -562,9 +559,9 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 		saddr = &addr_buf;
 	}
 
-	__ndisc_send(dev, neigh, daddr, saddr,
-		     &icmp6h, solicit,
-		     !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
+	ndisc_send(dev, neigh, daddr, saddr,
+		   &icmp6h, solicit,
+		   !ipv6_addr_any(saddr) ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
 void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
@@ -597,9 +594,9 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	__ndisc_send(dev, NULL, daddr, saddr,
-		     &icmp6h, NULL,
-		     send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
+	ndisc_send(dev, NULL, daddr, saddr,
+		   &icmp6h, NULL,
+		   send_sllao ? ND_OPT_SOURCE_LL_ADDR : 0);
 }
 
 
@@ -1357,7 +1354,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct in6_addr saddr_buf;
 	struct rt6_info *rt;
 	struct dst_entry *dst;
-	struct inet6_dev *idev;
 	struct flowi6 fl6;
 	u8 *opt;
 	int hlen, tlen;
@@ -1481,18 +1477,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 						 len, IPPROTO_ICMPV6,
 						 csum_partial(msg, len, 0));
 
-	skb_dst_set(buff, dst);
-	rcu_read_lock();
-	idev = __in6_dev_get(dst->dev);
-	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, buff, NULL, dst->dev,
-		      dst_output);
-	if (!err) {
-		ICMP6MSGOUT_INC_STATS(net, idev, NDISC_REDIRECT);
-		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
-	}
-
-	rcu_read_unlock();
+	__ndisc_send(buff, dst);
 	return;
 
 release:
-- 
1.7.9.5
