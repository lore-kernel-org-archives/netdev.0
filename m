From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 21 Feb 2012 19:41:23 +0100
Message-ID: <1329849683.18384.41.camel@edumazet-laptop>
References: <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <16215291.4ftfQWZto1@localhost.localdomain>
	 <1329429573.5450.2.camel@edumazet-laptop>
	 <1843012.xoR1aAbfqy@localhost.localdomain>
	 <1329431746.2438.8.camel@edumazet-laptop>
	 <CADVnQynNEzJQvWdFeSDadPA7uZsraC64m=kNwe8M8sDsCyBD1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: alekcejk@googlemail.com, netdev@vger.kernel.org
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54302 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752638Ab2BUSl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 13:41:27 -0500
Received: by wics10 with SMTP id s10so3708870wic.19
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 10:41:26 -0800 (PST)
In-Reply-To: <CADVnQynNEzJQvWdFeSDadPA7uZsraC64m=kNwe8M8sDsCyBD1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 17 f=C3=A9vrier 2012 =C3=A0 11:41 -0500, Neal Cardwell a =C3=
=A9crit :
> On Thu, Feb 16, 2012 at 5:35 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> > An incoming skb is considered as "good citizen" in term of memory u=
sage
> > if its truesize is no more than
> > len + len/4   (if adv_win_scale =3D=3D 2)
> >
> > That was true when truesize was 1500+NET_SKB_PAD+sizeof(sk_buff),
> > but not true anymore when truesize is 2048+sizeof(sk_buff), or even=
 more
> > when its 4096+sizeof(sk_buff)
> >
> > So receiver doesnt increase rcv_ssthresh and cannot open its window=
=2E
> >
> > tcp_grow_window() should be tweaked to :
> >
> > 1) Relax the requirements
> > 2) Allow bigger increase in case of super packets (LRO/GRO)
>=20
> That sounds great. Is this something you're planning on tackling?
>=20

Hmm, I thought about following (untested) patch :

Idea is to increase rcv_sshthresh by 2*len * (len/truesize), instead of
2*mss.



diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 53c8ce4..3fcea17 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -327,11 +327,17 @@ static void tcp_grow_window(struct sock *sk, cons=
t struct sk_buff *skb)
 		/* Check #2. Increase window, if skb with such overhead
 		 * will fit to rcvbuf in future.
 		 */
-		if (tcp_win_from_space(skb->truesize) <=3D skb->len)
-			incr =3D 2 * tp->advmss;
-		else
-			incr =3D __tcp_grow_window(sk, skb);
+		if (tp->rx_opt.rcv_wscale) {
+			u64 scaled =3D (u64)skb->len * skb->len;
=20
+			do_div(scaled, skb->truesize >> 1);
+			incr =3D (int)scaled;
+		} else {
+			if (tcp_win_from_space(skb->truesize) <=3D skb->len)
+				incr =3D 2 * tp->advmss;
+			else
+				incr =3D __tcp_grow_window(sk, skb);
+		}
 		if (incr) {
 			tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr,
 					       tp->window_clamp);
