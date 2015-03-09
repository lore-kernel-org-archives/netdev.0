From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 8/8] net/socket: sys_accept4 - use faster fd allocation api
Date: Mon,  9 Mar 2015 14:20:03 -0700
Message-ID: <1425936003-24544-8-git-send-email-zenczykowski@gmail.com>
References: <CAHo-OozBxw=h--dSjhobVfepC_10=H5_9DvXEvrhtnrFvc5tdw@mail.gmail.com>
 <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:40746 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753846AbbCIVUb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:31 -0400
Received: by igal13 with SMTP id l13so24938793iga.5
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:30 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 10f5daf0e625..f947c98831b2 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1445,7 +1445,7 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockaddr=
 __user *, upeer_sockaddr,
 {
 	struct socket *sock, *newsock;
 	struct file *newfile;
-	int err, len, newfd, fput_needed;
+	int err, len, fput_needed;
 	struct sockaddr_storage address;
=20
 	if (flags & ~(SOCK_CLOEXEC | SOCK_NONBLOCK))
@@ -1499,16 +1499,11 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockad=
dr __user *, upeer_sockaddr,
 			goto out_fput;
 	}
=20
-	newfd =3D get_unused_fd_flags(flags);
-	if (unlikely(newfd < 0)) {
-		err =3D newfd;
-		goto out_fput;
-	}
-
 	/* File flags are not inherited via accept() unlike another OSes. */
=20
-	fd_install(newfd, newfile);
-	err =3D newfd;
+	err =3D get_unused_fd_and_install_flags(flags, newfile);
+	if (unlikely(err < 0))
+		goto out_fput;
=20
 out_put:
 	fput_light(sock->file, fput_needed);
--=20
2.2.0.rc0.207.ga3a616c
