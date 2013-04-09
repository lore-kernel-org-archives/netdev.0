From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH net-next RFC] selftests: add socket options test with IPv6 testcases
Date: Tue,  9 Apr 2013 13:31:01 +0300
Message-ID: <1365503461-26309-4-git-send-email-alex.mihai.c@gmail.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Cc: willemb@google.com, dborkman@redhat.com, edumazet@google.com,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f52.google.com ([209.85.214.52]:33522 "EHLO
	mail-bk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935814Ab3DIKdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 06:33:11 -0400
Received: by mail-bk0-f52.google.com with SMTP id it16so3520843bkc.11
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 03:33:10 -0700 (PDT)
In-Reply-To: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only a part of the boolean socket options for IPv6 are tested.

Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 tools/testing/selftests/net/Makefile         |   3 +-
 tools/testing/selftests/net/run_netsocktests |  10 ++
 tools/testing/selftests/net/sockopt.c        | 189 +++++++++++++++++++++++++++
 3 files changed, 201 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/sockopt.c

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 9de4ae6..da0e954 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -5,13 +5,14 @@ CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout psock_tpacket
+NET_PROGS = socket sockopt psock_fanout psock_tpacket
 
 all: $(NET_PROGS)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
 socket: selftests.o
+sockopt: selftests.o
 
 run_tests: all
 	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
diff --git a/tools/testing/selftests/net/run_netsocktests b/tools/testing/selftests/net/run_netsocktests
index c09a682..7aa4b01 100644
--- a/tools/testing/selftests/net/run_netsocktests
+++ b/tools/testing/selftests/net/run_netsocktests
@@ -10,3 +10,13 @@ else
 	echo "[PASS]"
 fi
 
+echo "---------------------------"
+echo "running socket options test"
+echo "---------------------------"
+./sockopt
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+
diff --git a/tools/testing/selftests/net/sockopt.c b/tools/testing/selftests/net/sockopt.c
new file mode 100644
index 0000000..4c130e3
--- /dev/null
+++ b/tools/testing/selftests/net/sockopt.c
@@ -0,0 +1,189 @@
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <linux/in.h>
+#include <linux/ipv6.h>
+
+#include "selftests.h"
+
+struct sockopt_testcase {
+	/* socket */
+	int	domain;
+	int	type;
+	int	protocol;
+
+	/* option */
+	int	level;
+	int	optname;
+	void	*value;
+	socklen_t size;
+
+	#define TYPE_INT   1
+	#define TYPE_DATA  2
+	int data_type;
+
+	int	expect_set;
+	int	expect_get;
+
+	int	nosupport_ok;
+};
+
+
+static struct sockopt_testcase tests_inet6[] = {
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, -1,                      (void*)0, sizeof(int),  TYPE_INT, -ENOPROTOOPT,  -ENOPROTOOPT,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_V6ONLY,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_V6ONLY,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPKTINFO,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPKTINFO,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292PKTINFO,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292PKTINFO,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+	
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPLIMIT,       (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPLIMIT,       (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPLIMIT,       (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPLIMIT,       (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+ 	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVRTHDR,          (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVRTHDR,          (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292RTHDR,          (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292RTHDR,          (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+	
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPOPTS,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPOPTS,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPOPTS,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPOPTS,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVDSTOPTS,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVDSTOPTS,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292DSTOPTS,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292DSTOPTS,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_TCLASS,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_TCLASS,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVTCLASS,         (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVTCLASS,         (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_FLOWINFO,           (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_FLOWINFO,           (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPATHMTU,        (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPATHMTU,        (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVORIGDSTADDR,    (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVORIGDSTADDR,    (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_DONTFRAG,           (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_DONTFRAG,           (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU,                (void*)512,          sizeof(int),  TYPE_INT, -EINVAL, -ENOTCONN, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU,                (void*)IPV6_MIN_MTU, sizeof(int),  TYPE_INT,       0, -ENOTCONN, 0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,       (void*)IP_PMTUDISC_DONT, sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,       (void*)IP_PMTUDISC_WANT, sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,       (void*)IP_PMTUDISC_DO,   sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,       (void*)IP_PMTUDISC_PROBE,sizeof(int),  TYPE_INT,       0,     0, 0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_UNICAST_IF,         (void*)0,                sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_UNICAST_IF,         (void*)0x01000000,       sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_UNICAST_IF,         (void*)-1,               sizeof(int),  TYPE_INT, -EADDRNOTAVAIL,     -EADDRNOTAVAIL, 0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MULTICAST_IF,       (void*)0,                sizeof(int),  TYPE_INT, -ENOPROTOOPT, -ENOPROTOOPT, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_IF,        (void*)0,                sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_IF,        (void*)-1,               sizeof(int),  TYPE_INT, -ENODEV, -ENODEV, 0},
+
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_HOPS,      (void*)-1,               sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_HOPS,      (void*)0,                sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_HOPS,      (void*)255,              sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_MULTICAST_HOPS,      (void*)256,              sizeof(int),  TYPE_INT, -EINVAL,    0, 0},
+
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_UNICAST_HOPS,        (void*)-1,               sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_UNICAST_HOPS,        (void*)0,                sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_UNICAST_HOPS,        (void*)255,              sizeof(int),  TYPE_INT,      0,     0, 0},
+	{ AF_INET6, SOCK_DGRAM, IPPROTO_UDP,   IPPROTO_IPV6, IPV6_UNICAST_HOPS,        (void*)256,              sizeof(int),  TYPE_INT, -EINVAL,    0, 0},
+
+
+};
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+#define ERR_STRING_SZ	64
+
+static int my_run_testcase(void *arg)
+{
+	struct sockopt_testcase *s = (struct sockopt_testcase*)arg;
+	int fd, rc, val;
+	void *optdata;
+	socklen_t readsize;
+
+	fd = socket(s->domain, s->type, s->protocol);
+	ASSERT(fd > 0);
+
+	if (s->data_type == TYPE_INT) {
+		val = (long)s->value;
+		optdata = &val;
+	} else {
+		optdata = s->value;
+	}
+
+	rc = setsockopt(fd, s->level, s->optname, optdata, s->size);
+	CHECK(rc == 0 || errno == -s->expect_set, "setsockopt option %d\n", s->optname);
+
+	if (s->data_type == TYPE_INT) {
+		optdata = &val;
+		val = -1;
+	} else {
+		optdata = malloc(s->size);
+		ASSERT(optdata != NULL);
+	}
+
+	readsize = s->size;
+	rc = getsockopt(fd, s->level, s->optname, optdata, &readsize);
+	CHECK(rc == 0 || errno == -s->expect_get, "getsockopt option %d\n", s->optname);
+	ASSERT(readsize == s->size);
+
+	if (rc == 0 && errno == 0) {
+		if (s->data_type == TYPE_INT) {
+			CHECK(val == (long)s->value, "Read value different from written value\n");
+		} else {
+			CHECK(!memcmp(optdata, s->value, s->size), "Read value different from written value\n");
+			free(optdata);
+		}
+	}
+	ASSERT(close(fd) == 0);
+	return 0;
+}
+
+static int run_tests(void)
+{
+	int rc;
+	struct generic_test test1 = {
+		.name = "sockopt AF_INET6",
+		.prepare = NULL,
+		.run = my_run_testcase,
+		.testcases = tests_inet6,
+		.testcase_size = sizeof(struct sockopt_testcase),
+		.testcase_count = ARRAY_SIZE(tests_inet6),
+	};
+
+	rc = 0;
+	rc |= run_all_tests(&test1, NULL);
+
+	return rc;
+}
+
+int main(void)
+{
+	int err = run_tests();
+
+	return err;
+}
-- 
1.8.2
