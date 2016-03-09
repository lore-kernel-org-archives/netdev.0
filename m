From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] SOCK_SEQPACKET socketpair must get SIGPIPE in AF_UNIX if one end is closed
Date: Wed,  9 Mar 2016 15:10:23 +0100
Message-ID: <1457532623-125301-1-git-send-email-glider@google.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: edumazet@google.com, rweikusat@mobileactivedefense.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34316 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbcCIOK3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 09:10:29 -0500
Received: by mail-wm0-f52.google.com with SMTP id p65so194003664wmp.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 06:10:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to IEEE Std 1003.1, 2013, sending data to a SOCK_SEQPACKET
socketpair with MSG_NOSIGNAL flag set must result in a SIGPIPE if the
socket is no longer connected.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
I used the following program to check the kernel behavior:

/*****************/
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

void PipeHandler(int sig) {
  fprintf(stderr, "Killed by SIGPIPE\n");
  _exit(1);
}

int main(int argc, char *argv[]) {
  if (argc < 2) return 0;
  struct sigaction act;
  act.sa_handler = PipeHandler;
  sigaction(SIGPIPE, &act, NULL);
  int fds[2];
  if (strcmp(argv[1], "seqpacket") == 0) {
    if (socketpair(AF_UNIX, SOCK_SEQPACKET, 0, fds) == -1) return -1;
  } else {
    if (strcmp(argv[1], "stream") == 0) {
      if (socketpair(AF_UNIX, SOCK_STREAM, 0, fds) == -1) return -1;
    } else {
      return -1;
    }
  }
  int flags = 0;
  if ((argc > 2) && (strcmp(argv[2], "nosignal") == 0))
    flags = MSG_NOSIGNAL;

  struct msghdr msg;
  memset(&msg, 0, sizeof(msg));
  close(fds[0]);
  const ssize_t r = sendmsg(fds[1], &msg, flags);
  if (r == -1) perror("sendmsg");
  return 0;
}
/*****************/

Without the below patch the behavior is as follows:

$ ./sock seqpacket
sendmsg: Broken pipe
$ ./sock stream
Killed by SIGPIPE
$ ./sock seqpacket nosignal
sendmsg: Broken pipe
$ ./sock stream nosignal
sendmsg: Broken pipe

The behavior of the patched kernel complies with POSIX:

$  ./sock seqpacket
Killed by SIGPIPE
$ ./sock stream
Killed by SIGPIPE
$ ./sock seqpacket nosignal
sendmsg: Broken pipe
$ ./sock stream nosignal
sendmsg: Broken pipe

---
 net/unix/af_unix.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 8fbe6d7..ba34c73 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1645,6 +1645,7 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 	struct sock *other = NULL;
 	int namelen = 0; /* fake GCC */
 	int err;
+	bool send_sigpipe = false;
 	unsigned int hash;
 	struct sk_buff *skb;
 	long timeo;
@@ -1675,6 +1676,12 @@ static int unix_dgram_sendmsg(struct socket *sock, struct msghdr *msg,
 			goto out;
 	}
 
+	if (sk->sk_shutdown & SEND_SHUTDOWN && sock->type == SOCK_SEQPACKET) {
+		send_sigpipe = true;
+		err = -EPIPE;
+		goto out;
+	}
+
 	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
 	    && (err = unix_autobind(sock)) != 0)
 		goto out;
@@ -1769,8 +1776,11 @@ restart_locked:
 	}
 
 	err = -EPIPE;
-	if (other->sk_shutdown & RCV_SHUTDOWN)
+	if (other->sk_shutdown & RCV_SHUTDOWN) {
+		if (sock->type == SOCK_SEQPACKET)
+			send_sigpipe = true;
 		goto out_unlock;
+	}
 
 	if (sk->sk_type != SOCK_SEQPACKET) {
 		err = security_unix_may_send(sk->sk_socket, other->sk_socket);
@@ -1837,6 +1847,8 @@ out:
 	if (other)
 		sock_put(other);
 	scm_destroy(&scm);
+	if (send_sigpipe && !(msg->msg_flags & MSG_NOSIGNAL))
+		send_sig(SIGPIPE, current, 0);
 	return err;
 }
 
-- 
2.7.0.rc3.207.g0ac5344
