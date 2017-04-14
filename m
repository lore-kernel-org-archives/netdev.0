From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/6] bpf: lru: Refactor LRU map tests in map_perf_test
Date: Fri, 14 Apr 2017 10:30:27 -0700
Message-ID: <20170414173030.2853860-4-kafai@fb.com>
References: <20170414173030.2853860-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:58144 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754091AbdDNRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 13:30:32 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
        by mx0b-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3EHMVct016626
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0b-00082601.pphosted.com with ESMTP id 29tp48tret-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 10:30:32 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.102.107.97) with ESMTP id
 0e9753c4213811e7aaef0002c99331b0-b29f29a0 for <netdev@vger.kernel.org>;        Fri,
 14 Apr 2017 10:30:30 -0700
In-Reply-To: <20170414173030.2853860-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One more LRU test will be added later in this patch series.
In this patch, we first move all existing LRU map tests into
a single syscall (connect) first so that the future new
LRU test can be added without hunting another syscall.

One of the map name is also changed from percpu_lru_hash_map
to nocommon_lru_hash_map to avoid the confusion with percpu_hash_map.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/map_perf_test_kern.c | 43 +++++++++++++++++++++++---------
 samples/bpf/map_perf_test_user.c | 53 +++++++++++++++++++++++++++-------------
 2 files changed, 67 insertions(+), 29 deletions(-)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 9da2a3441b0a..404ed53b8a53 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -26,7 +26,7 @@ struct bpf_map_def SEC("maps") lru_hash_map = {
 	.max_entries = 10000,
 };
 
-struct bpf_map_def SEC("maps") percpu_lru_hash_map = {
+struct bpf_map_def SEC("maps") nocommon_lru_hash_map = {
 	.type = BPF_MAP_TYPE_LRU_HASH,
 	.key_size = sizeof(u32),
 	.value_size = sizeof(long),
@@ -100,6 +100,7 @@ int stress_percpu_hmap(struct pt_regs *ctx)
 		bpf_map_delete_elem(&percpu_hash_map, &key);
 	return 0;
 }
+
 SEC("kprobe/sys_getgid")
 int stress_hmap_alloc(struct pt_regs *ctx)
 {
@@ -128,24 +129,42 @@ int stress_percpu_hmap_alloc(struct pt_regs *ctx)
 	return 0;
 }
 
-SEC("kprobe/sys_getpid")
+SEC("kprobe/sys_connect")
 int stress_lru_hmap_alloc(struct pt_regs *ctx)
 {
-	u32 key = bpf_get_prandom_u32();
+	struct sockaddr_in6 *in6;
+	u16 test_case, dst6[8];
+	int addrlen, ret;
+	char fmt[] = "Failed at stress_lru_hmap_alloc. ret:%d\n";
 	long val = 1;
+	u32 key = bpf_get_prandom_u32();
 
-	bpf_map_update_elem(&lru_hash_map, &key, &val, BPF_ANY);
+	in6 = (struct sockaddr_in6 *)PT_REGS_PARM2(ctx);
+	addrlen = (int)PT_REGS_PARM3(ctx);
 
-	return 0;
-}
+	if (addrlen != sizeof(*in6))
+		return 0;
 
-SEC("kprobe/sys_getppid")
-int stress_percpu_lru_hmap_alloc(struct pt_regs *ctx)
-{
-	u32 key = bpf_get_prandom_u32();
-	long val = 1;
+	ret = bpf_probe_read(dst6, sizeof(dst6), &in6->sin6_addr);
+	if (ret)
+		goto done;
+
+	if (dst6[0] != 0xdead || dst6[1] != 0xbeef)
+		return 0;
+
+	test_case = dst6[7];
+
+	if (test_case == 0)
+		ret = bpf_map_update_elem(&lru_hash_map, &key, &val, BPF_ANY);
+	else if (test_case == 1)
+		ret = bpf_map_update_elem(&nocommon_lru_hash_map, &key, &val,
+					  BPF_ANY);
+	else
+		ret = -EINVAL;
 
-	bpf_map_update_elem(&percpu_lru_hash_map, &key, &val, BPF_ANY);
+done:
+	if (ret)
+		bpf_trace_printk(fmt, sizeof(fmt), ret);
 
 	return 0;
 }
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index e29ff318a793..51cb8f238aa2 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -18,6 +18,9 @@
 #include <string.h>
 #include <time.h>
 #include <sys/resource.h>
+#include <arpa/inet.h>
+#include <errno.h>
+
 #include "libbpf.h"
 #include "bpf_load.h"
 
@@ -36,7 +39,7 @@ static __u64 time_get_ns(void)
 #define HASH_KMALLOC		(1 << 2)
 #define PERCPU_HASH_KMALLOC	(1 << 3)
 #define LRU_HASH_PREALLOC	(1 << 4)
-#define PERCPU_LRU_HASH_PREALLOC	(1 << 5)
+#define NOCOMMON_LRU_HASH_PREALLOC	(1 << 5)
 #define LPM_KMALLOC		(1 << 6)
 #define HASH_LOOKUP		(1 << 7)
 #define ARRAY_LOOKUP		(1 << 8)
@@ -55,28 +58,44 @@ static void test_hash_prealloc(int cpu)
 	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
 }
 
