From: Vincent Bernat <vincent@bernat.im>
Subject: [net-next v2] vxlan: fix ND proxy when skb doesn't have transport header offset
Date: Wed, 29 Mar 2017 22:47:04 +0200
Message-ID: <20170329204704.26087-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: Eric Dumazet <edumazet@google.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:45711 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932822AbdC2UrW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 16:47:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an incoming frame is tagged or when GRO is disabled, the skb
handled to vxlan_xmit() doesn't contain a valid transport header
offset. This makes ND proxying fail.

Do not rely on skb_transport_offset(). Instead, use offsets from
skb_network_offset() with skb_header_pointer() to extract appropriate
information to detect an ICMPv6 neighbor solicitation and to extract the
information needed to build the answer.

Duplicate checks at the beginning of neigh_reduce() are removed.

Parsing of neighbor discovery options is done earlier to ignore the
whole packet in case of a malformed option. Moreover, the assumption the
skb was linear is removed and options are extracted with
skb_header_pointer() as well. The check on the source link-layer address
option is also more strict (for Ethernet, we expect the length field to
be 1).

After this change, the vxlan module is correctly able to answer to
VLAN-encapsulated frames:

22:02:46.332573 50:54:33:00:00:02 > 33:33:00:00:00:02, ethertype 802.1Q (0x8100), length 74: vlan 100, p 0,ethertype IPv6, (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::5254:33ff:fe00:2 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
          source link-address option (1), length 8 (1): 50:54:33:00:00:02
            0x0000:  5054 3300 0002
22:02:47.846631 50:54:33:00:00:08 > 33:33:00:00:00:02, ethertype 802.1Q (0x8100), length 74: vlan 100, p 0,ethertype IPv6, (hlim 255, next-header ICMPv6 (58) payload length: 16) fe80::5254:33ff:fe00:8 > ff02::2: [icmp6 sum ok] ICMP6, router solicitation, length 16
          source link-address option (1), length 8 (1): 50:54:33:00:00:08
            0x0000:  5054 3300 0008

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 drivers/net/vxlan.c | 85 ++++++++++++++++++++++++++++++-----------------------
 1 file changed, 48 insertions(+), 37 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e54fb5c883a..f40272785aa2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1504,20 +1504,43 @@ static int arp_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 
 #if IS_ENABLED(CONFIG_IPV6)
 static struct sk_buff *vxlan_na_create(struct sk_buff *request,
-	struct neighbour *n, bool isrouter)
+				       struct ipv6hdr *ip6h, struct nd_msg *ns,
+				       struct neighbour *n, bool isrouter)
 {
 	struct net_device *dev = request->dev;
 	struct sk_buff *reply;
-	struct nd_msg *ns, *na;
+	struct nd_msg *na;
 	struct ipv6hdr *pip6;
-	u8 *daddr;
+	u8 *daddr, _daddr[ETH_ALEN];
 	int na_olen = 8; /* opt hdr + ETH_ALEN for target */
-	int ns_olen;
-	int i, len;
+	int len, remaining, offset;
 
 	if (dev == NULL)
 		return NULL;
 
+	/* Destination address is the "source link-layer address"
+	 * option if present and valid or the source Ethernet
+	 * address */
+	daddr = eth_hdr(request)->h_source;
+	remaining = htons(ip6h->payload_len) - sizeof(*ns);
+	offset = skb_network_offset(request) + sizeof(*ip6h) + sizeof(*ns);
+	while (remaining > sizeof(struct nd_opt_hdr)) {
+		struct nd_opt_hdr *ohdr, _ohdr;
+		ohdr = skb_header_pointer(request, offset, sizeof(_ohdr), &_ohdr);
+		if (!ohdr || !(len = ohdr->nd_opt_len<<3) || len > remaining)
+			return NULL;
+		if (ohdr->nd_opt_type == ND_OPT_SOURCE_LL_ADDR &&
+		    len == na_olen) {
+			daddr = skb_header_pointer(request, offset + sizeof(_ohdr),
+						   sizeof(_daddr), _daddr);
+			if (!daddr)
+				return NULL;
+			break;
+		}
+		remaining -= len;
+		offset += len;
+	}
+
 	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
 		sizeof(*na) + na_olen + dev->needed_tailroom;
 	reply = alloc_skb(len, GFP_ATOMIC);
@@ -1530,16 +1553,6 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	skb_push(reply, sizeof(struct ethhdr));
 	skb_reset_mac_header(reply);
 
-	ns = (struct nd_msg *)skb_transport_header(request);
-
-	daddr = eth_hdr(request)->h_source;
-	ns_olen = request->len - skb_transport_offset(request) - sizeof(*ns);
-	for (i = 0; i < ns_olen-1; i += (ns->opt[i+1]<<3)) {
-		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
-			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
-			break;
-		}
-	}
 
 	/* Ethernet header */
 	ether_addr_copy(eth_hdr(reply)->h_dest, daddr);
