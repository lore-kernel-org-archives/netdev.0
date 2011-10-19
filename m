From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/3] net: time stamping fixes
Date: Wed, 19 Oct 2011 15:09:54 +0200
Message-ID: <1319029794.4424.37.camel@jlt3.sipsolutions.net>
References: <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 <cover.1318498805.git.richard.cochran@omicron.at>
	 <20111019.001610.312990203017422173.davem@davemloft.net>
	 <1319001336.4424.8.camel@jlt3.sipsolutions.net>
	 <20111019115012.GA7206@netboy.at.omicron.at>
	 <1319027881.3103.27.camel@edumazet-laptop>
	 (sfid-20111019_143837_360206_014A6AA4)  <1319029101.4424.36.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:38162 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751679Ab1JSNJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 09:09:58 -0400
In-Reply-To: <1319029101.4424.36.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-10-19 at 14:58 +0200, Johannes Berg wrote:

> Not disputing this either. But you said sk_refcnt can be 0, so why can't
> the following happen:
> 
> /* skb; skb->sk = sk; skb->destructor = sock_wfree; */
> 
> /* skb is on qdisc, some time passes */
> 
> sk_free(sk); /* user closed socket,
>                 sk->sk_refcnt reaches 0,
> 		sk->sk_wmem_alloc == skb->truesize,
> 		__sk_free not called, socket still lives,
> 		but no more +1 in sk_wmem_alloc */
> 
> /* some more time passes */
> 
> /* ethernet hard_start_xmit calls skb_clone_tx_timestamp() */
> skb2 = skb_clone(skb);
> skb2->sk = skb->sk;
> sock_hold(skb->sk);
> 
> /* ethernet TX completion calls skb_free(skb) */
> skb_free(skb):
>   sock_wfree(skb); /* sk_wmem_alloc reaches 0,
>                       __sk_free called DESPITE sk_refcnt > 0 */
> 
> /* later, in skb_complete_tx_timestamp() */
> sock_put(sk);	/* KABOOM */


Given the complexity of all this, I'm not sure we shouldn't do something
like this, but I have no idea what the cost would be:

--- wireless-testing.orig/include/net/sock.h	2011-10-18 22:28:41.000000000 +0200
+++ wireless-testing/include/net/sock.h	2011-10-19 15:08:45.000000000 +0200
@@ -434,7 +434,10 @@ static __inline__ int __sk_del_node_init
 
 static inline void sock_hold(struct sock *sk)
 {
-	atomic_inc(&sk->sk_refcnt);
+	if (atomic_inc_return(&sk->sk_refcnt) == 1) {
+		/* was zero -- we must've gotten an sk_wmem_alloc reference */
+		atomic_inc(&sk->sk_wmem_alloc);
+	}
 }
 
 /* Ungrab socket in the context, which assumes that socket refcnt


johannes
