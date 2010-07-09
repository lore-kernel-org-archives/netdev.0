From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 09 Jul 2010 07:28:54 +0200
Message-ID: <1278653334.2435.196.camel@edumazet-laptop>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
	 <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
	 <20100708.213420.112614033.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, rjw@sisk.pl,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, kaber@trash.net, jengelh@medozas.de,
	casteyde.christian@free.fr
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63634 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750815Ab0GIF3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jul 2010 01:29:33 -0400
In-Reply-To: <20100708.213420.112614033.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 juillet 2010 =C3=A0 21:34 -0700, David Miller a =C3=A9crit =
:
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 8 Jul 2010 18:34:25 -0700
>=20
> > On Thu, Jul 8, 2010 at 4:33 PM, Rafael J. Wysocki <rjw@sisk.pl> wro=
te:
> >>
> >> Bug-Entry       : http://bugzilla.kernel.org/show_bug.cgi?id=3D161=
87
> >> Subject         : Carrier detection failed in dhcpcd when link is =
up
> >> Submitter       : Christian Casteyde <casteyde.christian@free.fr>
> >> Date            : 2010-06-12 15:15 (27 days old)
> >> First-Bad-Commit: http://git.kernel.org/linus/10708f37ae729baba9b6=
7bd134c3720709d4ae62
> >> Handled-By      : Andrew Morton <akpm@linux-foundation.org>
> >=20
> > David? This bisects to a networking commit. Doesn't look sensible, =
but
> > what do I know?
>=20
> My suspicion is that dhcpd uses netlink to dump the info of the
> available links, and due to some bug gets confused with the new 64-bi=
t
> statistic netlink attribute being there now.
> a second to have a look at this.

It could be a dhcpcd bug because of extended size of answer

According to strace, dhcpcd tries a recvmsg() call with
a 256 bytes buffer to hold answer.

Looking at current dhcpcd source, I confirm it cannot realloc its buffe=
r

static int
get_netlink(int fd, int flags,
    int (*callback)(struct nlmsghdr *))
{
        char *buffer =3D NULL;
        ssize_t bytes;
        struct nlmsghdr *nlm;
        int r =3D -1;

        buffer =3D xzalloc(sizeof(char) * BUFFERLEN);
        for (;;) {
                bytes =3D recv(fd, buffer, BUFFERLEN, flags);
                if (bytes =3D=3D -1) {
                        if (errno =3D=3D EAGAIN) {
                                r =3D 0;
                                goto eexit;
                        }
                        if (errno =3D=3D EINTR)
                                continue;
                        goto eexit;
                }


This program needs to fix this.


