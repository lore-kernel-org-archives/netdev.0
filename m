From: Philip Craig <philipc@snapgear.com>
Subject: [RFC] gre: transparent ethernet bridging
Date: Mon, 31 Jul 2006 20:06:41 +1000
Message-ID: <44CDD631.5030008@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:41940 "EHLO
	cyberguard.com.au") by vger.kernel.org with ESMTP id S1751257AbWGaKGn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:06:43 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by hex.internal.moreton.com.au (Postfix) with ESMTP id 0E1C5EB94B
	for <netdev@vger.kernel.org>; Mon, 31 Jul 2006 20:06:41 +1000 (EST)
Received: from hex.internal.moreton.com.au ([127.0.0.1])
	by localhost (bne.snapgear.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 11653-04 for <netdev@vger.kernel.org>;
	Mon, 31 Jul 2006 20:06:40 +1000 (EST)
Received: from [10.46.1.56] (philipc0.sw.moreton.com.au [10.46.1.56])
	by hex.internal.moreton.com.au (Postfix) with ESMTP
	for <netdev@vger.kernel.org>; Mon, 31 Jul 2006 20:06:40 +1000 (EST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch implements transparent ethernet bridging for gre tunnels.
There are a few outstanding issues.

There is no way for userspace to select the type of gre tunnel. The
#if 0 near the top of the patch forces all gre tunnels to be bridges.
The problem is that userspace uses an IPPROTO_ to select the type of
tunnel, but both types of gre tunnel are IPPROTO_GRE. I can't see
anything else in struct ip_tunnel_parm that could be used to select
this. One approach that I've seen mentioned in the archives is to add
a netlink interface to replace the tunnel ioctls.

Network loops are bad. See the comments at the top of ip_gre.c for
a description of how gre tunnels handle this normally. But for gre
bridges, we don't want to copy the ttl (it breaks routing protocols),
and we don't want to force DF (we want to bridge 1500 byte packets).
I couldn't think of any solution for this.

Some routers set LLC_SAP_BSPAN in the gre protocol field, and then
give the bpdu packet without any other ethernet/llc header. This patch
currently tries to fake the ethernet/llc header before passing the
packet up, but it is buggy (mac addresses are wrong at least). Maybe a
better approach is to call directly into the bridging code. I didn't try
that at first because it isn't modular, and may break other things that
want to see the packet.


--- linux-2.6.x/net/ipv4/ip_gre.c	18 Jun 2006 23:30:56 -0000	1.1.1.33
+++ linux-2.6.x/net/ipv4/ip_gre.c	31 Jul 2006 09:57:41 -0000
@@ -30,6 +30,8 @@
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/etherdevice.h>
+#include <linux/llc.h>

 #include <net/sock.h>
 #include <net/ip.h>
@@ -41,6 +43,8 @@
 #include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/llc.h>
+#include <net/llc_pdu.h>

 #ifdef CONFIG_IPV6
 #include <net/ipv6.h>
@@ -119,6 +123,7 @@

 static int ipgre_tunnel_init(struct net_device *dev);
 static void ipgre_tunnel_setup(struct net_device *dev);
+static void ipgre_ether_tunnel_setup(struct net_device *dev);

 /* Fallback tunnel: no source, no destination, no key, no options */

@@ -274,7 +279,11 @@ static struct ip_tunnel * ipgre_tunnel_l
 			goto failed;
 	}

+#if 0
 	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
+#else
+	dev = alloc_netdev(sizeof(*t), name, ipgre_ether_tunnel_setup);
+#endif
 	if (!dev)
 	  return NULL;

@@ -550,6 +559,68 @@ ipgre_ecn_encapsulate(u8 tos, struct iph
 	return INET_ECN_encapsulate(tos, inner);
 }

+__be16 ipgre_type_trans(struct sk_buff *skb, int offset)
+{
+	u8     *h = skb->data;
+	__be16 flags = *(__be16*)h;
+	__be16 proto = *(__be16*)(h + 2);
+
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (flags == 0 &&
+	    proto == __constant_htons(ETH_P_WCCP)) {
+		proto = __constant_htons(ETH_P_IP);
+		if ((*(h + offset) & 0xF0) != 0x40)
+			offset += 4;
+	}
+
+	skb->mac.raw = skb->nh.raw;
+	skb->nh.raw = __pskb_pull(skb, offset);
+	skb_postpull_rcsum(skb, skb->h.raw, offset);
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	if (MULTICAST(iph->daddr)) {
+		/* Looped back packet, drop it! */
+		if (((struct rtable*)skb->dst)->fl.iif == 0)
+			return 0;
+		/* tunnel->stat.multicast++; */
+		skb->pkt_type = PACKET_BROADCAST;
+	}
+#endif
+
+	return proto;
+}
+
+extern const u8 br_group_address[ETH_ALEN];
+
+__be16 ipgre_ether_type_trans(struct sk_buff *skb, struct net_device *dev,
+			      int offset)
+{
+	u8     *h = skb->data;
+	__be16 proto = *(__be16*)(h + 2);
+
+	if (proto == htons(ETH_P_BRIDGE)) {
+		if (!pskb_may_pull(skb, offset + ETH_HLEN))
+			return 0;
+		skb_pull_rcsum(skb, offset);
+		return eth_type_trans(skb, dev);
+	} else if (proto == htons(LLC_SAP_BSPAN)) {
+		skb_pull_rcsum(skb, offset);
+
+		llc_pdu_header_init(skb, LLC_PDU_TYPE_U, LLC_SAP_BSPAN,
+				    LLC_SAP_BSPAN, LLC_PDU_CMD);
+		llc_pdu_init_as_ui_cmd(skb);
+
+		llc_mac_hdr_init(skb, dev->dev_addr, dev->dev_addr);
+		skb_pull(skb, ETH_HLEN);
+
+		return htons(ETH_P_802_2);
+	}
+
+	return 0;
+}
+
 static int ipgre_rcv(struct sk_buff *skb)
 {
 	struct iphdr *iph;
@@ -603,32 +674,8 @@ static int ipgre_rcv(struct sk_buff *skb
 	if ((tunnel = ipgre_tunnel_lookup(iph->saddr, iph->daddr, key)) != NULL) {
 		secpath_reset(skb);

-		skb->protocol = *(u16*)(h + 2);
-		/* WCCP version 1 and 2 protocol decoding.
-		 * - Change protocol to IP
-		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
-		 */
-		if (flags == 0 &&
-		    skb->protocol == __constant_htons(ETH_P_WCCP)) {
-			skb->protocol = __constant_htons(ETH_P_IP);
-			if ((*(h + offset) & 0xF0) != 0x40)
-				offset += 4;
-		}
-
-		skb->mac.raw = skb->nh.raw;
-		skb->nh.raw = __pskb_pull(skb, offset);
-		skb_postpull_rcsum(skb, skb->h.raw, offset);
 		memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 		skb->pkt_type = PACKET_HOST;
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (MULTICAST(iph->daddr)) {
-			/* Looped back packet, drop it! */
-			if (((struct rtable*)skb->dst)->fl.iif == 0)
-				goto drop;
-			tunnel->stat.multicast++;
-			skb->pkt_type = PACKET_BROADCAST;
-		}
-#endif

 		if (((flags&GRE_CSUM) && csum) ||
 		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
@@ -645,6 +692,15 @@ static int ipgre_rcv(struct sk_buff *skb
 			}
 			tunnel->i_seqno = seqno + 1;
 		}
+		if (tunnel->dev->type == ARPHRD_ETHER)
+			skb->protocol = ipgre_ether_type_trans(skb, tunnel->dev,
+							       offset);
+		else
+			skb->protocol = ipgre_type_trans(skb, offset);
+		if (!skb->protocol) {
+			tunnel->stat.rx_errors++;
+			goto drop;
+		}
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
@@ -686,7 +742,10 @@ static int ipgre_tunnel_xmit(struct sk_b
 		goto tx_error;
 	}

-	if (dev->hard_header) {
+	if (dev->type == ARPHRD_ETHER) {
+		gre_hlen = tunnel->hlen - ETH_HLEN;
+		tiph = &tunnel->parms.iph;
+	} else if (dev->hard_header) {
 		gre_hlen = 0;
 		tiph = (struct iphdr*)skb->data;
 	} else {
@@ -767,7 +826,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	else
 		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;

-	if (skb->dst)
+	if (skb->dst && skb->dst->ops)
 		skb->dst->ops->update_pmtu(skb->dst, mtu);

 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -849,7 +908,9 @@ static int ipgre_tunnel_xmit(struct sk_b
 	iph->saddr		=	rt->rt_src;

 	if ((iph->ttl = tiph->ttl) == 0) {
-		if (skb->protocol == htons(ETH_P_IP))
+		if (dev->type == ARPHRD_ETHER)
+			iph->ttl = dst_metric(&rt->u.dst, RTAX_HOPLIMIT);
+		else if (skb->protocol == htons(ETH_P_IP))
 			iph->ttl = old_iph->ttl;
 #ifdef CONFIG_IPV6
 		else if (skb->protocol == htons(ETH_P_IPV6))
@@ -860,7 +921,10 @@ static int ipgre_tunnel_xmit(struct sk_b
 	}

 	((u16*)(iph+1))[0] = tunnel->parms.o_flags;
-	((u16*)(iph+1))[1] = skb->protocol;
+	if (dev->type == ARPHRD_ETHER)
+		((__be16*)(iph+1))[1] = htons(ETH_P_BRIDGE);
+	else
+		((__be16*)(iph+1))[1] = skb->protocol;

 	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
 		u32 *ptr = (u32*)(((u8*)iph) + tunnel->hlen - 4);
@@ -956,7 +1020,9 @@ ipgre_tunnel_ioctl (struct net_device *d

 				t = netdev_priv(dev);

-				if (MULTICAST(p.iph.daddr))
+				if (t->dev->type == ARPHRD_ETHER)
+					nflags = IFF_BROADCAST;
+				else if (MULTICAST(p.iph.daddr))
 					nflags = IFF_BROADCAST;
 				else if (p.iph.daddr)
 					nflags = IFF_POINTOPOINT;
@@ -1147,6 +1213,18 @@ static void ipgre_tunnel_setup(struct ne
 	dev->addr_len		= 4;
 }

+static void ipgre_ether_tunnel_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	SET_MODULE_OWNER(dev);
+	dev->uninit		= ipgre_tunnel_uninit;
+	dev->destructor 	= free_netdev;
+	dev->hard_start_xmit	= ipgre_tunnel_xmit;
+	dev->get_stats		= ipgre_tunnel_get_stats;
+	dev->do_ioctl		= ipgre_tunnel_ioctl;
+}
+
 static int ipgre_tunnel_init(struct net_device *dev)
 {
 	struct net_device *tdev = NULL;
@@ -1162,8 +1240,27 @@ static int ipgre_tunnel_init(struct net_
 	tunnel->dev = dev;
 	strcpy(tunnel->parms.name, dev->name);

-	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+	if (dev->type == ARPHRD_ETHER)
+		random_ether_addr(dev->dev_addr);
+	else {
+		memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+		memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+	}
+
+	if (dev->type == ARPHRD_ETHER)
+		dev->flags |= IFF_BROADCAST;
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	else if (MULTICAST(iph->daddr)) {
+		if (!iph->saddr)
+			return -EINVAL;
+		dev->flags = IFF_BROADCAST;
+		dev->hard_header = ipgre_header;
+		dev->open = ipgre_open;
+		dev->stop = ipgre_close;
+	}
+#endif
+	else if (iph->daddr)
+		dev->flags |= IFF_POINTOPOINT;

 	/* Guess output device to choose reasonable mtu and hard_header_len */

@@ -1179,19 +1276,6 @@ static int ipgre_tunnel_init(struct net_
 			tdev = rt->u.dst.dev;
 			ip_rt_put(rt);
 		}
-
-		dev->flags |= IFF_POINTOPOINT;
-
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (MULTICAST(iph->daddr)) {
-			if (!iph->saddr)
-				return -EINVAL;
-			dev->flags = IFF_BROADCAST;
-			dev->hard_header = ipgre_header;
-			dev->open = ipgre_open;
-			dev->stop = ipgre_close;
-		}
-#endif
 	}

 	if (!tdev && tunnel->parms.link)
@@ -1212,6 +1296,8 @@ static int ipgre_tunnel_init(struct net_
 		if (tunnel->parms.o_flags&GRE_SEQ)
 			addend += 4;
 	}
+	if (dev->type == ARPHRD_ETHER)
+		addend += ETH_HLEN;
 	dev->hard_header_len = hlen + addend;
 	dev->mtu = mtu - addend;
 	tunnel->hlen = addend;
--- linux-2.6.x/include/linux/if_ether.h	18 Jun 2006 23:30:44 -0000	1.1.1.11
+++ linux-2.6.x/include/linux/if_ether.h	31 Jul 2006 09:57:41 -0000
@@ -55,6 +55,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_BRIDGE    0x6558          /* Transparent Ethernet Bridging */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/
