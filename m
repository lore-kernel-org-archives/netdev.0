From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] bpf: add sample usages for persistent maps/progs
Date: Fri, 16 Oct 2015 03:09:25 +0200
Message-ID: <a364b734d7a82f088ccae4cc517f1104709c8d34.1444956943.git.daniel@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	tgraf@suug.ch, hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1444956943.git.daniel@iogearbox.net>
In-Reply-To: <cover.1444956943.git.daniel@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a couple of stand-alone examples on how BPF_PIN_FD
and BPF_NEW_FD commands can be used.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile      |   2 +
 samples/bpf/fds_example.c | 224 ++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.c      |  20 +++++
 samples/bpf/libbpf.h      |   3 +
 4 files changed, 249 insertions(+)
 create mode 100644 samples/bpf/fds_example.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 63e7d50..f08a3cf 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -4,6 +4,7 @@ obj- := dummy.o
 # List of programs to build
 hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
+hostprogs-y += fds_example
 hostprogs-y += sockex1
 hostprogs-y += sockex2
 hostprogs-y += sockex3
@@ -18,6 +19,7 @@ hostprogs-y += lathist
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
+fds_example-objs := fds_example.o libbpf.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
new file mode 100644
index 0000000..6f912be
--- /dev/null
+++ b/samples/bpf/fds_example.c
@@ -0,0 +1,224 @@
+#include <linux/unistd.h>
+#include <linux/bpf.h>
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <stdint.h>
+#include <unistd.h>
+#include <string.h>
+#include <assert.h>
+#include <errno.h>
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <sys/xattr.h>
+
+#include <net/ethernet.h>
+#include <arpa/inet.h>
+
+#include "libbpf.h"
+
+static char *fname;
+
+static void test_bpf_pin_fd(int fd)
+{
+	char buff[64];
+	int ret;
+
+	memset(buff, 0, sizeof(buff));
+	ret = bpf_pin_fd(fd, fname);
+	getxattr(fname, "bpf.type", buff, sizeof(buff));
+
+	printf("fd:%d type:%s pinned (%s)\n", fd, buff, strerror(errno));
+	assert(ret == 0);
+}
+
+static int test_bpf_new_fd(void)
+{
+	char buff[64];
+	int fd;
+
+	memset(buff, 0, sizeof(buff));
+	getxattr(fname, "bpf.type", buff, sizeof(buff));
+	fd = bpf_new_fd(fname);
+
+	printf("fd:%d type:%s fetched (%s)\n", fd, buff, strerror(errno));
+	assert(fd > 0);
+
+	return fd;
+}
+
+static int test_bpf_map_create(void)
+{
+	int fd;
+
+	fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(uint32_t),
+			    sizeof(uint32_t), 1024);
+
+	printf("fd:%d created (%s)\n", fd, strerror(errno));
+	assert(fd > 0);
+
+	return fd;
+}
+
+static int test_bpf_map_insert(int fd, uint32_t val)
+{
+	uint32_t key = 123;
+	int ret;
+
+	ret = bpf_update_elem(fd, &key, &val, 0);
+
+	printf("fd:%d wrote (%u, %u)\n", fd, key, val);
+	assert(ret == 0);
+
+	return ret;
+}
+
+static int test_bpf_map_lookup(int fd)
+{
+	uint32_t key = 123, val;
+	int ret;
+
+	ret = bpf_lookup_elem(fd, &key, &val);
+
+	printf("fd:%d read (%u, %u)\n", fd, key, val);
+	assert(ret == 0);
+
+	return ret;
+}
+
+static int bpf_map_test_case_1(void)
+{
+	int fd;
+
+	fd = test_bpf_map_create();
+	test_bpf_pin_fd(fd);
+	test_bpf_map_insert(fd, 456);
+	test_bpf_map_lookup(fd);
+	close(fd);
+
+	return 0;
+}
+
+static int bpf_map_test_case_2(void)
+{
+	int fd;
+
+	fd = test_bpf_new_fd();
+	test_bpf_map_lookup(fd);
+	close(fd);
+
+	return 0;
+}
+
+static int bpf_map_test_case_3(void)
+{
+	int fd1, fd2;
+
+	unlink(fname);
+	fd1 = test_bpf_map_create();
+	test_bpf_pin_fd(fd1);
+	fd2 = test_bpf_new_fd();
+	test_bpf_map_lookup(fd1);
+	test_bpf_map_insert(fd2, 456);
+	test_bpf_map_lookup(fd1);
+	test_bpf_map_lookup(fd2);
+	test_bpf_map_insert(fd1, 789);
+	test_bpf_map_lookup(fd2);
+	close(fd1);
+	close(fd2);
+
+	return 0;
+}
+
+static int test_bpf_prog_create(void)
+{
+	struct bpf_insn insns[] = {
+		BPF_MOV64_IMM(BPF_REG_0, 1),
+		BPF_EXIT_INSN(),
+	};
+	int ret;
+
+	ret = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, insns,
+			    sizeof(insns), "GPL", 0);
+
+	assert(ret > 0);
+	printf("fd:%d created\n", ret);
+
+	return ret;
+}
+
+static int test_bpf_prog_attach(int fd)
+{
+	int sock, ret;
+
+	sock = open_raw_sock("lo");
+	ret = setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &fd, sizeof(fd));
+
+	printf("sock:%d got fd:%d attached\n", sock, fd);
+	assert(ret == 0);
+
+	return ret;
+}
+
+static int bpf_prog_test_case_1(void)
+{
+	int fd;
+
+	fd = test_bpf_prog_create();
+	test_bpf_pin_fd(fd);
+	close(fd);
+
+	return 0;
+}
+
+static int bpf_prog_test_case_2(void)
+{
+	int fd;
+
+	fd = test_bpf_new_fd();
+	test_bpf_prog_attach(fd);
+	close(fd);
+
+	return 0;
+}
+
+static int bpf_prog_test_case_3(void)
+{
+	int fd1, fd2;
+
+	unlink(fname);
+	fd1 = test_bpf_prog_create();
+	test_bpf_pin_fd(fd1);
+	fd2 = test_bpf_new_fd();
+	test_bpf_prog_attach(fd1);
+	test_bpf_prog_attach(fd2);
+	close(fd1);
+	close(fd2);
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	if (argc != 3)
+		return -1;
+
+	fname = argv[2];
+
+	if (!strcmp("map-pin", argv[1]))
+		return bpf_map_test_case_1();
+	if (!strcmp("map-new", argv[1]))
+		return bpf_map_test_case_2();
+	if (!strcmp("map-all", argv[1]))
+		return bpf_map_test_case_3();
+
+	if (!strcmp("prog-pin", argv[1]))
+		return bpf_prog_test_case_1();
+	if (!strcmp("prog-new", argv[1]))
+		return bpf_prog_test_case_2();
+	if (!strcmp("prog-all", argv[1]))
+		return bpf_prog_test_case_3();
+
+	return 0;
+}
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 7e1efa7..dcb7c49 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -103,6 +103,26 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
+int bpf_pin_fd(int fd, const char *pathname)
+{
+	union bpf_attr attr = {
+		.fd = fd,
+		.pathname = ptr_to_u64((void *)pathname),
+	};
+
+	return syscall(__NR_bpf, BPF_PIN_FD, &attr, sizeof(attr));
+}
+
+int bpf_new_fd(const char *pathname)
+{
+	union bpf_attr attr = {
+		.fd = 0,
+		.pathname = ptr_to_u64((void *)pathname),
+	};
+
+	return syscall(__NR_bpf, BPF_NEW_FD, &attr, sizeof(attr));
+}
+
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index b7f63c70..2832fc6 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -15,6 +15,9 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
 		  const char *license, int kern_version);
 
+int bpf_pin_fd(int fd, const char *pathname);
+int bpf_new_fd(const char *pathname);
+
 #define LOG_BUF_SIZE 65536
 extern char bpf_log_buf[LOG_BUF_SIZE];
 
-- 
1.9.3
