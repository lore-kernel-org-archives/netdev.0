From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Sat, 18 Sep 2004 20:25:49 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <E1C8cPd-0006K8-00@gondolin.me.apana.org.au>
References: <412F1269.8090303@eurodev.net>
Cc: davem@redhat.com, linux-net@vger.kernel.org, netdev@oss.sgi.com,
	kaber@trash.net
Return-path: <linux-net-owner@vger.kernel.org>
To: pablo@eurodev.net (Pablo Neira)
In-Reply-To: <412F1269.8090303@eurodev.net>
List-Id: netdev.vger.kernel.org

Pablo Neira <pablo@eurodev.net> wrote:
> 
> thanks, I fixed, I shouldn't type at 5 a.m. If any other problem, please 
> let me know.

Sorry I should've reviewed this patch sooner.  It finally caught my
attention as I went to update the 2.4 IPsec backport.

Firstly there is a sock leak there.  The following patch fixes it.
The white space damage is not mine :)

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Secondly, I'm dubious about the patch as a whole.  For instance, what
exactly is the wake_up_process() bit trying to do? Surely that process
would've been woken up multiple times already if its queue is full.  If
it can't empty the queue fast enough, what is this extra wake up going
to achieve?

And what is it going to do with thread groups?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
===== net/netlink/af_netlink.c 1.52 vs edited =====
--- 1.52/net/netlink/af_netlink.c	2004-08-28 10:11:04 +10:00
+++ 2.6/net/netlink/af_netlink.c	2004-09-18 20:09:20 +10:00
@@ -630,7 +630,8 @@
 
 			if (!nlwork)
 				return -1;
-		
+
+			sock_hold(sk);
 			INIT_WORK(&nlwork->work, netlink_wq_handler, nlwork);
 			nlwork->sk = sk;
 			nlwork->len = skb->len;
@@ -683,14 +684,13 @@
 			netlink_overrun(sk);
 			/* Clone failed. Notify ALL listeners. */
 			failure = 1;
-			sock_put(sk);
 		} else if (netlink_broadcast_deliver(sk, skb2)) {
 			netlink_overrun(sk);
-			sock_put(sk);
 		} else {
 			delivered = 1;
 			skb2 = NULL;
 		}
+		sock_put(sk);
 	}
 
 	netlink_unlock_table();
--
===== net/netlink/af_netlink.c 1.15 vs edited =====
--- 1.15/net/netlink/af_netlink.c	2004-08-31 10:04:34 +10:00
+++ 2.4/net/netlink/af_netlink.c	2004-09-18 20:25:29 +10:00
@@ -549,7 +549,8 @@
 		
 			if  (!nlwork) 
 				return -EAGAIN;
-		
+
+			sock_hold(sk);
 			INIT_TQUEUE(&nlwork->work, netlink_tq_handler, nlwork);
 			nlwork->sk = sk;
 			nlwork->len = skb->len;
@@ -601,12 +602,11 @@
 			netlink_overrun(sk);
 			/* Clone failed. Notify ALL listeners. */
 			failure = 1;
-			sock_put(sk);
 		} else if (netlink_broadcast_deliver(sk, skb2)) {
 			netlink_overrun(sk);
-			sock_put(sk);
 		} else
 			skb2 = NULL;
+		sock_put(sk);
 	}
 
 	netlink_unlock_table();
