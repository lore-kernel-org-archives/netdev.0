From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Add socket() system call self test.
Date: Tue, 19 Mar 2013 14:52:58 -0400 (EDT)
Message-ID: <20130319.145258.1891905092469394685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, linux-wireless@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755440Ab3CSSxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 14:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

As mentioned during the netfilter workshop, we will be adding
all sorts of networking tests now that 3.9.x has a selftest
framework in place.

The first test I'm adding to net-next does some very simple
testing of the socket() system call.

Feel free to send patches for more tests, making the run
script more powerful (perhaps by taking a whitespace
seperated list of tests to run on the command line), and
adding more checks to the socket.c test.

Thanks.

 tools/testing/selftests/Makefile                   |  1 +
 tools/testing/selftests/net-socket/Makefile        | 16 ++++
 .../testing/selftests/net-socket/run_netsocktests  | 12 +++
 tools/testing/selftests/net-socket/socket.c        | 92 ++++++++++++++++++++++
 4 files changed, 121 insertions(+)
 create mode 100644 tools/testing/selftests/net-socket/Makefile
 create mode 100644 tools/testing/selftests/net-socket/run_netsocktests
 create mode 100644 tools/testing/selftests/net-socket/socket.c

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index 3cc0ad7..7c6280f 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -5,6 +5,7 @@ TARGETS += vm
 TARGETS += cpu-hotplug
 TARGETS += memory-hotplug
 TARGETS += efivarfs
+TARGETS += net-socket
 
 all:
 	for TARGET in $(TARGETS); do \
diff --git a/tools/testing/selftests/net-socket/Makefile b/tools/testing/selftests/net-socket/Makefile
new file mode 100644
index 0000000..f27ee10
--- /dev/null
+++ b/tools/testing/selftests/net-socket/Makefile
@@ -0,0 +1,16 @@
+# Makefile for net-socket selftests
+
+CC = $(CROSS_COMPILE)gcc
+CFLAGS = -Wall
+
+NET_SOCK_PROGS = socket
+
+all: $(NET_SOCK_PROGS)
+%: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+run_tests: all
+	@/bin/sh ./run_netsocktests || echo "vmtests: [FAIL]"
+
+clean:
+	$(RM) $(NET_SOCK_PROGS)
diff --git a/tools/testing/selftests/net-socket/run_netsocktests b/tools/testing/selftests/net-socket/run_netsocktests
new file mode 100644
index 0000000..c09a682
--- /dev/null
+++ b/tools/testing/selftests/net-socket/run_netsocktests
@@ -0,0 +1,12 @@
+#!/bin/bash
+
+echo "--------------------"
+echo "running socket test"
+echo "--------------------"
+./socket
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+
diff --git a/tools/testing/selftests/net-socket/socket.c b/tools/testing/selftests/net-socket/socket.c
new file mode 100644
index 0000000..0f227f2
--- /dev/null
+++ b/tools/testing/selftests/net-socket/socket.c
@@ -0,0 +1,92 @@
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+
+struct socket_testcase {
+	int	domain;
+	int	type;
+	int	protocol;
+
+	/* 0    = valid file descriptor
+	 * -foo = error foo
+	 */
+	int	expect;
+
+	/* If non-zero, accept EAFNOSUPPORT to handle the case
+	 * of the protocol not being configured into the kernel.
+	 */
+	int	nosupport_ok;
+};
+
+static struct socket_testcase tests[] = {
+	{ AF_MAX,  0,           0,           -EAFNOSUPPORT,    0 },
+	{ AF_INET, SOCK_STREAM, IPPROTO_TCP, 0,                1  },
+	{ AF_INET, SOCK_DGRAM,  IPPROTO_TCP, -EPROTONOSUPPORT, 1  },
+	{ AF_INET, SOCK_DGRAM,  IPPROTO_UDP, 0,                1  },
+	{ AF_INET, SOCK_STREAM, IPPROTO_UDP, -EPROTONOSUPPORT, 1  },
+};
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+#define ERR_STRING_SZ	64
+
+static int run_tests(void)
+{
+	char err_string1[ERR_STRING_SZ];
+	char err_string2[ERR_STRING_SZ];
+	int i, err;
+
+	err = 0;
+	for (i = 0; i < ARRAY_SIZE(tests); i++) {
+		struct socket_testcase *s = &tests[i];
+		int fd;
+
+		fd = socket(s->domain, s->type, s->protocol);
+		if (fd < 0) {
+			if (s->nosupport_ok &&
+			    errno == EAFNOSUPPORT)
+				continue;
+
+			if (s->expect < 0 &&
+			    errno == -s->expect)
+				continue;
+
+			strerror_r(-s->expect, err_string1, ERR_STRING_SZ);
+			strerror_r(errno, err_string2, ERR_STRING_SZ);
+
+			fprintf(stderr, "socket(%d, %d, %d) expected "
+				"err (%s) got (%s)\n",
+				s->domain, s->type, s->protocol,
+				err_string1, err_string2);
+
+			err = -1;
+			break;
+		} else {
+			close(fd);
+
+			if (s->expect < 0) {
+				strerror_r(errno, err_string1, ERR_STRING_SZ);
+
+				fprintf(stderr, "socket(%d, %d, %d) expected "
+					"success got err (%s)\n",
+					s->domain, s->type, s->protocol,
+					err_string1);
+
+				err = -1;
+				break;
+			}
+		}
+	}
+
+	return err;
+}
+
+int main(void)
+{
+	int err = run_tests();
+
+	return err;
+}
-- 
1.7.11.7
