From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v6 3/3] bridge: suppress nd pkts on BR_NEIGH_SUPPRESS ports
Date: Fri,  6 Oct 2017 22:12:39 -0700
Message-ID: <1507353159-46814-4-git-send-email-roopa@cumulusnetworks.com>
References: <1507353159-46814-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com,
        stephen@networkplumber.org, makita.toshiaki@lab.ntt.co.jp,
        bridge@lists.linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:48195 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751057AbdJGFMs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 01:12:48 -0400
Received: by mail-pf0-f174.google.com with SMTP id n24so10464951pfk.5
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 22:12:47 -0700 (PDT)
In-Reply-To: <1507353159-46814-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch avoids flooding and proxies ndisc packets
for BR_NEIGH_SUPPRESS ports.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/bridge/br_arp_nd_proxy.c | 249 +++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_device.c       |  11 ++
 net/bridge/br_input.c        |  11 ++
 net/bridge/br_private.h      |   3 +
 4 files changed, 274 insertions(+)

diff --git a/net/bridge/br_arp_nd_proxy.c b/net/bridge/br_arp_nd_proxy.c
index a79c182..2cf7716 100644
--- a/net/bridge/br_arp_nd_proxy.c
+++ b/net/bridge/br_arp_nd_proxy.c
@@ -21,6 +21,9 @@
 #include <linux/if_vlan.h>
 #include <linux/inetdevice.h>
 #include <net/addrconf.h>
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ip6_checksum.h>
+#endif
 
 #include "br_private.h"
 
@@ -218,3 +221,249 @@ void br_do_proxy_suppress_arp(struct sk_buff *skb, struct net_bridge *br,
 	}
 }
 #endif
