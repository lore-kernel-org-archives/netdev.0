From: Ananda Raju <Ananda.Raju@neterion.com>
Subject: [PATCH 2.6.17] support for TSO over IPv6
Date: Thu, 29 Jun 2006 18:18:10 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	Ananda.Raju@neterion.com, sivakumar.subramani@neterion.com,
	Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:58827 "EHLO
	barracuda.mail.s2io.com") by vger.kernel.org with ESMTP
	id S933054AbWF2WSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 18:18:14 -0400
To: netdev@vger.kernel.org, jgarzik@pobox.com, shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, 
	This patch enables TSO over IPv6. Currently Linux network stacks
	restricts TSO over IPv6 by clearing of the NETIF_F_TSO bit from
	"dev->features". This patch will remove this restriction.

	This patch will introduce a new flag NETIF_F_TSO6 which will be used 
	to check whether device supports TSO over IPv6. If device support TSO
	over IPv6 then we don't clear of NETIF_F_TSO and which will make the 
	TCP layer to create TSO packets. Any device supporting TSO over IPv6 
	will set NETIF_F_TSO6 flag in "dev->features" along with NETIF_F_TSO.

	In case when user disables TSO using ethtool, NETIF_F_TSO will get
	cleared from "dev->features". So even if we have NETIF_F_TSO6 we don't
	get TSO packets created by TCP layer. 

	SKB_GSO_TCPV4 renamed to SKB_GSO_TCP to make it generic GSO packet.
	SKB_GSO_UDPV4 renamed to SKB_GSO_UDP as UFO is not a IPv4 feature.
	UFO is supported over IPv6 also

	The following table shows there is significant improvement in
	throughput with normal frames and CPU usage for both normal and jumbo.

        --------------------------------------------------
        |          |     1500        |      9600         |
        |          ------------------|-------------------|
        |          | thru     CPU    |  thru     CPU     |
        --------------------------------------------------
        | TSO OFF  | 2.00   5.5% id  |  5.66   20.0% id   |
        --------------------------------------------------
        | TSO ON   | 2.63   78.0 id  |  5.67   39.0% id  |
        --------------------------------------------------

Please review the patch.
Signed-off-by: Ananda Raju <ananda.raju@neterion.com>
---
diff -upNr netdev.org/drivers/net/s2io.c netdev.ipv6_tso/drivers/net/s2io.c
--- netdev.org/drivers/net/s2io.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/drivers/net/s2io.c	2006-06-27 07:38:48.000000000 -0700
@@ -3960,7 +3960,7 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Control_2 = 0;
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->gso_size;
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4) {
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_TCP) {
 		txdp->Control_1 |= TXD_TCP_LSO_EN;
 		txdp->Control_1 |= TXD_TCP_LSO_MSS(mss);
 	}
