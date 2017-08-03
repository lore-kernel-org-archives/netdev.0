From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 6/6] net: sockmap sample program
Date: Thu, 03 Aug 2017 16:38:36 -0700
Message-ID: <20170803233836.12107.77622.stgit@john-Precision-Tower-5810>
References: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net
To: davem@davemloft.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33418 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751884AbdHCXiy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 19:38:54 -0400
Received: by mail-pf0-f195.google.com with SMTP id c65so177485pfl.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 16:38:54 -0700 (PDT)
In-Reply-To: <20170803232443.12107.24752.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This program binds a program to a cgroup and then matches hard
coded IP addresses and adds these to a sockmap.

This will receive messages from the backend and send them to
the client.

     client:X <---> frontend:10000 client:X <---> backend:80

To keep things simple this is only designed for 1:1 connections
using hard coded values. A more complete example would use allow
many backends and clients.

Signed-off-by: John Fastabend <john.fastabend@gmail.com>
---
 samples/sockmap/Makefile                  |   78 ++++++++++++++++
 samples/sockmap/sockmap_kern.c            |  143 +++++++++++++++++++++++++++++
 samples/sockmap/sockmap_user.c            |   84 +++++++++++++++++
 tools/include/uapi/linux/bpf.h            |    1 
 tools/lib/bpf/bpf.c                       |   11 ++
 tools/lib/bpf/bpf.h                       |    4 +
 tools/testing/selftests/bpf/bpf_helpers.h |   12 ++
 7 files changed, 331 insertions(+), 2 deletions(-)
 create mode 100644 samples/sockmap/Makefile
 create mode 100644 samples/sockmap/sockmap_kern.c
 create mode 100644 samples/sockmap/sockmap_user.c

