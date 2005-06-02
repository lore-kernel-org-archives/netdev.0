From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV4/IPV6] Replace spin_lock_irq with spin_lock_bh
Date: Thu, 2 Jun 2005 19:44:04 +1000
Message-ID: <20050602094404.GA10316@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="cWoXeonUoKmBZSoM"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

In light of my recent patch to net/ipv4/udp.c that replaced the
spin_lock_irq calls on the receive queue lock with spin_lock_bh,
here is a similar patch for all other occurences of spin_lock_irq
on receive/error queue locks in IPv4 and IPv6.

In these stacks, we know that they can only be entered from user
or softirq context.  Therefore it's safe to disable BH only.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au> 

Since this patch simply improves the consistent use of locking
primitives rather fixing any real bugs, it should probably go
into net-2.6.13.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--cWoXeonUoKmBZSoM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -360,14 +360,14 @@ int ip_recv_error(struct sock *sk, struc
 	err = copied;
 
 	/* Reset and regenerate socket error */
-	spin_lock_irq(&sk->sk_error_queue.lock);
+	spin_lock_bh(&sk->sk_error_queue.lock);
 	sk->sk_err = 0;
 	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
 		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_irq(&sk->sk_error_queue.lock);
+		spin_unlock_bh(&sk->sk_error_queue.lock);
 		sk->sk_error_report(sk);
 	} else
-		spin_unlock_irq(&sk->sk_error_queue.lock);
+		spin_unlock_bh(&sk->sk_error_queue.lock);
 
 out_free_skb:	
 	kfree_skb(skb);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -691,11 +691,11 @@ static int raw_ioctl(struct sock *sk, in
 			struct sk_buff *skb;
 			int amount = 0;
 
-			spin_lock_irq(&sk->sk_receive_queue.lock);
+			spin_lock_bh(&sk->sk_receive_queue.lock);
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb != NULL)
 				amount = skb->len;
-			spin_unlock_irq(&sk->sk_receive_queue.lock);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
 			return put_user(amount, (int __user *)arg);
 		}
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -353,14 +353,14 @@ int ipv6_recv_error(struct sock *sk, str
 	err = copied;
 
 	/* Reset and regenerate socket error */
-	spin_lock_irq(&sk->sk_error_queue.lock);
+	spin_lock_bh(&sk->sk_error_queue.lock);
 	sk->sk_err = 0;
 	if ((skb2 = skb_peek(&sk->sk_error_queue)) != NULL) {
 		sk->sk_err = SKB_EXT_ERR(skb2)->ee.ee_errno;
-		spin_unlock_irq(&sk->sk_error_queue.lock);
+		spin_unlock_bh(&sk->sk_error_queue.lock);
 		sk->sk_error_report(sk);
 	} else {
-		spin_unlock_irq(&sk->sk_error_queue.lock);
+		spin_unlock_bh(&sk->sk_error_queue.lock);
 	}
 
 out_free_skb:	
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -434,12 +434,12 @@ csum_copy_err:
 	/* Clear queue. */
 	if (flags&MSG_PEEK) {
 		int clear = 0;
-		spin_lock_irq(&sk->sk_receive_queue.lock);
+		spin_lock_bh(&sk->sk_receive_queue.lock);
 		if (skb == skb_peek(&sk->sk_receive_queue)) {
 			__skb_unlink(skb, &sk->sk_receive_queue);
 			clear = 1;
 		}
-		spin_unlock_irq(&sk->sk_receive_queue.lock);
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		if (clear)
 			kfree_skb(skb);
 	}
@@ -971,11 +971,11 @@ static int rawv6_ioctl(struct sock *sk, 
 			struct sk_buff *skb;
 			int amount = 0;
 
-			spin_lock_irq(&sk->sk_receive_queue.lock);
+			spin_lock_bh(&sk->sk_receive_queue.lock);
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb != NULL)
 				amount = skb->tail - skb->h.raw;
-			spin_unlock_irq(&sk->sk_receive_queue.lock);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
 			return put_user(amount, (int __user *)arg);
 		}
 
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -300,12 +300,12 @@ csum_copy_err:
 	/* Clear queue. */
 	if (flags&MSG_PEEK) {
 		int clear = 0;
-		spin_lock_irq(&sk->sk_receive_queue.lock);
+		spin_lock_bh(&sk->sk_receive_queue.lock);
 		if (skb == skb_peek(&sk->sk_receive_queue)) {
 			__skb_unlink(skb, &sk->sk_receive_queue);
 			clear = 1;
 		}
-		spin_unlock_irq(&sk->sk_receive_queue.lock);
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
 		if (clear)
 			kfree_skb(skb);
 	}

--cWoXeonUoKmBZSoM--
