From: Bart De Schuymer <bdschuym@pandora.be>
Subject: [PATCH] Fix loopback over bridge port
Date: Sat, 27 Dec 2003 15:36:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312271536.46940.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S.Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

When sending a broadcast from a Linux bridge over a bridge port,
net/ipv4/ip_output.c::ip_dev_loopback_xmit() will send the packet back
to the bridge port. Currently, the bridge code will intercept this
loopback packet and try to bridge it. This is not right, the loopback
packet doesn't even have an Ethernet header. This loopback packet is
intended for the bridge port and should not be stolen by the bridge code.
The patch below fixes this by adding a check in __handle_bridge().
It also changes br_netfilter.c by only doing the paranoid checks of
br_nf_post_routing() when CONFIG_NETFILTER_DEBUG is set. I think the
loopback fix will get rid of any skbuffs matching those paranoid checks.

The patch also introduces/removes some whitespace in br_netfilter.c.

I think the code (in net/ipv4/ip_output.c::ip_dev_loopback_xmit())
__skb_pull(newskb, newskb->nh.raw - newskb->data);
is useless, as data always points to the network header at that moment. But
that's not really my territory...

cheers,
Bart

PS: I see I forgot a decent subject in my previous mail, it should have
read something like "[PATCH] Always copy and save the vlan header in
bridge-nf"


--- linux-2.6.0/net/core/dev.c.old	2003-12-25 17:03:41.000000000 +0100
+++ linux-2.6.0/net/core/dev.c	2003-12-25 17:04:29.000000000 +0100
@@ -1543,7 +1543,7 @@ static inline int __handle_bridge(struct
 			struct packet_type **pt_prev, int *ret)
 {
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-	if (skb->dev->br_port) {
+	if (skb->dev->br_port && skb->pkt_type != PACKET_LOOPBACK) {
 		*ret = handle_bridge(skb, *pt_prev);
 		if (br_handle_frame_hook(skb) == 0)
 			return 1;
--- linux-2.6.0/net/bridge/br_netfilter.c.earlier2	2003-12-25 17:31:49.000000000 +0100
+++ linux-2.6.0/net/bridge/br_netfilter.c	2003-12-25 17:59:28.000000000 +0100
@@ -352,6 +352,7 @@ static unsigned int br_nf_local_in(unsig
 	return NF_ACCEPT;
 }
 
+
 /* PF_BRIDGE/FORWARD *************************************************/
 static int br_nf_forward_finish(struct sk_buff *skb)
 {
@@ -462,6 +463,7 @@ static unsigned int br_nf_forward_arp(un
 	return NF_STOLEN;
 }
 
+
 /* PF_BRIDGE/LOCAL_OUT ***********************************************/
 static int br_nf_local_out_finish(struct sk_buff *skb)
 {
@@ -527,9 +529,7 @@ static unsigned int br_nf_local_out(unsi
 		return NF_ACCEPT;
 
 	nf_bridge = skb->nf_bridge;
-
 	nf_bridge->physoutdev = skb->dev;
-
 	realindev = nf_bridge->physindev;
 
 	/* Bridged, take PF_BRIDGE/FORWARD.
@@ -597,18 +597,15 @@ static unsigned int br_nf_post_routing(u
 	struct vlan_ethhdr *hdr = (struct vlan_ethhdr *)(skb->mac.ethernet);
 	struct net_device *realoutdev = bridge_parent(skb->dev);
 
-	/* Be very paranoid. Must be a device driver bug. */
+#ifdef CONFIG_NETFILTER_DEBUG
+	/* Be very paranoid. This probably won't happen anymore, but let's
+	 * keep the check just to be sure... */
 	if (skb->mac.raw < skb->head || skb->mac.raw + ETH_HLEN > skb->data) {
 		printk(KERN_CRIT "br_netfilter: Argh!! br_nf_post_routing: "
 				 "bad mac.raw pointer.");
-		if (skb->dev != NULL) {
-			printk("[%s]", skb->dev->name);
-			if (has_bridge_parent(skb->dev))
-				printk("[%s]", bridge_parent(skb->dev)->name);
-		}
-		printk(" head:%p, raw:%p\n", skb->head, skb->mac.raw);
-		return NF_ACCEPT;
+		goto print_error;
 	}
+#endif
 
 #ifdef CONFIG_SYSCTL
 	if (!nf_bridge)
@@ -618,13 +615,16 @@ static unsigned int br_nf_post_routing(u
 	if (skb->protocol != __constant_htons(ETH_P_IP) && !IS_VLAN_IP)
 		return NF_ACCEPT;
 
+#ifdef CONFIG_NETFILTER_DEBUG
 	/* Sometimes we get packets with NULL ->dst here (for example,
-	 * running a dhcp client daemon triggers this).
+	 * running a dhcp client daemon triggers this). This should now
+	 * be fixed, but let's keep the check around.
 	 */
-	if (skb->dst == NULL)
-		return NF_ACCEPT;
+	if (skb->dst == NULL) {
+		printk(KERN_CRIT "br_netfilter: skb->dst == NULL.");
+		goto print_error;
+	}
 
-#ifdef CONFIG_NETFILTER_DEBUG
 	skb->nf_debug ^= (1 << NF_IP_POST_ROUTING);
 #endif
 
@@ -651,6 +651,18 @@ static unsigned int br_nf_post_routing(u
 		realoutdev, br_dev_queue_push_xmit);
 
 	return NF_STOLEN;
+
+#ifdef CONFIG_NETFILTER_DEBUG
+print_error:
+	if (skb->dev != NULL) {
+		printk("[%s]", skb->dev->name);
+		if (has_bridge_parent(skb->dev))
+			printk("[%s]", bridge_parent(skb->dev)->name);
+	}
+	printk(" head:%p, raw:%p, data:%p\n", skb->head, skb->mac.raw,
+					      skb->data);
+	return NF_ACCEPT;
+#endif
 }
 
 
