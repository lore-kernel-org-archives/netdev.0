From: Tom Goff <thomas.goff@boeing.com>
Subject: [PATCH] IPv6 multicast routing
Date: Tue, 20 Jan 2009 12:02:48 -0800
Message-ID: <20090120200248.GA13928@boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fred Templin <fred.l.templin@boeing.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:63856 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752767AbZATUfV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 15:35:21 -0500
Received: from blv-av-01.boeing.com (blv-av-01.boeing.com [130.247.48.231])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id n0KK2oow011551
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 14:02:50 -0600 (CST)
Received: from blv-av-01.boeing.com (localhost [127.0.0.1])
	by blv-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id n0KK2n4r018419
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 12:02:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses the IPv6 multicast routing issues described
below.  It was tested with XORP 1.4/1.5 as the IPv6 PIM-SM routing
daemon against FreeBSD peers.

net/ipv6/ip6_input.c:

  - Don't try to forward link-local multicast packets.

  - Don't reset skb2->dev before calling ip6_mr_input() so packets can
    be identified as coming from the PIM register vif properly.

net/ipv6/ip6mr.c:

  - Fix incoming PIM register messages processing:

    * The IPv6 pseudo-header should be included when checksumming PIM
      messages (RFC 4601 section 4.9; RFC 3973 section 4.7.1).

    * Packets decapsulated from PIM register messages should have
      skb->protocol ETH_P_IPV6.

  - Enable/disable IPv6 multicast forwarding on the corresponding
    interface when a routing daemon adds/removes a multicast virtual
    interface.

  - Remove incorrect skb_pull() to fix userspace signaling.

  - Enable/disable global IPv6 multicast forwarding when an IPv6
    multicast routing socket is opened/closed.

net/ipv6/route.c:

  - Don't use strict routing logic for packets decapsulated from PIM
    register messages (similar to disabling rp_filter for the IPv4
    case).

Signed-off-by: Thomas Goff <thomas.goff@boeing.com>
Reviewed-by: Fred Templin <fred.l.templin@boeing.com>

---
 net/ipv6/ip6_input.c |    2 +-
 net/ipv6/ip6mr.c     |   23 ++++++++++++++++++-----
 net/ipv6/route.c     |    2 +-
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 936f489..f171e8d 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -255,6 +255,7 @@ int ip6_mc_input(struct sk_buff *skb)
 	 *      IPv6 multicast router mode is now supported ;)
 	 */
 	if (dev_net(skb->dev)->ipv6.devconf_all->mc_forwarding &&
+	    !(ipv6_addr_type(&hdr->daddr) & IPV6_ADDR_LINKLOCAL) &&
 	    likely(!(IP6CB(skb)->flags & IP6SKB_FORWARDED))) {
 		/*
 		 * Okay, we try to forward - split and duplicate
@@ -316,7 +317,6 @@ int ip6_mc_input(struct sk_buff *skb)
 		}

 		if (skb2) {
-			skb2->dev = skb2->dst->dev;
 			ip6_mr_input(skb2);
 		}
 	}
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 3c51b2d..d19a84b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -365,7 +365,9 @@ static int pim6_rcv(struct sk_buff *skb)
 	pim = (struct pimreghdr *)skb_transport_header(skb);
 	if (pim->type != ((PIM_VERSION << 4) | PIM_REGISTER) ||
 	    (pim->flags & PIM_NULL_REGISTER) ||
-	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
+	    (csum_ipv6_magic(&ipv6_hdr(skb)->saddr, &ipv6_hdr(skb)->daddr,
+			     sizeof(*pim), IPPROTO_PIM,
+			     csum_partial((void *)pim, sizeof(*pim), 0)) &&
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;

@@ -392,7 +394,7 @@ static int pim6_rcv(struct sk_buff *skb)
 	skb_pull(skb, (u8 *)encap - skb->data);
 	skb_reset_network_header(skb);
 	skb->dev = reg_dev;
-	skb->protocol = htons(ETH_P_IP);
+	skb->protocol = htons(ETH_P_IPV6);
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 	dst_release(skb->dst);
@@ -481,6 +483,7 @@ static int mif6_delete(struct net *net, int vifi)
 {
 	struct mif_device *v;
 	struct net_device *dev;
+	struct inet6_dev *in6_dev;
 	if (vifi < 0 || vifi >= net->ipv6.maxvif)
 		return -EADDRNOTAVAIL;

@@ -513,6 +516,10 @@ static int mif6_delete(struct net *net, int vifi)

 	dev_set_allmulti(dev, -1);

+	in6_dev = __in6_dev_get(dev);
+	if (in6_dev)
+		in6_dev->cnf.mc_forwarding--;
+
 	if (v->flags & MIFF_REGISTER)
 		unregister_netdevice(dev);

@@ -622,6 +629,7 @@ static int mif6_add(struct net *net, struct mif6ctl *vifc, int mrtsock)
 	int vifi = vifc->mif6c_mifi;
 	struct mif_device *v = &net->ipv6.vif6_table[vifi];
 	struct net_device *dev;
+	struct inet6_dev *in6_dev;
 	int err;

 	/* Is vif busy ? */
@@ -662,6 +670,10 @@ static int mif6_add(struct net *net, struct mif6ctl *vifc, int mrtsock)
 		return -EINVAL;
 	}

+	in6_dev = __in6_dev_get(dev);
+	if (in6_dev)
+		in6_dev->cnf.mc_forwarding++;
+
 	/*
 	 *	Fill in the VIF structures
 	 */
@@ -838,8 +850,6 @@ static int ip6mr_cache_report(struct net *net, struct sk_buff *pkt, mifi_t mifi,

 	skb->dst = dst_clone(pkt->dst);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
-
-	skb_pull(skb, sizeof(struct ipv6hdr));
 	}

 	if (net->ipv6.mroute6_sk == NULL) {
@@ -1222,8 +1232,10 @@ static int ip6mr_sk_init(struct sock *sk)

 	rtnl_lock();
 	write_lock_bh(&mrt_lock);
-	if (likely(net->ipv6.mroute6_sk == NULL))
+	if (likely(net->ipv6.mroute6_sk == NULL)) {
 		net->ipv6.mroute6_sk = sk;
+		net->ipv6.devconf_all->mc_forwarding++;
+	}
 	else
 		err = -EADDRINUSE;
 	write_unlock_bh(&mrt_lock);
@@ -1242,6 +1254,7 @@ int ip6mr_sk_done(struct sock *sk)
 	if (sk == net->ipv6.mroute6_sk) {
 		write_lock_bh(&mrt_lock);
 		net->ipv6.mroute6_sk = NULL;
+		net->ipv6.devconf_all->mc_forwarding--;
 		write_unlock_bh(&mrt_lock);

 		mroute_clean_tables(net);
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 76f06b9..f83275f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -794,7 +794,7 @@ void ip6_route_input(struct sk_buff *skb)
 		.proto = iph->nexthdr,
 	};

-	if (rt6_need_strict(&iph->daddr))
+	if (rt6_need_strict(&iph->daddr) && skb->dev->type != ARPHRD_PIMREG)
 		flags |= RT6_LOOKUP_F_IFACE;

 	skb->dst = fib6_rule_lookup(net, &fl, flags, ip6_pol_route_input);
-- 
1.5.6.6
