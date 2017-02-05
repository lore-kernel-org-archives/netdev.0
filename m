From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1 6/7] bpf: Use the bpf_load_program() from the library
Date: Mon,  6 Feb 2017 00:14:27 +0100
Message-ID: <20170205231428.23846-6-mic@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170205231428.23846-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_prog_load() with bpf_load_program() calls.

Use the tools include directory instead of the installed one to allow
builds from other kernels.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/testing/selftests/bpf/Makefile        |  6 +++++-
 tools/testing/selftests/bpf/bpf_sys.h       | 21 ---------------------
 tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
 tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
 4 files changed, 14 insertions(+), 27 deletions(-)

diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 769a6cb42b4b..712861492278 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,12 +1,16 @@
-CFLAGS += -Wall -O2 -I../../../../usr/include
+CFLAGS += -Wall -O2 -I../../../include/uapi -I../../../lib
 
 test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
 TEST_PROGS := $(test_objs) test_kmod.sh
 TEST_FILES := $(test_objs)
+LIBBPF := ../../../lib/bpf/bpf.o
 
 all: $(test_objs)
 
+test_verifier: $(LIBBPF)
+test_tag: $(LIBBPF)
+
 include ../lib.mk
 
 clean:
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index 6b4565f2a3f2..e7bbe3e5402e 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -84,25 +84,4 @@ static inline int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
 	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-static inline int bpf_prog_load(enum bpf_prog_type type,
-				const struct bpf_insn *insns, size_t size_insns,
-				const char *license, char *log, size_t size_log)
-{
-	union bpf_attr attr = {};
-
-	attr.prog_type = type;
-	attr.insns = bpf_ptr_to_u64(insns);
-	attr.insn_cnt = size_insns / sizeof(struct bpf_insn);
-	attr.license = bpf_ptr_to_u64(license);
-
-	if (size_log > 0) {
-		attr.log_buf = bpf_ptr_to_u64(log);
-		attr.log_size = size_log;
-		attr.log_level = 1;
-		log[0] = 0;
-	}
-
-	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
-}
-
 #endif /* __BPF_SYS__ */
diff --git a/tools/testing/selftests/bpf/test_tag.c b/tools/testing/selftests/bpf/test_tag.c
index 5f7c602f47d1..b77dc4b03e77 100644
--- a/tools/testing/selftests/bpf/test_tag.c
+++ b/tools/testing/selftests/bpf/test_tag.c
@@ -16,6 +16,8 @@
 #include <linux/bpf.h>
 #include <linux/if_alg.h>
 
+#include <bpf/bpf.h>
+
 #include "../../../include/linux/filter.h"
 
 #include "bpf_sys.h"
@@ -55,8 +57,8 @@ static int bpf_try_load_prog(int insns, int fd_map,
 	int fd_prog;
 
 	bpf_filler(insns, fd_map);
-	fd_prog = bpf_prog_load(BPF_PROG_TYPE_SCHED_CLS, prog, insns *
-				sizeof(struct bpf_insn), "", NULL, 0);
+	fd_prog = bpf_load_program(BPF_PROG_TYPE_SCHED_CLS, prog, insns, "", 0,
+			NULL, 0);
 	assert(fd_prog > 0);
 	if (fd_map > 0)
 		bpf_filler(insns, 0);
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0d0912c7f03c..04a549e54f61 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -23,6 +23,8 @@
 #include <linux/bpf_perf_event.h>
 #include <linux/bpf.h>
 
+#include <bpf/bpf.h>
+
 #include "../../../include/linux/filter.h"
 
 #include "bpf_sys.h"
@@ -4456,9 +4458,9 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
 	do_test_fixup(test, prog, &fd_f1, &fd_f2, &fd_f3);
 
-	fd_prog = bpf_prog_load(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
-				prog, prog_len * sizeof(struct bpf_insn),
-				"GPL", bpf_vlog, sizeof(bpf_vlog));
+	fd_prog = bpf_load_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
+				prog, prog_len, "GPL", 0, bpf_vlog,
+				sizeof(bpf_vlog));
 
 	expected_ret = unpriv && test->result_unpriv != UNDEF ?
 		       test->result_unpriv : test->result;
-- 
2.11.0
