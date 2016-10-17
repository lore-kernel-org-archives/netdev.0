From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: add initial suite for selftests
Date: Mon, 17 Oct 2016 14:28:36 +0200
Message-ID: <08cc05da80eda6abe3287c6d4876c31bb6107109.1476705709.git.daniel@iogearbox.net>
References: <cover.1476705709.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44080 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933756AbcJQM25 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 08:28:57 -0400
In-Reply-To: <cover.1476705709.git.daniel@iogearbox.net>
In-Reply-To: <cover.1476705709.git.daniel@iogearbox.net>
References: <cover.1476705709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a start of a test suite for kernel selftests. This moves test_verifier
and test_maps over to tools/testing/selftests/bpf/ along with various
code improvements and also adds a script for invoking test_bpf module.
The test suite can simply be run via selftest framework, f.e.:

  # cd tools/testing/selftests/bpf/
  # make
  # make run_tests

Both test_verifier and test_maps were kind of misplaced in samples/bpf/
directory and we were looking into adding them to selftests for a while
now, so it can be picked up by kbuild bot et al and hopefully also get
more exposure and thus new test case additions.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 MAINTAINERS                                 |    3 +-
 samples/bpf/Makefile                        |    3 -
 samples/bpf/test_maps.c                     |  503 -----
 samples/bpf/test_verifier.c                 | 2645 -------------------------
 tools/include/linux/filter.h                |   24 +
 tools/testing/selftests/Makefile            |    3 +-
 tools/testing/selftests/bpf/.gitignore      |    2 +
 tools/testing/selftests/bpf/Makefile        |   13 +
 tools/testing/selftests/bpf/bpf_sys.h       |  108 ++
 tools/testing/selftests/bpf/config          |    5 +
 tools/testing/selftests/bpf/test_kmod.sh    |   39 +
 tools/testing/selftests/bpf/test_maps.c     |  525 +++++
 tools/testing/selftests/bpf/test_verifier.c | 2764 +++++++++++++++++++++++++++
 13 files changed, 3484 insertions(+), 3153 deletions(-)
 delete mode 100644 samples/bpf/test_maps.c
 delete mode 100644 samples/bpf/test_verifier.c
 create mode 100644 tools/testing/selftests/bpf/.gitignore
 create mode 100644 tools/testing/selftests/bpf/Makefile
 create mode 100644 tools/testing/selftests/bpf/bpf_sys.h
 create mode 100644 tools/testing/selftests/bpf/config
 create mode 100755 tools/testing/selftests/bpf/test_kmod.sh
 create mode 100644 tools/testing/selftests/bpf/test_maps.c
 create mode 100644 tools/testing/selftests/bpf/test_verifier.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 1fc66f0a..f18b546 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2521,6 +2521,8 @@ L:	netdev@vger.kernel.org
 L:	linux-kernel@vger.kernel.org
 S:	Supported
 F:	kernel/bpf/
+F:	tools/testing/selftests/bpf/
+F:	lib/test_bpf.c
 
 BROADCOM B44 10/100 ETHERNET DRIVER
 M:	Michael Chan <michael.chan@broadcom.com>
@@ -8413,7 +8415,6 @@ F:	include/uapi/linux/net_namespace.h
 F:	tools/net/
 F:	tools/testing/selftests/net/
 F:	lib/random32.c
-F:	lib/test_bpf.c
 
 NETWORKING [IPv4/IPv6]
 M:	"David S. Miller" <davem@davemloft.net>
diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 12b7304..5c53fdb 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -2,7 +2,6 @@
 obj- := dummy.o
 
 # List of programs to build
-hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
 hostprogs-y += fds_example
 hostprogs-y += sockex1
@@ -28,8 +27,6 @@ hostprogs-y += test_current_task_under_cgroup
 hostprogs-y += trace_event
 hostprogs-y += sampleip
 
-test_verifier-objs := test_verifier.o libbpf.o
-test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
 fds_example-objs := bpf_load.o libbpf.o fds_example.o
 sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
