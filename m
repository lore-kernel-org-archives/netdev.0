From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Patch 2.5.43] IpInDelivers, IpInDiscards
Date: Mon, 28 Oct 2002 04:50:00 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021028.045000.117518979.davem@redhat.com>
References: <Pine.LNX.4.44.0210171640190.3745-100000@w-nivedita.beaverton.ibm.com>
	<20021017.164326.60506862.davem@redhat.com>
	<3DAF5172.8EDC0F1A@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: niv@us.ibm.com
In-Reply-To: <3DAF5172.8EDC0F1A@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Nivedita Singhvi <niv@us.ibm.com>
   Date: Thu, 17 Oct 2002 17:10:26 -0700

   "David S. Miller" wrote:
   
   > Thanks a lot for your work, I'll post what I end up applying
   > to my tree.
   
   Great :). Thanks much!

Here is what I applied.  Thanks again.

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.835   -> 1.836  
#	      net/ipv4/raw.c	1.17    -> 1.18   
#	 net/ipv4/ip_input.c	1.7     -> 1.8    
#	      net/ipv4/udp.c	1.23    -> 1.24   
#	      net/ipv6/udp.c	1.16    -> 1.17   
#	 net/ipv4/tcp_ipv4.c	1.33    -> 1.34   
#	      net/ipv6/raw.c	1.17    -> 1.18   
#	 net/ipv6/tcp_ipv6.c	1.29    -> 1.30   
#	net/ipv6/ip6_input.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/10/28	niv@us.ibm.com	1.836
# [IPV{4,6}]: Clean up SNMP counter bumping.
# --------------------------------------------
#
diff -Nru a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
--- a/net/ipv4/ip_input.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv4/ip_input.c	Mon Oct 28 04:54:10 2002
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
diff -Nru a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv4/raw.c	Mon Oct 28 04:54:10 2002
@@ -227,12 +227,11 @@
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
 
diff -Nru a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv4/tcp_ipv4.c	Mon Oct 28 04:54:10 2002
@@ -1700,8 +1700,6 @@
 		goto discard;
 #endif /* CONFIG_FILTER */
 
-  	IP_INC_STATS_BH(IpInDelivers);
-
 	if (sk->state == TCP_ESTABLISHED) { /* Fast path */
 		TCP_CHECK_TIMER(sk);
 		if (tcp_rcv_established(sk, skb, skb->h.th, skb->len))
diff -Nru a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv4/udp.c	Mon Oct 28 04:54:10 2002
@@ -951,8 +951,6 @@
 	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if (__udp_checksum_complete(skb)) {
 			UDP_INC_STATS_BH(UdpInErrors);
-			IP_INC_STATS_BH(IpInDiscards);
-			ip_statistics[smp_processor_id()*2].IpInDelivers--;
 			kfree_skb(skb);
 			return -1;
 		}
@@ -962,8 +960,6 @@
 
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		UDP_INC_STATS_BH(UdpInErrors);
-		IP_INC_STATS_BH(IpInDiscards);
-		ip_statistics[smp_processor_id()*2].IpInDelivers--;
 		kfree_skb(skb);
 		return -1;
 	}
@@ -1046,8 +1042,6 @@
 	u32 saddr = skb->nh.iph->saddr;
 	u32 daddr = skb->nh.iph->daddr;
 	int len = skb->len;
-
-  	IP_INC_STATS_BH(IpInDelivers);
 
 	/*
 	 *	Validate the packet and the UDP length.
diff -Nru a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
--- a/net/ipv6/ip6_input.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv6/ip6_input.c	Mon Oct 28 04:54:10 2002
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
 
diff -Nru a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv6/raw.c	Mon Oct 28 04:54:10 2002
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
 
diff -Nru a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv6/tcp_ipv6.c	Mon Oct 28 04:54:10 2002
@@ -1497,8 +1497,6 @@
 	 *	is currently called with bh processing disabled.
 	 */
 
-  	IP6_INC_STATS_BH(Ip6InDelivers);
-
 	/* Do Stevens' IPV6_PKTOPTIONS.
 
 	   Yes, guys, it is the only place in our code, where we
diff -Nru a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c	Mon Oct 28 04:54:10 2002
+++ b/net/ipv6/udp.c	Mon Oct 28 04:54:10 2002
@@ -545,7 +545,6 @@
 	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
 		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
 			UDP6_INC_STATS_BH(UdpInErrors);
-			IP6_INC_STATS_BH(Ip6InDiscards);
 			kfree_skb(skb);
 			return 0;
 		}
@@ -554,11 +553,9 @@
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
