From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: PROBLEM: kernel BUG at net/ipv6/ip6_output.c:718
Date: Tue, 3 Oct 2006 16:28:20 +1000
Message-ID: <20061003062820.GA24217@gondor.apana.org.au>
References: <20060828004906.GC20092@ripe.net> <20060829082828.GA8625@gondor.apana.org.au> <20060831151243.GJ3590@ripe.net> <20060901070557.GA15731@gondor.apana.org.au> <20060901162248.GI19284@ripe.net> <20060925121530.GC18667@gondor.apana.org.au> <20060926112122.GU22330@ripe.net> <20060928003829.GA8952@gondor.apana.org.au> <20060928084018.GA15141@ripe.net> <20061003054935.GA23963@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pekkas@netcore.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11792 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750960AbWJCG2g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 02:28:36 -0400
To: cagri coltekin <cagri@ripe.net>
Content-Disposition: inline
In-Reply-To: <20061003054935.GA23963@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 03:49:35PM +1000, Herbert Xu wrote:
>
> OK, I think I've got the right bug this time.

Here is the patch for the other bug that I found along the way:

[UDP6]: Fix MSG_PROBE crash

UDP tracks corking status through the pending variable.  The
IP layer also tracks it through the socket write queue.  It
is possible for the two to get out of sync when MSG_PROBE is
used.

This patch changes UDP to check the write queue to ensure
that the two stay in sync.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
--
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -675,6 +675,8 @@ do_append_data:
 		udp_flush_pending_frames(sk);
 	else if (!corkreq)
 		err = udp_push_pending_frames(sk, up);
+	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
+		up->pending = 0;
 	release_sock(sk);
 
 out:
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -770,6 +770,8 @@ do_append_data:
 		udp_v6_flush_pending_frames(sk);
 	else if (!corkreq)
 		err = udp_v6_push_pending_frames(sk, up);
+	else if (unlikely(skb_queue_empty(&sk->sk_write_queue)))
+		up->pending = 0;
 
 	if (dst) {
 		if (connected) {
