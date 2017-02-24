From: Jouni Malinen <jouni@codeaurora.org>
Subject: [PATCH] bridge: Add support for IEEE 802.11 Proxy ARP for IPv6
Date: Fri, 24 Feb 2017 20:39:41 +0200
Message-ID: <1487961581-20683-1-git-send-email-jouni@codeaurora.org>
Cc: netdev@vger.kernel.org, Jouni Malinen <jouni@codeaurora.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57098 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdBXSkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 13:40:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/bridge/br_multicast.c | 268 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 268 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index b760f26..7a375a7 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -32,6 +32,7 @@
 #include <net/ipv6.h>
 #include <net/mld.h>
 #include <net/ip6_checksum.h>
+#include <net/ip6_route.h>
 #include <net/addrconf.h>
 #endif
 
@@ -1815,6 +1816,272 @@ static int br_multicast_ipv4_rcv(struct net_bridge *br,
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+static int br_ndisc_send_na_finish(struct net *net, struct sock *sk,
+				   struct sk_buff *skb)
+{
+	return dev_queue_xmit(skb);
+}
+
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
+			ndisc_opt_addr_space(dev,
+					     NDISC_NEIGHBOUR_ADVERTISEMENT) +
+			tlen, GFP_ATOMIC);
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
+	space = ndisc_opt_addr_space(skb->dev, NDISC_NEIGHBOUR_ADVERTISEMENT);
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
+	hdr->payload_len = htons(skb->len - sizeof(*hdr));
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
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk, skb, NULL,
+		      dst->dev, dest_hw ? br_ndisc_send_na_finish : dst_output);
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
+static bool br_fdb_dst_proxyarp_wifi(struct net_bridge *br, u16 vid,
+				     struct net_bridge_port *p,
+				     struct neighbour *n)
+{
+	struct net_bridge_fdb_entry *f;
+	bool ret = false;
+
+	rcu_read_lock();
+	f = br_fdb_find_rcu(br, n->ha, vid);
+	if (f && ((p->flags & BR_PROXYARP) ||
+		  (f->dst && (f->dst->flags & BR_PROXYARP_WIFI))))
+		ret = true;
+	rcu_read_unlock();
+	return ret;
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
+	/* This function is called only if ipv6_mc_check_mld() return -ENOMSG,
+	 * i.e., after successful IP header validation. As such, the header
+	 * validation has already been performed and does not need to be
+	 * repeated here for the skb.
+	 */
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
+	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION ||
+	    ipv6_addr_loopback(daddr) ||
+	    ipv6_addr_is_multicast(&msg->target))
+		return;
+
+	n = neigh_lookup(&nd_tbl, &msg->target, dev);
+	if (!n)
+		return;
+
+	if (!(n->nud_state & NUD_VALID) ||
+	    !br_fdb_dst_proxyarp_wifi(br, vid, p, n))
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
@@ -1830,6 +2097,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	if (err == -ENOMSG) {
 		if (!ipv6_addr_is_ll_all_nodes(&ipv6_hdr(skb)->daddr))
 			BR_INPUT_SKB_CB(skb)->mrouters_only = 1;
+		br_do_proxy_ndisc(skb, br, vid, port);
 		return 0;
 	} else if (err < 0) {
 		br_multicast_err_count(br, port, skb->protocol);
-- 
2.7.4
