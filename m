From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: [Bridge] Re: [PATCH/RFC] Let {ip, arp}tables "see" bridged VLAN tagged {I,AR}P packets
Date: Tue, 7 Oct 2003 21:12:53 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310072112.53821.bdschuym@pandora.be>
References: <200310062204.07230.bdschuym@pandora.be> <20031007080640.50de4d45.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, greearb@candelatech.com, bridge@osdl.org,
        vlan@wanfear.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031007080640.50de4d45.davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 07 October 2003 17:06, David S. Miller wrote:
> On Mon, 6 Oct 2003 22:04:07 +0200
>
> Bart De Schuymer <bdschuym@pandora.be> wrote:
> > -	unsigned long hh[16 / sizeof(unsigned long)];
> > +	unsigned char hh[18];
>
> Maybe don't do this?  It should be aligned on a 'long' boundry I
> think.

I've changed it to 32 instead of 16. This wastes some space, but it's OK
with me if it's OK with you.

> The only real hard objection I have with the patch is the vlan xmit
> routine pointer crap, just export the symbol.
>
> Once you fix that I'll apply your patch as long as Stephen has no
> objections.

I've used Stephen's suggestion (out->priv_flags & IFF_802_1Q_VLAN), this
removes all that cruft.

cheers,
Bart


--- linux-2.6.0-test6/include/linux/skbuff.h	Sun Sep 28 02:50:29 2003
+++ linux-2.6.0-test6-new/include/linux/skbuff.h	Tue Oct  7 19:42:49 2003
@@ -103,8 +103,11 @@ struct nf_bridge_info {
 	atomic_t use;
 	struct net_device *physindev;
 	struct net_device *physoutdev;
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
+	struct net_device *netoutdev;
+#endif
 	unsigned int mask;
-	unsigned long hh[16 / sizeof(unsigned long)];
+	unsigned long hh[32 / sizeof(unsigned long)];
 };
 #endif
 
--- linux-2.6.0-test6/include/linux/netfilter_bridge.h	Sun Sep 28 02:50:28 2003
+++ linux-2.6.0-test6-new/include/linux/netfilter_bridge.h	Tue Oct  7 19:36:36 2003
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
+++ linux-2.6.0-test6-new/net/bridge/br_forward.c	Tue Oct  7 19:36:36 2003
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
+++ linux-2.6.0-test6-new/net/8021q/vlan_dev.c	Tue Oct  7 19:36:36 2003
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
+++ linux-2.6.0-test6-new/net/bridge/br_netfilter.c	Tue Oct  7 19:38:04 2003
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
+	    || ((out->priv_flags & IFF_802_1Q_VLAN) &&
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
+		if (out->priv_flags & IFF_802_1Q_VLAN)
+			nf_bridge->netoutdev = (struct net_device *)out;
+#endif
 		okfn(skb);
 		return NF_STOLEN;
 	}
