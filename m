From: Joe Stringer <joe@ovn.org>
Subject: [PATCH perf/core REBASE 4/5] samples/bpf: Remove perf_event_open() declaration
Date: Wed, 14 Dec 2016 14:43:41 -0800
Message-ID: <20161214224342.12858-5-joe@ovn.org>
References: <20161214224342.12858-1-joe@ovn.org>
Cc: netdev@vger.kernel.org, wangnan0@huawei.com, ast@fb.com,
        daniel@iogearbox.net, acme@kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161214224342.12858-1-joe@ovn.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This declaration was made in samples/bpf/libbpf.c for convenience, but
there's already one in tools/perf/perf-sys.h. Reuse that one.

Committer notes:

Testing it:

  $ make -j4 O=../build/v4.9.0-rc8+ samples/bpf/
  make[1]: Entering directory '/home/build/v4.9.0-rc8+'
    CHK     include/config/kernel.release
    GEN     ./Makefile
    CHK     include/generated/uapi/linux/version.h
    Using /home/acme/git/linux as source for kernel
    CHK     include/generated/utsrelease.h
    CHK     include/generated/timeconst.h
    CHK     include/generated/bounds.h
    CHK     include/generated/asm-offsets.h
    CALL    /home/acme/git/linux/scripts/checksyscalls.sh
    HOSTCC  samples/bpf/test_verifier.o
    HOSTCC  samples/bpf/libbpf.o
    HOSTCC  samples/bpf/../../tools/lib/bpf/bpf.o
    HOSTCC  samples/bpf/test_maps.o
    HOSTCC  samples/bpf/sock_example.o
    HOSTCC  samples/bpf/bpf_load.o
<SNIP>
    HOSTLD  samples/bpf/trace_event
    HOSTLD  samples/bpf/sampleip
    HOSTLD  samples/bpf/tc_l2_redirect
  make[1]: Leaving directory '/home/build/v4.9.0-rc8+'
  $

Signed-off-by: Joe Stringer <joe@ovn.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Link: http://lkml.kernel.org/r/20161209024620.31660-7-joe@ovn.org
[ Use -I$(srctree)/tools/lib/ to support out of source code tree builds ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 samples/bpf/Makefile            | 2 ++
 samples/bpf/bpf_load.c          | 3 ++-
 samples/bpf/libbpf.c            | 7 -------
 samples/bpf/libbpf.h            | 3 ---
 samples/bpf/sampleip_user.c     | 3 ++-
 samples/bpf/trace_event_user.c  | 9 +++++----
 samples/bpf/trace_output_user.c | 3 ++-
 samples/bpf/tracex6_user.c      | 3 ++-
 8 files changed, 15 insertions(+), 18 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index add514e2984a..9718f664fedf 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -108,6 +108,8 @@ always += xdp_tx_iptunnel_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
 HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
+HOSTCFLAGS += -I$(srctree)/tools/lib/ -I$(srctree)/tools/include
+HOSTCFLAGS += -I$(srctree)/tools/perf
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_fds_example += -lelf
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index f5b186c46b7c..982c3be702d7 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -23,6 +23,7 @@
 #include <ctype.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "perf-sys.h"
 
 #define DEBUGFS "/sys/kernel/debug/tracing/"
 
@@ -178,7 +179,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	id = atoi(buf);
 	attr.config = id;
 
-	efd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
+	efd = sys_perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
 	if (efd < 0) {
 		printf("event %d fd %d err %s\n", id, efd, strerror(errno));
 		return -1;
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index d9af876b4a2c..bee473a494f1 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -34,10 +34,3 @@ int open_raw_sock(const char *name)
 
 	return sock;
 }
-
-int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
-		    int group_fd, unsigned long flags)
-{
-	return syscall(__NR_perf_event_open, attr, pid, cpu,
-		       group_fd, flags);
-}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index cc815624aacf..09aedc320009 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -188,7 +188,4 @@ struct bpf_insn;
 /* create RAW socket and bind to interface 'name' */
 int open_raw_sock(const char *name);
 
