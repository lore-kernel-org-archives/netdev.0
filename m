From: Vincent Bernat <vincent@bernat.im>
Subject: [net-next v3] vxlan: fix ND proxy when skb doesn't have transport header offset
Date: Fri, 31 Mar 2017 10:18:15 +0200
Message-ID: <20170331081815.23061-1-vincent@bernat.im>
References: <CANn89i+Ms_vvuowjmgERsA3=rMdTm_Cux3XTVJ19ewTz-TtBOw@mail.gmail.com>
Cc: Vincent Bernat <vincent@bernat.im>
To: Eric Dumazet <edumazet@google.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev <netdev@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:55271 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750839AbdCaISg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 31 Mar 2017 04:18:36 -0400
In-Reply-To: <CANn89i+Ms_vvuowjmgERsA3=rMdTm_Cux3XTVJ19ewTz-TtBOw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an incoming frame is tagged or when GRO is disabled, the skb
handled to vxlan_xmit() doesn't contain a valid transport header
offset. This makes ND proxying fail.

We combine two changes: replace use of skb_transport_offset() and ensure
the necessary amount of skb is linear just before using it:

 - In vxlan_xmit(), when determining if we have an ICMPv6 neighbor
   discovery packet, just check if it is an ICMPv6 packet and rely on
   neigh_reduce() to do more checks if this is the case. The use of
   pskb_may_pull() is replaced by skb_header_pointer() for just the IPv6
   header.

 - In neigh_reduce(), add pskb_may_pull() for IPv6 header and neighbor
   discovery message since this was removed from vxlan_xmit(). Replace
   skb_transport_header() with ipv6_hdr() + 1.

 - In vxlan_na_create(), replace first skb_transport_offset() with
   ipv6_hdr() + 1 and second with skb_network_offset() + sizeof(struct
   ipv6hdr). Additionally, ensure we pskb_may_pull() the whole skb as we
   need it to iterate over the options.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 drivers/net/vxlan.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e54fb5c883a..54dda367de2b 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1515,7 +1515,7 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	int ns_olen;
 	int i, len;
 
-	if (dev == NULL)
+	if (dev == NULL || !pskb_may_pull(request, request->len))
 		return NULL;
 
 	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
@@ -1530,10 +1530,11 @@ static struct sk_buff *vxlan_na_create(struct sk_buff *request,
 	skb_push(reply, sizeof(struct ethhdr));
 	skb_reset_mac_header(reply);
 
-	ns = (struct nd_msg *)skb_transport_header(request);
+	ns = (struct nd_msg *)(ipv6_hdr(request) + 1);
 
 	daddr = eth_hdr(request)->h_source;
-	ns_olen = request->len - skb_transport_offset(request) - sizeof(*ns);
+	ns_olen = request->len - skb_network_offset(request) -
+		sizeof(struct ipv6hdr) - sizeof(*ns);
 	for (i = 0; i < ns_olen-1; i += (ns->opt[i+1]<<3)) {
 		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
 			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
@@ -1604,10 +1605,13 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb, __be32 vni)
 	if (!in6_dev)
 		goto out;
 
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr) + sizeof(struct nd_msg)))
+		goto out;
+
 	iphdr = ipv6_hdr(skb);
 	daddr = &iphdr->daddr;
 
-	msg = (struct nd_msg *)skb_transport_header(skb);
+	msg = (struct nd_msg *)(iphdr + 1);
 	if (msg->icmph.icmp6_code != 0 ||
 	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
 		goto out;
@@ -2238,21 +2242,17 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (vxlan->flags & VXLAN_F_PROXY) {
+		struct ipv6hdr *hdr, _hdr;
 		eth = eth_hdr(skb);
 		if (ntohs(eth->h_proto) == ETH_P_ARP)
 			return arp_reduce(dev, skb, vni);
 #if IS_ENABLED(CONFIG_IPV6)
 		else if (ntohs(eth->h_proto) == ETH_P_IPV6 &&
-			 pskb_may_pull(skb, sizeof(struct ipv6hdr)
-				       + sizeof(struct nd_msg)) &&
-			 ipv6_hdr(skb)->nexthdr == IPPROTO_ICMPV6) {
-				struct nd_msg *msg;
-
-				msg = (struct nd_msg *)skb_transport_header(skb);
-				if (msg->icmph.icmp6_code == 0 &&
-				    msg->icmph.icmp6_type == NDISC_NEIGHBOUR_SOLICITATION)
-					return neigh_reduce(dev, skb, vni);
-		}
+			 (hdr = skb_header_pointer(skb,
+						   skb_network_offset(skb),
+						   sizeof(_hdr), &_hdr)) &&
+			 hdr->nexthdr == IPPROTO_ICMPV6)
+			return neigh_reduce(dev, skb, vni);
 #endif
 	}
 
-- 
2.11.0
