From: Sargun Dhillon <sargun@sargun.me>
Subject: [PATCH net-next v2 2/2] Add example of using bpf_copy_to_user in bpf
 kprobes
Date: Tue, 19 Jul 2016 00:59:12 -0700
Message-ID: <20160719075910.GA22370@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:32996 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbcGSH7O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 03:59:14 -0400
Received: by mail-io0-f172.google.com with SMTP id 38so12330112iol.0
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 00:59:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This example shows using a kprobe to act as a dnat mechanism to divert
traffic for arbitrary endpoints. It rewrite the arguments to a syscall
while they're still in userspace, and before the syscall has a chance
to copy the argument into kernel space.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
Cc: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile       |  4 +++
 samples/bpf/tracex7_kern.c | 53 ++++++++++++++++++++++++++++++++
 samples/bpf/tracex7_user.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 133 insertions(+)
 create mode 100644 samples/bpf/tracex7_kern.c
 create mode 100644 samples/bpf/tracex7_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index a98b780..be2bab9 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -14,6 +14,7 @@ hostprogs-y += tracex3
 hostprogs-y += tracex4
 hostprogs-y += tracex5
 hostprogs-y += tracex6
+hostprogs-y += tracex7
 hostprogs-y += trace_output
 hostprogs-y += lathist
 hostprogs-y += offwaketime
@@ -35,6 +36,7 @@ tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
 tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
 tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
 tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
+tracex7-objs := bpf_load.o libbpf.o tracex7_user.o
 trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
 lathist-objs := bpf_load.o libbpf.o lathist_user.o
 offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
@@ -54,6 +56,7 @@ always += tracex3_kern.o
 always += tracex4_kern.o
 always += tracex5_kern.o
 always += tracex6_kern.o
+always += tracex7_kern.o
 always += trace_output_kern.o
 always += tcbpf1_kern.o
 always += lathist_kern.o
@@ -78,6 +81,7 @@ HOSTLOADLIBES_tracex3 += -lelf
 HOSTLOADLIBES_tracex4 += -lelf -lrt
 HOSTLOADLIBES_tracex5 += -lelf
 HOSTLOADLIBES_tracex6 += -lelf
+HOSTLOADLIBES_tracex7 += -lelf
 HOSTLOADLIBES_trace_output += -lelf -lrt
 HOSTLOADLIBES_lathist += -lelf
 HOSTLOADLIBES_offwaketime += -lelf
