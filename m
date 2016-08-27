From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/6] bpf: introduce BPF_PROG_TYPE_PERF_EVENT program type
Date: Fri, 26 Aug 2016 19:31:20 -0700
Message-ID: <1472265084-1767670-3-git-send-email-ast@fb.com>
References: <1472265084-1767670-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Arnaldo Carvalho de Melo <acme@infradead.org>,
        Wang Nan <wangnan0@huawei.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:20209 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754721AbcH0Cbk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 22:31:40 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u7R2LVtR004455
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:27 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 252ugx2kbx-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 19:31:27 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.101.97) with ESMTP id
 599eca5e6bfe11e6b52e24be0595f910-e37fdaa0 for <netdev@vger.kernel.org>;        Fri,
 26 Aug 2016 19:31:25 -0700
In-Reply-To: <1472265084-1767670-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce BPF_PROG_TYPE_PERF_EVENT programs that can be attached to
HW and SW perf events (PERF_TYPE_HARDWARE and PERF_TYPE_SOFTWARE
correspondingly in uapi/linux/perf_event.h)

The program visible context meta structure is
struct bpf_perf_event_data {
    struct pt_regs regs;
     __u64 sample_period;
};
which is accessible directly from the program:
int bpf_prog(struct bpf_perf_event_data *ctx)
{
  ... ctx->sample_period ...
  ... ctx->regs.ip ...
}

The bpf verifier rewrites the accesses into kernel internal
struct bpf_perf_event_data_kern which allows changing
struct perf_sample_data without affecting bpf programs.
New fields can be added to the end of struct bpf_perf_event_data
in the future.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/perf_event.h          |  5 ++++
 include/uapi/linux/Kbuild           |  1 +
 include/uapi/linux/bpf.h            |  1 +
 include/uapi/linux/bpf_perf_event.h | 18 ++++++++++++
 kernel/trace/bpf_trace.c            | 57 +++++++++++++++++++++++++++++++++++++
 5 files changed, 82 insertions(+)
 create mode 100644 include/uapi/linux/bpf_perf_event.h

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index 2b6b43cc0dd5..97bfe62f30d7 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -788,6 +788,11 @@ struct perf_output_handle {
 	int				page;
 };
 
+struct bpf_perf_event_data_kern {
+	struct pt_regs *regs;
+	struct perf_sample_data *data;
+};
+
 #ifdef CONFIG_CGROUP_PERF
 
 /*
diff --git a/include/uapi/linux/Kbuild b/include/uapi/linux/Kbuild
index 185f8ea2702f..d0352a971ebd 100644
--- a/include/uapi/linux/Kbuild
+++ b/include/uapi/linux/Kbuild
@@ -71,6 +71,7 @@ header-y += binfmts.h
 header-y += blkpg.h
 header-y += blktrace_api.h
 header-y += bpf_common.h
+header-y += bpf_perf_event.h
 header-y += bpf.h
 header-y += bpqether.h
 header-y += bsg.h
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e4c5a1baa993..f896dfac4ac0 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -95,6 +95,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_SCHED_ACT,
 	BPF_PROG_TYPE_TRACEPOINT,
 	BPF_PROG_TYPE_XDP,
+	BPF_PROG_TYPE_PERF_EVENT,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/include/uapi/linux/bpf_perf_event.h b/include/uapi/linux/bpf_perf_event.h
new file mode 100644
index 000000000000..067427259820
--- /dev/null
+++ b/include/uapi/linux/bpf_perf_event.h
@@ -0,0 +1,18 @@
+/* Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _UAPI__LINUX_BPF_PERF_EVENT_H__
+#define _UAPI__LINUX_BPF_PERF_EVENT_H__
+
+#include <linux/types.h>
+#include <linux/ptrace.h>
+
+struct bpf_perf_event_data {
+	struct pt_regs regs;
+	__u64 sample_period;
+};
+
+#endif /* _UAPI__LINUX_BPF_PERF_EVENT_H__ */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ad35213b8405..2af0688bedfc 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -1,4 +1,5 @@
 /* Copyright (c) 2011-2015 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
  *
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of version 2 of the GNU General Public
@@ -8,6 +9,7 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/bpf.h>
+#include <linux/bpf_perf_event.h>
 #include <linux/filter.h>
 #include <linux/uaccess.h>
 #include <linux/ctype.h>
@@ -552,10 +554,65 @@ static struct bpf_prog_type_list tracepoint_tl = {
 	.type	= BPF_PROG_TYPE_TRACEPOINT,
 };
 
+static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type,
+				    enum bpf_reg_type *reg_type)
+{
+	if (off < 0 || off >= sizeof(struct bpf_perf_event_data))
+		return false;
+	if (type != BPF_READ)
+		return false;
+	if (off % size != 0)
+		return false;
+	if (off == offsetof(struct bpf_perf_event_data, sample_period) &&
+	    size != sizeof(u64))
+		return false;
+	if (size != sizeof(long))
+		return false;
+	return true;
+}
+
+static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
+				      int src_reg, int ctx_off,
+				      struct bpf_insn *insn_buf,
+				      struct bpf_prog *prog)
+{
+	struct bpf_insn *insn = insn_buf;
+
+	switch (ctx_off) {
+	case offsetof(struct bpf_perf_event_data, sample_period):
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, data)),
+				      dst_reg, src_reg,
+				      offsetof(struct bpf_perf_event_data_kern, data));
+		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
+				      offsetof(struct perf_sample_data, period));
+		break;
+	default:
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(FIELD_SIZEOF(struct bpf_perf_event_data_kern, regs)),
+				      dst_reg, src_reg,
+				      offsetof(struct bpf_perf_event_data_kern, regs));
+		*insn++ = BPF_LDX_MEM(bytes_to_bpf_size(sizeof(long)),
+				      dst_reg, dst_reg, ctx_off);
+		break;
+	}
+	return insn - insn_buf;
+}
+
+static const struct bpf_verifier_ops perf_event_prog_ops = {
+	.get_func_proto		= tp_prog_func_proto,
+	.is_valid_access	= pe_prog_is_valid_access,
+	.convert_ctx_access	= pe_prog_convert_ctx_access,
+};
+
+static struct bpf_prog_type_list perf_event_tl = {
+	.ops	= &perf_event_prog_ops,
+	.type	= BPF_PROG_TYPE_PERF_EVENT,
+};
+
 static int __init register_kprobe_prog_ops(void)
 {
 	bpf_register_prog_type(&kprobe_tl);
 	bpf_register_prog_type(&tracepoint_tl);
+	bpf_register_prog_type(&perf_event_tl);
 	return 0;
 }
 late_initcall(register_kprobe_prog_ops);
-- 
2.8.0
