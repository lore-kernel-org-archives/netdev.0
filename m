From: Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH v3 5/5] VSOCK: add tools/testing/vsock/vsock_diag_test
Date: Thu,  5 Oct 2017 16:46:54 -0400
Message-ID: <20171005204654.2737-6-stefanha@redhat.com>
References: <20171005204654.2737-1-stefanha@redhat.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jorgen Hansen <jhansen@vmware.com>,
        Dexuan Cui <decui@microsoft.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11965 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751557AbdJEUrh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 16:47:37 -0400
In-Reply-To: <20171005204654.2737-1-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds tests for the vsock_diag.ko module.

These tests are not self-tests because they require manual set up of a
KVM or VMware guest.  Please see tools/testing/vsock/README for
instructions.

The control.h and timeout.h infrastructure can be used for additional
AF_VSOCK tests in the future.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 MAINTAINERS                           |   1 +
 tools/testing/vsock/Makefile          |   9 +
 tools/testing/vsock/control.h         |  13 +
 tools/testing/vsock/timeout.h         |  14 +
 tools/testing/vsock/control.c         | 219 +++++++++++
 tools/testing/vsock/timeout.c         |  64 ++++
 tools/testing/vsock/vsock_diag_test.c | 681 ++++++++++++++++++++++++++++++++++
 tools/testing/vsock/.gitignore        |   2 +
 tools/testing/vsock/README            |  36 ++
 9 files changed, 1039 insertions(+)
 create mode 100644 tools/testing/vsock/Makefile
 create mode 100644 tools/testing/vsock/control.h
 create mode 100644 tools/testing/vsock/timeout.h
 create mode 100644 tools/testing/vsock/control.c
 create mode 100644 tools/testing/vsock/timeout.c
 create mode 100644 tools/testing/vsock/vsock_diag_test.c
 create mode 100644 tools/testing/vsock/.gitignore
 create mode 100644 tools/testing/vsock/README

diff --git a/MAINTAINERS b/MAINTAINERS
index 039f0ad13482..5ad7381d92aa 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -14282,6 +14282,7 @@ F:	net/vmw_vsock/virtio_transport.c
 F:	drivers/net/vsockmon.c
 F:	drivers/vhost/vsock.c
 F:	drivers/vhost/vsock.h
+F:	tools/testing/vsock/
 
 VIRTIO CONSOLE DRIVER
 M:	Amit Shah <amit@kernel.org>
