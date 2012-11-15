From: David L Stevens <dlstevens@us.ibm.com>
Subject: [PATCHv2 net-next] add DOVE extensions for VXLAN
Date: Thu, 15 Nov 2012 08:46:27 -0500
Message-ID: <201211151347.qAFDkR8G023134@lab1.dls>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:44192 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767865Ab2KONwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 08:52:14 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Thu, 15 Nov 2012 06:52:13 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 320FE19D804C
	for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 06:51:43 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qAFDpWr9208296
	for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 06:51:37 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qAFDpWVJ012088
	for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 06:51:32 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	This patch provides extensions to VXLAN for supporting Distributed
Overlay Virtual Ethernet (DOVE) networks. The patch includes:

	+ a dove flag per VXLAN device to enable DOVE extensions
	+ ARP reduction, whereby a bridge-connected VXLAN tunnel endpoint
		answers ARP requests from the local bridge on behalf of
		remote DOVE clients
	+ route short-circuiting (aka L3 switching). Known destination IP
		addresses use the corresponding destination MAC address for
		switching rather than going to a (possibly remote) router first.
	+ netlink notification messages for forwarding table and L3 switching
		misses

Changes since v1:
	- split "dove" flag into separate feature flags:
		- "proxy" for ARP reduction
		- "rsc" for route short circuiting
		- "l2miss" for L2 switch miss notifications
		- "l3miss" for L3 switch miss notifications

Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8aca888..6503091 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -29,6 +29,8 @@
 #include <linux/etherdevice.h>
 #include <linux/if_ether.h>
 #include <linux/hash.h>