diff --git a/samples/sockmap/Makefile b/samples/sockmap/Makefile
new file mode 100644
index 0000000..9291ab8
--- /dev/null
+++ b/samples/sockmap/Makefile
@@ -0,0 +1,78 @@
+# kbuild trick to avoid linker error. Can be omitted if a module is built.
+obj- := dummy.o
+
+# List of programs to build
+hostprogs-y := sockmap
+
+# Libbpf dependencies
+LIBBPF := ../../tools/lib/bpf/bpf.o
+
+HOSTCFLAGS += -I$(objtree)/usr/include
+HOSTCFLAGS += -I$(srctree)/tools/lib/
+HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
+HOSTCFLAGS += -I$(srctree)/tools/lib/ -I$(srctree)/tools/include
+HOSTCFLAGS += -I$(srctree)/tools/perf
+
+sockmap-objs := ../bpf/bpf_load.o $(LIBBPF) sockmap_user.o
+
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
+always += sockmap_kern.o
+
+HOSTLOADLIBES_sockmap += -lelf -lpthread
+
+# Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
+#  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
+LLC ?= llc
+CLANG ?= clang
+
+# Trick to allow make to be run from this directory
+all:
+	$(MAKE) -C ../../ $(CURDIR)/
+
+clean:
+	$(MAKE) -C ../../ M=$(CURDIR) clean
+	@rm -f *~
+
+$(obj)/syscall_nrs.s:	$(src)/syscall_nrs.c
+	$(call if_changed_dep,cc_s_c)
+
+$(obj)/syscall_nrs.h:	$(obj)/syscall_nrs.s FORCE
+	$(call filechk,offsets,__SYSCALL_NRS_H__)
+
+clean-files += syscall_nrs.h
+
+FORCE:
+
+
+# Verify LLVM compiler tools are available and bpf target is supported by llc
+.PHONY: verify_cmds verify_target_bpf $(CLANG) $(LLC)
+
+verify_cmds: $(CLANG) $(LLC)
+	@for TOOL in $^ ; do \
+		if ! (which -- "$${TOOL}" > /dev/null 2>&1); then \
+			echo "*** ERROR: Cannot find LLVM tool $${TOOL}" ;\
+			exit 1; \
+		else true; fi; \
+	done
+
+verify_target_bpf: verify_cmds
+	@if ! (${LLC} -march=bpf -mattr=help > /dev/null 2>&1); then \
+		echo "*** ERROR: LLVM (${LLC}) does not support 'bpf' target" ;\
+		echo "   NOTICE: LLVM version >= 3.7.1 required" ;\
+		exit 2; \
+	else true; fi
+
+$(src)/*.c: verify_target_bpf
+
+# asm/sysreg.h - inline assembly used by it is incompatible with llvm.
+# But, there is no easy way to fix it, so just exclude it since it is
+# useless for BPF samples.
+$(obj)/%.o: $(src)/%.c
+	$(CLANG) $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) -I$(obj) \
+		-D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
+		-Wno-compare-distinct-pointer-types \
+		-Wno-gnu-variable-sized-type-not-at-end \
+		-Wno-address-of-packed-member -Wno-tautological-compare \
+		-Wno-unknown-warning-option \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
diff --git a/samples/sockmap/sockmap_kern.c b/samples/sockmap/sockmap_kern.c
new file mode 100644
index 0000000..07dea99
--- /dev/null
+++ b/samples/sockmap/sockmap_kern.c
@@ -0,0 +1,143 @@
+#include <uapi/linux/bpf.h>
+#include <uapi/linux/if_ether.h>
+#include <uapi/linux/if_packet.h>
+#include <uapi/linux/ip.h>
+#include "../../tools/testing/selftests/bpf/bpf_helpers.h"
+#include "../../tools/testing/selftests/bpf/bpf_endian.h"
+
+#define bpf_printk(fmt, ...)					\
+({								\
+	       char ____fmt[] = fmt;				\
+	       bpf_trace_printk(____fmt, sizeof(____fmt),	\
+				##__VA_ARGS__);			\
+})
+
+struct bpf_map_def SEC("maps") sock_map = {
+	.type = BPF_MAP_TYPE_SOCKMAP,
+	.key_size = sizeof(int),
+	.value_size = sizeof(int),
+	.max_entries = 20,
+};
+
+struct bpf_map_def SEC("maps") reply_port = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(int),
+	.value_size = sizeof(int),
+	.max_entries = 1,
+};
+
+SEC("socket1")
+int bpf_prog1(struct __sk_buff *skb)
+{
+	return skb->len;
+}
+
+SEC("socket2")
+int bpf_prog2(struct __sk_buff *skb)
+{
+	int ret = 0, loc = 0, *l, lp;
+	__u32 local_port = bpf_skb_get_local_port(skb);
+	__u32 remote_port = bpf_skb_get_remote_port(skb);
+	/*    client:X <---> frontend:80 client:X <---> backend:80
+	 *    A proxy has two components a frontend and backend here
+	 *    we use sockmap to attach frontend:80 to client:X in real
+	 *    use case we would have multiple clients and backends. For
+	 *    simplicity we hard code values here and bind 1:1.
+	 */
+	if (local_port == 10001) {
+		ret = 10;
+	} else {
+		ret=1;
+		l = bpf_map_lookup_elem(&reply_port, &loc);
+		lp = l ? *l : 0;
+		bpf_printk("local_port %d lp %d ret %d\n", local_port, lp, ret);
+	}
+
+	bpf_printk("kproxy: %d -> %d return %d\n", local_port, remote_port, ret);
+	bpf_printk("kproxy: local port %d remote port ntohl %d\n",
+		bpf_ntohl(local_port), bpf_ntohl(remote_port));
+	bpf_printk("kproxy: return %i\n", ret);
+
+	return bpf_sk_redirect_map(&sock_map, ret, 0);
+}
+
+
+SEC("sockops")
+int bpf_kproxy(struct bpf_sock_ops *skops)
+{
+	__u32 lport, rport;
+	__u32 daddr, saddr;
+	int op, err = 0, index, key, ret;
+
+
+	op = (int) skops->op;
+
+	switch (op) {
+	case BPF_SOCK_OPS_PASSIVE_ESTABLISHED_CB:
+		lport = skops->local_port;
+		rport = skops->remote_port;
+		saddr = skops->local_ip4;
+		daddr = skops->remote_ip4;
+
+		if ((((unsigned char *)&saddr)[3] == 238) &&
+		    (((unsigned char *)&saddr)[2] == 28)) {
+
+			bpf_printk("family: %i\n", skops->family);
+			bpf_printk("passive_established: %u.%u.%u",
+				((unsigned char *)&saddr)[0],
+				((unsigned char *)&saddr)[1],
+				((unsigned char *)&saddr)[2]);
+			bpf_printk("%u:%d -> ",
+				((unsigned char *)&saddr)[3],
+				lport);
+			bpf_printk("%u.%u.%u",
+				((unsigned char *)&daddr)[0],
+				((unsigned char *)&daddr)[1],
+				((unsigned char *)&daddr)[2]);
+			bpf_printk("%u:%d\n",
+				((unsigned char *)&daddr)[3], bpf_ntohl(rport));
+
+			ret = 1;
+			bpf_map_ctx_update_elem(skops, &sock_map, &ret, 1, 0x00);
+			if (!err)
+				bpf_printk("sk_redirect_map join success: 1: %d\n", err);
+		}
+		break;
+	case BPF_SOCK_OPS_ACTIVE_ESTABLISHED_CB:
+		lport = skops->local_port;
+		rport = skops->remote_port;
+		saddr = skops->local_ip4;
+		daddr = skops->remote_ip4;
+		if (bpf_ntohl(rport) == 80 && ((unsigned char *)&saddr)[3] == 238) {
+
+			bpf_printk("family: %i\n", skops->family);
+			bpf_printk("active_established_cb: %u.%u.%u",
+				((unsigned char *)&saddr)[0],
+				((unsigned char *)&saddr)[1],
+				((unsigned char *)&saddr)[2]);
+			bpf_printk("%u:%d -> %d\n",
+				((unsigned char *)&saddr)[3],
+				lport);
+			bpf_printk("%u.%u.%u",
+				((unsigned char *)&daddr)[0],
+				((unsigned char *)&daddr)[1],
+				((unsigned char *)&daddr)[2]);
+			bpf_printk("%u:%d\n",
+				((unsigned char *)&daddr)[3], bpf_ntohl(rport));
+
+			ret = 10;
+			err = bpf_map_ctx_update_elem(skops, &sock_map, &ret, 1, 0x01);
+			key = 0;
+			err = bpf_map_update_elem(&reply_port, &key, &lport, BPF_ANY);
+			bpf_printk("sk_redirect_map join success: 10: %d\n", err);
+		}
+		break;
+	default:
+		break;
+	}
+
+	if (err)
+		bpf_printk("sk_redirect_map err: %d\n", err);
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/sockmap/sockmap_user.c b/samples/sockmap/sockmap_user.c
new file mode 100644
index 0000000..46f911b
--- /dev/null
+++ b/samples/sockmap/sockmap_user.c
@@ -0,0 +1,84 @@
+#include <stdio.h>
+#include <stdlib.h>
+#include <pthread.h>
+#include <sys/socket.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <unistd.h>
+#include <string.h>
+#include <errno.h>
+#include <sys/ioctl.h>
+#include <stdbool.h>
+#include <signal.h>
+#include <fcntl.h>
+
+#include <linux/netlink.h>
+#include <linux/socket.h>
+#include <linux/sock_diag.h>
+#include <linux/bpf.h>
+#include <linux/if_link.h>
+#include <assert.h>
+#include <libgen.h>
+
+#include "../bpf/bpf_load.h"
+#include "../bpf/bpf_util.h"
+#include "../bpf/libbpf.h"
+
+int running;
+void running_handler(int a);
+
+int main(int argc, char **argv)
+{
+	int err, cg_fd;
+	char filename[256];
+	char *cg_path;
+
+	cg_path = argv[argc - 1];
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	running = 1;
+
+	/* catch SIGINT */
+	signal(SIGINT, running_handler);
+	sleep(1);
+
+	if (load_bpf_file(filename)) {
+		printf("load_bpf_file: (%s) %s\n", filename, strerror(errno));
+		return 1;
+	}
+
+	/* Cgroup configuration */
+	cg_fd = open(cg_path, O_DIRECTORY, O_RDONLY);
+	if (cg_fd < 0) {
+		fprintf(stderr, "ERROR: (%i) open cg path failed: %s\n", cg_fd, cg_path);
+		return cg_fd;
+	}
+	fprintf(stderr, "CG_FD open %i:%s\n", cg_fd, cg_path);
+
+	/* Attach programs to sockmap */
+	err = _bpf_prog_attach(prog_fd[0], prog_fd[1], map_fd[0], BPF_SOCKMAP_INGRESS, 0);
+	if (err) {
+		printf("ERROR: bpf_prog_attach (sockmap): %d (%s)\n", err, strerror(errno));
+		return err;
+	}
+
+	/* Attach to cgroups */
+	err = bpf_prog_attach(prog_fd[2], cg_fd, BPF_CGROUP_SOCK_OPS, 0);
+	if (err) {
+		printf("ERROR: bpf_prog_attach (reply): %d (%s)\n", err, strerror(errno));
+		return err;
+	}
+
+	fprintf(stderr, "BPF_CGROUP_SOCKS_OPS attached: %d\n", err);
+
+	while (running) {
+		fprintf(stderr, ".");
+		sleep(2);
+	}
+	return 0;
+}
+
+void running_handler(int a)
+{
+	running = 0;
+}
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index 1579cab..8ed8028 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -105,6 +105,7 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_ARRAY_OF_MAPS,
 	BPF_MAP_TYPE_HASH_OF_MAPS,
 	BPF_MAP_TYPE_DEVMAP,
+	BPF_MAP_TYPE_SOCKMAP,
 };
 
 enum bpf_prog_type {
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 256f571..969987b 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -209,20 +209,27 @@ int bpf_obj_get(const char *pathname)
 	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
 
-int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type,
+int _bpf_prog_attach(int prog_fd1, int prog_fd2, int target_fd, enum bpf_attach_type type,
 		    unsigned int flags)
 {
 	union bpf_attr attr;
 
 	bzero(&attr, sizeof(attr));
 	attr.target_fd	   = target_fd;
-	attr.attach_bpf_fd = prog_fd;
+	attr.attach_bpf_fd = prog_fd1;
+	attr.attach_bpf_fd2 = prog_fd2;
 	attr.attach_type   = type;
 	attr.attach_flags  = flags;
 
 	return sys_bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
 }
 
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type,
+		    unsigned int flags)
+{
+	return _bpf_prog_attach(prog_fd, 0, target_fd, type, flags);
+}
+
 int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 {
 	union bpf_attr attr;
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 418c86e..453f698 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -42,6 +42,8 @@ int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
+int bpf_map_ctx_update_elem(int fd, const void *key, const void *value,
+			__u64 flags);
 
 int bpf_map_lookup_elem(int fd, const void *key, void *value);
 int bpf_map_delete_elem(int fd, const void *key);
@@ -50,6 +52,8 @@ int bpf_map_update_elem(int fd, const void *key, const void *value,
 int bpf_obj_get(const char *pathname);
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type,
 		    unsigned int flags);
+int _bpf_prog_attach(int prog1, int prog2, int attachable_fd, enum bpf_attach_type type,
+		    unsigned int flags);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		      void *data_out, __u32 *size_out, __u32 *retval,
diff --git a/tools/testing/selftests/bpf/bpf_helpers.h b/tools/testing/selftests/bpf/bpf_helpers.h
index acbd605..a0d0b73 100644
--- a/tools/testing/selftests/bpf/bpf_helpers.h
+++ b/tools/testing/selftests/bpf/bpf_helpers.h
@@ -65,6 +65,13 @@ static int (*bpf_xdp_adjust_head)(void *ctx, int offset) =
 static int (*bpf_setsockopt)(void *ctx, int level, int optname, void *optval,
 			     int optlen) =
 	(void *) BPF_FUNC_setsockopt;
+static int (*bpf_sk_redirect_map)(void *map, int key, int flags) =
+	(void *) BPF_FUNC_sk_redirect_map;
+static int (*bpf_map_ctx_update_elem)(void *map, void *key, void *value,
+				      unsigned long long flags,
+				      unsigned long long map_lags) =
+	(void *) BPF_FUNC_map_ctx_update_elem;
+
 
 /* llvm builtin functions that eBPF C program may use to
  * emit BPF_LD_ABS and BPF_LD_IND instructions
@@ -102,6 +109,11 @@ static int (*bpf_skb_under_cgroup)(void *ctx, void *map, int index) =
 static int (*bpf_skb_change_head)(void *, int len, int flags) =
 	(void *) BPF_FUNC_skb_change_head;
 
+static int (*bpf_skb_get_remote_port)(void *ctx) =
+	(void *) BPF_FUNC_skb_get_remote_port;
+static int (*bpf_skb_get_local_port)(void *ctx) =
+	(void *) BPF_FUNC_skb_get_local_port;
+
 #if defined(__x86_64__)
 
 #define PT_REGS_PARM1(x) ((x)->di)
