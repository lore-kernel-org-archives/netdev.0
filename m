From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH, RFC] Add bridged IPv6 packet filtering
Date: Sat, 28 Aug 2004 17:13:29 +0200
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <200408281713.29192.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>,
	netfilter-devel <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S.Miller <davem@redhat.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Hello,

The patch below adds bridged IPv6 packet filtering.

One thing I was unclear of what to do: before giving an IPv6 packet to
ip6tables the IPv6 sanity checks are done (copied from ipv6_rcv()).
These checks include this code snippet:

if (hdr->nexthdr == NEXTHDR_HOP) {
	skb->h.raw = (u8*)(hdr+1);
	if (ipv6_parse_hopopts(skb, offsetof(struct ipv6hdr, nexthdr)) < 0) {
		IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
		return 0;
	}
	hdr = skb->nh.ipv6h;
}

If it's necessary to call ipv6_parse_hopopts() then this function will need
to be exported. Note that we only need ip6tables to behave correctly. So,
is this function call needed to let ip6tables behave properly?
Also, what happens if skb->h.raw = (u8*)(hdr+1); is executed once
inside the bridge-nf code and later all the IPv6 checks are done again
in ipv6_rcv() ? This can happen if the IPv6 packet is destined for the
bridge box or if it's used as a router too.

In short, I'd like to know which IPv6 sanity checks are absolutely
necessary for ip6tables and if there are any implications if those checks
are done twice.

This patch has been tested by Scott MacKay <scottmackay@yahoo.com>.

cheers,
Bart

--- linux-2.6.8.1/include/linux/netfilter_ipv6.h.old	Sun Aug 22 18:49:47 2004
+++ linux-2.6.8.1/include/linux/netfilter_ipv6.h	Sun Aug 22 18:53:56 2004
@@ -58,8 +58,10 @@ enum nf_ip6_hook_priorities {
 	NF_IP6_PRI_FIRST = INT_MIN,
 	NF_IP6_PRI_SELINUX_FIRST = -225,
 	NF_IP6_PRI_CONNTRACK = -200,
+	NF_IP6_PRI_BRIDGE_SABOTAGE_FORWARD = -175,
 	NF_IP6_PRI_MANGLE = -150,
 	NF_IP6_PRI_NAT_DST = -100,
+	NF_IP6_PRI_BRIDGE_SABOTAGE_LOCAL_OUT = -50,
 	NF_IP6_PRI_FILTER = 0,
 	NF_IP6_PRI_NAT_SRC = 100,
 	NF_IP6_PRI_SELINUX_LAST = 225,
--- linux-2.6.8.1/net/bridge/br_netfilter.c.old	Sun Aug 22 18:49:39 2004
+++ linux-2.6.8.1/net/bridge/br_netfilter.c	Sun Aug 22 20:12:48 2004
@@ -11,6 +11,7 @@
  *	Jun 19 2003: let arptables see bridged ARP traffic (bdschuym)
  *	Oct 06 2003: filter encapsulated IP/ARP VLAN traffic on untagged bridge
  *	             (bdschuym)
+ *	Aug 28 2004: add IPv6 filtering (bdschuym)
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -29,9 +30,11 @@
 #include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
+#include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_arp.h>
 #include <linux/in_route.h>
 #include <net/ip.h>
+#include <net/ipv6.h>
 #include <asm/uaccess.h>
 #include <asm/checksum.h>
 #include "br_private.h"
@@ -39,7 +42,6 @@
 #include <linux/sysctl.h>
 #endif
 
-
 #define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
 				 (skb->nf_bridge->data))->daddr.ipv4)
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = (skb)->nh.iph->daddr)
@@ -51,6 +53,7 @@
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables = 1;
+static int brnf_call_ip6tables = 1;
 static int brnf_call_arptables = 1;
 static int brnf_filter_vlan_tagged = 1;
 #else
@@ -60,6 +63,9 @@ static int brnf_filter_vlan_tagged = 1;
 #define IS_VLAN_IP (skb->protocol == __constant_htons(ETH_P_8021Q) &&    \
 	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP) &&  \
 	brnf_filter_vlan_tagged)
