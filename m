From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] [PATCH] Don't destroy TCP sockets twice
Date: Tue, 10 Aug 2010 10:30:40 +0200
Message-ID: <20100810083040.GB6801@basil.fritz.box>
References: <20100806110511.GA16448@basil.fritz.box>
 <20100809213002.GA23736@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58459 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422Ab0HJIap (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Aug 2010 04:30:45 -0400
Content-Disposition: inline
In-Reply-To: <20100809213002.GA23736@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 09, 2010 at 05:30:02PM -0400, Herbert Xu wrote:
> Andi Kleen <andi@firstfloor.org> wrote:
> > 
> > While working on something else I noticed that tcp_v4/6_destroy_sock()
> > can get called twice on a socket. This happens because when a reset or
> > similar happens tcp_done destroys the connection socket state, and 
> > then eventually when the socket is released it is destroyed again. 
> 
> I'm still having problems understanding why you're getting a call
> to send a FIN after tcp_done.  This shouldn't happen at all because
> tcp_done moves the socket to the TCP_CLOSE state, where FINs should
> not be sent.
> 
> Can you clarify on how we can reproduce this problem in the
>  upstream kernel?

This simple patch demonstrates double destroy. I have patches for showing
the more complicated case too, but they're much more ugly.

-Andi

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..bfbb06b 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -459,6 +459,8 @@ struct tcp_sock {
 	 * contains related tcp_cookie_transactions fields.
 	 */
 	struct tcp_cookie_values  *cookie_values;
+
+	int destroyed;
 };
 
 static inline struct tcp_sock *tcp_sk(const struct sock *sk)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 0207662..25bf80a 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1919,6 +1919,9 @@ void tcp_v4_destroy_sock(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
+	BUG_ON(tp->destroyed != 0);
+	tp->destroyed = 1;
+
 	tcp_clear_xmit_timers(sk);
 
 	tcp_cleanup_congestion_control(sk);
-- 
ak@linux.intel.com -- Speaking for myself only.
