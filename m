From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 2/3] [UDP]: Clean up for IS_UDPLITE macro
Date: Fri, 30 Nov 2007 11:15:49 +0800
Message-ID: <474F8065.2030000@cn.fujitsu.com>
References: <474F7EE8.2040009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andi@firstfloor.org, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk, Wang Chen <wangchen@cn.fujitsu.com>
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:62728 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755812AbXK3DSX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 22:18:23 -0500
In-Reply-To: <474F7EE8.2040009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(This patch base on "PATCH 1/3".)

Since we have macro IS_UDPLITE, we can use it.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 ipv4/udp.c |   19 +++++++++++--------
 ipv6/udp.c |   14 ++++++++------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff -Nurp linux-2.6.24.rc3.org/net/ipv4/udp.c linux-2.6.24.rc3/net/ipv4/udp.c
--- linux-2.6.24.rc3.org/net/ipv4/udp.c	2007-11-30 10:07:48.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv4/udp.c	2007-11-30 10:18:49.000000000 +0800
@@ -471,6 +471,7 @@ static int udp_push_pending_frames(struc
 	struct sk_buff *skb;
 	struct udphdr *uh;
 	int err = 0;
+	int is_udplite = IS_UDPLITE(sk);
 	__wsum csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
@@ -486,7 +487,7 @@ static int udp_push_pending_frames(struc
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (up->pcflag)  				 /*     UDP-Lite      */
+	if (is_udplite)  				 /*     UDP-Lite      */
 		csum  = udplite_csum_outgoing(sk, skb);
 
 	else if (sk->sk_no_check == UDP_CSUM_NOXMIT) {   /* UDP csum disabled */
@@ -514,7 +515,7 @@ out:
 	up->len = 0;
 	up->pending = 0;
 	if (!err)
-		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, up->pcflag);
+		UDP_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
 
@@ -531,7 +532,7 @@ int udp_sendmsg(struct kiocb *iocb, stru
 	__be32 daddr, faddr, saddr;
 	__be16 dport;
 	u8  tos;
-	int err, is_udplite = up->pcflag;
+	int err, is_udplite = IS_UDPLITE(sk);
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
@@ -942,6 +943,7 @@ int udp_queue_rcv_skb(struct sock * sk, 
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
+	int is_udplite = IS_UDPLITE(sk);
 
 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -978,7 +980,7 @@ int udp_queue_rcv_skb(struct sock * sk, 
 	/*
 	 * 	UDP-Lite specific tests, ignored on UDP sockets
 	 */
-	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+	if ((is_udplite & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
 
 		/*
 		 * MIB statistics other than incrementing the error count are
@@ -1019,14 +1021,14 @@ int udp_queue_rcv_skb(struct sock * sk, 
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
 	}
 
 	return 0;
 
 drop:
-	UDP_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }
@@ -1235,6 +1237,7 @@ int udp_lib_setsockopt(struct sock *sk, 
 	struct udp_sock *up = udp_sk(sk);
 	int val;
 	int err = 0;
+	int is_udplite = IS_UDPLITE(sk);
 
 	if (optlen<sizeof(int))
 		return -EINVAL;
@@ -1276,7 +1279,7 @@ int udp_lib_setsockopt(struct sock *sk, 
 	/* The sender sets actual checksum coverage length via this option.
 	 * The case coverage > packet length is handled by send module. */
 	case UDPLITE_SEND_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
+		if (!is_udplite)         /* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
 		if (val != 0 && val < 8) /* Illegal coverage: use default (8) */
 			val = 8;
@@ -1288,7 +1291,7 @@ int udp_lib_setsockopt(struct sock *sk, 
 	 * sense, this should be set to at least 8 (as done below). If zero is
 	 * used, this again means full checksum coverage.                     */
 	case UDPLITE_RECV_CSCOV:
-		if (!up->pcflag)         /* Disable the option on UDP sockets */
+		if (!is_udplite)         /* Disable the option on UDP sockets */
 			return -ENOPROTOOPT;
 		if (val != 0 && val < 8) /* Avoid silly minimal values.       */
 			val = 8;
diff -Nurp linux-2.6.24.rc3.org/net/ipv6/udp.c linux-2.6.24.rc3/net/ipv6/udp.c
--- linux-2.6.24.rc3.org/net/ipv6/udp.c	2007-11-30 10:07:48.000000000 +0800
+++ linux-2.6.24.rc3/net/ipv6/udp.c	2007-11-30 10:22:25.000000000 +0800
@@ -260,6 +260,7 @@ int udpv6_queue_rcv_skb(struct sock * sk
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
+	int is_udplite = IS_UDPLITE(sk);
 
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto drop;
@@ -267,7 +268,7 @@ int udpv6_queue_rcv_skb(struct sock * sk
 	/*
 	 * UDP-Lite specific tests, ignored on UDP sockets (see net/ipv4/udp.c).
 	 */
-	if ((up->pcflag & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
+	if ((is_udplite & UDPLITE_RECV_CC)  &&  UDP_SKB_CB(skb)->partial_cov) {
 
 		if (up->pcrlen == 0) {          /* full coverage was set  */
 			LIMIT_NETDEBUG(KERN_WARNING "UDPLITE6: partial coverage"
@@ -291,13 +292,13 @@ int udpv6_queue_rcv_skb(struct sock * sk
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
-			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+			UDP6_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, is_udplite);
 		goto drop;
 	}
 
 	return 0;
 drop:
-	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
+	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
 	kfree_skb(skb);
 	return -1;
 }
@@ -525,6 +526,7 @@ static int udp_v6_push_pending_frames(st
 	struct inet_sock *inet = inet_sk(sk);
 	struct flowi *fl = &inet->cork.fl;
 	int err = 0;
+	int is_udplite = IS_UDPLITE(sk);
 	__wsum csum = 0;
 
 	/* Grab the skbuff where UDP header space exists. */
@@ -540,7 +542,7 @@ static int udp_v6_push_pending_frames(st
 	uh->len = htons(up->len);
 	uh->check = 0;
 
-	if (up->pcflag)
+	if (is_udplite)
 		csum = udplite_csum_outgoing(sk, skb);
 	 else
 		csum = udp_csum_outgoing(sk, skb);
@@ -556,7 +558,7 @@ out:
 	up->len = 0;
 	up->pending = 0;
 	if (!err)
-		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, up->pcflag);
+		UDP6_INC_STATS_USER(UDP_MIB_OUTDATAGRAMS, is_udplite);
 	return err;
 }
 
@@ -580,7 +582,7 @@ int udpv6_sendmsg(struct kiocb *iocb, st
 	int corkreq = up->corkflag || msg->msg_flags&MSG_MORE;
 	int err;
 	int connected = 0;
-	int is_udplite = up->pcflag;
+	int is_udplite = IS_UDPLITE(sk);
 	int (*getfrag)(void *, char *, int, int, int, struct sk_buff *);
 
 	/* destination address check */

