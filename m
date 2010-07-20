From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: recv(2), MSG_TRUNK and kernels older than 2.6.22
Date: Tue, 20 Jul 2010 12:02:51 +0200
Message-ID: <1279620171.2498.30.camel@edumazet-laptop>
References: <4C455DC3.1050304@marples.name>
	 <1279616099.2498.9.camel@edumazet-laptop>  <4C45678A.4080408@marples.name>
	 <1279617873.2498.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Roy Marples <roy@marples.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46321 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757985Ab0GTKCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 06:02:55 -0400
Received: by wwj40 with SMTP id 40so608068wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 03:02:54 -0700 (PDT)
In-Reply-To: <1279617873.2498.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 20 juillet 2010 =C3=A0 11:24 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 20 juillet 2010 =C3=A0 10:08 +0100, Roy Marples a =C3=A9crit=
 :
> > On 20/07/2010 09:54, Eric Dumazet wrote:
> > > Is it for the dhcpcd problem we talk about few week ago, disturbe=
d by
> > > new 64bit stats ?
> >=20
> > Yes
> >=20
> > >
> > > Why do you want to have a fixed size of 256 bytes ?
> > >
> > > Using 8192 bytes on stack would avoid MSG_TRUNK mess.
> >=20
> > Yes it would, but that doesn't answer my question :)
>=20
> Your question might be wrong ? :=3D)
>=20
> > I would like to use a buffer big enough, but not a whole 8k in size=
=2E
> > dhcpcd has quite a small runtime and I'd like to keep it that way.
>=20
> 8192 bytes on stack is too much for you ?
>=20
> Then you should automatically resize your buffer, and not using
> MSG_TRUNK at all (there is no guarantee the information you need will=
 be
> part of the truncated part)
>=20
>=20

On < 2.6.22 kernels, recv() returns the length of your buffer, not size
of netlink frame.

You'll need something like :

size_t sz =3D 256;
char *buf =3D malloc(sz);
while (1) {
	if (!buf) error();
	len =3D recv(fd, buf, sz, MSG_PEEK | MSG_TRUNC);
	if (len < sz)
		break;
	if (len =3D=3D sz)
		sz *=3D 2; // old kernel, try to double size
	else
		sz =3D len; // recent kernel is nice with us
	buf =3D realloc(buf, sz);
}
len =3D recv(fd, buf, sz, 0);




