From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Wed, 17 Dec 2003 19:27:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200312171927.43433.bdschuym@pandora.be>
References: <Pine.LNX.4.44.0312170835050.8743-100000@sorbus2.navaho>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Steve Hill <steve@navaho.co.uk>
In-Reply-To: <Pine.LNX.4.44.0312170835050.8743-100000@sorbus2.navaho>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wednesday 17 December 2003 09:36, Steve Hill wrote:
> On Tue, 16 Dec 2003, Bart De Schuymer wrote:
> > OK, I think the patch below should fix it, my previous patch is still
> > valid. I'll send a combined patch once it's confirmed this fixes the bug.
>
> Yep, this seems to fix the problem.  Thanks.

Cool,

Dave, here's the patch, nf_bridge_info.hh is renamed to nf_bridge_info.data,
the bridge-nf IP code no longer uses the control buffer and a very
necessary call of nf_bridge_put is added.

cheers,
Bart


--- linux-2.6.0-test11-bk10/include/linux/skbuff.h.old	2003-12-17 08:12:12.000000000 +0100
+++ linux-2.6.0-test11-bk10/include/linux/skbuff.h	2003-12-17 08:12:38.000000000 +0100
@@ -107,7 +107,7 @@ struct nf_bridge_info {
 	struct net_device *netoutdev;
 #endif
 	unsigned int mask;
-	unsigned long hh[32 / sizeof(unsigned long)];
+	unsigned long data[32 / sizeof(unsigned long)];
 };
 #endif
 
--- linux-2.6.0-test11-bk10/include/linux/netfilter_bridge.h.old	2003-12-17 08:08:21.000000000 +0100
+++ linux-2.6.0-test11-bk10/include/linux/netfilter_bridge.h	2003-12-17 08:09:19.000000000 +0100
@@ -73,11 +73,11 @@ void nf_bridge_maybe_copy_header(struct 
 	if (skb->nf_bridge) {
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 		if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
-			memcpy(skb->data - 18, skb->nf_bridge->hh, 18);
+			memcpy(skb->data - 18, skb->nf_bridge->data, 18);
 			skb_push(skb, 4);
 		} else
 #endif
-			memcpy(skb->data - 16, skb->nf_bridge->hh, 16);
+			memcpy(skb->data - 16, skb->nf_bridge->data, 16);
 	}
 }
 
@@ -90,7 +90,7 @@ void nf_bridge_save_header(struct sk_buf
 	if (skb->protocol == __constant_htons(ETH_P_8021Q))
 		header_size = 18;
 #endif
-	memcpy(skb->nf_bridge->hh, skb->data - header_size, header_size);
+	memcpy(skb->nf_bridge->data, skb->data - header_size, header_size);
 }
 
 struct bridge_skb_cb {
--- linux-2.6.0-test11-bk10/net/bridge/br_netfilter.c.old	2003-12-16 08:33:35.000000000 +0100
+++ linux-2.6.0-test11-bk10/net/bridge/br_netfilter.c	2003-12-17 08:08:08.000000000 +0100
@@ -38,11 +38,9 @@
 
 
 #define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
-				 (skb->cb))->daddr.ipv4)
+				 (skb->nf_bridge->data))->daddr.ipv4)
 #define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = (skb)->nh.iph->daddr)
 #define dnat_took_place(skb)	 (skb_origaddr(skb) != (skb)->nh.iph->daddr)
-#define clear_cb(skb)		 (memset(&skb_origaddr(skb), 0, \
-				 sizeof(struct bridge_skb_cb)))
 
 #define has_bridge_parent(device)	((device)->br_port != NULL)
 #define bridge_parent(device)		((device)->br_port->br->dev)
@@ -203,7 +201,6 @@ bridged_dnat:
 				 */
 				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
-				clear_cb(skb);
 				if (skb->protocol ==
 				    __constant_htons(ETH_P_8021Q)) {
 					skb_push(skb, VLAN_HLEN);
@@ -224,7 +221,6 @@ bridged_dnat:
 		dst_hold(skb->dst);
 	}
 
-	clear_cb(skb);
 	skb->dev = nf_bridge->physindev;
 	if (skb->protocol == __constant_htons(ETH_P_8021Q)) {
 		skb_push(skb, VLAN_HLEN);
--- linux-2.6.0-test11-bk10/net/ipv4/ip_output.c.old	2003-12-16 22:05:02.000000000 +0100
+++ linux-2.6.0-test11-bk10/net/ipv4/ip_output.c	2003-12-16 22:36:02.000000000 +0100
@@ -417,6 +417,7 @@ static void ip_copy_metadata(struct sk_b
 	to->nfct = from->nfct;
 	nf_conntrack_get(to->nfct);
 #ifdef CONFIG_BRIDGE_NETFILTER
+	nf_bridge_put(to->nf_bridge);
 	to->nf_bridge = from->nf_bridge;
 	nf_bridge_get(to->nf_bridge);
 #endif
