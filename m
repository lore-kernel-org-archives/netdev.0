From: Philip Craig <philipc@snapgear.com>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Wed, 02 Aug 2006 16:17:42 +1000
Message-ID: <44D04386.2040705@snapgear.com>
References: <44CDD631.5030008@snapgear.com>	<20060731091423.3327f85e@dxpl.pdx.osdl.net>	<44CEAB31.5090501@snapgear.com> <20060731220822.444f04e4@localhost.localdomain> <44CF1EF8.2090800@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:30855 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1751265AbWHBGRq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 02:17:46 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <44CF1EF8.2090800@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Stephen Hemminger wrote:
>> I am not against making the bridge code smarter to handle other
>> encapsulation.

Here's an updated patch that fixes all issues I am aware of.

It generates a random mac address for gre ports, and also stores
a copy of the mac address for ethernet ports, rather than checking
dev->type everywhere.

The LLC_SAP_BSPAN packets are handled by simply registering that
protocol with dev_add_pack().  This would have worked for my original
patch too.

I had to release __fake_rtable as part of br_nf_dev_queue_xmit(),
otherwise ip_gre.c paniced trying to call skb->dst->ops->update_ptmu.


--- linux-2.6.x/net/bridge/br.c	18 Jun 2006 23:30:55 -0000	1.1.1.17
+++ linux-2.6.x/net/bridge/br.c	2 Aug 2006 06:05:10 -0000
@@ -26,6 +26,11 @@

 int (*br_should_route_hook) (struct sk_buff **pskb) = NULL;

+static struct packet_type br_stp_packet_type = {
+	.type = __constant_htons(LLC_SAP_BSPAN),
+	.func = br_stp_packet_rcv,
+};
+
 static struct llc_sap *br_stp_sap;

 static int __init br_init(void)
@@ -36,6 +41,8 @@ static int __init br_init(void)
 		return -EBUSY;
 	}

+	dev_add_pack(&br_stp_packet_type);
+	
 	br_fdb_init();

 #ifdef CONFIG_BRIDGE_NETFILTER