-struct perf_event_attr;
-int perf_event_open(struct perf_event_attr *attr, int pid, int cpu,
-		    int group_fd, unsigned long flags);
 #endif
diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
index 5ac5adf75931..be59d7dcbdde 100644
--- a/samples/bpf/sampleip_user.c
+++ b/samples/bpf/sampleip_user.c
@@ -21,6 +21,7 @@
 #include <sys/ioctl.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "perf-sys.h"
 
 #define DEFAULT_FREQ	99
 #define DEFAULT_SECS	5
@@ -49,7 +50,7 @@ static int sampling_start(int *pmu_fd, int freq)
 	};
 
 	for (i = 0; i < nr_cpus; i++) {
-		pmu_fd[i] = perf_event_open(&pe_sample_attr, -1 /* pid */, i,
+		pmu_fd[i] = sys_perf_event_open(&pe_sample_attr, -1 /* pid */, i,
 					    -1 /* group_fd */, 0 /* flags */);
 		if (pmu_fd[i] < 0) {
 			fprintf(stderr, "ERROR: Initializing perf sampling\n");
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index 704fe9fa77b2..0c5561d193a4 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -20,6 +20,7 @@
 #include <sys/resource.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "perf-sys.h"
 
 #define SAMPLE_FREQ 50
 
@@ -125,9 +126,9 @@ static void test_perf_event_all_cpu(struct perf_event_attr *attr)
 
 	/* open perf_event on all cpus */
 	for (i = 0; i < nr_cpus; i++) {
-		pmu_fd[i] = perf_event_open(attr, -1, i, -1, 0);
+		pmu_fd[i] = sys_perf_event_open(attr, -1, i, -1, 0);
 		if (pmu_fd[i] < 0) {
-			printf("perf_event_open failed\n");
+			printf("sys_perf_event_open failed\n");
 			goto all_cpu_err;
 		}
 		assert(ioctl(pmu_fd[i], PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
@@ -146,9 +147,9 @@ static void test_perf_event_task(struct perf_event_attr *attr)
 	int pmu_fd;
 
 	/* open task bound event */
-	pmu_fd = perf_event_open(attr, 0, -1, -1, 0);
+	pmu_fd = sys_perf_event_open(attr, 0, -1, -1, 0);
 	if (pmu_fd < 0) {
-		printf("perf_event_open failed\n");
+		printf("sys_perf_event_open failed\n");
 		return;
 	}
 	assert(ioctl(pmu_fd, PERF_EVENT_IOC_SET_BPF, prog_fd[0]) == 0);
diff --git a/samples/bpf/trace_output_user.c b/samples/bpf/trace_output_user.c
index 3bedd945def1..7449fac2819e 100644
--- a/samples/bpf/trace_output_user.c
+++ b/samples/bpf/trace_output_user.c
@@ -21,6 +21,7 @@
 #include <signal.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "perf-sys.h"
 
 static int pmu_fd;
 
@@ -159,7 +160,7 @@ static void test_bpf_perf_event(void)
 	};
 	int key = 0;
 
-	pmu_fd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
+	pmu_fd = sys_perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
 
 	assert(pmu_fd >= 0);
 	assert(bpf_map_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index 179297cb4d35..ca7874ed77f4 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -10,6 +10,7 @@
 #include <linux/bpf.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "perf-sys.h"
 
 #define SAMPLE_PERIOD  0x7fffffffffffffffULL
 
@@ -30,7 +31,7 @@ static void test_bpf_perf_event(void)
 	};
 
 	for (i = 0; i < nr_cpus; i++) {
-		pmu_fd[i] = perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
+		pmu_fd[i] = sys_perf_event_open(&attr_insn_pmu, -1/*pid*/, i/*cpu*/, -1/*group_fd*/, 0);
 		if (pmu_fd[i] < 0) {
 			printf("event syscall failed\n");
 			goto exit;
-- 
2.10.2