+#include <net/arp.h>
+#include <net/ndisc.h>
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/udp.h>
@@ -111,6 +113,10 @@ struct vxlan_dev {
 	__u8		  tos;		/* TOS override */
 	__u8		  ttl;
 	bool		  learn;
+	bool		  proxy;	/* ARP reduction */
+	bool		  rsc;		/* route short-circuit */
+	bool		  l2miss;	/* L2 miss notifications */
+	bool		  l3miss;	/* L3 miss notifications */
 
 	unsigned long	  age_interval;
 	struct timer_list age_timer;
@@ -155,6 +161,7 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 	struct nda_cacheinfo ci;
 	struct nlmsghdr *nlh;
 	struct ndmsg *ndm;
+	bool send_ip, send_eth;
 
 	nlh = nlmsg_put(skb, portid, seq, type, sizeof(*ndm), flags);
 	if (nlh == NULL)
@@ -162,16 +169,28 @@ static int vxlan_fdb_info(struct sk_buff *skb, struct vxlan_dev *vxlan,
 
 	ndm = nlmsg_data(nlh);
 	memset(ndm, 0, sizeof(*ndm));
-	ndm->ndm_family	= AF_BRIDGE;
+
+	send_eth = send_ip = true;
+
+	if (type == RTM_GETNEIGH) {
+		int i;
+
+		ndm->ndm_family	= AF_INET;
+		send_ip = fdb->remote_ip != 0;
+		send_eth = 0;
+		for (i=0; i<ETH_ALEN; ++i)
+			send_eth |= !!fdb->eth_addr[i];
+	} else
+		ndm->ndm_family	= AF_BRIDGE;
 	ndm->ndm_state = fdb->state;
 	ndm->ndm_ifindex = vxlan->dev->ifindex;
 	ndm->ndm_flags = NTF_SELF;
 	ndm->ndm_type = NDA_DST;
 
-	if (nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
+	if (send_eth && nla_put(skb, NDA_LLADDR, ETH_ALEN, &fdb->eth_addr))
 		goto nla_put_failure;
 
-	if (nla_put_be32(skb, NDA_DST, fdb->remote_ip))
+	if (send_ip && nla_put_be32(skb, NDA_DST, fdb->remote_ip))
 		goto nla_put_failure;
 
 	ci.ndm_used	 = jiffies_to_clock_t(now - fdb->used);
@@ -223,6 +242,29 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
+static void vxlan_ip_miss(struct net_device *dev, __be32 ipa)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_fdb f;
+
+	memset(&f, 0, sizeof f);
+	f.state = NUD_STALE;
+	f.remote_ip = ipa; /* goes to NDA_DST */
+
+	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
+}
+
+static void vxlan_fdb_miss(struct vxlan_dev *vxlan, const u8 eth_addr[ETH_ALEN])
+{
+	struct vxlan_fdb	f;
+
+	memset(&f, 0, sizeof f);
+	f.state = NUD_STALE;
+	memcpy(f.eth_addr, eth_addr, ETH_ALEN);
+
+	vxlan_fdb_notify(vxlan, &f, RTM_GETNEIGH);
+}
+
 /* Hash Ethernet address */
 static u32 eth_hash(const unsigned char *addr)
 {
@@ -552,6 +594,8 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 	}
 
+	skb_reset_mac_header(skb);
+
 	/* Re-examine inner Ethernet packet */
 	oip = ip_hdr(skb);
 	skb->protocol = eth_type_trans(skb, vxlan->dev);
@@ -600,6 +644,117 @@ drop:
 	return 0;
 }
 
+static int arp_reduce(struct net_device *dev, struct sk_buff *skb)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct arphdr *parp;
+	u8 *arpptr, *sha;
+	__be32 sip, tip;
+	struct neighbour *n;
+
+	if (dev->flags & IFF_NOARP)
+		goto out;
+
+	if (!pskb_may_pull(skb, arp_hdr_len(dev))) {
+		dev->stats.tx_dropped++;
+		goto out;
+	}
+	parp = arp_hdr(skb);
+
+	if ((parp->ar_hrd != htons(ARPHRD_ETHER) &&
+	     parp->ar_hrd != htons(ARPHRD_IEEE802)) ||
+	    parp->ar_pro != htons(ETH_P_IP) ||
+	    parp->ar_op != htons(ARPOP_REQUEST) ||
+	    parp->ar_hln != dev->addr_len ||
+	    parp->ar_pln != 4)
+		goto out;
+	arpptr = (u8 *)parp + sizeof(struct arphdr);
+	sha = arpptr;
+	arpptr += dev->addr_len;	/* sha */
+	memcpy(&sip, arpptr, sizeof(sip));
+	arpptr += sizeof(sip);
+	arpptr += dev->addr_len;	/* tha */
+	memcpy(&tip, arpptr, sizeof(tip));
+
+	if (ipv4_is_loopback(tip) ||
+	    ipv4_is_multicast(tip))
+		goto out;
+
+	n = neigh_lookup(&arp_tbl, &tip, dev);
+
+	if (n) {
+		struct vxlan_dev *vxlan = netdev_priv(dev);
+		struct vxlan_fdb *f;
+		struct sk_buff	*reply;
+
+		if (!(n->nud_state & NUD_CONNECTED)) {
+			neigh_release(n);
+			goto out;
+		}
+
+		f = vxlan_find_mac(vxlan, n->ha);
+		if (f && f->remote_ip == 0) {
+			/* bridge-local neighbor */
+			neigh_release(n);
+			goto out;
+		}
+
+		reply = arp_create(ARPOP_REPLY, ETH_P_ARP, sip, dev, tip, sha,
+				n->ha, sha);
+
+		neigh_release(n);
+
+		skb_reset_mac_header(reply);
+		__skb_pull(reply, skb_network_offset(reply));
+		reply->ip_summed = CHECKSUM_UNNECESSARY;
+		reply->pkt_type = PACKET_HOST;
+
+		if (netif_rx_ni(reply) == NET_RX_DROP)
+			dev->stats.rx_dropped++;
+	} else if (vxlan->l3miss)
+		vxlan_ip_miss(dev, tip);
+out:
+	consume_skb(skb);
+	return NETDEV_TX_OK;
+}
+
+static bool route_shortcircuit(struct net_device *dev, struct sk_buff *skb)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct neighbour *n;
+	struct iphdr *pip;
+
+	if (is_multicast_ether_addr(eth_hdr(skb)->h_dest))
+		return false;
+
+	n = NULL;
+	switch (ntohs(eth_hdr(skb)->h_proto)) {
+	case ETH_P_IP:
+		if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+			return false;
+		pip = ip_hdr(skb);
+		n = neigh_lookup(&arp_tbl, &pip->daddr, dev);
+		break;
+	default:
+		return false;
+	}
+
+	if (n) {
+		bool diff;
+
+		diff = compare_ether_addr(eth_hdr(skb)->h_dest, n->ha) != 0;
+		if (diff) {
+			memcpy(eth_hdr(skb)->h_source, eth_hdr(skb)->h_dest,
+				dev->addr_len);
+			memcpy(eth_hdr(skb)->h_dest, n->ha, dev->addr_len);
+		}
+		neigh_release(n);
+		return diff;
+	} else if (vxlan->l3miss)
+		vxlan_ip_miss(dev, pip->daddr);
+	return false;
+}
+
 /* Extract dsfield from inner protocol */
 static inline u8 vxlan_get_dsfield(const struct iphdr *iph,
 				   const struct sk_buff *skb)
