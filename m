From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next-2.6 3/3 (TAKE 3)] bridge br_multicast: IPv6 MLD support.
Date: Thu, 8 Apr 2010 14:52:30 +0900
Message-ID: <201004080611.o386BbdW015020@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:60042 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756299Ab0DHGLm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 02:11:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/bridge/Kconfig        |    6 +-
 net/bridge/br_multicast.c |  419 ++++++++++++++++++++++++++++++++++++++++++++-
 net/bridge/br_private.h   |    3 +
 3 files changed, 424 insertions(+), 4 deletions(-)

diff --git a/net/bridge/Kconfig b/net/bridge/Kconfig
index d115d5c..9190ae4 100644
--- a/net/bridge/Kconfig
+++ b/net/bridge/Kconfig
@@ -33,14 +33,14 @@ config BRIDGE
 	  If unsure, say N.
 
 config BRIDGE_IGMP_SNOOPING
-	bool "IGMP snooping"
+	bool "IGMP/MLD snooping"
 	depends on BRIDGE
 	depends on INET
 	default y
 	---help---
 	  If you say Y here, then the Ethernet bridge will be able selectively
-	  forward multicast traffic based on IGMP traffic received from each
-	  port.
+	  forward multicast traffic based on IGMP/MLD traffic received from
+	  each port.
 
 	  Say N to exclude this support and reduce the binary size.
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 8e98546..db0de7a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -24,9 +24,18 @@
 #include <linux/slab.h>
 #include <linux/timer.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
