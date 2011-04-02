From: Willy Tarreau <w@1wt.eu>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 2 Apr 2011 22:37:27 +0200
Message-ID: <20110402203727.GI5552@1wt.eu>
References: <201104022001.48144.cyril.bonte@free.fr> <1301767848.2837.14.camel@edumazet-laptop> <201104022046.11701.cyril.bonte@free.fr> <20110402191516.GG5552@1wt.eu> <1301773495.2837.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyril =?iso-8859-1?Q?Bont=E9?= <cyril.bonte@free.fr>,
	netdev@vger.kernel.org, Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:62127 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756731Ab1DBUhe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Apr 2011 16:37:34 -0400
Content-Disposition: inline
In-Reply-To: <1301773495.2837.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 02, 2011 at 09:44:55PM +0200, Eric Dumazet wrote:
> Le samedi 02 avril 2011 =E0 21:15 +0200, Willy Tarreau a =E9crit :
> > Hi Eric,
> >=20
> > On Sat, Apr 02, 2011 at 08:46:11PM +0200, Cyril Bont=E9 wrote:
> > > Le samedi 2 avril 2011 20:10:48, Eric Dumazet a =E9crit :
> > > > Le samedi 02 avril 2011 =E0 20:01 +0200, Cyril Bont=E9 a =E9cri=
t :
> > > > (...)
> > > > > > 		if (shutdown(listenfd, SHUT_WR) =3D=3D 0 &&
> > > > > 	=09
> > > > > 		    listen(listenfd, 1024) =3D=3D 0 &&
> > > > > 		    shutdown(listenfd, SHUT_RD) =3D=3D 0) {
> > > > > 		=09
> > > > > 			printf("shutdown OK\n");
> > > > > 	=09
> > > > > 		}
> > > > > =09
> > > > > 	}
> > > > > 	exit(0);
> > > > >=20
> > > > > }
> > > >=20
> > > > Wow, not clear what this is doing....
> > > >=20
> > > > for sure the listen() call is not needed ?
> > > >=20
> > > > And the shutdown(listenfd, SHUT_WR) is clearly useless too.
> > >=20
> > > Well, I'm not the best one to explain that part but from what i r=
ead in the=20
> > > comments of this part of code, both listen and SHUT_WR are used t=
o detect=20
> > > errors on various OS (OpenBSD, Solaris, ...).
> > >=20
> > > > I feel you only needed the shutdown(listenfd, SHUT_RD) call.
> > > >=20
> > > > Why haproxy needs to setup a second listening socket on same po=
rt ?
> > >=20
> > > I simplified the test case, which is far from what haproxy do (ju=
st forgot to=20
> > > explain the real behaviour).
> > > To reload the configuration, a new haproxy process is launched, s=
ending a=20
> > > signal to the previous one and asking it to free the ports for a =
while (the=20
> > > shutdown part in the test). The new process then tries to bind th=
e ports,=20
> > > which worked until 2.6.38 (if an error occurs, a new signal is se=
nt to the=20
> > > previous process to listen to its sockets again).
> >=20
> > Indeed, here's what normally happens when haproxy reloads.
> >=20
> > New process is loaded with a new config. Once the config correctly =
parses,
> > it sends a signal to the previous process asking it to temporarily =
release
> > its listening ports so that the new one can bind, hence the shutdow=
n(SHUT_RD)
> > performed in the old process.
> >=20
> > Then the new process can grab the ports and listen to them. Once th=
at's OK,
> > it sends another signal to the old process telling it it can go awa=
y. But
> > if the new process failed to completely start (eg: could not grab o=
ne port),
> > then it sends a third signal to the old process asking it to rebind=
 the port
> > and serve them again, and the new one dies with an error.
> >=20
> > That way, the service is never interrupted even if the new config f=
ails
> > late, because the old process has the ability to rebind to the port=
 it
> > temporarily released.
> >=20
> > Now with 2.6.38, as Cyril diagnosed it, the new bind() fails when t=
he
> > old process has just performed its shutdown(SHUT_RD), preventing th=
e
> > new process from binding to the ports until the old process has
> > definitely closed them.
> >=20
> > The behaviour is very useful, because the old process might have lo=
st
> > its privileges, it will not have to rebind to the socket, just list=
en
> > on it again since it is never closed.
> >=20
> > This is quite embarrassing, because this code used to work for the
> > last 10 years, at least since kernel 2.2, and maybe even 2.0, I don=
't
> > remember.
> >=20
> > I'm not sure what the original intent of the patch was, not what wa=
s
> > the reported issue, but maybe we could find a way to both fix the
> > reported issue (if any) and restore the old behaviour in order not
> > to break existing programs.
> >=20
> > Best regards,
> > Willy
> >=20
>=20
> I wish it was that simple....
>=20
> http://www.spinics.net/lists/netdev/msg151551.html

What a mess :-(

I've been used to actively bind() to source ip:ports when dealing with =
that
number of connections, because I've long noticed that the port auto-sel=
ection
did not work once all source ports were used on at least one IP address=
=2E
Managing a source port list in user space is no big deal when you have =
to
support hundreds of thousands of connections, as there are harder issue=
s
to deal with :-/

> Is Cyril program running OK on FreeBsd ?

I don't think so, as from memories, both FreeBSD and OpenBSD fail
on isten() after a shutdown(SHUT_RD), hence the strange looking
shut+listen+shut sequence you noticed (in order to detect whether
listen will work again or not).

I'm just wondering the relation between the SHUT_RD listen sockets
that we catch by accident and the issue that was the initial goal
of the patch regarding outgoing sockets. All this is not very clear
to me yet.

Regards,
Willy

