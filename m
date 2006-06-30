From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [4/4] [IPV6]: Added GSO support for TCPv6
Date: Fri, 30 Jun 2006 15:47:02 +1000
Message-ID: <20060630054702.GC30149@gondor.apana.org.au>
References: <20060630054209.GA28558@gondor.apana.org.au> <20060630054300.GA30149@gondor.apana.org.au> <20060630054542.GB30149@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:4875 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751144AbWF3Fsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 01:48:32 -0400
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060630054542.GB30149@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV6]: Added GSO support for TCPv6

This patch adds GSO support for IPv6 and TCPv6.  This is based on a patch
by Ananda Raju <Ananda.Raju@neterion.com>.  His original description is:

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
	| TSO OFF  | 2.00   5.5% id  |  5.66   20.0% id  |
	--------------------------------------------------
	| TSO ON   | 2.63   78.0 id  |  5.67   39.0% id  |
	--------------------------------------------------

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3960,7 +3960,7 @@ static int s2io_xmit(struct sk_buff *skb
 	txdp->Control_2 = 0;
 #ifdef NETIF_F_TSO
 	mss = skb_shinfo(skb)->gso_size;
-	if (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV4) {
+	if (skb_shinfo(skb)->gso_type & (SKB_GSO_TCPV4 | SKB_GSO_TCPV6)) {
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
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -315,9 +315,10 @@ struct net_device
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0xffff0000
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
-#define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_UFO		(SKB_GSO_UDP << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
-#define NETIF_F_TSO_ECN		(SKB_GSO_TCPV4_ECN << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCP_ECN << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO6		(SKB_GSO_TCPV6 << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -171,13 +171,15 @@ enum {
 
 enum {
 	SKB_GSO_TCPV4 = 1 << 0,
-	SKB_GSO_UDPV4 = 1 << 1,
+	SKB_GSO_UDP = 1 << 1,
 
 	/* This indicates the skb is from an untrusted source. */
 	SKB_GSO_DODGY = 1 << 2,
 
 	/* This indicates the tcp segment has CWR set. */
-	SKB_GSO_TCPV4_ECN = 1 << 3,
+	SKB_GSO_TCP_ECN = 1 << 3,
+
+	SKB_GSO_TCPV6 = 1 << 4,
 };
 
 /** 
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -146,7 +146,7 @@ static inline void ip6_dst_store(struct 
 	struct rt6_info *rt = (struct rt6_info *) dst;
 
 	write_lock(&sk->sk_dst_lock);
-	__sk_dst_set(sk, dst);
+	sk_setup_caps(sk, dst);
 	np->daddr_cache = daddr;
 	np->dst_cookie = rt->rt6i_node ? rt->rt6i_node->fn_sernum : 0;
 	write_unlock(&sk->sk_dst_lock);
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -55,9 +55,7 @@ static inline void TCP_ECN_send(struct s
 			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
 				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
 				skb->h.th->cwr = 1;
-				if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
-					skb_shinfo(skb)->gso_type |=
-						SKB_GSO_TCPV4_ECN;
+				skb_shinfo(skb)->gso_type |= SKB_GSO_TCP_ECN;
 			}
 		} else {
 			/* ACK or retransmitted segment: clear ECT|CE */
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
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
 
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -660,8 +660,6 @@ int inet6_sk_rebuild_header(struct sock 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	return 0;
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -187,8 +187,6 @@ int inet6_csk_xmit(struct sk_buff *skb, 
 		}
 
 		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 	}
 
 	skb->dst = dst_clone(dst);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
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
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -270,9 +270,8 @@ static int tcp_v6_connect(struct sock *s
 	ipv6_addr_copy(&np->saddr, saddr);
 	inet->rcv_saddr = LOOPBACK4_IPV6;
 
+	sk->sk_gso_type = SKB_GSO_TCPV6;
 	ip6_dst_store(sk, dst, NULL);
-	sk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	icsk->icsk_ext_hdr_len = 0;
 	if (np->opt)
@@ -930,9 +929,8 @@ static struct sock * tcp_v6_syn_recv_soc
 	 * comment in that function for the gory details. -acme
 	 */
 
+	sk->sk_gso_type = SKB_GSO_TCPV6;
 	ip6_dst_store(newsk, dst, NULL);
-	newsk->sk_route_caps = dst->dev->features &
-		~(NETIF_F_IP_CSUM | NETIF_F_TSO);
 
 	newtcp6sk = (struct tcp6_sock *)newsk;
 	inet_sk(newsk)->pinet6 = &newtcp6sk->inet6;
