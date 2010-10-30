From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_unix: optimize unix_dgram_poll()
Date: Sat, 30 Oct 2010 11:53:40 +0200
Message-ID: <1288432420.2680.933.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1010291306390.8517@davide-lnx1>
	 <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alban Crequy <alban.crequy@collabora.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48740 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967Ab0J3Jxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 05:53:47 -0400
In-Reply-To: <alpine.DEB.2.00.1010291339180.8517@davide-lnx1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 13:46 -0700, Davide Libenzi a =C3=A9=
crit :

> Also, why not using the existing wait->key instead of adding a poll2(=
)?

Indeed, if wait is not null, we have in wait->key the interest of
poller. If a particular poll() function is expensive, it can test these
bits.

Thanks !

Note: I chose the 'goto skip_write' to make this patch really obvious.

[PATCH] af_unix: optimize unix_dgram_poll()

unix_dgram_poll() is pretty expensive to check POLLOUT status, because
it has to lock the socket to get its peer, take a reference on the peer
to check its receive queue status, and queue another poll_wait on
peer_wait. This all can be avoided if the process calling
unix_dgram_poll() is not interested in POLLOUT status. It makes
unix_dgram_recvmsg() faster by not queueing irrelevant pollers in
peer_wait.

On a test program provided by Alan Crequy :

Before:

real    0m0.211s
user    0m0.000s
sys     0m0.208s

After:

real	0m0.044s
user	0m0.000s
sys	0m0.040s

Suggested-by: Davide Libenzi <davidel@xmailserver.org>
Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/unix/af_unix.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3c95304..dcb84fe 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2090,6 +2090,9 @@ static unsigned int unix_dgram_poll(struct file *=
file, struct socket *sock,
 			return mask;
 	}
=20
+	if (wait && !(wait->key & (POLLWRBAND | POLLWRNORM | POLLOUT)))
+		goto skip_write;
+
 	/* writable? */
 	writable =3D unix_writable(sk);
 	if (writable) {
@@ -2111,6 +2114,7 @@ static unsigned int unix_dgram_poll(struct file *=
file, struct socket *sock,
 	else
 		set_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
=20
+skip_write:
 	return mask;
 }
=20



