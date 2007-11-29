From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][UNIX] EOF on non-blocking SOCK_SEQPACKET
Date: Thu, 29 Nov 2007 23:20:48 +1100
Message-ID: <20071129122047.GA30420@gondor.apana.org.au>
References: <20071127093323.GA2690@florz.florz.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Zumbiehl <florz@florz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2948 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754525AbXK2MUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 07:20:51 -0500
Content-Disposition: inline
In-Reply-To: <20071127093323.GA2690@florz.florz.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 27, 2007 at 09:33:23AM +0000, Florian Zumbiehl wrote:
> 
> I am not absolutely sure whether this actually is a bug (as in: I've got
> no clue what the standards say or what other implementations do), but at
> least I was pretty surprised when I noticed that a recv() on a
> non-blocking unix domain socket of type SOCK_SEQPACKET (which is connection
> oriented, after all) where the remote end has closed the connection
> returned -1 (EAGAIN) rather than 0 to indicate end of file.

I agree with your expectation.  In fact, that's what POSIX says too.
Since the risk of this breaking an existing application seems to be
minimal, I've applied your patch to net-2.6.

However, I had to reformat it so that it fits with the Linux coding
style.  Please take this into account for future patches.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e835da8..060bba4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1637,8 +1637,15 @@ static int unix_dgram_recvmsg(struct kiocb *iocb, struct socket *sock,
 	mutex_lock(&u->readlock);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
-	if (!skb)
+	if (!skb) {
+		unix_state_lock(sk);
+		/* Signal EOF on disconnected non-blocking SEQPACKET socket. */
+		if (sk->sk_type == SOCK_SEQPACKET && err == -EAGAIN &&
+		    (sk->sk_shutdown & RCV_SHUTDOWN))
+			err = 0;
+		unix_state_unlock(sk);
 		goto out_unlock;
+	}
 
 	wake_up_interruptible_sync(&u->peer_wait);
 
