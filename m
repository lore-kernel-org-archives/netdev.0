From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 5/5] bpf: add sample usages for persistent maps/progs
Date: Thu, 29 Oct 2015 14:58:10 +0100
Message-ID: <b6d3d5d8c3e54dd49e6bef7e3cac25eed9405afc.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a couple of stand-alone examples on how BPF_OBJ_PIN
and BPF_OBJ_GET commands can be used.

Example with maps:

  # ./fds_example -F /sys/fs/bpf/m -P -m -k 1 -v 42
  bpf: map fd:3 (Success)
  bpf: pin ret:(0,Success)
  bpf: fd:3 u->(1:42) ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/m -G -m -k 1
  bpf: get fd:3 (Success)
  bpf: fd:3 l->(1):42 ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/m -G -m -k 1 -v 24
  bpf: get fd:3 (Success)
  bpf: fd:3 u->(1:24) ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/m -G -m -k 1
  bpf: get fd:3 (Success)
  bpf: fd:3 l->(1):24 ret:(0,Success)

  # ./fds_example -F /sys/fs/bpf/m2 -P -m
  bpf: map fd:3 (Success)
  bpf: pin ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/m2 -G -m -k 1
  bpf: get fd:3 (Success)
  bpf: fd:3 l->(1):0 ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/m2 -G -m
  bpf: get fd:3 (Success)

Example with progs:

  # ./fds_example -F /sys/fs/bpf/p -P -p
  bpf: prog fd:3 (Success)
  bpf: pin ret:(0,Success)
  bpf sock:4 <- fd:3 attached ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/p -G -p
  bpf: get fd:3 (Success)
  bpf: sock:4 <- fd:3 attached ret:(0,Success)

  # ./fds_example -F /sys/fs/bpf/p2 -P -p -o ./sockex1_kern.o
  bpf: prog fd:5 (Success)
  bpf: pin ret:(0,Success)
  bpf: sock:3 <- fd:5 attached ret:(0,Success)
  # ./fds_example -F /sys/fs/bpf/p2 -G -p
  bpf: get fd:3 (Success)
  bpf: sock:4 <- fd:3 attached ret:(0,Success)

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile      |   3 +
 samples/bpf/fds_example.c | 183 ++++++++++++++++++++++++++++++++++++++++++++++
 samples/bpf/libbpf.c      |  19 +++++
 samples/bpf/libbpf.h      |   3 +
 4 files changed, 208 insertions(+)
 create mode 100644 samples/bpf/fds_example.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index b305145..79b4596 100644
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
@@ -19,6 +20,7 @@ hostprogs-y += lathist
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
+fds_example-objs := bpf_load.o libbpf.o fds_example.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
 sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