@@ -622,22 +777,6 @@ static inline u8 vxlan_ecn_encap(u8 tos,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
-static __be32 vxlan_find_dst(struct vxlan_dev *vxlan, struct sk_buff *skb)
-{
-	const struct ethhdr *eth = (struct ethhdr *) skb->data;
-	const struct vxlan_fdb *f;
-
-	if (is_multicast_ether_addr(eth->h_dest))
-		return vxlan->gaddr;
-
-	f = vxlan_find_mac(vxlan, eth->h_dest);
-	if (f)
-		return f->remote_ip;
-	else
-		return vxlan->gaddr;
-
-}
-
 static void vxlan_sock_free(struct sk_buff *skb)
 {
 	sock_put(skb->sk);
@@ -684,6 +823,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct rtable *rt;
 	const struct iphdr *old_iph;
+	struct ethhdr *eth;
 	struct iphdr *iph;
 	struct vxlanhdr *vxh;
 	struct udphdr *uh;
@@ -694,10 +834,50 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
+	bool rsc = false;
+	const struct vxlan_fdb *f;
+
+	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
+
+	if (vxlan->proxy && ntohs(eth->h_proto) == ETH_P_ARP)
+		return arp_reduce(dev, skb);
+	else if (vxlan->rsc && ntohs(eth->h_proto) == ETH_P_IP)
+		rsc = route_shortcircuit(dev, skb);
 
-	dst = vxlan_find_dst(vxlan, skb);
-	if (!dst)
+	f = vxlan_find_mac(vxlan, eth->h_dest);
+	if (f == NULL) {
+		rsc = false;
+		dst = vxlan->gaddr;
+		if (!dst && vxlan->l2miss &&
+		    !is_multicast_ether_addr(eth->h_dest))
+			vxlan_fdb_miss(vxlan, eth->h_dest);
+	} else
+		dst = f->remote_ip;
+
+	if (!dst) {
+		if (rsc) {
+			__skb_pull(skb, skb_network_offset(skb));
+			skb->ip_summed = CHECKSUM_NONE;
+			skb->pkt_type = PACKET_HOST;
+
+			/* short-circuited back to local bridge */
+			if (netif_rx(skb) == NET_RX_SUCCESS) {
+				struct vxlan_stats *stats =
+						this_cpu_ptr(vxlan->stats);
+		
+				u64_stats_update_begin(&stats->syncp);
+				stats->tx_packets++;
+				stats->tx_bytes += pkt_len;
+				u64_stats_update_end(&stats->syncp);
+			} else {
+				dev->stats.tx_errors++;
+				dev->stats.tx_aborted_errors++;
+			}
+			return NETDEV_TX_OK;
+		}
 		goto drop;
+	}
 
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
@@ -1020,6 +1200,10 @@ static const struct nla_policy vxlan_policy[IFLA_VXLAN_MAX + 1] = {
 	[IFLA_VXLAN_AGEING]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_LIMIT]	= { .type = NLA_U32 },
 	[IFLA_VXLAN_PORT_RANGE] = { .len  = sizeof(struct ifla_vxlan_port_range) },
+	[IFLA_VXLAN_PROXY]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_RSC]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_L2MISS]	= { .type = NLA_U8 },
+	[IFLA_VXLAN_L3MISS]	= { .type = NLA_U8 },
 };
 
 static int vxlan_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1118,6 +1302,18 @@ static int vxlan_newlink(struct net *net, struct net_device *dev,
 	else
 		vxlan->age_interval = FDB_AGE_DEFAULT;
 
+	if (data[IFLA_VXLAN_PROXY] && nla_get_u8(data[IFLA_VXLAN_PROXY]))
+		vxlan->proxy = true;
+
+	if (data[IFLA_VXLAN_RSC] && nla_get_u8(data[IFLA_VXLAN_RSC]))
+		vxlan->rsc = true;
+
+	if (data[IFLA_VXLAN_L2MISS] && nla_get_u8(data[IFLA_VXLAN_L2MISS]))
+		vxlan->l2miss = true;
+
+	if (data[IFLA_VXLAN_L3MISS] && nla_get_u8(data[IFLA_VXLAN_L3MISS]))
+		vxlan->l3miss = true;
+
 	if (data[IFLA_VXLAN_LIMIT])
 		vxlan->addrmax = nla_get_u32(data[IFLA_VXLAN_LIMIT]);
 
@@ -1154,6 +1350,7 @@ static size_t vxlan_get_size(const struct net_device *dev)
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TTL */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_TOS */
 		nla_total_size(sizeof(__u8)) +	/* IFLA_VXLAN_LEARNING */
+		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_DOVE */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_AGEING */
 		nla_total_size(sizeof(__u32)) +	/* IFLA_VXLAN_LIMIT */
 		nla_total_size(sizeof(struct ifla_vxlan_port_range)) +
@@ -1183,6 +1380,10 @@ static int vxlan_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u8(skb, IFLA_VXLAN_TTL, vxlan->ttl) ||
 	    nla_put_u8(skb, IFLA_VXLAN_TOS, vxlan->tos) ||
 	    nla_put_u8(skb, IFLA_VXLAN_LEARNING, vxlan->learn) ||
+	    nla_put_u8(skb, IFLA_VXLAN_PROXY, vxlan->proxy) ||
+	    nla_put_u8(skb, IFLA_VXLAN_RSC, vxlan->rsc) ||
+	    nla_put_u8(skb, IFLA_VXLAN_L2MISS, vxlan->l2miss) ||
+	    nla_put_u8(skb, IFLA_VXLAN_L3MISS, vxlan->l3miss) ||
 	    nla_put_u32(skb, IFLA_VXLAN_AGEING, vxlan->age_interval) ||
 	    nla_put_u32(skb, IFLA_VXLAN_LIMIT, vxlan->addrmax))
 		goto nla_put_failure;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5c80cb1..89695ff 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -285,6 +285,10 @@ enum {
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
 	IFLA_VXLAN_PORT_RANGE,
+	IFLA_VXLAN_PROXY,
+	IFLA_VXLAN_RSC,
+	IFLA_VXLAN_L2MISS,
+	IFLA_VXLAN_L3MISS,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
