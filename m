From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH net-next 2/2] selftests/net: Add a test to validate behavior of rx timestamps
Date: Tue, 22 Aug 2017 13:27:03 -0400
Message-ID: <20170822172703.31703-3-maloneykernel@gmail.com>
References: <20170822172703.31703-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34570 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751768AbdHVR1U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:27:20 -0400
Received: by mail-yw0-f194.google.com with SMTP id y64so3981662ywf.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:27:20 -0700 (PDT)
In-Reply-To: <20170822172703.31703-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Validate the behavior of the combination of various timestamp socket
options, and ensure consistency across ip, udp, and tcp.

Signed-off-by: Mike Maloney <maloney@google.com>
---
 .../selftests/networking/timestamping/.gitignore   |   1 +
 .../selftests/networking/timestamping/Makefile     |   4 +-
 .../networking/timestamping/rxtimestamp.c          | 379 +++++++++++++++++++++
 3 files changed, 383 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/networking/timestamping/rxtimestamp.c

diff --git a/tools/testing/selftests/networking/timestamping/.gitignore b/tools/testing/selftests/networking/timestamping/.gitignore
index 9e69e982fb38..d9355035e746 100644
--- a/tools/testing/selftests/networking/timestamping/.gitignore
+++ b/tools/testing/selftests/networking/timestamping/.gitignore
@@ -1,3 +1,4 @@
 timestamping
+rxtimestamp
 txtimestamp
 hwtstamp_config
diff --git a/tools/testing/selftests/networking/timestamping/Makefile b/tools/testing/selftests/networking/timestamping/Makefile
index ccbb9edbbbb9..92fb8ee917c5 100644
--- a/tools/testing/selftests/networking/timestamping/Makefile
+++ b/tools/testing/selftests/networking/timestamping/Makefile
@@ -1,4 +1,6 @@
-TEST_PROGS := hwtstamp_config timestamping txtimestamp
+CFLAGS += -I../../../../../usr/include
+
+TEST_PROGS := hwtstamp_config rxtimestamp timestamping txtimestamp
 
 all: $(TEST_PROGS)
 