@@ -49,6 +51,7 @@ always += lathist_kern.o
 HOSTCFLAGS += -I$(objtree)/usr/include
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
+HOSTLOADLIBES_fds_example += -lelf
 HOSTLOADLIBES_sockex1 += -lelf
 HOSTLOADLIBES_sockex2 += -lelf
 HOSTLOADLIBES_sockex3 += -lelf
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
new file mode 100644
index 0000000..e2fd16c
--- /dev/null
+++ b/samples/bpf/fds_example.c
@@ -0,0 +1,183 @@
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
+
+#include "bpf_load.h"
+#include "libbpf.h"
+
+#define BPF_F_PIN	(1 << 0)
+#define BPF_F_GET	(1 << 1)
+#define BPF_F_PIN_GET	(BPF_F_PIN | BPF_F_GET)
+
+#define BPF_F_KEY	(1 << 2)
+#define BPF_F_VAL	(1 << 3)
+#define BPF_F_KEY_VAL	(BPF_F_KEY | BPF_F_VAL)
+
+#define BPF_M_UNSPEC	0
+#define BPF_M_MAP	1
+#define BPF_M_PROG	2
+
+static void usage(void)
+{
+	printf("Usage: fds_example [...]\n");
+	printf("       -F <file>   File to pin/get object\n");
+	printf("       -P          |- pin object\n");
+	printf("       -G          `- get object\n");
+	printf("       -m          eBPF map mode\n");
+	printf("       -k <key>    |- map key\n");
+	printf("       -v <value>  `- map value\n");
+	printf("       -p          eBPF prog mode\n");
+	printf("       -o <object> `- object file\n");
+	printf("       -h          Display this help.\n");
+}
+
+static int bpf_map_create(void)
+{
+	return bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(uint32_t),
+			      sizeof(uint32_t), 1024);
+}
+
+static int bpf_prog_create(const char *object)
+{
+	static const struct bpf_insn insns[] = {
+		BPF_MOV64_IMM(BPF_REG_0, 1),
+		BPF_EXIT_INSN(),
+	};
+
+	if (object) {
+		assert(!load_bpf_file((char *)object));
+		return prog_fd[0];
+	} else {
+		return bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
+				     insns, sizeof(insns), "GPL", 0);
+	}
+}
+
+static int bpf_do_map(const char *file, uint32_t flags, uint32_t key,
+		      uint32_t value)
+{
+	int fd, ret;
+
+	if (flags & BPF_F_PIN) {
+		fd = bpf_map_create();
+		printf("bpf: map fd:%d (%s)\n", fd, strerror(errno));
+		assert(fd > 0);
+
+		ret = bpf_obj_pin(fd, file);
+		printf("bpf: pin ret:(%d,%s)\n", ret, strerror(errno));
+		assert(ret == 0);
+	} else {
+		fd = bpf_obj_get(file);
+		printf("bpf: get fd:%d (%s)\n", fd, strerror(errno));
+		assert(fd > 0);
+	}
+
+	if ((flags & BPF_F_KEY_VAL) == BPF_F_KEY_VAL) {
+		ret = bpf_update_elem(fd, &key, &value, 0);
+		printf("bpf: fd:%d u->(%u:%u) ret:(%d,%s)\n", fd, key, value,
+		       ret, strerror(errno));
+		assert(ret == 0);
+	} else if (flags & BPF_F_KEY) {
+		ret = bpf_lookup_elem(fd, &key, &value);
+		printf("bpf: fd:%d l->(%u):%u ret:(%d,%s)\n", fd, key, value,
+		       ret, strerror(errno));
+		assert(ret == 0);
+	}
+
+	return 0;
+}
+
+static int bpf_do_prog(const char *file, uint32_t flags, const char *object)
+{
+	int fd, sock, ret;
+
+	if (flags & BPF_F_PIN) {
+		fd = bpf_prog_create(object);
+		printf("bpf: prog fd:%d (%s)\n", fd, strerror(errno));
+		assert(fd > 0);
+
+		ret = bpf_obj_pin(fd, file);
+		printf("bpf: pin ret:(%d,%s)\n", ret, strerror(errno));
+		assert(ret == 0);
+	} else {
+		fd = bpf_obj_get(file);
+		printf("bpf: get fd:%d (%s)\n", fd, strerror(errno));
+		assert(fd > 0);
+	}
+
+	sock = open_raw_sock("lo");
+	assert(sock > 0);
+
+	ret = setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &fd, sizeof(fd));
+	printf("bpf: sock:%d <- fd:%d attached ret:(%d,%s)\n", sock, fd,
+	       ret, strerror(errno));
+	assert(ret == 0);
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	const char *file = NULL, *object = NULL;
+	uint32_t key = 0, value = 0, flags = 0;
+	int opt, mode = BPF_M_UNSPEC;
+
+	while ((opt = getopt(argc, argv, "F:PGmk:v:po:")) != -1) {
+		switch (opt) {
+		/* General args */
+		case 'F':
+			file = optarg;
+			break;
+		case 'P':
+			flags |= BPF_F_PIN;
+			break;
+		case 'G':
+			flags |= BPF_F_GET;
+			break;
+		/* Map-related args */
+		case 'm':
+			mode = BPF_M_MAP;
+			break;
+		case 'k':
+			key = strtoul(optarg, NULL, 0);
+			flags |= BPF_F_KEY;
+			break;
+		case 'v':
+			value = strtoul(optarg, NULL, 0);
+			flags |= BPF_F_VAL;
+			break;
+		/* Prog-related args */
+		case 'p':
+			mode = BPF_M_PROG;
+			break;
+		case 'o':
+			object = optarg;
+			break;
+		default:
+			goto out;
+		}
+	}
+
+	if (!(flags & BPF_F_PIN_GET) || !file)
+		goto out;
+
+	switch (mode) {
+	case BPF_M_MAP:
+		return bpf_do_map(file, flags, key, value);
+	case BPF_M_PROG:
+		return bpf_do_prog(file, flags, object);
+	}
+out:
+	usage();
+	return -1;
+}
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 7e1efa7..65a8d48 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -103,6 +103,25 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
+int bpf_obj_pin(int fd, const char *pathname)
+{
+	union bpf_attr attr = {
+		.pathname	= ptr_to_u64((void *)pathname),
+		.bpf_fd		= fd,
+	};
+
+	return syscall(__NR_bpf, BPF_OBJ_PIN, &attr, sizeof(attr));
+}
+
+int bpf_obj_get(const char *pathname)
+{
+	union bpf_attr attr = {
+		.pathname	= ptr_to_u64((void *)pathname),
+	};
+
+	return syscall(__NR_bpf, BPF_OBJ_GET, &attr, sizeof(attr));
+}
+
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index b7f63c70..014aacf 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -15,6 +15,9 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
 		  const char *license, int kern_version);
 
+int bpf_obj_pin(int fd, const char *pathname);
+int bpf_obj_get(const char *pathname);
+
 #define LOG_BUF_SIZE 65536
 extern char bpf_log_buf[LOG_BUF_SIZE];
 
-- 
1.9.3
