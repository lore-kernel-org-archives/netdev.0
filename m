From: Yonghong Song <yhs@fb.com>
Subject: [PATCH 2/2] selftests/bpf: Add test cases to test narrower ctx field loads
Date: Tue, 13 Jun 2017 15:52:14 -0700
Message-ID: <20170613225214.2854085-3-yhs@fb.com>
References: <20170613225214.2854085-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <ast@fb.com>, <daniel@iogearbox.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:41796 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753946AbdFMWwn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2017 18:52:43 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v5DMqRIE023525
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 15:52:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2b24py59cc-17
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2017 15:52:37 -0700
Received: from facebook.com (2401:db00:11:d0af:face:0:2d:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 f1c99b94508a11e7bb4f0002c99293a0-dd13e8f0 for <netdev@vger.kernel.org>;        Tue,
 13 Jun 2017 15:52:15 -0700
In-Reply-To: <20170613225214.2854085-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add test cases in test_verifier and test_progs.
Negative tests are added in test_verifier as well.
The test in test_progs will compare the value of narrower ctx field
load result vs. the masked value of normal full-field load result,
and will fail if they are not the same.

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Yonghong Song <yhs@fb.com>
---
 tools/testing/selftests/bpf/Makefile             |   3 +-
 tools/testing/selftests/bpf/test_pkt_md_access.c |  35 +++++
 tools/testing/selftests/bpf/test_progs.c         |  21 +++
 tools/testing/selftests/bpf/test_verifier.c      | 176 +++++++++++++++++++++++
 4 files changed, 234 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/bpf/test_pkt_md_access.c

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 9f0e07b..2ca51a8 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -14,7 +14,8 @@ LDLIBS += -lcap -lelf
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs \
 	test_align
 
-TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o test_tcp_estats.o test_obj_id.o
+TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o test_tcp_estats.o test_obj_id.o \
+	test_pkt_md_access.o
 
 TEST_PROGS := test_kmod.sh
 
diff --git a/tools/testing/selftests/bpf/test_pkt_md_access.c b/tools/testing/selftests/bpf/test_pkt_md_access.c
new file mode 100644
index 0000000..71729d4
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_pkt_md_access.c
@@ -0,0 +1,35 @@
+/* Copyright (c) 2017 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stddef.h>
+#include <string.h>
+#include <linux/bpf.h>
+#include <linux/pkt_cls.h>
+#include "bpf_helpers.h"
+
+int _version SEC("version") = 1;
+
+#define TEST_FIELD(TYPE, FIELD, MASK)					\
+	{								\
+		TYPE tmp = *(volatile TYPE *)&skb->FIELD;		\
+		if (tmp != ((*(volatile __u32 *)&skb->FIELD) & MASK))	\
+			return TC_ACT_SHOT;				\
+	}
+
+SEC("test1")
+int process(struct __sk_buff *skb)
+{
+	TEST_FIELD(__u8,  len, 0xFF);
+	TEST_FIELD(__u16, len, 0xFFFF);
+	TEST_FIELD(__u32, len, 0xFFFFFFFF);
+	TEST_FIELD(__u16, protocol, 0xFFFF);
+	TEST_FIELD(__u32, protocol, 0xFFFFFFFF);
+	TEST_FIELD(__u8,  hash, 0xFF);
+	TEST_FIELD(__u16, hash, 0xFFFF);
+	TEST_FIELD(__u32, hash, 0xFFFFFFFF);
+
+	return TC_ACT_OK;
+}
diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index f10493d..5855cd3 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -484,6 +484,26 @@ static void test_bpf_obj_id(void)
 		bpf_object__close(objs[i]);
 }
 
+static void test_pkt_md_access(void)
+{
+	const char *file = "./test_pkt_md_access.o";
+	struct bpf_object *obj;
+	__u32 duration, retval;
+	int err, prog_fd;
+
+	err = bpf_prog_load(file, BPF_PROG_TYPE_SCHED_CLS, &obj, &prog_fd);
+	if (err)
+		return;
+
+	err = bpf_prog_test_run(prog_fd, 10, &pkt_v4, sizeof(pkt_v4),
+				NULL, NULL, &retval, &duration);
+	CHECK(err || retval, "",
+	      "err %d errno %d retval %d duration %d\n",
+	      err, errno, retval, duration);
+
+	bpf_object__close(obj);
+}
+
 int main(void)
 {
 	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
@@ -495,6 +515,7 @@ int main(void)
 	test_l4lb();
 	test_tcp_estats();
 	test_bpf_obj_id();
+	test_pkt_md_access();
 
 	printf("Summary: %d PASSED, %d FAILED\n", pass_cnt, error_cnt);
 	return error_cnt ? EXIT_FAILURE : EXIT_SUCCESS;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 1334170..c0af019 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -1095,6 +1095,59 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 	},
 	{
+		"check skb->hash byte load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash)),
+#else
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 3),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check skb->hash byte load not permitted 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check skb->hash byte load not permitted 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"check skb->hash byte load not permitted 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 3),
+#else
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash)),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
 		"check cb access: byte, wrong type",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -1188,6 +1241,37 @@ static struct bpf_test tests[] = {
 		.result = REJECT,
 	},
 	{
+		"check skb->hash half load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash)),
+#else
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 2),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"check skb->hash half load not permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash) + 2),
+#else
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, hash)),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
 		"check cb access: half, wrong type",
 		.insns = {
 			BPF_MOV64_IMM(BPF_REG_0, 0),
@@ -5103,6 +5187,98 @@ static struct bpf_test tests[] = {
 		},
 		.result = ACCEPT,
 	},
+	{
+		"check bpf_perf_event_data->sample_period byte load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period)),
+#else
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period) + 7),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
+		"check bpf_perf_event_data->sample_period half load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period)),
+#else
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period) + 6),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
+		"check bpf_perf_event_data->sample_period word load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period)),
+#else
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period) + 4),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
+		"check bpf_perf_event_data->sample_period dword load permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data, sample_period)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
+		"check skb->data half load not permitted",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+#else
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, data) + 2),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid bpf_context access",
+	},
+	{
+		"check skb->tc_classid half load not permitted for lwt prog",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+#ifdef __LITTLE_ENDIAN
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_classid)),
+#else
+			BPF_LDX_MEM(BPF_H, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_classid) + 2),
+#endif
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid bpf_context access",
+		.prog_type = BPF_PROG_TYPE_LWT_IN,
+	},
 };
 
 static int probe_filter_length(const struct bpf_insn *fp)
-- 
2.9.3
