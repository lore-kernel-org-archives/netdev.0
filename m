From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH/RFC] Let {ip,arp}tables "see" bridged VLAN tagged {I,AR}P
	packets
Date: Mon, 6 Oct 2003 22:04:07 +0200
Sender: vlan-bounces@wanfear.com
Message-ID: <200310062204.07230.bdschuym@pandora.be>
Reply-To: "Linux 802.1Q VLAN" <vlan@wanfear.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <vlan-bounces@wanfear.com>
To: netdev@oss.sgi.com, bridge <bridge@osdl.org>,
        "David S.Miller" <davem@redhat.com>,
        Ben Greear <greearb@candelatech.com>, vlan@wanfear.com,
        Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
List-Unsubscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=unsubscribe>
List-Archive: <http://ns1.wanfear.com/pipermail/vlan>
List-Post: <mailto:vlan@wanfear.com>
List-Help: <mailto:vlan-request@wanfear.com?subject=help>
List-Subscribe: <http://www.WANfear.com/mailman/listinfo/vlan>,
	<mailto:vlan-request@wanfear.com?subject=subscribe>
Errors-To: vlan-bounces@wanfear.com
List-Id: netdev.vger.kernel.org

Hi all,

The patch below does four trivial changes and one big change
Trivial changes, these are all in br_netfilter.c:
- check ar_pln==4 when giving bridged ARP packets to arptables
- delete unnecessary if in br_nf_local_in
- add more logging for the "Argh" message
- add some brag-comments in the file head comment

Big change: let {ip,arp}tables see VLAN tagged {I,AR}P packets.
This patch also makes an oops go away when locally generated packets
are sent through something like br0.1000.

This is what the patch does:
- add vlan_dev_hard_start_xmit_p, because br_netfilter.c needs to know
the address of vlan_dev_hard_start_xmit(). When the local machine sends
a packet through br0.1000, we need to allow filtering in LOCAL_OUT/FILTER
on the bridge out port, so we need to be able to postpone the iptables
filtering.
- add nf_bridge->netoutdev for vlan. When the local machine sends a
packet through br0.1000, iptables -o br0.1000 should match instead of
iptables -o br0. In the bridge code, it is not known that the out device
was br0.1000, so we need to save this info in nf_bridge->netoutdev.
- change nf_bridge->hh size to 18, which is the Ethernet header size +
VLAN header size.
- add BRNF_NF_BRIDGE_PREROUTING mask, to make sure the iptables PREROUTING
chain isn't traversed twice. The old mechanism isn't satisfactory when
the bridge port is a VLAN tagged device.
- add some code in vlan_dev.c::vlan_dev_hard_start_xmit():
skb->protocol = __constant_htons(ETH_P_8021Q);
skb->mac.raw -= VLAN_HLEN;
skb->nh.raw -= VLAN_HLEN;
When the logical VLAN device adds its VLAN header to the packet, I think
it should update the skb. The protocol then becomes VLAN, the Ethernet
header pointer should be updated correctly. Also, the network header
pointer should now point to the VLAN header.
This code is needed for the code in br_netfilter.c to work, without it
things will get more complicated inside br_netfilter.c.
I can put it between an #ifdef CONFIG_BRIDGE_NETFILTER if you like, but
I think that to keep the skb correct these changes should always happen.
- {arp,ip}tables can filter the VLAN tagged packets thanks to some
playing around with the skb->data and skb->nh.raw pointer inside
br_netfilter.c.

When br0.1000 (or the like) exists, this is what happens to the
device matching in {eb,ip}tables:
Suppose a frame arrives on br0: in PREROUTING the (logical) in-dev is
br0. When the frame is bridged, the in-dev remains br0. When the frame
is destined for the bridge box, the in-dev for iptables LOCAL_IN becomes
br0.1000, for ebtables LOCAL_IN it remains br0.
Suppose the bridge box sends a locally generated IP packet through
br0.1000. The out-dev for iptables is br0.1000, the out-dev for ebtables
is br0.

Comments are welcome.
If people could test this patch and give feedback, that would be great.

