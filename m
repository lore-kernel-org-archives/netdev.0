From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] inet: add IP_BIND_ADDRESS_NO_PORT to overcome
 bind(0) limitations
Date: Sat, 06 Jun 2015 10:39:55 -0700
Message-ID: <1433612395.1895.101.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433605985.1895.84.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHo-OowXiXLEc-7TJKUfK2gZespVPN1S8ZN+h4JBHL_8wRw-4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Kerrisk <mtk.manpages@gmail.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:34457 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751930AbbFFRj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jun 2015 13:39:57 -0400
Received: by igbhj9 with SMTP id hj9so35273460igb.1
        for <netdev@vger.kernel.org>; Sat, 06 Jun 2015 10:39:56 -0700 (PDT)
In-Reply-To: <CAHo-OowXiXLEc-7TJKUfK2gZespVPN1S8ZN+h4JBHL_8wRw-4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-06-06 at 18:38 +0200, Maciej =C5=BBenczykowski wrote:
> Hmm, I certainly like this.
>=20
> So IMHO this is indeed much better than a sysctl to select a magic
> port to ignore during a bind call (previous internal patchset),
> although it does use up one more bit per socket (and one more syscall
> per connect).
>=20
> ---
>=20
> Thinking about this some more, I think it might be possible to make
> this behaviour automatic in certain cases.
>=20
> The new socket bit has 2 different meanings, depending on whether a
> port is already allocated or not.
>   if a port is not yet allocated, it governs whether bind(port=3D0) w=
ill
> allocate a port.
>   if a port is already allocated, it flags whether it was autoallocat=
ed
> (obviously could also just use 2 bits instead of 1)
>=20
> bind(with port=3D0)
>   if the flag is set, doesn't select a port [ie. this patch]
>   if the flag wasn't set, selects a port, sets the flag


But this the problematic part here with multi threaded applications,
and servers where all ephemeral ports are already in use by at least on=
e
socket.

Also think about cohabitation with applications not using yet this
knowledge (lets say they use bind(0), getsockname(), connect())

My patch allows bind(0) to succeed even if all ports are in use.

Then connect() is almost guaranteed to succeed, unless this host alread=
y
have ~32000 sessions with exact same=20
(source_ip, destination_ip, destination_port) 3-tuple.

connect() already can return EADDRINUSE for this case.
(Some applications tried SO_REUSEADDR or SO_REUSEPORT to get rid of the
problem, with no great success)

So I am not sure what the 'automatic' stuff would provide anyway ?

Selecting a port is quite expensive because of all the spinlocks and
lookups, so doing this twice automatically would add a significant cost=
=2E

Thanks.
