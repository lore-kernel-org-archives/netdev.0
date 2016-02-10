From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next v3 7/7] soreuseport: BPF selection functional test for TCP
Date: Tue,  9 Feb 2016 19:19:02 -0500
Message-ID: <1455063542-18227-8-git-send-email-kraigatgoog@gmail.com>
References: <1455063542-18227-1-git-send-email-kraigatgoog@gmail.com>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f47.google.com ([209.85.192.47]:34744 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235AbcBJATT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2016 19:19:19 -0500
Received: by mail-qg0-f47.google.com with SMTP id b67so3017735qgb.1
        for <netdev@vger.kernel.org>; Tue, 09 Feb 2016 16:19:19 -0800 (PST)
In-Reply-To: <1455063542-18227-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

Unfortunately the existing test relied on packet payload in order to
map incoming packets to sockets.  In order to get this to work with TCP,
TCP_FASTOPEN needed to be used.

Since the fast open path is slightly different than the standard TCP path,
I created a second test which sends to reuseport group members based
on receiving cpu core id.  This will probably serve as a better
real-world example use as well.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 tools/testing/selftests/net/.gitignore          |   1 +
 tools/testing/selftests/net/Makefile            |   2 +-
 tools/testing/selftests/net/reuseport_bpf.c     | 117 ++++++++++-
 tools/testing/selftests/net/reuseport_bpf_cpu.c | 258 ++++++++++++++++++++++++
 4 files changed, 370 insertions(+), 8 deletions(-)
 create mode 100644 tools/testing/selftests/net/reuseport_bpf_cpu.c

diff --git a/tools/testing/selftests/net/.gitignore b/tools/testing/selftests/net/.gitignore
index 6fb23366b258..69bb3fc38fb2 100644
--- a/tools/testing/selftests/net/.gitignore
+++ b/tools/testing/selftests/net/.gitignore
@@ -2,3 +2,4 @@ socket
 psock_fanout
 psock_tpacket
 reuseport_bpf
+reuseport_bpf_cpu
diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index 41449b5ad0a9..c658792d47b4 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -4,7 +4,7 @@ CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf
+NET_PROGS = socket psock_fanout psock_tpacket reuseport_bpf reuseport_bpf_cpu
 
 all: $(NET_PROGS)
 %: %.c
diff --git a/tools/testing/selftests/net/reuseport_bpf.c b/tools/testing/selftests/net/reuseport_bpf.c
index bec1b5dd2530..96ba386b1b7b 100644
--- a/tools/testing/selftests/net/reuseport_bpf.c
+++ b/tools/testing/selftests/net/reuseport_bpf.c
@@ -9,10 +9,12 @@
 
 #include <errno.h>
 #include <error.h>
+#include <fcntl.h>
 #include <linux/bpf.h>
 #include <linux/filter.h>
 #include <linux/unistd.h>
 #include <netinet/in.h>
+#include <netinet/tcp.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
@@ -169,9 +171,15 @@ static void build_recv_group(const struct test_params p, int fd[], uint16_t mod,
 		if (bind(fd[i], addr, sockaddr_size()))
 			error(1, errno, "failed to bind recv socket %d", i);
 
-		if (p.protocol == SOCK_STREAM)
+		if (p.protocol == SOCK_STREAM) {
+			opt = 4;
+			if (setsockopt(fd[i], SOL_TCP, TCP_FASTOPEN, &opt,
+				       sizeof(opt)))
+				error(1, errno,
+				      "failed to set TCP_FASTOPEN on %d", i);
 			if (listen(fd[i], p.recv_socks * 10))
 				error(1, errno, "failed to listen on socket");
+		}
 	}
 	free(addr);
 }
@@ -189,10 +197,8 @@ static void send_from(struct test_params p, uint16_t sport, char *buf,
 
 	if (bind(fd, saddr, sockaddr_size()))
 		error(1, errno, "failed to bind send socket");
-	if (connect(fd, daddr, sockaddr_size()))
-		error(1, errno, "failed to connect");
 
-	if (send(fd, buf, len, 0) < 0)
+	if (sendto(fd, buf, len, MSG_FASTOPEN, daddr, sockaddr_size()) < 0)
 		error(1, errno, "failed to send message");
 
 	close(fd);
@@ -260,7 +266,7 @@ static void test_recv_order(const struct test_params p, int fd[], int mod)
 	}
 }
 
-static void test_reuseport_ebpf(const struct test_params p)
+static void test_reuseport_ebpf(struct test_params p)
 {
 	int i, fd[p.recv_socks];
 
@@ -268,6 +274,7 @@ static void test_reuseport_ebpf(const struct test_params p)
 	build_recv_group(p, fd, p.recv_socks, attach_ebpf);
 	test_recv_order(p, fd, p.recv_socks);
 
+	p.send_port_min += p.recv_socks * 2;
 	fprintf(stderr, "Reprograming, testing mod %zd...\n", p.recv_socks / 2);
 	attach_ebpf(fd[0], p.recv_socks / 2);
 	test_recv_order(p, fd, p.recv_socks / 2);
@@ -276,7 +283,7 @@ static void test_reuseport_ebpf(const struct test_params p)
 		close(fd[i]);
 }
 
