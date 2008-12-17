From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Thu, 18 Dec 2008 10:15:43 +1100
Message-ID: <20081217231543.GA28459@gondor.apana.org.au>
References: <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au> <20081217114138.GA20976@gondor.apana.org.au> <20081217125505.GA8379@ms2.inr.ac.ru> <20081217153015.GA17903@ms2.inr.ac.ru> <20081217212907.GA27243@gondor.apana.org.au> <20081217225231.GA28052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Petr Tesarik <ptesarik@suse.cz>,
	Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>,
	davem@davemloft.net, netdev@vger.kernel.org
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750796AbYLQXQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:16:04 -0500
Content-Disposition: inline
In-Reply-To: <20081217225231.GA28052@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 09:52:31AM +1100, Herbert Xu wrote:
> 
> 1) Fix fresh transmissions of urgent mode as Alexey suggested.
> 
> This is the safest way of ensuring that the urgent notification
> is not delayed.  This is still not as "fast" as the BSD behaviour
> but it is much safer with respect to broken^H^H^H^H^H^Hlegacy
> applications.

tcp: Always set urgent pointer if it's beyond snd_nxt

Our TCP stack does not set the urgent flag if the urgent pointer
does not fit in 16 bits, i.e., if it is more than 64K from the
sequence number of a packet.

This behaviour is different from the BSDs, and clearly contradicts
the purpose of urgent mode, which is to send the notification
(though not necessarily the associated data) as soon as possible.
Our current behaviour may in fact delay the urgent notification
indefinitely if the receiver window does not open up.

Simply matching BSD however may break legacy applications which
incorrectly rely on the out-of-band delivery of urgent data, and
conversely the in-band delivery of non-urgent data.

Alexey Kuznetsov suggested a safe solution of following BSD only
if the urgent pointer itself has not yet been transmitted.  This
way we guarantee that when the remote end sees the packet with
non-urgent data marked as urgent due to wrap-around we would have
advanced the urgent pointer beyond, either to the actual urgent
data or to an as-yet untransmitted packet.

The only potential downside is that applications on the remote
end may see multiple SIGURG notifications.  However, this would
occur anyway with other TCP stacks.  More importantly, the outcome
of such a duplicate notification is likely to be harmless since
the signal itself does not carry any information other than the
fact that we're in urgent mode.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fe3b4bd..e6e0319 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -663,10 +663,14 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	th->urg_ptr		= 0;
 
 	/* The urg_mode check is necessary during a below snd_una win probe */
-	if (unlikely(tcp_urg_mode(tp) &&
-		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
-		th->urg_ptr		= htons(tp->snd_up - tcb->seq);
-		th->urg			= 1;
+	if (unlikely(tcp_urg_mode(tp))) {
+		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF)) {
+			th->urg_ptr = htons(tp->snd_up - tcb->seq);
+			th->urg = 1;
+		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
+			th->urg_ptr = 0xFFFF;
+			th->urg = 1;
+		}
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
