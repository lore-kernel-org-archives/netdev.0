From: Nivedita Singhvi <niv@us.ibm.com>
Subject: [Patch 2.5.43] IpInDelivers, IpInDiscards
Date: Thu, 17 Oct 2002 14:49:04 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210171428520.3131-100000@w-nivedita.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch cleans up the use of the SNMP stats counters
IpInDelivers and IpInDiscards (and the v6 counterparts). 
A patch to address some of this had been submitted a while 
ago by Mark Price.

Specifically this patch:

- removes increments of IpInDelivers and IpInDiscards from
  upper level protocols and moves them to the IP layer.  
  (upper layer protocols neednt know whether it was ip or
  ip6 that delivered the packet (eg what we might have in sctp))

- it also eliminates the subsequent atomic decrement of
  IpInDelivers when UDP drops a packet and the current
  duplicate incrementing of IpInDelivers for multicast packets.

- leaves drops in raw sockets unaccounted for, at the moment.
  (that, along with remaining stats stuff will be addressed in
  subsequent patches if this is approved)

thanks, 
Nivedita


diff -urN linux-2.5.43/net/ipv4/ip_input.c linux-2.5.43s1/net/ipv4/ip_input.c
--- linux-2.5.43/net/ipv4/ip_input.c	Tue Oct 15 20:27:12 2002
+++ linux-2.5.43s1/net/ipv4/ip_input.c	Thu Oct 17 14:23:51 2002
@@ -237,11 +237,13 @@
 				protocol = -ret;
 				goto resubmit;
 			}
+			IP_INC_STATS_BH(IpInDelivers);
 		} else {
 			if (!raw_sk) {
 				icmp_send(skb, ICMP_DEST_UNREACH,
 					  ICMP_PROT_UNREACH, 0);
-			}
+			} else
+				IP_INC_STATS_BH(IpInDelivers);
 			kfree_skb(skb);
 		}
 	}
@@ -304,8 +306,10 @@
 		                                      --ANK (980813)
 		*/
 
-		if (skb_cow(skb, skb_headroom(skb)))
+		if (skb_cow(skb, skb_headroom(skb))) {
+			IP_INC_STATS_BH(IpInDiscards);
 			goto drop;
+		}
 		iph = skb->nh.iph;
 
 		if (ip_options_compile(NULL, skb))
@@ -353,8 +357,10 @@
 
 	IP_INC_STATS_BH(IpInReceives);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
+		IP_INC_STATS_BH(IpInDiscards);
 		goto out;
+	}
 
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
 		goto inhdr_error;
diff -urN linux-2.5.43/net/ipv4/raw.c linux-2.5.43s1/net/ipv4/raw.c
--- linux-2.5.43/net/ipv4/raw.c	Tue Oct 15 20:27:08 2002
+++ linux-2.5.43s1/net/ipv4/raw.c	Thu Oct 17 09:55:03 2002
@@ -226,12 +226,11 @@
 	/* Charge it to the socket. */
 	
 	if (sock_queue_rcv_skb(sk, skb) < 0) {
-		IP_INC_STATS(IpInDiscards);
+		/* FIXME: increment a raw drops counter here */
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
 
-	IP_INC_STATS(IpInDelivers);
 	return NET_RX_SUCCESS;
 }
 
diff -urN linux-2.5.43/net/ipv4/tcp_ipv4.c linux-2.5.43s1/net/ipv4/tcp_ipv4.c
--- linux-2.5.43/net/ipv4/tcp_ipv4.c	Tue Oct 15 20:27:50 2002
+++ linux-2.5.43s1/net/ipv4/tcp_ipv4.c	Wed Oct 16 18:39:30 2002
@@ -1674,8 +1674,6 @@
 		goto discard;
 #endif /* CONFIG_FILTER */
 
-  	IP_INC_STATS_BH(IpInDelivers);
-
 	if (sk->state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, skb->h.th, skb->len))
diff -urN linux-2.5.43/net/ipv4/udp.c linux-2.5.43s1/net/ipv4/udp.c
--- linux-2.5.43/net/ipv4/udp.c	Tue Oct 15 20:27:19 2002
+++ linux-2.5.43s1/net/ipv4/udp.c	Wed Oct 16 19:12:40 2002
@@ -819,8 +819,6 @@
 	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if (__udp_checksum_complete(skb)) {
 			UDP_INC_STATS_BH(UdpInErrors);
-			IP_INC_STATS_BH(IpInDiscards);
-			ip_statistics[smp_processor_id()*2].IpInDelivers--;
 			kfree_skb(skb);
 			return -1;
 		}
@@ -830,8 +828,6 @@
 
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		UDP_INC_STATS_BH(UdpInErrors);
-		IP_INC_STATS_BH(IpInDiscards);
-		ip_statistics[smp_processor_id()*2].IpInDelivers--;
 		kfree_skb(skb);
 		return -1;
 	}
