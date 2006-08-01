From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Tue, 01 Aug 2006 19:29:28 +1000
Message-ID: <44CF1EF8.2090800@snapgear.com>
References: <44CDD631.5030008@snapgear.com>	<20060731091423.3327f85e@dxpl.pdx.osdl.net>	<44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:9955 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S932442AbWHAJ3b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 05:29:31 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060731220822.444f04e4@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I am not against making the bridge code smarter to handle other
> encapsulation.

Do you mean something like this patch?

The only drawback I see for this approach is that it means you
can only encapsulate the ethernet header if the gre interface is
bridged.  That's not too bad a restriction though.

This patch only works for local packets so far, and doesn't
handle the LLC_SAP_BSPAN packets.

Also, if the gre interface is the only port on the bridge, then
we have no mac address.


--- linux-2.6.x/net/bridge/br_device.c	18 Jun 2006 23:30:55 -0000	1.1.1.14
+++ linux-2.6.x/net/bridge/br_device.c	1 Aug 2006 09:12:42 -0000
@@ -17,6 +17,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/if_arp.h>

 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -95,7 +96,9 @@ static int br_set_mac_address(struct net

 	spin_lock_bh(&br->lock);
 	list_for_each_entry(port, &br->port_list, list) {
-		if (!compare_ether_addr(port->dev->dev_addr, addr->sa_data)) {
+		if (port->dev->type == ARPHRD_ETHER &&
+				!compare_ether_addr(port->dev->dev_addr,
+						    addr->sa_data)) {
 			br_stp_change_bridge_id(br, addr->sa_data);
 			err = 0;
 			break;
--- linux-2.6.x/net/bridge/br_fdb.c	18 Jun 2006 23:30:55 -0000	1.1.1.13
+++ linux-2.6.x/net/bridge/br_fdb.c	1 Aug 2006 09:12:42 -0000
@@ -20,6 +20,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/jhash.h>
+#include <linux/if_arp.h>
 #include <asm/atomic.h>
 #include "br_private.h"

@@ -86,6 +87,7 @@ void br_fdb_changeaddr(struct net_bridge
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
+					    op->dev->type == ARPHRD_ETHER &&
 					    !compare_ether_addr(op->dev->dev_addr,
 								f->addr.addr)) {
 						f->dst = op;
@@ -151,6 +153,7 @@ void br_fdb_delete_by_port(struct net_br
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
+					    op->dev->type == ARPHRD_ETHER &&
 					    !compare_ether_addr(op->dev->dev_addr,
 								f->addr.addr)) {
 						f->dst = op;
--- linux-2.6.x/net/bridge/br_forward.c	18 Jun 2006 23:30:55 -0000	1.1.1.15
+++ linux-2.6.x/net/bridge/br_forward.c	1 Aug 2006 09:12:42 -0000
@@ -18,6 +18,7 @@
 #include <linux/skbuff.h>
 #include <linux/if_vlan.h>
 #include <linux/netfilter_bridge.h>
+#include <linux/if_arp.h>
 #include "br_private.h"

 static inline int should_deliver(const struct net_bridge_port *p,
@@ -46,6 +47,8 @@ int br_dev_queue_push_xmit(struct sk_buf
 		nf_bridge_maybe_copy_header(skb);
 #endif
 		skb_push(skb, ETH_HLEN);
+		if (skb->dev->type == ARPHRD_IPGRE)
+			skb->protocol = htons(ETH_P_BRIDGE);

 		dev_queue_xmit(skb);
 	}
--- linux-2.6.x/net/bridge/br_if.c	18 Jun 2006 23:30:55 -0000	1.1.1.23
+++ linux-2.6.x/net/bridge/br_if.c	1 Aug 2006 09:12:42 -0000
@@ -391,7 +391,10 @@ int br_add_if(struct net_bridge *br, str
 	struct net_bridge_port *p;
 	int err = 0;

-	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
+	if (dev->flags & IFF_LOOPBACK)
+		return -EINVAL;
+
+	if (dev->type != ARPHRD_ETHER && dev->type != ARPHRD_IPGRE)
 		return -EINVAL;

 	if (dev->hard_start_xmit == br_dev_xmit)
@@ -408,9 +411,11 @@ int br_add_if(struct net_bridge *br, str
 	if (err)
 		goto err0;

- 	err = br_fdb_insert(br, p, dev->dev_addr);
-	if (err)
-		goto err1;
+	if (dev->type == ARPHRD_ETHER) {
+ 		err = br_fdb_insert(br, p, dev->dev_addr);
+		if (err)
+			goto err1;
+	}

 	err = br_sysfs_addif(p);
 	if (err)
--- linux-2.6.x/net/bridge/br_input.c	18 Jun 2006 23:30:55 -0000	1.1.1.18
+++ linux-2.6.x/net/bridge/br_input.c	1 Aug 2006 09:12:42 -0000
@@ -17,6 +17,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/netfilter_bridge.h>
+#include <linux/if_arp.h>
 #include "br_private.h"

 /* Bridge group multicast address 802.1d (pg 51). */
@@ -124,11 +125,22 @@ static inline int is_link_local(const un
 int br_handle_frame(struct net_bridge_port *p, struct sk_buff **pskb)
 {
 	struct sk_buff *skb = *pskb;
-	const unsigned char *dest = eth_hdr(skb)->h_dest;
+	const unsigned char *dest;
+
+	if (skb->dev->type == ARPHRD_IPGRE) {
+		if (skb->protocol != htons(ETH_P_BRIDGE))
+			return 0;
+		if (!pskb_may_pull(skb, ETH_HLEN))
+			goto err;
+		skb->protocol = eth_type_trans(skb, p->br->dev);
+		skb_postpull_rcsum(skb, skb->mac.raw, ETH_HLEN);
+		skb->nh.raw += ETH_HLEN;
+	}

 	if (!is_valid_ether_addr(eth_hdr(skb)->h_source))
 		goto err;

+	dest = eth_hdr(skb)->h_dest;
 	if (unlikely(is_link_local(dest))) {
 		skb->pkt_type = PACKET_HOST;
 		return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
--- linux-2.6.x/net/bridge/br_notify.c	21 Mar 2006 01:35:39 -0000	1.1.1.12
+++ linux-2.6.x/net/bridge/br_notify.c	1 Aug 2006 09:12:42 -0000
@@ -14,6 +14,7 @@
  */

 #include <linux/kernel.h>
+#include <linux/if_arp.h>

 #include "br_private.h"

@@ -48,8 +49,10 @@ static int br_device_event(struct notifi
 		break;

 	case NETDEV_CHANGEADDR:
-		br_fdb_changeaddr(p, dev->dev_addr);
-		br_stp_recalculate_bridge_id(br);
+		if (dev->type == ARPHRD_ETHER) {
+			br_fdb_changeaddr(p, dev->dev_addr);
+			br_stp_recalculate_bridge_id(br);
+		}
 		break;

 	case NETDEV_CHANGE:
--- linux-2.6.x/include/linux/if_ether.h	18 Jun 2006 23:30:44 -0000	1.1.1.11
+++ linux-2.6.x/include/linux/if_ether.h	1 Aug 2006 09:12:42 -0000
@@ -55,6 +55,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_BRIDGE    0x6558          /* Transparent Ethernet Bridging */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
