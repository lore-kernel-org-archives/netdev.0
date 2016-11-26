From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 6/6] bpf: fix multiple issues in selftest suite and samples
Date: Sat, 26 Nov 2016 01:28:09 +0100
Message-ID: <25fab1a12b567babbe1030484cfc346a282cd263.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>,
        William Tu <u9012063@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42861 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751968AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) The test_lru_map and test_lru_dist fails building on my machine since
   the sys/resource.h header is not included.

2) test_verifier fails in one test case where we try to call an invalid
   function, since the verifier log output changed wrt printing function
   names.

3) Current selftest suite code relies on sysconf(_SC_NPROCESSORS_CONF) for
   retrieving the number of possible CPUs. This is broken at least in our
   scenario and really just doesn't work.

   glibc tries a number of things for retrieving _SC_NPROCESSORS_CONF.
   First it tries equivalent of /sys/devices/system/cpu/cpu[0-9]* | wc -l,
   if that fails, depending on the config, it either tries to count CPUs
   in /proc/cpuinfo, or returns the _SC_NPROCESSORS_ONLN value instead.
   If /proc/cpuinfo has some issue, it returns just 1 worst case. This
   oddity is nothing new [1], but semantics/behaviour seems to be settled.
   _SC_NPROCESSORS_ONLN will parse /sys/devices/system/cpu/online, if
   that fails it looks into /proc/stat for cpuX entries, and if also that
   fails for some reason, /proc/cpuinfo is consulted (and returning 1 if
   unlikely all breaks down).

   While that might match num_possible_cpus() from the kernel in some
   cases, it's really not guaranteed with CPU hotplugging, and can result
   in a buffer overflow since the array in user space could have too few
   number of slots, and on perpcu map lookup, the kernel will write beyond
   that memory of the value buffer.

   William Tu reported such mismatches:

     [...] The fact that sysconf(_SC_NPROCESSORS_CONF) != num_possible_cpu()
     happens when CPU hotadd is enabled. For example, in Fusion when
     setting vcpu.hotadd = "TRUE" or in KVM, setting ./qemu-system-x86_64
     -smp 2, maxcpus=4 ... the num_possible_cpu() will be 4 and sysconf()
     will be 2 [2]. [...]

   Documentation/cputopology.txt says /sys/devices/system/cpu/possible
   outputs cpu_possible_mask. That is the same as in num_possible_cpus(),
   so first step would be to fix the _SC_NPROCESSORS_CONF calls with our
   own implementation. Later, we could add support to bpf(2) for passing
   a mask via CPU_SET(3), for example, to just select a subset of CPUs.

   BPF samples code needs this fix as well (at least so that people stop
   copying this). Thus, define bpf_num_possible_cpus() once in selftests
   and import it from there for the sample code to avoid duplicating it.
   The remaining sysconf(_SC_NPROCESSORS_CONF) in samples are unrelated.

After all three issues are fixed, the test suite runs fine again:

  # make run_tests | grep self
  selftests: test_verifier [PASS]
  selftests: test_maps [PASS]
  selftests: test_lru_map [PASS]
  selftests: test_kmod.sh [PASS]

  [1] https://www.sourceware.org/ml/libc-alpha/2011-06/msg00079.html
  [2] https://www.mail-archive.com/netdev@vger.kernel.org/msg121183.html

Fixes: 3059303f59cf ("samples/bpf: update tracex[23] examples to use per-cpu maps")
Fixes: 86af8b4191d2 ("Add sample for adding simple drop program to link")
Fixes: df570f577231 ("samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_ARRAY")
Fixes: e15596717948 ("samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_HASH")
Fixes: ebb676daa1a3 ("bpf: Print function name in addition to function id")
Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: William Tu <u9012063@gmail.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/Makefile                        |  1 +
 samples/bpf/test_lru_dist.c                 |  5 +++-
 samples/bpf/tracex2_user.c                  |  4 ++-
 samples/bpf/tracex3_user.c                  |  6 +++--
 samples/bpf/xdp1_user.c                     |  4 ++-
 tools/testing/selftests/bpf/bpf_util.h      | 38 +++++++++++++++++++++++++++++
 tools/testing/selftests/bpf/test_lru_map.c  |  8 ++++--
 tools/testing/selftests/bpf/test_maps.c     |  7 +++---
 tools/testing/selftests/bpf/test_verifier.c |  2 +-
 9 files changed, 64 insertions(+), 11 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/bpf_util.h

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index fb17206..22b6407e 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -91,6 +91,7 @@ always += trace_event_kern.o
 always += sampleip_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
+HOSTCFLAGS += -I$(objtree)/tools/testing/selftests/bpf/
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
 HOSTLOADLIBES_fds_example += -lelf
diff --git a/samples/bpf/test_lru_dist.c b/samples/bpf/test_lru_dist.c
index 2859977..316230a 100644
--- a/samples/bpf/test_lru_dist.c
+++ b/samples/bpf/test_lru_dist.c
@@ -16,10 +16,13 @@
 #include <sched.h>
 #include <sys/wait.h>
 #include <sys/stat.h>
+#include <sys/resource.h>
 #include <fcntl.h>
 #include <stdlib.h>
 #include <time.h>
+
 #include "libbpf.h"
+#include "bpf_util.h"
 
 #define min(a, b) ((a) < (b) ? (a) : (b))
 #define offsetof(TYPE, MEMBER)	((size_t)&((TYPE *)0)->MEMBER)
