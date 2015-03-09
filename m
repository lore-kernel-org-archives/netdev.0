From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 4/8] net/socket: sys_accept4 - reverse allocation order
Date: Mon,  9 Mar 2015 14:19:59 -0700
Message-ID: <1425936003-24544-4-git-send-email-zenczykowski@gmail.com>
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
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38589 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbbCIVUY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:24 -0400
Received: by igbhl2 with SMTP id hl2so24956008igb.3
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:24 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 24 +++++++++++-------------
 1 file changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index a62c5cda5720..87fd36939778 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -1473,38 +1473,37 @@ SYSCALL_DEFINE4(accept4, int, fd, struct sockad=
dr __user *, upeer_sockaddr,
 	 */
 	__module_get(newsock->ops->owner);
=20
-	newfd =3D get_unused_fd_flags(flags);
-	if (unlikely(newfd < 0)) {
-		err =3D newfd;
-		sock_release(newsock);
-		goto out_put;
-	}
 	newfile =3D sock_alloc_file(newsock, flags, sock->sk->sk_prot_creator=
->name);
 	if (unlikely(IS_ERR(newfile))) {
 		err =3D PTR_ERR(newfile);
-		put_unused_fd(newfd);
 		sock_release(newsock);
 		goto out_put;
 	}
=20
 	err =3D security_socket_accept(sock, newsock);
 	if (err)
-		goto out_fd;
+		goto out_fput;
=20
 	err =3D sock->ops->accept(sock, newsock, sock->file->f_flags);
 	if (err < 0)
-		goto out_fd;
+		goto out_fput;
=20
 	if (upeer_sockaddr) {
 		if (newsock->ops->getname(newsock, (struct sockaddr *)&address,
 					  &len, 2) < 0) {
 			err =3D -ECONNABORTED;
-			goto out_fd;
+			goto out_fput;
 		}
 		err =3D move_addr_to_user(&address,
 					len, upeer_sockaddr, upeer_addrlen);
 		if (err < 0)
-			goto out_fd;
+			goto out_fput;
+	}
+
+	newfd =3D get_unused_fd_flags(flags);
+	if (unlikely(newfd < 0)) {
+		err =3D newfd;
+		goto out_fput;
 	}
=20
 	/* File flags are not inherited via accept() unlike another OSes. */
@@ -1516,9 +1515,8 @@ out_put:
 	fput_light(sock->file, fput_needed);
 out:
 	return err;
-out_fd:
+out_fput:
 	fput(newfile);
-	put_unused_fd(newfd);
 	goto out_put;
 }
=20
--=20
2.2.0.rc0.207.ga3a616c
