From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 2/2] reuseport, bpf: add test case for bpf_get_numa_node_id
Date: Fri, 21 Oct 2016 12:46:34 +0200
Message-ID: <a3bb5be5fdab7b8415adcad984442181196609a7.1477043973.git.daniel@iogearbox.net>
References: <cover.1477043972.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, edumazet@google.com,
        netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33308 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752203AbcJUKqo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:46:44 -0400
In-Reply-To: <cover.1477043972.git.daniel@iogearbox.net>
In-Reply-To: <cover.1477043972.git.daniel@iogearbox.net>
References: <cover.1477043972.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The test case is very similar to reuseport_bpf_cpu, only that here
we select socket members based on current numa node id.

  # numactl -H
  available: 2 nodes (0-1)
  node 0 cpus: 0 1 2 3 4 5 12 13 14 15 16 17
  node 0 size: 128867 MB
  node 0 free: 120080 MB
  node 1 cpus: 6 7 8 9 10 11 18 19 20 21 22 23
  node 1 size: 96765 MB
  node 1 free: 87504 MB
  node distances:
  node   0   1
    0:  10  20
    1:  20  10

  # ./reuseport_bpf_numa
  ---- IPv4 UDP ----
  send node 0, receive socket 0
  send node 1, receive socket 1
  send node 1, receive socket 1
  send node 0, receive socket 0
  ---- IPv6 UDP ----
  send node 0, receive socket 0
  send node 1, receive socket 1
  send node 1, receive socket 1
  send node 0, receive socket 0
  ---- IPv4 TCP ----
  send node 0, receive socket 0
  send node 1, receive socket 1
  send node 1, receive socket 1
  send node 0, receive socket 0
  ---- IPv6 TCP ----
  send node 0, receive socket 0
  send node 1, receive socket 1
  send node 1, receive socket 1
  send node 0, receive socket 0
  SUCCESS

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/net/.gitignore           |   1 +
 tools/testing/selftests/net/Makefile             |  11 +-
 tools/testing/selftests/net/reuseport_bpf_numa.c | 255 +++++++++++++++++++++++
 3 files changed, 263 insertions(+), 4 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_bpf_numa.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 0840684..afe109e 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -3,4 +3,5 @@ psock_fanout
 psock_tpacket
 reuseport_bpf
 reuseport_bpf_cpu
+reuseport_bpf_numa
 reuseport_dualstack
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 0e53407..e24e4c8 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -1,14 +1,17 @@
 # Makefile for net selftests
 
-CFLAGS = -Wall -O2 -g
-
+CFLAGS =  -Wall -Wl,--no-as-needed -O2 -g
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf reuseport_bpf_cpu reuseport_dualstack
+NET_PROGS =  socket
+NET_PROGS += psock_fanout psock_tpacket
+NET_PROGS += reuseport_bpf reuseport_bpf_cpu reuseport_bpf_numa
+NET_PROGS += reuseport_dualstack
 
 all: $(NET_PROGS)
+reuseport_bpf_numa: LDFLAGS += -lnuma
 %: %.c
-	$(CC) $(CFLAGS) -o $@ $^
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
 
 TEST_PROGS := run_netsocktests run_afpackettests test_bpf.sh
 TEST_FILES := $(NET_PROGS)