-static void test_reuseport_cbpf(const struct test_params p)
+static void test_reuseport_cbpf(struct test_params p)
 {
 	int i, fd[p.recv_socks];
 
@@ -284,6 +291,7 @@ static void test_reuseport_cbpf(const struct test_params p)
 	build_recv_group(p, fd, p.recv_socks, attach_cbpf);
 	test_recv_order(p, fd, p.recv_socks);
 
+	p.send_port_min += p.recv_socks * 2;
 	fprintf(stderr, "Reprograming, testing mod %zd...\n", p.recv_socks / 2);
 	attach_cbpf(fd[0], p.recv_socks / 2);
 	test_recv_order(p, fd, p.recv_socks / 2);
@@ -377,7 +385,7 @@ static void test_filter_no_reuseport(const struct test_params p)
 
 static void test_filter_without_bind(void)
 {
-	int fd1, fd2;
+	int fd1, fd2, opt = 1;
 
 	fprintf(stderr, "Testing filter add without bind...\n");
 	fd1 = socket(AF_INET, SOCK_DGRAM, 0);
@@ -386,6 +394,10 @@ static void test_filter_without_bind(void)
 	fd2 = socket(AF_INET, SOCK_DGRAM, 0);
 	if (fd2 < 0)
 		error(1, errno, "failed to create socket 2");
+	if (setsockopt(fd1, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt)))
+		error(1, errno, "failed to set SO_REUSEPORT on socket 1");
+	if (setsockopt(fd2, SOL_SOCKET, SO_REUSEPORT, &opt, sizeof(opt)))
+		error(1, errno, "failed to set SO_REUSEPORT on socket 2");
 
 	attach_ebpf(fd1, 10);
 	attach_cbpf(fd2, 10);
@@ -394,6 +406,32 @@ static void test_filter_without_bind(void)
 	close(fd2);
 }
 
+void enable_fastopen(void)
+{
+	int fd = open("/proc/sys/net/ipv4/tcp_fastopen", 0);
+	int rw_mask = 3;  /* bit 1: client side; bit-2 server side */
+	int val, size;
+	char buf[16];
+
+	if (fd < 0)
+		error(1, errno, "Unable to open tcp_fastopen sysctl");
+	if (read(fd, buf, sizeof(buf)) <= 0)
+		error(1, errno, "Unable to read tcp_fastopen sysctl");
+	val = atoi(buf);
+	close(fd);
+
+	if ((val & rw_mask) != rw_mask) {
+		fd = open("/proc/sys/net/ipv4/tcp_fastopen", O_RDWR);
+		if (fd < 0)
+			error(1, errno,
+			      "Unable to open tcp_fastopen sysctl for writing");
+		val |= rw_mask;
+		size = snprintf(buf, 16, "%d", val);
+		if (write(fd, buf, size) <= 0)
+			error(1, errno, "Unable to write tcp_fastopen sysctl");
+		close(fd);
+	}
+}
 
 int main(void)
 {
@@ -506,6 +544,71 @@ int main(void)
 		.recv_port = 8007,
 		.send_port_min = 9100});
 
+	/* TCP fastopen is required for the TCP tests */
+	enable_fastopen();
+	fprintf(stderr, "---- IPv4 TCP ----\n");
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET,
+		.send_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8008,
+		.send_port_min = 9120});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET,
+		.send_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8009,
+		.send_port_min = 9160});
+	test_extra_filter((struct test_params) {
+		.recv_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_port = 8010});
+	test_filter_no_reuseport((struct test_params) {
+		.recv_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_port = 8011});
+
+	fprintf(stderr, "---- IPv6 TCP ----\n");
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET6,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8012,
+		.send_port_min = 9200});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET6,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8013,
+		.send_port_min = 9240});
+	test_extra_filter((struct test_params) {
+		.recv_family = AF_INET6,
+		.protocol = SOCK_STREAM,
+		.recv_port = 8014});
+	test_filter_no_reuseport((struct test_params) {
+		.recv_family = AF_INET6,
+		.protocol = SOCK_STREAM,
+		.recv_port = 8015});
+
+	fprintf(stderr, "---- IPv6 TCP w/ mapped IPv4 ----\n");
+	test_reuseport_ebpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8016,
+		.send_port_min = 9320});
+	test_reuseport_cbpf((struct test_params) {
+		.recv_family = AF_INET6,
+		.send_family = AF_INET,
+		.protocol = SOCK_STREAM,
+		.recv_socks = 10,
+		.recv_port = 8017,
+		.send_port_min = 9360});
 
 	test_filter_without_bind();
 
