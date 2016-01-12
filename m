From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 4/4] bpf: bpf_htab: Test for BPF_MAP_TYPE_PERCPU_HASH
Date: Tue, 12 Jan 2016 00:20:52 -0800
Message-ID: <1452586852-1575604-5-git-send-email-kafai@fb.com>
References: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Ming Lei <tom.leiming@gmail.com>,
	FB Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452586852-1575604-1-git-send-email-kafai@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A sanity test for BPF_MAP_TYPE_PERCPU_HASH.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 samples/bpf/libbpf.c    |  13 ++++++
 samples/bpf/libbpf.h    |   1 +
 samples/bpf/test_maps.c | 113 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 127 insertions(+)

diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 65a8d48..a9c5e61 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -54,6 +54,19 @@ int bpf_lookup_elem(int fd, void *key, void *value)
 	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
+int bpf_lookup_percpu_elem(int fd, void *key, void *value, unsigned int cpu)
+{
+	union bpf_attr attr = {
+		.map_fd = fd,
+		.key = ptr_to_u64(key),
+		.value = ptr_to_u64(value),
+		.cpu = cpu,
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_PERCPU_ELEM, &attr,
+		       sizeof(attr));
+}
+
 int bpf_delete_elem(int fd, void *key)
 {
 	union bpf_attr attr = {
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 014aacf..7759517 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -8,6 +8,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries);
 int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
 int bpf_lookup_elem(int fd, void *key, void *value);
+int bpf_lookup_percpu_elem(int fd, void *key, void *value, unsigned int cpu);
 int bpf_delete_elem(int fd, void *key);
 int bpf_get_next_key(int fd, void *key, void *next_key);
 
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 6299ee9..7b1dc3e 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -89,6 +89,118 @@ static void test_hashmap_sanity(int i, void *data)
 	close(map_fd);
 }
 
+/* sanity tests for percpu map API */
+static void test_percpu_hashmap_sanity(int i, void *data)
+{
+	long long key, next_key, value;
+	int expected_key_mask = 0;
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	int map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
+				sizeof(value), 2);
+	if (map_fd < 0) {
+		printf("failed to create hashmap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* insert key=1 element */
+	assert(!(expected_key_mask & key));
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	expected_key_mask |= key;
+
+	/* BPF_NOEXIST means: add new element if it doesn't exist */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       /* key=1 already exists */
+	       errno == EEXIST);
+
+	/* -1 is an invalid flag */
+	assert(bpf_update_elem(map_fd, &key, &value, -1) == -1 &&
+	       errno == EINVAL);
+
+	/* check that key=1 can be found. value could be 0 if the lookup
+	 * was run from a different cpu.
+	 */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 &&
+	       (value == 0 || value == 1234));
+
+	key = 2;
+	/* check that key=2 is not found */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+
+	/* BPF_EXIST means: update existing element */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
+	       /* key=2 is not there */
+	       errno == ENOENT);
+
+	/* insert key=2 element */
+	assert(!(expected_key_mask & key));
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+	expected_key_mask |= key;
+
+	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
+	 * due to max_entries limit
+	 */
+	key = 0;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* check that key = 0 doesn't exist */
+	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+
+	/* iterate over two elements */
+	while (!bpf_get_next_key(map_fd, &key, &next_key)) {
+		unsigned int cpu;
+		int found;
+
+		assert((expected_key_mask & next_key) == next_key);
+		expected_key_mask &= ~next_key;
+
+		found = 0;
+		for (cpu = 0; cpu < nr_cpus; cpu++) {
+			if (!bpf_lookup_percpu_elem(map_fd, &next_key,
+						    &value, cpu)) {
+				if (value == 1234) {
+					assert(!found);
+					found = 1;
+				} else {
+					assert(value == 0);
+				}
+			} else {
+				assert(errno == ENXIO);
+			}
+		}
+		assert(found);
+
+		key = next_key;
+	}
+	assert(errno == ENOENT);
+
+	/* Look up the value with an invalid CPU */
+	key = 1;
+	assert(bpf_lookup_percpu_elem(map_fd, &key, &value, nr_cpus) == -1 &&
+	       errno == EINVAL);
+
+	/* Update with BPF_EXIST */
+	key = 1;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
+
+	/* delete both elements */
+	key = 1;
+	assert(bpf_delete_elem(map_fd, &key) == 0);
+	key = 2;
+	assert(bpf_delete_elem(map_fd, &key) == 0);
+	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+
+	key = 0;
+	/* check that map is empty */
+	assert(bpf_get_next_key(map_fd, &key, &next_key) == -1 &&
+	       errno == ENOENT);
+	close(map_fd);
+}
+
 static void test_arraymap_sanity(int i, void *data)
 {
 	int key, next_key, map_fd;
@@ -282,6 +394,7 @@ static void test_map_parallel(void)
 int main(void)
 {
 	test_hashmap_sanity(0, NULL);
+	test_percpu_hashmap_sanity(0, NULL);
 	test_arraymap_sanity(0, NULL);
 	test_map_large();
 	test_map_parallel();
-- 
2.5.1
