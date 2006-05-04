From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [DCCP]: Fix sock_orphan dead lock
Date: Thu, 4 May 2006 17:17:50 +1000
Message-ID: <20060504071750.GA17180@gondor.apana.org.au>
References: <20060427123404.GA20489@gondor.apana.org.au> <20060429111507.GA3077@gondor.apana.org.au> <20060429131320.GA4145@gondor.apana.org.au> <20060503.233223.24747225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="X1bOJ3K7DJ5YkBrT"
Cc: mingo@elte.hu, arjan@infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:62729 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751419AbWEDHR7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 03:17:59 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060503.233223.24747225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, May 03, 2006 at 11:32:23PM -0700, David S. Miller wrote:
> 
> Ok, it took me a while to review this one as verifying such
> a set of changes is always tricky, but looks good!

Thanks.  It took me quite a while to assure myself that it was OK
as well :)

Anyway, the same issue affects DCCP (and SCTP too probably).  Here
is a patch that does the same thing for DCCP.

[DCCP]: Fix sock_orphan dead lock

Calling sock_orphan inside bh_lock_sock in dccp_close can lead to dead
locks.  For example, the inet_diag code holds sk_callback_lock without
disabling BH.  If an inbound packet arrives during that admittedly tiny
window, it will cause a dead lock on bh_lock_sock.  Another possible
path would be through sock_wfree if the network device driver frees the
tx skb in process context with BH enabled.

We can fix this by moving sock_orphan out of bh_lock_sock.

The tricky bit is to work out when we need to destroy the socket
ourselves and when it has already been destroyed by someone else.

By moving sock_orphan before the release_sock we can solve this
problem.  This is because as long as we own the socket lock its
state cannot change.

So we simply record the socket state before the release_sock
and then check the state again after we regain the socket lock.
If the socket state has transitioned to DCCP_CLOSED in the time being,
we know that the socket has been destroyed.  Otherwise the socket is
still ours to keep.

This problem was discoverd by Ingo Molnar using his lock validator.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="dccp-sock-orphan.patch"

diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 1ff7328..2e0ee83 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -848,6 +848,7 @@
 void dccp_close(struct sock *sk, long timeout)
 {
 	struct sk_buff *skb;
+	int state;
 
 	lock_sock(sk);
 
@@ -882,6 +883,11 @@
 	sk_stream_wait_close(sk, timeout);
 
 adjudge_to_death:
+	state = sk->sk_state;
+	sock_hold(sk);
+	sock_orphan(sk);
+	atomic_inc(sk->sk_prot->orphan_count);
+
 	/*
 	 * It is the last release_sock in its life. It will remove backlog.
 	 */
@@ -894,8 +900,9 @@
 	bh_lock_sock(sk);
 	BUG_TRAP(!sock_owned_by_user(sk));
 
-	sock_hold(sk);
-	sock_orphan(sk);
+	/* Have we already been destroyed by a softirq or backlog? */
+	if (state != DCCP_CLOSED && sk->sk_state == DCCP_CLOSED)
+		goto out;
 
 	/*
 	 * The last release_sock may have processed the CLOSE or RESET
@@ -915,12 +922,12 @@
 #endif
 	}
 
-	atomic_inc(sk->sk_prot->orphan_count);
 	if (sk->sk_state == DCCP_CLOSED)
 		inet_csk_destroy_sock(sk);
 
 	/* Otherwise, socket is reprieved until protocol close. */
 
+out:
 	bh_unlock_sock(sk);
 	local_bh_enable();
 	sock_put(sk);

--X1bOJ3K7DJ5YkBrT--
