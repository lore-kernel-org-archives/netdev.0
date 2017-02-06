From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v2 2/8] bpf: Use bpf_map_update_elem() from the library
Date: Mon,  6 Feb 2017 23:49:35 +0100
Message-ID: <20170206224941.14739-2-mic@digikod.net>
References: <20170206224941.14739-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Shuah Khan <shuah@kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206224941.14739-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace bpf_map_update() with bpf_map_update_elem() calls.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Shuah Khan <shuah@kernel.org>
---
 tools/lib/bpf/bpf.c                        |  5 +--
 tools/lib/bpf/bpf.h                        |  2 +-
 tools/testing/selftests/bpf/bpf_sys.h      | 13 ------
 tools/testing/selftests/bpf/test_lpm_map.c | 15 +++----
 tools/testing/selftests/bpf/test_lru_map.c | 65 +++++++++++++++---------------
 tools/testing/selftests/bpf/test_maps.c    | 57 +++++++++++++-------------
 6 files changed, 73 insertions(+), 84 deletions(-)

diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index e96e2a9a7742..ea3369b50321 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -97,12 +97,11 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
-int bpf_map_update_elem(int fd, void *key, void *value,
+int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags)
 {
-	union bpf_attr attr;
+	union bpf_attr attr = {};
 
-	bzero(&attr, sizeof(attr));
 	attr.map_fd = fd;
 	attr.key = ptr_to_u64(key);
 	attr.value = ptr_to_u64(value);
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index bc959a2de023..2458534c8b33 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -33,7 +33,7 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     __u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
 
-int bpf_map_update_elem(int fd, void *key, void *value,
+int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
 
 int bpf_map_lookup_elem(int fd, void *key, void *value);
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
index e7bbe3e5402e..e08dec0db9e0 100644
--- a/tools/testing/selftests/bpf/bpf_sys.h
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -35,19 +35,6 @@ static inline int bpf_map_lookup(int fd, const void *key, void *value)
 	return bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
-static inline int bpf_map_update(int fd, const void *key, const void *value,
-				 uint64_t flags)
-{
-	union bpf_attr attr = {};
-
-	attr.map_fd = fd;
-	attr.key = bpf_ptr_to_u64(key);
-	attr.value = bpf_ptr_to_u64(value);
-	attr.flags = flags;
-
-	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
-}
-
 static inline int bpf_map_delete(int fd, const void *key)
 {
 	union bpf_attr attr = {};
diff --git a/tools/testing/selftests/bpf/test_lpm_map.c b/tools/testing/selftests/bpf/test_lpm_map.c
index 26775c00273f..e29ffbcd2932 100644
--- a/tools/testing/selftests/bpf/test_lpm_map.c
+++ b/tools/testing/selftests/bpf/test_lpm_map.c
@@ -22,6 +22,7 @@
 #include <sys/time.h>
 #include <sys/resource.h>
 
+#include <bpf/bpf.h>
 #include "bpf_sys.h"
 #include "bpf_util.h"
 
@@ -198,7 +199,7 @@ static void test_lpm_map(int keysize)
 
 		key->prefixlen = value[keysize];
 		memcpy(key->data, value, keysize);
-		r = bpf_map_update(map, key, value, 0);
+		r = bpf_map_update_elem(map, key, value, 0);
 		assert(!r);
 	}
 
@@ -266,32 +267,32 @@ static void test_lpm_ipaddr(void)
 	value = 1;
 	key_ipv4->prefixlen = 16;
 	inet_pton(AF_INET, "192.168.0.0", key_ipv4->data);
-	assert(bpf_map_update(map_fd_ipv4, key_ipv4, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv4, key_ipv4, &value, 0) == 0);
 
 	value = 2;
 	key_ipv4->prefixlen = 24;
 	inet_pton(AF_INET, "192.168.0.0", key_ipv4->data);
-	assert(bpf_map_update(map_fd_ipv4, key_ipv4, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv4, key_ipv4, &value, 0) == 0);
 
 	value = 3;
 	key_ipv4->prefixlen = 24;
 	inet_pton(AF_INET, "192.168.128.0", key_ipv4->data);
-	assert(bpf_map_update(map_fd_ipv4, key_ipv4, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv4, key_ipv4, &value, 0) == 0);
 
 	value = 5;
 	key_ipv4->prefixlen = 24;
 	inet_pton(AF_INET, "192.168.1.0", key_ipv4->data);
-	assert(bpf_map_update(map_fd_ipv4, key_ipv4, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv4, key_ipv4, &value, 0) == 0);
 
 	value = 4;
 	key_ipv4->prefixlen = 23;
 	inet_pton(AF_INET, "192.168.0.0", key_ipv4->data);
-	assert(bpf_map_update(map_fd_ipv4, key_ipv4, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv4, key_ipv4, &value, 0) == 0);
 
 	value = 0xdeadbeef;
 	key_ipv6->prefixlen = 64;
 	inet_pton(AF_INET6, "2a00:1450:4001:814::200e", key_ipv6->data);
-	assert(bpf_map_update(map_fd_ipv6, key_ipv6, &value, 0) == 0);
+	assert(bpf_map_update_elem(map_fd_ipv6, key_ipv6, &value, 0) == 0);
 
 	/* Set tprefixlen to maximum for lookups */
 	key_ipv4->prefixlen = 32;
diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index 9f7bd1915c21..8011680248bd 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -18,6 +18,7 @@
 #include <sys/wait.h>
 #include <sys/resource.h>
 
+#include <bpf/bpf.h>
 #include "bpf_sys.h"
 #include "bpf_util.h"
 
@@ -119,15 +120,15 @@ static void test_lru_sanity0(int map_type, int map_flags)
 	/* insert key=1 element */
 
 	key = 1;
-	assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-	assert(!bpf_map_update(expected_map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(expected_map_fd, &key, value, BPF_NOEXIST));
 
 	/* BPF_NOEXIST means: add new element if it doesn't exist */
-	assert(bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST) == -1 &&
 	       /* key=1 already exists */
 	       errno == EEXIST);
 
-	assert(bpf_map_update(lru_map_fd, &key, value, -1) == -1 &&
+	assert(bpf_map_update_elem(lru_map_fd, &key, value, -1) == -1 &&
 	       errno == EINVAL);
 
 	/* insert key=2 element */
@@ -138,11 +139,11 @@ static void test_lru_sanity0(int map_type, int map_flags)
 	       errno == ENOENT);
 
 	/* BPF_EXIST means: update existing element */
-	assert(bpf_map_update(lru_map_fd, &key, value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_EXIST) == -1 &&
 	       /* key=2 is not there */
 	       errno == ENOENT);
 
-	assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	/* insert key=3 element */
 
@@ -159,8 +160,8 @@ static void test_lru_sanity0(int map_type, int map_flags)
 	assert(value[0] == 1234);
 
 	key = 3;
-	assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-	assert(!bpf_map_update(expected_map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(expected_map_fd, &key, value, BPF_NOEXIST));
 
 	/* key=2 has been removed from the LRU */
 	key = 2;
@@ -217,13 +218,13 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	/* Insert 1 to tgt_free (+tgt_free keys) */
 	end_key = 1 + tgt_free;
 	for (key = 1; key < end_key; key++)
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	/* Lookup 1 to tgt_free/2 */
 	end_key = 1 + batch_size;
 	for (key = 1; key < end_key; key++) {
 		assert(!bpf_map_lookup(lru_map_fd, &key, value));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -234,8 +235,8 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	key = 1 + tgt_free;
 	end_key = key + tgt_free;
 	for (; key < end_key; key++) {
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -301,9 +302,9 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	/* Insert 1 to tgt_free (+tgt_free keys) */
 	end_key = 1 + tgt_free;
 	for (key = 1; key < end_key; key++)
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
-	/* Any bpf_map_update will require to acquire a new node
+	/* Any bpf_map_update_elem will require to acquire a new node
 	 * from LRU first.
 	 *
 	 * The local list is running out of free nodes.
@@ -316,10 +317,10 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	 */
 	key = 1;
 	if (map_type == BPF_MAP_TYPE_LRU_PERCPU_HASH) {
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 		assert(!bpf_map_delete(lru_map_fd, &key));
 	} else {
-		assert(bpf_map_update(lru_map_fd, &key, value, BPF_EXIST));
+		assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_EXIST));
 	}
 
 	/* Re-insert 1 to tgt_free/2 again and do a lookup
@@ -329,10 +330,10 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	value[0] = 4321;
 	for (key = 1; key < end_key; key++) {
 		assert(bpf_map_lookup(lru_map_fd, &key, value));
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 		assert(!bpf_map_lookup(lru_map_fd, &key, value));
 		assert(value[0] == 4321);
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -344,13 +345,13 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 		/* These newly added but not referenced keys will be
 		 * gone during the next LRU shrink.
 		 */
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	/* Insert 1+tgt_free*3/2 to  tgt_free*5/2 */
 	end_key = key + tgt_free;
 	for (; key < end_key; key++) {
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -401,13 +402,13 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	/* Insert 1 to 2*tgt_free (+2*tgt_free keys) */
 	end_key = 1 + (2 * tgt_free);
 	for (key = 1; key < end_key; key++)
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	/* Lookup key 1 to tgt_free*3/2 */
 	end_key = tgt_free + batch_size;
 	for (key = 1; key < end_key; key++) {
 		assert(!bpf_map_lookup(lru_map_fd, &key, value));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -417,8 +418,8 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	key = 2 * tgt_free + 1;
 	end_key = key + batch_size;
 	for (; key < end_key; key++) {
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -457,14 +458,14 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 	value[0] = 1234;
 
 	for (key = 1; key <= 2 * tgt_free; key++)
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	key = 1;
-	assert(bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
+	assert(bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
 
 	for (key = 1; key <= tgt_free; key++) {
 		assert(!bpf_map_lookup(lru_map_fd, &key, value));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -475,8 +476,8 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 
 	end_key = key + 2 * tgt_free;
 	for (; key < end_key; key++) {
-		assert(!bpf_map_update(lru_map_fd, &key, value, BPF_NOEXIST));
-		assert(!bpf_map_update(expected_map_fd, &key, value,
+		assert(!bpf_map_update_elem(lru_map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(expected_map_fd, &key, value,
 				       BPF_NOEXIST));
 	}
 
@@ -498,7 +499,7 @@ static void do_test_lru_sanity5(unsigned long long last_key, int map_fd)
 	value[0] = 1234;
 
 	key = last_key + 1;
-	assert(!bpf_map_update(map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST));
 	assert(!bpf_map_lookup(map_fd, &key, value));
 
 	/* Cannot find the last key because it was removed by LRU */
@@ -523,7 +524,7 @@ static void test_lru_sanity5(int map_type, int map_flags)
 
 	value[0] = 1234;
 	key = 0;
-	assert(!bpf_map_update(map_fd, &key, value, BPF_NOEXIST));
+	assert(!bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST));
 
 	while (sched_next_online(0, &next_cpu) != -1) {
 		pid_t pid;
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index eedfef8d2946..2574cc7517b9 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -21,6 +21,7 @@
 
 #include <linux/bpf.h>
 
+#include <bpf/bpf.h>
 #include "bpf_sys.h"
 #include "bpf_util.h"
 
@@ -41,16 +42,16 @@ static void test_hashmap(int task, void *data)
 	key = 1;
 	value = 1234;
 	/* Insert key=1 element. */
-	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0);
 
 	value = 0;
 	/* BPF_NOEXIST means add new element if it doesn't exist. */
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       /* key=1 already exists. */
 	       errno == EEXIST);
 
 	/* -1 is an invalid flag. */
-	assert(bpf_map_update(fd, &key, &value, -1) == -1 && errno == EINVAL);
+	assert(bpf_map_update_elem(fd, &key, &value, -1) == -1 && errno == EINVAL);
 
 	/* Check that key=1 can be found. */
 	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 1234);
@@ -60,27 +61,27 @@ static void test_hashmap(int task, void *data)
 	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means update existing element. */
-	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == -1 &&
 	       /* key=2 is not there. */
 	       errno == ENOENT);
 
 	/* Insert key=2 element. */
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == 0);
 
 	/* key=1 and key=2 were inserted, check that key=0 cannot be
 	 * inserted due to max_entries limit.
 	 */
 	key = 0;
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* Update existing element, though the map is full. */
 	key = 1;
-	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == 0);
 	key = 2;
-	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0);
 	key = 1;
-	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0);
 
 	/* Check that key = 0 doesn't exist. */
 	key = 0;
@@ -130,16 +131,16 @@ static void test_hashmap_percpu(int task, void *data)
 	key = 1;
 	/* Insert key=1 element. */
 	assert(!(expected_key_mask & key));
-	assert(bpf_map_update(fd, &key, value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, value, BPF_ANY) == 0);
 	expected_key_mask |= key;
 
 	/* BPF_NOEXIST means add new element if it doesn't exist. */
-	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, value, BPF_NOEXIST) == -1 &&
 	       /* key=1 already exists. */
 	       errno == EEXIST);
 
 	/* -1 is an invalid flag. */
-	assert(bpf_map_update(fd, &key, value, -1) == -1 && errno == EINVAL);
+	assert(bpf_map_update_elem(fd, &key, value, -1) == -1 && errno == EINVAL);
 
 	/* Check that key=1 can be found. Value could be 0 if the lookup
 	 * was run from a different CPU.
@@ -152,20 +153,20 @@ static void test_hashmap_percpu(int task, void *data)
 	assert(bpf_map_lookup(fd, &key, value) == -1 && errno == ENOENT);
 
 	/* BPF_EXIST means update existing element. */
-	assert(bpf_map_update(fd, &key, value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, value, BPF_EXIST) == -1 &&
 	       /* key=2 is not there. */
 	       errno == ENOENT);
 
 	/* Insert key=2 element. */
 	assert(!(expected_key_mask & key));
-	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == 0);
+	assert(bpf_map_update_elem(fd, &key, value, BPF_NOEXIST) == 0);
 	expected_key_mask |= key;
 
 	/* key=1 and key=2 were inserted, check that key=0 cannot be
 	 * inserted due to max_entries limit.
 	 */
 	key = 0;
-	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* Check that key = 0 doesn't exist. */
@@ -187,7 +188,7 @@ static void test_hashmap_percpu(int task, void *data)
 
 	/* Update with BPF_EXIST. */
 	key = 1;
-	assert(bpf_map_update(fd, &key, value, BPF_EXIST) == 0);
+	assert(bpf_map_update_elem(fd, &key, value, BPF_EXIST) == 0);
 
 	/* Delete both elements. */
 	key = 1;
@@ -219,10 +220,10 @@ static void test_arraymap(int task, void *data)
 	key = 1;
 	value = 1234;
 	/* Insert key=1 element. */
-	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_ANY) == 0);
 
 	value = 0;
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* Check that key=1 can be found. */
@@ -236,7 +237,7 @@ static void test_arraymap(int task, void *data)
 	 * due to max_entries limit.
 	 */
 	key = 2;
