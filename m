From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 06/53] perf tools: Fix PowerPC native building
Date: Mon, 11 Jan 2016 13:47:57 +0000
Message-ID: <1452520124-2073-7-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
To: <acme@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:41288 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759947AbcAKNtk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 08:49:40 -0500
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checks BPF syscall number, turn off libbpf building on platform doesn't
correctly support sys_bpf instead of blocking compiling.

Reported-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Acked-by: Jiri Olsa <jolsa@kernel.org>
Tested-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
---
 tools/build/feature/test-bpf.c | 20 +++++++++++++++++++-
 tools/lib/bpf/bpf.c            |  4 ++--
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/tools/build/feature/test-bpf.c b/tools/build/feature/test-bpf.c
index 062bac8..b389026 100644
--- a/tools/build/feature/test-bpf.c
+++ b/tools/build/feature/test-bpf.c
@@ -1,9 +1,23 @@
+#include <asm/unistd.h>
 #include <linux/bpf.h>
+#include <unistd.h>
+
+#ifndef __NR_bpf
+# if defined(__i386__)
+#  define __NR_bpf 357
+# elif defined(__x86_64__)
+#  define __NR_bpf 321
+# elif defined(__aarch64__)
+#  define __NR_bpf 280
+#  error __NR_bpf not defined. libbpf does not support your arch.
+# endif
+#endif
 
 int main(void)
 {
 	union bpf_attr attr;
 
+	/* Check fields in attr */
 	attr.prog_type = BPF_PROG_TYPE_KPROBE;
 	attr.insn_cnt = 0;
 	attr.insns = 0;
@@ -14,5 +28,9 @@ int main(void)
 	attr.kern_version = 0;
 
 	attr = attr;
-	return 0;
+	/*
+	 * Test existence of __NR_bpf and BPF_PROG_LOAD.
+	 * This call should fail if we run the testcase.
+	 */
+	return syscall(__NR_bpf, BPF_PROG_LOAD, attr, sizeof(attr));
 }
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 5bdc6ea..1f91cc9 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -14,8 +14,8 @@
 #include "bpf.h"
 
 /*
- * When building perf, unistd.h is override. Define __NR_bpf is
- * required to be defined.
+ * When building perf, unistd.h is overrided. __NR_bpf is
+ * required to be defined explicitly.
  */
 #ifndef __NR_bpf
 # if defined(__i386__)
-- 
1.8.3.4
