From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCH v6] vxlan: fix nonfunctional neigh_reduce()
Date: Mon, 24 Mar 2014 10:39:58 -0400
Message-ID: <201403241439.s2OEdwi0002321@xl.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:51108 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322AbaCXOkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 10:40:07 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Mon, 24 Mar 2014 10:40:06 -0400
Received: from b01cxnp22036.gho.pok.ibm.com (b01cxnp22036.gho.pok.ibm.com [9.57.198.26])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 095AAC9004A
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 10:39:58 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp22036.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2OEe1kK8192394
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 14:40:01 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2OEe13b022844
	for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 10:40:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The VXLAN neigh_reduce() code is completely non-functional since
check-in. Specific errors:

1) The original code drops all packets with a multicast destination address,
	even though neighbor solicitations are sent to the solicited-node
	address, a multicast address. The code after this check was never run.
2) The neighbor table lookup used the IPv6 header destination, which is the
	solicited node address, rather than the target address from the
	neighbor solicitation. So neighbor lookups would always fail if it
	got this far. Also for L3MISSes.
3) The code calls ndisc_send_na(), which does a send on the tunnel device.
	The context for neigh_reduce() is the transmit path, vxlan_xmit(),
	where the host or a bridge-attached neighbor is trying to transmit
	a neighbor solicitation. To respond to it, the tunnel endpoint needs
	to do a *receive* of the appropriate neighbor advertisement. Doing a
	send, would only try to send the advertisement, encapsulated, to the
	remote destinations in the fdb -- hosts that definitely did not do the
	corresponding solicitation.
4) The code uses the tunnel endpoint IPv6 forwarding flag to determine the
	isrouter flag in the advertisement. This has nothing to do with whether
	or not the target is a router, and generally won't be set since the
	tunnel endpoint is bridging, not routing, traffic.

	The patch below creates a proxy neighbor advertisement to respond to
neighbor solicitions as intended, providing proper IPv6 support for neighbor
reduction.

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>
---

Notes:
    Changes since v5:
    	-code cleanups per David Miller
    	-added multicast check on target
    	-split variable olen into na_olen and ns_olen
    Changes since v4:
    	-checkpatch cleanup suggested by Stephen Hemminger
    Changes since v3:
    	- code cleanup suggested by Brian Haley
    Changes since v2:
    	- code cleanup suggested by Stephen Hemminger and Daniel Baluta
    Changes since v1:
    	- reworked code to be structurally similar to arp_reduce()

 drivers/net/vxlan.c | 127 ++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 113 insertions(+), 14 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index eb59b14..30d2eec 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1336,15 +1336,103 @@ out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+
+static struct sk_buff *vxlan_na_create(struct sk_buff *request,
+	struct neighbour *n, bool isrouter)
+{
+	struct net_device *dev = request->dev;
+	struct sk_buff *reply;
+	struct nd_msg *ns, *na;
+	struct ipv6hdr *pip6;
+	u8 *daddr;
+	int na_olen = 8; /* opt hdr + ETH_ALEN for target */
+	int ns_olen;
+	int i, len;
+
+	if (dev == NULL)
+		return NULL;
+
+	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
+		sizeof(*na) + na_olen + dev->needed_tailroom;
+	reply = alloc_skb(len, GFP_ATOMIC);
+	if (reply == NULL)
+		return NULL;
+
+	reply->protocol = htons(ETH_P_IPV6);
+	reply->dev = dev;
+	skb_reserve(reply, LL_RESERVED_SPACE(request->dev));
+	skb_push(reply, sizeof(struct ethhdr));
+	skb_set_mac_header(reply, 0);
+
+	ns = (struct nd_msg *)skb_transport_header(request);
+
+	daddr = eth_hdr(request)->h_source;
+	ns_olen = request->len - skb_transport_offset(request) - sizeof(*ns);
+	for (i = 0; i < ns_olen-1; i += (ns->opt[i+1]<<3)) {
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
+
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
+	memset(na, 0, sizeof(*na)+na_olen);
+	na->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
+	na->icmph.icmp6_router = isrouter;
+	na->icmph.icmp6_override = 1;
+	na->icmph.icmp6_solicited = 1;
+	na->target = ns->target;
+	ether_addr_copy(&na->opt[2], n->ha);
+	na->opt[0] = ND_OPT_TARGET_LL_ADDR;
+	na->opt[1] = na_olen >> 3;
+
+	na->icmph.icmp6_cksum = csum_ipv6_magic(&pip6->saddr,
+		&pip6->daddr, sizeof(*na)+na_olen, IPPROTO_ICMPV6,
+		csum_partial(na, sizeof(*na)+na_olen, 0));
+
+	pip6->payload_len = htons(sizeof(*na)+na_olen);
+
+	skb_push(reply, sizeof(struct ipv6hdr));
+
+	reply->ip_summed = CHECKSUM_UNNECESSARY;
+
+	return reply;
+}
+
 static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct neighbour *n;
-	union vxlan_addr ipa;
+	struct nd_msg *msg;
 	const struct ipv6hdr *iphdr;
 	const struct in6_addr *saddr, *daddr;
-	struct nd_msg *msg;
-	struct inet6_dev *in6_dev = NULL;
+	struct neighbour *n;
+	struct inet6_dev *in6_dev;
 
 	in6_dev = __in6_dev_get(dev);
 	if (!in6_dev)
@@ -1357,19 +1445,20 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	saddr = &iphdr->saddr;
 	daddr = &iphdr->daddr;
 
-	if (ipv6_addr_loopback(daddr) ||
-	    ipv6_addr_is_multicast(daddr))
-		goto out;
-
 	msg = (struct nd_msg *)skb_transport_header(skb);
 	if (msg->icmph.icmp6_code != 0 ||
 	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
 		goto out;
 
-	n = neigh_lookup(ipv6_stub->nd_tbl, daddr, dev);
+	if (ipv6_addr_loopback(daddr) ||
+	    ipv6_addr_is_multicast(&msg->target))
+		goto out;
+
+	n = neigh_lookup(ipv6_stub->nd_tbl, &msg->target, dev);
 
 	if (n) {
 		struct vxlan_fdb *f;
+		struct sk_buff *reply;
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
@@ -1383,13 +1472,23 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 			goto out;
 		}
 
-		ipv6_stub->ndisc_send_na(dev, n, saddr, &msg->target,
-					 !!in6_dev->cnf.forwarding,
-					 true, false, false);
+		reply = vxlan_na_create(skb, n,
+					!!(f ? f->flags & NTF_ROUTER : 0));
+
 		neigh_release(n);
+
+		if (reply == NULL)
+			goto out;
+
+		if (netif_rx_ni(reply) == NET_RX_DROP)
+			dev->stats.rx_dropped++;
+
 	} else if (vxlan->flags & VXLAN_F_L3MISS) {
-		ipa.sin6.sin6_addr = *daddr;
-		ipa.sa.sa_family = AF_INET6;
+		union vxlan_addr ipa = {
+			.sin6.sin6_addr = msg->target,
+			.sa.sa_family = AF_INET6,
+		};
+
 		vxlan_ip_miss(dev, &ipa);
 	}
 
-- 
1.8.5.3