@@ -915,8 +911,6 @@
 	u32 daddr = skb->nh.iph->daddr;
 	int len = skb->len;
 
-  	IP_INC_STATS_BH(IpInDelivers);
-
 	/*
 	 *	Validate the packet and the UDP length.
 	 */
diff -urN linux-2.5.43/net/ipv6/ip6_input.c linux-2.5.43s1/net/ipv6/ip6_input.c
--- linux-2.5.43/net/ipv6/ip6_input.c	Tue Oct 15 20:28:32 2002
+++ linux-2.5.43s1/net/ipv6/ip6_input.c	Thu Oct 17 09:46:56 2002
@@ -60,8 +60,10 @@
 
 	IP6_INC_STATS_BH(Ip6InReceives);
 
-	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
+		IP6_INC_STATS_BH(Ip6InDiscards);
 		goto out;
+	}
 
 	/* Store incoming device index. When the packet will
 	   be queued, we cannot refer to skb->dev anymore.
@@ -175,11 +177,13 @@
 			nexthdr = -ret;
 			goto resubmit;
 		}
+		IP6_INC_STATS_BH(Ip6InDelivers);
 	} else {
 		if (!raw_sk) {
 			IP6_INC_STATS_BH(Ip6InUnknownProtos);
 			icmpv6_param_prob(skb, ICMPV6_UNK_NEXTHDR, nhoff);
-		}
+		} else
+			IP6_INC_STATS_BH(Ip6InDelivers);
 		kfree_skb(skb);
 	}
 
diff -urN linux-2.5.43/net/ipv6/raw.c linux-2.5.43s1/net/ipv6/raw.c
--- linux-2.5.43/net/ipv6/raw.c	Tue Oct 15 20:27:54 2002
+++ linux-2.5.43s1/net/ipv6/raw.c	Thu Oct 17 10:05:10 2002
@@ -275,7 +275,7 @@
 #if defined(CONFIG_FILTER)
 	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
-			IP6_INC_STATS_BH(Ip6InDiscards);
+			/* FIXME: increment a raw6 drops counter here */
 			kfree_skb(skb);
 			return 0;
 		}
@@ -284,12 +284,11 @@
 #endif
 	/* Charge it to the socket. */
 	if (sock_queue_rcv_skb(sk,skb)<0) {
-		IP6_INC_STATS_BH(Ip6InDiscards);
+		/* FIXME: increment a raw6 drops counter here */
 		kfree_skb(skb);
 		return 0;
 	}
 
-	IP6_INC_STATS_BH(Ip6InDelivers);
 	return 0;
 }
 
@@ -327,7 +326,7 @@
 	if (inet->hdrincl) {
 		if (skb->ip_summed != CHECKSUM_UNNECESSARY &&
 		    (unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
-			IP6_INC_STATS_BH(Ip6InDiscards);
+			/* FIXME: increment a raw6 drops counter here */
 			kfree_skb(skb);
 			return 0;
 		}
@@ -427,7 +426,7 @@
 	   as some normal condition.
 	 */
 	err = (flags&MSG_DONTWAIT) ? -EAGAIN : -EHOSTUNREACH;
-	IP6_INC_STATS_USER(Ip6InDiscards);
+	/* FIXME: increment a raw6 drops counter here */
 	goto out_free;
 }
 
diff -urN linux-2.5.43/net/ipv6/tcp_ipv6.c linux-2.5.43s1/net/ipv6/tcp_ipv6.c
--- linux-2.5.43/net/ipv6/tcp_ipv6.c	Tue Oct 15 20:28:23 2002
+++ linux-2.5.43s1/net/ipv6/tcp_ipv6.c	Wed Oct 16 18:40:38 2002
@@ -1470,8 +1470,6 @@
 	 *	is currently called with bh processing disabled.
 	 */
 
-  	IP6_INC_STATS_BH(Ip6InDelivers);
-
 	/* Do Stevens' IPV6_PKTOPTIONS.
 
 	   Yes, guys, it is the only place in our code, where we
diff -urN linux-2.5.43/net/ipv6/udp.c linux-2.5.43s1/net/ipv6/udp.c
--- linux-2.5.43/net/ipv6/udp.c	Tue Oct 15 20:27:48 2002
+++ linux-2.5.43s1/net/ipv6/udp.c	Wed Oct 16 18:52:38 2002
@@ -512,7 +512,6 @@
 	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			UDP6_INC_STATS_BH(UdpInErrors);
-			IP6_INC_STATS_BH(Ip6InDiscards);
 			kfree_skb(skb);
 			return 0;
 		}
@@ -521,11 +520,9 @@
 #endif
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		UDP6_INC_STATS_BH(UdpInErrors);
-		IP6_INC_STATS_BH(Ip6InDiscards);
 		kfree_skb(skb);
 		return 0;
 	}
-  	IP6_INC_STATS_BH(Ip6InDelivers);
 	UDP6_INC_STATS_BH(UdpInDatagrams);
 	return 0;
 }
