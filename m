From: Jouni Malinen <jouni@codeaurora.org>
Subject: [RFC v2] bridge: Add support for IEEE 802.11 Proxy ARP for IPv6
Date: Tue, 24 Mar 2015 17:55:11 +0200
Message-ID: <20150324155511.GA18284@jouni.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:51185 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932423AbbCXPzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 11:55:18 -0400
Received: from jouni.codeaurora.org (37-33-32-72.bb.dnainternet.fi [37.33.32.72])
	(using TLSv1 with cipher AES128-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: jouni@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id C83D4141FF9
	for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:55:14 +0000 (UTC)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an updated version of the ProxyARP extension to support the IPv6
case. The main difference here is in enabling the Hotspot 2.0
requirement of changing the source MAC address in the link layer header
which seemed to require replacing the use of ndisc.c functions with a
custom version of NA skb generation and going through dev_queue_xmit()
rather than dst_output() for the case where the sender's MAC address
needs to be modified to match that of the target device.

I'd welcome any feedback on this design. As far as main functionality is
concerned, this seems to work fine for the Hotspot 2.0 use case. I guess
this could be made somewhat cleaner, but I'm not sure whether there
would be sufficient justification for refactoring net/ipv6/ndisc.c
functions enough to meet this special case where the link layer header
needs modifications and similarly, where the target LL address ND option
needs to use different value.

The current RFC version:

bridge: Add support for IEEE 802.11 Proxy ARP for IPv6

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

To meet the Hotspot 2.0 requirement of using the target devices MAC
address as the sender's MAC address in the NA frame (when AP replies on
behalf of an associated station), the full link layer header needs to be
built with a custom function instead of going through the existing
ndisc.c implementation.

Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
---
 net/bridge/br_multicast.c | 261 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 257 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index c465876..c30d3e7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -30,6 +30,7 @@
 #include <net/ipv6.h>
 #include <net/mld.h>
 #include <net/ip6_checksum.h>
+#include <net/ip6_route.h>
 #include <net/addrconf.h>
 #endif
 
