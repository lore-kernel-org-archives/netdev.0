From: Ofer Heifetz <oferh@marvell.com>
Subject: RE: Splice status
Date: Mon, 5 Jul 2010 16:47:56 +0300
Message-ID: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B6E4@IL-MB01.marvell.com>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
 <1278334254.2877.158.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from galiil.marvell.com ([199.203.130.254]:8709 "EHLO
	galiil.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751387Ab0GENtJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 09:49:09 -0400
In-Reply-To: <1278334254.2877.158.camel@edumazet-laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Well, Samba still disables splice support (hard coded), I applied your =
patch (adding the SPLICE_F_NONBLOCK to the splice(sock, pipe)) and I ma=
naged to write 4G file to Samba share.

I did notice that the splice is done on buffers in two sizes: 1380 and =
2760 (when writing to share file), I guess that if I can get samba to u=
se bigger buffers it will reduce the splice calls and achieve better pe=
rformance.

I also saw that when re-writing a file splice does use the maximum buff=
er size (~16K) occasionally.

Need to perform some more testing with samba splice ...

-Ofer

-----Original Message-----
=46rom: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
Sent: Monday, July 05, 2010 3:51 PM
To: Ofer Heifetz
Cc: Changli Gao; netdev@vger.kernel.org
Subject: RE: Splice status

Le lundi 05 juillet 2010 =E0 13:52 +0300, Ofer Heifetz a =E9crit :
> I am using Samba, so from my understanding of the source code, it
loops and performs splice(sock, pipe) and splice(pipe, fd). There is no
flush of any sort in between.
>=20
> When you say drain you mean to flush all data to pipe?
>=20

Draining pipe before splice() call would only trigger the bug less
often.

splice(sock, pipe) can block if caller dont use appropriate "non
blocking pipe' splice() mode, even if pipe is empty before a splice()
call.

Last time I checked, splice() code was disabled in samba.

Is it a patched version ?

Samba should add SPLICE_F_NONBLOCK to first splice() call (from sock to
pipe)

(You also need a recent kernel, check for details :
http://patchwork.ozlabs.org/patch/34511/ )

diff --git a/source3/lib/recvfile.c b/source3/lib/recvfile.c
index ea01596..65e6f34 100644
--- a/source3/lib/recvfile.c
+++ b/source3/lib/recvfile.c
@@ -182,7 +182,7 @@ ssize_t sys_recvfile(int fromfd,
                int nread, to_write;
=20
                nread =3D splice(fromfd, NULL, pipefd[1], NULL,
-                              MIN(count, 16384), SPLICE_F_MOVE);
+                              MIN(count, 16384), SPLICE_F_MOVE | SPLIC=
E_F_NONBLOCK);
                if (nread =3D=3D -1) {
                        if (errno =3D=3D EINTR) {
                                continue;


