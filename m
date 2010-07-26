From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: lock_sock or sock_hold ?
Date: Mon, 26 Jul 2010 16:43:26 +0200
Message-ID: <1280155406.2899.407.camel@edumazet-laptop>
References: <AANLkTim7LQ65RWvy+TQ+HtwjJM89zt4g12H6mFinQT0v@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Neshama Parhoti <pneshama@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58327 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754681Ab0GZOna (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jul 2010 10:43:30 -0400
Received: by eya25 with SMTP id 25so471288eya.19
        for <netdev@vger.kernel.org>; Mon, 26 Jul 2010 07:43:28 -0700 (PDT)
In-Reply-To: <AANLkTim7LQ65RWvy+TQ+HtwjJM89zt4g12H6mFinQT0v@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 26 juillet 2010 =C3=A0 17:00 +0300, Neshama Parhoti a =C3=A9cr=
it :
> hello everyone,
>=20
> can you please be kind and help me understand the differences between
> lock_sock and sock_hold ?
>=20
> i can see that lock_sock takes a spin lock (bh) to mark owned =3D 1, =
and
> then takes a mutex, whereas sock_hold only increases the atomic
> refcnt.
>=20
> but how do i know which of them I should use ?
>=20
> i'm puzzled as to when should those two different APIs be used..

sock_hold() only increments a refcount, so that you are sure nobody can
destroy the socket (and its memory) under you. But you cannot modify
socket state only with this refcount taken.

To get exclusive access to the socket you either :

1) Are in process context and use lock_sock().

2) Are in softirq context (input path for example) :
 2.1) Lookup the socket in protocol hash tables, and get a refcount on
it (by sock_hold() or other atomic operation on refcnt)

 2.2) Then, get semi exclusive access using bh_lock_sock()
 2.3) Check if another process already is using the socket (we
interrupted this process on same CPU, or run on another cpu)
   if (sock_owned_by_user(sk)) {
	// queue work to socket backlog (delayed work)
   } else {
	// process packet right now
   }