diff --git a/samples/bpf/tracex7_kern.c b/samples/bpf/tracex7_kern.c
new file mode 100644
index 0000000..c341a0a
--- /dev/null
+++ b/samples/bpf/tracex7_kern.c
@@ -0,0 +1,53 @@
+/* Copyright (c) 2013-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <uapi/linux/bpf.h>
+#include <linux/version.h>
+#include "bpf_helpers.h"
+
+
+struct bpf_map_def SEC("maps") dnat_map = {
+	.type = BPF_MAP_TYPE_HASH,
+	.key_size = sizeof(struct sockaddr_in),
+	.value_size = sizeof(struct sockaddr_in),
+	.max_entries = 256,
+};
+
+
+/* kprobe is NOT a stable ABI
+ * kernel functions can be removed, renamed or completely change semantics.
+ * Number of arguments and their positions can change, etc.
+ * In such case this bpf+kprobe example will no longer be meaningful
+ *
+ * This example sits on a syscall, and the syscall ABI is relatively stable
+ * of course, across platforms, and over time, the ABI may change.
+ */
+SEC("kprobe/sys_connect")
+int bpf_prog1(struct pt_regs *ctx)
+{
+	struct sockaddr_in new_addr, orig_addr = {};
+	struct sockaddr_in *mapped_addr;
+	void *sockaddr_arg = (void *)PT_REGS_PARM2(ctx);
+	int sockaddr_len = (int)PT_REGS_PARM3(ctx);
+
+	if (sockaddr_len > sizeof(orig_addr))
+		return 0;
+
+	if (bpf_probe_read(&orig_addr, sizeof(orig_addr), sockaddr_arg) != 0)
+		return 0;
+
+	mapped_addr = bpf_map_lookup_elem(&dnat_map, &orig_addr);
+	if (mapped_addr != NULL) {
+		memcpy(&new_addr, mapped_addr, sizeof(new_addr));
+		bpf_copy_to_user(sockaddr_arg, &new_addr, sizeof(new_addr));
+	}
+	return 0;
+}
+
+char _license[] SEC("license") = "GPL";
+u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/tracex7_user.c b/samples/bpf/tracex7_user.c
new file mode 100644
index 0000000..167ee40
--- /dev/null
+++ b/samples/bpf/tracex7_user.c
@@ -0,0 +1,76 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include <unistd.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <sys/socket.h>
+#include <string.h>
+#include <netinet/in.h>
+#include <arpa/inet.h>
+
+int main(int ac, char **argv)
+{
+	int serverfd, serverconnfd, clientfd;
+	socklen_t sockaddr_len;
+	struct sockaddr serv_addr, mapped_addr, tmp_addr;
+	struct sockaddr_in *serv_addr_in, *mapped_addr_in, *tmp_addr_in;
+	char filename[256];
+	char *ip;
+
+	serv_addr_in = (struct sockaddr_in *)&serv_addr;
+	mapped_addr_in = (struct sockaddr_in *)&mapped_addr;
+	tmp_addr_in = (struct sockaddr_in *)&tmp_addr;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	assert((serverfd = socket(AF_INET, SOCK_STREAM, 0)) > 0);
+	assert((clientfd = socket(AF_INET, SOCK_STREAM, 0)) > 0);
+
+	/* Bind server to ephemeral port on lo */
+	memset(&serv_addr, 0, sizeof(serv_addr));
+	serv_addr_in->sin_family = AF_INET;
+	serv_addr_in->sin_port = 0;
+	serv_addr_in->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	assert(bind(serverfd, &serv_addr, sizeof(serv_addr)) == 0);
+
+	sockaddr_len = sizeof(serv_addr);
+	assert(getsockname(serverfd, &serv_addr, &sockaddr_len) == 0);
+	ip = inet_ntoa(serv_addr_in->sin_addr);
+	printf("Server bound to: %s:%d\n", ip, ntohs(serv_addr_in->sin_port));
+
+	memset(&mapped_addr, 0, sizeof(mapped_addr));
+	mapped_addr_in->sin_family = AF_INET;
+	mapped_addr_in->sin_port = htons(5555);
+	mapped_addr_in->sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	assert(bpf_update_elem(map_fd[0], &mapped_addr, &serv_addr,
+		BPF_ANY) == 0);
+
+	assert(listen(serverfd, 5) == 0);
+
+	ip = inet_ntoa(mapped_addr_in->sin_addr);
+	printf("Client connecting to: %s:%d\n", ip,
+		ntohs(mapped_addr_in->sin_port));
+	assert(connect(clientfd, &mapped_addr, sizeof(mapped_addr)) == 0);
+
+	sockaddr_len = sizeof(tmp_addr);
+	ip = inet_ntoa(tmp_addr_in->sin_addr);
+	assert((serverconnfd = accept(serverfd, &tmp_addr, &sockaddr_len)) > 0);
+	printf("Server received connection from: %s:%d\n", ip,
+		ntohs(tmp_addr_in->sin_port));
+
+	sockaddr_len = sizeof(tmp_addr);
+	assert(getpeername(clientfd, &tmp_addr, &sockaddr_len) == 0);
+	ip = inet_ntoa(tmp_addr_in->sin_addr);
+	printf("Client's peer address: %s:%d\n", ip,
+		ntohs(tmp_addr_in->sin_port));
+
+	return 0;
+}
-- 
2.7.4
