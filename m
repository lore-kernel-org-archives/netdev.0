From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tun: Only wake up writers
Date: Wed, 3 Jun 2009 22:36:55 +1000
Message-ID: <20090603123655.GA13916@gondor.apana.org.au>
References: <20090603033303.GA7889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50019 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753332AbZFCMgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 08:36:55 -0400
Content-Disposition: inline
In-Reply-To: <20090603033303.GA7889@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2009 at 01:33:03PM +1000, Herbert Xu wrote:
> 
> tun: Only wake up writers
> 
> Recently net/core/sock.c was updated so that when we free an skb
> that has been transmitted we only wake up writers instead of waking
> up both readers and writers.
> 
> This patch does the same thing for tun as this code is identical
> to that in net/core/sock.c
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Scratch that.  It doesn't actually work because our poll(2) doesn't
use this extra info.  Here's a patch that actually works:

tun: Only wake up writers

When I added socket accounting to tun I inadvertently introduced
spurious wake-up events that kills qemu performance.  The problem
occurs when qemu polls on the tun fd for read, and then transmits
packets.  For each packet transmitted, we will wake up qemu even
if it only cares about read events.

Now this affects all sockets, but it is only a new problem for
tun.  So this patch tries to fix it for tun first and we can then
look at the problem in general.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 735bf41..eeb8af5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -840,12 +840,12 @@ static void tun_sock_write_space(struct sock *sk)
 	if (!sock_writeable(sk))
 		return;
 
-	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
-		wake_up_interruptible_sync(sk->sk_sleep);
-
 	if (!test_and_clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags))
 		return;
 
+	if (sk->sk_sleep && waitqueue_active(sk->sk_sleep))
+		wake_up_interruptible_sync(sk->sk_sleep);
+
 	tun = container_of(sk, struct tun_sock, sk)->tun;
 	kill_fasync(&tun->fasync, SIGIO, POLL_OUT);
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
