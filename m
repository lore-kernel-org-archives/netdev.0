From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/6] samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_HASH
Date: Mon, 1 Feb 2016 22:39:56 -0800
Message-ID: <1454395198-1796236-5-git-send-email-ast@fb.com>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:38621 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752325AbcBBGkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:03 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126bEdw006992
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:02 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbkket-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:02 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 c81e373cc97711e595f924be0593f280-8edfb2b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:40:00 -0800
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>

A sanity test for BPF_MAP_TYPE_PERCPU_HASH.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_maps.c | 96 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 96 insertions(+)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 6299ee95cd11..5f5fe5332148 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -89,6 +89,100 @@ static void test_hashmap_sanity(int i, void *data)
 	close(map_fd);
 }
 
+/* sanity tests for percpu map API */
+static void test_percpu_hashmap_sanity(int task, void *data)
+{
+	long long key, next_key;
+	int expected_key_mask = 0;
+	unsigned int nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	long long value[nr_cpus];
+	int map_fd, i;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_HASH, sizeof(key),
+				sizeof(value[0]), 2);
+	if (map_fd < 0) {
+		printf("failed to create hashmap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		value[i] = i + 100;
+	key = 1;
+	/* insert key=1 element */
+	assert(!(expected_key_mask & key));
+	assert(bpf_update_elem(map_fd, &key, value, BPF_ANY) == 0);
+	expected_key_mask |= key;
+
+	/* BPF_NOEXIST means: add new element if it doesn't exist */
+	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
+	       /* key=1 already exists */
+	       errno == EEXIST);
+
+	/* -1 is an invalid flag */
+	assert(bpf_update_elem(map_fd, &key, value, -1) == -1 &&
+	       errno == EINVAL);
+
+	/* check that key=1 can be found. value could be 0 if the lookup
+	 * was run from a different cpu.
+	 */
+	value[0] = 1;
+	assert(bpf_lookup_elem(map_fd, &key, value) == 0 && value[0] == 100);
+
+	key = 2;
+	/* check that key=2 is not found */
+	assert(bpf_lookup_elem(map_fd, &key, value) == -1 && errno == ENOENT);
+
+	/* BPF_EXIST means: update existing element */
+	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == -1 &&
+	       /* key=2 is not there */
+	       errno == ENOENT);
+
+	/* insert key=2 element */
+	assert(!(expected_key_mask & key));
+	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
+	expected_key_mask |= key;
+
+	/* key=1 and key=2 were inserted, check that key=0 cannot be inserted
+	 * due to max_entries limit
+	 */
+	key = 0;
+	assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* check that key = 0 doesn't exist */
+	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
+
+	/* iterate over two elements */
+	while (!bpf_get_next_key(map_fd, &key, &next_key)) {
+		assert((expected_key_mask & next_key) == next_key);
+		expected_key_mask &= ~next_key;
+
+		assert(bpf_lookup_elem(map_fd, &next_key, value) == 0);
+		for (i = 0; i < nr_cpus; i++)
+			assert(value[i] == i + 100);
+
+		key = next_key;
+	}
+	assert(errno == ENOENT);
+
+	/* Update with BPF_EXIST */
+	key = 1;
+	assert(bpf_update_elem(map_fd, &key, value, BPF_EXIST) == 0);
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
@@ -209,6 +303,7 @@ static void run_parallel(int tasks, void (*fn)(int i, void *data), void *data)
 static void test_map_stress(void)
 {
 	run_parallel(100, test_hashmap_sanity, NULL);
+	run_parallel(100, test_percpu_hashmap_sanity, NULL);
 	run_parallel(100, test_arraymap_sanity, NULL);
 }
 
@@ -282,6 +377,7 @@ static void test_map_parallel(void)
 int main(void)
 {
 	test_hashmap_sanity(0, NULL);
+	test_percpu_hashmap_sanity(0, NULL);
 	test_arraymap_sanity(0, NULL);
 	test_map_large();
 	test_map_parallel();
-- 
2.4.6
