From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Splice status
Date: Mon, 05 Jul 2010 17:34:21 +0200
Message-ID: <1278344061.2877.337.camel@edumazet-laptop>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
	 <1278334254.2877.158.camel@edumazet-laptop>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B6E4@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55996 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171Ab0GEPe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 11:34:27 -0400
Received: by fxm14 with SMTP id 14so3807744fxm.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 08:34:24 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B6E4@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 16:47 +0300, Ofer Heifetz a =C3=A9crit =
:
> Hi,
>=20
> Well, Samba still disables splice support (hard coded), I applied you=
r
> patch (adding the SPLICE_F_NONBLOCK to the splice(sock, pipe)) and I
> managed to write 4G file to Samba share.
>=20
> I did notice that the splice is done on buffers in two sizes: 1380 an=
d
> 2760 (when writing to share file), I guess that if I can get samba to
> use bigger buffers it will reduce the splice calls and achieve better
> performance.
>=20

Note that if your load increases or network is faster, splice will
naturally use more data per call. Dont worry.

Also, you can change MIN(count, 16384) to MIN(count, 65536) now the rea=
l
samba bug is known and can be fixed (by the SPLICE_F_NONBLOCK patch I
sent)

(I guess using 16384 instead of 65536 was a try to reduce hang
probability)


> I also saw that when re-writing a file splice does use the maximum
> buffer size (~16K) occasionally.

max is 16 * PAGE_SIZE, 65536 bytes on x86

>=20
> Need to perform some more testing with samba splice ...
>=20
> -Ofer
>=20
> -----Original Message-----
> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]=20
> Sent: Monday, July 05, 2010 3:51 PM
> To: Ofer Heifetz
> Cc: Changli Gao; netdev@vger.kernel.org
> Subject: RE: Splice status
>=20
> Le lundi 05 juillet 2010 =C3=A0 13:52 +0300, Ofer Heifetz a =C3=A9cri=
t :
> > I am using Samba, so from my understanding of the source code, it
> loops and performs splice(sock, pipe) and splice(pipe, fd). There is =
no
> flush of any sort in between.
> >=20
> > When you say drain you mean to flush all data to pipe?
> >=20
>=20
> Draining pipe before splice() call would only trigger the bug less
> often.
>=20
> splice(sock, pipe) can block if caller dont use appropriate "non
> blocking pipe' splice() mode, even if pipe is empty before a splice()
> call.
>=20
> Last time I checked, splice() code was disabled in samba.
>=20
> Is it a patched version ?
>=20
> Samba should add SPLICE_F_NONBLOCK to first splice() call (from sock =
to
> pipe)
>=20
> (You also need a recent kernel, check for details :
> http://patchwork.ozlabs.org/patch/34511/ )
>=20
> diff --git a/source3/lib/recvfile.c b/source3/lib/recvfile.c
> index ea01596..65e6f34 100644
> --- a/source3/lib/recvfile.c
> +++ b/source3/lib/recvfile.c
> @@ -182,7 +182,7 @@ ssize_t sys_recvfile(int fromfd,
>                 int nread, to_write;
> =20
>                 nread =3D splice(fromfd, NULL, pipefd[1], NULL,
> -                              MIN(count, 16384), SPLICE_F_MOVE);
> +                              MIN(count, 16384), SPLICE_F_MOVE | SPL=
ICE_F_NONBLOCK);
>                 if (nread =3D=3D -1) {
>                         if (errno =3D=3D EINTR) {
>                                 continue;
>=20
>=20


