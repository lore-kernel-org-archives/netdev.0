From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 5/7] bpf: add a testsuite for eBPF maps
Date: Thu, 13 Nov 2014 17:36:48 -0800
Message-ID: <1415929010-9361-6-git-send-email-ast@plumgrid.com>
References: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415929010-9361-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

. check error conditions and sanity of hash and array map APIs
. check large maps (that kernel gracefully switches to vmalloc from kmalloc)
. check multi-process parallel access and stress test

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
Eventually it can be moved tools/testing/selftests/bpf/, but for now keep
it in samples/bpf/, since that's where all subsequent samples are coming to.

 samples/bpf/Makefile    |    3 +-
 samples/bpf/libbpf.c    |    3 +-
 samples/bpf/libbpf.h    |    2 +-
 samples/bpf/test_maps.c |  291 +++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 296 insertions(+), 3 deletions(-)
 create mode 100644 samples/bpf/test_maps.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 634391797856..0718d9ce4619 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,9 +2,10 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := test_verifier
+hostprogs-y := test_verifier test_maps
 
 test_verifier-objs := test_verifier.o libbpf.o
+test_maps-objs := test_maps.o libbpf.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index ff6504420738..17bb520eb57f 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -27,12 +27,13 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-int bpf_update_elem(int fd, void *key, void *value)
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
 		.key = ptr_to_u64(key),
 		.value = ptr_to_u64(value),
+		.flags = flags,
 	};
 
 	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 8a31babeca5d..f8678e5f48bf 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -6,7 +6,7 @@ struct bpf_insn;
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries);
-int bpf_update_elem(int fd, void *key, void *value);
+int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
 int bpf_lookup_elem(int fd, void *key, void *value);
 int bpf_delete_elem(int fd, void *key);
 int bpf_get_next_key(int fd, void *key, void *next_key);
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
new file mode 100644
index 000000000000..e286b42307f3
--- /dev/null
+++ b/samples/bpf/test_maps.c
@@ -0,0 +1,291 @@
+/*
+ * Testsuite for eBPF maps
+ *
+ * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <linux/bpf.h>
+#include <errno.h>
+#include <string.h>
+#include <assert.h>
+#include <sys/wait.h>
+#include <stdlib.h>
+#include "libbpf.h"
+
+/* sanity tests for map API */
+static void test_hashmap_sanity(int i, void *data)
+{
+	long long key, next_key, value;
+	int map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value), 2);
+	if (map_fd < 0) {
+		printf("failed to create hashmap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* insert key=1 element */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+
+	value = 0;
+	/* BPF_NOEXIST means: add new element if it doesn't exist */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       /* key=1 already exists */
+	       errno == EEXIST);
+
+	assert(bpf_update_elem(map_fd, &key, &value, -1) == -1 && errno == EINVAL);
+
+	/* check that key=1 can be found */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
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
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
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
+	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
+	       next_key == 2);
+	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
+	       next_key == 1);
+	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
+	       errno == ENOENT);
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
+static void test_arraymap_sanity(int i, void *data)
+{
+	int key, next_key, map_fd;
+	long long value;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value), 2);
+	if (map_fd < 0) {
+		printf("failed to create arraymap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* insert key=1 element */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+
+	value = 0;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* check that key=1 can be found */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
+
+	key = 0;
+	/* check that key=0 is also found and zero initialized */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+
+
+	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
+	 * due to max_entries limit
+	 */
+	key = 2;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* check that key = 2 doesn't exist */
+	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
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
+#define MAP_SIZE (32 * 1024)
+static void test_map_large(void)
+{
+	struct bigkey {
+		int a;
+		char b[116];
+		long long c;
+	} key;
+	int map_fd, i, value;
+
+	/* allocate 4Mbyte of memory */
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+				MAP_SIZE);
+	if (map_fd < 0) {
+		printf("failed to create large map '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < MAP_SIZE; i++) {
+		key = (struct bigkey) {.c = i};
+		value = i;
+		assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+	}
+	key.c = -1;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* iterate through all elements */
+	for (i = 0; i < MAP_SIZE; i++)
+		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
+	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+
+	key.c = 0;
+	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
+	key.a = 1;
+	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
+
+	close(map_fd);
+}
+
+/* fork N children and wait for them to complete */
+static void run_parallel(int tasks, void (*fn)(int i, void *data), void *data)
+{
+	pid_t pid[tasks];
+	int i;
+
+	for (i = 0; i < tasks; i++) {
+		pid[i] = fork();
+		if (pid[i] == 0) {
+			fn(i, data);
+			exit(0);
+		} else if (pid[i] == -1) {
+			printf("couldn't spawn #%d process\n", i);
+			exit(1);
+		}
+	}
+	for (i = 0; i < tasks; i++) {
+		int status;
+
+		assert(waitpid(pid[i], &status, 0) == pid[i]);
+		assert(status == 0);
+	}
+}
+
+static void test_map_stress(void)
+{
+	run_parallel(100, test_hashmap_sanity, NULL);
+	run_parallel(100, test_arraymap_sanity, NULL);
+}
+
+#define TASKS 1024
+#define DO_UPDATE 1
+#define DO_DELETE 0
+static void do_work(int fn, void *data)
+{
+	int map_fd = ((int *)data)[0];
+	int do_update = ((int *)data)[1];
+	int i;
+	int key, value;
+
+	for (i = fn; i < MAP_SIZE; i += TASKS) {
+		key = value = i;
+		if (do_update)
+			assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
+		else
+			assert(bpf_delete_elem(map_fd, &key) == 0);
+	}
+}
+
+static void test_map_parallel(void)
+{
+	int i, map_fd, key = 0, value = 0;
+	int data[2];
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+				MAP_SIZE);
+	if (map_fd < 0) {
+		printf("failed to create map for parallel test '%s'\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	data[0] = map_fd;
+	data[1] = DO_UPDATE;
+	/* use the same map_fd in children to add elements to this map
+	 * child_0 adds key=0, key=1024, key=2048, ...
+	 * child_1 adds key=1, key=1025, key=2049, ...
+	 * child_1023 adds key=1023, ...
+	 */
+	run_parallel(TASKS, do_work, data);
+
+	/* check that key=0 is already there */
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* check that all elements were inserted */
+	key = -1;
+	for (i = 0; i < MAP_SIZE; i++)
+		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
+	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+
+	/* another check for all elements */
+	for (i = 0; i < MAP_SIZE; i++) {
+		key = MAP_SIZE - i - 1;
+		assert(bpf_lookup_elem(map_fd, &key, &value) == 0 &&
+		       value == key);
+	}
+
+	/* now let's delete all elemenets in parallel */
+	data[1] = DO_DELETE;
+	run_parallel(TASKS, do_work, data);
+
+	/* nothing should be left */
+	key = -1;
+	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
+}
+
+int main(void)
+{
+	test_hashmap_sanity(0, NULL);
+	test_arraymap_sanity(0, NULL);
+	test_map_large();
+	test_map_parallel();
+	test_map_stress();
+	printf("test_maps: OK\n");
+	return 0;
+}
-- 
1.7.9.5
