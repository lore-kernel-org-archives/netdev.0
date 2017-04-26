From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/5] bpf: provide a generic macro for percpu values for selftests
Date: Thu, 27 Apr 2017 01:39:35 +0200
Message-ID: <9815eeb71f5507aa3f5335baf52d5c0cc7e7bdc0.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57409 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754581AbdDZXk5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:40:57 -0400
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
In-Reply-To: <cover.1493249192.git.daniel@iogearbox.net>
References: <cover.1493249192.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To overcome bugs as described and fixed in 89087c456fb5 ("bpf: Fix
values type used in test_maps"), provide a generic BPF_DECLARE_PERCPU()
and bpf_percpu() accessor macro for all percpu map values used in
tests.

Declaring variables works as follows (also works for structs):

  BPF_DECLARE_PERCPU(uint32_t, my_value);

They can then be accessed normally as uint32_t type through:

  bpf_percpu(my_value, <cpu_nr>)

For example:

  bpf_percpu(my_value, 0)++;

Implicitly, we make sure that the passed type is allocated and aligned
by gcc at least on a 8-byte boundary, so that it works together with
the map lookup/update syscall for percpu maps. We use it as a usage
example in test_maps, so that others are free to adapt this into their
code when necessary.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 tools/testing/selftests/bpf/bpf_util.h  |  7 +++++++
 tools/testing/selftests/bpf/test_maps.c | 37 ++++++++++++++++++---------------
 2 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/tools/testing/selftests/bpf/bpf_util.h b/tools/testing/selftests/bpf/bpf_util.h
index 7de2796..369e7d7 100644
--- a/tools/testing/selftests/bpf/bpf_util.h
+++ b/tools/testing/selftests/bpf/bpf_util.h
@@ -54,4 +54,11 @@ static inline unsigned int bpf_num_possible_cpus(void)
 	return possible_cpus;
 }
 
+#define __bpf_percpu_val_align	__attribute__((__aligned__(8)))
+
+#define BPF_DECLARE_PERCPU(type, name)				\
+	struct { type v; /* padding */ } __bpf_percpu_val_align	\
+		name[bpf_num_possible_cpus()]
+#define bpf_percpu(name, cpu) name[(cpu)].v
+
 #endif /* __BPF_UTIL__ */
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index a977c4f..9331452 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -137,20 +137,20 @@ static void test_hashmap_sizes(int task, void *data)
 static void test_hashmap_percpu(int task, void *data)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
-	long long value[nr_cpus];
+	BPF_DECLARE_PERCPU(long, value);
 	long long key, next_key, first_key;
 	int expected_key_mask = 0;
 	int fd, i;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
-			    sizeof(value[0]), 2, map_flags);
+			    sizeof(bpf_percpu(value, 0)), 2, map_flags);
 	if (fd < 0) {
 		printf("Failed to create hashmap '%s'!\n", strerror(errno));
 		exit(1);
 	}
 
 	for (i = 0; i < nr_cpus; i++)
-		value[i] = i + 100;
+		bpf_percpu(value, i) = i + 100;
 
 	key = 1;
 	/* Insert key=1 element. */
@@ -170,8 +170,9 @@ static void test_hashmap_percpu(int task, void *data)
 	/* Check that key=1 can be found. Value could be 0 if the lookup
 	 * was run from a different CPU.
 	 */
-	value[0] = 1;
-	assert(bpf_map_lookup_elem(fd, &key, value) == 0 && value[0] == 100);
+	bpf_percpu(value, 0) = 1;
+	assert(bpf_map_lookup_elem(fd, &key, value) == 0 &&
+	       bpf_percpu(value, 0) == 100);
 
 	key = 2;
 	/* Check that key=2 is not found. */
@@ -211,7 +212,7 @@ static void test_hashmap_percpu(int task, void *data)
 		assert(bpf_map_lookup_elem(fd, &next_key, value) == 0);
 
 		for (i = 0; i < nr_cpus; i++)
-			assert(value[i] == i + 100);
+			assert(bpf_percpu(value, i) == i + 100);
 
 		key = next_key;
 	}
@@ -296,34 +297,36 @@ static void test_arraymap(int task, void *data)
 static void test_arraymap_percpu(int task, void *data)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
+	BPF_DECLARE_PERCPU(long, values);
 	int key, next_key, fd, i;
-	long long values[nr_cpus];
 
 	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-			    sizeof(values[0]), 2, 0);
+			    sizeof(bpf_percpu(values, 0)), 2, 0);
 	if (fd < 0) {
 		printf("Failed to create arraymap '%s'!\n", strerror(errno));
 		exit(1);
 	}
 
 	for (i = 0; i < nr_cpus; i++)
-		values[i] = i + 100;
+		bpf_percpu(values, i) = i + 100;
 
 	key = 1;
 	/* Insert key=1 element. */
 	assert(bpf_map_update_elem(fd, &key, values, BPF_ANY) == 0);
 
-	values[0] = 0;
+	bpf_percpu(values, 0) = 0;
 	assert(bpf_map_update_elem(fd, &key, values, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* Check that key=1 can be found. */
-	assert(bpf_map_lookup_elem(fd, &key, values) == 0 && values[0] == 100);
+	assert(bpf_map_lookup_elem(fd, &key, values) == 0 &&
+	       bpf_percpu(values, 0) == 100);
 
 	key = 0;
 	/* Check that key=0 is also found and zero initialized. */
 	assert(bpf_map_lookup_elem(fd, &key, values) == 0 &&
-	       values[0] == 0 && values[nr_cpus - 1] == 0);
+	       bpf_percpu(values, 0) == 0 &&
+	       bpf_percpu(values, nr_cpus - 1) == 0);
 
 	/* Check that key=2 cannot be inserted due to max_entries limit. */
 	key = 2;
@@ -353,15 +356,15 @@ static void test_arraymap_percpu(int task, void *data)
 static void test_arraymap_percpu_many_keys(void)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
+	BPF_DECLARE_PERCPU(long, values);
 	/* nr_keys is not too large otherwise the test stresses percpu
 	 * allocator more than anything else
 	 */
 	unsigned int nr_keys = 2000;
-	long long values[nr_cpus];
 	int key, fd, i;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-			    sizeof(values[0]), nr_keys, 0);
+			    sizeof(bpf_percpu(values, 0)), nr_keys, 0);
 	if (fd < 0) {
 		printf("Failed to create per-cpu arraymap '%s'!\n",
 		       strerror(errno));
@@ -369,19 +372,19 @@ static void test_arraymap_percpu_many_keys(void)
 	}
 
 	for (i = 0; i < nr_cpus; i++)
-		values[i] = i + 10;
+		bpf_percpu(values, i) = i + 10;
 
 	for (key = 0; key < nr_keys; key++)
 		assert(bpf_map_update_elem(fd, &key, values, BPF_ANY) == 0);
 
 	for (key = 0; key < nr_keys; key++) {
 		for (i = 0; i < nr_cpus; i++)
-			values[i] = 0;
+			bpf_percpu(values, i) = 0;
 
 		assert(bpf_map_lookup_elem(fd, &key, values) == 0);
 
 		for (i = 0; i < nr_cpus; i++)
-			assert(values[i] == i + 10);
+			assert(bpf_percpu(values, i) == i + 10);
 	}
 
 	close(fd);
-- 
1.9.3
