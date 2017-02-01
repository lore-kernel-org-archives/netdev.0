From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 12/14] perf test: Add libbpf pinning test
Date: Wed,  1 Feb 2017 09:25:05 -0300
Message-ID: <20170201122507.29303-13-acme@kernel.org>
References: <20170201122507.29303-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:48626 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752342AbdBAMZs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 07:25:48 -0500
In-Reply-To: <20170201122507.29303-1-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>

Add a test for the newly added BPF object pinning functionality.

For example:

  # tools/perf/perf test 37
    37: BPF filter                                 :
    37.1: Basic BPF filtering                      : Ok
    37.2: BPF pinning                              : Ok
    37.3: BPF prologue generation                  : Ok
    37.4: BPF relocation checker                   : Ok

  # tools/perf/perf test 37 -v 2>&1 | grep pinned
    libbpf: pinned map '/sys/fs/bpf/perf_test/flip_table'
    libbpf: pinned program '/sys/fs/bpf/perf_test/func=SyS_epoll_wait/0'

Signed-off-by: Joe Stringer <joe@ovn.org>
Requested-and-Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170126212001.14103-7-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 tools/perf/tests/bpf.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 41 insertions(+), 1 deletion(-)

diff --git a/tools/perf/tests/bpf.c b/tools/perf/tests/bpf.c
index 92343f43e44a..1a04fe77487d 100644
--- a/tools/perf/tests/bpf.c
+++ b/tools/perf/tests/bpf.c
@@ -5,11 +5,13 @@
 #include <util/evlist.h>
 #include <linux/bpf.h>
 #include <linux/filter.h>
+#include <api/fs/fs.h>
 #include <bpf/bpf.h>
 #include "tests.h"
 #include "llvm.h"
 #include "debug.h"
 #define NR_ITERS       111
+#define PERF_TEST_BPF_PATH "/sys/fs/bpf/perf_test"
 
 #ifdef HAVE_LIBBPF_SUPPORT
 
@@ -54,6 +56,7 @@ static struct {
 	const char *msg_load_fail;
 	int (*target_func)(void);
 	int expect_result;
+	bool	pin;
 } bpf_testcase_table[] = {
 	{
 		LLVM_TESTCASE_BASE,
@@ -63,6 +66,17 @@ static struct {
 		"load bpf object failed",
 		&epoll_wait_loop,
 		(NR_ITERS + 1) / 2,
+		false,
+	},
+	{
+		LLVM_TESTCASE_BASE,
+		"BPF pinning",
+		"[bpf_pinning]",
+		"fix kbuild first",
+		"check your vmlinux setting?",
+		&epoll_wait_loop,
+		(NR_ITERS + 1) / 2,
+		true,
 	},
 #ifdef HAVE_BPF_PROLOGUE
 	{
@@ -73,6 +87,7 @@ static struct {
 		"check your vmlinux setting?",
 		&llseek_loop,
 		(NR_ITERS + 1) / 4,
+		false,
 	},
 #endif
 	{
@@ -83,6 +98,7 @@ static struct {
 		"libbpf error when dealing with relocation",
 		NULL,
 		0,
+		false,
 	},
 };
 
@@ -226,10 +242,34 @@ static int __test__bpf(int idx)
 		goto out;
 	}
 
-	if (obj)
+	if (obj) {
 		ret = do_test(obj,
 			      bpf_testcase_table[idx].target_func,
 			      bpf_testcase_table[idx].expect_result);
+		if (ret != TEST_OK)
+			goto out;
+		if (bpf_testcase_table[idx].pin) {
+			int err;
+
+			if (!bpf_fs__mount()) {
+				pr_debug("BPF filesystem not mounted\n");
+				ret = TEST_FAIL;
+				goto out;
+			}
+			err = mkdir(PERF_TEST_BPF_PATH, 0777);
+			if (err && errno != EEXIST) {
+				pr_debug("Failed to make perf_test dir: %s\n",
+					 strerror(errno));
+				ret = TEST_FAIL;
+				goto out;
+			}
+			if (bpf_object__pin(obj, PERF_TEST_BPF_PATH))
+				ret = TEST_FAIL;
+			if (rm_rf(PERF_TEST_BPF_PATH))
+				ret = TEST_FAIL;
+		}
+	}
+
 out:
 	bpf__clear();
 	return ret;
-- 
2.9.3
