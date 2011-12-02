From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Fri, 02 Dec 2011 21:45:56 +0100
Message-ID: <1322858756.2762.68.camel@edumazet-laptop>
References: <1322850989.2762.47.camel@edumazet-laptop>
	 <20111202.134040.638198723589712419.davem@davemloft.net>
	 <1322857369.2762.63.camel@edumazet-laptop>
	 <20111202.152426.447759025066188323.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: subramanian.vijay@gmail.com, therbert@google.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:42382 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308Ab1LBUqC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 15:46:02 -0500
Received: by bkas6 with SMTP id s6so4318696bka.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 12:46:01 -0800 (PST)
In-Reply-To: <20111202.152426.447759025066188323.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 15:24 -0500, David Miller a =C3=
=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 02 Dec 2011 21:22:49 +0100
>=20
> > Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 13:40 -0500, David Miller =
a =C3=A9crit :
> >=20
> >> Yes, for non-SG this always was technically possible.
> >>=20
> >=20
> > Yes this can, I reproduced it very easily.
> >=20
> > I find this hard to believe...
>=20
> Grrr :-)
>=20
> Ok, I'll think about this some more.

Maybe a quick fix would be to trim not len bytes but (len & ~3) bytes ?

This avoid reallocations and complex code for a 'should never happen in
normal circumstances'...

Retransmits could transmits 3 bytes already ACKed, is it a big deal ?

patch on top of linux/net tree :

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 63170e2..4e108c5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1126,7 +1126,7 @@ int tcp_trim_head(struct sock *sk, struct sk_buff=
 *skb, u32 len)
=20
 	/* If len =3D=3D headlen, we avoid __skb_pull to preserve alignment. =
*/
 	if (unlikely(len < skb_headlen(skb)))
-		__skb_pull(skb, len);
+		__skb_pull(skb, len & ~3); /* preserve alignement of tcp/ip headers =
*/
 	else
 		__pskb_trim_head(skb, len - skb_headlen(skb));
=20
