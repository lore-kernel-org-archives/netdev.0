From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: commit 64ff3b938ec6782e6585a83d5459b98b0c3f6eb8 breaks rlogin
Date: Sat, 21 Feb 2009 21:24:24 +0800
Message-ID: <20090221132424.GA28861@gondor.apana.org.au>
References: <20090206054541.GA4954@gondor.apana.org.au> <b6a2187b0902060335h646e8d86pf00773035f577665@mail.gmail.com> <20090209055848.GA3889@gondor.apana.org.au> <20090208.220357.261414983.davem@davemloft.net> <20090209061151.GA3982@gondor.apana.org.au> <Pine.LNX.4.64.0902090853360.20576@wrl-59.cs.helsinki.fi> <20090209072806.GB4380@gondor.apana.org.au> <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	rjw@sisk.pl, torvalds@linux-foundation.org,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41225 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751651AbZBUNYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 08:24:48 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0902091513190.31742@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 09, 2009 at 03:28:09PM +0200, Ilpo J=E4rvinen wrote:
>
> Yes, that should work too except the gcc catchable typo.

Thanks, so let's try again for net-next:

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

Thanks to Ilpo J=E4rvinen for fixing a critical bug in this and
Jeff Chua for reporting that bug.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dda42f0..f5263c8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -663,10 +663,14 @@ static int tcp_transmit_skb(struct sock *sk, stru=
ct sk_buff *skb, int clone_it,
 	th->urg_ptr		=3D 0;
=20
 	/* The urg_mode check is necessary during a below snd_una win probe *=
/
-	if (unlikely(tcp_urg_mode(tp) &&
-		     between(tp->snd_up, tcb->seq + 1, tcb->seq + 0xFFFF))) {
-		th->urg_ptr		=3D htons(tp->snd_up - tcb->seq);
-		th->urg			=3D 1;
+	if (unlikely(tcp_urg_mode(tp) && before(tcb->seq, tp->snd_up))) {
+		if (before(tp->snd_up, tcb->seq + 0x10000)) {
+			th->urg_ptr =3D htons(tp->snd_up - tcb->seq);
+			th->urg =3D 1;
+		} else if (after(tcb->seq + 0xFFFF, tp->snd_nxt)) {
+			th->urg_ptr =3D 0xFFFF;
+			th->urg =3D 1;
+		}
 	}
=20
 	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