@@ -510,7 +513,7 @@ int main(int argc, char **argv)
 
 	srand(time(NULL));
 
-	nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	nr_cpus = bpf_num_possible_cpus();
 	assert(nr_cpus != -1);
 	printf("nr_cpus:%d\n\n", nr_cpus);
 
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index ab5b19e..3e225e3 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -4,8 +4,10 @@
 #include <signal.h>
 #include <linux/bpf.h>
 #include <string.h>
+
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "bpf_util.h"
 
 #define MAX_INDEX	64
 #define MAX_STARS	38
@@ -36,8 +38,8 @@ struct hist_key {
 
 static void print_hist_for_pid(int fd, void *task)
 {
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	struct hist_key key = {}, next_key;
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
 	long values[nr_cpus];
 	char starstr[MAX_STARS];
 	long value;
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
index 48716f7..d0851cb 100644
--- a/samples/bpf/tracex3_user.c
+++ b/samples/bpf/tracex3_user.c
@@ -11,8 +11,10 @@
 #include <stdbool.h>
 #include <string.h>
 #include <linux/bpf.h>
+
 #include "libbpf.h"
 #include "bpf_load.h"
+#include "bpf_util.h"
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
 
@@ -20,7 +22,7 @@
 
 static void clear_stats(int fd)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	__u64 values[nr_cpus];
 	__u32 key;
 
@@ -77,7 +79,7 @@ static void print_banner(void)
 
 static void print_hist(int fd)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	__u64 total_events = 0;
 	long values[nr_cpus];
 	__u64 max_cnt = 0;
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index a5e109e..2b2150d 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -15,7 +15,9 @@
 #include <string.h>
 #include <sys/socket.h>
 #include <unistd.h>
+
 #include "bpf_load.h"
+#include "bpf_util.h"
 #include "libbpf.h"
 
 static int set_link_xdp_fd(int ifindex, int fd)
@@ -120,7 +122,7 @@ static void int_exit(int sig)
  */
 static void poll_stats(int interval)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	const unsigned int nr_keys = 256;
 	__u64 values[nr_cpus], prev[nr_keys][nr_cpus];
 	__u32 key;
diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
new file mode 100644
index 0000000..84a5d18
--- /dev/null
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -0,0 +1,38 @@
+#ifndef __BPF_UTIL__
+#define __BPF_UTIL__
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+
+static inline unsigned int bpf_num_possible_cpus(void)
+{
+	static const char *fcpu = "/sys/devices/system/cpu/possible";
+	unsigned int start, end, possible_cpus = 0;
+	char buff[128];
+	FILE *fp;
+
+	fp = fopen(fcpu, "r");
+	if (!fp) {
+		printf("Failed to open %s: '%s'!\n", fcpu, strerror(errno));
+		exit(1);
+	}
+
+	while (fgets(buff, sizeof(buff), fp)) {
+		if (sscanf(buff, "%u-%u", &start, &end) == 2) {
+			possible_cpus = start == 0 ? end + 1 : 0;
+			break;
+		}
+	}
+
+	fclose(fp);
+	if (!possible_cpus) {
+		printf("Failed to retrieve # possible CPUs!\n");
+		exit(1);
+	}
+
+	return possible_cpus;
+}
+
+#endif /* __BPF_UTIL__ */
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 627757e..b13fed5 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -12,10 +12,14 @@
 #include <string.h>
 #include <assert.h>
 #include <sched.h>
-#include <sys/wait.h>
 #include <stdlib.h>
 #include <time.h>
+
+#include <sys/wait.h>
+#include <sys/resource.h>
+
 #include "bpf_sys.h"
+#include "bpf_util.h"
 
 #define LOCAL_FREE_TARGET	(128)
 #define PERCPU_FREE_TARGET	(16)
@@ -559,7 +563,7 @@ int main(int argc, char **argv)
 
 	assert(!setrlimit(RLIMIT_MEMLOCK, &r));
 
-	nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	nr_cpus = bpf_num_possible_cpus();
 	assert(nr_cpus != -1);
 	printf("nr_cpus:%d\n\n", nr_cpus);
 
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index ee384f0..eedfef8 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -22,6 +22,7 @@
 #include <linux/bpf.h>
 
 #include "bpf_sys.h"
+#include "bpf_util.h"
 
 static int map_flags;
 
@@ -110,7 +111,7 @@ static void test_hashmap(int task, void *data)
 
 static void test_hashmap_percpu(int task, void *data)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	long long value[nr_cpus];
 	long long key, next_key;
 	int expected_key_mask = 0;
@@ -258,7 +259,7 @@ static void test_arraymap(int task, void *data)
 
 static void test_arraymap_percpu(int task, void *data)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	int key, next_key, fd, i;
 	long values[nr_cpus];
 
@@ -313,7 +314,7 @@ static void test_arraymap_percpu(int task, void *data)
 
 static void test_arraymap_percpu_many_keys(void)
 {
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_cpus = bpf_num_possible_cpus();
 	unsigned int nr_keys = 20000;
 	long values[nr_cpus];
 	int key, fd, i;
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
index 0ef8eaf..3c4a1fb 100644
--- a/tools/testing/selftests/bpf/test_verifier.c
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -285,7 +285,7 @@ struct test_val {
 			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, 1234567),
 			BPF_EXIT_INSN(),
 		},
-		.errstr = "invalid func 1234567",
+		.errstr = "invalid func unknown#1234567",
 		.result = REJECT,
 	},
 	{
-- 
1.9.3
