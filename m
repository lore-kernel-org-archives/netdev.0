From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH] bpf: Fix test_lru_sanity5() in test_lru_map.c
Date: Mon, 16 Jan 2017 22:17:29 -0800
Message-ID: <1484633849-2742833-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:37299 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750741AbdAQGRj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 01:17:39 -0500
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0H6EiT9022762
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 22:17:39 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2811ep9hgr-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 16 Jan 2017 22:17:38 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.223.100.97) with ESMTP id
 a007b5d4dc7c11e6aaae24be0593f280-2a0d9a50 for <netdev@vger.kernel.org>;        Mon,
 16 Jan 2017 22:17:30 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_lru_sanity5() fails when the number of online cpus
is fewer than the number of possible cpus.  It can be
reproduced with qemu by using cmd args "--smp cpus=2,maxcpus=8".

The problem is the loop in test_lru_sanity5() is testing
'i' which is incorrect.

This patch:
1. Make sched_next_online() always return -1 if it cannot
   find a next cpu to schedule the process.
2. In test_lru_sanity5(), the parent process does
   sched_setaffinity() first (through sched_next_online())
   and the forked process will inherit it according to
   the 'man sched_setaffinity'.

Fixes: 5db58faf989f ("bpf: Add tests for the LRU bpf_htab")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 tools/testing/selftests/bpf/test_lru_map.c | 53 +++++++++++++++---------------
 1 file changed, 27 insertions(+), 26 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_lru_map.c b/tools/testing/selftests/bpf/test_lru_map.c
index b13fed534d76..9f7bd1915c21 100644
--- a/tools/testing/selftests/bpf/test_lru_map.c
+++ b/tools/testing/selftests/bpf/test_lru_map.c
@@ -67,21 +67,23 @@ static int map_equal(int lru_map, int expected)
 	return map_subset(lru_map, expected) && map_subset(expected, lru_map);
 }
 
-static int sched_next_online(int pid, int next_to_try)
+static int sched_next_online(int pid, int *next_to_try)
 {
 	cpu_set_t cpuset;
+	int next = *next_to_try;
+	int ret = -1;
 
-	if (next_to_try == nr_cpus)
-		return -1;
-
-	while (next_to_try < nr_cpus) {
+	while (next < nr_cpus) {
 		CPU_ZERO(&cpuset);
-		CPU_SET(next_to_try++, &cpuset);
-		if (!sched_setaffinity(pid, sizeof(cpuset), &cpuset))
+		CPU_SET(next++, &cpuset);
+		if (!sched_setaffinity(pid, sizeof(cpuset), &cpuset)) {
+			ret = 0;
 			break;
+		}
 	}
 
-	return next_to_try;
+	*next_to_try = next;
+	return ret;
 }
 
 /* Size of the LRU amp is 2
@@ -96,11 +98,12 @@ static void test_lru_sanity0(int map_type, int map_flags)
 {
 	unsigned long long key, value[nr_cpus];
 	int lru_map_fd, expected_map_fd;
+	int next_cpu = 0;
 
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
-	assert(sched_next_online(0, 0) != -1);
+	assert(sched_next_online(0, &next_cpu) != -1);
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
 		lru_map_fd = create_map(map_type, map_flags, 2 * nr_cpus);
@@ -183,6 +186,7 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	int lru_map_fd, expected_map_fd;
 	unsigned int batch_size;
 	unsigned int map_size;
+	int next_cpu = 0;
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
 		/* Ther percpu lru list (i.e each cpu has its own LRU
@@ -196,7 +200,7 @@ static void test_lru_sanity1(int map_type, int map_flags, unsigned int tgt_free)
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
-	assert(sched_next_online(0, 0) != -1);
+	assert(sched_next_online(0, &next_cpu) != -1);
 
 	batch_size = tgt_free / 2;
 	assert(batch_size * 2 == tgt_free);
@@ -262,6 +266,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	int lru_map_fd, expected_map_fd;
 	unsigned int batch_size;
 	unsigned int map_size;
+	int next_cpu = 0;
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
 		/* Ther percpu lru list (i.e each cpu has its own LRU
@@ -275,7 +280,7 @@ static void test_lru_sanity2(int map_type, int map_flags, unsigned int tgt_free)
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
-	assert(sched_next_online(0, 0) != -1);
+	assert(sched_next_online(0, &next_cpu) != -1);
 
 	batch_size = tgt_free / 2;
 	assert(batch_size * 2 == tgt_free);
@@ -370,11 +375,12 @@ static void test_lru_sanity3(int map_type, int map_flags, unsigned int tgt_free)
 	int lru_map_fd, expected_map_fd;
 	unsigned int batch_size;
 	unsigned int map_size;
+	int next_cpu = 0;
 
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
-	assert(sched_next_online(0, 0) != -1);
+	assert(sched_next_online(0, &next_cpu) != -1);
 
 	batch_size = tgt_free / 2;
 	assert(batch_size * 2 == tgt_free);
@@ -430,11 +436,12 @@ static void test_lru_sanity4(int map_type, int map_flags, unsigned int tgt_free)
 	int lru_map_fd, expected_map_fd;
 	unsigned long long key, value[nr_cpus];
 	unsigned long long end_key;
+	int next_cpu = 0;
 
 	printf("%s (map_type:%d map_flags:0x%X): ", __func__, map_type,
 	       map_flags);
 
-	assert(sched_next_online(0, 0) != -1);
+	assert(sched_next_online(0, &next_cpu) != -1);
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
 		lru_map_fd = create_map(map_type, map_flags,
@@ -502,9 +509,8 @@ static void do_test_lru_sanity5(unsigned long long last_key, int map_fd)
 static void test_lru_sanity5(int map_type, int map_flags)
 {
 	unsigned long long key, value[nr_cpus];
-	int next_sched_cpu = 0;
+	int next_cpu = 0;
 	int map_fd;
-	int i;
 
 	if (map_flags & BPF_F_NO_COMMON_LRU)
 		return;
@@ -519,27 +525,20 @@ static void test_lru_sanity5(int map_type, int map_flags)
 	key = 0;
 	assert(!bpf_map_update(map_fd, &key, value, BPF_NOEXIST));
 
-	for (i = 0; i < nr_cpus; i++) {
+	while (sched_next_online(0, &next_cpu) != -1) {
 		pid_t pid;
 
 		pid = fork();
 		if (pid == 0) {
-			next_sched_cpu = sched_next_online(0, next_sched_cpu);
-			if (next_sched_cpu != -1)
-				do_test_lru_sanity5(key, map_fd);
+			do_test_lru_sanity5(key, map_fd);
 			exit(0);
 		} else if (pid == -1) {
-			printf("couldn't spawn #%d process\n", i);
+			printf("couldn't spawn process to test key:%llu\n",
+			       key);
 			exit(1);
 		} else {
 			int status;
 
-			/* It is mostly redundant and just allow the parent
-			 * process to update next_shced_cpu for the next child
-			 * process
-			 */
-			next_sched_cpu = sched_next_online(pid, next_sched_cpu);
-
 			assert(waitpid(pid, &status, 0) == pid);
 			assert(status == 0);
 			key++;
@@ -547,6 +546,8 @@ static void test_lru_sanity5(int map_type, int map_flags)
 	}
 
 	close(map_fd);
+	/* At least one key should be tested */
+	assert(key > 0);
 
 	printf("Pass\n");
 }
-- 
2.5.1
