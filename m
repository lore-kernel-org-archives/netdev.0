From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Mon, 23 May 2011 14:50:58 +0200
Message-ID: <1306155058.20687.8.camel@edumazet-laptop>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
	 <1306153938.20687.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38523 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753106Ab1EWMvC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 08:51:02 -0400
Received: by wya21 with SMTP id 21so4167814wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 05:51:01 -0700 (PDT)
In-Reply-To: <1306153938.20687.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 mai 2011 =C3=A0 14:32 +0200, Eric Dumazet a =C3=A9crit :

> Ouch, thats an ip_fragment() bug I am afraid... nothing to do with SF=
Q
>=20
> It calls=20
>=20
> err =3D output(skb);
>=20
> and a bit later does :
>=20
> skb =3D frag;
> frag =3D skb->next;   // thats completely illegal here !
> skb->next =3D NULL;
>=20
> I am cooking a patch and send it in a couple of minutes.

Oh well, false alarm, I am still trying to understand the case.

Some other reports would be appreciated, because here is the strange
thing :

[ 4461.969603] Code: b6 70 10=20
3b b3 08 01 00 00=20
0f 8d df 01 00 00 jge ....

41 8b 74 24 28    mov 0x28(%r12),%esi       qdisc_pkt_len(skb)
01 b3 b4 00 00 00                       sch->qstats.backlog +=3D qdisc_=
pkt_len(skb);

RAX =3D slot
R12 =3D SKB

48 8b 70 08       mov    0x8(%rax),%rsi     slot->skblist_prev
49 89 04 24       mov    %rax,(%r12)        skb->next =3D (struct sk_bu=
ff *)slot;
49 89 74 24 08    mov    %rsi,0x8(%r12)     skb->prev =3D slot->skblist=
_prev;
48 8b 70 08       mov    0x8(%rax),%rsi     slot->skblist_prev   (refet=
ch)

<4c> 89 26        mov    %r12,(%rsi)         slot->skblist_prev->next =3D=
 skb;  // CRASH

0f b6 f2          movzbl %dl,%esi
4c 89 60 08       mov    %r12,0x8(%rax)      slot->skblist_prev =3D skb=
;
48 8d 3c 76       lea
48 8d bc fb 90 01 00



And in your report RAX =3D R12 !!! (ffff8801172a7d08) I cant see how it
can happen (Its not even a valid skb address, since an SKB should be
64bytes aligned)

If available a disassembly of sfq_enqueue() would be appreciated too ;)

Thanks !


