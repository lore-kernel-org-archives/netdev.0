From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2] af_unix: optimize unix_dgram_poll()
Date: Sun, 31 Oct 2010 16:38:25 +0100
Message-ID: <1288539505.2660.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Davide Libenzi <davidel@xmailserver.org>,
	Alban Crequy <alban.crequy@collabora.co.uk>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52792 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755975Ab0JaPib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Oct 2010 11:38:31 -0400
Received: by wyf28 with SMTP id 28so4697125wyf.19
        for <netdev@vger.kernel.org>; Sun, 31 Oct 2010 08:38:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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

real    0m0.044s
user    0m0.000s
sys     0m0.040s

Suggested-by: Davide Libenzi <davidel@xmailserver.org>
Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
Acked-by: Davide Libenzi <davidel@xmailserver.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/unix/af_unix.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7375131..7067c5d 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -2089,6 +2089,10 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 			return mask;
 	}
 
+	/* No write status requested, avoid expensive OUT tests. */
+	if (wait && !(wait->key & (POLLWRBAND | POLLWRNORM | POLLOUT)))
+		return mask;
+
 	writable = unix_writable(sk);
 	other = unix_peer_get(sk);
 	if (other) {


