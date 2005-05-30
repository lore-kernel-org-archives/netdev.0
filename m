From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Bug in 2.6.11.11 - udp_poll(), fragments + CONFIG_HIGHMEM
Date: Tue, 31 May 2005 07:49:30 +1000
Message-ID: <E1Dcs8Y-0006bl-00@gondolin.me.apana.org.au>
References: <E1DclTK-0002qE-00@mta1.cl.cam.ac.uk>
Cc: linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, Steven.Hand@cl.cam.ac.uk, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Steven.Hand@cl.cam.ac.uk (Steven Hand)
In-Reply-To: <E1DclTK-0002qE-00@mta1.cl.cam.ac.uk>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Hand <Steven.Hand@cl.cam.ac.uk> wrote:
> 
> Reconstructed forward trace: 
> 
>   net/ipv4/udp.c:1334   spin_lock_irq() 
>   net/ipv4/udp.c:1336   udp_checksum_complete() 
> net/core/skbuff.c:1069   skb_shinfo(skb)->nr_frags > 1
> net/core/skbuff.c:1086   kunmap_skb_frag()
> net/core/skbuff.h:1087   local_bh_enable()
> kernel/softirq.c:0140   WARN_ON(irqs_disabled());

Thanks for catching this.  The receive queue lock is never taken
in IRQs (and should never be) so we can simply substitute bh for
irq.

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
@@ -738,7 +738,7 @@ int udp_ioctl(struct sock *sk, int cmd, 
 			unsigned long amount;
 
 			amount = 0;
-			spin_lock_irq(&sk->sk_receive_queue.lock);
+			spin_lock_bh(&sk->sk_receive_queue.lock);
 			skb = skb_peek(&sk->sk_receive_queue);
 			if (skb != NULL) {
 				/*
@@ -748,7 +748,7 @@ int udp_ioctl(struct sock *sk, int cmd, 
 				 */
 				amount = skb->len - sizeof(struct udphdr);
 			}
-			spin_unlock_irq(&sk->sk_receive_queue.lock);
+			spin_unlock_bh(&sk->sk_receive_queue.lock);
 			return put_user(amount, (int __user *)arg);
 		}
 
@@ -848,12 +848,12 @@ csum_copy_err:
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
@@ -1334,7 +1334,7 @@ unsigned int udp_poll(struct file *file,
 		struct sk_buff_head *rcvq = &sk->sk_receive_queue;
 		struct sk_buff *skb;
 
-		spin_lock_irq(&rcvq->lock);
+		spin_lock_bh(&rcvq->lock);
 		while ((skb = skb_peek(rcvq)) != NULL) {
 			if (udp_checksum_complete(skb)) {
 				UDP_INC_STATS_BH(UDP_MIB_INERRORS);
@@ -1345,7 +1345,7 @@ unsigned int udp_poll(struct file *file,
 				break;
 			}
 		}
-		spin_unlock_irq(&rcvq->lock);
+		spin_unlock_bh(&rcvq->lock);
 
 		/* nothing to see, move along */
 		if (skb == NULL)