-static void test_lru_hash_prealloc(int cpu)
+static void do_test_lru(int lru_test_flag, int cpu)
 {
+	struct sockaddr_in6 in6 = { .sin6_family = AF_INET6 };
+	const char *test_name;
 	__u64 start_time;
-	int i;
+	int i, ret;
+
+	in6.sin6_addr.s6_addr16[0] = 0xdead;
+	in6.sin6_addr.s6_addr16[1] = 0xbeef;
+
+	if (lru_test_flag & LRU_HASH_PREALLOC) {
+		test_name = "lru_hash_map_perf";
+		in6.sin6_addr.s6_addr16[7] = 0;
+	} else if (lru_test_flag & NOCOMMON_LRU_HASH_PREALLOC) {
+		test_name = "nocommon_lru_hash_map_perf";
+		in6.sin6_addr.s6_addr16[7] = 1;
+	} else {
+		assert(0);
+	}
 
 	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
-		syscall(__NR_getpid);
-	printf("%d:lru_hash_map_perf pre-alloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+	for (i = 0; i < MAX_CNT; i++) {
+		ret = connect(-1, (const struct sockaddr *)&in6, sizeof(in6));
+		assert(ret == -1 && errno == EBADF);
+	}
+	printf("%d:%s pre-alloc %lld events per sec\n",
+	       cpu, test_name,
+	       MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
 }
 
-static void test_percpu_lru_hash_prealloc(int cpu)
+static void test_lru_hash_prealloc(int cpu)
 {
-	__u64 start_time;
-	int i;
+	do_test_lru(LRU_HASH_PREALLOC, cpu);
+}
 
-	start_time = time_get_ns();
-	for (i = 0; i < MAX_CNT; i++)
-		syscall(__NR_getppid);
-	printf("%d:lru_hash_map_perf pre-alloc %lld events per sec\n",
-	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+static void test_nocommon_lru_hash_prealloc(int cpu)
+{
+	do_test_lru(NOCOMMON_LRU_HASH_PREALLOC, cpu);
 }
 
 static void test_percpu_hash_prealloc(int cpu)
@@ -174,8 +193,8 @@ static void loop(int cpu)
 	if (test_flags & LRU_HASH_PREALLOC)
 		test_lru_hash_prealloc(cpu);
 
-	if (test_flags & PERCPU_LRU_HASH_PREALLOC)
-		test_percpu_lru_hash_prealloc(cpu);
+	if (test_flags & NOCOMMON_LRU_HASH_PREALLOC)
+		test_nocommon_lru_hash_prealloc(cpu);
 
 	if (test_flags & LPM_KMALLOC)
 		test_lpm_kmalloc(cpu);
-- 
2.9.3
