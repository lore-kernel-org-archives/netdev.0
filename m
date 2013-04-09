From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 2/3 net-next RFC] selftest: Adapt socket test to new testing framework
Date: Tue,  9 Apr 2013 13:31:00 +0300
Message-ID: <1365503461-26309-3-git-send-email-alex.mihai.c@gmail.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Cc: willemb@google.com, dborkman@redhat.com, edumazet@google.com,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:42943 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936614Ab3DIKdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 06:33:08 -0400
Received: by mail-bk0-f49.google.com with SMTP id w12so3531179bku.8
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 03:33:07 -0700 (PDT)
In-Reply-To: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 tools/testing/selftests/net/Makefile |   4 +-
 tools/testing/selftests/net/socket.c | 107 +++++++++++++++++++++++++----------
 2 files changed, 80 insertions(+), 31 deletions(-)

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 750512b..9de4ae6 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -11,9 +11,11 @@ all: $(NET_PROGS)
 %: %.c
 	$(CC) $(CFLAGS) -o $@ $^
 
+socket: selftests.o
+
 run_tests: all
 	@/bin/sh ./run_netsocktests || echo "sockettests: [FAIL]"
 	@/bin/sh ./run_afpackettests || echo "afpackettests: [FAIL]"
 
 clean:
-	$(RM) $(NET_PROGS)
+	$(RM) $(NET_PROGS) *.o
diff --git a/tools/testing/selftests/net/socket.c b/tools/testing/selftests/net/socket.c
index 0f227f2..89b1b1e 100644
--- a/tools/testing/selftests/net/socket.c
+++ b/tools/testing/selftests/net/socket.c
@@ -6,6 +6,8 @@
 #include <sys/socket.h>
 #include <netinet/in.h>
 
