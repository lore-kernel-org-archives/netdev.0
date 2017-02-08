From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v4 04/11] bpf: Use bpf_load_program() from the library
Date: Wed,  8 Feb 2017 21:49:33 +0100
Message-ID: <20170208204940.26023-5-mic@digikod.net>
References: <20170208204940.26023-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170208204940.26023-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_prog_load() with bpf_load_program() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                         |  6 +++---
 tools/lib/bpf/bpf.h                         |  4 ++--
 tools/testing/selftests/bpf/Makefile        |  4 +++-
 tools/testing/selftests/bpf/bpf_sys.h       | 21 ---------------------
 tools/testing/selftests/bpf/test_tag.c      |  6 ++++--
 tools/testing/selftests/bpf/test_verifier.c |  8 +++++---
 6 files changed, 17 insertions(+), 32 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 3ddb58a36d3c..58ce252073fa 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -42,7 +42,7 @@
 # endif
 #endif
 
-static __u64 ptr_to_u64(void *ptr)
+static __u64 ptr_to_u64(const void *ptr)
 {
 	return (__u64) (unsigned long) ptr;
 }
@@ -69,8 +69,8 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size,
 	return sys_bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
-		     size_t insns_cnt, char *license,
+int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf, size_t log_buf_sz)
 {
 	int fd;
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index a2f9853dd882..bc959a2de023 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -28,8 +28,8 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 
 /* Recommend log buffer size */
 #define BPF_LOG_BUF_SIZE 65536
-int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
-		     size_t insns_cnt, char *license,
+int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
 
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index f3d65ad53494..a35f564f66a1 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -1,4 +1,4 @@
-CFLAGS += -Wall -O2 -lcap -I../../../include/uapi
+CFLAGS += -Wall -O2 -lcap -I../../../include/uapi -I../../../lib
 
 test_objs = test_verifier test_tag test_maps test_lru_map test_lpm_map
 
@@ -7,6 +7,8 @@ TEST_FILES := $(test_objs)
 
 all: $(test_objs)
 
+$(test_objs): ../../../lib/bpf/bpf.o
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
index 878bd60da376..3bdd1ddda6c1 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -24,6 +24,8 @@
 #include <linux/bpf_perf_event.h>
 #include <linux/bpf.h>
 
+#include <bpf/bpf.h>
+
 #include "../../../include/linux/filter.h"
 
 #include "bpf_sys.h"
@@ -4535,9 +4537,9 @@ static void do_test_single(struct bpf_test *test, bool unpriv,
 
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
