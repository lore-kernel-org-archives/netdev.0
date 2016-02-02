From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 5/6] samples/bpf: unit test for BPF_MAP_TYPE_PERCPU_ARRAY
Date: Mon, 1 Feb 2016 22:39:57 -0800
Message-ID: <1454395198-1796236-6-git-send-email-ast@fb.com>
References: <1454395198-1796236-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Martin KaFai Lau <kafai@fb.com>, Ming Lei <tom.leiming@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	<netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12322 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752796AbcBBGkE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 01:40:04 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u126bEe0006992
	for <netdev@vger.kernel.org>; Mon, 1 Feb 2016 22:40:03 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbkket-6
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 22:40:03 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.223.100.99) with ESMTP	id
 c8663df2c97711e5811024be05956610-a9f62b0 for <netdev@vger.kernel.org>;	Mon,
 01 Feb 2016 22:40:00 -0800
In-Reply-To: <1454395198-1796236-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "tom.leiming@gmail.com" <tom.leiming@gmail.com>

A sanity test for BPF_MAP_TYPE_PERCPU_ARRAY

Signed-off-by: Ming Lei <tom.leiming@gmail.com>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_maps.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 92 insertions(+)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 5f5fe5332148..ad466ed33093 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -236,6 +236,94 @@ static void test_arraymap_sanity(int i, void *data)
 	close(map_fd);
 }
 
+static void test_percpu_arraymap_many_keys(void)
+{
+	unsigned nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	unsigned nr_keys = 20000;
+	long values[nr_cpus];
+	int key, map_fd, i;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+				sizeof(values[0]), nr_keys);
+	if (map_fd < 0) {
+		printf("failed to create per-cpu arraymap '%s'\n",
+		       strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		values[i] = i + 10;
+
+	for (key = 0; key < nr_keys; key++)
+		assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
+
+	for (key = 0; key < nr_keys; key++) {
+		for (i = 0; i < nr_cpus; i++)
+			values[i] = 0;
+		assert(bpf_lookup_elem(map_fd, &key, values) == 0);
+		for (i = 0; i < nr_cpus; i++)
+			assert(values[i] == i + 10);
+	}
+
+	close(map_fd);
+}
+
+static void test_percpu_arraymap_sanity(int i, void *data)
+{
+	unsigned nr_cpus = sysconf(_SC_NPROCESSORS_CONF);
+	long values[nr_cpus];
+	int key, next_key, map_fd;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
+				sizeof(values[0]), 2);
+	if (map_fd < 0) {
+		printf("failed to create arraymap '%s'\n", strerror(errno));
+		exit(1);
+	}
+
+	for (i = 0; i < nr_cpus; i++)
+		values[i] = i + 100;
+
+	key = 1;
+	/* insert key=1 element */
+	assert(bpf_update_elem(map_fd, &key, values, BPF_ANY) == 0);
+
+	values[0] = 0;
+	assert(bpf_update_elem(map_fd, &key, values, BPF_NOEXIST) == -1 &&
+	       errno == EEXIST);
+
+	/* check that key=1 can be found */
+	assert(bpf_lookup_elem(map_fd, &key, values) == 0 && values[0] == 100);
+
+	key = 0;
+	/* check that key=0 is also found and zero initialized */
+	assert(bpf_lookup_elem(map_fd, &key, values) == 0 &&
+	       values[0] == 0 && values[nr_cpus - 1] == 0);
+
+
+	/* check that key=2 cannot be inserted due to max_entries limit */
+	key = 2;
+	assert(bpf_update_elem(map_fd, &key, values, BPF_EXIST) == -1 &&
+	       errno == E2BIG);
+
+	/* check that key = 2 doesn't exist */
+	assert(bpf_lookup_elem(map_fd, &key, values) == -1 && errno == ENOENT);
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
@@ -305,6 +393,7 @@ static void test_map_stress(void)
 	run_parallel(100, test_hashmap_sanity, NULL);
 	run_parallel(100, test_percpu_hashmap_sanity, NULL);
 	run_parallel(100, test_arraymap_sanity, NULL);
+	run_parallel(100, test_percpu_arraymap_sanity, NULL);
 }
 
 #define TASKS 1024
@@ -379,6 +468,9 @@ int main(void)
 	test_hashmap_sanity(0, NULL);
 	test_percpu_hashmap_sanity(0, NULL);
 	test_arraymap_sanity(0, NULL);
+	test_percpu_arraymap_sanity(0, NULL);
+	test_percpu_arraymap_many_keys();
+
 	test_map_large();
 	test_map_parallel();
 	test_map_stress();
-- 
2.4.6