+
+#if IS_ENABLED(CONFIG_IPV6)
+struct nd_msg *br_is_nd_neigh_msg(struct sk_buff *skb, struct nd_msg *msg)
+{
+	struct nd_msg *m;
+
+	m = skb_header_pointer(skb, skb_network_offset(skb) +
+			       sizeof(struct ipv6hdr), sizeof(*msg), msg);
+	if (!m)
+		return NULL;
+
+	if (m->icmph.icmp6_code != 0 ||
+	    (m->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION &&
+	     m->icmph.icmp6_type != NDISC_NEIGHBOUR_ADVERTISEMENT))
+		return NULL;
+
+	return m;
+}
+
+static void br_nd_send(struct net_bridge *br, struct net_bridge_port *p,
+		       struct sk_buff *request, struct neighbour *n,
+		       __be16 vlan_proto, u16 vlan_tci, struct nd_msg *ns)
+{
+	struct net_device *dev = request->dev;
+	struct net_bridge_vlan_group *vg;
+	struct sk_buff *reply;
+	struct nd_msg *na;
+	struct ipv6hdr *pip6;
+	int na_olen = 8; /* opt hdr + ETH_ALEN for target */
+	int ns_olen;
+	int i, len;
+	u8 *daddr;
+	u16 pvid;
+
+	if (!dev)
+		return;
+
+	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
+		sizeof(*na) + na_olen + dev->needed_tailroom;
+
+	reply = alloc_skb(len, GFP_ATOMIC);
+	if (!reply)
+		return;
+
+	reply->protocol = htons(ETH_P_IPV6);
+	reply->dev = dev;
+	skb_reserve(reply, LL_RESERVED_SPACE(dev));
+	skb_push(reply, sizeof(struct ethhdr));
+	skb_set_mac_header(reply, 0);
+
+	daddr = eth_hdr(request)->h_source;
+
+	/* Do we need option processing ? */
+	ns_olen = request->len - (skb_network_offset(request) +
+				  sizeof(struct ipv6hdr)) - sizeof(*ns);
+	for (i = 0; i < ns_olen - 1; i += (ns->opt[i + 1] << 3)) {
+		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
+			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
+			break;
+		}
+	}
+
+	/* Ethernet header */
+	ether_addr_copy(eth_hdr(reply)->h_dest, daddr);
+	ether_addr_copy(eth_hdr(reply)->h_source, n->ha);
+	eth_hdr(reply)->h_proto = htons(ETH_P_IPV6);
+	reply->protocol = htons(ETH_P_IPV6);
+
+	skb_pull(reply, sizeof(struct ethhdr));
+	skb_set_network_header(reply, 0);
+	skb_put(reply, sizeof(struct ipv6hdr));
+
+	/* IPv6 header */
+	pip6 = ipv6_hdr(reply);
+	memset(pip6, 0, sizeof(struct ipv6hdr));
+	pip6->version = 6;
+	pip6->priority = ipv6_hdr(request)->priority;
+	pip6->nexthdr = IPPROTO_ICMPV6;
+	pip6->hop_limit = 255;
+	pip6->daddr = ipv6_hdr(request)->saddr;
+	pip6->saddr = *(struct in6_addr *)n->primary_key;
+
+	skb_pull(reply, sizeof(struct ipv6hdr));
+	skb_set_transport_header(reply, 0);
+
+	na = (struct nd_msg *)skb_put(reply, sizeof(*na) + na_olen);
+
+	/* Neighbor Advertisement */
+	memset(na, 0, sizeof(*na) + na_olen);
+	na->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
+	na->icmph.icmp6_router = 0; /* XXX: should be 1 ? */
+	na->icmph.icmp6_override = 1;
+	na->icmph.icmp6_solicited = 1;
+	na->target = ns->target;
+	ether_addr_copy(&na->opt[2], n->ha);
+	na->opt[0] = ND_OPT_TARGET_LL_ADDR;
+	na->opt[1] = na_olen >> 3;
+
+	na->icmph.icmp6_cksum = csum_ipv6_magic(&pip6->saddr,
+						&pip6->daddr,
+						sizeof(*na) + na_olen,
+						IPPROTO_ICMPV6,
+						csum_partial(na, sizeof(*na) + na_olen, 0));
+
+	pip6->payload_len = htons(sizeof(*na) + na_olen);
+
+	skb_push(reply, sizeof(struct ipv6hdr));
+	skb_push(reply, sizeof(struct ethhdr));
+
+	reply->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (p)
+		vg = nbp_vlan_group_rcu(p);
+	else
+		vg = br_vlan_group_rcu(br);
+	pvid = br_get_pvid(vg);
+	if (pvid == (vlan_tci & VLAN_VID_MASK))
+		vlan_tci = 0;
+
+	if (vlan_tci)
+		__vlan_hwaccel_put_tag(reply, vlan_proto, vlan_tci);
+
+	netdev_dbg(dev, "nd send dev %s dst %pI6 dst_hw %pM src %pI6 src_hw %pM\n",
+		   dev->name, &pip6->daddr, daddr, &pip6->saddr, n->ha);
+
+	if (p) {
+		dev_queue_xmit(reply);
+	} else {
+		skb_reset_mac_header(reply);
+		__skb_pull(reply, skb_network_offset(reply));
+		reply->ip_summed = CHECKSUM_UNNECESSARY;
+		reply->pkt_type = PACKET_HOST;
+
+		netif_rx_ni(reply);
+	}
+}
+
+static int br_chk_addr_ip6(struct net_device *dev, void *data)
+{
+	struct in6_addr *addr = (struct in6_addr *)data;
+
+	if (ipv6_chk_addr(dev_net(dev), addr, dev, 0))
+		return 1;
+
+	return 0;
+}
+
+static bool br_is_local_ip6(struct net_device *dev, struct in6_addr *addr)
+
+{
+	if (br_chk_addr_ip6(dev, addr))
+		return true;
+
+	/* check if ip is configured on upper dev */
+	if (netdev_walk_all_upper_dev_rcu(dev, br_chk_addr_ip6, addr))
+		return true;
+
+	return false;
+}
+
+void br_do_suppress_nd(struct sk_buff *skb, struct net_bridge *br,
+		       u16 vid, struct net_bridge_port *p, struct nd_msg *msg)
+{
+	struct net_device *dev = br->dev;
+	struct net_device *vlandev = NULL;
+	struct in6_addr *saddr, *daddr;
+	struct ipv6hdr *iphdr;
+	struct neighbour *n;
+
+	BR_INPUT_SKB_CB(skb)->proxyarp_replied = false;
+
+	if (p && (p->flags & BR_NEIGH_SUPPRESS))
+		return;
+
+	if (msg->icmph.icmp6_type == NDISC_NEIGHBOUR_ADVERTISEMENT &&
+	    !msg->icmph.icmp6_solicited) {
+		/* prevent flooding to neigh suppress ports */
+		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		return;
+	}
+
+	if (msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
+		return;
+
+	iphdr = ipv6_hdr(skb);
+	saddr = &iphdr->saddr;
+	daddr = &iphdr->daddr;
+
+	if (ipv6_addr_any(saddr) || !ipv6_addr_cmp(saddr, daddr)) {
+		/* prevent flooding to neigh suppress ports */
+		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		return;
+	}
+
+	if (vid != 0) {
+		/* build neigh table lookup on the vlan device */
+		vlandev = __vlan_find_dev_deep_rcu(br->dev, skb->vlan_proto,
+						   vid);
+		if (!vlandev)
+			return;
+	} else {
+		vlandev = dev;
+	}
+
+	if (br_is_local_ip6(vlandev, &msg->target)) {
+		/* its our own ip, so don't proxy reply
+		 * and don't forward to arp suppress ports
+		 */
+		BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		return;
+	}
+
+	n = neigh_lookup(ipv6_stub->nd_tbl, &msg->target, vlandev);
+	if (n) {
+		struct net_bridge_fdb_entry *f;
+
+		if (!(n->nud_state & NUD_VALID)) {
+			neigh_release(n);
+			return;
+		}
+
+		f = br_fdb_find_rcu(br, n->ha, vid);
+		if (f) {
+			bool replied = false;
+
+			if (f->dst && (f->dst->flags & BR_NEIGH_SUPPRESS)) {
+				if (vid != 0)
+					br_nd_send(br, p, skb, n,
+						   skb->vlan_proto,
+						   skb_vlan_tag_get(skb), msg);
+				else
+					br_nd_send(br, p, skb, n, 0, 0, msg);
+				replied = true;
+			}
+
+			/* If we have replied or as long as we know the
+			 * mac, indicate to NEIGH_SUPPRESS ports that we
+			 * have replied
+			 */
+			if (replied || br->neigh_suppress_enabled)
+				BR_INPUT_SKB_CB(skb)->proxyarp_replied = true;
+		}
+		neigh_release(n);
+	}
+}
+#endif
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index eb30c6a..28bb221 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -69,6 +69,17 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	     eth->h_proto == htons(ETH_P_RARP)) &&
 	    br->neigh_suppress_enabled) {
 		br_do_proxy_suppress_arp(skb, br, vid, NULL);
+	} else if (IS_ENABLED(CONFIG_IPV6) &&
+		   skb->protocol == htons(ETH_P_IPV6) &&
+		   br->neigh_suppress_enabled &&
+		   pskb_may_pull(skb, sizeof(struct ipv6hdr) +
+				 sizeof(struct nd_msg)) &&
+		   ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6) {
+			struct nd_msg *msg, _msg;
+
+			msg = br_is_nd_neigh_msg(skb, &_msg);
+			if (msg)
+				br_do_suppress_nd(skb, br, vid, NULL, msg);
 	}
 
 	dest = eth_hdr(skb)->h_dest;
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 4b8d2ec..a096d3e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -119,6 +119,17 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 	    (skb->protocol == htons(ETH_P_ARP) ||
 	     skb->protocol == htons(ETH_P_RARP))) {
 		br_do_proxy_suppress_arp(skb, br, vid, p);
+	} else if (IS_ENABLED(CONFIG_IPV6) &&
+		   skb->protocol == htons(ETH_P_IPV6) &&
+		   br->neigh_suppress_enabled &&
+		   pskb_may_pull(skb, sizeof(struct ipv6hdr) +
+				 sizeof(struct nd_msg)) &&
+		   ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6) {
+			struct nd_msg *msg, _msg;
+
+			msg = br_is_nd_neigh_msg(skb, &_msg);
+			if (msg)
+				br_do_suppress_nd(skb, br, vid, p, msg);
 	}
 
 	switch (pkt_type) {
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 4e6b25b..fa0039f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -1144,4 +1144,7 @@ static inline void br_switchdev_frame_unmark(struct sk_buff *skb)
 void br_recalculate_neigh_suppress_enabled(struct net_bridge *br);
 void br_do_proxy_suppress_arp(struct sk_buff *skb, struct net_bridge *br,
 			      u16 vid, struct net_bridge_port *p);
+void br_do_suppress_nd(struct sk_buff *skb, struct net_bridge *br,
+		       u16 vid, struct net_bridge_port *p, struct nd_msg *msg);
+struct nd_msg *br_is_nd_neigh_msg(struct sk_buff *skb, struct nd_msg *m);
 #endif
-- 
2.1.4