+#define IS_VLAN_IPV6 (skb->protocol == __constant_htons(ETH_P_8021Q) &&    \
+	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_IPV6) &&  \
+	brnf_filter_vlan_tagged)
 #define IS_VLAN_ARP (skb->protocol == __constant_htons(ETH_P_8021Q) &&   \
 	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_ARP) && \
 	brnf_filter_vlan_tagged)
@@ -71,8 +77,7 @@ static int brnf_filter_vlan_tagged = 1;
  * Currently, we fill in the PMTU entry because netfilter
  * refragmentation needs it, and the rt_flags entry because
  * ipt_REJECT needs it.  Future netfilter modules might
- * require us to fill additional fields.
- */
+ * require us to fill additional fields. */
 static struct net_device __fake_net_device = {
 	.hard_header_len	= ETH_HLEN
 };
@@ -91,6 +96,36 @@ static struct rtable __fake_rtable = {
 
 
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
+/* Undo the changes made for ip6tables PREROUTING and continue the
+ * bridge PRE_ROUTING hook. */
+static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug ^= (1 << NF_BR_PRE_ROUTING);
+#endif
+
+	if (nf_bridge->mask & BRNF_PKT_TYPE) {
+		skb->pkt_type = PACKET_OTHERHOST;
+		nf_bridge->mask ^= BRNF_PKT_TYPE;
+	}
+	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
+
+	skb->dst = (struct dst_entry *)&__fake_rtable;
+	dst_hold(skb->dst);
+
+	skb->dev = nf_bridge->physindev;
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_push(skb, VLAN_HLEN);
+		skb->nh.raw -= VLAN_HLEN;
+	}
+	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+		       br_handle_frame_finish, 1);
+
+	return 0;
+}
+
 static void __br_dnat_complain(void)
 {
 	static unsigned long last_complaint;
@@ -102,7 +137,6 @@ static void __br_dnat_complain(void)
 	}
 }
 
-
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address,
  * and this is a tricky process.
@@ -145,9 +179,7 @@ static void __br_dnat_complain(void)
  *
  * --Lennert, 20020411
  * --Bart, 20020416 (updated)
