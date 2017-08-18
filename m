From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: [PATCH RESEND 2/2] selftests/net: add test to verify datagram socket timeout
Date: Fri, 18 Aug 2017 18:44:10 +0000
Message-ID: <1503081850-10671-3-git-send-email-vallish@amazon.com>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eduval@amazon.com>, <anchalag@amazon.com>, <vallish@amazon.com>
To: <davem@davemloft.net>, <shuah@kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503081850-10671-1-git-send-email-vallish@amazon.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

AF_UNIX and AF_INET datagram sockets use high resolution timer to time
SO_RCVTIMEO value used with setsockopt(2). This test checks for the
accuracy of kernel notifying these sockets timeout to application. Test
program has code to check AF_UNIX socket, however the kernel function used
to timeout AF_INET socket is the same kernel function used by AF_UNIX as
well which is __skb_wait_for_more_packets().

Reported-by: Manjula Peiris <thelgep@amazon.com>
Reviewed-by: Eduardo Valentin <eduval@amazon.com>
Reviewed-by: Anchal Agarwal <anchalag@amazon.com>
Signed-off-by: Vallish Vaidyeshwara <vallish@amazon.com>
---
 tools/testing/selftests/net/Makefile               |   3 +-
 .../testing/selftests/net/datagram_sock_timeout.c  | 119 +++++++++++++++++++++
 .../selftests/net/run_datagram_sock_timeout.sh     |  12 +++
 3 files changed, 133 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/datagram_sock_timeout.c
 create mode 100755 tools/testing/selftests/net/run_datagram_sock_timeout.sh

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index f6c9dbf..eb5a8c7 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -3,11 +3,12 @@
 CFLAGS =  -Wall -Wl,--no-as-needed -O2 -g
 CFLAGS += -I../../../../usr/include/
 
-TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh
+TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh run_datagram_sock_timeout.sh
 TEST_GEN_FILES =  socket
 TEST_GEN_FILES += psock_fanout psock_tpacket
 TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
 TEST_GEN_FILES += reuseport_dualstack
+TEST_GEN_FILES += datagram_sock_timeout
 
 include ../lib.mk
 
diff --git a/tools/testing/selftests/net/datagram_sock_timeout.c b/tools/testing/selftests/net/datagram_sock_timeout.c
new file mode 100644
index 0000000..2549be5
--- /dev/null
+++ b/tools/testing/selftests/net/datagram_sock_timeout.c
@@ -0,0 +1,119 @@
+/*
+ * Copyright 2017 Amazon.com, Inc.
+ * Author: Manjula Peiris <thelgep@amazon.com>
+ *         Vallish Vaidyeshwara <vallish@amazon.com>
+ *
+ * selftests/net: test to verify datagram socket timeout
+ *
+ * AF_UNIX and AF_INET datagram sockets use high resolution timer to time
+ * SO_RCVTIMEO value used with setsockopt(2). This test checks for the accuracy
+ * of kernel notifying these sockets timeout to application. Test program has
+ * code to check AF_UNIX socket, however the kernel function used to timeout
+ * AF_INET socket is the same kernel function used by AF_UNIX as well which is
+ * __skb_wait_for_more_packets().
+ *
+ * License (GPLv2):
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program.
+ */
+
+#include <stdlib.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include <signal.h>
+#include <stdio.h>
+#include <fcntl.h>
+#include <err.h>
+#include <errno.h>
+#include <sys/un.h>
+#include <time.h>
+#include <assert.h>
+
+#define BUF_SIZE 128
+#define KB 1024
+#define NUM_FD 2
+
+static int set_socket_timeout(int sockfd, unsigned int ms)
+{
+	int ret;
+	struct timeval timeout;
+	socklen_t cb = sizeof(timeout);
+
+	timeout.tv_sec = ms / 1000;
+	timeout.tv_usec = (ms % 1000) * 1000;
+	ret = setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, cb);
+	return ret;
+}
+
+int main(int argc, char **argv)
+{
+	char err[BUF_SIZE];
+	int ret;
+	int fds[NUM_FD];
+	struct msghdr message;
+	char buffer[KB];
+	struct sockaddr_storage src_addr;
+	struct iovec iov[1];
+	time_t start, end;
+	unsigned int timeout;
+
+	iov[0].iov_base = buffer;
+	iov[0].iov_len = sizeof(buffer);
+	message.msg_name = &src_addr;
+	message.msg_namelen = sizeof(src_addr);
+	message.msg_iov = iov;
+	message.msg_iovlen = 1;
+	message.msg_control = 0;
+	message.msg_controllen = 0;
+
+	if (argc != 2) {
+		fprintf(stderr,
+			"datagram_sock_timeout failed: no timeout specified\n");
+		return -1;
+	}
+	timeout = (unsigned int)(atoi(argv[1]));
+
+	if (socketpair(AF_UNIX, SOCK_DGRAM, 0, fds) != 0) {
+		strerror_r(errno, err, BUF_SIZE);
+		fprintf(stderr, "socketpair() call failed with %s\n", err);
+		return -1;
+	}
+
+	if (set_socket_timeout(fds[0], timeout) != 0) {
+		strerror_r(errno, err, BUF_SIZE);
+		fprintf(stderr, "setsockopt() call failed with %s\n", err);
+		return -1;
+	}
+
+	start = time(NULL);
+	ret = (int)recvmsg(fds[0], &message, 0);
+	end = time(NULL);
+	if (!(ret == -1 && errno == 11)) {
+		fprintf(stderr,
+			"datagram_sock_timeout failed: test was interrupted\n");
+		return -1;
+	}
+
+	if (((int)(end - start)) != (timeout / 1000)) {
+		fprintf(stderr,
+			"datagram_sock_timeout failed: took %.2f seconds\n",
+			(double)(end - start));
+		return -1;
+	}
+
+	close(fds[0]);
+	close(fds[1]);
+
+	fprintf(stderr, "datagram_sock_timeout passed\n");
+	return 0;
+}
diff --git a/tools/testing/selftests/net/run_datagram_sock_timeout.sh b/tools/testing/selftests/net/run_datagram_sock_timeout.sh
new file mode 100755
index 0000000..d5f4f82
--- /dev/null
+++ b/tools/testing/selftests/net/run_datagram_sock_timeout.sh
@@ -0,0 +1,12 @@
+#!/bin/sh
+# Runs datagram socket timeout test
+
+echo "--------------------"
+echo "running run_datagram_sock_timeout test"
+echo "--------------------"
+./datagram_sock_timeout 180000
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
-- 
2.7.3.AMZN
