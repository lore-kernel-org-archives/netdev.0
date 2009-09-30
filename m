From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Wed, 30 Sep 2009 06:54:25 +0200
Message-ID: <4AC2E481.5060509@gmail.com>
References: <20090930004820.GC19540@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57450 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbZI3EzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 00:55:00 -0400
In-Reply-To: <20090930004820.GC19540@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason Gunthorpe a =E9crit :
> Eric,
>=20
> I saw your patch from January regarding splicing on blocking sockets,
> and I wondered what ever happened to it?
>=20
> http://lkml.org/lkml/2009/1/13/507
>=20
> It doesn't look like it has been applied.. I see the patch thread die=
d
> at davem's comments?
>=20
> I have run into exactly the same problem as Samba, where I'd like the
> TCP socket to be blocking, and the pipe to be non blocking ...
>=20
> As it stands,=20
>   splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE);=20
> causes a random endless block and
>   splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
> will return 0 immediately if the TCP buffer is empty.
>=20
> FWIW, it looks like samba has a splice code now, but doesn't enable i=
t
> due to this issue?
>=20
> http://git.samba.org/?p=3Dsamba.git;a=3Dhistory;f=3Dsource3/lib/recvf=
ile.c;h=3Dea0159642137390a0f7e57a123684e6e63e47581;hb=3DHEAD
>=20
> Thanks,
> Jason

Hi Jason, thanks for this reminding

Hmm, most probably I did not replied correctly do David objection which=
 was :

Date	Wed, 14 Jan 2009 20:58:39 -0800 (PST)
Subject	Re: maximum buffer size for splice(2) tcp->pipe?
=46rom	David Miller <>

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 14 Jan 2009 00:38:32 +0100
> [PATCH] net: splice() from tcp to socket should take into account O_N=
ONBLOCK
>=20
> Instead of using SPLICE_F_NONBLOCK to select a non blocking mode both=
 on
> source tcp socket and pipe destination, we use the underlying file fl=
ag (O_NONBLOCK)
> for selecting a non blocking socket.
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

This needs at least some more thought.

It seems, for one thing, that this change will interfere with the
intentions of the code in splice_dirt_to_actor which goes:

	/*
	 * Don't block on output, we have to drain the direct pipe.
	 */
	sd->flags &=3D ~SPLICE_F_NONBLOCK;

-----------------------------------------------------------------------=
-------

But splice_dist_to_actor() handles a REG/BLK file as input and a pipe a=
s output,
so I believe my patch wont change splice_dist_to_actor() behavior.

My patch title was wrong :

net: splice() from tcp to socket should take into account O_NONBLOCK


So maybe David was mistaken by the title :)


[PATCH] net: splice() from tcp to pipe should take into account O_NONBL=
OCK

Before this patch :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE);=20
causes a random endless block (if pipe is full) and
splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
will return 0 immediately if the TCP buffer is empty.

User application has no way to instruct splice() that socket should be =
in blocking mode
but pipe in nonblock more.
=20
http://git.samba.org/?p=3Dsamba.git;a=3Dhistory;f=3Dsource3/lib/recvfil=
e.c;h=3Dea0159642137390a0f7e57a123684e6e63e47581;hb=3DHEAD

One way to handle this is to switch tcp_read() to use the underlying fi=
le O_NONBLOCK
flag, as other socket operations do. And let SPLICE_F_NONBLOCK control =
the pipe output only.

Users will then call :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK );=20

to block on data coming from socket (if file is in blocking mode),
and not block on pipe output (to avoid deadlock)

Reported-by: Volker Lendecke <vl@samba.org>
Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 21387eb..8cdfab6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -580,7 +580,7 @@ ssize_t tcp_splice_read(struct socket *sock, loff_t=
 *ppos,
=20
 	lock_sock(sk);
=20
-	timeo =3D sock_rcvtimeo(sk, flags & SPLICE_F_NONBLOCK);
+	timeo =3D sock_rcvtimeo(sk, sock->file->f_flags & O_NONBLOCK);
 	while (tss.len) {
 		ret =3D __tcp_splice_read(sk, &tss);
 		if (ret < 0)
