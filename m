From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 3/3 RFC v2] selftests/net: add socket options test with IPv6 testcases
Date: Thu, 25 Apr 2013 14:05:00 +0300
Message-ID: <1366887900-24769-4-git-send-email-alex.mihai.c@gmail.com>
References: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	ebiederm@xmission.com, gorcunov@openvz.org, palewis@adobe.com,
	edumazet@google.com, Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Only a part of the boolean socket options for IPv6 are tested.

Signed-of-by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 tools/testing/selftests/net/Makefile         |   3 +-
 tools/testing/selftests/net/run_netsocktests |  10 ++
 tools/testing/selftests/net/sockopt.c        | 185 +++++++++++++++++++++++++++
 3 files changed, 197 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/sockopt.c

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 7984f80..087e9a0 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -5,13 +5,14 @@ CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/ -I../lib
 
-NET_PROGS = socket psock_fanout psock_tpacket
+NET_PROGS = socket sockopt psock_fanout psock_tpacket
 
 LIB = ../lib/selftests.a
 
 all: $(NET_PROGS)
 
 socket: socket.o $(LIB)
+sockopt: sockopt.o $(LIB)
 
 %.o: %.c
 	$(CC) $(CFLAGS) -c -o $@ $^
diff --git a/tools/testing/selftests/net/run_netsocktests b/tools/testing/selftests/net/run_netsocktests
index c09a682..9f21498 100644
--- a/tools/testing/selftests/net/run_netsocktests
+++ b/tools/testing/selftests/net/run_netsocktests
@@ -10,3 +10,13 @@ else
 	echo "[PASS]"
 fi
 
+echo "--------------------"
+echo "running setsockopt test"
+echo "--------------------"
+./sockopt
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
+
diff --git a/tools/testing/selftests/net/sockopt.c b/tools/testing/selftests/net/sockopt.c
new file mode 100644
index 0000000..56311bc
--- /dev/null
+++ b/tools/testing/selftests/net/sockopt.c
@@ -0,0 +1,185 @@
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+#include <string.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <linux/ipv6.h>
+#include <linux/in.h>
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
+	/* 0    = valid file descriptor
+	 * -foo = error foo
+	 */
+	int	expect_set;
+	int	expect_get;
+
+	/* If non-zero, accept EAFNOSUPPORT to handle the case
+	 * of the protocol not being configured into the kernel.
+	 */
+	int	nosupport_ok;
+};
+
+static struct sockopt_testcase tests_inet6[] = {
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_V6ONLY,                  (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_V6ONLY,                  (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPKTINFO,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPKTINFO,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292PKTINFO,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292PKTINFO,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+	
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPLIMIT,            (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPLIMIT,            (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPLIMIT,            (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPLIMIT,            (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+ 	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVRTHDR,               (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVRTHDR,               (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292RTHDR,               (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292RTHDR,               (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+	
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPOPTS,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVHOPOPTS,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPOPTS,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292HOPOPTS,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVDSTOPTS,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVDSTOPTS,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292DSTOPTS,             (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_2292DSTOPTS,             (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_TCLASS,                  (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_TCLASS,                  (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVTCLASS,              (void*)1, sizeof(int),  TYPE_INT, 0,  0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVTCLASS,              (void*)0, sizeof(int),  TYPE_INT, 0,  0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_FLOWINFO,                (void*)1, sizeof(int),  TYPE_INT, 0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_FLOWINFO,                (void*)0, sizeof(int),  TYPE_INT, 0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPATHMTU,             (void*)1, sizeof(int),  TYPE_INT, 0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVPATHMTU,             (void*)0, sizeof(int),  TYPE_INT, 0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVORIGDSTADDR,         (void*)1, sizeof(int),  TYPE_INT, 0,  0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_RECVORIGDSTADDR,         (void*)0, sizeof(int),  TYPE_INT, 0,  0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU,                     (void*)512,          sizeof(int),  TYPE_INT, -EINVAL, -ENOTCONN, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU,                     (void*)IPV6_MIN_MTU, sizeof(int),  TYPE_INT,       0, -ENOTCONN, 0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_DONTFRAG,                (void*)1,            sizeof(int),  TYPE_INT,       0,         0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_DONTFRAG,                (void*)0,            sizeof(int),  TYPE_INT,       0,         0, 0},
+
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,             (void*)IP_PMTUDISC_DONT, sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,             (void*)IP_PMTUDISC_WANT, sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,             (void*)IP_PMTUDISC_DO,   sizeof(int),  TYPE_INT,       0,     0, 0},
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP,   IPPROTO_IPV6, IPV6_MTU_DISCOVER,             (void*)IP_PMTUDISC_PROBE,sizeof(int),  TYPE_INT,       0,     0, 0},
+
+};
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+#define ERR_STRING_SZ	64
+
+static test_result_t my_run_testcase(void *arg)
+{
+	struct sockopt_testcase *s = (struct sockopt_testcase*)arg;
+	int fd, rc, val;
+	void *optdata;
+	socklen_t readsize;
+	test_result_t ret;
+
+	ret = 0;
+	fd = socket(s->domain, s->type, s->protocol);
+	abort(fd > 0);
+
+	if (s->data_type == TYPE_INT) {
+		val = (long)s->value;
+		optdata = &val;
+	} else {
+		optdata = s->value;
+	}
+
+	rc = setsockopt(fd, s->level, s->optname, optdata, s->size);
+	check(rc == 0 || errno == -s->expect_set, clean_socket, ret,
+	      "setsockopt option %d", s->optname);
+
+	if (s->data_type == TYPE_INT) {
+		optdata = &val;
+		val = -1;
+	} else {
+		optdata = malloc(s->size);
+		abort(optdata != NULL);
+	}
+
+	readsize = s->size;
+	rc = getsockopt(fd, s->level, s->optname, optdata, &readsize);
+	check(rc == 0 || errno == -s->expect_get, clean_data, ret,
+	      "getsockopt option %d", s->optname);
+	abort(readsize == s->size);
+
+	if (!rc) {
+		if (s->data_type == TYPE_INT) {
+			check(val == (long)s->value, clean_socket, ret,
+			      "option %d: Read value different from written value\n", s->optname);
+		} else {
+			check(!memcmp(optdata, s->value, s->size), clean_data, ret,
+			      "option %d: Read value different from written value\n", s->optname);
+		}
+	}
+
+clean_data:
+	if (s->data_type != TYPE_INT)
+		free(optdata);
+clean_socket:
+	abort(close(fd) == 0);
+
+	return ret;
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
+		.abort_on_fail = 1,
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
1.8.2.1
