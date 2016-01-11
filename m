From: Wang Nan <wangnan0@huawei.com>
Subject: [PATCH 14/53] perf test: Check environment before start real BPF test
Date: Mon, 11 Jan 2016 13:48:05 +0000
Message-ID: <1452520124-2073-15-git-send-email-wangnan0@huawei.com>
References: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <pi3orama@163.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>, Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452520124-2073-1-git-send-email-wangnan0@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Copying perf to old kernel system results:

 # perf test bpf
 37: Test BPF filter                                          :
 37.1: Test basic BPF filtering                               : FAILED!
 37.2: Test BPF prologue generation                           : Skip

However, in case when kernel doesn't support a test case it should
return 'Skip', 'FAILED!' should be reserved for kernel tests for when
the kernel supports a feature that then fails to work as advertised.

This patch checks environment before real testcase.

Signed-off-by: Wang Nan <wangnan0@huawei.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/tests/bpf.c | 37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/tools/perf/tests/bpf.c b/tools/perf/tests/bpf.c
index 33689a0..826b4b3 100644
--- a/tools/perf/tests/bpf.c
+++ b/tools/perf/tests/bpf.c
@@ -1,7 +1,11 @@
 #include <stdio.h>
 #include <sys/epoll.h>
+#include <util/util.h>
 #include <util/bpf-loader.h>
 #include <util/evlist.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <bpf/bpf.h>
 #include "tests.h"
 #include "llvm.h"
 #include "debug.h"
@@ -227,6 +231,36 @@ const char *test__bpf_subtest_get_desc(int i)
 	return bpf_testcase_table[i].desc;
 }
 
+static int check_env(void)
+{
+	int err;
+	unsigned int kver_int;
+	char license[] = "GPL";
+
+	struct bpf_insn insns[] = {
+		BPF_MOV64_IMM(BPF_REG_0, 1),
+		BPF_EXIT_INSN(),
+	};
+
+	err = fetch_kernel_version(&kver_int, NULL, 0);
+	if (err) {
+		pr_debug("Unable to get kernel version\n");
+		return err;
+	}
+
+	err = bpf_load_program(BPF_PROG_TYPE_KPROBE, insns,
+			       sizeof(insns) / sizeof(insns[0]),
+			       license, kver_int, NULL, 0);
+	if (err < 0) {
+		pr_err("Missing basic BPF support, skip this test: %s\n",
+		       strerror(errno));
+		return err;
+	}
+	close(err);
+
+	return 0;
+}
+
 int test__bpf(int i)
 {
 	int err;
@@ -239,6 +273,9 @@ int test__bpf(int i)
 		return TEST_SKIP;
 	}
 
+	if (check_env())
+		return TEST_SKIP;
+
 	err = __test__bpf(i);
 	return err;
 }
-- 
1.8.3.4