@@ -56,6 +63,7 @@ static int __init br_init(void)
 static void __exit br_deinit(void)
 {
 	rcu_assign_pointer(br_stp_sap->rcv_func, NULL);
+	dev_remove_pack(&br_stp_packet_type);

 #ifdef CONFIG_BRIDGE_NETFILTER
 	br_netfilter_fini();
--- linux-2.6.x/net/bridge/br_device.c	18 Jun 2006 23:30:55 -0000	1.1.1.14
+++ linux-2.6.x/net/bridge/br_device.c	2 Aug 2006 06:05:10 -0000
@@ -95,7 +95,7 @@ static int br_set_mac_address(struct net

 	spin_lock_bh(&br->lock);
 	list_for_each_entry(port, &br->port_list, list) {
-		if (!compare_ether_addr(port->dev->dev_addr, addr->sa_data)) {
+		if (!compare_ether_addr(port->addr.addr, addr->sa_data)) {
 			br_stp_change_bridge_id(br, addr->sa_data);
 			err = 0;
 			break;
--- linux-2.6.x/net/bridge/br_fdb.c	18 Jun 2006 23:30:55 -0000	1.1.1.13
+++ linux-2.6.x/net/bridge/br_fdb.c	2 Aug 2006 06:05:10 -0000
@@ -24,8 +24,7 @@
 #include "br_private.h"

 static kmem_cache_t *br_fdb_cache __read_mostly;
-static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		      const unsigned char *addr);
+static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source);

 void __init br_fdb_init(void)
 {
@@ -67,7 +66,7 @@ static __inline__ void fdb_delete(struct
 	br_fdb_put(f);
 }

-void br_fdb_changeaddr(struct net_bridge_port *p, const unsigned char *newaddr)
+void br_fdb_changeaddr(struct net_bridge_port *p)
 {
 	struct net_bridge *br = p->br;
 	int i;
@@ -86,7 +85,7 @@ void br_fdb_changeaddr(struct net_bridge
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
+					    !compare_ether_addr(op->addr.addr,
 								f->addr.addr)) {
 						f->dst = op;
 						goto insert;
@@ -101,7 +100,7 @@ void br_fdb_changeaddr(struct net_bridge
 	}
  insert:
 	/* insert new address,  may fail if invalid address or dup. */
-	fdb_insert(br, p, newaddr);
+	fdb_insert(br, p);

 	spin_unlock_bh(&br->hash_lock);
 }
@@ -151,7 +150,7 @@ void br_fdb_delete_by_port(struct net_br
 				struct net_bridge_port *op;
 				list_for_each_entry(op, &br->port_list, list) {
 					if (op != p &&
-					    !compare_ether_addr(op->dev->dev_addr,
+					    !compare_ether_addr(op->addr.addr,
 								f->addr.addr)) {
 						f->dst = op;
 						goto skip_delete;
@@ -291,9 +290,9 @@ static struct net_bridge_fdb_entry *fdb_
 	return fdb;
 }

-static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+static int fdb_insert(struct net_bridge *br, struct net_bridge_port *source)
 {
+	const unsigned char *addr = source->addr.addr;
 	struct hlist_head *head = &br->hash[br_mac_hash(addr)];
 	struct net_bridge_fdb_entry *fdb;

@@ -320,13 +319,12 @@ static int fdb_insert(struct net_bridge
 	return 0;
 }

-int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source,
-		  const unsigned char *addr)
+int br_fdb_insert(struct net_bridge *br, struct net_bridge_port *source)
 {
 	int ret;

 	spin_lock_bh(&br->hash_lock);
-	ret = fdb_insert(br, source, addr);
+	ret = fdb_insert(br, source);
 	spin_unlock_bh(&br->hash_lock);
 	return ret;
 }
--- linux-2.6.x/net/bridge/br_forward.c	18 Jun 2006 23:30:55 -0000	1.1.1.15
+++ linux-2.6.x/net/bridge/br_forward.c	2 Aug 2006 06:05:10 -0000
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
+++ linux-2.6.x/net/bridge/br_if.c	2 Aug 2006 06:05:10 -0000
@@ -21,6 +21,7 @@
 #include <linux/init.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_ether.h>
+#include <linux/etherdevice.h>
 #include <net/sock.h>

 #include "br_private.h"
@@ -391,7 +392,10 @@ int br_add_if(struct net_bridge *br, str
 	struct net_bridge_port *p;
 	int err = 0;

-	if (dev->flags & IFF_LOOPBACK || dev->type != ARPHRD_ETHER)
+	if (dev->flags & IFF_LOOPBACK)
+		return -EINVAL;
+
+	if (dev->type != ARPHRD_ETHER && dev->type != ARPHRD_IPGRE)
 		return -EINVAL;

 	if (dev->hard_start_xmit == br_dev_xmit)
@@ -408,7 +412,12 @@ int br_add_if(struct net_bridge *br, str
 	if (err)
 		goto err0;

- 	err = br_fdb_insert(br, p, dev->dev_addr);
+	if (dev->type == ARPHRD_ETHER)
+		memcpy(p->addr.addr, dev->dev_addr, ETH_ALEN);
+	else
+		random_ether_addr(p->addr.addr);
+
+	err = br_fdb_insert(br, p);
 	if (err)
 		goto err1;

--- linux-2.6.x/net/bridge/br_input.c	18 Jun 2006 23:30:55 -0000	1.1.1.18
+++ linux-2.6.x/net/bridge/br_input.c	2 Aug 2006 06:05:10 -0000
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
--- linux-2.6.x/net/bridge/br_netfilter.c	18 Jun 2006 23:30:55 -0000	1.1.1.25
+++ linux-2.6.x/net/bridge/br_netfilter.c	2 Aug 2006 06:05:10 -0000
@@ -765,14 +765,24 @@ out:
 	return NF_STOLEN;
 }

+static int __br_nf_dev_queue_xmit(struct sk_buff *skb)
+{
+	if (skb->dst == (struct dst_entry *)&__fake_rtable) {
+		dst_release(skb->dst);
+		skb->dst = NULL;
+	}
+
+	return br_dev_queue_push_xmit(skb);
+}
+
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
 	if (skb->protocol == htons(ETH_P_IP) &&
 	    skb->len > skb->dev->mtu &&
 	    !(skb_shinfo(skb)->ufo_size || skb_shinfo(skb)->tso_size))
-		return ip_fragment(skb, br_dev_queue_push_xmit);
+		return ip_fragment(skb, __br_nf_dev_queue_xmit);
 	else
-		return br_dev_queue_push_xmit(skb);
+		return __br_nf_dev_queue_xmit(skb);
 }

 /* PF_BRIDGE/POST_ROUTING ********************************************/
--- linux-2.6.x/net/bridge/br_notify.c	21 Mar 2006 01:35:39 -0000	1.1.1.12
+++ linux-2.6.x/net/bridge/br_notify.c	2 Aug 2006 06:05:10 -0000
@@ -14,6 +14,7 @@
  */

 #include <linux/kernel.h>
+#include <linux/if_arp.h>

 #include "br_private.h"

@@ -48,8 +49,11 @@ static int br_device_event(struct notifi
 		break;

 	case NETDEV_CHANGEADDR:
-		br_fdb_changeaddr(p, dev->dev_addr);
-		br_stp_recalculate_bridge_id(br);
+		if (dev->type == ARPHRD_ETHER) {
+			memcpy(p->addr.addr, dev->dev_addr, ETH_ALEN);
+			br_fdb_changeaddr(p);
+			br_stp_recalculate_bridge_id(br);
+		}
 		break;

 	case NETDEV_CHANGE:
--- linux-2.6.x/net/bridge/br_private.h	18 Jun 2006 23:30:55 -0000	1.1.1.16
+++ linux-2.6.x/net/bridge/br_private.h	2 Aug 2006 06:05:10 -0000
@@ -77,6 +77,7 @@ struct net_bridge_port
 	bridge_id			designated_bridge;
 	u32				path_cost;
 	u32				designated_cost;
+	mac_addr			addr;

 	struct timer_list		forward_delay_timer;
 	struct timer_list		hold_timer;
@@ -139,8 +140,7 @@ extern int br_dev_xmit(struct sk_buff *s
 /* br_fdb.c */
 extern void br_fdb_init(void);
 extern void br_fdb_fini(void);
-extern void br_fdb_changeaddr(struct net_bridge_port *p,
-			      const unsigned char *newaddr);
+extern void br_fdb_changeaddr(struct net_bridge_port *p);
 extern void br_fdb_cleanup(unsigned long arg);
 extern void br_fdb_delete_by_port(struct net_bridge *br,
 			   struct net_bridge_port *p);
@@ -152,8 +152,7 @@ extern void br_fdb_put(struct net_bridge
 extern int br_fdb_fillbuf(struct net_bridge *br, void *buf,
 			  unsigned long count, unsigned long off);
 extern int br_fdb_insert(struct net_bridge *br,
-			 struct net_bridge_port *source,
-			 const unsigned char *addr);
+			 struct net_bridge_port *source);
 extern void br_fdb_update(struct net_bridge *br,
 			  struct net_bridge_port *source,
 			  const unsigned char *addr);
@@ -220,6 +219,9 @@ extern ssize_t br_show_bridge_id(char *b
 /* br_stp_bpdu.c */
 extern int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
 		      struct packet_type *pt, struct net_device *orig_dev);
+extern int br_stp_packet_rcv(struct sk_buff *skb, struct net_device *dev,
+			     struct packet_type *pt,
+			     struct net_device *orig_dev);

 /* br_stp_timer.c */
 extern void br_stp_timer_init(struct net_bridge *br);
--- linux-2.6.x/net/bridge/br_stp_bpdu.c	18 Jun 2006 23:30:55 -0000	1.1.1.9
+++ linux-2.6.x/net/bridge/br_stp_bpdu.c	2 Aug 2006 06:05:10 -0000
@@ -50,7 +50,7 @@ static void br_send_bpdu(struct net_brid
 			    LLC_SAP_BSPAN, LLC_PDU_CMD);
 	llc_pdu_init_as_ui_cmd(skb);

-	llc_mac_hdr_init(skb, p->dev->dev_addr, p->br->group_addr);
+	llc_mac_hdr_init(skb, p->addr.addr, p->br->group_addr);

 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 		dev_queue_xmit);
@@ -124,35 +124,23 @@ void br_send_tcn_bpdu(struct net_bridge_
 	br_send_bpdu(p, buf, 7);
 }

-/*
- * Called from llc.
- *
- * NO locks, but rcu_read_lock (preempt_disabled)
- */
-int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
-	       struct packet_type *pt, struct net_device *orig_dev)
+static void __br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
+			 const unsigned char *dest)
 {
-	const struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
-	const unsigned char *dest = eth_hdr(skb)->h_dest;
 	struct net_bridge_port *p = rcu_dereference(dev->br_port);
 	struct net_bridge *br;
 	const unsigned char *buf;

 	if (!p)
-		goto err;
-
-	if (pdu->ssap != LLC_SAP_BSPAN
-	    || pdu->dsap != LLC_SAP_BSPAN
-	    || pdu->ctrl_1 != LLC_PDU_TYPE_U)
-		goto err;
+		return;

 	if (!pskb_may_pull(skb, 4))
-		goto err;
+		return;

 	/* compare of protocol id and version */
 	buf = skb->data;
 	if (buf[0] != 0 || buf[1] != 0 || buf[2] != 0)
-		goto err;
+		return;

 	br = p->br;
 	spin_lock(&br->lock);
@@ -162,7 +150,7 @@ int br_stp_rcv(struct sk_buff *skb, stru
 	    || !(br->dev->flags & IFF_UP))
 		goto out;

-	if (compare_ether_addr(dest, br->group_addr) != 0)
+	if (dest && compare_ether_addr(dest, br->group_addr) != 0)
 		goto out;

 	buf = skb_pull(skb, 3);
@@ -213,7 +201,39 @@ int br_stp_rcv(struct sk_buff *skb, stru
 	}
  out:
 	spin_unlock(&br->lock);
+}
+
+/*
+ * Called from llc.
+ *
+ * NO locks, but rcu_read_lock (preempt_disabled)
+ */
+int br_stp_rcv(struct sk_buff *skb, struct net_device *dev,
+	       struct packet_type *pt, struct net_device *orig_dev)
+{
+	const struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
+	const unsigned char *dest = eth_hdr(skb)->h_dest;
+
+	if (pdu->ssap != LLC_SAP_BSPAN
+	    || pdu->dsap != LLC_SAP_BSPAN
+	    || pdu->ctrl_1 != LLC_PDU_TYPE_U)
+		goto err;
+
+	__br_stp_rcv(skb, dev, dest);
  err:
 	kfree_skb(skb);
 	return 0;
 }
+
+/*
+ * Called from dev/core.c for protocol LLC_SAP_BSPAN.
+ * This isn't a real ethernet protocol value, but it can occur for bridging
+ * over gre, and its value is less than 1536 so there is no confusion.
+ */
+int br_stp_packet_rcv(struct sk_buff *skb, struct net_device *dev,
+		      struct packet_type *pt, struct net_device *orig_dev)
+{
+	__br_stp_rcv(skb, dev, NULL);
+	kfree_skb(skb);
+	return 0;
+}
--- linux-2.6.x/net/bridge/br_stp_if.c	21 Mar 2006 01:35:39 -0000	1.1.1.13
+++ linux-2.6.x/net/bridge/br_stp_if.c	2 Aug 2006 06:05:10 -0000
@@ -155,8 +155,8 @@ void br_stp_recalculate_bridge_id(struct

 	list_for_each_entry(p, &br->port_list, list) {
 		if (addr == br_mac_zero ||
-		    memcmp(p->dev->dev_addr, addr, ETH_ALEN) < 0)
-			addr = p->dev->dev_addr;
+		    memcmp(p->addr.addr, addr, ETH_ALEN) < 0)
+			addr = p->addr.addr;

 	}

--- linux-2.6.x/include/linux/if_ether.h	18 Jun 2006 23:30:44 -0000	1.1.1.11
+++ linux-2.6.x/include/linux/if_ether.h	2 Aug 2006 06:05:10 -0000
@@ -55,6 +55,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_BRIDGE    0x6558          /* Transparent Ethernet Bridging */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