+#include "selftests.h"
+
 struct socket_testcase {
 	int	domain;
 	int	type;
@@ -22,7 +24,7 @@ struct socket_testcase {
 	int	nosupport_ok;
 };
 
-static struct socket_testcase tests[] = {
+static struct socket_testcase tests_inet[] = {
 	{ AF_MAX,  0,           0,           -EAFNOSUPPORT,    0 },
 	{ AF_INET, SOCK_STREAM, IPPROTO_TCP, 0,                1  },
 	{ AF_INET, SOCK_DGRAM,  IPPROTO_TCP, -EPROTONOSUPPORT, 1  },
@@ -30,58 +32,103 @@ static struct socket_testcase tests[] = {
 	{ AF_INET, SOCK_STREAM, IPPROTO_UDP, -EPROTONOSUPPORT, 1  },
 };
 
+static struct socket_testcase tests_inet6[] = {
+	{ AF_INET6, SOCK_STREAM, IPPROTO_TCP, 0,                1  },
+	{ AF_INET6, SOCK_DGRAM,  IPPROTO_TCP, -EPROTONOSUPPORT, 1  },
+	{ AF_INET6, SOCK_DGRAM,  IPPROTO_UDP, 0,                1  },
+	{ AF_INET6, SOCK_STREAM, IPPROTO_UDP, -EPROTONOSUPPORT, 1  },
+};
+
+static struct socket_testcase tests_unix[] = {
+	{ AF_UNIX, SOCK_STREAM,    0,           0,                1  },
+	{ AF_UNIX, SOCK_DGRAM,     0,           0,                1  },
+	{ AF_UNIX, SOCK_SEQPACKET, 0,           0,                1  },
+	{ AF_UNIX, SOCK_STREAM,    PF_UNIX,     0,                1  },
+	{ AF_UNIX, SOCK_DGRAM,     PF_UNIX,     0,                1  },
+	{ AF_UNIX, SOCK_SEQPACKET, PF_UNIX,     0,                1  },
+	{ AF_UNIX, SOCK_STREAM,    IPPROTO_TCP, -EPROTONOSUPPORT, 1  },
+	{ AF_UNIX, SOCK_STREAM,    IPPROTO_UDP, -EPROTONOSUPPORT, 1  },
+	{ AF_UNIX, SOCK_DCCP,      0,           -ESOCKTNOSUPPORT, 1  },
+};
+
 #define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
 #define ERR_STRING_SZ	64
 
-static int run_tests(void)
+static int my_run_testcase(void *arg)
 {
+	struct socket_testcase *s = (struct socket_testcase*)arg;
+	int fd;
 	char err_string1[ERR_STRING_SZ];
 	char err_string2[ERR_STRING_SZ];
-	int i, err;
-
-	err = 0;
-	for (i = 0; i < ARRAY_SIZE(tests); i++) {
-		struct socket_testcase *s = &tests[i];
-		int fd;
 
-		fd = socket(s->domain, s->type, s->protocol);
-		if (fd < 0) {
-			if (s->nosupport_ok &&
-			    errno == EAFNOSUPPORT)
-				continue;
+	fd = socket(s->domain, s->type, s->protocol);
+	if (fd < 0) {
+		if (s->nosupport_ok && errno == EAFNOSUPPORT)
+			return 0;
 
-			if (s->expect < 0 &&
-			    errno == -s->expect)
-				continue;
+		if (s->expect < 0 && errno == -s->expect)
+			return 0;
 
-			strerror_r(-s->expect, err_string1, ERR_STRING_SZ);
-			strerror_r(errno, err_string2, ERR_STRING_SZ);
+		strerror_r(-s->expect, err_string1, ERR_STRING_SZ);
+		strerror_r(errno, err_string2, ERR_STRING_SZ);
 
-			fprintf(stderr, "socket(%d, %d, %d) expected "
+		fprintf(stderr, "socket(%d, %d, %d) expected "
 				"err (%s) got (%s)\n",
 				s->domain, s->type, s->protocol,
 				err_string1, err_string2);
 
-			err = -1;
-			break;
-		} else {
-			close(fd);
+		return -1;
+	} else {
+		close(fd);
 
-			if (s->expect < 0) {
-				strerror_r(errno, err_string1, ERR_STRING_SZ);
+		if (s->expect < 0) {
+			strerror_r(errno, err_string1, ERR_STRING_SZ);
 
-				fprintf(stderr, "socket(%d, %d, %d) expected "
+			fprintf(stderr, "socket(%d, %d, %d) expected "
 					"success got err (%s)\n",
 					s->domain, s->type, s->protocol,
 					err_string1);
 
-				err = -1;
-				break;
-			}
+			return -1;
 		}
 	}
+	return 0;
+}
 
-	return err;
+static int run_tests(void)
+{
+	int rc;
+	struct generic_test test1 = {
+		.name = "socket AF_INET",
+		.prepare = NULL,
+		.run = my_run_testcase,
+		.testcases = tests_inet,
+		.testcase_size = sizeof(struct socket_testcase),
+		.testcase_count = ARRAY_SIZE(tests_inet),
+	};
+	struct generic_test test2 = {
+		.name = "socket AF_INET6",
+		.prepare = NULL,
+		.run = my_run_testcase,
+		.testcases = tests_inet6,
+		.testcase_size = sizeof(struct socket_testcase),
+		.testcase_count = ARRAY_SIZE(tests_inet6),
+	};
+	struct generic_test test3 = {
+		.name = "socket AF_UNIX",
+		.prepare = NULL,
+		.run = my_run_testcase,
+		.testcases = tests_unix,
+		.testcase_size = sizeof(struct socket_testcase),
+		.testcase_count = ARRAY_SIZE(tests_unix),
+	};
+
+	rc = 0;
+	rc |= run_all_tests(&test1, NULL);
+	rc |= run_all_tests(&test2, NULL);
+	rc |= run_all_tests(&test3, NULL);
+
+	return rc;
 }
 
 int main(void)
-- 
1.8.2