diff --git a/tools/testing/vsock/Makefile b/tools/testing/vsock/Makefile
new file mode 100644
index 000000000000..66ba0924194d
--- /dev/null
+++ b/tools/testing/vsock/Makefile
@@ -0,0 +1,9 @@
+all: test
+test: vsock_diag_test
+vsock_diag_test: vsock_diag_test.o timeout.o control.o
+
+CFLAGS += -g -O2 -Werror -Wall -I. -I../../include/uapi -I../../include -Wno-pointer-sign -fno-strict-overflow -fno-strict-aliasing -fno-common -MMD -U_FORTIFY_SOURCE -D_GNU_SOURCE
+.PHONY: all test clean
+clean:
+	${RM} *.o *.d vsock_diag_test
+-include *.d
diff --git a/tools/testing/vsock/control.h b/tools/testing/vsock/control.h
new file mode 100644
index 000000000000..54a07efd267c
--- /dev/null
+++ b/tools/testing/vsock/control.h
@@ -0,0 +1,13 @@
+#ifndef CONTROL_H
+#define CONTROL_H
+
+#include <stdbool.h>
+
+void control_init(const char *control_host, const char *control_port,
+		  bool server);
+void control_cleanup(void);
+void control_writeln(const char *str);
+char *control_readln(void);
+void control_expectln(const char *str);
+
+#endif /* CONTROL_H */
diff --git a/tools/testing/vsock/timeout.h b/tools/testing/vsock/timeout.h
new file mode 100644
index 000000000000..77db9ce9860a
--- /dev/null
+++ b/tools/testing/vsock/timeout.h
@@ -0,0 +1,14 @@
+#ifndef TIMEOUT_H
+#define TIMEOUT_H
+
+enum {
+	/* Default timeout */
+	TIMEOUT = 10 /* seconds */
+};
+
+void sigalrm(int signo);
+void timeout_begin(unsigned int seconds);
+void timeout_check(const char *operation);
+void timeout_end(void);
+
+#endif /* TIMEOUT_H */
diff --git a/tools/testing/vsock/control.c b/tools/testing/vsock/control.c
new file mode 100644
index 000000000000..90fd47f0e422
--- /dev/null
+++ b/tools/testing/vsock/control.c
@@ -0,0 +1,219 @@
+/* Control socket for client/server test execution
+ *
+ * Copyright (C) 2017 Red Hat, Inc.
+ *
+ * Author: Stefan Hajnoczi <stefanha@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+/* The client and server may need to coordinate to avoid race conditions like
+ * the client attempting to connect to a socket that the server is not
+ * listening on yet.  The control socket offers a communications channel for
+ * such coordination tasks.
+ *
+ * If the client calls control_expectln("LISTENING"), then it will block until
+ * the server calls control_writeln("LISTENING").  This provides a simple
+ * mechanism for coordinating between the client and the server.
+ */
+
+#include <errno.h>
+#include <netdb.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include "timeout.h"
+#include "control.h"
+
+static int control_fd = -1;
+
+/* Open the control socket, either in server or client mode */
+void control_init(const char *control_host,
+		  const char *control_port,
+		  bool server)
+{
+	struct addrinfo hints = {
+		.ai_socktype = SOCK_STREAM,
+	};
+	struct addrinfo *result = NULL;
+	struct addrinfo *ai;
+	int ret;
+
+	ret = getaddrinfo(control_host, control_port, &hints, &result);
+	if (ret != 0) {
+		fprintf(stderr, "%s\n", gai_strerror(ret));
+		exit(EXIT_FAILURE);
+	}
+
+	for (ai = result; ai; ai = ai->ai_next) {
+		int fd;
+		int val = 1;
+
+		fd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
+		if (fd < 0)
+			continue;
+
+		if (!server) {
+			if (connect(fd, ai->ai_addr, ai->ai_addrlen) < 0)
+				goto next;
+			control_fd = fd;
+			printf("Control socket connected to %s:%s.\n",
+			       control_host, control_port);
+			break;
+		}
+
+		if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,
+			       &val, sizeof(val)) < 0) {
+			perror("setsockopt");
+			exit(EXIT_FAILURE);
+		}
+
+		if (bind(fd, ai->ai_addr, ai->ai_addrlen) < 0)
+			goto next;
+		if (listen(fd, 1) < 0)
+			goto next;
+
+		printf("Control socket listening on %s:%s\n",
+		       control_host, control_port);
+		fflush(stdout);
+
+		control_fd = accept(fd, NULL, 0);
+		close(fd);
+
+		if (control_fd < 0) {
+			perror("accept");
+			exit(EXIT_FAILURE);
+		}
+		printf("Control socket connection accepted...\n");
+		break;
+
+next:
+		close(fd);
+	}
+
+	if (control_fd < 0) {
+		fprintf(stderr, "Control socket initialization failed.  Invalid address %s:%s?\n",
+			control_host, control_port);
+		exit(EXIT_FAILURE);
+	}
+
+	freeaddrinfo(result);
+}
+
+/* Free resources */
+void control_cleanup(void)
+{
+	close(control_fd);
+	control_fd = -1;
+}
+
+/* Write a line to the control socket */
+void control_writeln(const char *str)
+{
+	ssize_t len = strlen(str);
+	ssize_t ret;
+
+	timeout_begin(TIMEOUT);
+
+	do {
+		ret = send(control_fd, str, len, MSG_MORE);
+		timeout_check("send");
+	} while (ret < 0 && errno == EINTR);
+
+	if (ret != len) {
+		perror("send");
+		exit(EXIT_FAILURE);
+	}
+
+	do {
+		ret = send(control_fd, "\n", 1, 0);
+		timeout_check("send");
+	} while (ret < 0 && errno == EINTR);
+
+	if (ret != 1) {
+		perror("send");
+		exit(EXIT_FAILURE);
+	}
+
+	timeout_end();
+}
+
+/* Return the next line from the control socket (without the trailing newline).
+ *
+ * The program terminates if a timeout occurs.
+ *
+ * The caller must free() the returned string.
+ */
+char *control_readln(void)
+{
+	char *buf = NULL;
+	size_t idx = 0;
+	size_t buflen = 0;
+
+	timeout_begin(TIMEOUT);
+
+	for (;;) {
+		ssize_t ret;
+
+		if (idx >= buflen) {
+			char *new_buf;
+
+			new_buf = realloc(buf, buflen + 80);
+			if (!new_buf) {
+				perror("realloc");
+				exit(EXIT_FAILURE);
+			}
+
+			buf = new_buf;
+			buflen += 80;
+		}
+
+		do {
+			ret = recv(control_fd, &buf[idx], 1, 0);
+			timeout_check("recv");
+		} while (ret < 0 && errno == EINTR);
+
+		if (ret == 0) {
+			fprintf(stderr, "unexpected EOF on control socket\n");
+			exit(EXIT_FAILURE);
+		}
+
+		if (ret != 1) {
+			perror("recv");
+			exit(EXIT_FAILURE);
+		}
+
+		if (buf[idx] == '\n') {
+			buf[idx] = '\0';
+			break;
+		}
+
+		idx++;
+	}
+
+	timeout_end();
+
+	return buf;
+}
+
+/* Wait until a given line is received or a timeout occurs */
+void control_expectln(const char *str)
+{
+	char *line;
+
+	line = control_readln();
+	if (strcmp(str, line) != 0) {
+		fprintf(stderr, "expected \"%s\" on control socket, got \"%s\"\n",
+			str, line);
+		exit(EXIT_FAILURE);
+	}
+
+	free(line);
+}
diff --git a/tools/testing/vsock/timeout.c b/tools/testing/vsock/timeout.c
new file mode 100644
index 000000000000..c49b3003b2db
--- /dev/null
+++ b/tools/testing/vsock/timeout.c
@@ -0,0 +1,64 @@
+/* Timeout API for single-threaded programs that use blocking
+ * syscalls (read/write/send/recv/connect/accept).
+ *
+ * Copyright (C) 2017 Red Hat, Inc.
+ *
+ * Author: Stefan Hajnoczi <stefanha@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+/* Use the following pattern:
+ *
+ *   timeout_begin(TIMEOUT);
+ *   do {
+ *       ret = accept(...);
+ *       timeout_check("accept");
+ *   } while (ret < 0 && ret == EINTR);
+ *   timeout_end();
+ */
+
+#include <stdlib.h>
+#include <stdbool.h>
+#include <unistd.h>
+#include <stdio.h>
+#include "timeout.h"
+
+static volatile bool timeout;
+
+/* SIGALRM handler function.  Do not use sleep(2), alarm(2), or
+ * setitimer(2) while using this API - they may interfere with each
+ * other.
+ */
+void sigalrm(int signo)
+{
+	timeout = true;
+}
+
+/* Start a timeout.  Call timeout_check() to verify that the timeout hasn't
+ * expired.  timeout_end() must be called to stop the timeout.  Timeouts cannot
+ * be nested.
+ */
+void timeout_begin(unsigned int seconds)
+{
+	alarm(seconds);
+}
+
+/* Exit with an error message if the timeout has expired */
+void timeout_check(const char *operation)
+{
+	if (timeout) {
+		fprintf(stderr, "%s timed out\n", operation);
+		exit(EXIT_FAILURE);
+	}
+}
+
+/* Stop a timeout */
+void timeout_end(void)
+{
+	alarm(0);
+	timeout = false;
+}
diff --git a/tools/testing/vsock/vsock_diag_test.c b/tools/testing/vsock/vsock_diag_test.c
new file mode 100644
index 000000000000..e896a4af52f4
--- /dev/null
+++ b/tools/testing/vsock/vsock_diag_test.c
@@ -0,0 +1,681 @@
+/*
+ * vsock_diag_test - vsock_diag.ko test suite
+ *
+ * Copyright (C) 2017 Red Hat, Inc.
+ *
+ * Author: Stefan Hajnoczi <stefanha@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; version 2
+ * of the License.
+ */
+
+#include <getopt.h>
+#include <stdio.h>
+#include <stdbool.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <unistd.h>
+#include <signal.h>
+#include <sys/socket.h>
+#include <sys/stat.h>
+#include <sys/types.h>
+#include <linux/list.h>
+#include <linux/net.h>
+#include <linux/netlink.h>
+#include <linux/sock_diag.h>
+#include <netinet/tcp.h>
+
+#include "../../../include/uapi/linux/vm_sockets.h"
+#include "../../../include/uapi/linux/vm_sockets_diag.h"
+
+#include "timeout.h"
+#include "control.h"
+
+enum test_mode {
+	TEST_MODE_UNSET,
+	TEST_MODE_CLIENT,
+	TEST_MODE_SERVER
+};
+
+/* Per-socket status */
+struct vsock_stat {
+	struct list_head list;
+	struct vsock_diag_msg msg;
+};
+
+static const char *sock_type_str(int type)
+{
+	switch (type) {
+	case SOCK_DGRAM:
+		return "DGRAM";
+	case SOCK_STREAM:
+		return "STREAM";
+	default:
+		return "INVALID TYPE";
+	}
+}
+
+static const char *sock_state_str(int state)
+{
+	switch (state) {
+	case TCP_CLOSE:
+		return "UNCONNECTED";
+	case TCP_SYN_SENT:
+		return "CONNECTING";
+	case TCP_ESTABLISHED:
+		return "CONNECTED";
+	case TCP_CLOSING:
+		return "DISCONNECTING";
+	case TCP_LISTEN:
+		return "LISTEN";
+	default:
+		return "INVALID STATE";
+	}
+}
+
+static const char *sock_shutdown_str(int shutdown)
+{
+	switch (shutdown) {
+	case 1:
+		return "RCV_SHUTDOWN";
+	case 2:
+		return "SEND_SHUTDOWN";
+	case 3:
+		return "RCV_SHUTDOWN | SEND_SHUTDOWN";
+	default:
+		return "0";
+	}
+}
+
+static void print_vsock_addr(FILE *fp, unsigned int cid, unsigned int port)
+{
+	if (cid == VMADDR_CID_ANY)
+		fprintf(fp, "*:");
+	else
+		fprintf(fp, "%u:", cid);
+
+	if (port == VMADDR_PORT_ANY)
+		fprintf(fp, "*");
+	else
+		fprintf(fp, "%u", port);
+}
+
+static void print_vsock_stat(FILE *fp, struct vsock_stat *st)
+{
+	print_vsock_addr(fp, st->msg.vdiag_src_cid, st->msg.vdiag_src_port);
+	fprintf(fp, " ");
+	print_vsock_addr(fp, st->msg.vdiag_dst_cid, st->msg.vdiag_dst_port);
+	fprintf(fp, " %s %s %s %u\n",
+		sock_type_str(st->msg.vdiag_type),
+		sock_state_str(st->msg.vdiag_state),
+		sock_shutdown_str(st->msg.vdiag_shutdown),
+		st->msg.vdiag_ino);
+}
+
+static void print_vsock_stats(FILE *fp, struct list_head *head)
+{
+	struct vsock_stat *st;
+
+	list_for_each_entry(st, head, list)
+		print_vsock_stat(fp, st);
+}
+
+static struct vsock_stat *find_vsock_stat(struct list_head *head, int fd)
+{
+	struct vsock_stat *st;
+	struct stat stat;
+
+	if (fstat(fd, &stat) < 0) {
+		perror("fstat");
+		exit(EXIT_FAILURE);
+	}
+
+	list_for_each_entry(st, head, list)
+		if (st->msg.vdiag_ino == stat.st_ino)
+			return st;
+
+	fprintf(stderr, "cannot find fd %d\n", fd);
+	exit(EXIT_FAILURE);
+}
+
+static void check_no_sockets(struct list_head *head)
+{
+	if (!list_empty(head)) {
+		fprintf(stderr, "expected no sockets\n");
+		print_vsock_stats(stderr, head);
+		exit(1);
+	}
+}
+
+static void check_num_sockets(struct list_head *head, int expected)
+{
+	struct list_head *node;
+	int n = 0;
+
+	list_for_each(node, head)
+		n++;
+
+	if (n != expected) {
+		fprintf(stderr, "expected %d sockets, found %d\n",
+			expected, n);
+		print_vsock_stats(stderr, head);
+		exit(EXIT_FAILURE);
+	}
+}
+
+static void check_socket_state(struct vsock_stat *st, __u8 state)
+{
+	if (st->msg.vdiag_state != state) {
+		fprintf(stderr, "expected socket state %#x, got %#x\n",
+			state, st->msg.vdiag_state);
+		exit(EXIT_FAILURE);
+	}
+}
+
+static void send_req(int fd)
+{
+	struct sockaddr_nl nladdr = {
+		.nl_family = AF_NETLINK,
+	};
+	struct {
+		struct nlmsghdr nlh;
+		struct vsock_diag_req vreq;
+	} req = {
+		.nlh = {
+			.nlmsg_len = sizeof(req),
+			.nlmsg_type = SOCK_DIAG_BY_FAMILY,
+			.nlmsg_flags = NLM_F_REQUEST | NLM_F_DUMP,
+		},
+		.vreq = {
+			.sdiag_family = AF_VSOCK,
+			.vdiag_states = ~(__u32)0,
+		},
+	};
+	struct iovec iov = {
+		.iov_base = &req,
+		.iov_len = sizeof(req),
+	};
+	struct msghdr msg = {
+		.msg_name = &nladdr,
+		.msg_namelen = sizeof(nladdr),
+		.msg_iov = &iov,
+		.msg_iovlen = 1,
+	};
+
+	for (;;) {
+		if (sendmsg(fd, &msg, 0) < 0) {
+			if (errno == EINTR)
+				continue;
+
+			perror("sendmsg");
+			exit(EXIT_FAILURE);
+		}
+
+		return;
+	}
+}
+
+static ssize_t recv_resp(int fd, void *buf, size_t len)
+{
+	struct sockaddr_nl nladdr = {
+		.nl_family = AF_NETLINK,
+	};
+	struct iovec iov = {
+		.iov_base = buf,
+		.iov_len = len,
+	};
+	struct msghdr msg = {
+		.msg_name = &nladdr,
+		.msg_namelen = sizeof(nladdr),
+		.msg_iov = &iov,
+		.msg_iovlen = 1,
+	};
+	ssize_t ret;
+
+	do {
+		ret = recvmsg(fd, &msg, 0);
+	} while (ret < 0 && errno == EINTR);
+
+	if (ret < 0) {
+		perror("recvmsg");
+		exit(EXIT_FAILURE);
+	}
+
+	return ret;
+}
+
+static void add_vsock_stat(struct list_head *sockets,
+			   const struct vsock_diag_msg *resp)
+{
+	struct vsock_stat *st;
+
+	st = malloc(sizeof(*st));
+	if (!st) {
+		perror("malloc");
+		exit(EXIT_FAILURE);
+	}
+
+	st->msg = *resp;
+	list_add_tail(&st->list, sockets);
+}
+
+/*
+ * Read vsock stats into a list.
+ */
+static void read_vsock_stat(struct list_head *sockets)
+{
+	long buf[8192 / sizeof(long)];
+	int fd;
+
+	fd = socket(AF_NETLINK, SOCK_RAW, NETLINK_SOCK_DIAG);
+	if (fd < 0) {
+		perror("socket");
+		exit(EXIT_FAILURE);
+	}
+
+	send_req(fd);
+
+	for (;;) {
+		const struct nlmsghdr *h;
+		ssize_t ret;
+
+		ret = recv_resp(fd, buf, sizeof(buf));
+		if (ret == 0)
+			goto done;
+		if (ret < sizeof(*h)) {
+			fprintf(stderr, "short read of %zd bytes\n", ret);
+			exit(EXIT_FAILURE);
+		}
+
+		h = (struct nlmsghdr *)buf;
+
+		while (NLMSG_OK(h, ret)) {
+			if (h->nlmsg_type == NLMSG_DONE)
+				goto done;
+
+			if (h->nlmsg_type == NLMSG_ERROR) {
+				const struct nlmsgerr *err = NLMSG_DATA(h);
+
+				if (h->nlmsg_len < NLMSG_LENGTH(sizeof(*err)))
+					fprintf(stderr, "NLMSG_ERROR\n");
+				else {
+					errno = -err->error;
+					perror("NLMSG_ERROR");
+				}
+
+				exit(EXIT_FAILURE);
+			}
+
+			if (h->nlmsg_type != SOCK_DIAG_BY_FAMILY) {
+				fprintf(stderr, "unexpected nlmsg_type %#x\n",
+					h->nlmsg_type);
+				exit(EXIT_FAILURE);
+			}
+			if (h->nlmsg_len <
+			    NLMSG_LENGTH(sizeof(struct vsock_diag_msg))) {
+				fprintf(stderr, "short vsock_diag_msg\n");
+				exit(EXIT_FAILURE);
+			}
+
+			add_vsock_stat(sockets, NLMSG_DATA(h));
+
+			h = NLMSG_NEXT(h, ret);
+		}
+	}
+
+done:
+	close(fd);
+}
+
+static void free_sock_stat(struct list_head *sockets)
+{
+	struct vsock_stat *st;
+	struct vsock_stat *next;
+
+	list_for_each_entry_safe(st, next, sockets, list)
+		free(st);
+}
+
+static void test_no_sockets(unsigned int peer_cid)
+{
+	LIST_HEAD(sockets);
+
+	read_vsock_stat(&sockets);
+
+	check_no_sockets(&sockets);
+
+	free_sock_stat(&sockets);
+}
+
+static void test_listen_socket_server(unsigned int peer_cid)
+{
+	union {
+		struct sockaddr sa;
+		struct sockaddr_vm svm;
+	} addr = {
+		.svm = {
+			.svm_family = AF_VSOCK,
+			.svm_port = 1234,
+			.svm_cid = VMADDR_CID_ANY,
+		},
+	};
+	LIST_HEAD(sockets);
+	struct vsock_stat *st;
+	int fd;
+
+	fd = socket(AF_VSOCK, SOCK_STREAM, 0);
+
+	if (bind(fd, &addr.sa, sizeof(addr.svm)) < 0) {
+		perror("bind");
+		exit(EXIT_FAILURE);
+	}
+
+	if (listen(fd, 1) < 0) {
+		perror("listen");
+		exit(EXIT_FAILURE);
+	}
+
+	read_vsock_stat(&sockets);
+
+	check_num_sockets(&sockets, 1);
+	st = find_vsock_stat(&sockets, fd);
+	check_socket_state(st, TCP_LISTEN);
+
+	close(fd);
+	free_sock_stat(&sockets);
+}
+
+static void test_connect_client(unsigned int peer_cid)
+{
+	union {
+		struct sockaddr sa;
+		struct sockaddr_vm svm;
+	} addr = {
+		.svm = {
+			.svm_family = AF_VSOCK,
+			.svm_port = 1234,
+			.svm_cid = peer_cid,
+		},
+	};
+	int fd;
+	int ret;
+	LIST_HEAD(sockets);
+	struct vsock_stat *st;
+
+	control_expectln("LISTENING");
+
+	fd = socket(AF_VSOCK, SOCK_STREAM, 0);
+
+	timeout_begin(TIMEOUT);
+	do {
+		ret = connect(fd, &addr.sa, sizeof(addr.svm));
+		timeout_check("connect");
+	} while (ret < 0 && errno == EINTR);
+	timeout_end();
+
+	if (ret < 0) {
+		perror("connect");
+		exit(EXIT_FAILURE);
+	}
+
+	read_vsock_stat(&sockets);
+
+	check_num_sockets(&sockets, 1);
+	st = find_vsock_stat(&sockets, fd);
+	check_socket_state(st, TCP_ESTABLISHED);
+
+	control_expectln("DONE");
+	control_writeln("DONE");
+
+	close(fd);
+	free_sock_stat(&sockets);
+}
+
+static void test_connect_server(unsigned int peer_cid)
+{
+	union {
+		struct sockaddr sa;
+		struct sockaddr_vm svm;
+	} addr = {
+		.svm = {
+			.svm_family = AF_VSOCK,
+			.svm_port = 1234,
+			.svm_cid = VMADDR_CID_ANY,
+		},
+	};
+	union {
+		struct sockaddr sa;
+		struct sockaddr_vm svm;
+	} clientaddr;
+	socklen_t clientaddr_len = sizeof(clientaddr.svm);
+	LIST_HEAD(sockets);
+	struct vsock_stat *st;
+	int fd;
+	int client_fd;
+
+	fd = socket(AF_VSOCK, SOCK_STREAM, 0);
+
+	if (bind(fd, &addr.sa, sizeof(addr.svm)) < 0) {
+		perror("bind");
+		exit(EXIT_FAILURE);
+	}
+
+	if (listen(fd, 1) < 0) {
+		perror("listen");
+		exit(EXIT_FAILURE);
+	}
+
+	control_writeln("LISTENING");
+
+	timeout_begin(TIMEOUT);
+	do {
+		client_fd = accept(fd, &clientaddr.sa, &clientaddr_len);
+		timeout_check("accept");
+	} while (client_fd < 0 && errno == EINTR);
+	timeout_end();
+
+	if (client_fd < 0) {
+		perror("accept");
+		exit(EXIT_FAILURE);
+	}
+	if (clientaddr.sa.sa_family != AF_VSOCK) {
+		fprintf(stderr, "expected AF_VSOCK from accept(2), got %d\n",
+			clientaddr.sa.sa_family);
+		exit(EXIT_FAILURE);
+	}
+	if (clientaddr.svm.svm_cid != peer_cid) {
+		fprintf(stderr, "expected peer CID %u from accept(2), got %u\n",
+			peer_cid, clientaddr.svm.svm_cid);
+		exit(EXIT_FAILURE);
+	}
+
+	read_vsock_stat(&sockets);
+
+	check_num_sockets(&sockets, 2);
+	find_vsock_stat(&sockets, fd);
+	st = find_vsock_stat(&sockets, client_fd);
+	check_socket_state(st, TCP_ESTABLISHED);
+
+	control_writeln("DONE");
+	control_expectln("DONE");
+
+	close(client_fd);
+	close(fd);
+	free_sock_stat(&sockets);
+}
+
+static struct {
+	const char *name;
+	void (*run_client)(unsigned int peer_cid);
+	void (*run_server)(unsigned int peer_cid);
+} test_cases[] = {
+	{
+		.name = "No sockets",
+		.run_server = test_no_sockets,
+	},
+	{
+		.name = "Listen socket",
+		.run_server = test_listen_socket_server,
+	},
+	{
+		.name = "Connect",
+		.run_client = test_connect_client,
+		.run_server = test_connect_server,
+	},
+	{},
+};
+
+static void init_signals(void)
+{
+	struct sigaction act = {
+		.sa_handler = sigalrm,
+	};
+
+	sigaction(SIGALRM, &act, NULL);
+	signal(SIGPIPE, SIG_IGN);
+}
+
+static unsigned int parse_cid(const char *str)
+{
+	char *endptr = NULL;
+	unsigned long int n;
+
+	errno = 0;
+	n = strtoul(str, &endptr, 10);
+	if (errno || *endptr != '\0') {
+		fprintf(stderr, "malformed CID \"%s\"\n", str);
+		exit(EXIT_FAILURE);
+	}
+	return n;
+}
+
+static const char optstring[] = "";
+static const struct option longopts[] = {
+	{
+		.name = "control-host",
+		.has_arg = required_argument,
+		.val = 'H',
+	},
+	{
+		.name = "control-port",
+		.has_arg = required_argument,
+		.val = 'P',
+	},
+	{
+		.name = "mode",
+		.has_arg = required_argument,
+		.val = 'm',
+	},
+	{
+		.name = "peer-cid",
+		.has_arg = required_argument,
+		.val = 'p',
+	},
+	{
+		.name = "help",
+		.has_arg = no_argument,
+		.val = '?',
+	},
+	{},
+};
+
+static void usage(void)
+{
+	fprintf(stderr, "Usage: vsock_diag_test [--help] [--control-host=<host>] --control-port=<port> --mode=client|server --peer-cid=<cid>\n"
+		"\n"
+		"  Server: vsock_diag_test --control-port=1234 --mode=server --peer-cid=3\n"
+		"  Client: vsock_diag_test --control-host=192.168.0.1 --control-port=1234 --mode=client --peer-cid=2\n"
+		"\n"
+		"Run vsock_diag.ko tests.  Must be launched in both\n"
+		"guest and host.  One side must use --mode=client and\n"
+		"the other side must use --mode=server.\n"
+		"\n"
+		"A TCP control socket connection is used to coordinate tests\n"
+		"between the client and the server.  The server requires a\n"
+		"listen address and the client requires an address to\n"
+		"connect to.\n"
+		"\n"
+		"The CID of the other side must be given with --peer-cid=<cid>.\n");
+	exit(EXIT_FAILURE);
+}
+
+int main(int argc, char **argv)
+{
+	const char *control_host = NULL;
+	const char *control_port = NULL;
+	int mode = TEST_MODE_UNSET;
+	unsigned int peer_cid = VMADDR_CID_ANY;
+	int i;
+
+	init_signals();
+
+	for (;;) {
+		int opt = getopt_long(argc, argv, optstring, longopts, NULL);
+
+		if (opt == -1)
+			break;
+
+		switch (opt) {
+		case 'H':
+			control_host = optarg;
+			break;
+		case 'm':
+			if (strcmp(optarg, "client") == 0)
+				mode = TEST_MODE_CLIENT;
+			else if (strcmp(optarg, "server") == 0)
+				mode = TEST_MODE_SERVER;
+			else {
+				fprintf(stderr, "--mode must be \"client\" or \"server\"\n");
+				return EXIT_FAILURE;
+			}
+			break;
+		case 'p':
+			peer_cid = parse_cid(optarg);
+			break;
+		case 'P':
+			control_port = optarg;
+			break;
+		case '?':
+		default:
+			usage();
+		}
+	}
+
+	if (!control_port)
+		usage();
+	if (mode == TEST_MODE_UNSET)
+		usage();
+	if (peer_cid == VMADDR_CID_ANY)
+		usage();
+
+	if (!control_host) {
+		if (mode != TEST_MODE_SERVER)
+			usage();
+		control_host = "0.0.0.0";
+	}
+
+	control_init(control_host, control_port, mode == TEST_MODE_SERVER);
+
+	for (i = 0; test_cases[i].name; i++) {
+		void (*run)(unsigned int peer_cid);
+
+		printf("%s...", test_cases[i].name);
+		fflush(stdout);
+
+		if (mode == TEST_MODE_CLIENT)
+			run = test_cases[i].run_client;
+		else
+			run = test_cases[i].run_server;
+
+		if (run)
+			run(peer_cid);
+
+		printf("ok\n");
+	}
+
+	control_cleanup();
+	return EXIT_SUCCESS;
+}
diff --git a/tools/testing/vsock/.gitignore b/tools/testing/vsock/.gitignore
new file mode 100644
index 000000000000..dc5f11faf530
--- /dev/null
+++ b/tools/testing/vsock/.gitignore
@@ -0,0 +1,2 @@
+*.d
+vsock_diag_test
diff --git a/tools/testing/vsock/README b/tools/testing/vsock/README
new file mode 100644
index 000000000000..2cc6d7302db6
--- /dev/null
+++ b/tools/testing/vsock/README
@@ -0,0 +1,36 @@
+AF_VSOCK test suite
+-------------------
+These tests exercise net/vmw_vsock/ host<->guest sockets for VMware, KVM, and
+Hyper-V.
+
+The following tests are available:
+
+  * vsock_diag_test - vsock_diag.ko module for listing open sockets
+
+The following prerequisite steps are not automated and must be performed prior
+to running tests:
+
+1. Build the kernel and these tests.
+2. Install the kernel and tests on the host.
+3. Install the kernel and tests inside the guest.
+4. Boot the guest and ensure that the AF_VSOCK transport is enabled.
+
+Invoke test binaries in both directions as follows:
+
+  # host=server, guest=client
+  (host)# $TEST_BINARY --mode=server \
+                       --control-port=1234 \
+                       --peer-cid=3
+  (guest)# $TEST_BINARY --mode=client \
+                        --control-host=$HOST_IP \
+                        --control-port=1234 \
+                        --peer-cid=2
+
+  # host=client, guest=server
+  (guest)# $TEST_BINARY --mode=server \
+                        --control-port=1234 \
+                        --peer-cid=2
+  (host)# $TEST_BINARY --mode=client \
+                       --control-port=$GUEST_IP \
+                       --control-port=1234 \
+                       --peer-cid=3
-- 
2.13.6