@@ -3980,7 +3980,7 @@ static int s2io_xmit(struct sk_buff *skb
 	}
 
 	frg_len = skb->len - skb->data_len;
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4) {
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP) {
 		int ufo_size;
 
 		ufo_size = skb_shinfo(skb)->gso_size;
@@ -4009,7 +4009,7 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Host_Control = (unsigned long) skb;
 	txdp->Control_1 |= TXD_BUFFER0_SIZE(frg_len);
 
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
 		txdp->Control_1 |= TXD_UFO_EN;
 
 	frg_cnt = skb_shinfo(skb)->nr_frags;
@@ -4024,12 +4024,12 @@ static int s2io_xmit(struct sk_buff *skb
 		    (sp->pdev, frag->page, frag->page_offset,
 		     frag->size, PCI_DMA_TODEVICE);
 		txdp->Control_1 = TXD_BUFFER0_SIZE(frag->size);
-		if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
+		if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
 			txdp->Control_1 |= TXD_UFO_EN;
 	}
 	txdp->Control_1 |= TXD_GATHER_CODE_LAST;
 
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
 		frg_cnt++; /* as Txd0 was used for inband header */
 
 	tx_fifo = mac_control->tx_FIFO_start[queue];
@@ -4043,7 +4043,7 @@ static int s2io_xmit(struct sk_buff *skb
 	if (mss)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
 #endif
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDPV4)
+	if (skb_shinfo(skb)->gso_type == SKB_GSO_UDP)
 		val64 |= TX_FIFO_SPECIAL_FUNC;
 	writeq(val64, &tx_fifo->List_Control);
 
@@ -7021,6 +7021,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 #ifdef NETIF_F_TSO
 	dev->features |= NETIF_F_TSO;
 #endif
+#ifdef NETIF_F_TSO6
+	dev->features |= NETIF_F_TSO6;
+#endif
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		dev->features |= NETIF_F_UFO;
 		dev->features |= NETIF_F_HW_CSUM;
diff -upNr netdev.org/include/linux/netdevice.h netdev.ipv6_tso/include/linux/netdevice.h
--- netdev.org/include/linux/netdevice.h	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/include/linux/netdevice.h	2006-06-27 07:38:48.000000000 -0700
@@ -313,8 +313,9 @@ struct net_device
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
-#define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO		(SKB_GSO_TCP << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
diff -upNr netdev.org/include/linux/skbuff.h netdev.ipv6_tso/include/linux/skbuff.h
--- netdev.org/include/linux/skbuff.h	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/include/linux/skbuff.h	2006-06-27 07:38:48.000000000 -0700
@@ -170,8 +170,9 @@ enum {
 };
 
 enum {
-	SKB_GSO_TCPV4 = 1 << 0,
-	SKB_GSO_UDPV4 = 1 << 1,
+	SKB_GSO_TCP = 1 << 0,
+	SKB_GSO_UDP = 1 << 1,
+	SKB_GSO_TCPV6 = 1 << 2,
 };
 
 /** 
diff -upNr netdev.org/net/ipv4/ip_output.c netdev.ipv6_tso/net/ipv4/ip_output.c
--- netdev.org/net/ipv4/ip_output.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv4/ip_output.c	2006-06-27 07:38:48.000000000 -0700
@@ -744,7 +744,7 @@ static inline int ip_ufo_append_data(str
 	if (!err) {
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
 
 		return 0;
@@ -1089,7 +1089,7 @@ ssize_t	ip_append_page(struct sock *sk, 
 	if ((sk->sk_protocol == IPPROTO_UDP) &&
 	    (rt->u.dst.dev->features & NETIF_F_UFO)) {
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 	}
 
 
diff -upNr netdev.org/net/ipv4/tcp_output.c netdev.ipv6_tso/net/ipv4/tcp_output.c
--- netdev.org/net/ipv4/tcp_output.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv4/tcp_output.c	2006-06-27 07:38:48.000000000 -0700
@@ -525,7 +525,7 @@ static void tcp_set_skb_tso_segs(struct 
 		factor /= mss_now;
 		skb_shinfo(skb)->gso_segs = factor;
 		skb_shinfo(skb)->gso_size = mss_now;
-		skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+		skb_shinfo(skb)->gso_type = SKB_GSO_TCP;
 	}
 }
 
diff -upNr netdev.org/net/ipv6/af_inet6.c netdev.ipv6_tso/net/ipv6/af_inet6.c
--- netdev.org/net/ipv6/af_inet6.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/af_inet6.c	2006-06-27 07:38:48.000000000 -0700
@@ -660,8 +660,11 @@ int inet6_sk_rebuild_header(struct sock 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+		if (dst->dev->features & NETIF_F_TSO6)
+			sk->sk_route_caps = dst->dev->features;
+		else
+			sk->sk_route_caps = dst->dev->features &
+					~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	return 0;
diff -upNr netdev.org/net/ipv6/inet6_connection_sock.c netdev.ipv6_tso/net/ipv6/inet6_connection_sock.c
--- netdev.org/net/ipv6/inet6_connection_sock.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/inet6_connection_sock.c	2006-06-27 07:38:48.000000000 -0700
@@ -187,8 +187,11 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+		if (dst->dev->features & NETIF_F_TSO6)
+			sk->sk_route_caps = dst->dev->features;
+		else
+			sk->sk_route_caps = dst->dev->features &
+				~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	skb->dst = dst_clone(dst);
diff -upNr netdev.org/net/ipv6/ip6_output.c netdev.ipv6_tso/net/ipv6/ip6_output.c
--- netdev.org/net/ipv6/ip6_output.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/ip6_output.c	2006-06-27 07:38:48.000000000 -0700
@@ -230,7 +230,7 @@ int ip6_xmit(struct sock *sk, struct sk_
 	skb->priority = sk->sk_priority;
 
 	mtu = dst_mtu(dst);
-	if ((skb->len <= mtu) || ipfragok) {
+	if ((skb->len <= mtu) || ipfragok || skb_shinfo(skb)->gso_size) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTREQUESTS);
 		return NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, dst->dev,
 				dst_output);
@@ -835,7 +835,7 @@ static inline int ip6_ufo_append_data(st
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen - 
 					    sizeof(struct frag_hdr);
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDPV4;
+		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 		ipv6_select_ident(skb, &fhdr);
 		skb_shinfo(skb)->ip6_frag_id = fhdr.identification;
 		__skb_queue_tail(&sk->sk_write_queue, skb);
diff -upNr netdev.org/net/ipv6/tcp_ipv6.c netdev.ipv6_tso/net/ipv6/tcp_ipv6.c
--- netdev.org/net/ipv6/tcp_ipv6.c	2006-06-27 07:30:36.000000000 -0700
+++ netdev.ipv6_tso/net/ipv6/tcp_ipv6.c	2006-06-27 07:38:48.000000000 -0700
@@ -271,8 +271,11 @@ static int tcp_v6_connect(struct sock *s
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
 	ip6_dst_store(sk, dst, NULL);
-	sk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+	if (dst->dev->features & NETIF_F_TSO6)
+		sk->sk_route_caps = dst->dev->features;
+	else
+		sk->sk_route_caps = dst->dev->features &
+				~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
@@ -931,8 +934,11 @@ static struct sock * tcp_v6_syn_recv_soc
 	 */
 
 	ip6_dst_store(newsk, dst, NULL);
-	newsk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+	if (dst->dev->features & NETIF_F_TSO6)
+		sk->sk_route_caps = dst->dev->features;
+	else
+		newsk->sk_route_caps = dst->dev->features &
+				~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;