@@ -1556,10 +1569,10 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	pip6 = ipv6_hdr(reply);
 	memset(pip6, 0, sizeof(struct ipv6hdr));
 	pip6->version = 6;
-	pip6->priority = ipv6_hdr(request)->priority;
+	pip6->priority = ip6h->priority;
 	pip6->nexthdr = IPPROTO_ICMPV6;
 	pip6->hop_limit = 255;
-	pip6->daddr = ipv6_hdr(request)->saddr;
+	pip6->daddr = ip6h->saddr;
 	pip6->saddr = *(struct in6_addr *)n->primary_key;
 
 	skb_pull(reply, sizeof(struct ipv6hdr));
@@ -1591,11 +1604,11 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	return reply;
 }
 
-static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
+static int neigh_reduce(struct net_device *dev, struct sk_buff *skb,
+			struct ipv6hdr *iphdr, struct nd_msg *msg,
+			__be32 vni)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct nd_msg *msg;
-	const struct ipv6hdr *iphdr;
 	const struct in6_addr *daddr;
 	struct neighbour *n;
 	struct inet6_dev *in6_dev;
@@ -1604,14 +1617,8 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 	if (!in6_dev)
 		goto out;
 
-	iphdr = ipv6_hdr(skb);
 	daddr = &iphdr->daddr;
 
-	msg = (struct nd_msg *)skb_transport_header(skb);
-	if (msg->icmph.icmp6_code != 0 ||
-	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
-		goto out;
-
 	if (ipv6_addr_loopback(daddr) ||
 	    ipv6_addr_is_multicast(&msg->target))
 		goto out;
@@ -1634,7 +1641,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 			goto out;
 		}
 
-		reply = vxlan_na_create(skb, n,
+		reply = vxlan_na_create(skb, iphdr, msg, n,
 					!!(f ? f->flags & NTF_ROUTER : 0));
 
 		neigh_release(n);
@@ -2242,16 +2249,20 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
 			return arp_reduce(dev, skb, vni);
 #if IS_ENABLED(CONFIG_IPV6)
-		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
-			 pskb_may_pull(skb, sizeof(struct ipv6hdr)
-				       + sizeof(struct nd_msg)) &&
-			 ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6) {
-				struct nd_msg *msg;
-
-				msg = (struct nd_msg *)skb_transport_header(skb);
-				if (msg->icmph.icmp6_code == 0 &&
-				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
-					return neigh_reduce(dev, skb, vni);
+		else if (ntohs(eth->h_proto) == ETH_P_IPV6) {
+			struct ipv6hdr *hdr, _hdr;
+			struct nd_msg *msg, _msg;
+			if ((hdr = skb_header_pointer(skb,
+						      skb_network_offset(skb),
+						      sizeof(_hdr), &_hdr)) &&
+			    hdr->nexthdr == IPPROTO_ICMPV6 &&
+			    (msg = skb_header_pointer(skb,
+						      skb_network_offset(skb) +
+						      sizeof(_hdr),
+						      sizeof(_msg), &_msg)) &&
+			    msg->icmph.icmp6_code == 0 &&
+			    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
+				return neigh_reduce(dev, skb, hdr, msg, vni);
 		}
 #endif
 	}
-- 
2.11.0
