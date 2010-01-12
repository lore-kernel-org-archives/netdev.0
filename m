From: "James Kosin" <JKosin@intcomgrp.com>
Subject: RE: arm: Optimization for ethernet MAC handling at91_ether.c
Date: Tue, 12 Jan 2010 14:39:43 -0500
Message-ID: <3DBBD805E3BA064A87F551C0E8BD367402897428@MAILSRV.intcomgrp.com>
References: <3DBBD805E3BA064A87F551C0E8BD3674028973F5@MAILSRV.intcomgrp.com> <4B4CA4E5.7030800@gmail.com> <3DBBD805E3BA064A87F551C0E8BD36740289740E@MAILSRV.intcomgrp.com> <4B4CBA93.4090909@gmail.com> <3DBBD805E3BA064A87F551C0E8BD367402897418@MAILSRV.intcomgrp.com> <3DBBD805E3BA064A87F551C0E8BD36740289741C@MAILSRV.intcomgrp.com> <4B4CCC7B.8040609@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754824Ab0ALTiI@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B4CCC7B.8040609@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-----Original Message-----
>From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
>Sent: Tuesday, January 12, 2010 2:25 PM
>To: James Kosin
>Cc: linux-kernel@vger.kernel.org; Linux Netdev List
>Subject: Re: arm: Optimization for ethernet MAC handling at91_ether.c
>
>Le 12/01/2010 20:03, James Kosin a =E9crit :
>>=20
>> Scratch that.  The interrupt doesn't queue up or send another packet=
 directly.  So, it wouldn't help on performance here.  But, may in othe=
r implementations that queue/transmit packets in the ISR.  At least in =
the case where the transmitter is limited to one.
>>=20
>
>It could, at least on SMP. tx completion wakes a blocked sender, while
>this cpu continue with RX handling (possibly expensive)
>
>But even on UP, doing tx completion before rx handling allows
>a better reuse of skb just freed (and partly present in cpu cache, if =
available).
>
>Start of IRQ
>
>1) tx completion
>    -> free a skb
>
>2) rx handling:
>    -> allocate an skb, kmalloc() reuses previous one, still in cpu ca=
che.
>
>End of IRQ

I think this may work to improve things slightly; since, the transmitte=
r always frees the skb regardless of error or success currently.

What I was proposing was to modify the sequence slightly to be more lik=
e this:

1) tx completion
	-> test for TX TUND error
		-> resend the current skb (to avoid having to re-do)
	-> else
		-> test for TX RTRY error
			-> increment error count as before
		-> free the skb
