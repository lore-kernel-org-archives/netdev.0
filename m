From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [PATCH 2.6.17-rc5] support for TSO over IPv6.
Date: Mon, 5 Jun 2006 15:09:45 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10606051458530.20246-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, ravinandan.arakali@neterion.com,
	rapuru.sriram@neterion.com, ananda.raju@neterion.com,
	sivakumar.subramani@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:42448 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S1751185AbWFETJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 15:09:48 -0400
To: netdev@vger.kernel.org, jgarzik@pobox.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
	Neterion Xframe adapter supports TSO over IPv6 but the linux kernel 
	don't support TSO over Ipv6. This patch will allow TCP
	Segmentation Offload (TSO) packets to be created over IPv6. 
	
	The following table shows there is significant improvement in
	throughput with normal frames and CPU usage for both normal and jumbo.

        --------------------------------------------------
        |          |     1500        |      9600         |
        |          ------------------|-------------------|
        |          | thru     CPU    |  thru     CPU     |
        --------------------------------------------------
        | TSO OFF  | 1.80   2.0% id  |  5.53   1.0% id   |
        --------------------------------------------------
        | TSO ON   | 2.61   74.0 id  |  5.52   32.0% id  |
        --------------------------------------------------

Please review the patch.

Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr netdev.org/drivers/net/s2io.c netdev.ipv6_tso/drivers/net/s2io.c
--- netdev.org/drivers/net/s2io.c	2006-06-02 07:29:22.000000000 -0700
+++ netdev.ipv6_tso/drivers/net/s2io.c	2006-06-02 09:37:50.000000000 -0700
@@ -6211,6 +6211,7 @@ Defaulting to INTA\n");
 #endif
 
 	dev->features |= NETIF_F_SG | NETIF_F_IP_CSUM;
+	dev->features |= NETIF_F_IP6_CSUM;
 	if (sp->high_dma_flag == TRUE)
 		dev->features |= NETIF_F_HIGHDMA;
 #ifdef NETIF_F_TSO
diff -upNr netdev.org/include/linux/netdevice.h netdev.ipv6_tso/include/linux/netdevice.h
--- netdev.org/include/linux/netdevice.h	2006-06-02 07:28:21.000000000 -0700
+++ netdev.ipv6_tso/include/linux/netdevice.h	2006-06-02 08:30:54.000000000 -0700
@@ -310,6 +310,7 @@ struct net_device
 #define NETIF_F_TSO		2048	/* Can offload TCP/IP segmentation */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
 #define NETIF_F_UFO             8192    /* Can offload UDP Large Send*/
+#define NETIF_F_IP6_CSUM	16384   /* Can checksum TCP/UDP over IPv6 */
 
 	struct net_device	*next_sched;
 
diff -upNr netdev.org/net/ipv6/af_inet6.c netdev.ipv6_tso/net/ipv6/af_inet6.c
--- netdev.org/net/ipv6/af_inet6.c	2006-06-02 06:51:57.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/af_inet6.c	2006-06-02 09:56:05.000000000 -0700
@@ -660,8 +660,11 @@ int inet6_sk_rebuild_header(struct sock 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+		if (dst->dev->features & NETIF_F_IP6_CSUM)
+			sk->sk_route_caps = dst->dev->features;
+		else
+			sk->sk_route_caps = dst->dev->features &
+				~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	return 0;
diff -upNr netdev.org/net/ipv6/inet6_connection_sock.c netdev.ipv6_tso/net/ipv6/inet6_connection_sock.c
--- netdev.org/net/ipv6/inet6_connection_sock.c	2006-06-02 06:52:06.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/inet6_connection_sock.c	2006-06-02 09:54:50.000000000 -0700
@@ -187,8 +187,11 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+		if (dst->dev->features & NETIF_F_IP6_CSUM)
+			sk->sk_route_caps = dst->dev->features;
+		else
+			sk->sk_route_caps = dst->dev->features &
+				~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	skb->dst = dst_clone(dst);
diff -upNr netdev.org/net/ipv6/ip6_output.c netdev.ipv6_tso/net/ipv6/ip6_output.c
--- netdev.org/net/ipv6/ip6_output.c	2006-06-02 06:55:31.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/ip6_output.c	2006-06-02 08:50:29.000000000 -0700
@@ -147,7 +147,8 @@ static int ip6_output2(struct sk_buff *s
 
 int ip6_output(struct sk_buff *skb)
 {
-	if ((skb->len > dst_mtu(skb->dst) && !skb_shinfo(skb)->ufo_size) ||
+	if ((skb->len > dst_mtu(skb->dst) &&
+	     !(skb_shinfo(skb)->tso_size || skb_shinfo(skb)->ufo_size)) ||
 				dst_allfrag(skb->dst))
 		return ip6_fragment(skb, ip6_output2);
 	else
@@ -229,7 +230,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	skb->priority = sk->sk_priority;
 
 	mtu = dst_mtu(dst);
-	if ((skb->len <= mtu) || ipfragok) {
+	if ((skb->len <= mtu) || ipfragok || skb_shinfo(skb)->tso_size) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
diff -upNr netdev.org/net/ipv6/tcp_ipv6.c netdev.ipv6_tso/net/ipv6/tcp_ipv6.c
--- netdev.org/net/ipv6/tcp_ipv6.c	2006-06-02 06:52:12.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/tcp_ipv6.c	2006-06-02 09:59:01.000000000 -0700
@@ -271,8 +271,12 @@ static int tcp_v6_connect(struct sock *s
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
 	ip6_dst_store(sk, dst, NULL);
-	sk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+
+	if (dst->dev->features & NETIF_F_IP6_CSUM)
+		sk->sk_route_caps = dst->dev->features;
+	else
+		sk->sk_route_caps = dst->dev->features &
+			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
@@ -931,8 +935,12 @@ static struct sock * tcp_v6_syn_recv_soc
 	 */
 
 	ip6_dst_store(newsk, dst, NULL);
-	newsk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+
+	if (dst->dev->features & NETIF_F_IP6_CSUM)
+		newsk->sk_route_caps = dst->dev->features;
+	else
+		newsk->sk_route_caps = dst->dev->features &
+			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;

