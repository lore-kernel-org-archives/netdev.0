From: Sargun Dhillon <sargun@sargun.me>
Subject: [RFC 3/4] security/checmate: Add Checmate sample
Date: Thu, 4 Aug 2016 00:11:53 -0700
Message-ID: <20160804071152.GA19128@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Checmate sample installs a policy barring new AF_INET connections
to port 1. We install the hook, and show an example of connect
returning EPERM, and then reset the policy.

If this is running concurrently with other policy engines, bad things
could happen.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 samples/bpf/Makefile         |  4 ++++
 samples/bpf/bpf_load.c       | 11 ++++++---
 samples/bpf/checmate1_kern.c | 27 ++++++++++++++++++++++
 samples/bpf/checmate1_user.c | 54 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 93 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/checmate1_kern.c
 create mode 100644 samples/bpf/checmate1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 90ebf7d..83e1da8 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -24,6 +24,7 @@ hostprogs-y += test_overhead
 hostprogs-y += test_cgrp2_array_pin
 hostprogs-y += xdp1
 hostprogs-y += xdp2
+hostprogs-y += checmate1
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
@@ -49,6 +50,7 @@ test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
 xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
 # reuse xdp1 source intentionally
 xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
+checmate1-objs := bpf_load.o libbpf.o checmate1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -74,6 +76,7 @@ always += parse_varlen.o parse_simple.o parse_ldabs.o
 always += test_cgrp2_tc_kern.o
 always += xdp1_kern.o
 always += xdp2_kern.o
+always += checmate1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 
@@ -97,6 +100,7 @@ HOSTLOADLIBES_map_perf_test += -lelf -lrt
 HOSTLOADLIBES_test_overhead += -lelf -lrt
 HOSTLOADLIBES_xdp1 += -lelf
 HOSTLOADLIBES_xdp2 += -lelf
+HOSTLOADLIBES_checmate1 += -lelf
 
 # Allows pointing LLC/CLANG to a LLVM backend with bpf support, redefine on cmdline:
 #  make samples/bpf/ LLC=~/git/llvm/build/bin/llc CLANG=~/git/llvm/build/bin/clang
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 0cfda23..49e84e7b 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -51,6 +51,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_kretprobe = strncmp(event, "kretprobe/", 10) == 0;
 	bool is_tracepoint = strncmp(event, "tracepoint/", 11) == 0;
 	bool is_xdp = strncmp(event, "xdp", 3) == 0;
+	bool is_checmate = strncmp(event, "checmate", 8) == 0;
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -69,6 +70,8 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		prog_type = BPF_PROG_TYPE_TRACEPOINT;
 	} else if (is_xdp) {
 		prog_type = BPF_PROG_TYPE_XDP;
+	} else if (is_checmate) {
+		prog_type = BPF_PROG_TYPE_CHECMATE;
 	} else {
 		printf("Unknown event '%s'\n", event);
 		return -1;
@@ -82,7 +85,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 
 	prog_fd[prog_cnt++] = fd;
 
-	if (is_xdp)
+	if (is_xdp || is_checmate)
 		return 0;
 
 	if (is_socket) {
@@ -326,7 +329,8 @@ int load_bpf_file(char *path)
 			    memcmp(shname_prog, "kretprobe/", 10) == 0 ||
 			    memcmp(shname_prog, "tracepoint/", 11) == 0 ||
 			    memcmp(shname_prog, "xdp", 3) == 0 ||
-			    memcmp(shname_prog, "socket", 6) == 0)
+			    memcmp(shname_prog, "socket", 6) == 0 ||
+			    memcpy(shname_prog, "checmate", 8) == 0)
 				load_and_attach(shname_prog, insns, data_prog->d_size);
 		}
 	}
@@ -344,7 +348,8 @@ int load_bpf_file(char *path)
 		    memcmp(shname, "kretprobe/", 10) == 0 ||
 		    memcmp(shname, "tracepoint/", 11) == 0 ||
 		    memcmp(shname, "xdp", 3) == 0 ||
-		    memcmp(shname, "socket", 6) == 0)
+		    memcmp(shname, "socket", 6) == 0 ||
+		    memcmp(shname, "checmate", 8) == 0)
 			load_and_attach(shname, data->d_buf, data->d_size);
 	}
 
diff --git a/samples/bpf/checmate1_kern.c b/samples/bpf/checmate1_kern.c
new file mode 100644
index 0000000..f78b66b
--- /dev/null
+++ b/samples/bpf/checmate1_kern.c
@@ -0,0 +1,27 @@
+#include <uapi/linux/bpf.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/checmate.h>
+#include "bpf_helpers.h"
+
+SEC("checmate")
+int prog(struct checmate_ctx *ctx)
+{
+	struct sockaddr address;
+	struct sockaddr_in *in_addr;
+	char fmt[] = "Denying access on port 1\n";
+
+	bpf_probe_read(&address, sizeof(struct sockaddr_in),
+		       ctx->socket_connect_ctx.address);
+	if (address.sa_family == AF_INET) {
+		in_addr = (struct sockaddr_in *) &address;
+		if (be16_to_cpu(in_addr->sin_port) == 1) {
+			bpf_trace_printk(fmt, sizeof(fmt));
+			return -EPERM;
+		}
+	}
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+
diff --git a/samples/bpf/checmate1_user.c b/samples/bpf/checmate1_user.c
new file mode 100644
index 0000000..94b7040
--- /dev/null
+++ b/samples/bpf/checmate1_user.c
@@ -0,0 +1,54 @@
+#include <linux/bpf.h>
+#include <stdio.h>
+#include <sys/prctl.h>
+#include <linux/checmate.h>
+#include <errno.h>
+#include <stdlib.h>
+#include <string.h>
+#include "bpf_load.h"
+#include "libbpf.h"
+#include <netinet/in.h>
+#include <arpa/inet.h>
+#include <assert.h>
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	int rc = 0;
+	int sockfd;
+	struct sockaddr_in in_addr;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+	if (!prog_fd[0]) {
+		printf("load_bpf_file: %s\n", strerror(errno));
+		return 1;
+	}
+	rc = prctl(PR_CHECMATE, CHECMATE_INSTALL_HOOK,
+		   CHECMATE_HOOK_SOCKET_CONNECT, prog_fd[0]);
+	if (rc) {
+		printf("Failed to install hook: %s\n", strerror(errno));
+		return 1;
+	}
+	assert((sockfd = socket(AF_INET, SOCK_STREAM, 0)) > 0);
+
+	/* Fake destination address (on loopback) on port 1 */
+	in_addr.sin_family = AF_INET;
+	in_addr.sin_port = htons(1);
+	in_addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+	assert(connect(sockfd, (const struct sockaddr *)&in_addr,
+		       sizeof(in_addr)) != 0);
+	assert(errno = -EPERM);
+
+	rc = prctl(PR_CHECMATE, CHECMATE_RESET,
+		   CHECMATE_HOOK_SOCKET_CONNECT, prog_fd[0]);
+	if (rc) {
+		printf("Failed to reset hook: %s\n", strerror(errno));
+		return 1;
+	}
+
+	return rc;
+}
-- 
2.7.4
