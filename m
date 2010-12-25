From: Jan Engelhardt <jengelh@medozas.de>
Subject: [patch] net/unix: do not forget to autobind in standard case
Date: Sat, 25 Dec 2010 01:08:30 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1012250107330.22521@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>
To: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:44696 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752910Ab0LYAIc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Dec 2010 19:08:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

parent 67514fc40bbec857018cbc689d440282b75551db (v2.6.37-rc1-229-g67514fc)
commit 973bdc63c6aba703dd7b62a6ec7ae4bab7847731
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Dec 25 00:50:59 2010 +0100

net/unix: do not forget to autobind in standard case

A program using recvmsg on an AF_LOCAL datagram socket does not
receive the peer's address when the remote has not issued a bind. This
makes it impossible to send messages back. (But the same _does_ work
in IP.) The cause for this is because autobinding was only done when
credential passing was requested.

The shown test program outputs:

getsockname gives 16
Received 2 bytes, and sk2_size is 16. Text: Hi
reply text: World

getsockname gives 2
Received 2 bytes, and sk2_size is 0. Text: Hi
sendto fd1: Transport endpoint is not connected
Aborted

getsockname gives 8
Received 2 bytes, and sk2_size is 8. Text: Hi
reply text: World

---8<---
//#define chosen_AF AF_INET

union sockaddr_all {
	struct sockaddr_in in;
	struct sockaddr_un un;
};

static inline size_t sock_size(unsigned int af)
{
	if (af == AF_INET)
		return sizeof(struct sockaddr_in);
	if (af == AF_LOCAL)
		return sizeof(struct sockaddr_un);
	return 0;
}

int main(void)
{
	union sockaddr_all sk1;
	union sockaddr_all sk2;
	int fd1, fd2;
	socklen_t sk2_size;
	char buf[64];
	ssize_t ret;

	fd1 = socket(chosen_AF, SOCK_DGRAM, 0);
	if (fd1 < 0) {
		perror("socket fd1");
		abort();
	}
	memset(&sk1, 0, sizeof(sk1));
	if (chosen_AF == AF_INET) {
		sk1.in.sin_family = chosen_AF;
		sk1.in.sin_port = htons(1234);
	} else if (chosen_AF == AF_LOCAL) {
		sk1.un.sun_family = chosen_AF;
		snprintf(sk1.un.sun_path, sizeof(sk1.un.sun_path), "/tmp/sk1");
		unlink(sk1.un.sun_path);
	}
	if (bind(fd1, (void *)&sk1, sock_size(chosen_AF))) {
		perror("bind fd1");
		abort();
	}

	fd2 = socket(chosen_AF, SOCK_DGRAM, 0);
	if (fd2 < 0) {
		perror("socket");
		abort();
	}
	/* Cause implicit bind */
	if (sendto(fd2, "Hi", 2, 0, (void *)&sk1, sock_size(chosen_AF)) < 0) {
		perror("sendto fd2");
		abort();
	}
	/* check if socket has been bound */
	sk2_size = sock_size(chosen_AF);
	memset(&sk2, 0, sizeof(sk2));
	if (getsockname(fd2, (void *)&sk2, &sk2_size) < 0) {
		perror("getsockname fd2");
		abort();
	}
	printf("getsockname gives %d\n", (int)sk2_size);

	/* But with recvfrom... */
	memset(&sk2, 0, sizeof(sk2));
	memset(buf, 0, sizeof(buf));
	sk2_size = sock_size(chosen_AF);
	ret = recvfrom(fd1, buf, sizeof(buf), 0, (void *)&sk2, &sk2_size);
	if (ret < 0) {
		perror("recvfrom fd1");
		abort();
	}
	printf("Received %zd bytes, and sk2_size is %d. Text: %.*s\n",
		ret, (int)sk2_size, (int)ret, buf);
	ret = sendto(fd1, "World", 5, 0, (const void *)&sk2, sk2_size);
	if (ret < 0) {
		perror("sendto fd1");
		abort();
	}

	ret = recvfrom(fd2, buf, sizeof(buf), 0, NULL, 0);
	if (ret < 0) {
		perror("recvfrom fd2");
		abort();
	}
	printf("reply text: %.*s\n", (int)ret, buf);
	return 0;
}
--->8---

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/unix/af_unix.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 7ff31c6..945797c 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -964,8 +964,8 @@ static int unix_dgram_connect(struct socket *sock, struct sockaddr *addr,
 			goto out;
 		alen = err;
 
-		if (test_bit(SOCK_PASSCRED, &sock->flags) &&
-		    !unix_sk(sk)->addr && (err = unix_autobind(sock)) != 0)
+		if (unix_sk(sk)->addr == NULL &&
+		    (err = unix_autobind(sock)) != 0)
 			goto out;
 
 restart:
@@ -1063,8 +1063,7 @@ static int unix_stream_connect(struct socket *sock, struct sockaddr *uaddr,
 		goto out;
 	addr_len = err;
 
-	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
-	    (err = unix_autobind(sock)) != 0)
+	if (u->addr == NULL && (err = unix_autobind(sock)) != 0)
 		goto out;
 
 	timeo = sock_sndtimeo(sk, flags & O_NONBLOCK);
@@ -1419,8 +1418,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 			goto out;
 	}
 
-	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr
-	    && (err = unix_autobind(sock)) != 0)
+	if (u->addr == NULL && (err = unix_autobind(sock)) != 0)
 		goto out;
 
 	err = -EMSGSIZE;
-- 
# Created with git-export-patch

