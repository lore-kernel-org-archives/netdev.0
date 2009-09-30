From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Splice on blocking TCP sockets again..
Date: Wed, 30 Sep 2009 08:19:37 +0200
Message-ID: <4AC2F879.4080807@gmail.com>
References: <20090930004820.GC19540@obsidianresearch.com> <4AC2E481.5060509@gmail.com> <20090930054031.GY22310@obsidianresearch.com> <4AC2F1D9.1010801@gmail.com> <4AC2F3E4.5000904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Volker Lendecke <vl@samba.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42153 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582AbZI3GTq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2009 02:19:46 -0400
In-Reply-To: <4AC2F3E4.5000904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Eric Dumazet a =E9crit :
>> Jason Gunthorpe a =E9crit :
>>>> One way to handle this is to switch tcp_read() to use the underlyi=
ng file O_NONBLOCK
>>>> flag, as other socket operations do. And let SPLICE_F_NONBLOCK con=
trol the pipe output only.
>> arg, this was tcp_splice_read() of course
>>
>>> Thanks Eric, this seems reasonable from my userspace perspective.
>>>
>>> I admit I don't understand why SPLICE_F_NONBLOCK exists, it seems v=
ery
>>> un-unixy to have a syscall completely ignore the NONBLOCK flag of t=
he
>>> fd it is called on. Ie setting NONBLOCK on the pipe itself does
>>> nothing when using splice..
>>>
>> Hmm, good question, I dont have the answer but I'll digg one.
>>
>=20
> commit	29e350944fdc2dfca102500790d8ad6d6ff4f69d
> splice: add SPLICE_F_NONBLOCK flag
>=20
> It doesn't make the splice itself necessarily nonblocking (because th=
e
> actual file descriptors that are spliced from/to may block unless the=
y
> have the O_NONBLOCK flag set), but it makes the splice pipe operation=
s
> nonblocking.
>=20
> Signed-off-by: Linus Torvalds <torvalds@osdl.org>
>=20
>=20
> See Linus intention was pretty clear : O_NONBLOCK should be taken int=
o account
> by 'actual file that are spliced from/to', regardless of SPLICE_F_NON=
BLOCK flag
>=20

I also found first submission of the patch from Octavian Purdila,
so credit should be given to Octavian as well.

http://lkml.indiana.edu/hypermail/linux/kernel/0807.2/0687.html

We could add Linus into the discussion if it can help to make progress =
on this point.

I personally stopped to use splice(tcp -> pipe) in my projects because =
it was not usable=20
in a reliable way.

Thanks


[PATCH] net: splice() from tcp to pipe should take into account O_NONBL=
OCK

tcp_splice_read() doesnt take into account socket's O_NONBLOCK flag

Before this patch :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE);=20
causes a random endless block (if pipe is full) and
splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK);
will return 0 immediately if the TCP buffer is empty.

User application has no way to instruct splice() that socket should be =
in blocking mode
but pipe in nonblock more.

Many projects cannot use splice(tcp -> pipe) because of this flaw.
=20
http://git.samba.org/?p=3Dsamba.git;a=3Dhistory;f=3Dsource3/lib/recvfil=
e.c;h=3Dea0159642137390a0f7e57a123684e6e63e47581;hb=3DHEAD
http://lkml.indiana.edu/hypermail/linux/kernel/0807.2/0687.html

Linus introduced  SPLICE_F_NONBLOCK in commit 29e350944fdc2dfca10250079=
0d8ad6d6ff4f69d
(splice: add SPLICE_F_NONBLOCK flag )

  It doesn't make the splice itself necessarily nonblocking (because th=
e
  actual file descriptors that are spliced from/to may block unless the=
y
  have the O_NONBLOCK flag set), but it makes the splice pipe operation=
s
  nonblocking.


Linus intention was clear : let SPLICE_F_NONBLOCK control the splice pi=
pe mode only


This patch instruct tcp_splice_read() to use the underlying file O_NONB=
LOCK
flag, as other socket operations do.


Users will then call :

splice(socket,0,pipe,0,128*1024,SPLICE_F_MOVE | SPLICE_F_NONBLOCK );=20

to block on data coming from socket (if file is in blocking mode),
and not block on pipe output (to avoid deadlock)

=46irst version of this patch was submitted by Octavian Purdila

Reported-by: Volker Lendecke <vl@samba.org>
Reported-by: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
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
