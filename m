From: Ming Lei <tom.leiming@gmail.com>
Subject: [PATCH 9/9] samples/bpf: test percpu array map
Date: Mon, 11 Jan 2016 23:57:01 +0800
Message-ID: <1452527821-12276-10-git-send-email-tom.leiming@gmail.com>
References: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>,
	Martin KaFai Lau <kafai@fb.com>,
	Ming Lei <tom.leiming@gmail.com>
To: linux-kernel@vger.kernel.org, Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452527821-12276-1-git-send-email-tom.leiming@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
---
 samples/bpf/test_maps.c | 110 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 110 insertions(+)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 6299ee9..ff5d373 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -142,6 +142,106 @@ static void test_arraymap_sanity(int i, void *data)
 	close(map_fd);
 }
 
+static int handle_one_cpu(unsigned cpu, void *val_cpu, void *val)
+{
+	unsigned long *cnt = val;
+
+	*cnt += *(long *)val_cpu;
+	return 0;
+}
+
+
+static void test_percpu_arraymap_all_cpu_sanity(int i)
+{
+	int key, map_fd;
+	unsigned long value = 0;
+	unsigned long val_cpu;
+	unsigned cpu;
+	unsigned nr_keys = 2;
+	unsigned nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY_PERCPU, sizeof(key),
+				sizeof(value), nr_keys);
+	if (map_fd < 0) {
+		printf("failed to create arraymap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	for (key = 0; key < nr_keys; key++) {
+		for (cpu = 0; cpu < nr_cpus; cpu++) {
+			val_cpu = key;
+			assert(bpf_update_elem_percpu(map_fd, &key, &val_cpu,
+						      BPF_ANY, cpu) == 0);
+		}
+	}
+
+	for (key = 0; key < nr_keys; key++) {
+		assert(bpf_lookup_elem_allcpu(map_fd, &key, &val_cpu,
+					      &value, handle_one_cpu) == 0);
+		assert(value == nr_cpus * key);
+	}
+
+	close(map_fd);
+}
+
+static void test_percpu_arraymap_single_cpu_sanity(int i, void *data)
+{
+	int key, next_key, map_fd;
+	long long value;
+	unsigned cpu = *(unsigned *)data;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY_PERCPU, sizeof(key),
+				sizeof(value), 2);
+	if (map_fd < 0) {
+		printf("failed to create arraymap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* insert key=1 element */
+	assert(bpf_update_elem_percpu(map_fd, &key, &value, BPF_ANY, cpu) == 0);
+
+	value = 0;
+	assert(bpf_update_elem_percpu(map_fd, &key, &value, BPF_NOEXIST,
+				      cpu) == -1 && errno == EEXIST);
+
+	/* check that key=1 can be found */
+	assert(bpf_lookup_elem_percpu(map_fd, &key, &value, cpu) == 0 &&
+				      value == 1234);
+
+	key = 0;
+	/* check that key=0 is also found and zero initialized */
+	assert(bpf_lookup_elem_percpu(map_fd, &key, &value, cpu) == 0 &&
+				      value == 0);
+
+
+	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
+	 * due to max_entries limit
+	 */
+	key = 2;
+	assert(bpf_update_elem_percpu(map_fd, &key, &value, BPF_EXIST,
+				      cpu) == -1 && errno == E2BIG);
+
+	/* check that key = 2 doesn't exist */
+	assert(bpf_lookup_elem_percpu(map_fd, &key, &value, cpu) == -1 &&
+				      errno == ENOENT);
+
+	/* iterate over two elements */
+	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
+	       next_key == 0);
+	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
+	       next_key == 1);
+	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	/* delete shouldn't succeed */
+	key = 1;
+	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
+
+	close(map_fd);
+}
+
 #define MAP_SIZE (32 * 1024)
 static void test_map_large(void)
 {
@@ -281,8 +381,18 @@ static void test_map_parallel(void)
 
 int main(void)
 {
+	int cpu;
+	unsigned data;
+
 	test_hashmap_sanity(0, NULL);
 	test_arraymap_sanity(0, NULL);
+
+	for (cpu = 0; cpu < sysconf(_SC_NPROCESSORS_CONF); cpu++) {
+		data = cpu;
+		test_percpu_arraymap_single_cpu_sanity(0, &data);
+	}
+	test_percpu_arraymap_all_cpu_sanity(0);
+
 	test_map_large();
 	test_map_parallel();
 	test_map_stress();
-- 
1.9.1
