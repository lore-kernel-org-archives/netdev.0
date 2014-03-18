From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCHv3 net-next] VXLAN: fix nonfunctional neigh_reduce
Date: Tue, 18 Mar 2014 12:20:17 -0400
Message-ID: <201403181620.s2IGKHcW028664@lab1.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:54974 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756478AbaCRQUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 12:20:31 -0400
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 18 Mar 2014 10:20:30 -0600
Received: from b03cxnp08028.gho.boulder.ibm.com (b03cxnp08028.gho.boulder.ibm.com [9.17.130.20])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 88A6719D8040
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:20:24 -0600 (MDT)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s2IGKRLk51904514
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 17:20:27 +0100
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s2IGKRnC021937
	for <netdev@vger.kernel.org>; Tue, 18 Mar 2014 10:20:27 -0600
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

Changes since v2:

- code cleanup suggested by Stephen Hemminger and Daniel Baluta

Changes since v1:

- reworked code to be structurally similar to arp_reduce() per Dave Miller

Signed-Off-By: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index eb59b14..f6ddde9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1336,14 +1336,102 @@ out:
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
+
+static struct sk_buff *vxlan_na_create(struct sk_buff *request,
+	struct neighbour *n, bool isrouter)
+{
+	struct net_device *dev = request->dev;
+	struct sk_buff *reply = NULL;
+	struct nd_msg *ns, *na;
+	struct ipv6hdr *pip6;
+	u8 *daddr;
+	int olen = 8; /* opt hdr + ETH_ALEN for target */
+	int i, len;
+
+	if (dev == NULL)
+		return NULL;
+
+	ns = (struct nd_msg *)skb_transport_header(request);
+
+	len = LL_RESERVED_SPACE(dev) + sizeof(struct ipv6hdr) +
+		sizeof(*na) + olen + dev->needed_tailroom;
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
+	daddr = eth_hdr(request)->h_source;
+	olen = request->len - skb_transport_offset(request) - sizeof(*ns);
+	for (i = 0; i < olen-1; i += (ns->opt[i+1]<<3)) {
+		if (ns->opt[i] == ND_OPT_SOURCE_LL_ADDR) {
+			daddr = ns->opt + i + sizeof(struct nd_opt_hdr);
+			break;
+		}
+	}
+
+	/* Ethernet header */
+	memcpy(eth_hdr(reply)->h_dest, daddr, ETH_ALEN);
+	memcpy(eth_hdr(reply)->h_source, n->ha, ETH_ALEN);
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
+	olen = 8; /* ND_OPT_TARGET_LL_ADDR */
+	na = (struct nd_msg *)skb_put(reply, sizeof(*na) + olen);
+
+	/* Neighbor Advertisement */
+	memset(na, 0, sizeof(*na)+olen);
+	na->icmph.icmp6_type = NDISC_NEIGHBOUR_ADVERTISEMENT;
+	na->icmph.icmp6_router = isrouter;
+	na->icmph.icmp6_override = 1;
+	na->icmph.icmp6_solicited = 1;
+	na->target = ns->target;
+	memcpy(&na->opt[2], n->ha, ETH_ALEN);
+	na->opt[0] = ND_OPT_TARGET_LL_ADDR;
+	na->opt[1] = 1; /* 8 bytes */
+
+	na->icmph.icmp6_cksum = csum_ipv6_magic(&pip6->saddr,
+		&pip6->daddr, sizeof(*na)+olen, IPPROTO_ICMPV6, 
+		csum_partial(na, sizeof(*na)+olen, 0));
+
+	pip6->payload_len = htons(sizeof(*na)+olen);
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
+	struct neighbour *n;
 	struct inet6_dev *in6_dev = NULL;
 
 	in6_dev = __in6_dev_get(dev);
@@ -1357,8 +1445,7 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	saddr = &iphdr->saddr;
 	daddr = &iphdr->daddr;
 
-	if (ipv6_addr_loopback(daddr) ||
-	    ipv6_addr_is_multicast(daddr))
+	if (ipv6_addr_loopback(daddr))
 		goto out;
 
 	msg = (struct nd_msg *)skb_transport_header(skb);
@@ -1366,10 +1453,11 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
 	    msg->icmph.icmp6_type != NDISC_NEIGHBOUR_SOLICITATION)
 		goto out;
 
-	n = neigh_lookup(ipv6_stub->nd_tbl, daddr, dev);
+	n = neigh_lookup(ipv6_stub->nd_tbl, &msg->target, dev);
 
 	if (n) {
 		struct vxlan_fdb *f;
+		struct sk_buff *reply;
 
 		if (!(n->nud_state & NUD_CONNECTED)) {
 			neigh_release(n);
@@ -1383,13 +1471,23 @@ static int neigh_reduce(struct net_device *dev, struct sk_buff *skb)
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
 
