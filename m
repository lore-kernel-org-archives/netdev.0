From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v4 3/3] samples/bpf: add lpm-trie benchmark
Date: Sat, 21 Jan 2017 17:26:13 +0100
Message-ID: <20170121162613.4159-4-daniel@zonque.org>
References: <20170121162613.4159-1-daniel@zonque.org>
Cc: dh.herrmann@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, davem@davemloft.net
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:36638 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750876AbdAUQ0j (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 21 Jan 2017 11:26:39 -0500
In-Reply-To: <20170121162613.4159-1-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Herrmann <dh.herrmann@gmail.com>

Extend the map_perf_test_{user,kern}.c infrastructure to stress test
lpm-trie lookups. We hook into the kprobe on sys_gettid() and measure
the latency depending on trie size and lookup count.

On my Intel Haswell i7-6400U, a single gettid() syscall with an empty
bpf program takes roughly 6.5us on my system. Lookups in empty tries
take ~1.8us on first try, ~0.9us on retries. Lookups in tries with 8192
entries take ~7.1us (on the first _and_ any subsequent try).

Signed-off-by: David Herrmann <dh.herrmann@gmail.com>
Reviewed-by: Daniel Mack <daniel@zonque.org>
---
 samples/bpf/map_perf_test_kern.c | 30 ++++++++++++++++++++++++
 samples/bpf/map_perf_test_user.c | 49 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/samples/bpf/map_perf_test_kern.c b/samples/bpf/map_perf_test_kern.c
index 7ee1574..a91872a 100644
--- a/samples/bpf/map_perf_test_kern.c
+++ b/samples/bpf/map_perf_test_kern.c
@@ -57,6 +57,14 @@ struct bpf_map_def SEC("maps") percpu_hash_map_alloc = {
 	.map_flags = BPF_F_NO_PREALLOC,
 };
 
+struct bpf_map_def SEC("maps") lpm_trie_map_alloc = {
+	.type = BPF_MAP_TYPE_LPM_TRIE,
+	.key_size = 8,
+	.value_size = sizeof(long),
+	.max_entries = 10000,
+	.map_flags = BPF_F_NO_PREALLOC,
+};
+
 SEC("kprobe/sys_getuid")
 int stress_hmap(struct pt_regs *ctx)
 {
@@ -135,5 +143,27 @@ int stress_percpu_lru_hmap_alloc(struct pt_regs *ctx)
 	return 0;
 }
 
+SEC("kprobe/sys_gettid")
+int stress_lpm_trie_map_alloc(struct pt_regs *ctx)
+{
+	union {
+		u32 b32[2];
+		u8 b8[8];
+	} key;
+	unsigned int i;
+
+	key.b32[0] = 32;
+	key.b8[4] = 192;
+	key.b8[5] = 168;
+	key.b8[6] = 0;
+	key.b8[7] = 1;
+
+#pragma clang loop unroll(full)
+	for (i = 0; i < 32; ++i)
+		bpf_map_lookup_elem(&lpm_trie_map_alloc, &key);
+
+	return 0;
+}
+
 char _license[] SEC("license") = "GPL";
 u32 _version SEC("version") = LINUX_VERSION_CODE;
diff --git a/samples/bpf/map_perf_test_user.c b/samples/bpf/map_perf_test_user.c
index 9505b4d..680260a 100644
--- a/samples/bpf/map_perf_test_user.c
+++ b/samples/bpf/map_perf_test_user.c
@@ -37,6 +37,7 @@ static __u64 time_get_ns(void)
 #define PERCPU_HASH_KMALLOC	(1 << 3)
 #define LRU_HASH_PREALLOC	(1 << 4)
 #define PERCPU_LRU_HASH_PREALLOC	(1 << 5)
+#define LPM_KMALLOC		(1 << 6)
 
 static int test_flags = ~0;
 
@@ -112,6 +113,18 @@ static void test_percpu_hash_kmalloc(int cpu)
 	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
 }
 
+static void test_lpm_kmalloc(int cpu)
+{
+	__u64 start_time;
+	int i;
+
+	start_time = time_get_ns();
+	for (i = 0; i < MAX_CNT; i++)
+		syscall(__NR_gettid);
+	printf("%d:lpm_perf kmalloc %lld events per sec\n",
+	       cpu, MAX_CNT * 1000000000ll / (time_get_ns() - start_time));
+}
+
 static void loop(int cpu)
 {
 	cpu_set_t cpuset;
@@ -137,6 +150,9 @@ static void loop(int cpu)
 
 	if (test_flags & PERCPU_LRU_HASH_PREALLOC)
 		test_percpu_lru_hash_prealloc(cpu);
+
+	if (test_flags & LPM_KMALLOC)
+		test_lpm_kmalloc(cpu);
 }
 
 static void run_perf_test(int tasks)
@@ -162,6 +178,37 @@ static void run_perf_test(int tasks)
 	}
 }
 
+static void fill_lpm_trie(void)
+{
+	struct bpf_lpm_trie_key *key;
+	unsigned long value = 0;
+	unsigned int i;
+	int r;
+
+	key = alloca(sizeof(*key) + 4);
+	key->prefixlen = 32;
+
+	for (i = 0; i < 512; ++i) {
+		key->prefixlen = rand() % 33;
+		key->data[0] = rand() & 0xff;
+		key->data[1] = rand() & 0xff;
+		key->data[2] = rand() & 0xff;
+		key->data[3] = rand() & 0xff;
+		r = bpf_map_update_elem(map_fd[6], key, &value, 0);
+		assert(!r);
+	}
+
+	key->prefixlen = 32;
+	key->data[0] = 192;
+	key->data[1] = 168;
+	key->data[2] = 0;
+	key->data[3] = 1;
+	value = 128;
+
+	r = bpf_map_update_elem(map_fd[6], key, &value, 0);
+	assert(!r);
+}
+
 int main(int argc, char **argv)
 {
 	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
@@ -182,6 +229,8 @@ int main(int argc, char **argv)
 		return 1;
 	}
 
+	fill_lpm_trie();
+
 	run_perf_test(num_cpu);
 
 	return 0;
-- 
2.9.3
