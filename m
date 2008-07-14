From: Philip Craig <philipc@snapgear.com>
Subject: Re: bridging with gre tunnel
Date: Mon, 14 Jul 2008 10:41:49 +1000
Message-ID: <487AA0CD.9090600@snapgear.com>
References: <4876FDF0.1030807@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070507080107070304050600"
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:58533 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753763AbYGNAlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 20:41:53 -0400
In-Reply-To: <4876FDF0.1030807@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070507080107070304050600
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit

Timo Teräs wrote:
> Is there newer/better patches to achieve this? Any thoughts about
> doing bridging with gre tunnels?

Here's a patch I did against 2.6.17.

I didn't submit this to mainline though because the userspace ABI
is ugly.  The basic problem is that the struct used for the ioctl
isn't extensible.  The only way I can think of to fix it properly
is to add configuration of gre using netlink, but I never got around
to doing that.  


--------------070507080107070304050600
Content-Type: text/x-diff;
 name="gre-bridge-6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gre-bridge-6.patch"

Subject: ethernet over GRE

- ip tunnel show doesn't work
- iph.id field isn't really appropriate

--- linux-2.6.x/net/ipv4/ip_gre.c	18 Jun 2006 23:30:56 -0000	1.1.1.33
+++ linux-2.6.x/net/ipv4/ip_gre.c	11 Aug 2006 04:10:04 -0000
@@ -30,6 +30,9 @@
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
+#include <linux/if_bridge.h>
+#include <linux/etherdevice.h>
+#include <linux/llc.h>
 
 #include <net/sock.h>
 #include <net/ip.h>
@@ -119,6 +122,7 @@
 
 static int ipgre_tunnel_init(struct net_device *dev);
 static void ipgre_tunnel_setup(struct net_device *dev);
+static void ipgre_ether_tunnel_setup(struct net_device *dev);
 
 /* Fallback tunnel: no source, no destination, no key, no options */
 
@@ -274,7 +278,10 @@ static struct ip_tunnel * ipgre_tunnel_l
 			goto failed;
 	}
 
-	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
+	if (parms->iph.id == htons(ETH_P_BRIDGE))
+		dev = alloc_netdev(sizeof(*t), name, ipgre_ether_tunnel_setup);
+	else
+		dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
 	if (!dev)
 	  return NULL;
 
@@ -550,6 +557,23 @@ ipgre_ecn_encapsulate(u8 tos, struct iph
 	return INET_ECN_encapsulate(tos, inner);
 }
 
+static __be16 ipgre_type_trans(struct sk_buff *skb, struct net_device *dev)
+{
+	if (skb->protocol == htons(ETH_P_BRIDGE)) {
+		if (!pskb_may_pull(skb, ETH_HLEN))
+			return 0;
+		return eth_type_trans(skb, dev);
+	}
+#if defined(CONFIG_BRIDGE) || defined (CONFIG_BRIDGE_MODULE)
+	else if (skb->protocol == htons(LLC_SAP_BSPAN)) {
+		br_stp_rcv_raw(skb, dev);
+		return 0;
+	}
+#endif
+
+	return 0;
+}
+
 static int ipgre_rcv(struct sk_buff *skb)
 {
 	struct iphdr *iph;
@@ -645,6 +669,13 @@ static int ipgre_rcv(struct sk_buff *skb
 			}
 			tunnel->i_seqno = seqno + 1;
 		}
+		if (tunnel->dev->type == ARPHRD_ETHER) {
+			skb->protocol = ipgre_type_trans(skb, tunnel->dev);
+			if (!skb->protocol) {
+				tunnel->stat.rx_errors++;
+				goto drop;
+			}
+		}
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
@@ -678,6 +709,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	struct iphdr  *iph;			/* Our new IP header */
 	int    max_headroom;			/* The extra header space needed */
 	int    gre_hlen;
+	int    push_hlen;
 	u32    dst;
 	int    mtu;
 
@@ -686,11 +718,18 @@ static int ipgre_tunnel_xmit(struct sk_b
 		goto tx_error;
 	}
 
-	if (dev->hard_header) {
-		gre_hlen = 0;
+	if (dev->type == ARPHRD_ETHER) {
+		skb->protocol = htons(ETH_P_BRIDGE);
+		gre_hlen = tunnel->hlen - ETH_HLEN;
+		push_hlen = gre_hlen;
+		tiph = &tunnel->parms.iph;
+	} else if (dev->hard_header) {
+		gre_hlen = tunnel->hlen;
+		push_hlen = 0;
 		tiph = (struct iphdr*)skb->data;
 	} else {
 		gre_hlen = tunnel->hlen;
+		push_hlen = gre_hlen;
 		tiph = &tunnel->parms.iph;
 	}
 
@@ -792,7 +831,8 @@ static int ipgre_tunnel_xmit(struct sk_b
 			}
 		}
 
