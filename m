From: Jouni Malinen <jouni@codeaurora.org>
Subject: [RFC] bridge: Add support for IEEE 802.11 Proxy ARP for IPv6
Date: Fri, 6 Mar 2015 11:26:29 +0200
Message-ID: <20150306092629.GA5749@jouni.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:33640 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbCFJ0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 04:26:36 -0500
Received: from jouni.codeaurora.org (87-93-82-155.bb.dnainternet.fi [87.93.82.155])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: jouni@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 59349140AF9
	for <netdev@vger.kernel.org>; Fri,  6 Mar 2015 09:26:33 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch below adds IPv6 version of the recently added IEEE 802.11
Proxy ARP functionality (BR_PROXYARP and BR_PROXYARP_WIFI) that covers
IPv4 in current net-next. There was couple of different options on how
to try to re-use existing functions for sending out NA either using an
extended version of ndisc_send_na() or by implementing similar
functionality in net/bridge to avoid changes in ndisc_send_na(). The
patch below follows the latter alternative and exports couple of
net/ipv6/ndisc.c functions to allow that to be done (or well, now that I
look at it, it does not actually add EXPORT_SYMBOL, but would likely
need to add that to make this work with modular IPv6 build). I do have
another version that goes through the ndisc_send_na() version as well
(i.e., add target_lladdr argument to it to enable the required change
into the NA contents to be made for proxyarp purposes).

However, while both of these alternatives of reusing existing functions
to build and send the NA seem to work at least when using Linux devices,
one of the IEEE 802.11, or well, Hotspot 2.0, to be more exact, protocol
requirements is not met. There is an expectation of the access point
(i.e., the device that replies to NS on behalf of the real target) to
use the MAC address of the real target as the source link layer MAC
address in the IPv6 frame that carries the NA. This does not seem to be
very convenient requirement from the view point of being able to use
ndisc_send_skb() or normal means of sending a IPv6 packet in general.

