From: Yonghong Song <yhs@fb.com>
Subject: [PATCH net] perf/bpf: fix a clang compilation issue
Date: Thu, 7 Sep 2017 18:36:15 -0700
Message-ID: <20170908013615.973478-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <peterz@infradead.org>, <rostedt@goodmis.org>, <ast@fb.com>,
        <daniel@iogearbox.net>, <ndesaulniers@google.com>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36582 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751456AbdIHBgR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 21:36:17 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v881XeBB014840
        for <netdev@vger.kernel.org>; Thu, 7 Sep 2017 18:36:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2cufg5gec4-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 18:36:17 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

clang does not support variable length array for structure member.
It has the following error during compilation:

kernel/trace/trace_syscalls.c:568:17: error: fields must have a constant size:
'variable length array in structure' extension will never be supported
                unsigned long args[sys_data->nb_args];
                              ^

The fix is to use a fixed array length instead.

Reported-by: Nick Desaulniers <ndesaulniers@google.com>
Signed-off-by: Yonghong Song <yhs@fb.com>
---
 include/linux/syscalls.h      | 2 ++
 kernel/trace/trace_syscalls.c | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 88951b7..95606a2 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -200,6 +200,8 @@ static inline int is_syscall_trace_event(struct trace_event_call *tp_event)
 #define SYSCALL_DEFINE5(name, ...) SYSCALL_DEFINEx(5, _##name, __VA_ARGS__)
 #define SYSCALL_DEFINE6(name, ...) SYSCALL_DEFINEx(6, _##name, __VA_ARGS__)
 
+#define SYSCALL_DEFINE_MAXARGS	6
+
 #define SYSCALL_DEFINEx(x, sname, ...)				\
 	SYSCALL_METADATA(sname, x, __VA_ARGS__)			\
 	__SYSCALL_DEFINEx(x, sname, __VA_ARGS__)
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index 9c4eef2..696afe7 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -565,7 +565,7 @@ static int perf_call_bpf_enter(struct bpf_prog *prog, struct pt_regs *regs,
 	struct syscall_tp_t {
 		unsigned long long regs;
 		unsigned long syscall_nr;
-		unsigned long args[sys_data->nb_args];
+		unsigned long args[SYSCALL_DEFINE_MAXARGS];
 	} param;
 	int i;
 
-- 
2.9.5
