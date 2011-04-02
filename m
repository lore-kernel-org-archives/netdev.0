From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 02 Apr 2011 21:44:55 +0200
Message-ID: <1301773495.2837.26.camel@edumazet-laptop>
References: <201104022001.48144.cyril.bonte@free.fr>
	 <1301767848.2837.14.camel@edumazet-laptop>
	 <201104022046.11701.cyril.bonte@free.fr>  <20110402191516.GG5552@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cyril =?ISO-8859-1?Q?Bont=E9?= <cyril.bonte@free.fr>,
	netdev@vger.kernel.org, Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:44157 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756717Ab1DBTpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 15:45:02 -0400
Received: by wwa36 with SMTP id 36so5202422wwa.1
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2011 12:45:01 -0700 (PDT)
In-Reply-To: <20110402191516.GG5552@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 02 avril 2011 =C3=A0 21:15 +0200, Willy Tarreau a =C3=A9crit =
:
> Hi Eric,
>=20
> On Sat, Apr 02, 2011 at 08:46:11PM +0200, Cyril Bont=C3=A9 wrote:
> > Le samedi 2 avril 2011 20:10:48, Eric Dumazet a =C3=A9crit :
> > > Le samedi 02 avril 2011 =C3=A0 20:01 +0200, Cyril Bont=C3=A9 a =C3=
=A9crit :
> > > (...)
> > > > > 		if (shutdown(listenfd, SHUT_WR) =3D=3D 0 &&
> > > > 	=09
> > > > 		    listen(listenfd, 1024) =3D=3D 0 &&
> > > > 		    shutdown(listenfd, SHUT_RD) =3D=3D 0) {
> > > > 		=09
> > > > 			printf("shutdown OK\n");
> > > > 	=09
> > > > 		}
> > > > =09
> > > > 	}
> > > > 	exit(0);
> > > >=20
> > > > }
> > >=20
> > > Wow, not clear what this is doing....
> > >=20
> > > for sure the listen() call is not needed ?
> > >=20
> > > And the shutdown(listenfd, SHUT_WR) is clearly useless too.
> >=20
> > Well, I'm not the best one to explain that part but from what i rea=
d in the=20
> > comments of this part of code, both listen and SHUT_WR are used to =
detect=20
> > errors on various OS (OpenBSD, Solaris, ...).
> >=20
> > > I feel you only needed the shutdown(listenfd, SHUT_RD) call.
> > >=20
> > > Why haproxy needs to setup a second listening socket on same port=
 ?
> >=20
> > I simplified the test case, which is far from what haproxy do (just=
 forgot to=20
> > explain the real behaviour).
> > To reload the configuration, a new haproxy process is launched, sen=
ding a=20
> > signal to the previous one and asking it to free the ports for a wh=
ile (the=20
> > shutdown part in the test). The new process then tries to bind the =
ports,=20
> > which worked until 2.6.38 (if an error occurs, a new signal is sent=
 to the=20
> > previous process to listen to its sockets again).
>=20
> Indeed, here's what normally happens when haproxy reloads.
>=20
> New process is loaded with a new config. Once the config correctly pa=
rses,
> it sends a signal to the previous process asking it to temporarily re=
lease
> its listening ports so that the new one can bind, hence the shutdown(=
SHUT_RD)
> performed in the old process.
>=20
> Then the new process can grab the ports and listen to them. Once that=
's OK,
> it sends another signal to the old process telling it it can go away.=
 But
> if the new process failed to completely start (eg: could not grab one=
 port),
> then it sends a third signal to the old process asking it to rebind t=
he port
> and serve them again, and the new one dies with an error.
>=20
> That way, the service is never interrupted even if the new config fai=
ls
> late, because the old process has the ability to rebind to the port i=
t
> temporarily released.
>=20
> Now with 2.6.38, as Cyril diagnosed it, the new bind() fails when the
> old process has just performed its shutdown(SHUT_RD), preventing the
> new process from binding to the ports until the old process has
> definitely closed them.
>=20
> The behaviour is very useful, because the old process might have lost
> its privileges, it will not have to rebind to the socket, just listen
> on it again since it is never closed.
>=20
> This is quite embarrassing, because this code used to work for the
> last 10 years, at least since kernel 2.2, and maybe even 2.0, I don't
> remember.
>=20
> I'm not sure what the original intent of the patch was, not what was
> the reported issue, but maybe we could find a way to both fix the
> reported issue (if any) and restore the old behaviour in order not
> to break existing programs.
>=20
> Best regards,
> Willy
>=20

I wish it was that simple....

http://www.spinics.net/lists/netdev/msg151551.html

Is Cyril program running OK on FreeBsd ?



