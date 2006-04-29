From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP]: Fix sock_orphan dead lock
Date: Sat, 29 Apr 2006 23:13:20 +1000
Message-ID: <20060429131320.GA4145@gondor.apana.org.au>
References: <20060424122659.GA26882@elte.hu> <20060424145353.GA29318@elte.hu> <20060425010549.GA28889@gondor.apana.org.au> <20060425131036.GA28018@elte.hu> <20060425232930.GB7740@gondor.apana.org.au> <20060426053821.GA31107@elte.hu> <20060427123404.GA20489@gondor.apana.org.au> <20060429111507.GA3077@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="qMm9M+Fa2AknHoGS"
Cc: "David S. Miller" <davem@davemloft.net>,
	Arjan van de Ven <arjan@infradead.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30993 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750701AbWD2NNf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Apr 2006 09:13:35 -0400
To: Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline
In-Reply-To: <20060429111507.GA3077@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Apr 29, 2006 at 09:15:07PM +1000, herbert wrote:
> 
> Unfortunately this is only true for TCP.  All of the connectionless
> protocols use the callback lock without the socket lock so it does
> still serve a purpose.
> 
> I'd be happy to see your patch included.

I've just changed my mind :) Instead of disabling BH on the read_lock
callers, we can instead move sock_orphan outside bh_lock_sock.

[TCP]: Fix sock_orphan dead lock

Calling sock_orphan inside bh_lock_sock in tcp_close can lead to dead
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
If the socket state has transitioned to TCP_CLOSE in the time being,
we know that the socket has been destroyed.  Otherwise the socket is
still ours to keep.

Note that I've also moved the increment on the orphan count forward.
This may look like a problem as we're increasing it even if the socket
is just about to be destroyed where it'll be decreased again.  However,
this simply enlarges a window that already exists.  This also changes
the orphan count test by one.

Considering what the orphan count is meant to do this is no big deal.

This problem was discoverd by Ingo Molnar using his lock validator.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--qMm9M+Fa2AknHoGS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tcp-sock-orphan.patch"

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 87f68e7..e2b7b80 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1468,6 +1468,7 @@
 {
 	struct sk_buff *skb;
 	int data_was_unread = 0;
+	int state;
 
 	lock_sock(sk);
 	sk->sk_shutdown = SHUTDOWN_MASK;
@@ -1544,6 +1545,11 @@
 	sk_stream_wait_close(sk, timeout);
 
 adjudge_to_death:
+	state = sk->sk_state;
+	sock_hold(sk);
+	sock_orphan(sk);
+	atomic_inc(sk->sk_prot->orphan_count);
+
 	/* It is the last release_sock in its life. It will remove backlog. */
 	release_sock(sk);
 
@@ -1555,8 +1561,9 @@
 	bh_lock_sock(sk);
 	BUG_TRAP(!sock_owned_by_user(sk));
 
-	sock_hold(sk);
-	sock_orphan(sk);
+	/* Have we already been destroyed by a softirq or backlog? */
+	if (state != TCP_CLOSE && sk->sk_state == TCP_CLOSE)
+		goto out;
 
 	/*	This is a (useful) BSD violating of the RFC. There is a
 	 *	problem with TCP as specified in that the other end could
@@ -1584,7 +1591,6 @@
 			if (tmo > TCP_TIMEWAIT_LEN) {
 				inet_csk_reset_keepalive_timer(sk, tcp_fin_time(sk));
 			} else {
-				atomic_inc(sk->sk_prot->orphan_count);
 				tcp_time_wait(sk, TCP_FIN_WAIT2, tmo);
 				goto out;
 			}
@@ -1603,7 +1609,6 @@
 			NET_INC_STATS_BH(LINUX_MIB_TCPABORTONMEMORY);
 		}
 	}
-	atomic_inc(sk->sk_prot->orphan_count);
 
 	if (sk->sk_state == TCP_CLOSE)
 		inet_csk_destroy_sock(sk);

--qMm9M+Fa2AknHoGS--
