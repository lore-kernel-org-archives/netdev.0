From: Joe Stringer <joe@ovn.org>
Subject: [PATCH perf/core REBASE 3/5] tools lib bpf: Add bpf_prog_{attach,detach}
Date: Wed, 14 Dec 2016 14:43:40 -0800
Message-ID: <20161214224342.12858-4-joe@ovn.org>
References: <20161214224342.12858-1-joe@ovn.org>
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:60551 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756931AbcLNWrA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2016 17:47:00 -0500
In-Reply-To: <20161214224342.12858-1-joe@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d8c5b17f2bc0 ("samples: bpf: add userspace example for attaching
eBPF programs to cgroups") added these functions to samples/libbpf, but
during this merge all of the samples libbpf functionality is shifting to
tools/lib/bpf. Shift these functions there.

Signed-off-by: Joe Stringer <joe@ovn.org>
---
Arnaldo, this is a new patch you didn't previously review which I've
prepared due to the conflict with net-next. I figured it's better to try
to get samples/bpf properly switched over this window rather than defer the
problem and end up having to deal with another merge problem next time
around. I hope that is fine for you. If not, this patch onwards will need
to be dropped

It's a simple copy/paste/delete with a minor change for sys_bpf() vs
syscall().
---
 samples/bpf/libbpf.c | 21 ---------------------
 samples/bpf/libbpf.h |  3 ---
 tools/lib/bpf/bpf.c  | 21 +++++++++++++++++++++
 tools/lib/bpf/bpf.h  |  3 +++
 4 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 3391225ad7e9..d9af876b4a2c 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -11,27 +11,6 @@
 #include <arpa/inet.h>
 #include "libbpf.h"
 
-int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
-{
-	union bpf_attr attr = {
-		.target_fd = target_fd,
-		.attach_bpf_fd = prog_fd,
-		.attach_type = type,
-	};
-
-	return syscall(__NR_bpf, BPF_PROG_ATTACH, &attr, sizeof(attr));
-}
-
-int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
-{
-	union bpf_attr attr = {
-		.target_fd = target_fd,
-		.attach_type = type,
-	};
-
-	return syscall(__NR_bpf, BPF_PROG_DETACH, &attr, sizeof(attr));
-}
-
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index cf7d2386d1f9..cc815624aacf 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -6,9 +6,6 @@
 
 struct bpf_insn;
 
-int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
-int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
-
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
 #define BPF_ALU64_REG(OP, DST, SRC)				\
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index d0afb26c2e0f..e19335df0d3a 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -167,3 +167,24 @@ int bpf_obj_get(const char *pathname)
 
 	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
+
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_bpf_fd = prog_fd,
+		.attach_type = type,
+	};
+
+	return sys_bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
+}
+
+int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
+{
+	union bpf_attr attr = {
+		.target_fd = target_fd,
+		.attach_type = type,
+	};
+
+	return sys_bpf(BPF_PROG_DETACH, &attr, sizeof(attr));
+}
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index 7fcdce16fd62..a2f9853dd882 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -41,5 +41,8 @@ int bpf_map_delete_elem(int fd, void *key);
 int bpf_map_get_next_key(int fd, void *key, void *next_key);
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
+int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
+int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
+
 
 #endif
-- 
2.10.2
