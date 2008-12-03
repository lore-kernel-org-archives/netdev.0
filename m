From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 03 Dec 2008 15:37:05 +0100
Message-ID: <1228315025.4112.21.camel@nathan.suse.cz>
References: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:38368 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751198AbYLCOhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2008 09:37:09 -0500
In-Reply-To: <Pine.LNX.4.64.0812031320340.31282@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=C3=A4rvinen p=C3=AD=C5=A1e v St 03. 12. 2008 v 13:22 +0200:
> I should have noticed this earlier... :-) The previous solution
> to URG+GSO/TSO will cause SACK block tcp_fragment to do zig-zig
> patterns, or even worse, a steep downward slope into packet
> counting because each skb pcount would be truncated to pcount
> of 2 and then the following fragments of the later portion would
> restore the window again.

Oops, not nice. :(

> Basically this reverts "tcp: Do not use TSO/GSO when there is
> urgent data" (33cf71cee1). It also removes some unnecessary code
> from tcp_current_mss that didn't work as intented either (could
> be that something was changed down the road, or it might have
> been broken since the dawn of time) because it only works once
> urg is already written while this bug shows up starting from
> ~64k before the urg point.
>=20
> The retransmissions already are split to mss sized chunks, so
> only new data sending paths need splitting in case they have
> a segment otherwise suitable for gso/tso. The actually check
> can be improved to be more narrow but since this is late -rc
> already, I'll postpone thinking the more fine-grained things.
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
> Cc: Petr Tesarik <ptesarik@suse.cz>

Yes, re-fragmenting the packet here is probably the best way to go. But
repeating the same condition on multiple places is not so nice. What
about this little improvement?

(I didn't roll the revert of 33cf71cee1 into it, as it makes the actual
change less obvious. I think there are better ways of doing a revert in
git.)

Signed-off-by: Petr Tesarik <ptesarik@suse.cz>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

--
 tcp_output.c |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index ba85d88..a45c62d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1028,10 +1028,6 @@ unsigned int tcp_sync_mss(struct sock *sk, u32 p=
mtu)
=20
 /* Compute the current effective MSS, taking SACKs and IP options,
  * and even PMTU discovery events into account.
- *
- * LARGESEND note: !tcp_urg_mode is overkill, only frames up to snd_up
- * cannot be large. However, taking into account rare use of URG, this
- * is not a big flaw.
  */
 unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 {
@@ -1046,7 +1042,7 @@ unsigned int tcp_current_mss(struct sock *sk, int=
 large_allowed)
=20
 	mss_now =3D tp->mss_cache;
=20
-	if (large_allowed && sk_can_gso(sk) && !tcp_urg_mode(tp))
+	if (large_allowed && sk_can_gso(sk))
 		doing_tso =3D 1;
=20
 	if (dst) {
@@ -1113,6 +1109,10 @@ static void tcp_cwnd_validate(struct sock *sk)
  * return whenever allowed by the other factors). Basically we need th=
e
  * modulo only when the receiver window alone is the limiting factor o=
r
  * when we would be allowed to send the split-due-to-Nagle skb fully.
+ *
+ * LARGESEND note: !tcp_urg_mode is overkill, only frames between
+ * snd_up-64k-mss .. snd_up cannot be large. However, taking into
+ * account rare use of URG, this is not a big flaw.
  */
 static unsigned int tcp_mss_split_point(struct sock *sk, struct sk_buf=
f *skb,
 					unsigned int mss_now, unsigned int cwnd)
@@ -1120,6 +1120,9 @@ static unsigned int tcp_mss_split_point(struct so=
ck *sk, struct sk_buff *skb,
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	u32 needed, window, cwnd_len;
=20
+	if (unlikely(tcp_urg_mode(tp)))
+		return mss_now;
+
 	window =3D tcp_wnd_end(tp) - TCP_SKB_CB(skb)->seq;
 	cwnd_len =3D mss_now * cwnd;
=20


