From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net] selftests/bpf: fix broken build
Date: Fri, 10 Mar 2017 22:05:55 -0800
Message-ID: <1489212355-3289694-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:49220 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751325AbdCKGGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Mar 2017 01:06:00 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2B62PP9020074
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 22:05:59 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 293r0rb7m2-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 22:05:59 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 ca0bacb4062011e790bc0002c9521c9e-a61eb9a0 for <netdev@vger.kernel.org>;        Fri,
 10 Mar 2017 22:05:55 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent merge of 'linux-kselftest-4.11-rc1' tree broke bpf test build.
None of the tests were building and test_verifier.c had tons of compiler errors.
Fix it and add #ifdef CAP_IS_SUPPORTED to support old versions of libcap.
Tested on centos 6.8 and 7

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/include/uapi/linux/bpf_perf_event.h   | 18 ++++++++++++++++++
 tools/testing/selftests/bpf/Makefile        |  4 +++-
 tools/testing/selftests/bpf/test_verifier.c |  4 ++++
 3 files changed, 25 insertions(+), 1 deletion(-)
 create mode 100644 tools/include/uapi/linux/bpf_perf_event.h

diff --git a/tools/include/uapi/linux/bpf_perf_event.h b/tools/include/uapi/linux/bpf_perf_event.h
new file mode 100644
index 000000000000..067427259820
--- /dev/null
+++ b/tools/include/uapi/linux/bpf_perf_event.h
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
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 4b498265dae6..67531f47781b 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,12 +1,14 @@
 LIBDIR := ../../../lib
 BPFOBJ := $(LIBDIR)/bpf/bpf.o
 
-CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR)
+CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I$(LIBDIR) $(BPFOBJ)
 
 TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
 TEST_PROGS := test_kmod.sh
 
+all: $(TEST_GEN_PROGS)
+
 .PHONY: all clean force
 
 # force a rebuild of BPFOBJ when its dependencies are updated
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index e1f5b9eea1e8..d1555e4240c0 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -8,6 +8,8 @@
  * License as published by the Free Software Foundation.
  */
 
+#include <asm/types.h>
+#include <linux/types.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
@@ -4583,10 +4585,12 @@ static bool is_admin(void)
 	cap_flag_value_t sysadmin = CAP_CLEAR;
 	const cap_value_t cap_val = CAP_SYS_ADMIN;
 
+#ifdef CAP_IS_SUPPORTED
 	if (!CAP_IS_SUPPORTED(CAP_SETFCAP)) {
 		perror("cap_get_flag");
 		return false;
 	}
+#endif
 	caps = cap_get_proc();
 	if (!caps) {
 		perror("cap_get_proc");
-- 
2.8.0
