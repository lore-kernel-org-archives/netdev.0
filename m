From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [1/5] [NET]: Merge TSO/UFO fields in sk_buff
Date: Wed, 21 Jun 2006 14:48:15 -0700
Message-ID: <1150926495.3475.5.camel@rh4>
References: <20060620090919.GA31613@gondor.apana.org.au>
 <20060620091050.GA31854@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:44555 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751475AbWFUVtG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 17:49:06 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060620091050.GA31854@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-06-20 at 19:10 +1000, Herbert Xu wrote:

> I've made gso_type a conjunction.  The idea is that you have a base type
> (e.g., SKB_GSO_TCPV4) that can be modified further to support new features.
> For example, if we add a hardware TSO type that supports ECN, they would
> declare NETIF_F_TSO | NETIF_F_TSO_ECN.

Hi Herbert,

We have some hardware that supports TSO and ECN.  Is something like the
patch below what you had in mind to support NETIF_F_TSO_ECN?  Or are you
thinking about something more generic that works with or without
hardware support?

[NET]: Add hardware TSO support for ECN

In the current TSO implementation, NETIF_F_TSO and ECN cannot be
turned on together in a TCP connection.  This patch adds a new
feature NETIF_F_TSO_ECN for hardware that supports TSO and ECN.

To support NETIF_F_TSO_ECN, hardware has to set the ECE flag in the
TCP flags for all segments if the first TSO segment has the ECE flag set.
If the CWR flag is set in the first TSO segment, hardware has to set
CWR in the first segment only and clear it in all subsequent segments.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3af961..825b66d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -316,6 +316,7 @@ struct net_device
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCPV4_ECN << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 679feab..818f478 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -173,6 +173,7 @@ enum {
 enum {
 	SKB_GSO_TCPV4 = 1 << 0,
 	SKB_GSO_UDPV4 = 1 << 1,
+	SKB_GSO_TCPV4_ECN = 1 << 2,
 };
 
 /** 
diff --git a/include/net/sock.h b/include/net/sock.h
index 6aac245..7c1ac0c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1034,7 +1034,8 @@ static inline void sk_setup_caps(struct 
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_TSO;
 	if (sk->sk_route_caps & NETIF_F_TSO) {
-		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
+		if ((sock_flag(sk, SOCK_NO_LARGESEND) &&
+		    !(sk->sk_route_caps & NETIF_F_TSO_ECN)) || dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_TSO;
 		else 
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
index c6b8439..c8a3b48 100644
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -31,7 +31,8 @@ static inline void TCP_ECN_send_syn(stru
 				    struct sk_buff *skb)
 {
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
+	if (sysctl_tcp_ecn && (!(sk->sk_route_caps & NETIF_F_TSO) ||
+				(sk->sk_route_caps & NETIF_F_TSO_ECN))) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
 		sock_set_flag(sk, SOCK_NO_LARGESEND);
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdd71db..a65fe56 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2044,7 +2044,8 @@ struct sk_buff * tcp_make_synack(struct 
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	if (dst->dev->features&NETIF_F_TSO)
+	if ((dst->dev->features&NETIF_F_TSO) &&
+	    !(dst->dev->features&NETIF_F_TSO_ECN))
 		ireq->ecn_ok = 0;
 	TCP_ECN_make_synack(req, th);
 	th->source = inet_sk(sk)->sport;


