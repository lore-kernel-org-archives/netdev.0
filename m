From: Martin KaFai Lau <kafai@fb.com>
Subject: [RFC net-next 2/2] bpf: Test for bpf_prog ID and BPF_PROG_GET_NEXT_ID
Date: Wed, 26 Apr 2017 23:24:49 -0700
Message-ID: <20170427062449.80290-3-kafai@fb.com>
References: <20170427062449.80290-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <ast@fb.com>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60576 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752185AbdD0GYv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 02:24:51 -0400
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3R6OcHK007133
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 23:24:50 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2a2x3eavtf-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 23:24:50 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 372a79fe2b1211e79ab20002c9931860-ff2da9a0 for <netdev@vger.kernel.org>;        Wed,
 26 Apr 2017 23:24:49 -0700
In-Reply-To: <20170427062449.80290-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add test to exercise the bpf_prog id generation
and iteration.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/include/uapi/linux/bpf.h             |  6 ++
 tools/lib/bpf/bpf.c                        | 11 ++++
 tools/lib/bpf/bpf.h                        |  1 +
 tools/testing/selftests/bpf/Makefile       |  2 +-
 tools/testing/selftests/bpf/test_prog_id.c | 93 ++++++++++++++++++++++++++++++
 5 files changed, 112 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/bpf/test_prog_id.c

diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index e553529929f6..270f501c5597 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -82,6 +82,7 @@ enum bpf_cmd {
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
 	BPF_PROG_TEST_RUN,
+	BPF_PROG_GET_NEXT_ID,
 };
 
 enum bpf_map_type {
@@ -201,6 +202,11 @@ union bpf_attr {
 		__u32		repeat;
 		__u32		duration;
 	} test;
+
+	struct { /* anonymous struct used by BPF_PROG_GET_NEXT_ID */
+		__u32		start_id;
+		__aligned_u64	next_id;
+	};
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 4fe444b8092e..e23011f88fb4 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -235,3 +235,14 @@ int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		*duration = attr.test.duration;
 	return ret;
 }
+
+int bpf_prog_get_next_id(__u32 start_id, __u32 *next_id)
+{
+	union bpf_attr attr;
+
+	bzero(&attr, sizeof(attr));
+	attr.start_id = start_id;
+	attr.next_id = ptr_to_u64(next_id);
+
+	return sys_bpf(BPF_PROG_GET_NEXT_ID, &attr, sizeof(attr));
+}
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index edb4daeff7a5..200f1ffc9cf9 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -50,5 +50,6 @@ int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_test_run(int prog_fd, int repeat, void *data, __u32 size,
 		      void *data_out, __u32 *size_out, __u32 *retval,
 		      __u32 *duration);
+int bpf_prog_get_next_id(__u32 start_id, __u32 *next_id);
 
 #endif
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index d8d94b9bd76c..68c4a920cb56 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -11,7 +11,7 @@ endif
 CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include
 LDLIBS += -lcap -lelf
 
-TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
+TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs test_prog_id
 
 TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o
 
diff --git a/tools/testing/selftests/bpf/test_prog_id.c b/tools/testing/selftests/bpf/test_prog_id.c
new file mode 100644
index 000000000000..f6c56c649d72
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_prog_id.c
@@ -0,0 +1,93 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/types.h>
+#include <linux/bpf.h>
+#include <linux/err.h>
+#include <bpf/bpf.h>
+#include <sys/resource.h>
+#include <unistd.h>
+#include <bpf/libbpf.h>
+#include <assert.h>
+
+#include "bpf_util.h"
+
+static int bpf_prog_load(const char *file, enum bpf_prog_type type,
+			 struct bpf_object **pobj, int *prog_fd)
+{
+	struct bpf_program *prog;
+	struct bpf_object *obj;
+	int err;
+
+	obj = bpf_object__open(file);
+	if (IS_ERR(obj))
+		return -ENOENT;
+
+	prog = bpf_program__next(NULL, obj);
+	if (!prog) {
+		bpf_object__close(obj);
+		return -ENOENT;
+	}
+
+	bpf_program__set_type(prog, type);
+	err = bpf_object__load(obj);
+	if (err) {
+		bpf_object__close(obj);
+		return -EINVAL;
+	}
+
+	*pobj = obj;
+	*prog_fd = bpf_program__fd(prog);
+	return 0;
+}
+
+int main(void)
+{
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+	const char *file = "./test_pkt_access.o";
+	const int nr_iters = 16;
+	int bpf_prog_fds[nr_iters];
+	int i, err = 0;
+	uint32_t next_id = 0;
+
+	if (setrlimit(RLIMIT_MEMLOCK, &rinf)) {
+		perror("setrlimit");
+		return -1;
+	}
+
+	memset(bpf_prog_fds, -1, sizeof(bpf_prog_fds));
+
+	for (i = 0; i < nr_iters; i++) {
+		struct bpf_object *obj;
+		int prog_fd;
+
+		err = bpf_prog_load(file, BPF_PROG_TYPE_SCHED_CLS, &obj,
+				    &prog_fd);
+		if (err) {
+			perror("bpf_prog_load");
+			goto done;
+		}
+
+		bpf_prog_fds[i] = prog_fd;
+	}
+
+	i = 0;
+	while (!bpf_prog_get_next_id(next_id, &next_id)) {
+		printf("prog_uid:%08u\n", next_id);
+		i++;
+		assert(i <= nr_iters);
+	}
+	assert(i == nr_iters);
+
+done:
+	for (i = 0; i < nr_iters; i++) {
+		if (bpf_prog_fds[i] != -1) {
+			close(bpf_prog_fds[i]);
+		}
+	}
+
+	return err ? -1 : 0;
+}
-- 
2.9.3
