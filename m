From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Clone skb before setting peeked flag
Date: Mon, 13 Jul 2015 16:04:13 +0800
Message-ID: <20150713080413.GA8901@gondor.apana.org.au>
References: <20150710115141.12980.88829.stgit@buzz>
 <20150713072352.GA8485@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:42350 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415AbbGMIET (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jul 2015 04:04:19 -0400
Content-Disposition: inline
In-Reply-To: <20150713072352.GA8485@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shared skbs must not be modified and this is crucial for broadcast
and/or multicast paths where we use it as an optimisation to avoid
unnecessary cloning.

The function skb_recv_datagram breaks this rule by setting peeked
without cloning the skb first.  This causes funky races which leads
to double-free.

This patch fixes this by cloning the skb and replacing the skb
in the list when setting skb->peeked.

Fixes: a59322be07c9 ("[UDP]: Only increment counter on first peek/recv")
Reported-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/datagram.c b/net/core/datagram.c
index b80fb91..4e9a3f6 100644
--- a/net/core/datagram.c
+++ b/net/core/datagram.c
@@ -131,6 +131,35 @@ out_noerr:
 	goto out;
 }
 
+static int skb_set_peeked(struct sk_buff *skb)
+{
+	struct sk_buff *nskb;
+
+	if (skb->peeked)
+		return 0;
+
+	/* We have to unshare an skb before modifying it. */
+	if (!skb_shared(skb))
+		goto done;
+
+	nskb = skb_clone(skb, GFP_ATOMIC);
+	if (!nskb)
+		return -ENOMEM;
+
+	skb->prev->next = nskb;
+	skb->next->prev = nskb;
+	nskb->prev = skb->prev;
+	nskb->next = skb->next;
+
+	consume_skb(skb);
+	skb = nskb;
+
+done:
+	skb->peeked = 1;
+
+	return 0;
+}
+
 /**
  *	__skb_recv_datagram - Receive a datagram skbuff
  *	@sk: socket
@@ -165,7 +194,9 @@ out_noerr:
 struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 				    int *peeked, int *off, int *err)
 {
+	struct sk_buff_head *queue = &sk->sk_receive_queue;
 	struct sk_buff *skb, *last;
+	unsigned long cpu_flags;
 	long timeo;
 	/*
 	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
@@ -184,8 +215,6 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 		 * Look at current nfs client by the way...
 		 * However, this function was correct in any case. 8)
 		 */
-		unsigned long cpu_flags;
-		struct sk_buff_head *queue = &sk->sk_receive_queue;
 		int _off = *off;
 
 		last = (struct sk_buff *)queue;
@@ -199,7 +228,11 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 					_off -= skb->len;
 					continue;
 				}
-				skb->peeked = 1;
+
+				error = skb_set_peeked(skb);
+				if (error)
+					goto unlock_err;
+
 				atomic_inc(&skb->users);
 			} else
 				__skb_unlink(skb, queue);
@@ -223,6 +256,8 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
 
 	return NULL;
 
+unlock_err:
+	spin_unlock_irqrestore(&queue->lock, cpu_flags);
 no_packet:
 	*err = error;
 	return NULL;
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
