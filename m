From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: allow splice() to build full TSO packets
Date: Thu, 05 Apr 2012 15:05:35 +0200
Message-ID: <1333631135.18626.606.camel@edumazet-glaptop>
References: <1333481821.18626.322.camel@edumazet-glaptop>
	 <20120403.172126.672236532461758456.davem@davemloft.net>
	 <1333488689.18626.331.camel@edumazet-glaptop>
	 <20120403.173614.962252876842659412.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, hkchu@google.com, maze@google.com,
	maheshb@google.com, ilpo.jarvinen@helsinki.fi, nanditad@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63662 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840Ab2DENFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 09:05:41 -0400
Received: by wgbdr13 with SMTP id dr13so1300396wgb.1
        for <netdev@vger.kernel.org>; Thu, 05 Apr 2012 06:05:39 -0700 (PDT)
In-Reply-To: <20120403.173614.962252876842659412.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 17:36 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 03 Apr 2012 23:31:29 +0200
>=20
> > The code in tcp_sendmsg() and do_tcp_sendpages() is similar (actual=
ly
> > probably copy/pasted) but the thing is tcp_sendmsg() is called once=
 per
> > sendmsg() call (and the push logic is OK at the end of it), while a
> > single splice() system call can call do_tcp_sendpages() 16 times (o=
r
> > even more if pipe buffer was extended by fcntl(F_SETPIPE_SZ))
>=20
> Ok, so this means that in essence the tcp_mark_push should also only
> be done in the final sendpage call.
>=20
> And since I'm wholly convinced that the URG stuff is a complete
> "don't care" for this path, I'm convinced your patch is the right
> thing to do.
>=20
> Applied to 'net' and queued up for -stable, thanks Eric.

Hmm, thinking again about this, I did more tests and it appears we need
to differentiate the SPLICE_F_MORE flag (user request) and the internal
marker provided by splice logic (handling a batch of pages)

A program doing splice(... SPLICE_F_MORE) should really call tcp_push()
at the end of its work.

Thanks

[PATCH] tcp: tcp_sendpages() should call tcp_push() once

commit 2f533844242 (tcp: allow splice() to build full TSO packets) adde=
d
a regression for splice() calls using SPLICE_F_MORE.

We need to call tcp_flush() at the end of the last page processed in
tcp_sendpages(), or else transmits can be deferred and future sends
stall.

Add a new internal flag, MSG_SENDPAGE_NOTLAST, acting like MSG_MORE, bu=
t
with different semantic.

=46or all sendpage() providers, its a transparent change. Only
sock_sendpage() and tcp_sendpages() can differentiate the two different
flags provided by pipe_to_sendpage()

Reported-by: Tom Herbert <therbert@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
Cc: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail>com>
---
 fs/splice.c            |    5 ++++-
 include/linux/socket.h |    2 +-
 net/ipv4/tcp.c         |    2 +-
 net/socket.c           |    6 +++---
 4 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/fs/splice.c b/fs/splice.c
index 5f883de..f847684 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -30,6 +30,7 @@
 #include <linux/uio.h>
 #include <linux/security.h>
 #include <linux/gfp.h>
+#include <linux/socket.h>
=20
 /*
  * Attempt to steal a page from a pipe buffer. This should perhaps go =
into
@@ -690,7 +691,9 @@ static int pipe_to_sendpage(struct pipe_inode_info =
*pipe,
 	if (!likely(file->f_op && file->f_op->sendpage))
 		return -EINVAL;
=20
-	more =3D (sd->flags & SPLICE_F_MORE) || sd->len < sd->total_len;
+	more =3D (sd->flags & SPLICE_F_MORE) ? MSG_MORE : 0;
+	if (sd->len < sd->total_len)
+		more |=3D MSG_SENDPAGE_NOTLAST;
 	return file->f_op->sendpage(file, buf->page, buf->offset,
 				    sd->len, &pos, more);
 }
diff --git a/include/linux/socket.h b/include/linux/socket.h
index da2d3e2..b84bbd4 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -265,7 +265,7 @@ struct ucred {
 #define MSG_NOSIGNAL	0x4000	/* Do not generate SIGPIPE */
 #define MSG_MORE	0x8000	/* Sender will send more */
 #define MSG_WAITFORONE	0x10000	/* recvmmsg(): block until 1+ packets a=
vail */
-
+#define MSG_SENDPAGE_NOTLAST 0x20000 /* sendpage() internal : not the =
last page */
 #define MSG_EOF         MSG_FIN
=20
 #define MSG_CMSG_CLOEXEC 0x40000000	/* Set close_on_exit for file
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2ff6f45..5d54ed3 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -860,7 +860,7 @@ wait_for_memory:
 	}
=20
 out:
-	if (copied && !(flags & MSG_MORE))
+	if (copied && !(flags & MSG_SENDPAGE_NOTLAST))
 		tcp_push(sk, flags, mss_now, tp->nonagle);
 	return copied;
=20
diff --git a/net/socket.c b/net/socket.c
index 484cc69..851edcd 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -811,9 +811,9 @@ static ssize_t sock_sendpage(struct file *file, str=
uct page *page,
=20
 	sock =3D file->private_data;
=20
-	flags =3D !(file->f_flags & O_NONBLOCK) ? 0 : MSG_DONTWAIT;
-	if (more)
-		flags |=3D MSG_MORE;
+	flags =3D (file->f_flags & O_NONBLOCK) ? MSG_DONTWAIT : 0;
+	/* more is a combination of MSG_MORE and MSG_SENDPAGE_NOTLAST */
+	flags |=3D more;
=20
 	return kernel_sendpage(sock, page, offset, size, flags);
 }