+#include <net/mld.h>
 
 #include "br_private.h"
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int ipv6_addr_is_mc_linklocal(const struct in6_addr *addr)
+{
+	return addr->s6_addr16[0] == htons(0xff02);
+}
+#endif
+
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 {
 	if (a->proto != b->proto)
@@ -34,6 +43,10 @@ static inline int br_ip_equal(const struct br_ip *a, const struct br_ip *b)
 	switch (a->proto) {
 	case htons(ETH_P_IP):
 		return a->u.ip4 == b->u.ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return ipv6_addr_equal(&a->u.ip6, &b->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -43,12 +56,24 @@ static inline int __br_ip4_hash(struct net_bridge_mdb_htable *mdb, __be32 ip)
 	return jhash_1word(mdb->secret, (u32)ip) & (mdb->max - 1);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static inline int __br_ip6_hash(struct net_bridge_mdb_htable *mdb,
+				const struct in6_addr *ip)
+{
+	return jhash2(ip->s6_addr32, 4, mdb->secret) & (mdb->max - 1);
+}
+#endif
+
 static inline int br_ip_hash(struct net_bridge_mdb_htable *mdb,
 			     struct br_ip *ip)
 {
 	switch (ip->proto) {
 	case htons(ETH_P_IP):
 		return __br_ip4_hash(mdb, ip->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return __br_ip6_hash(mdb, &ip->u.ip6);
+#endif
 	}
 	return 0;
 }
@@ -78,6 +103,19 @@ static struct net_bridge_mdb_entry *br_mdb_ip4_get(
 	return __br_mdb_ip_get(mdb, &br_dst, __br_ip4_hash(mdb, dst));
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct net_bridge_mdb_entry *br_mdb_ip6_get(
+	struct net_bridge_mdb_htable *mdb, const struct in6_addr *dst)
+{
+	struct br_ip br_dst;
+
+	ipv6_addr_copy(&br_dst.u.ip6, dst);
+	br_dst.proto = htons(ETH_P_IPV6);
+
+	return __br_mdb_ip_get(mdb, &br_dst, __br_ip6_hash(mdb, dst));
+}
+#endif
+
 static struct net_bridge_mdb_entry *br_mdb_ip_get(
 	struct net_bridge_mdb_htable *mdb, struct br_ip *dst)
 {
@@ -102,6 +140,11 @@ struct net_bridge_mdb_entry *br_mdb_get(struct net_bridge *br,
 	case htons(ETH_P_IP):
 		ip.u.ip4 = ip_hdr(skb)->daddr;
 		break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		ipv6_addr_copy(&ip.u.ip6, &ipv6_hdr(skb)->daddr);
+		break;
+#endif
 	default:
 		return NULL;
 	}
@@ -352,12 +395,95 @@ out:
 	return skb;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static struct sk_buff *br_ip6_multicast_alloc_query(struct net_bridge *br,
+						    struct in6_addr *group)
+{
+	struct sk_buff *skb;
+	struct ipv6hdr *ip6h;
+	struct mld_msg *mldq;
+	struct ethhdr *eth;
+	u8 *hopopt;
+	unsigned long interval;
+
+	skb = netdev_alloc_skb_ip_align(br->dev, sizeof(*eth) + sizeof(*ip6h) +
+						 8 + sizeof(*mldq));
+	if (!skb)
+		goto out;
+
+	skb->protocol = htons(ETH_P_IPV6);
+
+	/* Ethernet header */
+	skb_reset_mac_header(skb);
+	eth = eth_hdr(skb);
+
+	memcpy(eth->h_source, br->dev->dev_addr, 6);
+	ipv6_eth_mc_map(group, eth->h_dest);
+	eth->h_proto = htons(ETH_P_IPV6);
+	skb_put(skb, sizeof(*eth));
+
+	/* IPv6 header + HbH option */
+	skb_set_network_header(skb, skb->len);
+	ip6h = ipv6_hdr(skb);
+
+	*(__force __be32 *)ip6h = htonl(0x60000000);
+	ip6h->payload_len = 8 + sizeof(*mldq);
+	ip6h->nexthdr = IPPROTO_HOPOPTS;
+	ip6h->hop_limit = 1;
+	ipv6_addr_copy(&ip6h->saddr, &in6addr_any);
+	ipv6_addr_copy(&ip6h->daddr, &in6addr_linklocal_allnodes);
+	ipv6_addr_copy(&ip6h->daddr, group);
+
+	hopopt = (u8 *)(ip6h + 1);
+	hopopt[0] = IPPROTO_ICMPV6;		/* next hdr */
+	hopopt[1] = 0;				/* length of HbH */
+	hopopt[2] = IPV6_TLV_ROUTERALERT;	/* Router Alert */
+	hopopt[3] = 2;				/* Length of RA Option */
+	hopopt[4] = 0;				/* Type = 0x0000 (MLD) */
+	hopopt[5] = 0;
+	hopopt[6] = IPV6_TLV_PAD0;		/* Pad0 */
+	hopopt[7] = IPV6_TLV_PAD0;		/* Pad0 */
+
+	skb_put(skb, sizeof(*ip6h) + 8);
+
+	/* ICMPv6 */
+	skb_set_transport_header(skb, skb->len);
+	mldq = (struct mld_msg *) icmp6_hdr(skb);
+
+	interval = ipv6_addr_any(group) ? br->multicast_last_member_interval :
+					  br->multicast_query_response_interval;
+
+	mldq->mld_type = ICMPV6_MGM_QUERY;
+	mldq->mld_code = 0;
+	mldq->mld_cksum = 0;
+	mldq->mld_maxdelay = htons((u16)jiffies_to_msecs(interval));
+	mldq->mld_reserved = 0;
+	ipv6_addr_copy(&mldq->mld_mca, group);
+
+	/* checksum */
+	mldq->mld_cksum = csum_ipv6_magic(&in6addr_any, group,
+					  sizeof(*mldq), IPPROTO_ICMPV6,
+					  csum_partial(mldq,
+						       sizeof(*mldq), 0));
+	skb_put(skb, sizeof(*mldq));
+
+	__skb_pull(skb, sizeof(*eth));
+
+out:
+	return skb;
+}
+#endif
+
 static struct sk_buff *br_multicast_alloc_query(struct net_bridge *br,
 						struct br_ip *addr)
 {
 	switch (addr->proto) {
 	case htons(ETH_P_IP):
 		return br_ip4_multicast_alloc_query(br, addr->u.ip4);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_ip6_multicast_alloc_query(br, &addr->u.ip6);
+#endif
 	}
 	return NULL;
 }
@@ -631,6 +757,23 @@ static int br_ip4_multicast_add_group(struct net_bridge *br,
 	return br_multicast_add_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_add_group(struct net_bridge *br,
+				      struct net_bridge_port *port,
+				      const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_addr_is_mc_linklocal(group))
+		return 0;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IP);
+
+	return br_multicast_add_group(br, port, &br_group);
+}
+#endif
+
 static void br_multicast_router_expired(unsigned long data)
 {
 	struct net_bridge_port *port = (void *)data;
@@ -681,10 +824,15 @@ static void br_multicast_send_query(struct net_bridge *br,
 	    timer_pending(&br->multicast_querier_timer))
 		return;
 
-	br_group.u.ip4 = 0;
+	memset(&br_group.u, 0, sizeof(br_group.u));
+
 	br_group.proto = htons(ETH_P_IP);
+	__br_multicast_send_query(br, port, &br_group);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	br_group.proto = htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
+#endif
 
 	time = jiffies;
 	time += sent < br->multicast_startup_query_count ?
@@ -825,6 +973,66 @@ static int br_ip4_multicast_igmp3_report(struct net_bridge *br,
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_mld2_report(struct net_bridge *br,
+					struct net_bridge_port *port,
+					struct sk_buff *skb)
+{
+	struct icmp6hdr *icmp6h;
+	struct mld2_grec *grec;
+	int i;
+	int len;
+	int num;
+	int err = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*icmp6h)))
+		return -EINVAL;
+
+	icmp6h = icmp6_hdr(skb);
+	num = ntohs(icmp6h->icmp6_dataun.un_data16[1]);
+	len = sizeof(*icmp6h);
+
+	for (i = 0; i < num; i++) {
+		__be16 *nsrcs, _nsrcs;
+
+		nsrcs = skb_header_pointer(skb,
+					   len + offsetof(struct mld2_grec,
+							  grec_mca),
+					   sizeof(_nsrcs), &_nsrcs);
+		if (!nsrcs)
+			return -EINVAL;
+
+		if (!pskb_may_pull(skb,
+				   len + sizeof(*grec) +
+				   sizeof(struct in6_addr) * (*nsrcs)))
+			return -EINVAL;
+
+		grec = (struct mld2_grec *)(skb->data + len);
+		len += sizeof(*grec) + sizeof(struct in6_addr) * (*nsrcs);
+
+		/* We treat these as MLDv1 reports for now. */
+		switch (grec->grec_type) {
+		case MLD2_MODE_IS_INCLUDE:
+		case MLD2_MODE_IS_EXCLUDE:
+		case MLD2_CHANGE_TO_INCLUDE:
+		case MLD2_CHANGE_TO_EXCLUDE:
+		case MLD2_ALLOW_NEW_SOURCES:
+		case MLD2_BLOCK_OLD_SOURCES:
+			break;
+
+		default:
+			continue;
+		}
+
+		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca);
+		if (!err)
+			break;
+	}
+
+	return err;
+}
+#endif
+
 static void br_multicast_add_router(struct net_bridge *br,
 				    struct net_bridge_port *port)
 {
@@ -955,6 +1163,75 @@ out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_ip6_multicast_query(struct net_bridge *br,
+				  struct net_bridge_port *port,
+				  struct sk_buff *skb)
+{
+	struct ipv6hdr *ip6h = ipv6_hdr(skb);
+	struct mld_msg *mld = (struct mld_msg *) icmp6_hdr(skb);
+	struct net_bridge_mdb_entry *mp;
+	struct mld2_query *mld2q;
+	struct net_bridge_port_group *p, **pp;
+	unsigned long max_delay;
+	unsigned long now = jiffies;
+	struct in6_addr *group = NULL;
+	int err = 0;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) ||
+	    (port && port->state == BR_STATE_DISABLED))
+		goto out;
+
+	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr));
+
+	if (skb->len == sizeof(*mld)) {
+		if (!pskb_may_pull(skb, sizeof(*mld))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld = (struct mld_msg *) icmp6_hdr(skb);
+		max_delay = msecs_to_jiffies(htons(mld->mld_maxdelay));
+		if (max_delay)
+			group = &mld->mld_mca;
+	} else if (skb->len >= sizeof(*mld2q)) {
+		if (!pskb_may_pull(skb, sizeof(*mld2q))) {
+			err = -EINVAL;
+			goto out;
+		}
+		mld2q = (struct mld2_query *)icmp6_hdr(skb);
+		if (!mld2q->mld2q_nsrcs)
+			group = &mld2q->mld2q_mca;
+		max_delay = mld2q->mld2q_mrc ? MLDV2_MRC(mld2q->mld2q_mrc) : 1;
+	}
+
+	if (!group)
+		goto out;
+
+	mp = br_mdb_ip6_get(br->mdb, group);
+	if (!mp)
+		goto out;
+
+	max_delay *= br->multicast_last_member_count;
+	if (!hlist_unhashed(&mp->mglist) &&
+	    (timer_pending(&mp->timer) ?
+	     time_after(mp->timer.expires, now + max_delay) :
+	     try_to_del_timer_sync(&mp->timer) >= 0))
+		mod_timer(&mp->timer, now + max_delay);
+
+	for (pp = &mp->ports; (p = *pp); pp = &p->next) {
+		if (timer_pending(&p->timer) ?
+		    time_after(p->timer.expires, now + max_delay) :
+		    try_to_del_timer_sync(&p->timer) >= 0)
+			mod_timer(&mp->timer, now + max_delay);
+	}
+
+out:
+	spin_unlock(&br->multicast_lock);
+	return err;
+}
+#endif
+
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
 				     struct br_ip *group)
