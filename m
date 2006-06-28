From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH]NET: Add ECN support for TSO
Date: Tue, 27 Jun 2006 20:06:47 -0700
Message-ID: <1151464007.5124.13.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:33033 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1423000AbWF1DFp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 23:05:45 -0400
To: davem@davemloft.net, herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the current TSO implementation, NETIF_F_TSO and ECN cannot be
turned on together in a TCP connection.  The problem is that most
hardware that supports TSO does not handle CWR correctly if it is set
in the TSO packet.  Correct handling requires CWR to be set in the
first packet only if it is set in the TSO header.

This patch adds the ability to turn on NETIF_F_TSO and ECN using 
GSO if necessary to handle TSO packets with CWR set.  Hardware
that handles CWR correctly can turn on NETIF_F_TSO_ECN in the dev->
features flag.

All TSO packets with CWR set will have the SKB_GSO_TCPV4_ECN set.  If
the output device does not have the NETIF_F_TSO_ECN feature set, GSO
will split the packet up correctly with CWR only set in the first
segment.

It is further assumed that all hardware will handle ECE properly by
replicating the ECE flag in all segments.  If that is not the case, a
simple extension of the logic will be required.


Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index efd1e2a..f393de2 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -316,6 +316,7 @@ struct net_device
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCPV4_ECN << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
@@ -1002,6 +1003,11 @@ static inline int netif_needs_gso(struct
 	return !skb_gso_ok(skb, dev->features);
 }
 
+static inline int tso_ecn_capable(unsigned long features)
+{
+	return ((features & NETIF_F_GSO) || (features & NETIF_F_TSO_ECN));
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _LINUX_DEV_H */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5fb72da..e74c294 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -175,6 +175,9 @@ enum {
 
 	/* This indicates the skb is from an untrusted source. */
 	SKB_GSO_DODGY = 1 << 2,
+
+	/* This indicates the tcp segment has CWR set. */
+	SKB_GSO_TCPV4_ECN = 1 << 3,
 };
 
 /** 
diff --git a/include/net/sock.h b/include/net/sock.h
index 2d8d6ad..2c75172 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1033,7 +1033,8 @@ static inline void sk_setup_caps(struct 
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_TSO;
 	if (sk->sk_route_caps & NETIF_F_TSO) {
-		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
+		if ((sock_flag(sk, SOCK_NO_LARGESEND) &&
+		    !tso_ecn_capable(sk->sk_route_caps)) || dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_TSO;
 		else 
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
index c6b8439..871dca2 100644
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -31,7 +31,8 @@ static inline void TCP_ECN_send_syn(stru
 				    struct sk_buff *skb)
 {
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
+	if (sysctl_tcp_ecn && (!(sk->sk_route_caps & NETIF_F_TSO) ||
+			       tso_ecn_capable(sk->sk_route_caps))) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 		sock_set_flag(sk, SOCK_NO_LARGESEND);
@@ -56,6 +57,9 @@ static inline void TCP_ECN_send(struct s
 			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
 				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
 				skb->h.th->cwr = 1;
+				if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+					skb_shinfo(skb)->gso_type |=
+						SKB_GSO_TCPV4_ECN;
 			}
 		} else {
 			/* ACK or retransmitted segment: clear ECT|CE */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdd71db..c4a4dba 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2044,7 +2044,8 @@ struct sk_buff * tcp_make_synack(struct 
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	if (dst->dev->features&NETIF_F_TSO)
+	if ((dst->dev->features & NETIF_F_TSO) &&
+	    !tso_ecn_capable(dst->dev->features))
 		ireq->ecn_ok = 0;
 	TCP_ECN_make_synack(req, th);
 	th->source = inet_sk(sk)->sport;