cheers,
Bart


--- linux-2.6.0-test6/net/8021q/vlan.c	Sun Sep 28 02:50:40 2003
+++ linux-2.6.0-test6-new/net/8021q/vlan.c	Sun Oct  5 21:56:15 2003
@@ -103,6 +103,9 @@ static int __init vlan_proto_init(void)
 
 	vlan_ioctl_set(vlan_ioctl_handler);
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+	vlan_dev_hard_start_xmit_p = vlan_dev_hard_start_xmit;
+#endif
 	return 0;
 }
 
@@ -125,6 +128,9 @@ static void __exit vlan_cleanup_devices(
 		}
 	}
 	rtnl_unlock();
+#ifdef CONFIG_BRIDGE_NETFILTER
+	vlan_dev_hard_start_xmit_p = NULL;
+#endif
 }
 
 /*
--- linux-2.6.0-test6/net/core/dev.c	Sun Sep 28 02:50:20 2003
+++ linux-2.6.0-test6-new/net/core/dev.c	Sun Oct  5 21:56:15 2003
@@ -1489,6 +1489,14 @@ static void net_tx_action(struct softirq
 }
 
 #if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
+
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#ifdef CONFIG_BRIDGE_NETFILTER
+/* net/bridge/br_netfilter.c needs the address of vlan_dev_hard_start_xmit */
+int (*vlan_dev_hard_start_xmit_p)(struct sk_buff *skb, struct net_device *dev);
+#endif
+#endif
+
 int (*br_handle_frame_hook)(struct sk_buff *skb);
 
 static __inline__ int handle_bridge(struct sk_buff *skb,
--- linux-2.6.0-test6/include/linux/if_vlan.h	Sun Sep 28 02:50:10 2003
+++ linux-2.6.0-test6-new/include/linux/if_vlan.h	Sun Oct  5 21:56:15 2003
@@ -54,6 +54,12 @@ struct vlan_hdr {
 
 #define VLAN_VID_MASK	0xfff
 
+#ifdef CONFIG_BRIDGE_NETFILTER
+extern int (*vlan_dev_hard_start_xmit_p)(struct sk_buff *skb,
+					  struct net_device *dev);
+#endif
+
+
 /* found in socket.c */
 extern void vlan_ioctl_set(int (*hook)(unsigned long));
 
--- linux-2.6.0-test6/net/netsyms.c	Sun Sep 28 02:50:17 2003
+++ linux-2.6.0-test6-new/net/netsyms.c	Sun Oct  5 21:56:15 2003
@@ -236,6 +236,11 @@ EXPORT_SYMBOL(scm_detach_fds);
 
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 EXPORT_SYMBOL(br_handle_frame_hook);
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#ifdef CONFIG_BRIDGE_NETFILTER
+EXPORT_SYMBOL(vlan_dev_hard_start_xmit_p);
+#endif
+#endif
 #endif
 
 #ifdef CONFIG_NET_DIVERT
--- linux-2.6.0-test6/include/linux/skbuff.h	Sun Sep 28 02:50:29 2003
+++ linux-2.6.0-test6-new/include/linux/skbuff.h	Sun Oct  5 21:56:15 2003
@@ -103,8 +103,11 @@ struct nf_bridge_info {
 	atomic_t use;
 	struct net_device *physindev;
 	struct net_device *physoutdev;
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	struct net_device *netoutdev;
+#endif
 	unsigned int mask;
-	unsigned long hh[16 / sizeof(unsigned long)];
+	unsigned char hh[18];
 };
 #endif
 
--- linux-2.6.0-test6/include/linux/netfilter_bridge.h	Sun Sep 28 02:50:28 2003
+++ linux-2.6.0-test6-new/include/linux/netfilter_bridge.h	Mon Oct  6 20:56:42 2003
@@ -8,6 +8,9 @@
 #include <linux/netfilter.h>
 #if defined(__KERNEL__) && defined(CONFIG_BRIDGE_NETFILTER)
 #include <asm/atomic.h>
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+#include <linux/if_ether.h>
+#endif
 #endif
 
 /* Bridge Hooks */
@@ -44,6 +47,7 @@ enum nf_br_hook_priorities {
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_DONT_TAKE_PARENT		0x04
 #define BRNF_BRIDGED			0x08
+#define BRNF_NF_BRIDGE_PREROUTING	0x10
 
 static inline
 struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
@@ -54,9 +58,39 @@ struct nf_bridge_info *nf_bridge_alloc(s
 		atomic_set(&(*nf_bridge)->use, 1);
 		(*nf_bridge)->mask = 0;
 		(*nf_bridge)->physindev = (*nf_bridge)->physoutdev = NULL;
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+		(*nf_bridge)->netoutdev = NULL;
+#endif
 	}
 
 	return *nf_bridge;
+}
+
+/* Only used in br_forward.c */
+static inline
+void nf_bridge_maybe_copy_header(struct sk_buff *skb)
+{
+	if (skb->nf_bridge) {
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			memcpy(skb->data - 18, skb->nf_bridge->hh, 18);
+			skb_push(skb, 4);
+		} else
+#endif
+			memcpy(skb->data - 16, skb->nf_bridge->hh, 16);
+	}
+}
+
+static inline
+void nf_bridge_save_header(struct sk_buff *skb)
+{
+        int header_size = 16;
+
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	if (skb->protocol == __constant_htons(ETH_P_8021Q))
+		header_size = 18;
+#endif
+	memcpy(skb->nf_bridge->hh, skb->data - header_size, header_size);
 }
 
 struct bridge_skb_cb {
--- linux-2.6.0-test6/net/bridge/br_forward.c	Sun Sep 28 02:50:15 2003
+++ linux-2.6.0-test6-new/net/bridge/br_forward.c	Mon Oct  6 20:19:32 2003
@@ -35,8 +35,7 @@ int br_dev_queue_push_xmit(struct sk_buf
 {
 #ifdef CONFIG_BRIDGE_NETFILTER
 	/* ip_refrag calls ip_fragment, which doesn't copy the MAC header. */
-	if (skb->nf_bridge)
-		memcpy(skb->data - 16, skb->nf_bridge->hh, 16);
+	nf_bridge_maybe_copy_header(skb);
 #endif
 	skb_push(skb, ETH_HLEN);
 
--- linux-2.6.0-test6/net/8021q/vlan_dev.c	Sun Sep 28 02:51:00 2003
+++ linux-2.6.0-test6-new/net/8021q/vlan_dev.c	Sun Oct  5 21:56:15 2003
@@ -502,6 +502,10 @@ int vlan_dev_hard_start_xmit(struct sk_b
 	stats->tx_packets++; /* for statics only */
 	stats->tx_bytes += skb->len;
 
+	skb->protocol = __constant_htons(ETH_P_8021Q);
+	skb->mac.raw -= VLAN_HLEN;
+	skb->nh.raw -= VLAN_HLEN;
+
 	dev_queue_xmit(skb);
 
 	return 0;
--- linux-2.6.0-test6/net/bridge/br_netfilter.c	Sun Sep 28 02:51:07 2003
+++ linux-2.6.0-test6-new/net/bridge/br_netfilter.c	Mon Oct  6 21:10:40 2003
@@ -4,7 +4,13 @@
  *
  *	Authors:
  *	Lennert Buytenhek               <buytenh@gnu.org>
- *	Bart De Schuymer		<bdschuym@pandora.be>
+ *	Bart De Schuymer (maintainer)	<bdschuym@pandora.be>
+ *
+ *	Changes:
+ *	Apr 29 2003: physdev module support (bdschuym)
+ *	Jun 19 2003: let arptables see bridged ARP traffic (bdschuym)
+ *	Oct 06 2003: filter encapsulated IP/ARP VLAN traffic on untagged bridge
+ *	             (bdschuym)
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -20,6 +26,7 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/if_ether.h>
+#include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_arp.h>
@@ -40,6 +47,11 @@
 #define has_bridge_parent(device)	((device)->br_port != NULL)
 #define bridge_parent(device)		((device)->br_port->br->dev)
 
+#define IS_VLAN_IP (skb->protocol == __constant_htons(ETH_P_8021Q) && \
+	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_IP))
+#define IS_VLAN_ARP (skb->protocol == __constant_htons(ETH_P_8021Q) && \
+	hdr->h_vlan_encapsulated_proto == __constant_htons(ETH_P_ARP))
+
 /* We need these fake structures to make netfilter happy --
  * lots of places assume that skb->dst != NULL, which isn't
  * all that unreasonable.
@@ -135,8 +147,13 @@ static int br_nf_pre_routing_finish_brid
 		skb->pkt_type = PACKET_HOST;
 		skb->nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
+	skb->nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
 	skb->dev = bridge_parent(skb->dev);
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_pull(skb, VLAN_HLEN);
+		skb->nh.raw += VLAN_HLEN;
+	}
 	skb->dst->output(skb);
 	return 0;
 }
@@ -155,6 +172,7 @@ static int br_nf_pre_routing_finish(stru
 		skb->pkt_type = PACKET_OTHERHOST;
 		nf_bridge->mask ^= BRNF_PKT_TYPE;
 	}
+	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
 	if (dnat_took_place(skb)) {
 		if (ip_route_input(skb, iph->daddr, iph->saddr, iph->tos,
@@ -186,6 +204,11 @@ bridged_dnat:
 				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
 				clear_cb(skb);
+				if (skb->protocol ==
+				    __constant_htons(ETH_P_8021Q)) {
+					skb_push(skb, VLAN_HLEN);
+					skb->nh.raw -= VLAN_HLEN;
+				}
 				NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING,
 					       skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
@@ -202,6 +225,10 @@ bridged_dnat:
 
 	clear_cb(skb);
 	skb->dev = nf_bridge->physindev;
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_push(skb, VLAN_HLEN);
+		skb->nh.raw -= VLAN_HLEN;
+	}
 	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
@@ -220,13 +247,20 @@ static unsigned int br_nf_pre_routing(un
 {
 	struct iphdr *iph;
 	__u32 len;
-	struct sk_buff *skb;
+	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 
-	if ((*pskb)->protocol != __constant_htons(ETH_P_IP))
-		return NF_ACCEPT;
-
-	if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
+	if (skb->protocol != __constant_htons(ETH_P_IP)) {
+		struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)
+					  ((*pskb)->mac.ethernet);
+
+		if (!IS_VLAN_IP)
+			return NF_ACCEPT;
+		if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
+			goto out;
+		skb_pull(*pskb, VLAN_HLEN);
+		(*pskb)->nh.raw += VLAN_HLEN;
+	} else if ((skb = skb_share_check(*pskb, GFP_ATOMIC)) == NULL)
 		goto out;
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
@@ -264,6 +298,7 @@ static unsigned int br_nf_pre_routing(un
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
+	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = bridge_parent(skb->dev);
 	store_orig_dstaddr(skb);
@@ -294,9 +329,6 @@ static unsigned int br_nf_local_in(unsig
 {
 	struct sk_buff *skb = *pskb;
 
-	if (skb->protocol != __constant_htons(ETH_P_IP))
-		return NF_ACCEPT;
-
 	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -310,12 +342,13 @@ static int br_nf_forward_finish(struct s
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *in;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_BR_FORWARD);
 #endif
 
-	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP) {
 		in = nf_bridge->physindev;
 		if (nf_bridge->mask & BRNF_PKT_TYPE) {
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -324,7 +357,10 @@ static int br_nf_forward_finish(struct s
 	} else {
 		in = *((struct net_device **)(skb->cb));
 	}
-
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_push(skb, VLAN_HLEN);
+		skb->nh.raw -= VLAN_HLEN;
+	}
 	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_FORWARD, skb, in,
 			skb->dev, br_forward_finish, 1);
 	return 0;
@@ -342,15 +378,20 @@ static unsigned int br_nf_forward(unsign
 {
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 
 	if (skb->protocol != __constant_htons(ETH_P_IP) &&
-	    skb->protocol != __constant_htons(ETH_P_ARP))
-		return NF_ACCEPT;
+	    skb->protocol != __constant_htons(ETH_P_ARP)) {
+		if (!IS_VLAN_IP && !IS_VLAN_ARP)
+			return NF_ACCEPT;
+		skb_pull(*pskb, VLAN_HLEN);
+		(*pskb)->nh.raw += VLAN_HLEN;
+	}
 
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_BR_FORWARD);
 #endif
-	if (skb->protocol == __constant_htons(ETH_P_IP)) {
+	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP) {
 		nf_bridge = skb->nf_bridge;
 		if (skb->pkt_type == PACKET_OTHERHOST) {
 			skb->pkt_type = PACKET_HOST;
@@ -365,7 +406,15 @@ static unsigned int br_nf_forward(unsign
 			bridge_parent(out), br_nf_forward_finish);
 	} else {
 		struct net_device **d = (struct net_device **)(skb->cb);
+		struct arphdr *arp = skb->nh.arph;
 
+		if (arp->ar_pln != 4) {
+			if (IS_VLAN_ARP) {
+				skb_push(*pskb, VLAN_HLEN);
+				(*pskb)->nh.raw -= VLAN_HLEN;
+			}
+			return NF_ACCEPT;
+		}
 		*d = (struct net_device *)in;
 		NF_HOOK(NF_ARP, NF_ARP_FORWARD, skb, (struct net_device *)in,
 			(struct net_device *)out, br_nf_forward_finish);
@@ -381,6 +430,10 @@ static int br_nf_local_out_finish(struct
 #ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug &= ~(1 << NF_BR_LOCAL_OUT);
 #endif
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_push(skb, VLAN_HLEN);
+		skb->nh.raw -= VLAN_HLEN;
+	}
 
 	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			br_forward_finish, NF_BR_PRI_FIRST + 1);
@@ -419,8 +472,9 @@ static unsigned int br_nf_local_out(unsi
 	struct net_device *realindev;
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 
-	if (skb->protocol != __constant_htons(ETH_P_IP))
+	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
 		return NF_ACCEPT;
 
 	/* Sometimes we get packets with NULL ->dst here (for example,
@@ -444,11 +498,26 @@ static unsigned int br_nf_local_out(unsi
 			skb->pkt_type = PACKET_OTHERHOST;
 			nf_bridge->mask ^= BRNF_PKT_TYPE;
 		}
+		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			skb_push(skb, VLAN_HLEN);
+			skb->nh.raw -= VLAN_HLEN;
+		}
 
 		NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, realindev,
 			skb->dev, okfn);
 	} else {
+		struct net_device *realoutdev = bridge_parent(skb->dev);
+
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+		/* iptables should match -o br0.x */
+		if (nf_bridge->netoutdev)
+			realoutdev = nf_bridge->netoutdev;
+#endif
 		okfn = br_nf_local_out_finish;
+		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			skb_pull(skb, VLAN_HLEN);
+			(*pskb)->nh.raw += VLAN_HLEN;
+		}
 		/* IP forwarded traffic has a physindev, locally
 		 * generated traffic hasn't.
 		 */
@@ -456,9 +525,8 @@ static unsigned int br_nf_local_out(unsi
 			if (((nf_bridge->mask & BRNF_DONT_TAKE_PARENT) == 0) &&
 			    has_bridge_parent(realindev))
 				realindev = bridge_parent(realindev);
-
 			NF_HOOK_THRESH(PF_INET, NF_IP_FORWARD, skb, realindev,
-				       bridge_parent(skb->dev), okfn,
+				       realoutdev, okfn,
 				       NF_IP_PRI_BRIDGE_SABOTAGE_FORWARD + 1);
 		} else {
 #ifdef CONFIG_NETFILTER_DEBUG
@@ -466,7 +534,7 @@ static unsigned int br_nf_local_out(unsi
 #endif
 
 			NF_HOOK_THRESH(PF_INET, NF_IP_LOCAL_OUT, skb, realindev,
-				       bridge_parent(skb->dev), okfn,
+				       realoutdev, okfn,
 				       NF_IP_PRI_BRIDGE_SABOTAGE_LOCAL_OUT + 1);
 		}
 	}
@@ -482,6 +550,8 @@ static unsigned int br_nf_post_routing(u
 {
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge = (*pskb)->nf_bridge;
+	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
+	struct net_device *realoutdev = bridge_parent(skb->dev);
 
 	/* Be very paranoid. Must be a device driver bug. */
 	if (skb->mac.raw < skb->head || skb->mac.raw + ETH_HLEN > skb->data) {
@@ -492,11 +562,11 @@ static unsigned int br_nf_post_routing(u
 			if (has_bridge_parent(skb->dev))
 				printk("[%s]", bridge_parent(skb->dev)->name);
 		}
-		printk("\n");
+		printk(" head:%p, raw:%p\n", skb->head, skb->mac.raw);
 		return NF_ACCEPT;
 	}
 
-	if (skb->protocol != __constant_htons(ETH_P_IP))
+	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
 		return NF_ACCEPT;
 
 	/* Sometimes we get packets with NULL ->dst here (for example,
@@ -517,10 +587,19 @@ static unsigned int br_nf_post_routing(u
 		nf_bridge->mask |= BRNF_PKT_TYPE;
 	}
 
-	memcpy(nf_bridge->hh, skb->data - 16, 16);
+	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+		skb_pull(skb, VLAN_HLEN);
+		skb->nh.raw += VLAN_HLEN;
+	}
+
+	nf_bridge_save_header(skb);
 
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	if (nf_bridge->netoutdev)
+		realoutdev = nf_bridge->netoutdev;
+#endif
 	NF_HOOK(PF_INET, NF_IP_POST_ROUTING, skb, NULL,
-		bridge_parent(skb->dev), br_dev_queue_push_xmit);
+		realoutdev, br_dev_queue_push_xmit);
 
 	return NF_STOLEN;
 }
@@ -535,8 +614,8 @@ static unsigned int ipv4_sabotage_in(uns
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
-	if (in->hard_start_xmit == br_dev_xmit &&
-	    okfn != br_nf_pre_routing_finish) {
+	if ((*pskb)->nf_bridge &&
+	    !((*pskb)->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)) {
 		okfn(*pskb);
 		return NF_STOLEN;
 	}
@@ -552,10 +631,15 @@ static unsigned int ipv4_sabotage_out(un
    const struct net_device *in, const struct net_device *out,
    int (*okfn)(struct sk_buff *))
 {
-	if (out->hard_start_xmit == br_dev_xmit &&
+	if ((out->hard_start_xmit == br_dev_xmit &&
 	    okfn != br_nf_forward_finish &&
 	    okfn != br_nf_local_out_finish &&
-	    okfn != br_dev_queue_push_xmit) {
+	    okfn != br_dev_queue_push_xmit)
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	    || (out->hard_start_xmit == vlan_dev_hard_start_xmit_p &&
+	    VLAN_DEV_INFO(out)->real_dev->hard_start_xmit == br_dev_xmit)
+#endif
+	    ) {
 		struct sk_buff *skb = *pskb;
 		struct nf_bridge_info *nf_bridge;
 
@@ -574,6 +658,11 @@ static unsigned int ipv4_sabotage_out(un
 			nf_bridge->mask &= BRNF_DONT_TAKE_PARENT;
 			nf_bridge->physindev = (struct net_device *)in;
 		}
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+		/* the iptables outdev is br0.x, not br0 */
+		if (out->hard_start_xmit == vlan_dev_hard_start_xmit_p)
+			nf_bridge->netoutdev = (struct net_device *)out;
+#endif
 		okfn(skb);
 		return NF_STOLEN;
 	}

_______________________________________________
VLAN mailing list  -  VLAN@wanfear.com
http://www.WANfear.com/mailman/listinfo/vlan
VLAN Page:  http://scry.wanfear.com/~greear/vlan.html
