From: Andries.Brouwer@cwi.nl
Subject: [patch] posix compliance for send(to)
Date: Sat, 25 Oct 2003 23:44:19 +0200 (MEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <UTC200310252144.h9PLiJ502790.aeb@smtp.cwi.nl>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

POSIX 1003.1-2001, 2003 edition
(see http://www.opengroup.org/onlinepubs/007904975/toc.htm)
says about send():

  The send() function shall send a message only
  when the socket is connected

and gives the error returns

[ENOTCONN]
  The socket is not connected or otherwise has not had the peer
  pre-specified.
[EPIPE]
  The socket is shut down for writing, or the socket is connection-mode
  and is no longer connected. In the latter case, and if the socket is of
  type SOCK_STREAM, the SIGPIPE signal is generated to the calling thread.

However, currently (2.6.0-test6) I see EPIPE and SIGPIPE
for a send() on a fresh, non-connected socket.

I suppose the below patch fixes this, but have not checked
details of the state machine.

Andries

diff -u --recursive --new-file -X /linux/dontdiff a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c	Mon Jun 23 04:44:14 2003
+++ b/net/ipv4/tcp.c	Sat Oct 25 22:46:44 2003
@@ -1044,6 +1044,10 @@
 	flags = msg->msg_flags;
 	timeo = sock_sndtimeo(sk, flags & MSG_DONTWAIT);
 
+	err = -ENOTCONN;
+	if (sk->sk_state == TCP_CLOSE && !sock_flag(sk, SOCK_DONE))
+		goto out_err;
+
 	/* Wait for a connection to finish. */
 	if ((1 << sk->sk_state) & ~(TCPF_ESTABLISHED | TCPF_CLOSE_WAIT))
 		if ((err = wait_for_tcp_connect(sk, flags, &timeo)) != 0)
