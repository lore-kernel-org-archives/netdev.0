From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH]NET: Add ECN support for TSO
Date: Tue, 27 Jun 2006 21:37:01 -0700
Message-ID: <1151469421.3502.3.camel@rh4>
References: <1151464007.5124.13.camel@rh4>
 <20060628031052.GA4570@gondor.apana.org.au>
 <1151466034.5124.18.camel@rh4>
 <20060628034823.GA5125@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:48912 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1423005AbWF1Efy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 00:35:54 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060628034823.GA5125@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-28 at 13:48 +1000, Herbert Xu wrote:

> I think you're mixing up GSO the mechanism with GSO the flag.  The GSO
> flag simply tells the TCP stack whether TSO should be used or not, even
> if the hardware does not support TSO at all.  The GSO mechanism on the
> other hand is ALWAYS present.  So regardless of the presence of the GSO
> flag, you can always rely on the GSO mechanism to pick up the pieces (or
> rather generate the pieces as the case may be :)
> 
Thanks, that was my confusion.  Here's the revised patch:

[NET]: Add ECN support for TSO

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

With help from Herbert Xu <herbert@gondor.apana.org.au>.

Since ECN can always be enabled with TSO, the SOCK_NO_LARGESEND sock
flag is completely removed.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 84b0f0d..a42a9f4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -316,6 +316,7 @@ struct net_device
 #define NETIF_F_TSO		(SKB_GSO_TCPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_UFO		(SKB_GSO_UDPV4 << NETIF_F_GSO_SHIFT)
 #define NETIF_F_GSO_ROBUST	(SKB_GSO_DODGY << NETIF_F_GSO_SHIFT)
+#define NETIF_F_TSO_ECN		(SKB_GSO_TCPV4_ECN << NETIF_F_GSO_SHIFT)
 
 #define NETIF_F_GEN_CSUM	(NETIF_F_NO_CSUM | NETIF_F_HW_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSUM | NETIF_F_GEN_CSUM)
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
index 2d8d6ad..7136bae 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -383,7 +383,6 @@ enum sock_flags {
 	SOCK_USE_WRITE_QUEUE, /* whether to call sk->sk_write_space in sock_wfree */
 	SOCK_DBG, /* %SO_DEBUG setting */
 	SOCK_RCVTSTAMP, /* %SO_TIMESTAMP setting */
-	SOCK_NO_LARGESEND, /* whether to sent large segments or not */
 	SOCK_LOCALROUTE, /* route locally only, %SO_DONTROUTE setting */
 	SOCK_QUEUE_SHRUNK, /* write queue has been shrunk recently */
 };
@@ -1033,7 +1032,7 @@ static inline void sk_setup_caps(struct 
 	if (sk->sk_route_caps & NETIF_F_GSO)
 		sk->sk_route_caps |= NETIF_F_TSO;
 	if (sk->sk_route_caps & NETIF_F_TSO) {
-		if (sock_flag(sk, SOCK_NO_LARGESEND) || dst->header_len)
+		if (dst->header_len)
 			sk->sk_route_caps &= ~NETIF_F_TSO;
 		else 
 			sk->sk_route_caps |= NETIF_F_SG | NETIF_F_HW_CSUM;
diff --git a/include/net/tcp_ecn.h b/include/net/tcp_ecn.h
index c6b8439..7bb366f 100644
--- a/include/net/tcp_ecn.h
+++ b/include/net/tcp_ecn.h
@@ -31,10 +31,9 @@ static inline void TCP_ECN_send_syn(stru
 				    struct sk_buff *skb)
 {
 	tp->ecn_flags = 0;
-	if (sysctl_tcp_ecn && !(sk->sk_route_caps & NETIF_F_TSO)) {
+	if (sysctl_tcp_ecn) {
 		TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_ECE|TCPCB_FLAG_CWR;
 		tp->ecn_flags = TCP_ECN_OK;
-		sock_set_flag(sk, SOCK_NO_LARGESEND);
 	}
 }
 
@@ -56,6 +55,9 @@ static inline void TCP_ECN_send(struct s
 			if (tp->ecn_flags&TCP_ECN_QUEUE_CWR) {
 				tp->ecn_flags &= ~TCP_ECN_QUEUE_CWR;
 				skb->h.th->cwr = 1;
+				if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4)
+					skb_shinfo(skb)->gso_type |=
+						SKB_GSO_TCPV4_ECN;
 			}
 		} else {
 			/* ACK or retransmitted segment: clear ECT|CE */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 94fe5b1..7fa0b4a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4178,8 +4178,6 @@ static int tcp_rcv_synsent_state_process
 		 */
 
 		TCP_ECN_rcv_synack(tp, th);
-		if (tp->ecn_flags&TCP_ECN_OK)
-			sock_set_flag(sk, SOCK_NO_LARGESEND);
 
 		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
@@ -4322,8 +4320,6 @@ discard:
 		tp->max_window = tp->snd_wnd;
 
 		TCP_ECN_rcv_syn(tp, th);
-		if (tp->ecn_flags&TCP_ECN_OK)
-			sock_set_flag(sk, SOCK_NO_LARGESEND);
 
 		tcp_mtup_init(sk);
 		tcp_sync_mss(sk, icsk->icsk_pmtu_cookie);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2b9b7f6..54b2ef7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -440,8 +440,6 @@ struct sock *tcp_create_openreq_child(st
 			newicsk->icsk_ack.last_seg_size = skb->len - newtp->tcp_header_len;
 		newtp->rx_opt.mss_clamp = req->mss;
 		TCP_ECN_openreq_child(newtp, req);
-		if (newtp->ecn_flags&TCP_ECN_OK)
-			sock_set_flag(newsk, SOCK_NO_LARGESEND);
 
 		TCP_INC_STATS_BH(TCP_MIB_PASSIVEOPENS);
 	}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index bdd71db..5a7cb4a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2044,8 +2044,6 @@ struct sk_buff * tcp_make_synack(struct 
 	memset(th, 0, sizeof(struct tcphdr));
 	th->syn = 1;
 	th->ack = 1;
-	if (dst->dev->features&NETIF_F_TSO)
-		ireq->ecn_ok = 0;
 	TCP_ECN_make_synack(req, th);
 	th->source = inet_sk(sk)->sport;
 	th->dest = ireq->rmt_port;


