From: jamal <hadi@cyberus.ca>
Subject: patch: tunnels not setting inputdev
Date: 31 Dec 2004 12:16:33 -0500
Message-ID: <1104513392.1048.316.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-qFQt6HEKMQ274NM9KnwZ"
Cc: netdev@oss.sgi.com, Wichert Akkerman <wichert@wiggy.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-qFQt6HEKMQ274NM9KnwZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Dave,

Patch attached that has tunnels setting input dev correctly. 

Incorporates what ive sent to Wichert already.

A lot of the stuff the tunnels do is very similar, so maybe wiser to
have something like tunnel_type_trans().

cheers,
jamal

--=-qFQt6HEKMQ274NM9KnwZ
Content-Disposition: attachment; filename=indev-patch
Content-Type: text/plain; name=indev-patch; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:00:25	1.1
+++ 2610-bk1/net/ipv4/xfrm4_input.c	2004/12/31 17:01:05
@@ -142,6 +142,7 @@
 			dst_release(skb->dst);
 			skb->dst = NULL;
 		}
+		skb->input_dev = skb->dev;
 		netif_rx(skb);
 		return 0;
 	} else {
--- 2610-bk1/net/ipv4/ipmr.c	2004/12/31 17:01:24	1.1
+++ 2610-bk1/net/ipv4/ipmr.c	2004/12/31 17:01:54
@@ -1461,6 +1461,7 @@
 	((struct net_device_stats*)reg_dev->priv)->rx_bytes += skb->len;
 	((struct net_device_stats*)reg_dev->priv)->rx_packets++;
 	nf_reset(skb);
+	skb->input_dev = skb->dev;
 	netif_rx(skb);
 	dev_put(reg_dev);
 	return 0;
@@ -1516,6 +1517,7 @@
 	((struct net_device_stats*)reg_dev->priv)->rx_bytes += skb->len;
 	((struct net_device_stats*)reg_dev->priv)->rx_packets++;
 	skb->dst = NULL;
+	skb->input_dev = skb->dev;
 	nf_reset(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
--- 2610-bk1/net/ipv4/ip_gre.c	2004/12/31 17:02:02	1.1
+++ 2610-bk1/net/ipv4/ip_gre.c	2004/12/31 17:03:08
@@ -655,6 +655,7 @@
 		skb->dst = NULL;
 		nf_reset(skb);
 		ipgre_ecn_decapsulate(iph, skb);
+		skb->input_dev = skb->dev;
 		netif_rx(skb);
 		read_unlock(&ipgre_lock);
 		return(0);
--- 2610-bk1/net/ipv4/ipip.c	2004/12/31 17:03:24	1.1
+++ 2610-bk1/net/ipv4/ipip.c	2004/12/31 17:03:52
@@ -497,6 +497,7 @@
 		skb->dst = NULL;
 		nf_reset(skb);
 		ipip_ecn_decapsulate(iph, skb);
+		skb->input_dev = skb->dev;
 		netif_rx(skb);
 		read_unlock(&ipip_lock);
 		return 0;
--- 2610-bk1/net/ipv6/ip6_tunnel.c	2004/12/31 17:06:12	1.1
+++ 2610-bk1/net/ipv6/ip6_tunnel.c	2004/12/31 17:07:03
@@ -547,6 +547,7 @@
 		ip6ip6_ecn_decapsulate(ipv6h, skb);
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;
+		skb->input_dev = skb->dev;
 		netif_rx(skb);
 		read_unlock(&ip6ip6_lock);
 		return 0;
--- 2610-bk1/net/ipv6/xfrm6_input.c	2004/12/31 17:07:18	1.1
+++ 2610-bk1/net/ipv6/xfrm6_input.c	2004/12/31 17:07:45
@@ -126,6 +126,7 @@
 			dst_release(skb->dst);
 			skb->dst = NULL;
 		}
+		skb->input_dev = skb->dev;
 		netif_rx(skb);
 		return -1;
 	} else {
--- a/net/ipv4/ip_output.c	2004/12/31 14:26:08	1.1
+++ b/net/ipv4/ip_output.c	2004/12/31 14:27:53
@@ -111,6 +111,7 @@
 #ifdef CONFIG_NETFILTER_DEBUG
 	nf_debug_ip_loopback_xmit(newskb);
 #endif
+	newskb->input_dev = newskb->dev;
 	netif_rx(newskb);
 	return 0;
 }
--- a/net/ipv6/ip6_output.c	2004-12-24 16:33:51.000000000 -0500
+++ b/net/ipv6/ip6_output.c	2004-12-31 10:29:47.505392096 -0500
@@ -102,7 +102,7 @@
 	newskb->pkt_type = PACKET_LOOPBACK;
 	newskb->ip_summed = CHECKSUM_UNNECESSARY;
 	BUG_TRAP(newskb->dst);
-
+	newskb->input_dev = newskb->dev;
 	netif_rx(newskb);
 	return 0;
 }
--- a/net/ipv6/sit.c	2004/12/31 11:03:32	1.1
+++ b/net/ipv6/sit.c	2004/12/31 11:06:50
@@ -385,7 +385,7 @@
 		skb->pkt_type = PACKET_HOST;
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
-		skb->dev = tunnel->dev;
+		skb->input_dev = skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
 		nf_reset(skb);

--=-qFQt6HEKMQ274NM9KnwZ--