Would anyone have any recommendations on how to be able to cleanly build
an NA from net/bridge/*.c and send it using a specific (not local) MAC
address as the link layer source address? Or would the only realistic
way for achieving this require the full skb to be build from scratch
with the specific source MAC address and not even trying to re-use
ndisc_send_skb() for sending it?


The current RFC version:

This is an IPv6 extension of commit 958501163ddd ("bridge: Add support
for IEEE 802.11 Proxy ARP"). The IEEE 802.11 Proxy ARP feature is
defined in IEEE Std 802.11-2012, 10.23.13. It allows the AP devices to
keep track of the hardware-address-to-IP-address mapping of the mobile
devices within the WLAN network.

The AP will learn this mapping via observing NS/NA frames (this part is
implemented in user space, e.g., in hostapd). When a request for such
information is made (i.e., Neighbor Solicitation), the AP will respond
on behalf of the associated mobile device. In the process of doing so,
the AP will drop the multicast request frame that was intended to go out
to the wireless medium.

Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 include/net/ndisc.h       |   5 +++
 net/bridge/br_multicast.c | 112 ++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv6/ndisc.c          |  11 +++--
 3 files changed, 118 insertions(+), 10 deletions(-)

diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index b3a7751..91cb20a 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -190,6 +190,11 @@ void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 		   const struct in6_addr *daddr,
 		   const struct in6_addr *solicited_addr,
 		   bool router, bool solicited, bool override, bool inc_opt);
+void ndisc_fill_addr_option(struct sk_buff *skb, int type, const void *data);
+struct sk_buff *ndisc_alloc_skb(struct net_device *dev, int len);
+void ndisc_send_skb(struct sk_buff *skb,
+		    const struct in6_addr *daddr,
+		    const struct in6_addr *saddr);
 
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target);
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c465876..6fa276d 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1651,6 +1651,104 @@ err_out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+void br_ndisc_send_na(struct net_device *dev,
+		      const struct in6_addr *daddr,
+		      const struct in6_addr *solicited_addr,
+		      const u8 *target_lladdr, bool solicited, bool override)
+{
+	struct sk_buff *skb;
+	struct nd_msg *msg;
+
+	/* TODO: How to replace source MAC address in the link layer header to
+	 * be that of the device on behalf of which we are replying? That is
+	 * needed to meet the BR_PROXYARP_WIFI expectations.
+	 */
+	skb = ndisc_alloc_skb(dev, sizeof(*msg) + ndisc_opt_addr_space(dev));
+	if (!skb)
+		return;
+
+	msg = (struct nd_msg *)skb_put(skb, sizeof(*msg));
+	*msg = (struct nd_msg) {
+		.icmph = {
+			.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT,
+			.icmp6_router = false,
+			.icmp6_solicited = solicited,
+			.icmp6_override = override,
+		},
+		.target = *solicited_addr,
+	};
+
+	/* We are replying on behalf of other entity. Let that entity's
+	 * addresses be the target ll addr and src_addr.
+	 */
+	ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, target_lladdr);
+	ndisc_send_skb(skb, daddr, solicited_addr);
+}
+
+static void br_do_proxy_ndisc(struct sk_buff *skb, struct net_bridge *br,
+			      u16 vid, struct net_bridge_port *p)
+{
+	struct net_device *dev = br->dev;
+	struct nd_msg *msg;
+	const struct ipv6hdr *iphdr;
+	const struct in6_addr *saddr, *daddr;
+	struct neighbour *n;
+	struct net_bridge_fdb_entry *f;
+
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
+
+	if (!p)
+		return;
+
+	if (!pskb_may_pull(skb, skb->len))
+		return;
+
+	iphdr = ipv6_hdr(skb);
+	saddr = &iphdr->saddr;
+	daddr = &iphdr->daddr;
+
+	msg = (struct nd_msg *)skb_transport_header(skb);
+	if (msg->icmph.icmp6_code != 0 ||
+	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
+		return;
+
+	if (ipv6_addr_loopback(daddr) ||
+	    ipv6_addr_is_multicast(&msg->target))
+		return;
+
+	n = neigh_lookup(&nd_tbl, &msg->target, dev);
+	if (!n)
+		return;
+
+	if (!(n->nud_state & NUD_VALID)) {
+		neigh_release(n);
+		return;
+	}
+
+	f = __br_fdb_get(br, n->ha, vid);
+	if (f && ((p->flags & BR_PROXYARP) ||
+		  (f->dst && (f->dst->flags & BR_PROXYARP_WIFI)))) {
+		bool override = false, solicited = true;
+		bool dad = ipv6_addr_any(saddr);
+		const struct in6_addr *daddr_na = saddr;
+
+		if (dad && !ipv6_addr_is_solict_mult(daddr))
+			return;
+
+		if (dad) {
+			override = true;
+			solicited = false;
+			daddr_na = &in6addr_linklocal_allnodes;
+		}
+
+		br_ndisc_send_na(dev, daddr_na, &msg->target, n->ha, solicited,
+				 override);
+		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+	}
+
+	neigh_release(n);
+}
+
 static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb,
@@ -1671,9 +1769,9 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	ip6h = ipv6_hdr(skb);
 
 	/*
-	 * We're interested in MLD messages only.
+	 * For the interested messages:
 	 *  - Version is 6
-	 *  - MLD has always Router Alert hop-by-hop option
+	 *  - If MLD, always has Router Alert hop-by-hop option
 	 *  - But we do not support jumbrograms.
 	 */
 	if (ip6h->version != 6)
@@ -1683,8 +1781,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 
-	if (ip6h->nexthdr != IPPROTO_HOPOPTS ||
-	    ip6h->payload_len == 0)
+	if (ip6h->payload_len == 0)
 		return 0;
 
 	len = ntohs(ip6h->payload_len) + sizeof(*ip6h);
@@ -1720,7 +1817,14 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	case ICMPV6_MGM_REPORT:
 	case ICMPV6_MGM_REDUCTION:
 	case ICMPV6_MLD2_REPORT:
+		if (ip6h->nexthdr != IPPROTO_HOPOPTS) {
+			err = 0;
+			goto out;
+		}
 		break;
+	case NDISC_NEIGHBOUR_SOLICITATION:
+		br_do_proxy_ndisc(skb2, br, vid, port);
+		/* FALL THROUGH */
 	default:
 		err = 0;
 		goto out;
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 247ad7c..79dab0c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -148,7 +148,7 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
+void ndisc_fill_addr_option(struct sk_buff *skb, int type, const void *data)
 {
 	int pad   = ndisc_addr_option_pad(skb->dev->type);
 	int data_len = skb->dev->addr_len;
@@ -375,8 +375,7 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
-static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
-				       int len)
+struct sk_buff *ndisc_alloc_skb(struct net_device *dev, int len)
 {
 	int hlen = LL_RESERVED_SPACE(dev);
 	int tlen = dev->needed_tailroom;
@@ -425,9 +424,9 @@ static void ip6_nd_hdr(struct sk_buff *skb,
 	hdr->daddr = *daddr;
 }
 
-static void ndisc_send_skb(struct sk_buff *skb,
-			   const struct in6_addr *daddr,
-			   const struct in6_addr *saddr)
+void ndisc_send_skb(struct sk_buff *skb,
+		    const struct in6_addr *daddr,
+		    const struct in6_addr *saddr)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net *net = dev_net(skb->dev);
-- 
1.9.1


-- 
Jouni Malinen                                            PGP id EFC895FA