- * --Bart, 20021007 (updated)
- */
-
+ * --Bart, 20021007 (updated) */
 static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 {
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -195,8 +227,7 @@ static int br_nf_pre_routing_finish(stru
 
 			if (!ip_route_output_key(&rt, &fl)) {
 				/* Bridged-and-DNAT'ed traffic doesn't
-				 * require ip_forwarding.
-				 */
+				 * require ip_forwarding. */
 				if (((struct dst_entry *)rt)->dev == dev) {
 					skb->dst = (struct dst_entry *)rt;
 					goto bridged_dnat;
@@ -210,8 +241,7 @@ static int br_nf_pre_routing_finish(stru
 			if (skb->dst->dev == dev) {
 bridged_dnat:
 				/* Tell br_nf_local_out this is a
-				 * bridged frame
-				 */
+				 * bridged frame */
 				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
 				if (skb->protocol ==
@@ -245,12 +275,80 @@ bridged_dnat:
 	return 0;
 }
 
-/* Replicate the checks that IPv4 does on packet reception.
+/* Some common code for IPv4/IPv6 */
+static void setup_pre_routing(struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+
+	if (skb->pkt_type == PACKET_OTHERHOST) {
+		skb->pkt_type = PACKET_HOST;
+		nf_bridge->mask |= BRNF_PKT_TYPE;
+	}
+
+	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
+	nf_bridge->physindev = skb->dev;
+	skb->dev = bridge_parent(skb->dev);
+}
+
+/* Replicate the checks that IPv6 does on packet reception and pass the packet
+ * to ip6tables, which doesn't support NAT, so things are fairly simple. */
+static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
+   struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	struct ipv6hdr *hdr;
+	u32 pkt_len;
+	struct nf_bridge_info *nf_bridge;
+
+	if (skb->len < sizeof(struct ipv6hdr))
+		goto inhdr_error;
+
+	if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+		goto inhdr_error;
+
+	hdr = skb->nh.ipv6h;
+
+	if (hdr->version != 6)
+		goto inhdr_error;
+
+	pkt_len = ntohs(hdr->payload_len);
+
+	if (pkt_len || hdr->nexthdr != NEXTHDR_HOP) {
+		if (pkt_len + sizeof(struct ipv6hdr) > skb->len)
+			goto inhdr_error;
+		if (pkt_len + sizeof(struct ipv6hdr) < skb->len &&
+		    __pskb_trim(skb, pkt_len + sizeof(struct ipv6hdr)))
+			goto inhdr_error;
+	}
+#if 0
+	if (hdr->nexthdr == NEXTHDR_HOP) {
+		skb->h.raw = (u8*)(hdr+1);
+		if (ipv6_parse_hopopts(skb, offsetof(struct ipv6hdr, nexthdr))<0)
+			goto inhdr_error;
+	}
+#endif
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug ^= (1 << NF_IP6_PRE_ROUTING);
+#endif
+	if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
+		return NF_DROP;
+	setup_pre_routing(skb);
+
+	NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
+		br_nf_pre_routing_finish_ipv6);
+
+	return NF_STOLEN;
+
+inhdr_error:
+	return NF_DROP;
+}
+
+/* Direct IPv6 traffic to br_nf_pre_routing_ipv6.
+ * Replicate the checks that IPv4 does on packet reception.
  * Set skb->dev to the bridge device (i.e. parent of the
  * receiving device) to make netfilter happy, the REDIRECT
  * target in particular.  Save the original destination IP
- * address to be able to detect DNAT afterwards.
- */
+ * address to be able to detect DNAT afterwards. */
 static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
@@ -259,25 +357,39 @@ static unsigned int br_nf_pre_routing(un
 	__u32 len;
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)
+				   ((*pskb)->mac.ethernet);
 
+	if (skb->protocol == __constant_htons(ETH_P_IPV6) || IS_VLAN_IPV6) {
+#ifdef CONFIG_SYSCTL
+		if (!brnf_call_ip6tables)
+			return NF_ACCEPT;
+#endif
+		if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
+			goto out;
+
+		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			skb_pull(skb, VLAN_HLEN);
+			(skb)->nh.raw += VLAN_HLEN;
+		}
+		return br_nf_pre_routing_ipv6(hook, skb, in, out, okfn);
+	}
 #ifdef CONFIG_SYSCTL
 	if (!brnf_call_iptables)
 		return NF_ACCEPT;
 #endif
 
-	if (skb->protocol != __constant_htons(ETH_P_IP)) {
-		struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)
-					  ((*pskb)->mac.ethernet);
+	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
+		return NF_ACCEPT;
 
-		if (!IS_VLAN_IP)
-			return NF_ACCEPT;
-		if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
-			goto out;
-		skb_pull(*pskb, VLAN_HLEN);
-		(*pskb)->nh.raw += VLAN_HLEN;
-	} else if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
+	if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
 		goto out;
 
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_pull(skb, VLAN_HLEN);
+		(skb)->nh.raw += VLAN_HLEN;
+	}
+
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto inhdr_error;
 
@@ -305,17 +417,9 @@ static unsigned int br_nf_pre_routing(un
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_IP_PRE_ROUTING);
 #endif
- 	if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
+	if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
 		return NF_DROP;
-
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
-	}
-
-	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
-	nf_bridge->physindev = skb->dev;
-	skb->dev = bridge_parent(skb->dev);
+	setup_pre_routing(skb);
 	store_orig_dstaddr(skb);
 
 	NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
@@ -336,8 +440,7 @@ out:
  * packet would pass through PRE_ROUTING again (which already
  * took place when the packet entered the bridge), but we
  * register an IPv4 PRE_ROUTING 'sabotage' hook that will