@@ -1651,6 +1652,252 @@ err_out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+void br_ndisc_send_na(struct net_device *dev,
+		      const struct in6_addr *daddr,
+		      const struct in6_addr *solicited_addr,
+		      const u8 *target_lladdr, bool solicited,
+		      bool override, const u8 *dest_hw)
+{
+	struct sk_buff *skb;
+	struct nd_msg *msg;
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
+	struct dst_entry *dst;
+	struct net *net = dev_net(dev);
+	struct sock *sk = net->ipv6.ndisc_sk;
+	struct inet6_dev *idev;
+	int err;
+	struct ipv6hdr *hdr;
+	struct icmp6hdr *icmp6h;
+	u8 type;
+	const struct in6_addr *saddr = solicited_addr;
+	int pad, data_len, space;
+	u8 *opt;
+
+	skb = alloc_skb(hlen + sizeof(struct ipv6hdr) + sizeof(*msg) +
+			ndisc_opt_addr_space(dev) + tlen, GFP_ATOMIC);
+	if (!skb)
+		return;
+
+	skb->protocol = htons(ETH_P_IPV6);
+	skb->dev = dev;
+
+	skb_reserve(skb, hlen + sizeof(struct ipv6hdr));
+	skb_reset_transport_header(skb);
+
+	/* Manually assign socket ownership as we avoid calling
+	 * sock_alloc_send_pskb() to bypass wmem buffer limits
+	 */
+	skb_set_owner_w(skb, sk);
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
+	 * address be the target ll addr and src_addr.
+	 */
+	pad = ndisc_addr_option_pad(skb->dev->type);
+	data_len = skb->dev->addr_len;
+	space = ndisc_opt_addr_space(skb->dev);
+	opt = skb_put(skb, space);
+
+	opt[0] = ND_OPT_TARGET_LL_ADDR;
+	opt[1] = space >> 3;
+
+	memset(opt + 2, 0, pad);
+	opt += pad;
+	space -= pad;
+
+	memcpy(opt + 2, target_lladdr, dev->addr_len);
+	data_len += 2;
+	opt += data_len;
+	space -= data_len;
+	if (space > 0)
+		memset(opt, 0, space);
+
+	dst = skb_dst(skb);
+	icmp6h = icmp6_hdr(skb);
+
+	type = icmp6h->icmp6_type;
+
+	if (!dst) {
+		struct flowi6 fl6;
+
+		icmpv6_flow_init(sk, &fl6, type, saddr, daddr,
+				 skb->dev->ifindex);
+		dst = icmp6_dst_alloc(skb->dev, &fl6);
+		if (IS_ERR(dst))
+			goto out;
+
+		skb_dst_set(skb, dst);
+	}
+
+	icmp6h->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
+					      IPPROTO_ICMPV6,
+					      csum_partial(icmp6h,
+							   skb->len, 0));
+
+	skb_push(skb, sizeof(*hdr));
+	skb_reset_network_header(skb);
+	hdr = ipv6_hdr(skb);
+
+	ip6_flow_hdr(hdr, 0, 0);
+
+	hdr->payload_len = htons(skb->len);
+	hdr->nexthdr = IPPROTO_ICMPV6;
+	hdr->hop_limit = inet6_sk(sk)->hop_limit;
+
+	hdr->saddr = *saddr;
+	hdr->daddr = *daddr;
+
+	/* We are replying on behalf of another entity. Use that entity's
+	 * address as the source link layer address if we have all the needed
+	 * information to build the link layer header.
+	 */
+	if (dest_hw &&
+	    dev_hard_header(skb, dev, ETH_P_IPV6, dest_hw, target_lladdr,
+			    skb->len) < 0)
+		goto out;
+
+	rcu_read_lock();
+	idev = __in6_dev_get(dst->dev);
+	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
+
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, skb, NULL, dst->dev,
+		      dest_hw ? dev_queue_xmit : dst_output);
+	if (!err) {
+		ICMP6MSGOUT_INC_STATS(net, idev, type);
+		ICMP6_INC_STATS(net, idev, ICMP6_MIB_OUTMSGS);
+	}
+
+	rcu_read_unlock();
+	return;
+
+out:
+	kfree_skb(skb);
+}
+
+static const u8 *br_get_ndisc_lladdr(const u8 *opt, int opt_len,
+				     unsigned int alen)
+{
+	const struct nd_opt_hdr *nd_opt = (const struct nd_opt_hdr *)opt;
+
+	while (opt_len > sizeof(struct nd_opt_hdr)) {
+		int l;
+
+		l = nd_opt->nd_opt_len << 3;
+		if (opt_len < l || l == 0)
+			return NULL;
+
+		if (nd_opt->nd_opt_type == ND_OPT_SOURCE_LL_ADDR) {
+			if (l >= 2 + alen)
+				return (const u8 *)(nd_opt + 1);
+		}
+
+		opt_len -= l;
+		nd_opt = ((void *)nd_opt) + l;
+	}
+
+	return NULL;
+}
+
+static void br_do_proxy_ndisc(struct sk_buff *skb, struct net_bridge *br,
+			      u16 vid, struct net_bridge_port *p)
+{
+	struct net_device *dev = br->dev;
+	struct nd_msg *msg;
+	const struct ipv6hdr *iphdr;
+	const struct in6_addr *saddr, *daddr;
+	struct neighbour *n, *n_sender = NULL;
+	struct net_bridge_fdb_entry *f;
+	int ndoptlen;
+	bool override = false, solicited = true;
+	bool dad;
+	const struct in6_addr *daddr_na;
+	const u8 *dest_hw = NULL;
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
+	if (!(n->nud_state & NUD_VALID))
+		goto out;
+
+	f = __br_fdb_get(br, n->ha, vid);
+	if (!f)
+		goto out;
+
+	if (!(p->flags & BR_PROXYARP) &&
+	    !(f->dst && (f->dst->flags & BR_PROXYARP_WIFI)))
+		goto out;
+
+	dad = ipv6_addr_any(saddr);
+	daddr_na = saddr;
+
+	if (dad && !ipv6_addr_is_solict_mult(daddr))
+		goto out;
+
+	if (dad) {
+		override = true;
+		solicited = false;
+		daddr_na = &in6addr_linklocal_allnodes;
+	}
+
+	if (!(p->flags & BR_PROXYARP)) {
+		ndoptlen = skb_tail_pointer(skb) -
+			(skb_transport_header(skb) +
+			 offsetof(struct nd_msg, opt));
+		dest_hw = br_get_ndisc_lladdr(msg->opt, ndoptlen,
+					      dev->addr_len);
+		if (!dest_hw && !dad) {
+			n_sender = neigh_lookup(&nd_tbl, saddr, dev);
+			if (n_sender)
+				dest_hw = n_sender->ha;
+		}
+
+		if (dest_hw && is_multicast_ether_addr(dest_hw))
+			dest_hw = NULL;
+	}
+
+	br_ndisc_send_na(dev, daddr_na, &msg->target, n->ha, solicited,
+			 override, dest_hw);
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+
+out:
+	neigh_release(n);
+	if (n_sender)
+		neigh_release(n_sender);
+}
+
 static int br_multicast_ipv6_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
 				 struct sk_buff *skb,
@@ -1671,9 +1918,9 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
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
@@ -1683,8 +1930,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	if (!ipv6_addr_is_ll_all_nodes(&ip6h->daddr))
 		BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
 
-	if (ip6h->nexthdr != IPPROTO_HOPOPTS ||
-	    ip6h->payload_len == 0)
+	if (ip6h->payload_len == 0)
 		return 0;
 
 	len = ntohs(ip6h->payload_len) + sizeof(*ip6h);
@@ -1720,7 +1966,14 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
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
-- 
1.9.1


-- 
Jouni Malinen                                            PGP id EFC895FA