diff --git a/tools/testing/selftests/networking/timestamping/rxtimestamp.c b/tools/testing/selftests/networking/timestamping/rxtimestamp.c
new file mode 100644
index 000000000000..6abcdf401d1a
--- /dev/null
+++ b/tools/testing/selftests/networking/timestamping/rxtimestamp.c
@@ -0,0 +1,379 @@
+#include <errno.h>
+#include <error.h>
+#include <getopt.h>
+#include <stdbool.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+
+#include <sys/time.h>
+#include <sys/socket.h>
+#include <sys/select.h>
+#include <sys/ioctl.h>
+#include <arpa/inet.h>
+#include <net/if.h>
+
+#include <asm/types.h>
+#include <linux/net_tstamp.h>
+#include <linux/errqueue.h>
+
+#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
+
+struct options {
+	int so_timestamp;
+	int so_timestampns;
+	int so_timestamping;
+};
+
+struct tstamps {
+	bool tstamp;
+	bool tstampns;
+	bool swtstamp;
+	bool hwtstamp;
+};
+
+struct socket_type {
+	char *friendly_name;
+	int type;
+	int protocol;
+	bool enabled;
+};
+
+struct test_case {
+	struct options sockopt;
+	struct tstamps expected;
+	bool enabled;
+};
+
+struct sof_flag {
+	int mask;
+	char *name;
+};
+
+static struct sof_flag sof_flags[] = {
+#define SOF_FLAG(f) { f, #f }
+	SOF_FLAG(SOF_TIMESTAMPING_SOFTWARE),
+	SOF_FLAG(SOF_TIMESTAMPING_RX_SOFTWARE),
+	SOF_FLAG(SOF_TIMESTAMPING_RX_HARDWARE),
+};
+
+static struct socket_type socket_types[] = {
+	{ "ip",		SOCK_DGRAM,	IPPROTO_IP },
+	{ "udp",	SOCK_DGRAM,	IPPROTO_UDP },
+	{ "tcp",	SOCK_STREAM,	IPPROTO_TCP },
+};
+
+static struct test_case test_cases[] = {
+	{ {}, {} },
+	{
+		{ so_timestamp: 1 },
+		{ tstamp: true }
+	},
+	{
+		{ so_timestampns: 1 },
+		{ tstampns: true }
+	},
+	{
+		{ so_timestamp: 1, so_timestampns: 1 },
+		{ tstampns: true }
+	},
+	{
+		{ so_timestamping: SOF_TIMESTAMPING_RX_SOFTWARE },
+		{}
+	},
+	{
+		/* Loopback device does not support hw timestamps. */
+		{ so_timestamping: SOF_TIMESTAMPING_RX_HARDWARE },
+		{}
+	},
+	{
+		{ so_timestamping: SOF_TIMESTAMPING_SOFTWARE },
+		{}
+	},
+	{
+		{ so_timestamping: SOF_TIMESTAMPING_RX_SOFTWARE
+			| SOF_TIMESTAMPING_RX_HARDWARE },
+		{}
+	},
+	{
+		{ so_timestamping: SOF_TIMESTAMPING_SOFTWARE
+			| SOF_TIMESTAMPING_RX_SOFTWARE },
+		{ swtstamp: true }
+	},
+	{
+		{ so_timestamp: 1, so_timestamping: SOF_TIMESTAMPING_SOFTWARE
+			| SOF_TIMESTAMPING_RX_SOFTWARE },
+		{ tstamp: true, swtstamp: true }
+	},
+};
+
+static struct option long_options[] = {
+	{ "list_tests", no_argument, 0, 'l' },
+	{ "test_num", required_argument, 0, 'n' },
+	{ "op_size", required_argument, 0, 's' },
+	{ "tcp", no_argument, 0, 't' },
+	{ "udp", no_argument, 0, 'u' },
+	{ "ip", no_argument, 0, 'i' },
+};
+
+static int next_port = 19999;
+static int op_size = 10 * 1024;
+
+void print_test_case(struct test_case *t)
+{
+	int f = 0;
+
+	printf("sockopts {");
+	if (t->sockopt.so_timestamp)
+		printf(" SO_TIMESTAMP ");
+	if (t->sockopt.so_timestampns)
+		printf(" SO_TIMESTAMPNS ");
+	if (t->sockopt.so_timestamping) {
+		printf(" SO_TIMESTAMPING: {");
+		for (f = 0; f < ARRAY_SIZE(sof_flags); f++)
+			if (t->sockopt.so_timestamping & sof_flags[f].mask)
+				printf(" %s |", sof_flags[f].name);
+		printf("}");
+	}
+	printf("} expected cmsgs: {");
+	if (t->expected.tstamp)
+		printf(" SCM_TIMESTAMP ");
+	if (t->expected.tstampns)
+		printf(" SCM_TIMESTAMPNS ");
+	if (t->expected.swtstamp || t->expected.hwtstamp) {
+		printf(" SCM_TIMESTAMPING {");
+		if (t->expected.swtstamp)
+			printf("0");
+		if (t->expected.swtstamp && t->expected.hwtstamp)
+			printf(",");
+		if (t->expected.hwtstamp)
+			printf("2");
+		printf("}");
+	}
+	printf("}\n");
+}
+
+void do_send(int src)
+{
+	int r;
+	char *buf = malloc(op_size);
+
+	memset(buf, 'z', op_size);
+	r = write(src, buf, op_size);
+	if (r < 0)
+		error(1, errno, "Failed to sendmsg");
+
+	free(buf);
+}
+
+bool do_recv(int rcv, struct tstamps expected)
+{
+	const int CMSG_SIZE = 1024;
+
+	struct scm_timestamping *ts;
+	struct tstamps actual = {};
+	char cmsg_buf[CMSG_SIZE];
+	struct iovec recv_iov;
+	struct cmsghdr *cmsg;
+	bool failed = false;
+	struct msghdr hdr;
+	int flags = 0;
+	int r;
+
+	memset(&hdr, 0, sizeof(hdr));
+	hdr.msg_iov = &recv_iov;
+	hdr.msg_iovlen = 1;
+	recv_iov.iov_base = malloc(op_size);
+	recv_iov.iov_len = op_size;
+
+	hdr.msg_control = cmsg_buf;
+	hdr.msg_controllen = sizeof(cmsg_buf);
+
+	r = recvmsg(rcv, &hdr, flags);
+	if (r < 0)
+		error(1, errno, "Failed to recvmsg");
+	if (r != op_size)
+		error(1, 0, "Only received %d bytes of payload.", r);
+
+	if (hdr.msg_flags & (MSG_TRUNC | MSG_CTRUNC))
+		error(1, 0, "Message was truncated.");
+
+	for (cmsg = CMSG_FIRSTHDR(&hdr); cmsg != NULL;
+	     cmsg = CMSG_NXTHDR(&hdr, cmsg)) {
+		if (cmsg->cmsg_level != SOL_SOCKET)
+			error(1, 0, "Unexpected cmsg_level %d",
+			      cmsg->cmsg_level);
+		switch (cmsg->cmsg_type) {
+		case SCM_TIMESTAMP:
+			actual.tstamp = true;
+			break;
+		case SCM_TIMESTAMPNS:
+			actual.tstampns = true;
+			break;
+		case SCM_TIMESTAMPING:
+			ts = (struct scm_timestamping *)CMSG_DATA(cmsg);
+			actual.swtstamp = !!ts->ts[0].tv_sec;
+			actual.hwtstamp = !!ts->ts[2].tv_sec;
+			break;
+		default:
+			error(1, 0, "Unexpected cmsg_type %d", cmsg->cmsg_type);
+		}
+	}
+
+#define VALIDATE(field) \
+	do { \
+		if (expected.field != actual.field) { \
+			if (expected.field) \
+				error(0, 0, "Expected " #field " to be set."); \
+			else \
+				error(0, 0, \
+				      "Expected " #field " to not be set."); \
+			failed = true; \
+		} \
+	} while (0)
+
+	VALIDATE(tstamp);
+	VALIDATE(tstampns);
+	VALIDATE(swtstamp);
+	VALIDATE(hwtstamp);
+#undef VALIDATE
+
+	free(recv_iov.iov_base);
+
+	return failed;
+}
+
+void config_so_flags(int rcv, struct options o)
+{
+	int on = 1;
+
+	if (setsockopt(rcv, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on)) < 0)
+		error(1, errno, "Failed to enable SO_REUSEADDR");
+
+	if (o.so_timestamp &&
+	    setsockopt(rcv, SOL_SOCKET, SO_TIMESTAMP,
+		       &o.so_timestamp, sizeof(o.so_timestamp)) < 0)
+		error(1, errno, "Failed to enable SO_TIMESTAMP");
+
+	if (o.so_timestampns &&
+	    setsockopt(rcv, SOL_SOCKET, SO_TIMESTAMPNS,
+		       &o.so_timestampns, sizeof(o.so_timestampns)) < 0)
+		error(1, errno, "Failed to enable SO_TIMESTAMPNS");
+
+	if (o.so_timestamping &&
+	    setsockopt(rcv, SOL_SOCKET, SO_TIMESTAMPING,
+		       &o.so_timestamping, sizeof(o.so_timestamping)) < 0)
+		error(1, errno, "Failed to set SO_TIMESTAMPING");
+}
+
+bool run_test_case(struct socket_type s, struct test_case t)
+{
+	int port = (s.type == IPPROTO_IP) ? 0 : next_port++;
+	struct sockaddr_in addr;
+	bool failed = false;
+	int src, dst, rcv;
+
+	src = socket(AF_INET, s.type, s.protocol);
+	if (src < 0)
+		error(1, errno, "Failed to open src socket");
+
+	dst = socket(AF_INET, s.type, s.protocol);
+	if (dst < 0)
+		error(1, errno, "Failed to open dst socket");
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sin_family = AF_INET;
+	addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	addr.sin_port = htons(port);
+
+	if (bind(dst, (struct sockaddr *)&addr, sizeof(addr)) < 0)
+		error(1, errno, "Failed to bind to port %d", port);
+
+	if (s.type == SOCK_STREAM && (listen(dst, 1) < 0))
+		error(1, errno, "Failed to listen");
+
+	if (connect(src, (struct sockaddr *)&addr, sizeof(addr)) < 0)
+		error(1, errno, "Failed to connect");
+
+	if (s.type == SOCK_STREAM) {
+		rcv = accept(dst, NULL, NULL);
+		if (rcv < 0)
+			error(1, errno, "Failed to accept");
+		close(dst);
+	} else {
+		rcv = dst;
+	}
+
+	config_so_flags(rcv, t.sockopt);
+	usleep(20000); /* setsockopt for SO_TIMESTAMPING is asynchronous */
+	do_send(src);
+	failed = do_recv(rcv, t.expected);
+
+	close(rcv);
+	close(src);
+
+	return failed;
+}
+
+int main(int argc, char **argv)
+{
+	bool all_protocols = true;
+	bool all_tests = true;
+	int arg_index = 0;
+	int failures = 0;
+	int s, t;
+	char opt;
+
+	while ((opt = getopt_long(argc, argv, "", long_options,
+				  &arg_index)) != -1) {
+		switch (opt) {
+		case 'l':
+			for (t = 0; t < ARRAY_SIZE(test_cases); t++) {
+				printf("%d\t", t);
+				print_test_case(&test_cases[t]);
+			}
+			return 0;
+		case 'n':
+			t = atoi(optarg);
+			if (t > ARRAY_SIZE(test_cases))
+				error(1, 0, "Invalid test case: %d", t);
+			all_tests = false;
+			test_cases[t].enabled = true;
+			break;
+		case 's':
+			op_size = atoi(optarg);
+			break;
+		case 'u':
+			all_protocols = false;
+			socket_types[1].enabled = true;
+			break;
+		case 'i':
+			all_protocols = false;
+			socket_types[0].enabled = true;
+			break;
+		default:
+			error(1, 0, "Failed to parse parameters.");
+		}
+	}
+
+	for (s = 0; s < ARRAY_SIZE(socket_types); s++) {
+		if (!all_protocols && !socket_types[s].enabled)
+			continue;
+
+		printf("Testing %s...\n", socket_types[s].friendly_name);
+		for (t = 0; t < ARRAY_SIZE(test_cases); t++) {
+			if (!all_tests && !test_cases[t].enabled)
+				continue;
+
+			printf("Starting testcase %d...\n", t);
+			if (run_test_case(socket_types[s], test_cases[t])) {
+				failures++;
+				printf("FAILURE in test case ");
+				print_test_case(&test_cases[t]);
+			}
+		}
+	}
+	if (!failures)
+		printf("PASSED.\n");
+	return failures;
+}
-- 
2.14.1.480.gb18f417b89-goog