- * prevent this from happening.
- */
+ * prevent this from happening. */
 static unsigned int br_nf_local_in(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
@@ -364,7 +467,7 @@ static int br_nf_forward_finish(struct s
 	skb->nf_debug ^= (1 << NF_BR_FORWARD);
 #endif
 
-	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP) {
+	if (skb->protocol != __constant_htons(ETH_P_ARP) && !IS_VLAN_ARP) {
 		in = nf_bridge->physindev;
 		if (nf_bridge->mask & BRNF_PKT_TYPE) {
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -385,9 +488,8 @@ static int br_nf_forward_finish(struct s
 /* This is the 'purely bridged' case.  For IP, we pass the packet to
  * netfilter with indev and outdev set to the bridge device,
  * but we are still able to filter on the 'real' indev/outdev
- * because of the ipt_physdev.c module. For ARP, indev and outdev are the
- * bridge ports.
- */
+ * because of the physdev module. For ARP, indev and outdev are the
+ * bridge ports. */
 static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
@@ -395,15 +497,17 @@ static unsigned int br_nf_forward_ip(uns
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	int pf;
 
-#ifdef CONFIG_SYSCTL
 	if (!skb->nf_bridge)
 		return NF_ACCEPT;
-#endif
 
-	if (skb->protocol != __constant_htons(ETH_P_IP)) {
-		if (!IS_VLAN_IP)
-			return NF_ACCEPT;
+	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP)
+		pf = PF_INET;
+	else
+		pf = PF_INET6;
+
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
 		skb_pull(*pskb, VLAN_HLEN);
 		(*pskb)->nh.raw += VLAN_HLEN;
 	}
@@ -421,7 +525,7 @@ static unsigned int br_nf_forward_ip(uns
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
 
-	NF_HOOK(PF_INET, NF_IP_FORWARD, skb, bridge_parent(in),
+	NF_HOOK(pf, NF_IP_FORWARD, skb, bridge_parent(in),
 		bridge_parent(out), br_nf_forward_finish);
 
 	return NF_STOLEN;
@@ -483,11 +587,10 @@ static int br_nf_local_out_finish(struct
 	return 0;
 }
 
-
 /* This function sees both locally originated IP packets and forwarded
  * IP packets (in both cases the destination device is a bridge
  * device). It also sees bridged-and-DNAT'ed packets.
- * To be able to filter on the physical bridge devices (with the ipt_physdev.c
+ * To be able to filter on the physical bridge devices (with the physdev
  * module), we steal packets destined to a bridge device away from the
  * PF_INET/FORWARD and PF_INET/OUTPUT hook functions, and give them back later,
  * when we have determined the real output device. This is done in here.
@@ -501,45 +604,44 @@ static int br_nf_local_out_finish(struct
  * this packet before, and so the packet was locally originated. We fake
  * the PF_INET/LOCAL_OUT hook.
  * Finally, if nf_bridge->physindev isn't NULL, then the packet was IP routed,
- * so we fake the PF_INET/FORWARD hook. ipv4_sabotage_out() makes sure
+ * so we fake the PF_INET/FORWARD hook. ip_sabotage_out() makes sure
  * even routed packets that didn't arrive on a bridge interface have their
- * nf_bridge->physindev set.
- */
-
+ * nf_bridge->physindev set. */
 static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
-   int (*_okfn)(struct sk_buff *))
+   int (*okfn)(struct sk_buff *))
 {
-	int (*okfn)(struct sk_buff *skb);
-	struct net_device *realindev;
+	struct net_device *realindev, *realoutdev;
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	int pf;
 
-#ifdef CONFIG_SYSCTL
 	if (!skb->nf_bridge)
 		return NF_ACCEPT;
-#endif
 
-	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
-		return NF_ACCEPT;
+	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP)
+		pf = PF_INET;
+	else
+		pf = PF_INET6;
 
+#ifdef CONFIG_NETFILTER_DEBUG
 	/* Sometimes we get packets with NULL ->dst here (for example,
-	 * running a dhcp client daemon triggers this).
-	 */
-	if (skb->dst == NULL)
+	 * running a dhcp client daemon triggers this). This should now
+	 * be fixed, but let's keep the check around. */
+	if (skb->dst == NULL) {
+		printk(KERN_CRIT "br_netfilter: skb->dst == NULL.");
 		return NF_ACCEPT;
+	}
+#endif
 
 	nf_bridge = skb->nf_bridge;
 	nf_bridge->physoutdev = skb->dev;
 	realindev = nf_bridge->physindev;
 
 	/* Bridged, take PF_BRIDGE/FORWARD.
-	 * (see big note in front of br_nf_pre_routing_finish)
-	 */
+	 * (see big note in front of br_nf_pre_routing_finish) */
 	if (nf_bridge->mask & BRNF_BRIDGED_DNAT) {
-		okfn = br_forward_finish;
-
 		if (nf_bridge->mask & BRNF_PKT_TYPE) {
 			skb->pkt_type = PACKET_OTHERHOST;
 			nf_bridge->mask ^= BRNF_PKT_TYPE;
@@ -550,41 +652,41 @@ static unsigned int br_nf_local_out(unsi
 		}
 
 		NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, realindev,
-			skb->dev, okfn);
-	} else {
-		struct net_device *realoutdev = bridge_parent(skb->dev);
+			skb->dev, br_forward_finish);
+		goto out;
+	}
+	realoutdev = bridge_parent(skb->dev);
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-		/* iptables should match -o br0.x */
-		if (nf_bridge->netoutdev)
-			realoutdev = nf_bridge->netoutdev;
+	/* iptables should match -o br0.x */
+	if (nf_bridge->netoutdev)
+		realoutdev = nf_bridge->netoutdev;
 #endif
-		okfn = br_nf_local_out_finish;
-		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
-			skb_pull(skb, VLAN_HLEN);
-			(*pskb)->nh.raw += VLAN_HLEN;
-		}
-		/* IP forwarded traffic has a physindev, locally
-		 * generated traffic hasn't.
-		 */
-		if (realindev != NULL) {
-			if (((nf_bridge->mask & BRNF_DONT_TAKE_PARENT) == 0) &&
-			    has_bridge_parent(realindev))
-				realindev = bridge_parent(realindev);
-			NF_HOOK_THRESH(PF_INET, NF_IP_FORWARD, skb, realindev,
-				       realoutdev, okfn,
-				       NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD + 1);
-		} else {
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_pull(skb, VLAN_HLEN);
+		(*pskb)->nh.raw += VLAN_HLEN;
+	}
+	/* IP forwarded traffic has a physindev, locally
+	 * generated traffic hasn't. */
+	if (realindev != NULL) {
+		if (!(nf_bridge->mask & BRNF_DONT_TAKE_PARENT) &&
+		    has_bridge_parent(realindev))
+			realindev = bridge_parent(realindev);
+
+		NF_HOOK_THRESH(pf, NF_IP_FORWARD, skb, realindev,
+			       realoutdev, br_nf_local_out_finish,
+			       NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD + 1);
+	} else {
 #ifdef CONFIG_NETFILTER_DEBUG
-			skb->nf_debug ^= (1 << NF_IP_LOCAL_OUT);
+		skb->nf_debug ^= (1 << NF_IP_LOCAL_OUT);
 #endif
 
-			NF_HOOK_THRESH(PF_INET, NF_IP_LOCAL_OUT, skb, realindev,
-				       realoutdev, okfn,
-				       NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT + 1);
-		}
+		NF_HOOK_THRESH(pf, NF_IP_LOCAL_OUT, skb, realindev,
+			       realoutdev, br_nf_local_out_finish,
+			       NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT + 1);
 	}
 
+out:
 	return NF_STOLEN;
 }
 
