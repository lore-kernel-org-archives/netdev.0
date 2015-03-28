From: Dave Taht <dave.taht@gmail.com>
Subject: notifications of interfaces going down/up/being created/destroyed?
Date: Sat, 28 Mar 2015 09:37:24 -0700
Message-ID: <CAA93jw7u=aPjXVME5WwCa97tbD1-5XpgRPg_C9y2kH9qkrt1mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35134 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752284AbbC1QhY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 12:37:24 -0400
Received: by pacwz10 with SMTP id wz10so73884330pac.2
        for <netdev@vger.kernel.org>; Sat, 28 Mar 2015 09:37:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

is there an asynchronous way to register for a notification of an
interface going down/up?

---------- Forwarded message ----------
=46rom: Juliusz Chroboczek <jch@pps.univ-paris-diderot.fr>
Date: Sat, Mar 28, 2015 at 9:30 AM
Subject: Re: [Babel-users] Looping in EAGAIN
To: Dave Taht <dave.taht@gmail.com>
Cc: Simon Kelley <simon@thekelleys.org.uk>,
"babel-users@lists.alioth.debian.org"
<babel-users@lists.alioth.debian.org>


> Say wlan0 vanishes. All the routes going out that interface are no
> longer valid, but from what I understood of this patch, it will loop =
for
> a while, then give up.

If wlan0 vanishes, this will be recognised the next time check_interfac=
es
is run, and all neighbours visible through wlan0 will be flushed.

The issue we're having is a race condition -- if wlan0 goes down and th=
en
back up before we run check_interfaces, and the IP addresses don't chan=
ge,
then check_interfaces will not notice the transition, and Babel will th=
ink
that its routes through wlan0 are still up -- end you end up with a FIB
that is not a subset of the RIB.  Ouch.

So it might be a good idea to run check_interfaces early when we get
EAGAIN, but I'm not sure what consequences it might have -- EAGAIN can
also happen when we're under load, and we'd rather not be repeatedly
scanning our interfaces in that case.

It would be better to get async notifications from the kernel about
interfaces going down.

> Not clear to me if this would happen for 4 hello intervals before the
> interface is recognised as gone?

No, the hellos are used to notice vanishing neighbours, not vanishing
interfaces.  That's a completely different mechanism.

-- Juliusz


--=20
Dave T=C3=A4ht
Let's make wifi fast, less jittery and reliable again!

https://plus.google.com/u/0/107942175615993706558/posts/TVX3o84jjmb