@@ -1030,6 +1307,22 @@ static void br_ip4_multicast_leave_group(struct net_bridge *br,
 	br_multicast_leave_group(br, port, &br_group);
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static void br_ip6_multicast_leave_group(struct net_bridge *br,
+					 struct net_bridge_port *port,
+					 const struct in6_addr *group)
+{
+	struct br_ip br_group;
+
+	if (ipv6_addr_is_mc_linklocal(group))
+		return;
+
+	ipv6_addr_copy(&br_group.u.ip6, group);
+	br_group.proto = htons(ETH_P_IPV6);
+
+	br_multicast_leave_group(br, port, &br_group);
+}
+#endif
 
 static int br_multicast_ipv4_rcv(struct net_bridge *br,
 				 struct net_bridge_port *port,
@@ -1129,6 +1422,126 @@ err_out:
 	return err;
 }
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+static int br_multicast_ipv6_rcv(struct net_bridge *br,
+				 struct net_bridge_port *port,
+				 struct sk_buff *skb)
+{
+	struct sk_buff *skb2 = skb;
+	struct ipv6hdr *ip6h;
+	struct icmp6hdr *icmp6h;
+	u8 nexthdr;
+	unsigned len;
+	unsigned offset;
+	int err;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 0;
+	BR_INPUT_SKB_CB(skb)->mrouters_only = 0;
+
+	if (!pskb_may_pull(skb, sizeof(*ip6h)))
+		return -EINVAL;
+
+	ip6h = ipv6_hdr(skb);
+
+	/*
+	 * We're interested in MLD messages only.
+	 *  - Version is 6
+	 *  - MLD has always Router Alert hop-by-hop option
+	 *  - But we do not support jumbrograms.
+	 */
+	if (ip6h->version != 6 ||
+	    ip6h->nexthdr != IPPROTO_HOPOPTS ||
+	    ip6h->payload_len == 0)
+		return 0;
+
+	len = ntohs(ip6h->payload_len);
+	if (skb->len < len)
+		return -EINVAL;
+
+	nexthdr = ip6h->nexthdr;
+	offset = ipv6_skip_exthdr(skb, sizeof(*ip6h), &nexthdr);
+
+	if (offset < 0 || nexthdr != IPPROTO_ICMPV6)
+		return 0;
+
+	/* Okay, we found ICMPv6 header */
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (!skb2)
+		return -ENOMEM;
+
+	len -= offset - skb_network_offset(skb2);
+
+	__skb_pull(skb2, offset);
+	skb_reset_transport_header(skb2);
+
+	err = -EINVAL;
+	if (!pskb_may_pull(skb2, sizeof(*icmp6h)))
+		goto out;
+
+	icmp6h = icmp6_hdr(skb2);
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_QUERY:
+	case ICMPV6_MGM_REPORT:
+	case ICMPV6_MGM_REDUCTION:
+	case ICMPV6_MLD2_REPORT:
+		break;
+	default:
+		err = 0;
+		goto out;
+	}
+
+	/* Okay, we found MLD message. Check further. */
+	if (skb2->len > len) {
+		err = pskb_trim_rcsum(skb2, len);
+		if (err)
+			goto out;
+	}
+
+	switch (skb2->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		if (!csum_fold(skb2->csum))
+			break;
+		/*FALLTHROUGH*/
+	case CHECKSUM_NONE:
+		skb2->csum = 0;
+		if (skb_checksum_complete(skb2))
+			goto out;
+	}
+
+	err = 0;
+
+	BR_INPUT_SKB_CB(skb)->igmp = 1;
+
+	switch (icmp6h->icmp6_type) {
+	case ICMPV6_MGM_REPORT:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		BR_INPUT_SKB_CB(skb2)->mrouters_only = 1;
+		err = br_ip6_multicast_add_group(br, port, &mld->mld_mca);
+		break;
+	    }
+	case ICMPV6_MLD2_REPORT:
+		err = br_ip6_multicast_mld2_report(br, port, skb2);
+		break;
+	case ICMPV6_MGM_QUERY:
+		err = br_ip6_multicast_query(br, port, skb2);
+		break;
+	case ICMPV6_MGM_REDUCTION:
+	    {
+		struct mld_msg *mld = (struct mld_msg *)icmp6h;
+		br_ip6_multicast_leave_group(br, port, &mld->mld_mca);
+	    }
+	}
+
+out:
+	__skb_push(skb2, offset);
+	if (skb2 != skb)
+		kfree_skb(skb2);
+	return err;
+}
+#endif
+
 int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 		     struct sk_buff *skb)
 {
@@ -1138,6 +1551,10 @@ int br_multicast_rcv(struct net_bridge *br, struct net_bridge_port *port,
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		return br_multicast_ipv4_rcv(br, port, skb);
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+	case htons(ETH_P_IPV6):
+		return br_multicast_ipv6_rcv(br, port, skb);
+#endif
 	}
 
 	return 0;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b55de82..da37715 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -49,6 +49,9 @@ struct br_ip
 {
 	union {
 		__be32	ip4;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		struct in6_addr ip6;
+#endif
 	} u;
 	__be16		proto;
 };
-- 
1.5.6.5