@@ -598,6 +700,7 @@ static unsigned int br_nf_post_routing(u
 	struct nf_bridge_info *nf_bridge = (*pskb)->nf_bridge;
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 	struct net_device *realoutdev = bridge_parent(skb->dev);
+	int pf;
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	/* Be very paranoid. This probably won't happen anymore, but let's
@@ -609,19 +712,15 @@ static unsigned int br_nf_post_routing(u
 	}
 #endif
 
-#ifdef CONFIG_SYSCTL
 	if (!nf_bridge)
 		return NF_ACCEPT;
-#endif
 
-	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
-		return NF_ACCEPT;
+	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP)
+		pf = PF_INET;
+	else
+		pf = PF_INET6;
 
 #ifdef CONFIG_NETFILTER_DEBUG
-	/* Sometimes we get packets with NULL ->dst here (for example,
-	 * running a dhcp client daemon triggers this). This should now
-	 * be fixed, but let's keep the check around.
-	 */
 	if (skb->dst == NULL) {
 		printk(KERN_CRIT "br_netfilter: skb->dst == NULL.");
 		goto print_error;
@@ -631,8 +730,7 @@ static unsigned int br_nf_post_routing(u
 #endif
 
 	/* We assume any code from br_dev_queue_push_xmit onwards doesn't care
-	 * about the value of skb->pkt_type.
-	 */
+	 * about the value of skb->pkt_type. */
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		skb->pkt_type = PACKET_HOST;
 		nf_bridge->mask |= BRNF_PKT_TYPE;
@@ -649,8 +747,8 @@ static unsigned int br_nf_post_routing(u
 	if (nf_bridge->netoutdev)
 		realoutdev = nf_bridge->netoutdev;
 #endif
-	NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
-		realoutdev, br_dev_queue_push_xmit);
+	NF_HOOK(pf, NF_IP_POST_ROUTING, skb, NULL, realoutdev,
+	        br_dev_queue_push_xmit);
 
 	return NF_STOLEN;
 
@@ -668,12 +766,10 @@ print_error:
 }
 
 
-/* IPv4/SABOTAGE *****************************************************/
-
-/* Don't hand locally destined packets to PF_INET/PRE_ROUTING
- * for the second time.
- */
-static unsigned int ipv4_sabotage_in(unsigned int hook, struct sk_buff **pskb,
+/* IP/SABOTAGE *****************************************************/
+/* Don't hand locally destined packets to PF_INET(6)/PRE_ROUTING
+ * for the second time. */
+static unsigned int ip_sabotage_in(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
@@ -686,19 +782,27 @@ static unsigned int ipv4_sabotage_in(uns
 	return NF_ACCEPT;
 }
 
-/* Postpone execution of PF_INET/FORWARD, PF_INET/LOCAL_OUT
- * and PF_INET/POST_ROUTING until we have done the forwarding
- * decision in the bridge code and have determined skb->physoutdev.
- */
-static unsigned int ipv4_sabotage_out(unsigned int hook, struct sk_buff **pskb,
+/* Postpone execution of PF_INET(6)/FORWARD, PF_INET(6)/LOCAL_OUT
+ * and PF_INET(6)/POST_ROUTING until we have done the forwarding
+ * decision in the bridge code and have determined nf_bridge->physoutdev. */
+static unsigned int ip_sabotage_out(unsigned int hook, struct sk_buff **pskb,
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
 	struct sk_buff *skb = *pskb;
 
 #ifdef CONFIG_SYSCTL
-	if (!brnf_call_iptables && !skb->nf_bridge)
-		return NF_ACCEPT;
+	if (!skb->nf_bridge) {
+		struct vlan_ethhdr *hdr =
+		   (struct vlan_ethhdr *)(skb->mac.ethernet);
+
+		if (skb->protocol == __constant_htons(ETH_P_IP) ||
+		    IS_VLAN_IP) {
+			if (!brnf_call_iptables)
+				return NF_ACCEPT;
+		} else if (!brnf_call_ip6tables)
+			return NF_ACCEPT;
+	}
 #endif
 
 	if ((out->hard_start_xmit == br_dev_xmit &&
@@ -721,8 +825,7 @@ static unsigned int ipv4_sabotage_out(un
 		 * will need the indev then. For a brouter, the real indev
 		 * can be a bridge port, so we make sure br_nf_local_out()
 		 * doesn't use the bridge parent of the indev by using
-		 * the BRNF_DONT_TAKE_PARENT mask.
-		 */
+		 * the BRNF_DONT_TAKE_PARENT mask. */
 		if (hook == NF_IP_FORWARD && nf_bridge->physindev == NULL) {
 			nf_bridge->mask &= BRNF_DONT_TAKE_PARENT;
 			nf_bridge->physindev = (struct net_device *)in;
@@ -742,8 +845,7 @@ static unsigned int ipv4_sabotage_out(un
 /* For br_nf_local_out we need (prio = NF_BR_PRI_FIRST), to insure that innocent
  * PF_BRIDGE/NF_BR_LOCAL_OUT functions don't get bridged traffic as input.
  * For br_nf_post_routing, we need (prio = NF_BR_PRI_LAST), because
- * ip_refrag() can return NF_STOLEN.
- */
+ * ip_refrag() can return NF_STOLEN. */
 static struct nf_hook_ops br_nf_ops[] = {
 	{ .hook = br_nf_pre_routing, 
 	  .owner = THIS_MODULE, 
@@ -775,26 +877,46 @@ static struct nf_hook_ops br_nf_ops[] = 
 	  .pf = PF_BRIDGE,
 	  .hooknum = NF_BR_POST_ROUTING,
 	  .priority = NF_BR_PRI_LAST, },
-	{ .hook = ipv4_sabotage_in,
+	{ .hook = ip_sabotage_in,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET,
 	  .hooknum = NF_IP_PRE_ROUTING,
 	  .priority = NF_IP_PRI_FIRST, },
-	{ .hook = ipv4_sabotage_out,
+	{ .hook = ip_sabotage_in,
+	  .owner = THIS_MODULE,
+	  .pf = PF_INET6,
+	  .hooknum = NF_IP6_PRE_ROUTING,
+	  .priority = NF_IP6_PRI_FIRST, },
+	{ .hook = ip_sabotage_out,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET,
 	  .hooknum = NF_IP_FORWARD,
 	  .priority = NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD, },
-	{ .hook = ipv4_sabotage_out,
+	{ .hook = ip_sabotage_out,
+	  .owner = THIS_MODULE,
+	  .pf = PF_INET6,
+	  .hooknum = NF_IP6_FORWARD,
+	  .priority = NF_IP6_PRI_BRIDGE_SABOTAGE_FORWARD, },
+	{ .hook = ip_sabotage_out,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET,
 	  .hooknum = NF_IP_LOCAL_OUT,
 	  .priority = NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT, },
-	{ .hook = ipv4_sabotage_out,
+	{ .hook = ip_sabotage_out,
+	  .owner = THIS_MODULE,
+	  .pf = PF_INET6,
+	  .hooknum = NF_IP6_LOCAL_OUT,
+	  .priority = NF_IP6_PRI_BRIDGE_SABOTAGE_LOCAL_OUT, },
+	{ .hook = ip_sabotage_out,
 	  .owner = THIS_MODULE,
 	  .pf = PF_INET,
 	  .hooknum = NF_IP_POST_ROUTING,
 	  .priority = NF_IP_PRI_FIRST, },
+	{ .hook = ip_sabotage_out,
+	  .owner = THIS_MODULE,
+	  .pf = PF_INET6,
+	  .hooknum = NF_IP6_POST_ROUTING,
+	  .priority = NF_IP6_PRI_FIRST, },
 };
 
 #ifdef CONFIG_SYSCTL
@@ -824,6 +946,14 @@ static ctl_table brnf_table[] = {
 		.ctl_name	= NET_BRIDGE_NF_CALL_IPTABLES,
 		.procname	= "bridge-nf-call-iptables",
 		.data		= &brnf_call_iptables,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &brnf_sysctl_call_tables,
+	},
+	{
+		.ctl_name	= NET_BRIDGE_NF_CALL_IP6TABLES,
+		.procname	= "bridge-nf-call-ip6tables",
+		.data		= &brnf_call_ip6tables,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= &brnf_sysctl_call_tables,
--- linux-2.6.8.1/Documentation/networking/ip-sysctl.txt.old	2004-08-28 16:15:09.000000000 +0200
+++ linux-2.6.8.1/Documentation/networking/ip-sysctl.txt	2004-08-28 16:19:23.000000000 +0200
@@ -837,6 +837,11 @@ bridge-nf-call-iptables - BOOLEAN
 	0 : disable this.
 	Default: 1
 
+bridge-nf-call-ip6tables - BOOLEAN
+	1 : pass bridged IPv6 traffic to ip6tables' chains.
+	0 : disable this.
+	Default: 1
+
 bridge-nf-filter-vlan-tagged - BOOLEAN
 	1 : pass bridged vlan-tagged ARP/IP traffic to arptables/iptables.
 	0 : disable this.
