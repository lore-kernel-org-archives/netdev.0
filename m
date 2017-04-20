From: David Miller <davem@davemloft.net>
Subject: [PATCH] Fix values type used in test_maps
Date: Thu, 20 Apr 2017 15:20:16 -0400 (EDT)
Message-ID: <20170420.152016.2219427430519868937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: borkmann@iogearbox.net, netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47710 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946967AbdDTTUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Maps of per-cpu type have their value element size adjusted to 8 if it
is specified smaller during various map operations.

This makes test_maps as a 32-bit binary fail, in fact the kernel
writes past the end of the value's array on the user's stack.

To be quite honest, I think the kernel should reject creation of a
per-cpu map that doesn't have a value size of at least 8 if that's
what the kernel is going to silently adjust to later.

If the user passed something smaller, it is a sizeof() calcualtion
based upon the type they will actually use (just like in this testcase
code) in later calls to the map operations.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/tools/testing/selftests/bpf/test_maps.c b/tools/testing/selftests/bpf/test_maps.c
index a0aa200..20f1871 100644
--- a/tools/testing/selftests/bpf/test_maps.c
+++ b/tools/testing/selftests/bpf/test_maps.c
@@ -282,7 +282,7 @@ static void test_arraymap_percpu(int task, void *data)
 {
 	unsigned int nr_cpus = bpf_num_possible_cpus();
 	int key, next_key, fd, i;
-	long values[nr_cpus];
+	long long values[nr_cpus];
 
 	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
 			    sizeof(values[0]), 2, 0);
@@ -340,7 +340,7 @@ static void test_arraymap_percpu_many_keys(void)
 	 * allocator more than anything else
 	 */
 	unsigned int nr_keys = 2000;
-	long values[nr_cpus];
+	long long values[nr_cpus];
 	int key, fd, i;
 
 	fd = bpf_create_map(BPF_MAP_TYPE_PERCPU_ARRAY, sizeof(key),
