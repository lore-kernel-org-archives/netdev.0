From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 22:41:38 +1100
Message-ID: <20081217114138.GA20976@gondor.apana.org.au>
References: <Pine.LNX.4.64.0812171004500.9494@wrl-59.cs.helsinki.fi> <E1LCtP8-0004QO-Bp@gondolin.me.apana.org.au> <20081217103129.GA17248@gondor.apana.org.au> <20081217104254.GA17407@gondor.apana.org.au> <1229511143.13305.23.camel@nathan.suse.cz> <20081217112600.GA19106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo J??rvinen <ilpo.jarvinen@helsinki.fi>, davem@davemloft.net,
	netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Petr Tesarik <ptesarik@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:58186 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751091AbYLQLlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 06:41:50 -0500
Content-Disposition: inline
In-Reply-To: <20081217112600.GA19106@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 17, 2008 at 10:26:00PM +1100, Herbert Xu wrote:
>
> I just checked NetBSD and guess what, they do exactly what I've
> suggested:

Actually the code quoted is from OpenBSD but I just checked
again and NetBSD does the same thing, while FreeBSD doesn't
check for overflows at all (Oops!).

> 	if (SEQ_GT(tp->snd_up, tp->snd_nxt)) {
> 		u_int32_t urp = tp->snd_up - tp->snd_nxt;
> 		if (urp > IP_MAXPACKET)
> 			urp = IP_MAXPACKET;
> 		th->th_urp = htons((u_int16_t)urp);
> 		th->th_flags |= TH_URG;
> 	} else  
> 
> So if you think this is bad then it's been there for decades :)

In case you still think you can rely on the urgent behaviour
you should check out this document:

http://tools.ietf.org/html/draft-gont-tcpm-urgent-data-00

So I think given all of the above setting the urg_ptr to 0xffff
is a good compromise.  Yes it does have the downside that the
recipient may misbehave by taking things out-of-band but an app
that doesn't deal with this is broken anyway since that's exactly
what'll happen if you run it under BSD.  On the plus side, we'll
actually signal urgent mode as soon as possible which is about
the only sensible thing to do for urgent data.

In other words what we do currently potentially makes urgent
mode completely useless since it may delay the sending of the
urgent notification indefinitely.  While the BSD behaviour would
only break "broken" applications.

Anyway, here's the patch:

tcp: Set urgent pointer even if we're more than 64K from the end

Our TCP stack does not set the urgent flag if the urgent pointer
does not fit in 16 bits, i.e., if it is more than 64K from the
sequence number of a packet.

This behaviour is different from NetBSD and OpenBSD, and clearly
contradicts the purpose of urgent mode, which is to send the
notification (though not necessarily the associated data) as soon
as possible.  Our current behaviour may in fact delay the urgent
message indefinitely if the receiver window does not open up.

This patch modifies our behaviour to align with that of the BSDs.

The potential downside is that applications that does not cope
with out-of-band data correctly may be confused by originally
in-band stuff going out-of-band.  However, such applications
are seriously broken anyway because this can occur when it runs
on any BSD or if urgent notifications are merged.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fe3b4bd..2964c77 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -663,10 +663,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	th->urg_ptr		= 0;
 
 	/* The urg_mode check is necessary during a below snd_una win probe */
-	if (unlikely(tcp_urg_mode(tp) &&
-		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
-		th->urg_ptr		= htons(tp->snd_up - tcb->seq);
+	if (unlikely(tcp_urg_mode(tp))) {
 		th->urg			= 1;
+		if (between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))
+			th->urg_ptr = htons(tp->snd_up - tcb->seq);
+		else
+			th->urg_ptr = 0xFFFF;
 	}
 
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
