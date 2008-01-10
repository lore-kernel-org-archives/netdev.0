From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Thu, 10 Jan 2008 16:35:55 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801101554100.52456@pkunk.americas.sgi.com>
References: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au> <alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:42544 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756136AbYAJWf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 17:35:57 -0500
In-Reply-To: <alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here's what I think is a better patch.  Or maybe just simpler.

However, I'm still unsure what the effect of this patch on
file descriptor passing might be.  Reading the prior code,
and the parallel portions/comments in unix_dgram_recvmsg(),
it looks like there's been a lot of uncertainty as to how
file descriptor passing should be handled durning MSG_PEEK
operations.  To quote:

	/* It is questionable: on PEEK we could:
	   - do not return fds - good, but too simple 8)
	   - return fds, and do not return them on read (old strategy,
	     apparently wrong)
	   - clone fds (I chose it for now, it is the most universal
	     solution)

	   POSIX 1003.1g does not actually define this clearly
	   at all. POSIX 1003.1g doesn't define a lot of things
	   clearly however!
	*/

With this patch, passed file descriptors are ignored during MSG_PEEK.
This is essentially the first case in the comment above.  What I
can't seem to figure out is why this is incorrect.  I suspect there's
some history here that I can't find via Google, mailing list archives,
or revision logs.

So, that said, here's a cleaner patch.  It's still not ready for
application until the file descriptor passing is better understood.

Thanks,
Brent

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 060bba4..6d6cdb4 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1750,6 +1750,8 @@ static int unix_stream_recvmsg(struct ki
 	int target;
 	int err = 0;
 	long timeo;
+	struct sk_buff *skb;
+	struct sk_buff_head peek_stack;
 
 	err = -EINVAL;
 	if (sk->sk_state != TCP_ESTABLISHED)
@@ -1759,6 +1761,9 @@ static int unix_stream_recvmsg(struct ki
 	if (flags&MSG_OOB)
 		goto out;
 
+	if (flags & MSG_PEEK)
+		skb_queue_head_init(&peek_stack);
+
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
 	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
 
@@ -1778,7 +1783,6 @@ static int unix_stream_recvmsg(struct ki
 	do
 	{
 		int chunk;
-		struct sk_buff *skb;
 
 		unix_state_lock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
@@ -1864,19 +1868,14 @@ static int unix_stream_recvmsg(struct ki
 
 			if (siocb->scm->fp)
 				break;
-		}
-		else
-		{
-			/* It is questionable, see note in unix_dgram_recvmsg.
-			 */
-			if (UNIXCB(skb).fp)
-				siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+		} else
+			__skb_queue_head(&peek_stack, skb);
+	} while (size);
 
-			/* put message back and return */
+	/* Push all peeked skbs back onto receive queue */
+	if (flags & MSG_PEEK)
+		while ((skb = __skb_dequeue(&peek_stack)))
 			skb_queue_head(&sk->sk_receive_queue, skb);
-			break;
-		}
-	} while (size);
 
 	mutex_unlock(&u->readlock);
 	scm_recv(sock, msg, siocb->scm, flags);
