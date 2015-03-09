From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH 3/8] net/socket: sock_map_fd - reverse allocation order
Date: Mon,  9 Mar 2015 14:19:58 -0700
Message-ID: <1425936003-24544-3-git-send-email-zenczykowski@gmail.com>
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
Received: from mail-ie0-f172.google.com ([209.85.223.172]:44402 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712AbbCIVUW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 17:20:22 -0400
Received: by iery20 with SMTP id y20so13985665ier.11
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2015 14:20:22 -0700 (PDT)
In-Reply-To: <1425936003-24544-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/socket.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/socket.c b/net/socket.c
index 8e282bae488d..a62c5cda5720 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -392,19 +392,20 @@ EXPORT_SYMBOL(sock_alloc_file);
 static int sock_map_fd(struct socket *sock, int flags)
 {
 	struct file *newfile;
-	int fd =3D get_unused_fd_flags(flags);
-	if (unlikely(fd < 0)) {
-		sock_release(sock);
-		return fd;
-	}
+	int fd;
=20
 	newfile =3D sock_alloc_file(sock, flags, NULL);
 	if (unlikely(IS_ERR(newfile))) {
-		put_unused_fd(fd);
 		sock_release(sock);
 		return PTR_ERR(newfile);
 	}
=20
+	fd =3D get_unused_fd_flags(flags);
+	if (unlikely(fd < 0)) {
+		fput(newfile);
+		return fd;
+	}
+
 	fd_install(fd, newfile);
 	return fd;
 }
--=20
2.2.0.rc0.207.ga3a616c
