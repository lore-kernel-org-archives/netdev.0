From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net 2/2] samples/bpf: add bpf_map_update_elem() tests
Date: Fri, 5 Aug 2016 14:01:28 -0700
Message-ID: <1470430888-2530070-2-git-send-email-ast@fb.com>
References: <1470430888-2530070-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, <netdev@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:8109 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1427129AbcHEVBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 17:01:31 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u75KufOO027860
	for <netdev@vger.kernel.org>; Fri, 5 Aug 2016 14:01:30 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 24n051rq2v-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 05 Aug 2016 14:01:30 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 c79454d05b4f11e6b3490002c992ebde-da3f7af0 for <netdev@vger.kernel.org>;	Fri,
 05 Aug 2016 14:01:29 -0700
In-Reply-To: <1470430888-2530070-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

increase test coverage to check previously missing 'update when full'

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 samples/bpf/test_maps.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/samples/bpf/test_maps.c b/samples/bpf/test_maps.c
index 47bf0858f9e4..cce2b59751eb 100644
--- a/samples/bpf/test_maps.c
+++ b/samples/bpf/test_maps.c
@@ -68,7 +68,16 @@ static void test_hashmap_sanity(int i, void *data)
 	assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == -1 &&
 	       errno == E2BIG);
 
+	/* update existing element, thought the map is full */
+	key = 1;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
+	key = 2;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+	key = 1;
+	assert(bpf_update_elem(map_fd, &key, &value, BPF_ANY) == 0);
+
 	/* check that key = 0 doesn't exist */
+	key = 0;
 	assert(bpf_delete_elem(map_fd, &key) == -1 && errno == ENOENT);
 
 	/* iterate over two elements */
@@ -413,10 +422,12 @@ static void do_work(int fn, void *data)
 
 	for (i = fn; i < MAP_SIZE; i += TASKS) {
 		key = value = i;
-		if (do_update)
+		if (do_update) {
 			assert(bpf_update_elem(map_fd, &key, &value, BPF_NOEXIST) == 0);
-		else
+			assert(bpf_update_elem(map_fd, &key, &value, BPF_EXIST) == 0);
+		} else {
 			assert(bpf_delete_elem(map_fd, &key) == 0);
+		}
 	}
 }
 
-- 
2.8.0