-	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* Check that key = 2 doesn't exist. */
@@ -275,10 +276,10 @@ static void test_arraymap_percpu(int task, void *data)
 
 	key = 1;
 	/* Insert key=1 element. */
-	assert(bpf_map_update(fd, &key, values, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(fd, &key, values, BPF_ANY) == 0);
 
 	values[0] = 0;
-	assert(bpf_map_update(fd, &key, values, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, values, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* Check that key=1 can be found. */
@@ -291,7 +292,7 @@ static void test_arraymap_percpu(int task, void *data)
 
 	/* Check that key=2 cannot be inserted due to max_entries limit. */
 	key = 2;
-	assert(bpf_map_update(fd, &key, values, BPF_EXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, values, BPF_EXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* Check that key = 2 doesn't exist. */
@@ -331,7 +332,7 @@ static void test_arraymap_percpu_many_keys(void)
 		values[i] = i + 10;
 
 	for (key = 0; key < nr_keys; key++)
-		assert(bpf_map_update(fd, &key, values, BPF_ANY) == 0);
+		assert(bpf_map_update_elem(fd, &key, values, BPF_ANY) == 0);
 
 	for (key = 0; key < nr_keys; key++) {
 		for (i = 0; i < nr_cpus; i++)
@@ -368,11 +369,11 @@ static void test_map_large(void)
 		key = (struct bigkey) { .c = i };
 		value = i;
 
-		assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
+		assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == 0);
 	}
 
 	key.c = -1;
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
 	/* Iterate through all elements. */
@@ -437,8 +438,8 @@ static void do_work(int fn, void *data)
 		key = value = i;
 
 		if (do_update) {
-			assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
-			assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == 0);
+			assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == 0);
+			assert(bpf_map_update_elem(fd, &key, &value, BPF_EXIST) == 0);
 		} else {
 			assert(bpf_map_delete(fd, &key) == 0);
 		}
@@ -468,7 +469,7 @@ static void test_map_parallel(void)
 	run_parallel(TASKS, do_work, data);
 
 	/* Check that key=0 is already there. */
-	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	assert(bpf_map_update_elem(fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == EEXIST);
 
 	/* Check that all elements were inserted. */
-- 
2.11.0
