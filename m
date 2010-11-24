From: Cypher Wu <cypher.w@gmail.com>
Subject: Re: [PATCH] arch/tile: fix rwlock so would-be write lockers don't
 block new readers
Date: Thu, 25 Nov 2010 00:37:48 +0800
Message-ID: <AANLkTi=eXuRYK=JOx=JQ6fBFB4Hr2ajuO5So42nQm_za@mail.gmail.com>
References: <AANLkTikvT=x9eBovn2-m6HLqk7wyXSAR3sc9jCQ0C6mL@mail.gmail.com>
	<1289489007.17691.1310.camel@edumazet-laptop>
	<AANLkTik93QUQxSDmwd4Qj-gXQiWWPzd68JPAYAHBAsHR@mail.gmail.com>
	<ZXmP8hjgLHA.4648@exchange1.tad.internal.tilera.com>
	<4CDF1945.8090101@tilera.com>
	<AANLkTind92uwcigzmDn8yn9a22exDy7zcreGQ5-6NLV-@mail.gmail.com>
	<201011151425.oAFEPU3W005682@farm-0010.internal.tilera.com>
	<AANLkTikGj+zG9OqVJseKh4fGqQNnqnJpHgcaaXOL8nNi@mail.gmail.com>
	<4CEA71AD.5010606@tilera.com>
	<AANLkTim1YyujwGZfenU_m52HEJJSFmTg3Wswn2DkqA3a@mail.gmail.com>
	<4CEC2BE7.4060205@tilera.com>
	<AANLkTinx3pcJHGrQq_C-Rgk5g7SxjmpTcD0A50d8d48b@mail.gmail.com>
	<4CED1C87.7010500@tilera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	=?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52330 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754425Ab0KXQht convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 11:37:49 -0500
In-Reply-To: <4CED1C87.7010500@tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/11/24 Chris Metcalf <cmetcalf@tilera.com>:
> On 11/23/2010 9:53 PM, Cypher Wu wrote:
>> 2010/11/24 Chris Metcalf <cmetcalf@tilera.com>:
>>> On 11/22/2010 8:36 PM, Cypher Wu wrote:
>>>> Say, if core A try to write_lock() rwlock and current_ticket_ is 0=
 and
>>>> it write next_ticket_ to 1, when it processing the lock, core B tr=
y to
>>>> write_lock() again and write next_ticket_ to 2, then when A
>>>> write_unlock() it seen that (current_ticket_+1) is not equal to
>>>> next_ticket_, so it increment current_ticket_, and core B get the
>>>> lock. If core A try write_lock again before core B write_unlock, i=
t
>>>> will increment next_ticket_ to 3. And so on.
>>>> This may rarely happened, I've tested it yesterday for several hou=
rs
>>>> it goes very well under pressure.
>>> This should be OK when it happens (other than starving out the read=
ers, but
>>> that was the decision made by doing a ticket lock in the first plac=
e).
>>> Even if we wrap around 255 back to zero on the tickets, the ticket =
queue
>>> will work correctly. =A0The key is not to need more than 256 concur=
rent write
>>> lock waiters, which we don't.
>> If we count on that, should we make 'my_ticket_ =3D (val >>
>> WR_NEXT_SHIFT) & WR_MASK;'
>
> No, it's OK. =A0As the comment for the declaration of "my_ticket_" sa=
ys, the
> trailing underscore reminds us that the high bits are garbage, and wh=
en we
> use the value, we do the mask: "((my_ticket_ - curr_) & WR_MASK)". =A0=
It
> turned out doing the mask here made the most sense from a code-genera=
tion
> point of view, partly just because of the possibility of the counter =
wrapping.
>
> --
> Chris Metcalf, Tilera Corp.
> http://www.tilera.com
>
>

If wrap does occurr direct subtraction may cause problem, but
write_lock() is usually only lock very little code, and since two
issue of that call will take us so many cycles that one the same core
the time eslapsed will be enough that wrap will never occurr.


--=20
Cyberman Wu
http://www.meganovo.com