deleted file mode 100644
index cce2b59..0000000
--- a/samples/bpf/test_maps.c
+++ /dev/null
@@ -1,503 +0,0 @@
-/*
- * Testsuite for eBPF maps
- *
- * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
- * Copyright (c) 2016 Facebook
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- */
-#include <stdio.h>
-#include <unistd.h>
-#include <linux/bpf.h>
-#include <errno.h>
-#include <string.h>
-#include <assert.h>
-#include <sys/wait.h>
-#include <stdlib.h>
-#include "libbpf.h"
-
-static int map_flags;
-
-/* sanity tests for map API */
-static void test_hashmap_sanity(int i, void *data)
-{
-	long long key, next_key, value;
-	int map_fd;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
-				2, map_flags);
-	if (map_fd < 0) {
-		printf("failed to create hashmap '%s'\n", strerror(errno));
-		exit(1);
-	}
-
-	key = 1;
-	value = 1234;
-	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
-
-	value = 0;
-	/* BPF_NOEXIST means: add new element if it doesn't exist */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
-	       /* key=1 already exists */
-	       errno == EEXIST);
-
-	assert(bpf_update_elem(map_fd, &key, &value, -1) == -1 && errno == EINVAL);
-
-	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
-
-	key = 2;
-	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
-
-	/* BPF_EXIST means: update existing element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
-	       /* key=2 is not there */
-	       errno == ENOENT);
-
-	/* insert key=2 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
-
-	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
-	 * due to max_entries limit
-	 */
-	key = 0;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
-	       errno == E2BIG);
-
-	/* update existing element, thought the map is full */
-	key = 1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
-	key = 2;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
-	key = 1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
-
-	/* check that key = 0 doesn't exist */
-	key = 0;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
-
-	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
-	       (next_key == 1 || next_key == 2));
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
-	       (next_key == 1 || next_key == 2));
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
-	       errno == ENOENT);
-
-	/* delete both elements */
-	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	key = 2;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
-
-	key = 0;
-	/* check that map is empty */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == -1 &&
-	       errno == ENOENT);
-	close(map_fd);
-}
-
-/* sanity tests for percpu map API */
-static void test_percpu_hashmap_sanity(int task, void *data)
-{
-	long long key, next_key;
-	int expected_key_mask = 0;
-	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
-	long long value[nr_cpus];
-	int map_fd, i;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
-				sizeof(value[0]), 2, map_flags);
-	if (map_fd < 0) {
-		printf("failed to create hashmap '%s'\n", strerror(errno));
-		exit(1);
-	}
-
-	for (i = 0; i < nr_cpus; i++)
-		value[i] = i + 100;
-	key = 1;
-	/* insert key=1 element */
-	assert(!(expected_key_mask & key));
-	assert(bpf_update_elem(map_fd, &key, value, BPF_ANY) == 0);
-	expected_key_mask |= key;
-
-	/* BPF_NOEXIST means: add new element if it doesn't exist */
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
-	       /* key=1 already exists */
-	       errno == EEXIST);
-
-	/* -1 is an invalid flag */
-	assert(bpf_update_elem(map_fd, &key, value, -1) == -1 &&
-	       errno == EINVAL);
-
-	/* check that key=1 can be found. value could be 0 if the lookup
-	 * was run from a different cpu.
-	 */
-	value[0] = 1;
-	assert(bpf_lookup_elem(map_fd, &key, value) == 0 && value[0] == 100);
-
-	key = 2;
-	/* check that key=2 is not found */
-	assert(bpf_lookup_elem(map_fd, &key, value) == -1 && errno == ENOENT);
-
-	/* BPF_EXIST means: update existing element */
-	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == -1 &&
-	       /* key=2 is not there */
-	       errno == ENOENT);
-
-	/* insert key=2 element */
-	assert(!(expected_key_mask & key));
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
-	expected_key_mask |= key;
-
-	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
-	 * due to max_entries limit
-	 */
-	key = 0;
-	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
-	       errno == E2BIG);
-
-	/* check that key = 0 doesn't exist */
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
-
-	/* iterate over two elements */
-	while (!bpf_get_next_key(map_fd, &key, &next_key)) {
-		assert((expected_key_mask & next_key) == next_key);
-		expected_key_mask &= ~next_key;
-
-		assert(bpf_lookup_elem(map_fd, &next_key, value) == 0);
-		for (i = 0; i < nr_cpus; i++)
-			assert(value[i] == i + 100);
-
-		key = next_key;
-	}
-	assert(errno == ENOENT);
-
-	/* Update with BPF_EXIST */
-	key = 1;
-	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == 0);
-
-	/* delete both elements */
-	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	key = 2;
-	assert(bpf_delete_elem(map_fd, &key) == 0);
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
-
-	key = 0;
-	/* check that map is empty */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == -1 &&
-	       errno == ENOENT);
-	close(map_fd);
-}
-
-static void test_arraymap_sanity(int i, void *data)
-{
-	int key, next_key, map_fd;
-	long long value;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
-				2, 0);
-	if (map_fd < 0) {
-		printf("failed to create arraymap '%s'\n", strerror(errno));
-		exit(1);
-	}
-
-	key = 1;
-	value = 1234;
-	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
-
-	value = 0;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
-	       errno == EEXIST);
-
-	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 1234);
-
-	key = 0;
-	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
-
-
-	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
-	 * due to max_entries limit
-	 */
-	key = 2;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == -1 &&
-	       errno == E2BIG);
-
-	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
-
-	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
-	       next_key == 0);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
-	       next_key == 1);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
-	       errno == ENOENT);
-
-	/* delete shouldn't succeed */
-	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
-
-	close(map_fd);
-}
-
-static void test_percpu_arraymap_many_keys(void)
-{
-	unsigned nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
-	unsigned nr_keys = 20000;
-	long values[nr_cpus];
-	int key, map_fd, i;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-				sizeof(values[0]), nr_keys, 0);
-	if (map_fd < 0) {
-		printf("failed to create per-cpu arraymap '%s'\n",
-		       strerror(errno));
-		exit(1);
-	}
-
-	for (i = 0; i < nr_cpus; i++)
-		values[i] = i + 10;
-
-	for (key = 0; key < nr_keys; key++)
-		assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
-
-	for (key = 0; key < nr_keys; key++) {
-		for (i = 0; i < nr_cpus; i++)
-			values[i] = 0;
-		assert(bpf_lookup_elem(map_fd, &key, values) == 0);
-		for (i = 0; i < nr_cpus; i++)
-			assert(values[i] == i + 10);
-	}
-
-	close(map_fd);
-}
-
-static void test_percpu_arraymap_sanity(int i, void *data)
-{
-	unsigned nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
-	long values[nr_cpus];
-	int key, next_key, map_fd;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
-				sizeof(values[0]), 2, 0);
-	if (map_fd < 0) {
-		printf("failed to create arraymap '%s'\n", strerror(errno));
-		exit(1);
-	}
-
-	for (i = 0; i < nr_cpus; i++)
-		values[i] = i + 100;
-
-	key = 1;
-	/* insert key=1 element */
-	assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
-
-	values[0] = 0;
-	assert(bpf_update_elem(map_fd, &key, values, BPF_NOEXIST) == -1 &&
-	       errno == EEXIST);
-
-	/* check that key=1 can be found */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 && values[0] == 100);
-
-	key = 0;
-	/* check that key=0 is also found and zero initialized */
-	assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
-	       values[0] == 0 && values[nr_cpus - 1] == 0);
-
-
-	/* check that key=2 cannot be inserted due to max_entries limit */
-	key = 2;
-	assert(bpf_update_elem(map_fd, &key, values, BPF_EXIST) == -1 &&
-	       errno == E2BIG);
-
-	/* check that key = 2 doesn't exist */
-	assert(bpf_lookup_elem(map_fd, &key, values) == -1 && errno == ENOENT);
-
-	/* iterate over two elements */
-	assert(bpf_get_next_key(map_fd, &key, &next_key) == 0 &&
-	       next_key == 0);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == 0 &&
-	       next_key == 1);
-	assert(bpf_get_next_key(map_fd, &next_key, &next_key) == -1 &&
-	       errno == ENOENT);
-
-	/* delete shouldn't succeed */
-	key = 1;
-	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == EINVAL);
-
-	close(map_fd);
-}
-
-#define MAP_SIZE (32 * 1024)
-static void test_map_large(void)
-{
-	struct bigkey {
-		int a;
-		char b[116];
-		long long c;
-	} key;
-	int map_fd, i, value;
-
-	/* allocate 4Mbyte of memory */
-	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
-				MAP_SIZE, map_flags);
-	if (map_fd < 0) {
-		printf("failed to create large map '%s'\n", strerror(errno));
-		exit(1);
-	}
-
-	for (i = 0; i < MAP_SIZE; i++) {
-		key = (struct bigkey) {.c = i};
-		value = i;
-		assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
-	}
-	key.c = -1;
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
-	       errno == E2BIG);
-
-	/* iterate through all elements */
-	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
-
-	key.c = 0;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == 0 && value == 0);
-	key.a = 1;
-	assert(bpf_lookup_elem(map_fd, &key, &value) == -1 && errno == ENOENT);
-
-	close(map_fd);
-}
-
-/* fork N children and wait for them to complete */
-static void run_parallel(int tasks, void (*fn)(int i, void *data), void *data)
-{
-	pid_t pid[tasks];
-	int i;
-
-	for (i = 0; i < tasks; i++) {
-		pid[i] = fork();
-		if (pid[i] == 0) {
-			fn(i, data);
-			exit(0);
-		} else if (pid[i] == -1) {
-			printf("couldn't spawn #%d process\n", i);
-			exit(1);
-		}
-	}
-	for (i = 0; i < tasks; i++) {
-		int status;
-
-		assert(waitpid(pid[i], &status, 0) == pid[i]);
-		assert(status == 0);
-	}
-}
-
-static void test_map_stress(void)
-{
-	run_parallel(100, test_hashmap_sanity, NULL);
-	run_parallel(100, test_percpu_hashmap_sanity, NULL);
-	run_parallel(100, test_arraymap_sanity, NULL);
-	run_parallel(100, test_percpu_arraymap_sanity, NULL);
-}
-
-#define TASKS 1024
-#define DO_UPDATE 1
-#define DO_DELETE 0
-static void do_work(int fn, void *data)
-{
-	int map_fd = ((int *)data)[0];
-	int do_update = ((int *)data)[1];
-	int i;
-	int key, value;
-
-	for (i = fn; i < MAP_SIZE; i += TASKS) {
-		key = value = i;
-		if (do_update) {
-			assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
-			assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
-		} else {
-			assert(bpf_delete_elem(map_fd, &key) == 0);
-		}
-	}
-}
-
-static void test_map_parallel(void)
-{
-	int i, map_fd, key = 0, value = 0;
-	int data[2];
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
-				MAP_SIZE, map_flags);
-	if (map_fd < 0) {
-		printf("failed to create map for parallel test '%s'\n",
-		       strerror(errno));
-		exit(1);
-	}
-
-	data[0] = map_fd;
-	data[1] = DO_UPDATE;
-	/* use the same map_fd in children to add elements to this map
-	 * child_0 adds key=0, key=1024, key=2048, ...
-	 * child_1 adds key=1, key=1025, key=2049, ...
-	 * child_1023 adds key=1023, ...
-	 */
-	run_parallel(TASKS, do_work, data);
-
-	/* check that key=0 is already there */
-	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
-	       errno == EEXIST);
-
-	/* check that all elements were inserted */
-	key = -1;
-	for (i = 0; i < MAP_SIZE; i++)
-		assert(bpf_get_next_key(map_fd, &key, &key) == 0);
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
-
-	/* another check for all elements */
-	for (i = 0; i < MAP_SIZE; i++) {
-		key = MAP_SIZE - i - 1;
-		assert(bpf_lookup_elem(map_fd, &key, &value) == 0 &&
-		       value == key);
-	}
-
-	/* now let's delete all elemenets in parallel */
-	data[1] = DO_DELETE;
-	run_parallel(TASKS, do_work, data);
-
-	/* nothing should be left */
-	key = -1;
-	assert(bpf_get_next_key(map_fd, &key, &key) == -1 && errno == ENOENT);
-}
-
-static void run_all_tests(void)
-{
-	test_hashmap_sanity(0, NULL);
-	test_percpu_hashmap_sanity(0, NULL);
-	test_arraymap_sanity(0, NULL);
-	test_percpu_arraymap_sanity(0, NULL);
-	test_percpu_arraymap_many_keys();
-
-	test_map_large();
-	test_map_parallel();
-	test_map_stress();
-}
-
-int main(void)
-{
-	map_flags = 0;
-	run_all_tests();
-	map_flags = BPF_F_NO_PREALLOC;
-	run_all_tests();
-	printf("test_maps: OK\n");
-	return 0;
-}
diff --git a/samples/bpf/test_verifier.c b/samples/bpf/test_verifier.c
deleted file mode 100644
index 45cf740..0000000
--- a/samples/bpf/test_verifier.c
+++ /dev/null
@@ -1,2645 +0,0 @@
-/*
- * Testsuite for eBPF verifier
- *
- * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of version 2 of the GNU General Public
- * License as published by the Free Software Foundation.
- */
-#include <stdio.h>
-#include <unistd.h>
-#include <linux/bpf.h>
-#include <errno.h>
-#include <linux/unistd.h>
-#include <string.h>
-#include <linux/filter.h>
-#include <linux/bpf_perf_event.h>
-#include <stddef.h>
-#include <stdbool.h>
-#include <sys/resource.h>
-#include "libbpf.h"
-
-#define MAX_INSNS 512
-#define ARRAY_SIZE(x) (sizeof(x) / sizeof(*(x)))
-
-#define MAX_FIXUPS 8
-
-struct bpf_test {
-	const char *descr;
-	struct bpf_insn	insns[MAX_INSNS];
-	int fixup[MAX_FIXUPS];
-	int prog_array_fixup[MAX_FIXUPS];
-	int test_val_map_fixup[MAX_FIXUPS];
-	const char *errstr;
-	const char *errstr_unpriv;
-	enum {
-		UNDEF,
-		ACCEPT,
-		REJECT
-	} result, result_unpriv;
-	enum bpf_prog_type prog_type;
-};
-
-/* Note we want this to be 64 bit aligned so that the end of our array is
- * actually the end of the structure.
- */
-#define MAX_ENTRIES 11
-struct test_val {
-	unsigned index;
-	int foo[MAX_ENTRIES];
-};
-
-struct other_val {
-	unsigned int action[32];
-};
-
-static struct bpf_test tests[] = {
-	{
-		"add+sub+mul",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_1, 1),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 2),
-			BPF_MOV64_IMM(BPF_REG_2, 3),
-			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -1),
-			BPF_ALU64_IMM(BPF_MUL, BPF_REG_1, 3),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-	},
-	{
-		"unreachable",
-		.insns = {
-			BPF_EXIT_INSN(),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "unreachable",
-		.result = REJECT,
-	},
-	{
-		"unreachable2",
-		.insns = {
-			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "unreachable",
-		.result = REJECT,
-	},
-	{
-		"out of range jump",
-		.insns = {
-			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "jump out of range",
-		.result = REJECT,
-	},
-	{
-		"out of range jump2",
-		.insns = {
-			BPF_JMP_IMM(BPF_JA, 0, 0, -2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "jump out of range",
-		.result = REJECT,
-	},
-	{
-		"test1 ld_imm64",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_MOV64_IMM(BPF_REG_0, 2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid BPF_LD_IMM insn",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"test2 ld_imm64",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid BPF_LD_IMM insn",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"test3 ld_imm64",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
-			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 0),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_LD_IMM64(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_ld_imm64 insn",
-		.result = REJECT,
-	},
-	{
-		"test4 ld_imm64",
-		.insns = {
-			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_ld_imm64 insn",
-		.result = REJECT,
-	},
-	{
-		"test5 ld_imm64",
-		.insns = {
-			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
-		},
-		.errstr = "invalid bpf_ld_imm64 insn",
-		.result = REJECT,
-	},
-	{
-		"no bpf_exit",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
-		},
-		.errstr = "jump out of range",
-		.result = REJECT,
-	},
-	{
-		"loop (back-edge)",
-		.insns = {
-			BPF_JMP_IMM(BPF_JA, 0, 0, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "back-edge",
-		.result = REJECT,
-	},
-	{
-		"loop2 (back-edge)",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, -4),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "back-edge",
-		.result = REJECT,
-	},
-	{
-		"conditional loop",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, -3),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "back-edge",
-		.result = REJECT,
-	},
-	{
-		"read uninitialized register",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R2 !read_ok",
-		.result = REJECT,
-	},
-	{
-		"read invalid register",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_0, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R15 is invalid",
-		.result = REJECT,
-	},
-	{
-		"program doesn't init R0 before exit",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 !read_ok",
-		.result = REJECT,
-	},
-	{
-		"program doesn't init R0 before exit in all branches",
-		.insns = {
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R0 !read_ok",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"stack out of bounds",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid stack",
-		.result = REJECT,
-	},
-	{
-		"invalid call insn1",
-		.insns = {
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL | BPF_X, 0, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "BPF_CALL uses reserved",
-		.result = REJECT,
-	},
-	{
-		"invalid call insn2",
-		.insns = {
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 1, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "BPF_CALL uses reserved",
-		.result = REJECT,
-	},
-	{
-		"invalid function call",
-		.insns = {
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, 1234567),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid func 1234567",
-		.result = REJECT,
-	},
-	{
-		"uninitialized stack1",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {2},
-		.errstr = "invalid indirect read from stack",
-		.result = REJECT,
-	},
-	{
-		"uninitialized stack2",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -8),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid read from stack",
-		.result = REJECT,
-	},
-	{
-		"invalid argument register",
-		.insns = {
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_cgroup_classid),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_cgroup_classid),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R1 !read_ok",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"non-invalid argument register",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_1),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_cgroup_classid),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_1, BPF_REG_6),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_cgroup_classid),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"check valid spill/fill",
-		.insns = {
-			/* spill R1(ctx) into stack */
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
-
-			/* fill it back into R2 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
-
-			/* should be able to access R0 = *(R2 + 8) */
-			/* BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8), */
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R0 leaks addr",
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-	},
-	{
-		"check valid spill/fill, skb mark",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_1),
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = ACCEPT,
-	},
-	{
-		"check corrupted spill/fill",
-		.insns = {
-			/* spill R1(ctx) into stack */
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
-
-			/* mess up with R1 pointer on stack */
-			BPF_ST_MEM(BPF_B, BPF_REG_10, -7, 0x23),
-
-			/* fill back into R0 should fail */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
-
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "attempt to corrupt spilled",
-		.errstr = "corrupted spill",
-		.result = REJECT,
-	},
-	{
-		"invalid src register in STX",
-		.insns = {
-			BPF_STX_MEM(BPF_B, BPF_REG_10, -1, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R15 is invalid",
-		.result = REJECT,
-	},
-	{
-		"invalid dst register in STX",
-		.insns = {
-			BPF_STX_MEM(BPF_B, 14, BPF_REG_10, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R14 is invalid",
-		.result = REJECT,
-	},
-	{
-		"invalid dst register in ST",
-		.insns = {
-			BPF_ST_MEM(BPF_B, 14, -1, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R14 is invalid",
-		.result = REJECT,
-	},
-	{
-		"invalid src register in LDX",
-		.insns = {
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, 12, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R12 is invalid",
-		.result = REJECT,
-	},
-	{
-		"invalid dst register in LDX",
-		.insns = {
-			BPF_LDX_MEM(BPF_B, 11, BPF_REG_1, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "R11 is invalid",
-		.result = REJECT,
-	},
-	{
-		"junk insn",
-		.insns = {
-			BPF_RAW_INSN(0, 0, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid BPF_LD_IMM",
-		.result = REJECT,
-	},
-	{
-		"junk insn2",
-		.insns = {
-			BPF_RAW_INSN(1, 0, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "BPF_LDX uses reserved fields",
-		.result = REJECT,
-	},
-	{
-		"junk insn3",
-		.insns = {
-			BPF_RAW_INSN(-1, 0, 0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid BPF_ALU opcode f0",
-		.result = REJECT,
-	},
-	{
-		"junk insn4",
-		.insns = {
-			BPF_RAW_INSN(-1, -1, -1, -1, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid BPF_ALU opcode f0",
-		.result = REJECT,
-	},
-	{
-		"junk insn5",
-		.insns = {
-			BPF_RAW_INSN(0x7f, -1, -1, -1, -1),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "BPF_ALU uses reserved fields",
-		.result = REJECT,
-	},
-	{
-		"misaligned read from stack",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -4),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "misaligned access",
-		.result = REJECT,
-	},
-	{
-		"invalid map_fd for function call",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_delete_elem),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "fd 0 is not pointing to valid bpf_map",
-		.result = REJECT,
-	},
-	{
-		"don't check return value before access",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr = "R0 invalid mem access 'map_value_or_null'",
-		.result = REJECT,
-	},
-	{
-		"access memory with incorrect alignment",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr = "misaligned access",
-		.result = REJECT,
-	},
-	{
-		"sometimes access memory with incorrect alignment",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
-			BPF_EXIT_INSN(),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr = "R0 invalid mem access",
-		.errstr_unpriv = "R0 leaks addr",
-		.result = REJECT,
-	},
-	{
-		"jump test 1",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -8),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 5),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"jump test 2",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 14),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 8),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 5),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 2),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"jump test 3",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 19),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 3),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 15),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 3),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -32),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 3),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -40),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 7),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 3),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -48),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 0),
-			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -56),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_delete_elem),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {24},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"jump test 4",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"jump test 5",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
-			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"access skb fields ok",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, len)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, pkt_type)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, queue_mapping)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, protocol)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, vlan_present)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, vlan_tci)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-	},
-	{
-		"access skb fields bad1",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, -4),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access",
-		.result = REJECT,
-	},
-	{
-		"access skb fields bad2",
-		.insns = {
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 9),
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
-			BPF_EXIT_INSN(),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, pkt_type)),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {4},
-		.errstr = "different pointers",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"access skb fields bad3",
-		.insns = {
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, pkt_type)),
-			BPF_EXIT_INSN(),
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
-			BPF_EXIT_INSN(),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, -12),
-		},
-		.fixup = {6},
-		.errstr = "different pointers",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"access skb fields bad4",
-		.insns = {
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 3),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, len)),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
-			BPF_EXIT_INSN(),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
-			BPF_JMP_IMM(BPF_JA, 0, 0, -13),
-		},
-		.fixup = {7},
-		.errstr = "different pointers",
-		.errstr_unpriv = "R1 pointer comparison",
-		.result = REJECT,
-	},
-	{
-		"check skb->mark is not writeable by sockets",
-		.insns = {
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access",
-		.errstr_unpriv = "R1 leaks addr",
-		.result = REJECT,
-	},
-	{
-		"check skb->tc_index is not writeable by sockets",
-		.insns = {
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, tc_index)),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access",
-		.errstr_unpriv = "R1 leaks addr",
-		.result = REJECT,
-	},
-	{
-		"check non-u32 access to cb",
-		.insns = {
-			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[0])),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access",
-		.errstr_unpriv = "R1 leaks addr",
-		.result = REJECT,
-	},
-	{
-		"check out of range skb->cb access",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[0]) + 256),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access",
-		.errstr_unpriv = "",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SCHED_ACT,
-	},
-	{
-		"write skb fields from socket prog",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[4])),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, tc_index)),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[0])),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[2])),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.errstr_unpriv = "R1 leaks addr",
-		.result_unpriv = REJECT,
-	},
-	{
-		"write skb fields from tc_cls_act prog",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, cb[0])),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
-				    offsetof(struct __sk_buff, tc_index)),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
-				    offsetof(struct __sk_buff, tc_index)),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
-				    offsetof(struct __sk_buff, cb[3])),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"PTR_TO_STACK store/load",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
-			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-	},
-	{
-		"PTR_TO_STACK store/load - bad alignment on off",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
-			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "misaligned access off -6 size 8",
-	},
-	{
-		"PTR_TO_STACK store/load - bad alignment on reg",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
-			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "misaligned access off -2 size 8",
-	},
-	{
-		"PTR_TO_STACK store/load - out of bounds low",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -80000),
-			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack off=-79992 size=8",
-	},
-	{
-		"PTR_TO_STACK store/load - out of bounds high",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
-			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack off=0 size=8",
-	},
-	{
-		"unpriv: return pointer",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_10),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R0 leaks addr",
-	},
-	{
-		"unpriv: add const to pointer",
-		.insns = {
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
-	},
-	{
-		"unpriv: add pointer to pointer",
-		.insns = {
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
-	},
-	{
-		"unpriv: neg pointer",
-		.insns = {
-			BPF_ALU64_IMM(BPF_NEG, BPF_REG_1, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer arithmetic",
-	},
-	{
-		"unpriv: cmp pointer with const",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R1 pointer comparison",
-	},
-	{
-		"unpriv: cmp pointer with pointer",
-		.insns = {
-			BPF_JMP_REG(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.result_unpriv = REJECT,
-		.errstr_unpriv = "R10 pointer comparison",
-	},
-	{
-		"unpriv: check that printk is disallowed",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
-			BPF_MOV64_IMM(BPF_REG_2, 8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_trace_printk),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "unknown func 6",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: pass pointer to helper function",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr_unpriv = "R4 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: indirectly pass pointer on stack to helper function",
-		.insns = {
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr = "invalid indirect read from stack off -8+0 size 8",
-		.result = REJECT,
-	},
-	{
-		"unpriv: mangle pointer on stack 1",
-		.insns = {
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
-			BPF_ST_MEM(BPF_W, BPF_REG_10, -8, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "attempt to corrupt spilled",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: mangle pointer on stack 2",
-		.insns = {
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
-			BPF_ST_MEM(BPF_B, BPF_REG_10, -1, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "attempt to corrupt spilled",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: read pointer from stack in small chunks",
-		.insns = {
-			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_10, -8),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid size",
-		.result = REJECT,
-	},
-	{
-		"unpriv: write pointer into ctx",
-		.insns = {
-			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R1 leaks addr",
-		.result_unpriv = REJECT,
-		.errstr = "invalid bpf_context access",
-		.result = REJECT,
-	},
-	{
-		"unpriv: spill/fill of ctx",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: spill/fill of ctx 2",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"unpriv: spill/fill of ctx 3",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "R1 type=fp expected=ctx",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"unpriv: spill/fill of ctx 4",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_10, BPF_REG_0, -8, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_get_hash_recalc),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "R1 type=inv expected=ctx",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"unpriv: spill/fill of different pointers stx",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_3, 42),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
-			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "same insn cannot be used with different pointers",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"unpriv: spill/fill of different pointers ldx",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2,
-				      -(__s32)offsetof(struct bpf_perf_event_data,
-						       sample_period) - 8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
-			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct bpf_perf_event_data,
-					     sample_period)),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "same insn cannot be used with different pointers",
-		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
-	},
-	{
-		"unpriv: write pointer into map elem value",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {3},
-		.errstr_unpriv = "R0 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: partial copy of pointer",
-		.insns = {
-			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R10 partial copy",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: pass pointer to tail_call",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
-			BPF_LD_MAP_FD(BPF_REG_2, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_tail_call),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.prog_array_fixup = {1},
-		.errstr_unpriv = "R3 leaks addr into helper",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: cmp map pointer with zero",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_1, 0),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {1},
-		.errstr_unpriv = "R1 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: write into frame pointer",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_10, BPF_REG_1),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "frame pointer is read only",
-		.result = REJECT,
-	},
-	{
-		"unpriv: spill/fill frame pointer",
-		.insns = {
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "frame pointer is read only",
-		.result = REJECT,
-	},
-	{
-		"unpriv: cmp of frame pointer",
-		.insns = {
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_10, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R10 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: cmp of stack pointer",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_2, 0, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R2 pointer comparison",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"unpriv: obfuscate stack pointer",
-		.insns = {
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr_unpriv = "R2 pointer arithmetic",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"raw_stack: no skb_load_bytes",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			/* Call to skb_load_bytes() omitted. */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid read from stack off -8+0 size 8",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, negative len",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, -8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, negative len 2",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, ~0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, zero len",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, no init",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, init",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_ST_MEM(BPF_DW, BPF_REG_6, 0, 0xcafe),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, spilled regs around bounds",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
-				    offsetof(struct __sk_buff, priority)),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, spilled regs corruption",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0), /* spill ctx from R1 */
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0), /* fill ctx into R0 */
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "R0 invalid mem access 'inv'",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, spilled regs corruption 2",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0), /* spill ctx from R1 */
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0), /* fill ctx into R3 */
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
-				    offsetof(struct __sk_buff, priority)),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_3,
-				    offsetof(struct __sk_buff, pkt_type)),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "R3 invalid mem access 'inv'",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, spilled regs + data",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8), /* spill ctx from R1 */
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0), /* spill ctx from R1 */
-			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8), /* spill ctx from R1 */
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8), /* fill ctx into R0 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8), /* fill ctx into R2 */
-			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0), /* fill data into R3 */
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
-				    offsetof(struct __sk_buff, mark)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
-				    offsetof(struct __sk_buff, priority)),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 1",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -513),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-513 access_size=8",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 2",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 8),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=8",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 3",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 0xffffffff),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=-1",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 4",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-1 access_size=2147483647",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 5",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-512 access_size=2147483647",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, invalid access 6",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid stack type R3 off=-512 access_size=0",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"raw_stack: skb_load_bytes, large access",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_4, 512),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test1",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test2",
-		.insns = {
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_4, 15),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 7),
-			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_3, 12),
-			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 14),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_4),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 48),
-			BPF_ALU64_IMM(BPF_RSH, BPF_REG_2, 48),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_2),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_3),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 8),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
-			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_3, 4),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test3",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid bpf_context access off=76",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SOCKET_FILTER,
-	},
-	{
-		"direct packet access: test4 (write)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
-			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test5 (pkt_end >= reg, good access)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test6 (pkt_end >= reg, bad access)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid access to packet",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test7 (pkt_end >= reg, both accesses)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid access to packet",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test8 (double test, variant 1)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 4),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test9 (double test, variant 2)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 1),
-			BPF_EXIT_INSN(),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"direct packet access: test10 (write invalid)",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.errstr = "invalid access to packet",
-		.result = REJECT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test1, valid packet_ptr range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct xdp_md, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct xdp_md, data_end)),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 5),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {5},
-		.result_unpriv = ACCEPT,
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_XDP,
-	},
-	{
-		"helper access to packet: test2, unchecked packet_ptr",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct xdp_md, data)),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {1},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_XDP,
-	},
-	{
-		"helper access to packet: test3, variable add",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-					offsetof(struct xdp_md, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-					offsetof(struct xdp_md, data_end)),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 10),
-			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_2, 0),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_5),
-			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 4),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_4),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {11},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_XDP,
-	},
-	{
-		"helper access to packet: test4, packet_ptr with bad range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct xdp_md, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct xdp_md, data_end)),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {7},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_XDP,
-	},
-	{
-		"helper access to packet: test5, packet_ptr with too short range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct xdp_md, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct xdp_md, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 3),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {6},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_XDP,
-	},
-	{
-		"helper access to packet: test6, cls valid packet_ptr range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 5),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_update_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {5},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test7, cls unchecked packet_ptr",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {1},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test8, cls variable add",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-					offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-					offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 10),
-			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_2, 0),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_5),
-			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 4),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_4),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {11},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test9, cls packet_ptr with bad range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 2),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {7},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test10, cls packet_ptr with too short range",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
-			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 3),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.fixup = {6},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test11, cls unsuitable helper 1",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_3, BPF_REG_7, 4),
-			BPF_MOV64_IMM(BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 42),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_store_bytes),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "helper access to the packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test12, cls unsuitable helper 2",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_7, 3),
-			BPF_MOV64_IMM(BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 4),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_skb_load_bytes),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "helper access to the packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test13, cls helper ok",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = ACCEPT,
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test14, cls helper fail sub",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_ALU64_IMM(BPF_SUB, BPF_REG_1, 4),
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "type=inv expected=fp",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test15, cls helper fail range 1",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_2, 8),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test16, cls helper fail range 2",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_2, -9),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test17, cls helper fail range 3",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_2, ~0),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test18, cls helper fail range zero",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_MOV64_IMM(BPF_REG_2, 0),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test19, pkt end as input",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_7),
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "R1 type=pkt_end expected=fp",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"helper access to packet: test20, wrong reg",
-		.insns = {
-			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
-				    offsetof(struct __sk_buff, data)),
-			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
-				    offsetof(struct __sk_buff, data_end)),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
-			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
-			BPF_MOV64_IMM(BPF_REG_2, 4),
-			BPF_MOV64_IMM(BPF_REG_3, 0),
-			BPF_MOV64_IMM(BPF_REG_4, 0),
-			BPF_MOV64_IMM(BPF_REG_5, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_csum_diff),
-			BPF_MOV64_IMM(BPF_REG_0, 0),
-			BPF_EXIT_INSN(),
-		},
-		.result = REJECT,
-		.errstr = "invalid access to packet",
-		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
-	},
-	{
-		"valid map access into an array with a constant",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr_unpriv = "R0 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"valid map access into an array with a register",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
-			BPF_MOV64_IMM(BPF_REG_1, 4),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr_unpriv = "R0 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"valid map access into an array with a variable",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES, 3),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr_unpriv = "R0 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"valid map access into an array with a signed variable",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 9),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
-			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 0xffffffff, 1),
-			BPF_MOV32_IMM(BPF_REG_1, 0),
-			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
-			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
-			BPF_MOV32_IMM(BPF_REG_1, 0),
-			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr_unpriv = "R0 leaks addr",
-		.result_unpriv = REJECT,
-		.result = ACCEPT,
-	},
-	{
-		"invalid map access into an array with a constant",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, (MAX_ENTRIES + 1) << 2,
-				   offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr = "invalid access to map value, value_size=48 off=48 size=8",
-		.result = REJECT,
-	},
-	{
-		"invalid map access into an array with a register",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
-			BPF_MOV64_IMM(BPF_REG_1, MAX_ENTRIES + 1),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr = "R0 min value is outside of the array range",
-		.result = REJECT,
-	},
-	{
-		"invalid map access into an array with a variable",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
-			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
-		.result = REJECT,
-	},
-	{
-		"invalid map access into an array with no floor check",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
-			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
-			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
-			BPF_MOV32_IMM(BPF_REG_1, 0),
-			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
-		.result = REJECT,
-	},
-	{
-		"invalid map access into an array with a invalid max check",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
-			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
-			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES + 1),
-			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
-			BPF_MOV32_IMM(BPF_REG_1, 0),
-			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
-			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3},
-		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
-		.result = REJECT,
-	},
-	{
-		"invalid map access into an array with a invalid max check",
-		.insns = {
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 10),
-			BPF_MOV64_REG(BPF_REG_8, BPF_REG_0),
-			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
-			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
-			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
-			BPF_LD_MAP_FD(BPF_REG_1, 0),
-			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
-			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
-			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_8),
-			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0, offsetof(struct test_val, foo)),
-			BPF_EXIT_INSN(),
-		},
-		.test_val_map_fixup = {3, 11},
-		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
-		.result = REJECT,
-	},
-};
-
-static int probe_filter_length(struct bpf_insn *fp)
-{
-	int len = 0;
-
-	for (len = MAX_INSNS - 1; len > 0; --len)
-		if (fp[len].code != 0 || fp[len].imm != 0)
-			break;
-
-	return len + 1;
-}
-
-static int create_map(size_t val_size, int num)
-{
-	int map_fd;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_HASH,
-				sizeof(long long), val_size, num, 0);
-	if (map_fd < 0)
-		printf("failed to create map '%s'\n", strerror(errno));
-
-	return map_fd;
-}
-
-static int create_prog_array(void)
-{
-	int map_fd;
-
-	map_fd = bpf_create_map(BPF_MAP_TYPE_PROG_ARRAY,
-				sizeof(int), sizeof(int), 4, 0);
-	if (map_fd < 0)
-		printf("failed to create prog_array '%s'\n", strerror(errno));
-
-	return map_fd;
-}
-
-static int test(void)
-{
-	int prog_fd, i, pass_cnt = 0, err_cnt = 0;
-	bool unpriv = geteuid() != 0;
-
-	for (i = 0; i < ARRAY_SIZE(tests); i++) {
-		struct bpf_insn *prog = tests[i].insns;
-		int prog_type = tests[i].prog_type;
-		int prog_len = probe_filter_length(prog);
-		int *fixup = tests[i].fixup;
-		int *prog_array_fixup = tests[i].prog_array_fixup;
-		int *test_val_map_fixup = tests[i].test_val_map_fixup;
-		int expected_result;
-		const char *expected_errstr;
-		int map_fd = -1, prog_array_fd = -1, test_val_map_fd = -1;
-
-		if (*fixup) {
-			map_fd = create_map(sizeof(long long), 1024);
-
-			do {
-				prog[*fixup].imm = map_fd;
-				fixup++;
-			} while (*fixup);
-		}
-		if (*prog_array_fixup) {
-			prog_array_fd = create_prog_array();
-
-			do {
-				prog[*prog_array_fixup].imm = prog_array_fd;
-				prog_array_fixup++;
-			} while (*prog_array_fixup);
-		}
-		if (*test_val_map_fixup) {
-			/* Unprivileged can't create a hash map.*/
-			if (unpriv)
-				continue;
-			test_val_map_fd = create_map(sizeof(struct test_val),
-						     256);
-			do {
-				prog[*test_val_map_fixup].imm = test_val_map_fd;
-				test_val_map_fixup++;
-			} while (*test_val_map_fixup);
-		}
-
-		printf("#%d %s ", i, tests[i].descr);
-
-		prog_fd = bpf_prog_load(prog_type ?: BPF_PROG_TYPE_SOCKET_FILTER,
-					prog, prog_len * sizeof(struct bpf_insn),
-					"GPL", 0);
-
-		if (unpriv && tests[i].result_unpriv != UNDEF)
-			expected_result = tests[i].result_unpriv;
-		else
-			expected_result = tests[i].result;
-
-		if (unpriv && tests[i].errstr_unpriv)
-			expected_errstr = tests[i].errstr_unpriv;
-		else
-			expected_errstr = tests[i].errstr;
-
-		if (expected_result == ACCEPT) {
-			if (prog_fd < 0) {
-				printf("FAIL\nfailed to load prog '%s'\n",
-				       strerror(errno));
-				printf("%s", bpf_log_buf);
-				err_cnt++;
-				goto fail;
-			}
-		} else {
-			if (prog_fd >= 0) {
-				printf("FAIL\nunexpected success to load\n");
-				printf("%s", bpf_log_buf);
-				err_cnt++;
-				goto fail;
-			}
-			if (strstr(bpf_log_buf, expected_errstr) == 0) {
-				printf("FAIL\nunexpected error message: %s",
-				       bpf_log_buf);
-				err_cnt++;
-				goto fail;
-			}
-		}
-
-		pass_cnt++;
-		printf("OK\n");
-fail:
-		if (map_fd >= 0)
-			close(map_fd);
-		if (prog_array_fd >= 0)
-			close(prog_array_fd);
-		if (test_val_map_fd >= 0)
-			close(test_val_map_fd);
-		close(prog_fd);
-
-	}
-	printf("Summary: %d PASSED, %d FAILED\n", pass_cnt, err_cnt);
-
-	return 0;
-}
-
-int main(void)
-{
-	struct rlimit r = {1 << 20, 1 << 20};
-
-	setrlimit(RLIMIT_MEMLOCK, &r);
-	return test();
-}
diff --git a/tools/include/linux/filter.h b/tools/include/linux/filter.h
index 3276625..122153b 100644
--- a/tools/include/linux/filter.h
+++ b/tools/include/linux/filter.h
@@ -218,6 +218,30 @@
 		.off   = OFF,					\
 		.imm   = IMM })
 
