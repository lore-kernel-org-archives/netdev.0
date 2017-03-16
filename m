From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 6/6] samples/bpf: add map_lookup microbenchmark
Date: Wed, 15 Mar 2017 18:26:44 -0700
Message-ID: <1489627604-2288703-7-git-send-email-ast@fb.com>
References: <1489627604-2288703-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Fengguang Wu <fengguang.wu@intel.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:38459 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750895AbdCPB0r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 21:26:47 -0400
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2G1PRPU024782
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:45 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 297au1sqf7-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 18:26:45 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 9dda798409e711e7bf680002c9dfb610-186a36e0 for <netdev@vger.kernel.org>;        Wed,
 15 Mar 2017 18:26:44 -0700
In-Reply-To: <1489627604-2288703-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

$ map_perf_test 128
speed of HASH bpf_map_lookup_elem() in lookups per second
	w/o JIT		w/JIT
before	46M		58M
after	42M		74M

perf report
before:
    54.23%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
    14.24%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
     8.84%  map_perf_test  [kernel.kallsyms]  [k] htab_map_lookup_elem
     5.93%  map_perf_test  [kernel.kallsyms]  [k] bpf_map_lookup_elem
     2.30%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     1.49%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

after:
    60.03%  map_perf_test  [kernel.kallsyms]  [k] __htab_map_lookup_elem
    18.07%  map_perf_test  [kernel.kallsyms]  [k] lookup_elem_raw
     2.91%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     1.94%  map_perf_test  [kernel.kallsyms]  [k] _einittext
     1.90%  map_perf_test  [kernel.kallsyms]  [k] __audit_syscall_exit
     1.72%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

Notice that bpf_map_lookup_elem() and htab_map_lookup_elem() are trivial
functions, yet they take sizeable amount of cpu time.
htab_map_gen_lookup() removes bpf_map_lookup_elem() and converts
htab_map_lookup_elem() into three BPF insns which causing cpu time
for bpf_prog_da4fc6a3f41761a2() slightly increase.

$ map_perf_test 256
speed of ARRAY bpf_map_lookup_elem() in lookups per second
	w/o JIT		w/JIT
before	97M		174M
after	64M		280M

before:
    37.33%  map_perf_test  [kernel.kallsyms]  [k] array_map_lookup_elem
    13.95%  map_perf_test  [kernel.kallsyms]  [k] bpf_map_lookup_elem
     6.54%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     4.57%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

after:
    32.86%  map_perf_test  [kernel.kallsyms]  [k] bpf_prog_da4fc6a3f41761a2
     6.54%  map_perf_test  [kernel.kallsyms]  [k] kprobe_ftrace_handler

array_map_gen_lookup() removes calls to array_map_lookup_elem()
and bpf_map_lookup_elem() and replaces them with 7 bpf insns.

The performance without JIT is slower, since executing extra insns
in the interpreter is slower than running native C code,
but with JIT the performance gains are obvious,
since native C->x86 code is replaced with fewer bpf->x86 instructions.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/map_perf_test_kern.c | 33 +++++++++++++++++++++++++++++++++
 samples/bpf/map_perf_test_user.c | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 65 insertions(+)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index a91872a97742..9da2a3441b0a 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -65,6 +65,13 @@ struct bpf_map_def SEC("maps") lpm_trie_map_alloc = {
 	.map_flags = BPF_F_NO_PREALLOC,
 };
 
+struct bpf_map_def SEC("maps") array_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = MAX_ENTRIES,
+};
+
 SEC("kprobe/sys_getuid")
 int stress_hmap(struct pt_regs *ctx)
 {
@@ -165,5 +172,31 @@ int stress_lpm_trie_map_alloc(struct pt_regs *ctx)
 	return 0;
 }
 
+SEC("kprobe/sys_getpgid")
+int stress_hash_map_lookup(struct pt_regs *ctx)
+{
+	u32 key = 1, i;
+	long *value;
+
+#pragma clang loop unroll(full)
+	for (i = 0; i < 64; ++i)
+		value = bpf_map_lookup_elem(&hash_map, &key);
+
+	return 0;
+}
+
+SEC("kprobe/sys_getpgrp")
+int stress_array_map_lookup(struct pt_regs *ctx)
+{
+	u32 key = 1, i;
+	long *value;
+
+#pragma clang loop unroll(full)
+	for (i = 0; i < 64; ++i)
+		value = bpf_map_lookup_elem(&array_map, &key);
+
+	return 0;
+}
+
 char _license[] SEC("license") = "GPL";
 u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 680260a91f50..e29ff318a793 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -38,6 +38,8 @@ static __u64 time_get_ns(void)
 #define LRU_HASH_PREALLOC	(1 << 4)
 #define PERCPU_LRU_HASH_PREALLOC	(1 << 5)
 #define LPM_KMALLOC		(1 << 6)
+#define HASH_LOOKUP		(1 << 7)
+#define ARRAY_LOOKUP		(1 << 8)
 
 static int test_flags = ~0;
 
@@ -125,6 +127,30 @@ static void test_lpm_kmalloc(int cpu)
 	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
 }
 
+static void test_hash_lookup(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_getpgid, 0);
+	printf("%d:hash_lookup %lld lookups per sec\n",
+	       cpu, MAX_CNT * 1000000000ll * 64 / (time_get_ns() - start_time));
+}
+
+static void test_array_lookup(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_getpgrp, 0);
+	printf("%d:array_lookup %lld lookups per sec\n",
+	       cpu, MAX_CNT * 1000000000ll * 64 / (time_get_ns() - start_time));
+}
+
 static void loop(int cpu)
 {
 	cpu_set_t cpuset;
@@ -153,6 +179,12 @@ static void loop(int cpu)
 
 	if (test_flags & LPM_KMALLOC)
 		test_lpm_kmalloc(cpu);
+
+	if (test_flags & HASH_LOOKUP)
+		test_hash_lookup(cpu);
+
+	if (test_flags & ARRAY_LOOKUP)
+		test_array_lookup(cpu);
 }
 
 static void run_perf_test(int tasks)
-- 
2.8.0
