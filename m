From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Splice status
Date: Mon, 05 Jul 2010 14:50:54 +0200
Message-ID: <1278334254.2877.158.camel@edumazet-laptop>
References: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B63A@IL-MB01.marvell.com>
	 <AANLkTimbVY2xhIiYXFvphajuZyn8_PJ0gOqf8VfW-NsM@mail.gmail.com>
	 <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ofer Heifetz <oferh@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:55131 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756464Ab0GEMu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 08:50:58 -0400
Received: by fxm14 with SMTP id 14so3621496fxm.19
        for <netdev@vger.kernel.org>; Mon, 05 Jul 2010 05:50:57 -0700 (PDT)
In-Reply-To: <EE71107DF0D1F24FA2D95041E64AB9E8ED2541B66E@IL-MB01.marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 05 juillet 2010 =C3=A0 13:52 +0300, Ofer Heifetz a =C3=A9crit =
:
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


