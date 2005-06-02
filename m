From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [SCTP] Replace spin_lock_irqsave with spin_lock_bh
Date: Thu, 2 Jun 2005 19:54:59 +1000
Message-ID: <20050602095459.GA26638@gondor.apana.org.au>
References: <20050602094404.GA10316@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050602094404.GA10316@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch replaces the spin_lock_irqsave call on the receive queue
lock in SCTP with spin_lock_bh.  Despite the proliferation of
spin_lock_irqsave calls in this stack, it is only entered from the
IPv4/IPv6 stack and user space.  That is, it is never entered from
hardirq context.

The call in question is only called from recvmsg which means that
IRQs aren't disabled.  Therefore it is safe to replace it with
spin_lock_bh.
 
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

As before, this should probably only go into net-2.6.13.
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4368,15 +4368,11 @@ static struct sk_buff *sctp_skb_recv_dat
 		 *  However, this function was corrent in any case. 8)
 		 */
 		if (flags & MSG_PEEK) {
-			unsigned long cpu_flags;
-
-			sctp_spin_lock_irqsave(&sk->sk_receive_queue.lock,
-					       cpu_flags);
+			spin_lock_bh(&sk->sk_receive_queue.lock);
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb)
 				atomic_inc(&skb->users);
-			sctp_spin_unlock_irqrestore(&sk->sk_receive_queue.lock,
-						    cpu_flags);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
 		} else {
 			skb = skb_dequeue(&sk->sk_receive_queue);
 		}

--2oS5YaxWCcQjTEyO--
