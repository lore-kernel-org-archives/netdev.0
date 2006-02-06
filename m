From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/3] bridge: netfilter handle RCU during removal
Date: Mon, 06 Feb 2006 14:27:34 -0800
Message-ID: <20060206222853.844546000@dxpl.pdx.osdl.net>
References: <20060206222732.661214000@dxpl.pdx.osdl.net>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=br-netfilter-ref.patch
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Bridge netfilter code needs to handle the case where device is
removed from bridge while packet in process. In these cases the
bridge_parent can be come null while processing.

This should fix: http://bugzilla.kernel.org/show_bug.cgi?id=5803

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br-2.6.orig/net/bridge/br_netfilter.c
+++ br-2.6/net/bridge/br_netfilter.c
@@ -51,9 +51,6 @@
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = (skb)->nh.iph->daddr)
 #define dnat_took_place(skb)	 (skb_origaddr(skb) != (skb)->nh.iph->daddr)
 
-#define has_bridge_parent(device)	((device)->br_port != NULL)
-#define bridge_parent(device)		((device)->br_port->br->dev)
-
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables = 1;
@@ -98,6 +95,12 @@ static struct rtable __fake_rtable = {
 	.rt_flags	= 0,
 };
 
+static inline struct net_device *bridge_parent(const struct net_device *dev)
+{
+	struct net_bridge_port *port = rcu_dereference(dev->br_port);
+
+	return port ? port->br->dev : NULL;
+}
 
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
@@ -189,11 +192,15 @@ static int br_nf_pre_routing_finish_brid
 	skb->nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
 	skb->dev = bridge_parent(skb->dev);
-	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
-		skb_pull(skb, VLAN_HLEN);
-		skb->nh.raw += VLAN_HLEN;
+	if (!skb->dev)
+		kfree_skb(skb);
+	else {
+		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
+			skb_pull(skb, VLAN_HLEN);
+			skb->nh.raw += VLAN_HLEN;
+		}
+		skb->dst->output(skb);
 	}
-	skb->dst->output(skb);
 	return 0;
 }
 
@@ -270,7 +277,7 @@ bridged_dnat:
 }
 
 /* Some common code for IPv4/IPv6 */
-static void setup_pre_routing(struct sk_buff *skb)
+static struct net_device *setup_pre_routing(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 
@@ -282,6 +289,8 @@ static void setup_pre_routing(struct sk_
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
 	skb->dev = bridge_parent(skb->dev);
+
+	return skb->dev;
 }
 
 /* We only check the length. A bridge shouldn't do any hop-by-hop stuff anyway */
@@ -376,7 +385,8 @@ static unsigned int br_nf_pre_routing_ip
  	nf_bridge_put(skb->nf_bridge);
 	if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
 		return NF_DROP;
-	setup_pre_routing(skb);
+	if (!setup_pre_routing(skb))
+		return NF_DROP;
 
 	NF_HOOK(PF_INET6, NF_IP6_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
@@ -465,7 +475,8 @@ static unsigned int br_nf_pre_routing(un
  	nf_bridge_put(skb->nf_bridge);
 	if ((nf_bridge = nf_bridge_alloc(skb)) == NULL)
 		return NF_DROP;
-	setup_pre_routing(skb);
+	if (!setup_pre_routing(skb))
+		return NF_DROP;
 	store_orig_dstaddr(skb);
 
 	NF_HOOK(PF_INET, NF_IP_PRE_ROUTING, skb, skb->dev, NULL,
@@ -539,11 +550,16 @@ static unsigned int br_nf_forward_ip(uns
 	struct sk_buff *skb = *pskb;
 	struct nf_bridge_info *nf_bridge;
 	struct vlan_ethhdr *hdr = vlan_eth_hdr(skb);
+	struct net_device *parent;
 	int pf;
 
 	if (!skb->nf_bridge)
 		return NF_ACCEPT;
 
+	parent = bridge_parent(out);
+	if (!parent)
+		return NF_DROP;
+
 	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP)
 		pf = PF_INET;
 	else
@@ -564,8 +580,8 @@ static unsigned int br_nf_forward_ip(uns
 	nf_bridge->mask |= BRNF_BRIDGED;
 	nf_bridge->physoutdev = skb->dev;
 
-	NF_HOOK(pf, NF_IP_FORWARD, skb, bridge_parent(in),
-		bridge_parent(out), br_nf_forward_finish);
+	NF_HOOK(pf, NF_IP_FORWARD, skb, bridge_parent(in), parent,
+		br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
@@ -688,6 +704,8 @@ static unsigned int br_nf_local_out(unsi
 		goto out;
 	}
 	realoutdev = bridge_parent(skb->dev);
+	if (!realoutdev)
+		return NF_DROP;
 
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 	/* iptables should match -o br0.x */
@@ -701,9 +719,11 @@ static unsigned int br_nf_local_out(unsi
 	/* IP forwarded traffic has a physindev, locally
 	 * generated traffic hasn't. */
 	if (realindev != NULL) {
-		if (!(nf_bridge->mask & BRNF_DONT_TAKE_PARENT) &&
-		    has_bridge_parent(realindev))
-			realindev = bridge_parent(realindev);
+		if (!(nf_bridge->mask & BRNF_DONT_TAKE_PARENT) ) {
+			struct net_device *parent = bridge_parent(realindev);
+			if (parent)
+				realindev = parent;
+		}
 
 		NF_HOOK_THRESH(pf, NF_IP_FORWARD, skb, realindev,
 			       realoutdev, br_nf_local_out_finish,
@@ -743,6 +763,9 @@ static unsigned int br_nf_post_routing(u
 	if (!nf_bridge)
 		return NF_ACCEPT;
 
+	if (!realoutdev)
+		return NF_DROP;
+
 	if (skb->protocol == __constant_htons(ETH_P_IP) || IS_VLAN_IP)
 		pf = PF_INET;
 	else

--
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
