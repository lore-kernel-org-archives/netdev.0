From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net 2/2] soreuseport: test mixed v4/v6 sockets
Date: Tue, 12 Apr 2016 13:11:26 -0400
Message-ID: <1460481086-12982-3-git-send-email-kraigatgoog@gmail.com>
References: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34898 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965485AbcDLRLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 13:11:38 -0400
Received: by mail-qg0-f43.google.com with SMTP id f105so21438950qge.2
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 10:11:37 -0700 (PDT)
In-Reply-To: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Test to validate the behavior of SO_REUSEPORT sockets that are
created with both AF_INET and AF_INET6.  See the commit prior to this
for a description of this behavior.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 tools/testing/selftests/net/.gitignore            |   1 +
 tools/testing/selftests/net/Makefile              |   2 +-
 tools/testing/selftests/net/reuseport_dualstack.c | 208 ++++++++++++++++++++++
 3 files changed, 210 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/reuseport_dualstack.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 69bb3fc38fb2..0840684deb7d 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -3,3 +3,4 @@ psock_fanout
 psock_tpacket
 reuseport_bpf
 reuseport_bpf_cpu
+reuseport_dualstack
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index c658792d47b4..0e5340742620 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -4,7 +4,7 @@ CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf reuseport_bpf_cpu
+NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf reuseport_bpf_cpu reuseport_dualstack
 
 all: $(NET_PROGS)
 %: %.c