diff --git a/tools/testing/selftests/net/reuseport_bpf_numa.c b/tools/testing/selftests/net/reuseport_bpf_numa.c
new file mode 100644
index 0000000..6f20bc9
--- /dev/null
+++ b/tools/testing/selftests/net/reuseport_bpf_numa.c
@@ -0,0 +1,255 @@
+/*
+ * Test functionality of BPF filters with SO_REUSEPORT. Same test as
+ * in reuseport_bpf_cpu, only as one socket per NUMA node.
+ */
+
+#define _GNU_SOURCE
+
+#include <arpa/inet.h>
+#include <errno.h>
+#include <error.h>
+#include <linux/filter.h>
+#include <linux/bpf.h>
+#include <linux/in.h>
+#include <linux/unistd.h>
+#include <sched.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <sys/epoll.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <unistd.h>
+#include <numa.h>
+
+static const int PORT = 8888;
+
+static void build_rcv_group(int *rcv_fd, size_t len, int family, int proto)
+{
+	struct sockaddr_storage addr;
+	struct sockaddr_in  *addr4;
+	struct sockaddr_in6 *addr6;
+	size_t i;
+	int opt;
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
+	for (i = 0; i < len; ++i) {
+		rcv_fd[i] = socket(family, proto, 0);
+		if (rcv_fd[i] < 0)
+			error(1, errno, "failed to create receive socket");
+
+		opt = 1;
+		if (setsockopt(rcv_fd[i], SOL_SOCKET, SO_REUSEPORT, &opt,
+			       sizeof(opt)))
+			error(1, errno, "failed to set SO_REUSEPORT");
+
+		if (bind(rcv_fd[i], (struct sockaddr *)&addr, sizeof(addr)))
+			error(1, errno, "failed to bind receive socket");
+
+		if (proto == SOCK_STREAM && listen(rcv_fd[i], len * 10))
+			error(1, errno, "failed to listen on receive port");
+	}
+}
+
+static void attach_bpf(int fd)
+{
+	static char bpf_log_buf[65536];
+	static const char bpf_license[] = "";
+
+	int bpf_fd;
+	const struct bpf_insn prog[] = {
+		/* R0 = bpf_get_numa_node_id() */
+		{ BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_numa_node_id },
+		/* return R0 */
+		{ BPF_JMP | BPF_EXIT, 0, 0, 0, 0 }
+	};
+	union bpf_attr attr;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	attr.insn_cnt = sizeof(prog) / sizeof(prog[0]);
+	attr.insns = (unsigned long) &prog;
+	attr.license = (unsigned long) &bpf_license;
+	attr.log_buf = (unsigned long) &bpf_log_buf;
+	attr.log_size = sizeof(bpf_log_buf);
+	attr.log_level = 1;
+
+	bpf_fd = syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
+	if (bpf_fd < 0)
+		error(1, errno, "ebpf error. log:\n%s\n", bpf_log_buf);
+
+	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_REUSEPORT_EBPF, &bpf_fd,
+			sizeof(bpf_fd)))
+		error(1, errno, "failed to set SO_ATTACH_REUSEPORT_EBPF");
+
+	close(bpf_fd);
+}
+
+static void send_from_node(int node_id, int family, int proto)
+{
+	struct sockaddr_storage saddr, daddr;
+	struct sockaddr_in  *saddr4, *daddr4;
+	struct sockaddr_in6 *saddr6, *daddr6;
+	int fd;
+
+	switch (family) {
+	case AF_INET:
+		saddr4 = (struct sockaddr_in *)&saddr;
+		saddr4->sin_family = AF_INET;
+		saddr4->sin_addr.s_addr = htonl(INADDR_ANY);
+		saddr4->sin_port = 0;
+
+		daddr4 = (struct sockaddr_in *)&daddr;
+		daddr4->sin_family = AF_INET;
+		daddr4->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+		daddr4->sin_port = htons(PORT);
+		break;
+	case AF_INET6:
+		saddr6 = (struct sockaddr_in6 *)&saddr;
+		saddr6->sin6_family = AF_INET6;
+		saddr6->sin6_addr = in6addr_any;
+		saddr6->sin6_port = 0;
+
+		daddr6 = (struct sockaddr_in6 *)&daddr;
+		daddr6->sin6_family = AF_INET6;
+		daddr6->sin6_addr = in6addr_loopback;
+		daddr6->sin6_port = htons(PORT);
+		break;
+	default:
+		error(1, 0, "Unsupported family %d", family);
+	}
+
+	if (numa_run_on_node(node_id) < 0)
+		error(1, errno, "failed to pin to node");
+
+	fd = socket(family, proto, 0);
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
+static
+void receive_on_node(int *rcv_fd, int len, int epfd, int node_id, int proto)
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
+	for (i = 0; i < len; ++i)
+		if (ev.data.fd == rcv_fd[i])
+			break;
+	if (i == len)
+		error(1, 0, "failed to find socket");
+	fprintf(stderr, "send node %d, receive socket %d\n", node_id, i);
+	if (node_id != i)
+		error(1, 0, "node id/receive socket mismatch");
+}
+
+static void test(int *rcv_fd, int len, int family, int proto)
+{
+	struct epoll_event ev;
+	int epfd, node;
+
+	build_rcv_group(rcv_fd, len, family, proto);
+	attach_bpf(rcv_fd[0]);
+
+	epfd = epoll_create(1);
+	if (epfd < 0)
+		error(1, errno, "failed to create epoll");
+	for (node = 0; node < len; ++node) {
+		ev.events = EPOLLIN;
+		ev.data.fd = rcv_fd[node];
+		if (epoll_ctl(epfd, EPOLL_CTL_ADD, rcv_fd[node], &ev))
+			error(1, errno, "failed to register sock epoll");
+	}
+
+	/* Forward iterate */
+	for (node = 0; node < len; ++node) {
+		send_from_node(node, family, proto);
+		receive_on_node(rcv_fd, len, epfd, node, proto);
+	}
+
+	/* Reverse iterate */
+	for (node = len - 1; node >= 0; --node) {
+		send_from_node(node, family, proto);
+		receive_on_node(rcv_fd, len, epfd, node, proto);
+	}
+
+	close(epfd);
+	for (node = 0; node < len; ++node)
+		close(rcv_fd[node]);
+}
+
+int main(void)
+{
+	int *rcv_fd, nodes;
+
+	if (numa_available() < 0)
+		error(1, errno, "no numa api support");
+
+	nodes = numa_max_node() + 1;
+
+	rcv_fd = calloc(nodes, sizeof(int));
+	if (!rcv_fd)
+		error(1, 0, "failed to allocate array");
+
+	fprintf(stderr, "---- IPv4 UDP ----\n");
+	test(rcv_fd, nodes, AF_INET, SOCK_DGRAM);
+
+	fprintf(stderr, "---- IPv6 UDP ----\n");
+	test(rcv_fd, nodes, AF_INET6, SOCK_DGRAM);
+
+	fprintf(stderr, "---- IPv4 TCP ----\n");
+	test(rcv_fd, nodes, AF_INET, SOCK_STREAM);
+
+	fprintf(stderr, "---- IPv6 TCP ----\n");
+	test(rcv_fd, nodes, AF_INET6, SOCK_STREAM);
+
+	free(rcv_fd);
+
+	fprintf(stderr, "SUCCESS\n");
+	return 0;
+}
-- 
1.9.3