diff --git a/tools/testing/selftests/net/reuseport_bpf_cpu.c b/tools/testing/selftests/net/reuseport_bpf_cpu.c
new file mode 100644
index 000000000000..b23d6f54de7b
--- /dev/null
+++ b/tools/testing/selftests/net/reuseport_bpf_cpu.c
@@ -0,0 +1,258 @@
+/*
+ * Test functionality of BPF filters with SO_REUSEPORT.  This program creates
+ * an SO_REUSEPORT receiver group containing one socket per CPU core. It then
+ * creates a BPF program that will select a socket from this group based
+ * on the core id that receives the packet.  The sending code artificially
+ * moves itself to run on different core ids and sends one message from
+ * each core.  Since these packets are delivered over loopback, they should
+ * arrive on the same core that sent them.  The receiving code then ensures
+ * that the packet was received on the socket for the corresponding core id.
+ * This entire process is done for several different core id permutations
+ * and for each IPv4/IPv6 and TCP/UDP combination.
+ */
+
+#define _GNU_SOURCE
+
+#include <arpa/inet.h>
+#include <errno.h>
+#include <error.h>
+#include <linux/filter.h>
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
+	struct sock_filter code[] = {
+		/* A = raw_smp_processor_id() */
+		{ BPF_LD  | BPF_W | BPF_ABS, 0, 0, SKF_AD_OFF + SKF_AD_CPU },
+		/* return A */
+		{ BPF_RET | BPF_A, 0, 0, 0 },
+	};
+	struct sock_fprog p = {
+		.len = 2,
+		.filter = code,
+	};
+
+	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_REUSEPORT_CBPF, &p, sizeof(p)))
+		error(1, errno, "failed to set SO_ATTACH_REUSEPORT_CBPF");
+}
+
+static void send_from_cpu(int cpu_id, int family, int proto)
+{
+	struct sockaddr_storage saddr, daddr;
+	struct sockaddr_in  *saddr4, *daddr4;
+	struct sockaddr_in6 *saddr6, *daddr6;
+	cpu_set_t cpu_set;
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
+	memset(&cpu_set, 0, sizeof(cpu_set));
+	CPU_SET(cpu_id, &cpu_set);
+	if (sched_setaffinity(0, sizeof(cpu_set), &cpu_set) < 0)
+		error(1, errno, "failed to pin to cpu");
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
+void receive_on_cpu(int *rcv_fd, int len, int epfd, int cpu_id, int proto)
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
+	fprintf(stderr, "send cpu %d, receive socket %d\n", cpu_id, i);
+	if (cpu_id != i)
+		error(1, 0, "cpu id/receive socket mismatch");
+}
+
+static void test(int *rcv_fd, int len, int family, int proto)
+{
+	struct epoll_event ev;
+	int epfd, cpu;
+
+	build_rcv_group(rcv_fd, len, family, proto);
+	attach_bpf(rcv_fd[0]);
+
+	epfd = epoll_create(1);
+	if (epfd < 0)
+		error(1, errno, "failed to create epoll");
+	for (cpu = 0; cpu < len; ++cpu) {
+		ev.events = EPOLLIN;
+		ev.data.fd = rcv_fd[cpu];
+		if (epoll_ctl(epfd, EPOLL_CTL_ADD, rcv_fd[cpu], &ev))
+			error(1, errno, "failed to register sock epoll");
+	}
+
+	/* Forward iterate */
+	for (cpu = 0; cpu < len; ++cpu) {
+		send_from_cpu(cpu, family, proto);
+		receive_on_cpu(rcv_fd, len, epfd, cpu, proto);
+	}
+
+	/* Reverse iterate */
+	for (cpu = len - 1; cpu >= 0; --cpu) {
+		send_from_cpu(cpu, family, proto);
+		receive_on_cpu(rcv_fd, len, epfd, cpu, proto);
+	}
+
+	/* Even cores */
+	for (cpu = 0; cpu < len; cpu += 2) {
+		send_from_cpu(cpu, family, proto);
+		receive_on_cpu(rcv_fd, len, epfd, cpu, proto);
+	}
+
+	/* Odd cores */
+	for (cpu = 1; cpu < len; cpu += 2) {
+		send_from_cpu(cpu, family, proto);
+		receive_on_cpu(rcv_fd, len, epfd, cpu, proto);
+	}
+
+	close(epfd);
+	for (cpu = 0; cpu < len; ++cpu)
+		close(rcv_fd[cpu]);
+}
+
+int main(void)
+{
+	int *rcv_fd, cpus;
+
+	cpus = sysconf(_SC_NPROCESSORS_ONLN);
+	if (cpus <= 0)
+		error(1, errno, "failed counting cpus");
+
+	rcv_fd = calloc(cpus, sizeof(int));
+	if (!rcv_fd)
+		error(1, 0, "failed to allocate array");
+
+	fprintf(stderr, "---- IPv4 UDP ----\n");
+	test(rcv_fd, cpus, AF_INET, SOCK_DGRAM);
+
+	fprintf(stderr, "---- IPv6 UDP ----\n");
+	test(rcv_fd, cpus, AF_INET6, SOCK_DGRAM);
+
+	fprintf(stderr, "---- IPv4 TCP ----\n");
+	test(rcv_fd, cpus, AF_INET, SOCK_STREAM);
+
+	fprintf(stderr, "---- IPv6 TCP ----\n");
+	test(rcv_fd, cpus, AF_INET6, SOCK_STREAM);
+
+	free(rcv_fd);
+
+	fprintf(stderr, "SUCCESS\n");
+	return 0;
+}
-- 
2.7.0.rc3.207.g0ac5344