diff --git a/tools/testing/selftests/net/reuseport_dualstack.c b/tools/testing/selftests/net/reuseport_dualstack.c
new file mode 100644
index 000000000000..90958aaaafb9
--- /dev/null
+++ b/tools/testing/selftests/net/reuseport_dualstack.c
@@ -0,0 +1,208 @@
+/*
+ * It is possible to use SO_REUSEPORT to open multiple sockets bound to
+ * equivalent local addresses using AF_INET and AF_INET6 at the same time.  If
+ * the AF_INET6 socket has IPV6_V6ONLY set, it's clear which socket should
+ * receive a given incoming packet.  However, when it is not set, incoming v4
+ * packets should prefer the AF_INET socket(s).  This behavior was defined with
+ * the original SO_REUSEPORT implementation, but broke with
+ * e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
+ * This test creates these mixed AF_INET/AF_INET6 sockets and asserts the
+ * AF_INET preference for v4 packets.
+ */
+
+#define _GNU_SOURCE
+
+#include <arpa/inet.h>
+#include <errno.h>
+#include <error.h>
+#include <linux/in.h>
+#include <linux/unistd.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/epoll.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <unistd.h>
+
+static const int PORT = 8888;
+
+static void build_rcv_fd(int family, int proto, int *rcv_fds, int count)
+{
+	struct sockaddr_storage addr;
+	struct sockaddr_in  *addr4;
+	struct sockaddr_in6 *addr6;
+	int opt, i;
+
+	switch (family) {
+	case AF_INET:
+		addr4 = (struct sockaddr_in *)&addr;
+		addr4->sin_family = AF_INET;
+		addr4->sin_addr.s_addr = htonl(INADDR_ANY);
+		addr4->sin_port = htons(PORT);
+		break;
+	case AF_INET6:
+		addr6 = (struct sockaddr_in6 *)&addr;
+		addr6->sin6_family = AF_INET6;
+		addr6->sin6_addr = in6addr_any;
+		addr6->sin6_port = htons(PORT);
+		break;
+	default:
+		error(1, 0, "Unsupported family %d", family);
+	}
+
+	for (i = 0; i < count; ++i) {
+		rcv_fds[i] = socket(family, proto, 0);
+		if (rcv_fds[i] < 0)
+			error(1, errno, "failed to create receive socket");
+
+		opt = 1;
+		if (setsockopt(rcv_fds[i], SOL_SOCKET, SO_REUSEPORT, &opt,
+			       sizeof(opt)))
+			error(1, errno, "failed to set SO_REUSEPORT");
+
+		if (bind(rcv_fds[i], (struct sockaddr *)&addr, sizeof(addr)))
+			error(1, errno, "failed to bind receive socket");
+
+		if (proto == SOCK_STREAM && listen(rcv_fds[i], 10))
+			error(1, errno, "failed to listen on receive port");
+	}
+}
+
+static void send_from_v4(int proto)
+{
+	struct sockaddr_in  saddr, daddr;
+	int fd;
+
+	saddr.sin_family = AF_INET;
+	saddr.sin_addr.s_addr = htonl(INADDR_ANY);
+	saddr.sin_port = 0;
+
+	daddr.sin_family = AF_INET;
+	daddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	daddr.sin_port = htons(PORT);
+
+	fd = socket(AF_INET, proto, 0);
+	if (fd < 0)
+		error(1, errno, "failed to create send socket");
+
+	if (bind(fd, (struct sockaddr *)&saddr, sizeof(saddr)))
+		error(1, errno, "failed to bind send socket");
+
+	if (connect(fd, (struct sockaddr *)&daddr, sizeof(daddr)))
+		error(1, errno, "failed to connect send socket");
+
+	if (send(fd, "a", 1, 0) < 0)
+		error(1, errno, "failed to send message");
+
+	close(fd);
+}
+
+static int receive_once(int epfd, int proto)
+{
+	struct epoll_event ev;
+	int i, fd;
+	char buf[8];
+
+	i = epoll_wait(epfd, &ev, 1, -1);
+	if (i < 0)
+		error(1, errno, "epoll_wait failed");
+
+	if (proto == SOCK_STREAM) {
+		fd = accept(ev.data.fd, NULL, NULL);
+		if (fd < 0)
+			error(1, errno, "failed to accept");
+		i = recv(fd, buf, sizeof(buf), 0);
+		close(fd);
+	} else {
+		i = recv(ev.data.fd, buf, sizeof(buf), 0);
+	}
+
+	if (i < 0)
+		error(1, errno, "failed to recv");
+
+	return ev.data.fd;
+}
+
+static void test(int *rcv_fds, int count, int proto)
+{
+	struct epoll_event ev;
+	int epfd, i, test_fd;
+	uint16_t test_family;
+	socklen_t len;
+
+	epfd = epoll_create(1);
+	if (epfd < 0)
+		error(1, errno, "failed to create epoll");
+
+	ev.events = EPOLLIN;
+	for (i = 0; i < count; ++i) {
+		ev.data.fd = rcv_fds[i];
+		if (epoll_ctl(epfd, EPOLL_CTL_ADD, rcv_fds[i], &ev))
+			error(1, errno, "failed to register sock epoll");
+	}
+
+	send_from_v4(proto);
+
+	test_fd = receive_once(epfd, proto);
+	if (getsockopt(test_fd, SOL_SOCKET, SO_DOMAIN, &test_family, &len))
+		error(1, errno, "failed to read socket domain");
+	if (test_family != AF_INET)
+		error(1, 0, "expected to receive on v4 socket but got v6 (%d)",
+		      test_family);
+
+	close(epfd);
+}
+
+int main(void)
+{
+	int rcv_fds[32], i;
+
+	fprintf(stderr, "---- UDP IPv4 created before IPv6 ----\n");
+	build_rcv_fd(AF_INET, SOCK_DGRAM, rcv_fds, 5);
+	build_rcv_fd(AF_INET6, SOCK_DGRAM, &(rcv_fds[5]), 5);
+	test(rcv_fds, 10, SOCK_DGRAM);
+	for (i = 0; i < 10; ++i)
+		close(rcv_fds[i]);
+
+	fprintf(stderr, "---- UDP IPv6 created before IPv4 ----\n");
+	build_rcv_fd(AF_INET6, SOCK_DGRAM, rcv_fds, 5);
+	build_rcv_fd(AF_INET, SOCK_DGRAM, &(rcv_fds[5]), 5);
+	test(rcv_fds, 10, SOCK_DGRAM);
+	for (i = 0; i < 10; ++i)
+		close(rcv_fds[i]);
+
+	/* NOTE: UDP socket lookups traverse a different code path when there
+	 * are > 10 sockets in a group.
+	 */
+	fprintf(stderr, "---- UDP IPv4 created before IPv6 (large) ----\n");
+	build_rcv_fd(AF_INET, SOCK_DGRAM, rcv_fds, 16);
+	build_rcv_fd(AF_INET6, SOCK_DGRAM, &(rcv_fds[16]), 16);
+	test(rcv_fds, 32, SOCK_DGRAM);
+	for (i = 0; i < 32; ++i)
+		close(rcv_fds[i]);
+
+	fprintf(stderr, "---- UDP IPv6 created before IPv4 (large) ----\n");
+	build_rcv_fd(AF_INET6, SOCK_DGRAM, rcv_fds, 16);
+	build_rcv_fd(AF_INET, SOCK_DGRAM, &(rcv_fds[16]), 16);
+	test(rcv_fds, 32, SOCK_DGRAM);
+	for (i = 0; i < 32; ++i)
+		close(rcv_fds[i]);
+
+	fprintf(stderr, "---- TCP IPv4 created before IPv6 ----\n");
+	build_rcv_fd(AF_INET, SOCK_STREAM, rcv_fds, 5);
+	build_rcv_fd(AF_INET6, SOCK_STREAM, &(rcv_fds[5]), 5);
+	test(rcv_fds, 10, SOCK_STREAM);
+	for (i = 0; i < 10; ++i)
+		close(rcv_fds[i]);
+
+	fprintf(stderr, "---- TCP IPv6 created before IPv4 ----\n");
+	build_rcv_fd(AF_INET6, SOCK_STREAM, rcv_fds, 5);
+	build_rcv_fd(AF_INET, SOCK_STREAM, &(rcv_fds[5]), 5);
+	test(rcv_fds, 10, SOCK_STREAM);
+	for (i = 0; i < 10; ++i)
+		close(rcv_fds[i]);
+
+	fprintf(stderr, "SUCCESS\n");
+	return 0;
+}
-- 
2.8.0.rc3.226.g39d4020
