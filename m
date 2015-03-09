From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 2/8] net/socket: sock_map_fd - call sock_release in error path
Date: Mon,  9 Mar 2015 14:19:57 -0700
Message-ID: <1425936003-24544-2-git-send-email-zenczykowski@gmail.com>
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
Received: from mail-ig0-f175.google.com ([209.85.213.175]:43667 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753585AbbCIVUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:21 -0400
Received: by igbhn18 with SMTP id hn18so25352256igb.2
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:20 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

(sock_map_fd only called from sys_socket)

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 323ebd530b88..8e282bae488d 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -393,12 +393,15 @@ static int sock_map_fd(struct socket *sock, int f=
lags)
 {
 	struct file *newfile;
 	int fd =3D get_unused_fd_flags(flags);
-	if (unlikely(fd < 0))
+	if (unlikely(fd < 0)) {
+		sock_release(sock);
 		return fd;
+	}
=20
 	newfile =3D sock_alloc_file(sock, flags, NULL);
 	if (unlikely(IS_ERR(newfile))) {
 		put_unused_fd(fd);
+		sock_release(sock);
 		return PTR_ERR(newfile);
 	}
=20
@@ -1256,16 +1259,10 @@ SYSCALL_DEFINE3(socket, int, family, int, type,=
 int, protocol)
 		goto out;
=20
 	retval =3D sock_map_fd(sock, flags & (O_CLOEXEC | O_NONBLOCK));
-	if (retval < 0)
-		goto out_release;
=20
 out:
 	/* It may be already another descriptor 8) Not kernel problem. */
 	return retval;
-
-out_release:
-	sock_release(sock);
-	return retval;
 }
=20
 /*
--=20
2.2.0.rc0.207.ga3a616c
