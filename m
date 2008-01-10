From: Brent Casavant <bcasavan@sgi.com>
Subject: Re: AF_UNIX MSG_PEEK bug?
Date: Wed, 9 Jan 2008 20:50:06 -0600 (CST)
Message-ID: <alpine.BSF.1.00.0801092031290.35527@pkunk.americas.sgi.com>
References: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
Reply-To: Brent Casavant <bcasavan@sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: penguin-kernel@i-love.sakura.ne.jp, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:46921 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754137AbYAJCuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 21:50:09 -0500
In-Reply-To: <E1JCkrp-0000vX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Jan 2008, Herbert Xu wrote:

> Having said that, I do agree that having TCP and AF_UNIX behave
> in the same way is a plus.  However, if you really want this to
> happen it would help if you had attached a patch :)

The following patch appears to fix the problem.  However, I would
really appreciate if someone more familiar with UNIX credential
passing could review what I did here and provide some feedback.
It wasn't at all clear to me why the MSG_PEEK and !MSG_PEEK code
paths were taking different actions regarding credentials, so I
unified them to behave the same way as the !MSG_PEEK code path.

I haven't tested credential passing under this new code yet, but
hope to do so tomorrow.  Again, a review with an eye towards
that area would be most appreciated.

The various test cases I had which tripped this bug now pass without
incident.  Also, if netstat is to be believed, quite a few programs
which utilize AF_UNIX sockets (e.g. hald, dbus, acpid) are running
very contentedly on the test system, so at least I didn't severely
break anything, possible UNIX credential issues notwithstanding.

Note: I'm not proposing this patch be integrated yet -- I'm throwing
it out here as a starting point.

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 060bba4..2ffdf5b 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -50,6 +50,9 @@
  *	     Arnaldo C. Melo	:	Remove MOD_{INC,DEC}_USE_COUNT,
  *	     				the core infrastructure is doing that
  *	     				for all net proto families now (2.5.69+)
+ *		Brent Casavant	:	SOCK_STREAM MSG_PEEK should peek
+ *					far enough ahead to satisfy the request
+ *					rather than stop after the first skb.
  *
  *
  * Known differences from reference BSD that was tested:
@@ -1750,6 +1753,8 @@ static int unix_stream_recvmsg(struct ki
 	int target;
 	int err = 0;
 	long timeo;
+	struct sk_buff *skb;
+	struct sk_buff_head peek_stack;
 
 	err = -EINVAL;
 	if (sk->sk_state != TCP_ESTABLISHED)
@@ -1759,6 +1764,9 @@ static int unix_stream_recvmsg(struct ki
 	if (flags&MSG_OOB)
 		goto out;
 
+	if (flags & MSG_PEEK)
+		skb_queue_head_init(&peek_stack);
+
 	target = sock_rcvlowat(sk, flags&MSG_WAITALL, size);
 	timeo = sock_rcvtimeo(sk, flags&MSG_DONTWAIT);
 
@@ -1778,7 +1786,6 @@ static int unix_stream_recvmsg(struct ki
 	do
 	{
 		int chunk;
-		struct sk_buff *skb;
 
 		unix_state_lock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
@@ -1845,39 +1852,31 @@ static int unix_stream_recvmsg(struct ki
 		copied += chunk;
 		size -= chunk;
 
-		/* Mark read part of skb as used */
-		if (!(flags & MSG_PEEK))
-		{
-			skb_pull(skb, chunk);
-
-			if (UNIXCB(skb).fp)
-				unix_detach_fds(siocb->scm, skb);
+		/* Credential passing */
+		if (UNIXCB(skb).fp)
+			unix_detach_fds(siocb->scm, skb);
 
-			/* put the skb back if we didn't use it up.. */
+		if (!(flags & MSG_PEEK)) {
+			/* Mark read part of skb as used */
+			skb_pull(skb, chunk);
+			/* Return unused portion or free skb */
 			if (skb->len)
-			{
 				skb_queue_head(&sk->sk_receive_queue, skb);
-				break;
-			}
-
-			kfree_skb(skb);
-
-			if (siocb->scm->fp)
-				break;
-		}
-		else
-		{
-			/* It is questionable, see note in unix_dgram_recvmsg.
-			 */
-			if (UNIXCB(skb).fp)
-				siocb->scm->fp = scm_fp_dup(UNIXCB(skb).fp);
+			else
+				kfree_skb(skb);
+		} else
+			__skb_queue_head(&peek_stack, skb);
 
-			/* put message back and return */
-			skb_queue_head(&sk->sk_receive_queue, skb);
+		/* Stop early when passed credentials are encountered */
+		if (siocb->scm->fp)
 			break;
-		}
 	} while (size);
 
+	/* Push all peeked skbs back onto receive queue */
+	if (flags & MSG_PEEK)
+		while ((skb = __skb_dequeue(&peek_stack)))
+			skb_queue_head(&sk->sk_receive_queue, skb);
+
 	mutex_unlock(&u->readlock);
 	scm_recv(sock, msg, siocb->scm, flags);
 out:
