From: josef@toxicpanda.com
Subject: [PATCH 1/3][v2] selftest: add a reuseaddr test
Date: Tue, 19 Sep 2017 09:51:26 -0400
Message-ID: <1505829088-1823-1-git-send-email-jbacik@fb.com>
Cc: Josef Bacik <jbacik@fb.com>
To: shuah@kernel.org, davem@davemloft.net, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35152 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751361AbdISNvb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 09:51:31 -0400
Received: by mail-qk0-f193.google.com with SMTP id o77so2289915qke.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 06:51:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josef Bacik <jbacik@fb.com>

This is to test for a regression introduced by

b9470c27607b ("inet: kill smallest_size and smallest_port")

which introduced a problem with reuseaddr and bind conflicts.

Signed-off-by: Josef Bacik <jbacik@fb.com>
---
 tools/testing/selftests/net/.gitignore           |   1 +
 tools/testing/selftests/net/Makefile             |   2 +-
 tools/testing/selftests/net/reuseaddr_conflict.c | 114 +++++++++++++++++++++++
 3 files changed, 116 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/net/reuseaddr_conflict.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 9801253e4802..c612d6e38c62 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -6,3 +6,4 @@ reuseport_bpf
 reuseport_bpf_cpu
 reuseport_bpf_numa
 reuseport_dualstack
+reuseaddr_conflict
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index de1f5772b878..3df542c84610 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -7,7 +7,7 @@ TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh netdevice.sh rtnetl
 TEST_GEN_FILES =  socket
 TEST_GEN_FILES += psock_fanout psock_tpacket
 TEST_GEN_FILES += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
-TEST_GEN_FILES += reuseport_dualstack msg_zerocopy
+TEST_GEN_FILES += reuseport_dualstack msg_zerocopy reuseaddr_conflict
 
 include ../lib.mk
 
diff --git a/tools/testing/selftests/net/reuseaddr_conflict.c b/tools/testing/selftests/net/reuseaddr_conflict.c
new file mode 100644
index 000000000000..7c5b12664b03
--- /dev/null
+++ b/tools/testing/selftests/net/reuseaddr_conflict.c
@@ -0,0 +1,114 @@
+/*
+ * Test for the regression introduced by
+ *
+ * b9470c27607b ("inet: kill smallest_size and smallest_port")
+ *
+ * If we open an ipv4 socket on a port with reuseaddr we shouldn't reset the tb
+ * when we open the ipv6 conterpart, which is what was happening previously.
+ */
+#include <errno.h>
+#include <error.h>
+#include <arpa/inet.h>
+#include <netinet/in.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <sys/socket.h>
+#include <sys/types.h>
+#include <unistd.h>
+
+#define PORT 9999
+
+int open_port(int ipv6, int any)
+{
+	int fd = -1;
+	int reuseaddr = 1;
+	int v6only = 1;
+	int addrlen;
+	int ret = -1;
+	struct sockaddr *addr;
+	int family = ipv6 ? AF_INET6 : AF_INET;
+
+	struct sockaddr_in6 addr6 = {
+		.sin6_family = AF_INET6,
+		.sin6_port = htons(PORT),
+		.sin6_addr = in6addr_any
+	};
+	struct sockaddr_in addr4 = {
+		.sin_family = AF_INET,
+		.sin_port = htons(PORT),
+		.sin_addr.s_addr = any ? htonl(INADDR_ANY) : inet_addr("127.0.0.1"),
+	};
+
+
+	if (ipv6) {
+		addr = (struct sockaddr*)&addr6;
+		addrlen = sizeof(addr6);
+	} else {
+		addr = (struct sockaddr*)&addr4;
+		addrlen = sizeof(addr4);
+	}
+
+	if ((fd = socket(family, SOCK_STREAM, IPPROTO_TCP)) < 0) {
+		perror("socket");
+		goto out;
+	}
+
+	if (ipv6 && setsockopt(fd, IPPROTO_IPV6, IPV6_V6ONLY, (void*)&v6only,
+			       sizeof(v6only)) < 0) {
+		perror("setsockopt IPV6_V6ONLY");
+		goto out;
+	}
+
+	if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuseaddr,
+		       sizeof(reuseaddr)) < 0) {
+		perror("setsockopt SO_REUSEADDR");
+		goto out;
+	}
+
+	if (bind(fd, addr, addrlen) < 0) {
+		perror("bind");
+		goto out;
+	}
+
+	if (any)
+		return fd;
+
+	if (listen(fd, 1) < 0) {
+		perror("listen");
+		goto out;
+	}
+	return fd;
+out:
+	close(fd);
+	return ret;
+}
+
+int main(void)
+{
+	int listenfd;
+	int fd1, fd2;
+
+	fprintf(stderr, "Opening 127.0.0.1:%d\n", PORT);
+	listenfd = open_port(0, 0);
+	if (listenfd < 0)
+		error(1, errno, "Couldn't open listen socket");
+	fprintf(stderr, "Opening INADDR_ANY:%d\n", PORT);
+	fd1 = open_port(0, 1);
+	if (fd1 >= 0)
+		error(1, 0, "Was allowed to create an ipv4 reuseport on a already bound non-reuseport socket");
+	fprintf(stderr, "Opening in6addr_any:%d\n", PORT);
+	fd1 = open_port(1, 1);
+	if (fd1 < 0)
+		error(1, errno, "Couldn't open ipv6 reuseport");
+	fprintf(stderr, "Opening INADDR_ANY:%d\n", PORT);
+	fd2 = open_port(0, 1);
+	if (fd2 >= 0)
+		error(1, 0, "Was allowed to create an ipv4 reuseport on a already bound non-reuseport socket");
+	close(fd1);
+	fprintf(stderr, "Opening INADDR_ANY:%d after closing ipv6 socket\n", PORT);
+	fd1 = open_port(0, 1);
+	if (fd1 >= 0)
+		error(1, 0, "Was allowed to create an ipv4 reuseport on an already bound non-reuseport socket with no ipv6");
+	fprintf(stderr, "Success");
+	return 0;
+}
-- 
2.7.4
