From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: bug in qavg calculation in include/net/red.h (resending as
 plain-text email)
Date: Thu, 05 Jan 2012 22:19:56 +0100
Message-ID: <1325798396.2748.19.camel@edumazet-laptop>
References: <67E2BF19E6D6A749A7680AEF496EB37C39D9204067@GVW0547EXC.americas.hpqcorp.net>
	 <1325794400.2748.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Yalagandula, Praveen" <praveen.yalagandula@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:60565 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948Ab2AEVUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 16:20:04 -0500
Received: by wibhm6 with SMTP id hm6so663687wib.19
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2012 13:20:03 -0800 (PST)
In-Reply-To: <1325794400.2748.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 janvier 2012 =C3=A0 21:13 +0100, Eric Dumazet a =C3=A9crit =
:
> Le jeudi 05 janvier 2012 =C3=A0 19:30 +0000, Yalagandula, Praveen a =C3=
=A9crit :
> > (Resending as plain text)
> >=20
> > Dear Alexey,
> >=20
> > The code (see below) for computing the queue average for RED
> > implementation in Linux kernel has a bug. The return line should be
> > "return p->qavg + ((backlog - p->qavg) >> p->Wlog);".=20
> >=20
> > qavg =3D qavg*(1-W) + backlog*W
> >=20
> >      =3D qavg + (backlog-qavg)*W
> >=20
> > The current buggy code applies right shift to only the previous qav=
g,
> > where as it should be applied to (backlog - qavg). Hope you can get
> > this bug corrected.
>=20
> Code is correct.
>=20
> Please read the comment, it really explains the thing.
>=20

I have more time to explain what's going on :

On input, "unsigned int backlog" is not yet scaled.
But qavg _is_ scaled by p->Wlog.

So we should first scale "backlog" by Wlog bits to the left :

backlog_scaled =3D backlog << p->Wlog;

Then we do our computation as you stated :

return p->qavg + ((backlog_scaled - p->qavg) >> p->Wlog);

Its equivalent to current code, but using a single shift to the right.

return p->qavg + (backlog - (p->qavg >> p->Wlog));


Hope this helps.