+/* BPF_LD_IMM64 macro encodes single 'load 64-bit immediate' insn */
+
+#define BPF_LD_IMM64(DST, IMM)					\
+	BPF_LD_IMM64_RAW(DST, 0, IMM)
+
+#define BPF_LD_IMM64_RAW(DST, SRC, IMM)				\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_DW | BPF_IMM,		\
+		.dst_reg = DST,					\
+		.src_reg = SRC,					\
+		.off   = 0,					\
+		.imm   = (__u32) (IMM) }),			\
+	((struct bpf_insn) {					\
+		.code  = 0, /* zero is reserved opcode */	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = ((__u64) (IMM)) >> 32 })
+
+/* pseudo BPF_LD_IMM64 insn used to refer to process-local map_fd */
+
+#define BPF_LD_MAP_FD(DST, MAP_FD)				\
+	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
+
 /* Program exit */
 
 #define BPF_EXIT_INSN()						\
diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index f770dba..a3144a3 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -1,4 +1,5 @@
-TARGETS = breakpoints
+TARGETS =  bpf
+TARGETS += breakpoints
 TARGETS += capabilities
 TARGETS += cpu-hotplug
 TARGETS += efivarfs
diff --git a/tools/testing/selftests/bpf/.gitignore b/tools/testing/selftests/bpf/.gitignore
new file mode 100644
index 0000000..3c59f96e
--- /dev/null
+++ b/tools/testing/selftests/bpf/.gitignore
@@ -0,0 +1,2 @@
+test_verifier
+test_maps
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
new file mode 100644
index 0000000..4761e2d6
--- /dev/null
+++ b/tools/testing/selftests/bpf/Makefile
@@ -0,0 +1,13 @@
+CFLAGS += -Wall -O2
+
+test_objs = test_verifier test_maps
+
+TEST_PROGS := test_verifier test_maps test_kmod.sh
+TEST_FILES := $(test_objs)
+
+all: $(test_objs)
+
+include ../lib.mk
+
+clean:
+	$(RM) $(test_objs)
diff --git a/tools/testing/selftests/bpf/bpf_sys.h b/tools/testing/selftests/bpf/bpf_sys.h
new file mode 100644
index 0000000..6b4565f
--- /dev/null
+++ b/tools/testing/selftests/bpf/bpf_sys.h
@@ -0,0 +1,108 @@
+#ifndef __BPF_SYS__
+#define __BPF_SYS__
+
+#include <stdint.h>
+#include <stdlib.h>
+
+#include <sys/syscall.h>
+
+#include <linux/bpf.h>
+
+static inline __u64 bpf_ptr_to_u64(const void *ptr)
+{
+	return (__u64)(unsigned long) ptr;
+}
+
+static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
+{
+#ifdef __NR_bpf
+	return syscall(__NR_bpf, cmd, attr, size);
+#else
+	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
+	errno = ENOSYS;
+	return -1;
+#endif
+}
+
+static inline int bpf_map_lookup(int fd, const void *key, void *value)
+{
+	union bpf_attr attr = {};
+
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+	attr.value = bpf_ptr_to_u64(value);
+
+	return bpf(BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+static inline int bpf_map_update(int fd, const void *key, const void *value,
+				 uint64_t flags)
+{
+	union bpf_attr attr = {};
+
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+	attr.value = bpf_ptr_to_u64(value);
+	attr.flags = flags;
+
+	return bpf(BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
+}
+
+static inline int bpf_map_delete(int fd, const void *key)
+{
+	union bpf_attr attr = {};
+
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+
+	return bpf(BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
+}
+
+static inline int bpf_map_next_key(int fd, const void *key, void *next_key)
+{
+	union bpf_attr attr = {};
+
+	attr.map_fd = fd;
+	attr.key = bpf_ptr_to_u64(key);
+	attr.next_key = bpf_ptr_to_u64(next_key);
+
+	return bpf(BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
+}
+
+static inline int bpf_map_create(enum bpf_map_type type, uint32_t size_key,
+				 uint32_t size_value, uint32_t max_elem,
+				 uint32_t flags)
+{
+	union bpf_attr attr = {};
+
+	attr.map_type = type;
+	attr.key_size = size_key;
+	attr.value_size = size_value;
+	attr.max_entries = max_elem;
+	attr.map_flags = flags;
+
+	return bpf(BPF_MAP_CREATE, &attr, sizeof(attr));
+}
+
+static inline int bpf_prog_load(enum bpf_prog_type type,
+				const struct bpf_insn *insns, size_t size_insns,
+				const char *license, char *log, size_t size_log)
+{
+	union bpf_attr attr = {};
+
+	attr.prog_type = type;
+	attr.insns = bpf_ptr_to_u64(insns);
+	attr.insn_cnt = size_insns / sizeof(struct bpf_insn);
+	attr.license = bpf_ptr_to_u64(license);
+
+	if (size_log > 0) {
+		attr.log_buf = bpf_ptr_to_u64(log);
+		attr.log_size = size_log;
+		attr.log_level = 1;
+		log[0] = 0;
+	}
+
+	return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
+#endif /* __BPF_SYS__ */
diff --git a/tools/testing/selftests/bpf/config b/tools/testing/selftests/bpf/config
new file mode 100644
index 0000000..52d53ed
--- /dev/null
+++ b/tools/testing/selftests/bpf/config
@@ -0,0 +1,5 @@
+CONFIG_BPF=y
+CONFIG_BPF_SYSCALL=y
+CONFIG_NET_CLS_BPF=m
+CONFIG_BPF_EVENTS=y
+CONFIG_TEST_BPF=m
diff --git a/tools/testing/selftests/bpf/test_kmod.sh b/tools/testing/selftests/bpf/test_kmod.sh
new file mode 100755
index 0000000..92e627a
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_kmod.sh
@@ -0,0 +1,39 @@
+#!/bin/bash
+
+SRC_TREE=../../../../
+
+test_run()
+{
+	sysctl -w net.core.bpf_jit_enable=$1 2>&1 > /dev/null
+	sysctl -w net.core.bpf_jit_harden=$2 2>&1 > /dev/null
+
+	echo "[ JIT enabled:$1 hardened:$2 ]"
+	dmesg -C
+	insmod $SRC_TREE/lib/test_bpf.ko 2> /dev/null
+	if [ $? -ne 0 ]; then
+		rc=1
+	fi
+	rmmod  test_bpf 2> /dev/null
+	dmesg | grep FAIL
+}
+
+test_save()
+{
+	JE=`sysctl -n net.core.bpf_jit_enable`
+	JH=`sysctl -n net.core.bpf_jit_harden`
+}
+
+test_restore()
+{
+	sysctl -w net.core.bpf_jit_enable=$JE 2>&1 > /dev/null
+	sysctl -w net.core.bpf_jit_harden=$JH 2>&1 > /dev/null
+}
+
+rc=0
+test_save
+test_run 0 0
+test_run 1 0
+test_run 1 1
+test_run 1 2
+test_restore
+exit $rc
diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
new file mode 100644
index 0000000..ee384f0
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -0,0 +1,525 @@
+/*
+ * Testsuite for eBPF maps
+ *
+ * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ * Copyright (c) 2016 Facebook
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+
+#include <stdio.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <assert.h>
+#include <stdlib.h>
+
+#include <sys/wait.h>
+#include <sys/resource.h>
+
+#include <linux/bpf.h>
+
+#include "bpf_sys.h"
+
+static int map_flags;
+
+static void test_hashmap(int task, void *data)
+{
+	long long key, next_key, value;
+	int fd;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+			    2, map_flags);
+	if (fd < 0) {
+		printf("Failed to create hashmap '%s'!\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* Insert key=1 element. */
+	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+
+	value = 0;
+	/* BPF_NOEXIST means add new element if it doesn't exist. */
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       /* key=1 already exists. */
+	       errno == EEXIST);
+
+	/* -1 is an invalid flag. */
+	assert(bpf_map_update(fd, &key, &value, -1) == -1 && errno == EINVAL);
+
+	/* Check that key=1 can be found. */
+	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 1234);
+
+	key = 2;
+	/* Check that key=2 is not found. */
+	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+
+	/* BPF_EXIST means update existing element. */
+	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == -1 &&
+	       /* key=2 is not there. */
+	       errno == ENOENT);
+
+	/* Insert key=2 element. */
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
+
+	/* key=1 and key=2 were inserted, check that key=0 cannot be
+	 * inserted due to max_entries limit.
+	 */
+	key = 0;
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* Update existing element, though the map is full. */
+	key = 1;
+	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == 0);
+	key = 2;
+	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+	key = 1;
+	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+
+	/* Check that key = 0 doesn't exist. */
+	key = 0;
+	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+
+	/* Iterate over two elements. */
+	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	       (next_key == 1 || next_key == 2));
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	       (next_key == 1 || next_key == 2));
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	/* Delete both elements. */
+	key = 1;
+	assert(bpf_map_delete(fd, &key) == 0);
+	key = 2;
+	assert(bpf_map_delete(fd, &key) == 0);
+	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+
+	key = 0;
+	/* Check that map is empty. */
+	assert(bpf_map_next_key(fd, &key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	close(fd);
+}
+
+static void test_hashmap_percpu(int task, void *data)
+{
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	long long value[nr_cpus];
+	long long key, next_key;
+	int expected_key_mask = 0;
+	int fd, i;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
+			    sizeof(value[0]), 2, map_flags);
+	if (fd < 0) {
+		printf("Failed to create hashmap '%s'!\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		value[i] = i + 100;
+
+	key = 1;
+	/* Insert key=1 element. */
+	assert(!(expected_key_mask & key));
+	assert(bpf_map_update(fd, &key, value, BPF_ANY) == 0);
+	expected_key_mask |= key;
+
+	/* BPF_NOEXIST means add new element if it doesn't exist. */
+	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == -1 &&
+	       /* key=1 already exists. */
+	       errno == EEXIST);
+
+	/* -1 is an invalid flag. */
+	assert(bpf_map_update(fd, &key, value, -1) == -1 && errno == EINVAL);
+
+	/* Check that key=1 can be found. Value could be 0 if the lookup
+	 * was run from a different CPU.
+	 */
+	value[0] = 1;
+	assert(bpf_map_lookup(fd, &key, value) == 0 && value[0] == 100);
+
+	key = 2;
+	/* Check that key=2 is not found. */
+	assert(bpf_map_lookup(fd, &key, value) == -1 && errno == ENOENT);
+
+	/* BPF_EXIST means update existing element. */
+	assert(bpf_map_update(fd, &key, value, BPF_EXIST) == -1 &&
+	       /* key=2 is not there. */
+	       errno == ENOENT);
+
+	/* Insert key=2 element. */
+	assert(!(expected_key_mask & key));
+	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == 0);
+	expected_key_mask |= key;
+
+	/* key=1 and key=2 were inserted, check that key=0 cannot be
+	 * inserted due to max_entries limit.
+	 */
+	key = 0;
+	assert(bpf_map_update(fd, &key, value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* Check that key = 0 doesn't exist. */
+	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+
+	/* Iterate over two elements. */
+	while (!bpf_map_next_key(fd, &key, &next_key)) {
+		assert((expected_key_mask & next_key) == next_key);
+		expected_key_mask &= ~next_key;
+
+		assert(bpf_map_lookup(fd, &next_key, value) == 0);
+
+		for (i = 0; i < nr_cpus; i++)
+			assert(value[i] == i + 100);
+
+		key = next_key;
+	}
+	assert(errno == ENOENT);
+
+	/* Update with BPF_EXIST. */
+	key = 1;
+	assert(bpf_map_update(fd, &key, value, BPF_EXIST) == 0);
+
+	/* Delete both elements. */
+	key = 1;
+	assert(bpf_map_delete(fd, &key) == 0);
+	key = 2;
+	assert(bpf_map_delete(fd, &key) == 0);
+	assert(bpf_map_delete(fd, &key) == -1 && errno == ENOENT);
+
+	key = 0;
+	/* Check that map is empty. */
+	assert(bpf_map_next_key(fd, &key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	close(fd);
+}
+
+static void test_arraymap(int task, void *data)
+{
+	int key, next_key, fd;
+	long long value;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
+			    2, 0);
+	if (fd < 0) {
+		printf("Failed to create arraymap '%s'!\n", strerror(errno));
+		exit(1);
+	}
+
+	key = 1;
+	value = 1234;
+	/* Insert key=1 element. */
+	assert(bpf_map_update(fd, &key, &value, BPF_ANY) == 0);
+
+	value = 0;
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* Check that key=1 can be found. */
+	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 1234);
+
+	key = 0;
+	/* Check that key=0 is also found and zero initialized. */
+	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 0);
+
+	/* key=0 and key=1 were inserted, check that key=2 cannot be inserted
+	 * due to max_entries limit.
+	 */
+	key = 2;
+	assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* Check that key = 2 doesn't exist. */
+	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+
+	/* Iterate over two elements. */
+	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	       next_key == 0);
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	       next_key == 1);
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	/* Delete shouldn't succeed. */
+	key = 1;
+	assert(bpf_map_delete(fd, &key) == -1 && errno == EINVAL);
+
+	close(fd);
+}
+
+static void test_arraymap_percpu(int task, void *data)
+{
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	int key, next_key, fd, i;
+	long values[nr_cpus];
+
+	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+			    sizeof(values[0]), 2, 0);
+	if (fd < 0) {
+		printf("Failed to create arraymap '%s'!\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		values[i] = i + 100;
+
+	key = 1;
+	/* Insert key=1 element. */
+	assert(bpf_map_update(fd, &key, values, BPF_ANY) == 0);
+
+	values[0] = 0;
+	assert(bpf_map_update(fd, &key, values, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* Check that key=1 can be found. */
+	assert(bpf_map_lookup(fd, &key, values) == 0 && values[0] == 100);
+
+	key = 0;
+	/* Check that key=0 is also found and zero initialized. */
+	assert(bpf_map_lookup(fd, &key, values) == 0 &&
+	       values[0] == 0 && values[nr_cpus - 1] == 0);
+
+	/* Check that key=2 cannot be inserted due to max_entries limit. */
+	key = 2;
+	assert(bpf_map_update(fd, &key, values, BPF_EXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* Check that key = 2 doesn't exist. */
+	assert(bpf_map_lookup(fd, &key, values) == -1 && errno == ENOENT);
+
+	/* Iterate over two elements. */
+	assert(bpf_map_next_key(fd, &key, &next_key) == 0 &&
+	       next_key == 0);
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == 0 &&
+	       next_key == 1);
+	assert(bpf_map_next_key(fd, &next_key, &next_key) == -1 &&
+	       errno == ENOENT);
+
+	/* Delete shouldn't succeed. */
+	key = 1;
+	assert(bpf_map_delete(fd, &key) == -1 && errno == EINVAL);
+
+	close(fd);
+}
+
+static void test_arraymap_percpu_many_keys(void)
+{
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned int nr_keys = 20000;
+	long values[nr_cpus];
+	int key, fd, i;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+			    sizeof(values[0]), nr_keys, 0);
+	if (fd < 0) {
+		printf("Failed to create per-cpu arraymap '%s'!\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		values[i] = i + 10;
+
+	for (key = 0; key < nr_keys; key++)
+		assert(bpf_map_update(fd, &key, values, BPF_ANY) == 0);
+
+	for (key = 0; key < nr_keys; key++) {
+		for (i = 0; i < nr_cpus; i++)
+			values[i] = 0;
+
+		assert(bpf_map_lookup(fd, &key, values) == 0);
+
+		for (i = 0; i < nr_cpus; i++)
+			assert(values[i] == i + 10);
+	}
+
+	close(fd);
+}
+
+#define MAP_SIZE (32 * 1024)
+
+static void test_map_large(void)
+{
+	struct bigkey {
+		int a;
+		char b[116];
+		long long c;
+	} key;
+	int fd, i, value;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+			    MAP_SIZE, map_flags);
+	if (fd < 0) {
+		printf("Failed to create large map '%s'!\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < MAP_SIZE; i++) {
+		key = (struct bigkey) { .c = i };
+		value = i;
+
+		assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
+	}
+
+	key.c = -1;
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* Iterate through all elements. */
+	for (i = 0; i < MAP_SIZE; i++)
+		assert(bpf_map_next_key(fd, &key, &key) == 0);
+	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+
+	key.c = 0;
+	assert(bpf_map_lookup(fd, &key, &value) == 0 && value == 0);
+	key.a = 1;
+	assert(bpf_map_lookup(fd, &key, &value) == -1 && errno == ENOENT);
+
+	close(fd);
+}
+
+static void run_parallel(int tasks, void (*fn)(int task, void *data),
+			 void *data)
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
+			printf("Couldn't spawn #%d process!\n", i);
+			exit(1);
+		}
+	}
+
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
+	run_parallel(100, test_hashmap, NULL);
+	run_parallel(100, test_hashmap_percpu, NULL);
+
+	run_parallel(100, test_arraymap, NULL);
+	run_parallel(100, test_arraymap_percpu, NULL);
+}
+
+#define TASKS 1024
+
+#define DO_UPDATE 1
+#define DO_DELETE 0
+
+static void do_work(int fn, void *data)
+{
+	int do_update = ((int *)data)[1];
+	int fd = ((int *)data)[0];
+	int i, key, value;
+
+	for (i = fn; i < MAP_SIZE; i += TASKS) {
+		key = value = i;
+
+		if (do_update) {
+			assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == 0);
+			assert(bpf_map_update(fd, &key, &value, BPF_EXIST) == 0);
+		} else {
+			assert(bpf_map_delete(fd, &key) == 0);
+		}
+	}
+}
+
+static void test_map_parallel(void)
+{
+	int i, fd, key = 0, value = 0;
+	int data[2];
+
+	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(key), sizeof(value),
+			    MAP_SIZE, map_flags);
+	if (fd < 0) {
+		printf("Failed to create map for parallel test '%s'!\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	/* Use the same fd in children to add elements to this map:
+	 * child_0 adds key=0, key=1024, key=2048, ...
+	 * child_1 adds key=1, key=1025, key=2049, ...
+	 * child_1023 adds key=1023, ...
+	 */
+	data[0] = fd;
+	data[1] = DO_UPDATE;
+	run_parallel(TASKS, do_work, data);
+
+	/* Check that key=0 is already there. */
+	assert(bpf_map_update(fd, &key, &value, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* Check that all elements were inserted. */
+	key = -1;
+	for (i = 0; i < MAP_SIZE; i++)
+		assert(bpf_map_next_key(fd, &key, &key) == 0);
+	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+
+	/* Another check for all elements */
+	for (i = 0; i < MAP_SIZE; i++) {
+		key = MAP_SIZE - i - 1;
+
+		assert(bpf_map_lookup(fd, &key, &value) == 0 &&
+		       value == key);
+	}
+
+	/* Now let's delete all elemenets in parallel. */
+	data[1] = DO_DELETE;
+	run_parallel(TASKS, do_work, data);
+
+	/* Nothing should be left. */
+	key = -1;
+	assert(bpf_map_next_key(fd, &key, &key) == -1 && errno == ENOENT);
+}
+
+static void run_all_tests(void)
+{
+	test_hashmap(0, NULL);
+	test_hashmap_percpu(0, NULL);
+
+	test_arraymap(0, NULL);
+	test_arraymap_percpu(0, NULL);
+
+	test_arraymap_percpu_many_keys();
+
+	test_map_large();
+	test_map_parallel();
+	test_map_stress();
+}
+
+int main(void)
+{
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+
+	setrlimit(RLIMIT_MEMLOCK, &rinf);
+
+	map_flags = 0;
+	run_all_tests();
+
+	map_flags = BPF_F_NO_PREALLOC;
+	run_all_tests();
+
+	printf("test_maps: OK\n");
+	return 0;
+}
diff --git a/tools/testing/selftests/bpf/test_verifier.c b/tools/testing/selftests/bpf/test_verifier.c
new file mode 100644
index 0000000..ff5df12
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_verifier.c
@@ -0,0 +1,2764 @@
+/*
+ * Testsuite for eBPF verifier
+ *
+ * Copyright (c) 2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+
+#include <stdio.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <stddef.h>
+#include <stdbool.h>
+#include <sched.h>
+
+#include <sys/resource.h>
+
+#include <linux/unistd.h>
+#include <linux/filter.h>
+#include <linux/bpf_perf_event.h>
+#include <linux/bpf.h>
+
+#include "../../../include/linux/filter.h"
+
+#include "bpf_sys.h"
+
+#ifndef ARRAY_SIZE
+# define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#define MAX_INSNS	512
+#define MAX_FIXUPS	8
+
+struct bpf_test {
+	const char *descr;
+	struct bpf_insn	insns[MAX_INSNS];
+	int fixup_map1[MAX_FIXUPS];
+	int fixup_map2[MAX_FIXUPS];
+	int fixup_prog[MAX_FIXUPS];
+	const char *errstr;
+	const char *errstr_unpriv;
+	enum {
+		UNDEF,
+		ACCEPT,
+		REJECT
+	} result, result_unpriv;
+	enum bpf_prog_type prog_type;
+};
+
+/* Note we want this to be 64 bit aligned so that the end of our array is
+ * actually the end of the structure.
+ */
+#define MAX_ENTRIES 11
+
+struct test_val {
+	unsigned int index;
+	int foo[MAX_ENTRIES];
+};
+
+static struct bpf_test tests[] = {
+	{
+		"add+sub+mul",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 2),
+			BPF_MOV64_IMM(BPF_REG_2, 3),
+			BPF_ALU64_REG(BPF_SUB, BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -1),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_1, 3),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"unreachable",
+		.insns = {
+			BPF_EXIT_INSN(),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"unreachable2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "unreachable",
+		.result = REJECT,
+	},
+	{
+		"out of range jump",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"out of range jump2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"test1 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"test2 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM insn",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"test3 ld_imm64",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 0),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_LD_IMM64(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test4 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"test5 ld_imm64",
+		.insns = {
+			BPF_RAW_INSN(BPF_LD | BPF_IMM | BPF_DW, 0, 0, 0, 0),
+		},
+		.errstr = "invalid bpf_ld_imm64 insn",
+		.result = REJECT,
+	},
+	{
+		"no bpf_exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_0, BPF_REG_2),
+		},
+		.errstr = "jump out of range",
+		.result = REJECT,
+	},
+	{
+		"loop (back-edge)",
+		.insns = {
+			BPF_JMP_IMM(BPF_JA, 0, 0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"loop2 (back-edge)",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"conditional loop",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, -3),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "back-edge",
+		.result = REJECT,
+	},
+	{
+		"read uninitialized register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R2 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"read invalid register",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"program doesn't init R0 before exit",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.result = REJECT,
+	},
+	{
+		"program doesn't init R0 before exit in all branches",
+		.insns = {
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R0 !read_ok",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"stack out of bounds",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid stack",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn1",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL | BPF_X, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid call insn2",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_CALL uses reserved",
+		.result = REJECT,
+	},
+	{
+		"invalid function call",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, 1234567),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid func 1234567",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 2 },
+		.errstr = "invalid indirect read from stack",
+		.result = REJECT,
+	},
+	{
+		"uninitialized stack2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid read from stack",
+		.result = REJECT,
+	},
+	{
+		"invalid argument register",
+		.insns = {
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_cgroup_classid),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_cgroup_classid),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R1 !read_ok",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"non-invalid argument register",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_1),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_cgroup_classid),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_1, BPF_REG_6),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_cgroup_classid),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"check valid spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			/* fill it back into R2 */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_10, -8),
+			/* should be able to access R0 = *(R2 + 8) */
+			/* BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, 8), */
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R0 leaks addr",
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+	},
+	{
+		"check valid spill/fill, skb mark",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = ACCEPT,
+	},
+	{
+		"check corrupted spill/fill",
+		.insns = {
+			/* spill R1(ctx) into stack */
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_1, -8),
+			/* mess up with R1 pointer on stack */
+			BPF_ST_MEM(BPF_B, BPF_REG_10, -7, 0x23),
+			/* fill back into R0 should fail */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_10, -8),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "attempt to corrupt spilled",
+		.errstr = "corrupted spill",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, BPF_REG_10, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R15 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in STX",
+		.insns = {
+			BPF_STX_MEM(BPF_B, 14, BPF_REG_10, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in ST",
+		.insns = {
+			BPF_ST_MEM(BPF_B, 14, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R14 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid src register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, 12, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R12 is invalid",
+		.result = REJECT,
+	},
+	{
+		"invalid dst register in LDX",
+		.insns = {
+			BPF_LDX_MEM(BPF_B, 11, BPF_REG_1, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "R11 is invalid",
+		.result = REJECT,
+	},
+	{
+		"junk insn",
+		.insns = {
+			BPF_RAW_INSN(0, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_LD_IMM",
+		.result = REJECT,
+	},
+	{
+		"junk insn2",
+		.insns = {
+			BPF_RAW_INSN(1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_LDX uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"junk insn3",
+		.insns = {
+			BPF_RAW_INSN(-1, 0, 0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn4",
+		.insns = {
+			BPF_RAW_INSN(-1, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid BPF_ALU opcode f0",
+		.result = REJECT,
+	},
+	{
+		"junk insn5",
+		.insns = {
+			BPF_RAW_INSN(0x7f, -1, -1, -1, -1),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "BPF_ALU uses reserved fields",
+		.result = REJECT,
+	},
+	{
+		"misaligned read from stack",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_2, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"invalid map_fd for function call",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_delete_elem),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "fd 0 is not pointing to valid bpf_map",
+		.result = REJECT,
+	},
+	{
+		"don't check return value before access",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr = "R0 invalid mem access 'map_value_or_null'",
+		.result = REJECT,
+	},
+	{
+		"access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr = "misaligned access",
+		.result = REJECT,
+	},
+	{
+		"sometimes access memory with incorrect alignment",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr = "R0 invalid mem access",
+		.errstr_unpriv = "R0 leaks addr",
+		.result = REJECT,
+	},
+	{
+		"jump test 1",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_1, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 5),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"jump test 2",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 14),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 5),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 2),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"jump test 3",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -8, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 19),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 1, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -16, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 15),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 2, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -32, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -32),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 11),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 3, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -40, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -40),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 7),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 4, 3),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -48, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -48),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 5, 0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_2, -56, 0),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -56),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_delete_elem),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 24 },
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"jump test 4",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 1),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 2),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 3),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 4),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"jump test 5",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_3, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 2),
+			BPF_STX_MEM(BPF_DW, BPF_REG_2, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JA, 0, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"access skb fields ok",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, len)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, pkt_type)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, queue_mapping)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, protocol)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, vlan_present)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, vlan_tci)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"access skb fields bad1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1, -4),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"access skb fields bad2",
+		.insns = {
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 9),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, pkt_type)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 4 },
+		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"access skb fields bad3",
+		.insns = {
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 2),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, pkt_type)),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -12),
+		},
+		.fixup_map1 = { 6 },
+		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"access skb fields bad4",
+		.insns = {
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, 0, 3),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, len)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_0, 0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_0),
+			BPF_JMP_IMM(BPF_JA, 0, 0, -13),
+		},
+		.fixup_map1 = { 7 },
+		.errstr = "different pointers",
+		.errstr_unpriv = "R1 pointer comparison",
+		.result = REJECT,
+	},
+	{
+		"check skb->mark is not writeable by sockets",
+		.insns = {
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
+		.result = REJECT,
+	},
+	{
+		"check skb->tc_index is not writeable by sockets",
+		.insns = {
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
+		.result = REJECT,
+	},
+	{
+		"check non-u32 access to cb",
+		.insns = {
+			BPF_STX_MEM(BPF_H, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "R1 leaks addr",
+		.result = REJECT,
+	},
+	{
+		"check out of range skb->cb access",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0]) + 256),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access",
+		.errstr_unpriv = "",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_ACT,
+	},
+	{
+		"write skb fields from socket prog",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[4])),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_0, 0, 1),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[2])),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.errstr_unpriv = "R1 leaks addr",
+		.result_unpriv = REJECT,
+	},
+	{
+		"write skb fields from tc_cls_act prog",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, cb[0])),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_1,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, tc_index)),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_0,
+				    offsetof(struct __sk_buff, cb[3])),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"PTR_TO_STACK store/load",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"PTR_TO_STACK store/load - bad alignment on off",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 2, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 2),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "misaligned access off -6 size 8",
+	},
+	{
+		"PTR_TO_STACK store/load - bad alignment on reg",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -10),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "misaligned access off -2 size 8",
+	},
+	{
+		"PTR_TO_STACK store/load - out of bounds low",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -80000),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack off=-79992 size=8",
+	},
+	{
+		"PTR_TO_STACK store/load - out of bounds high",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_1, 8, 0xfaceb00c),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_1, 8),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack off=0 size=8",
+	},
+	{
+		"unpriv: return pointer",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_10),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R0 leaks addr",
+	},
+	{
+		"unpriv: add const to pointer",
+		.insns = {
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: add pointer to pointer",
+		.insns = {
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_1, BPF_REG_10),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: neg pointer",
+		.insns = {
+			BPF_ALU64_IMM(BPF_NEG, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer arithmetic",
+	},
+	{
+		"unpriv: cmp pointer with const",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R1 pointer comparison",
+	},
+	{
+		"unpriv: cmp pointer with pointer",
+		.insns = {
+			BPF_JMP_REG(BPF_JEQ, BPF_REG_1, BPF_REG_10, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.result_unpriv = REJECT,
+		.errstr_unpriv = "R10 pointer comparison",
+	},
+	{
+		"unpriv: check that printk is disallowed",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, -8),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_trace_printk),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "unknown func 6",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: pass pointer to helper function",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_update_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R4 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: indirectly pass pointer on stack to helper function",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr = "invalid indirect read from stack off -8+0 size 8",
+		.result = REJECT,
+	},
+	{
+		"unpriv: mangle pointer on stack 1",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_ST_MEM(BPF_W, BPF_REG_10, -8, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "attempt to corrupt spilled",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: mangle pointer on stack 2",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_ST_MEM(BPF_B, BPF_REG_10, -1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "attempt to corrupt spilled",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: read pointer from stack in small chunks",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_10, BPF_REG_10, -8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_10, -8),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid size",
+		.result = REJECT,
+	},
+	{
+		"unpriv: write pointer into ctx",
+		.insns = {
+			BPF_STX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R1 leaks addr",
+		.result_unpriv = REJECT,
+		.errstr = "invalid bpf_context access",
+		.result = REJECT,
+	},
+	{
+		"unpriv: spill/fill of ctx",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: spill/fill of ctx 2",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of ctx 3",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R1 type=fp expected=ctx",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of ctx 4",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_10,
+				     BPF_REG_0, -8, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_get_hash_recalc),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R1 type=inv expected=ctx",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of different pointers stx",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 42),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_STX_MEM(BPF_W, BPF_REG_1, BPF_REG_3,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "same insn cannot be used with different pointers",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"unpriv: spill/fill of different pointers ldx",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 3),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2,
+				      -(__s32)offsetof(struct bpf_perf_event_data,
+						       sample_period) - 8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_2, 0),
+			BPF_JMP_IMM(BPF_JNE, BPF_REG_1, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_6, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct bpf_perf_event_data,
+					     sample_period)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "same insn cannot be used with different pointers",
+		.prog_type = BPF_PROG_TYPE_PERF_EVENT,
+	},
+	{
+		"unpriv: write pointer into map elem value",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_STX_MEM(BPF_DW, BPF_REG_0, BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 3 },
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: partial copy of pointer",
+		.insns = {
+			BPF_MOV32_REG(BPF_REG_1, BPF_REG_10),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R10 partial copy",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: pass pointer to tail_call",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_1),
+			BPF_LD_MAP_FD(BPF_REG_2, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_tail_call),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_prog = { 1 },
+		.errstr_unpriv = "R3 leaks addr into helper",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: cmp map pointer with zero",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_1, 0),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_1, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 1 },
+		.errstr_unpriv = "R1 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: write into frame pointer",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_10, BPF_REG_1),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "frame pointer is read only",
+		.result = REJECT,
+	},
+	{
+		"unpriv: spill/fill frame pointer",
+		.insns = {
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_10, 0),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_10, BPF_REG_6, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "frame pointer is read only",
+		.result = REJECT,
+	},
+	{
+		"unpriv: cmp of frame pointer",
+		.insns = {
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_10, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R10 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: cmp of stack pointer",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_2, 0, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R2 pointer comparison",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"unpriv: obfuscate stack pointer",
+		.insns = {
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr_unpriv = "R2 pointer arithmetic",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"raw_stack: no skb_load_bytes",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			/* Call to skb_load_bytes() omitted. */
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid read from stack off -8+0 size 8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, negative len",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, -8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, negative len 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, ~0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, zero len",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, no init",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, init",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_ST_MEM(BPF_DW, BPF_REG_6, 0, 0xcafe),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs around bounds",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs corruption",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R0 invalid mem access 'inv'",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs corruption 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_3,
+				    offsetof(struct __sk_buff, pkt_type)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R3 invalid mem access 'inv'",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, spilled regs + data",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -16),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1, -8),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  0),
+			BPF_STX_MEM(BPF_DW, BPF_REG_6, BPF_REG_1,  8),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, -8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_2, BPF_REG_6,  8),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_3, BPF_REG_6,  0),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct __sk_buff, mark)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_2,
+				    offsetof(struct __sk_buff, priority)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_3),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 1",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -513),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-513 access_size=8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=8",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 3",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 0xffffffff),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0xffffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=-1",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 4",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -1),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-1 access_size=2147483647",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 5",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0x7fffffff),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-512 access_size=2147483647",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, invalid access 6",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid stack type R3 off=-512 access_size=0",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"raw_stack: skb_load_bytes, large access",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_ALU64_REG(BPF_MOV, BPF_REG_6, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, -512),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_4, 512),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_LDX_MEM(BPF_DW, BPF_REG_0, BPF_REG_6, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test2",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_4, 15),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_3, 7),
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_3, 12),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 14),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_4),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_2, 48),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_2, 48),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_1, BPF_REG_3, 4),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid bpf_context access off=76",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SOCKET_FILTER,
+	},
+	{
+		"direct packet access: test4 (write)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test5 (pkt_end >= reg, good access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test6 (pkt_end >= reg, bad access)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test7 (pkt_end >= reg, both accesses)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 3),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test8 (double test, variant 1)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test9 (double test, variant 2)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 1),
+			BPF_EXIT_INSN(),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_0, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"direct packet access: test10 (write invalid)",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_0, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_STX_MEM(BPF_B, BPF_REG_2, BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.errstr = "invalid access to packet",
+		.result = REJECT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test1, valid packet_ptr range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 5),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_update_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 5 },
+		.result_unpriv = ACCEPT,
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test2, unchecked packet_ptr",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 1 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test3, variable add",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+					offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+					offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 10),
+			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_2, 0),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_5),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_4),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 11 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test4, packet_ptr with bad range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 7 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test5, packet_ptr with too short range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct xdp_md, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct xdp_md, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 3),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 6 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_XDP,
+	},
+	{
+		"helper access to packet: test6, cls valid packet_ptr range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_3, 5),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_2),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_update_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 5 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test7, cls unchecked packet_ptr",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 1 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test8, cls variable add",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+					offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+					offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 10),
+			BPF_LDX_MEM(BPF_B, BPF_REG_5, BPF_REG_2, 0),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_4, BPF_REG_5),
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_5, BPF_REG_3, 4),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_4),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 11 },
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test9, cls packet_ptr with bad range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 7 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test10, cls packet_ptr with too short range",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, 1),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_4, BPF_REG_3, 3),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map1 = { 6 },
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test11, cls unsuitable helper 1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_3, BPF_REG_7, 4),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 42),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_store_bytes),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "helper access to the packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test12, cls unsuitable helper 2",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_MOV64_REG(BPF_REG_3, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 8),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_6, BPF_REG_7, 3),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 4),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_skb_load_bytes),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "helper access to the packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test13, cls helper ok",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = ACCEPT,
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test14, cls helper fail sub",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_ALU64_IMM(BPF_SUB, BPF_REG_1, 4),
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "type=inv expected=fp",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test15, cls helper fail range 1",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_2, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test16, cls helper fail range 2",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_2, -9),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test17, cls helper fail range 3",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_2, ~0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test18, cls helper fail range zero",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_MOV64_IMM(BPF_REG_2, 0),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test19, pkt end as input",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_7),
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "R1 type=pkt_end expected=fp",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"helper access to packet: test20, wrong reg",
+		.insns = {
+			BPF_LDX_MEM(BPF_W, BPF_REG_6, BPF_REG_1,
+				    offsetof(struct __sk_buff, data)),
+			BPF_LDX_MEM(BPF_W, BPF_REG_7, BPF_REG_1,
+				    offsetof(struct __sk_buff, data_end)),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_6, 1),
+			BPF_MOV64_REG(BPF_REG_1, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_1, 7),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_1, BPF_REG_7, 6),
+			BPF_MOV64_IMM(BPF_REG_2, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 0),
+			BPF_MOV64_IMM(BPF_REG_4, 0),
+			BPF_MOV64_IMM(BPF_REG_5, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_csum_diff),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.result = REJECT,
+		.errstr = "invalid access to packet",
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+	},
+	{
+		"valid map access into an array with a constant",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 leaks addr",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a register",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_IMM(BPF_REG_1, 4),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 5),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JGE, BPF_REG_1, MAX_ENTRIES, 3),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"valid map access into an array with a signed variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 9),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_JMP_IMM(BPF_JSGT, BPF_REG_1, 0xffffffff, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
+			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.result_unpriv = REJECT,
+		.result = ACCEPT,
+	},
+	{
+		"invalid map access into an array with a constant",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, (MAX_ENTRIES + 1) << 2,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr = "invalid access to map value, value_size=48 off=48 size=8",
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a register",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_MOV64_IMM(BPF_REG_1, MAX_ENTRIES + 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is outside of the array range",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a variable",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 4),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with no floor check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES),
+			BPF_JMP_REG(BPF_JSGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a invalid max check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 7),
+			BPF_LDX_MEM(BPF_W, BPF_REG_1, BPF_REG_0, 0),
+			BPF_MOV32_IMM(BPF_REG_2, MAX_ENTRIES + 1),
+			BPF_JMP_REG(BPF_JGT, BPF_REG_2, BPF_REG_1, 1),
+			BPF_MOV32_IMM(BPF_REG_1, 0),
+			BPF_ALU32_IMM(BPF_LSH, BPF_REG_1, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_1),
+			BPF_ST_MEM(BPF_DW, BPF_REG_0, 0,
+				   offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "invalid access to map value, value_size=48 off=44 size=8",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+	},
+	{
+		"invalid map access into an array with a invalid max check",
+		.insns = {
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 10),
+			BPF_MOV64_REG(BPF_REG_8, BPF_REG_0),
+			BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
+			BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
+			BPF_LD_MAP_FD(BPF_REG_1, 0),
+			BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0,
+				     BPF_FUNC_map_lookup_elem),
+			BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_0, BPF_REG_8),
+			BPF_LDX_MEM(BPF_W, BPF_REG_0, BPF_REG_0,
+				    offsetof(struct test_val, foo)),
+			BPF_EXIT_INSN(),
+		},
+		.fixup_map2 = { 3, 11 },
+		.errstr_unpriv = "R0 pointer arithmetic prohibited",
+		.errstr = "R0 min value is negative, either use unsigned index or do a if (index >=0) check.",
+		.result_unpriv = REJECT,
+		.result = REJECT,
+	},
+};
+
+static int probe_filter_length(const struct bpf_insn *fp)
+{
+	int len;
+
+	for (len = MAX_INSNS - 1; len > 0; --len)
+		if (fp[len].code != 0 || fp[len].imm != 0)
+			break;
+	return len + 1;
+}
+
+static int create_map(uint32_t size_value, uint32_t max_elem)
+{
+	int fd;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_HASH, sizeof(long long),
+			    size_value, max_elem, BPF_F_NO_PREALLOC);
+	if (fd < 0)
+		printf("Failed to create hash map '%s'!\n", strerror(errno));
+
+	return fd;
+}
+
+static int create_prog_array(void)
+{
+	int fd;
+
+	fd = bpf_map_create(BPF_MAP_TYPE_PROG_ARRAY, sizeof(int),
+			    sizeof(int), 4, 0);
+	if (fd < 0)
+		printf("Failed to create prog array '%s'!\n", strerror(errno));
+
+	return fd;
+}
+
+static char bpf_vlog[32768];
+
+static void do_test_fixup(struct bpf_test *test, struct bpf_insn *prog,
+			  int *fd_f1, int *fd_f2, int *fd_f3)
+{
+	int *fixup_map1 = test->fixup_map1;
+	int *fixup_map2 = test->fixup_map2;
+	int *fixup_prog = test->fixup_prog;
+
+	/* Allocating HTs with 1 elem is fine here, since we only test
+	 * for verifier and not do a runtime lookup, so the only thing
+	 * that really matters is value size in this case.
+	 */
+	if (*fixup_map1) {
+		*fd_f1 = create_map(sizeof(long long), 1);
+		do {
+			prog[*fixup_map1].imm = *fd_f1;
+			fixup_map1++;
+		} while (*fixup_map1);
+	}
+
+	if (*fixup_map2) {
+		*fd_f2 = create_map(sizeof(struct test_val), 1);
+		do {
+			prog[*fixup_map2].imm = *fd_f2;
+			fixup_map2++;
+		} while (*fixup_map2);
+	}
+
+	if (*fixup_prog) {
+		*fd_f3 = create_prog_array();
+		do {
+			prog[*fixup_prog].imm = *fd_f3;
+			fixup_prog++;
+		} while (*fixup_prog);
+	}
+}
+
+static void do_test_single(struct bpf_test *test, bool unpriv,
+			   int *passes, int *errors)
+{
+	struct bpf_insn *prog = test->insns;
+	int prog_len = probe_filter_length(prog);
+	int prog_type = test->prog_type;
+	int fd_f1 = -1, fd_f2 = -1, fd_f3 = -1;
+	int fd_prog, expected_ret;
+	const char *expected_err;
+
+	do_test_fixup(test, prog, &fd_f1, &fd_f2, &fd_f3);
+
+	fd_prog = bpf_prog_load(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
+				prog, prog_len * sizeof(struct bpf_insn),
+				"GPL", bpf_vlog, sizeof(bpf_vlog));
+
+	expected_ret = unpriv && test->result_unpriv != UNDEF ?
+		       test->result_unpriv : test->result;
+	expected_err = unpriv && test->errstr_unpriv ?
+		       test->errstr_unpriv : test->errstr;
+	if (expected_ret == ACCEPT) {
+		if (fd_prog < 0) {
+			printf("FAIL\nFailed to load prog '%s'!\n",
+			       strerror(errno));
+			goto fail_log;
+		}
+	} else {
+		if (fd_prog >= 0) {
+			printf("FAIL\nUnexpected success to load!\n");
+			goto fail_log;
+		}
+		if (!strstr(bpf_vlog, expected_err)) {
+			printf("FAIL\nUnexpected error message!\n");
+			goto fail_log;
+		}
+	}
+
+	(*passes)++;
+	printf("OK\n");
+close_fds:
+	close(fd_prog);
+	close(fd_f1);
+	close(fd_f2);
+	close(fd_f3);
+	sched_yield();
+	return;
+fail_log:
+	(*errors)++;
+	printf("%s", bpf_vlog);
+	goto close_fds;
+}
+
+static int do_test(bool unpriv, unsigned int from, unsigned int to)
+{
+	int i, passes = 0, errors = 0;
+
+	for (i = from; i < to; i++) {
+		struct bpf_test *test = &tests[i];
+
+		/* Program types that are not supported by non-root we
+		 * skip right away.
+		 */
+		if (unpriv && test->prog_type)
+			continue;
+
+		printf("#%d %s ", i, test->descr);
+		do_test_single(test, unpriv, &passes, &errors);
+	}
+
+	printf("Summary: %d PASSED, %d FAILED\n", passes, errors);
+	return errors ? -errors : 0;
+}
+
+int main(int argc, char **argv)
+{
+	struct rlimit rinf = { RLIM_INFINITY, RLIM_INFINITY };
+	struct rlimit rlim = { 1 << 20, 1 << 20 };
+	unsigned int from = 0, to = ARRAY_SIZE(tests);
+	bool unpriv = geteuid() != 0;
+
+	if (argc == 3) {
+		unsigned int l = atoi(argv[argc - 2]);
+		unsigned int u = atoi(argv[argc - 1]);
+
+		if (l < to && u < to) {
+			from = l;
+			to   = u + 1;
+		}
+	} else if (argc == 2) {
+		unsigned int t = atoi(argv[argc - 1]);
+
+		if (t < to) {
+			from = t;
+			to   = t + 1;
+		}
+	}
+
+	setrlimit(RLIMIT_MEMLOCK, unpriv ? &rlim : &rinf);
+	return do_test(unpriv, from, to);
+}
-- 
1.9.3
