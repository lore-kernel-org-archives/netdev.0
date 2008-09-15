From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bug 11572] New: udp: unbalanced unlock bug in
	udp_queue_rcv_skb with ipsec
Date: Mon, 15 Sep 2008 11:34:20 -0700
Message-ID: <20080915183419.GA12978@gondor.apana.org.au>
References: <bug-11572-2647@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: bugme-daemon@bugzilla.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55220 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752569AbYIOSe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2008 14:34:27 -0400
Content-Disposition: inline
In-Reply-To: <bug-11572-2647@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 15, 2008 at 07:04:24AM -0700, bugme-daemon@bugzilla.kernel.org wrote:
> 
> after upgrading our production firewall to kernel 2.6.26.4, it freezed numerous
> times out of the blue. First problem was isolated and now fixed in bug #11142,
> but the box still freezed every two days. Yesterday night it crashed during
> setup of ipsec connections, so I've built a test box setting up over 25 ipsec
> connections to invalid peers. This will issue the following backtrace:
> 
> ====================================
> [ BUG: bad unlock balance detected! ]
> -------------------------------------
> pluto/2943 is trying to release lock (slock-AF_INET) at:
> [<c02b660f>] udp_queue_rcv_skb+0xa3/0x210
> but there are no more locks to release!
> 
> other info that might help us debug this:
> no locks held by pluto/2943.
> 
> stack backtrace:
> Pid: 2943, comm: pluto Not tainted 2.6.26-2.i2nsmp #2
>  [<c013ebb9>] print_unlock_inbalance_bug+0xd7/0xe1
>  [<c02c73a5>] ? xfrm_sk_policy_lookup+0x44/0x4b
>  [<c02c7d7b>] ? __xfrm_policy_check+0x19b/0x4a2
>  [<c02b660f>] ? udp_queue_rcv_skb+0xa3/0x210
>  [<c013ed95>] lock_release+0xad/0x15c
>  [<c02e1056>] _spin_unlock+0x16/0x20
>  [<c02b660f>] udp_queue_rcv_skb+0xa3/0x210
>  [<c0279ce0>] release_sock+0x5e/0xab

Sorry my previous fix is simply bogus.  The real problem is that
we added the socket lock in the wrong place.  It should be around
the socket queueing only.

udp: Fix rcv socket locking

The previous patch in response to the recursive locking on IPsec
reception is broken as it tries to drop the BH socket lock while in
user context.

This patch fixes it by shrinking the section protected by the
socket lock to sock_queue_rcv_skb only.  The only reason we added
the lock is for the accounting which happens in that function.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8e42fbb..57e26fa 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -951,6 +951,27 @@ int udp_disconnect(struct sock *sk, int flags)
 	return 0;
 }
 
+static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	int is_udplite = IS_UDPLITE(sk);
+	int rc;
+
+	if ((rc = sock_queue_rcv_skb(sk, skb)) < 0) {
+		/* Note that an ENOMEM error is charged twice */
+		if (rc == -ENOMEM)
+			UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_RCVBUFERRORS,
+					 is_udplite);
+		goto drop;
+	}
+
+	return 0;
+
+drop:
+	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
+	kfree_skb(skb);
+	return -1;
+}
+
 /* returns:
  *  -1: error
  *   0: success
@@ -989,9 +1010,7 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 		    up->encap_rcv != NULL) {
 			int ret;
 
-			bh_unlock_sock(sk);
 			ret = (*up->encap_rcv)(sk, skb);
-			bh_lock_sock(sk);
 			if (ret <= 0) {
 				UDP_INC_STATS_BH(sock_net(sk),
 						 UDP_MIB_INDATAGRAMS,
@@ -1044,17 +1063,16 @@ int udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb)
 			goto drop;
 	}
 
-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
-		/* Note that an ENOMEM error is charged twice */
-		if (rc == -ENOMEM) {
-			UDP_INC_STATS_BH(sock_net(sk),
-					UDP_MIB_RCVBUFERRORS, is_udplite);
-			atomic_inc(&sk->sk_drops);
-		}
-		goto drop;
-	}
+	rc = 0;
 
-	return 0;
+	bh_lock_sock(sk);
+	if (!sock_owned_by_user(sk))
+		rc = __udp_queue_rcv_skb(sk, skb);
+	else
+		sk_add_backlog(sk, skb);
+	bh_unlock_sock(sk);
+
+	return rc;
 
 drop:
 	UDP_INC_STATS_BH(sock_net(sk), UDP_MIB_INERRORS, is_udplite);
@@ -1092,15 +1110,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
 				skb1 = skb_clone(skb, GFP_ATOMIC);
 
 			if (skb1) {
-				int ret = 0;
-
-				bh_lock_sock(sk);
-				if (!sock_owned_by_user(sk))
-					ret = udp_queue_rcv_skb(sk, skb1);
-				else
-					sk_add_backlog(sk, skb1);
-				bh_unlock_sock(sk);
-
+				int ret = udp_queue_rcv_skb(sk, skb1);
 				if (ret > 0)
 					/* we should probably re-process instead
 					 * of dropping packets here. */
@@ -1195,13 +1205,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct hlist_head udptable[],
 			uh->dest, inet_iif(skb), udptable);
 
 	if (sk != NULL) {
-		int ret = 0;
-		bh_lock_sock(sk);
-		if (!sock_owned_by_user(sk))
-			ret = udp_queue_rcv_skb(sk, skb);
-		else
-			sk_add_backlog(sk, skb);
-		bh_unlock_sock(sk);
+		int ret = udp_queue_rcv_skb(sk, skb);
 		sock_put(sk);
 
 		/* a return value > 0 means to resubmit the input, but
@@ -1494,7 +1498,7 @@ struct proto udp_prot = {
 	.sendmsg	   = udp_sendmsg,
 	.recvmsg	   = udp_recvmsg,
 	.sendpage	   = udp_sendpage,
-	.backlog_rcv	   = udp_queue_rcv_skb,
+	.backlog_rcv	   = __udp_queue_rcv_skb,
 	.hash		   = udp_lib_hash,
 	.unhash		   = udp_lib_unhash,
 	.get_port	   = udp_v4_get_port,

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