-		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
+		if (mtu >= IPV6_MIN_MTU &&
+		    mtu < skb->len - tunnel->hlen + push_hlen) {
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu, dev);
 			ip_rt_put(rt);
 			goto tx_error;
@@ -809,7 +849,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 			tunnel->err_count = 0;
 	}
 
-	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen;
+	max_headroom = LL_RESERVED_SPACE(tdev) + push_hlen;
 
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
@@ -828,7 +868,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	}
 
 	skb->h.raw = skb->nh.raw;
-	skb->nh.raw = skb_push(skb, gre_hlen);
+	skb->nh.raw = skb_push(skb, push_hlen);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
 	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
 			      IPSKB_REROUTED);
@@ -863,7 +903,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	((u16*)(iph+1))[1] = skb->protocol;
 
 	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
-		u32 *ptr = (u32*)(((u8*)iph) + tunnel->hlen - 4);
+		u32 *ptr = (u32*)(((u8*)iph) + gre_hlen - 4);
 
 		if (tunnel->parms.o_flags&GRE_SEQ) {
 			++tunnel->o_seqno;
@@ -935,6 +975,8 @@ ipgre_tunnel_ioctl (struct net_device *d
 		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
 		    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
 			goto done;
+		if (p.iph.id != 0 && p.iph.id != htons(ETH_P_BRIDGE))
+			goto done;
 		if (p.iph.ttl)
 			p.iph.frag_off |= htons(IP_DF);
 
@@ -956,7 +998,9 @@ ipgre_tunnel_ioctl (struct net_device *d
 
 				t = netdev_priv(dev);
 
-				if (MULTICAST(p.iph.daddr))
+				if (t->dev->type == ARPHRD_ETHER)
+					nflags = IFF_BROADCAST;
+				else if (MULTICAST(p.iph.daddr))
 					nflags = IFF_BROADCAST;
 				else if (p.iph.daddr)
 					nflags = IFF_POINTOPOINT;
@@ -1147,6 +1191,18 @@ static void ipgre_tunnel_setup(struct ne
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
@@ -1162,8 +1218,27 @@ static int ipgre_tunnel_init(struct net_
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
 
@@ -1179,19 +1254,6 @@ static int ipgre_tunnel_init(struct net_
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
@@ -1212,6 +1274,8 @@ static int ipgre_tunnel_init(struct net_
 		if (tunnel->parms.o_flags&GRE_SEQ)
 			addend += 4;
 	}
+	if (dev->type == ARPHRD_ETHER)
+		addend += ETH_HLEN;
 	dev->hard_header_len = hlen + addend;
 	dev->mtu = mtu - addend;
 	tunnel->hlen = addend;
--- linux-2.6.x/net/bridge/br_netfilter.c	18 Jun 2006 23:30:55 -0000	1.1.1.25
+++ linux-2.6.x/net/bridge/br_netfilter.c	11 Aug 2006 04:10:04 -0000
@@ -765,14 +765,28 @@ out:
 	return NF_STOLEN;
 }
 
+/*
+ * We've finished passing through netfilter, so we can remove the fake dst.
+ * This is required by some lower layers, eg ip_gre
+ */
+static int br_nf_dev_queue_xmit_finish(struct sk_buff *skb)
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
+		return ip_fragment(skb, br_nf_dev_queue_xmit_finish);
 	else
-		return br_dev_queue_push_xmit(skb);
+		return br_nf_dev_queue_xmit_finish(skb);
 }
 
 /* PF_BRIDGE/POST_ROUTING ********************************************/
--- linux-2.6.x/net/bridge/br_stp_bpdu.c	18 Jun 2006 23:30:55 -0000	1.1.1.9
+++ linux-2.6.x/net/bridge/br_stp_bpdu.c	11 Aug 2006 04:10:04 -0000
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
@@ -213,7 +201,34 @@ int br_stp_rcv(struct sk_buff *skb, stru
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
+
  err:
 	kfree_skb(skb);
 	return 0;
 }
+
+void br_stp_rcv_raw(struct sk_buff *skb, struct net_device *dev)
+{
+	rcu_read_lock();
+	__br_stp_rcv(skb, dev, NULL);
+	rcu_read_unlock();
+}
--- linux-2.6.x/include/linux/if_bridge.h	19 Oct 2004 06:13:18 -0000	1.1.1.6
+++ linux-2.6.x/include/linux/if_bridge.h	11 Aug 2006 04:10:04 -0000
@@ -107,6 +107,7 @@ struct __fdb_entry
 extern void brioctl_set(int (*ioctl_hook)(unsigned int, void __user *));
 extern int (*br_handle_frame_hook)(struct net_bridge_port *p, struct sk_buff **pskb);
 extern int (*br_should_route_hook)(struct sk_buff **pskb);
+extern void br_stp_rcv_raw(struct sk_buff *skb, struct net_device *dev);
 
 #endif
 
--- linux-2.6.x/include/linux/if_ether.h	18 Jun 2006 23:30:44 -0000	1.1.1.11
+++ linux-2.6.x/include/linux/if_ether.h	11 Aug 2006 04:10:04 -0000
@@ -55,6 +55,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_BRIDGE    0x6558          /* Transparent Ethernet Bridging */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/

--------------070507080107070304050600
Content-Type: text/x-diff;
 name="gre-bridge-iproute2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="gre-bridge-iproute2.patch"

Index: iproute2/ip/iptunnel.c
===================================================================
RCS file: /cvs/sw/new-wave/user/iproute2/ip/iptunnel.c,v
retrieving revision 1.4
diff -u -p -r1.4 iptunnel.c
--- iproute2/ip/iptunnel.c	17 Sep 2003 10:04:44 -0000	1.4
+++ iproute2/ip/iptunnel.c	11 Aug 2006 04:19:50 -0000
@@ -30,6 +30,7 @@
 #include <net/if_arp.h>
 #include <netinet/in.h>
 
+#include "../lib/if_ether.h"
 #include "if_tunnel.h"
 #include "rt_names.h"
 #include "utils.h"
@@ -186,11 +187,20 @@ static int parse_args(int argc, char **a
 				p->iph.protocol = IPPROTO_IPIP;
 			} else if (strcmp(*argv, "gre") == 0 ||
 				   strcmp(*argv, "gre/ip") == 0) {
-				if (p->iph.protocol && p->iph.protocol != IPPROTO_GRE) {
+				if (p->iph.protocol && (p->iph.protocol != IPPROTO_GRE || p->iph.id != 0)) {
 					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
 					exit(-1);
 				}
 				p->iph.protocol = IPPROTO_GRE;
+			} else if (strcmp(*argv, "eogre") == 0 ||
+				   strcmp(*argv, "ether/gre") == 0 ||
+				   strcmp(*argv, "ether/gre/ip") == 0) {
+				if (p->iph.protocol && (p->iph.protocol != IPPROTO_GRE || p->iph.id != htons(ETH_P_BRIDGE))) {
+					fprintf(stderr,"You managed to ask for more than one tunnel mode.\n");
+					exit(-1);
+				}
+				p->iph.protocol = IPPROTO_GRE;
+				p->iph.id = htons(ETH_P_BRIDGE);
 			} else if (strcmp(*argv, "sit") == 0 ||
 				   strcmp(*argv, "ipv6/ip") == 0) {
 				if (p->iph.protocol && p->iph.protocol != IPPROTO_IPV6) {
@@ -409,8 +419,9 @@ void print_tunnel(struct ip_tunnel_parm 
 	inet_ntop(AF_INET, &p->i_key, s3, sizeof(s3));
 	inet_ntop(AF_INET, &p->o_key, s4, sizeof(s4));
 
-	printf("%s: %s/ip  remote %s  local %s ",
+	printf("%s: %s%s/ip  remote %s  local %s ",
 	       p->name,
+	       p->iph.id == htons(ETH_P_BRIDGE) ? "ether/" : "",
 	       p->iph.protocol == IPPROTO_IPIP ? "ip" :
 	       (p->iph.protocol == IPPROTO_GRE ? "gre" :
 		(p->iph.protocol == IPPROTO_IPV6 ? "ipv6" : "unknown")),
Index: iproute2/lib/if_ether.h
===================================================================
RCS file: /cvs/sw/new-wave/user/iproute2/lib/if_ether.h,v
retrieving revision 1.1
diff -u -p -r1.1 if_ether.h
--- iproute2/lib/if_ether.h	10 Sep 2003 05:25:08 -0000	1.1
+++ iproute2/lib/if_ether.h	11 Aug 2006 04:19:50 -0000
@@ -53,6 +53,7 @@
 #define ETH_P_DIAG      0x6005          /* DEC Diagnostics              */
 #define ETH_P_CUST      0x6006          /* DEC Customer use             */
 #define ETH_P_SCA       0x6007          /* DEC Systems Comms Arch       */
+#define ETH_P_BRIDGE    0x6558          /* Transparent Ethernet Bridging */
 #define ETH_P_RARP      0x8035		/* Reverse Addr Res packet	*/
 #define ETH_P_ATALK	0x809B		/* Appletalk DDP		*/
 #define ETH_P_AARP	0x80F3		/* Appletalk AARP		*/

--------------070507080107070304050600--
