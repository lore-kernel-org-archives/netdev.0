From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26][ARP]: Introduce the arp_hdr_len helper.
Date: Mon, 03 Mar 2008 13:56:40 +0300
Message-ID: <47CBD968.5010008@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34406 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760443AbYCCK4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 05:56:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some place, that calculate the ARP header length. These
calculations are correct, but 
 a) some operate with "magic" constants,
 b) enlarge the code length (sometimes at the cost of coding style),
 c) are not informative from the first glance.

The proposal is to introduce a helper, that includes all the good
sides of these calculations.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 9666434..5fc9d8d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2646,10 +2646,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	if (!slave || !slave_do_arp_validate(bond, slave))
 		goto out_unlock;
 
-	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
-	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
-				 (2 * dev->addr_len) +
-				 (2 * sizeof(u32)))))
+	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
 		goto out_unlock;
 
 	arp = arp_hdr(skb);
diff --git a/include/linux/if_arp.h b/include/linux/if_arp.h
index 296e8e8..4d34018 100644
--- a/include/linux/if_arp.h
+++ b/include/linux/if_arp.h
@@ -156,6 +156,12 @@ static inline struct arphdr *arp_hdr(const struct sk_buff *skb)
 {
 	return (struct arphdr *)skb_network_header(skb);
 }
+
+static inline int arp_hdr_len(struct net_device *dev)
+{
+	/* ARP header, plus 2 device addresses, plus 2 IP addresses. */
+	return sizeof(struct arphdr) + (dev->addr_len + sizeof(u32)) * 2;
+}
 #endif
 
 #endif	/* _LINUX_IF_ARP_H */
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 6faa128..7ae9865 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -384,9 +384,7 @@ static void arp_reply(struct sk_buff *skb)
 	if (skb->dev->flags & IFF_NOARP)
 		return;
 
-	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
-				 (2 * skb->dev->addr_len) +
-				 (2 * sizeof(u32)))))
+	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return;
 
 	skb_reset_network_header(skb);
@@ -414,7 +412,7 @@ static void arp_reply(struct sk_buff *skb)
 	    ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		return;
 
-	size = sizeof(struct arphdr) + 2 * (skb->dev->addr_len + 4);
+	size = arp_hdr_len(skb->dev);
 	send_skb = find_skb(np, size + LL_RESERVED_SPACE(np->dev),
 			    LL_RESERVED_SPACE(np->dev));
 
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 8e17f65..69e80bd 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -570,14 +570,13 @@ struct sk_buff *arp_create(int type, int ptype, __be32 dest_ip,
 	 *	Allocate a buffer
 	 */
 
-	skb = alloc_skb(sizeof(struct arphdr)+ 2*(dev->addr_len+4)
-				+ LL_RESERVED_SPACE(dev), GFP_ATOMIC);
+	skb = alloc_skb(arp_hdr_len(dev) + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
 	if (skb == NULL)
 		return NULL;
 
 	skb_reserve(skb, LL_RESERVED_SPACE(dev));
 	skb_reset_network_header(skb);
-	arp = (struct arphdr *) skb_put(skb,sizeof(struct arphdr) + 2*(dev->addr_len+4));
+	arp = (struct arphdr *) skb_put(skb, arp_hdr_len(dev));
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_ARP);
 	if (src_hw == NULL)
@@ -916,9 +915,7 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto freeskb;
 
 	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
-	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
-				 (2 * dev->addr_len) +
-				 (2 * sizeof(u32)))))
+	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
 		goto freeskb;
 
 	arp = arp_hdr(skb);
diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index c90e75a..f84041d 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -459,10 +459,7 @@ ic_rarp_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (rarp->ar_pro != htons(ETH_P_IP))
 		goto drop;
 
-	if (!pskb_may_pull(skb,
-			   sizeof(struct arphdr) +
-			   (2 * dev->addr_len) +
-			   (2 * 4)))
+	if (!pskb_may_pull(skb, arp_hdr_len(dev)))
 		goto drop;
 
 	/* OK, it is all there and looks valid, process... */
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index a7591ce..9b59044 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -233,10 +233,7 @@ unsigned int arpt_do_table(struct sk_buff *skb,
 	void *table_base;
 	struct xt_table_info *private;
 
-	/* ARP header, plus 2 device addresses, plus 2 IP addresses.  */
-	if (!pskb_may_pull(skb, (sizeof(struct arphdr) +
-				 (2 * skb->dev->addr_len) +
-				 (2 * sizeof(u32)))))
+	if (!pskb_may_pull(skb, arp_hdr_len(skb->dev)))
 		return NF_DROP;
 
 	indev = in ? in->name : nulldevname;
