From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 4/5] bpf: Swap the order of checking prog_info and map_info
Date: Wed, 27 Sep 2017 14:37:55 -0700
Message-ID: <20170927213756.1254938-5-kafai@fb.com>
References: <20170927213756.1254938-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:35862 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751964AbdI0Vh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:37:58 -0400
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RLbXPL005908
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d8g23sn7j-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
In-Reply-To: <20170927213756.1254938-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch swaps the checking order.  It now checks the map_info
first and then prog_info.  It is a prep work for adding
test to the newly added fields (the map_ids of prog_info field
in particular).

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tools/testing/selftests/bpf/test_progs.c | 58 +++++++++++++++++---------------
 1 file changed, 30 insertions(+), 28 deletions(-)

diff --git a/tools/testing/selftests/bpf/test_progs.c b/tools/testing/selftests/bpf/test_progs.c
index 11ee25cea227..31ae27dc8d04 100644
--- a/tools/testing/selftests/bpf/test_progs.c
+++ b/tools/testing/selftests/bpf/test_progs.c
@@ -316,6 +316,36 @@ static void test_bpf_obj_id(void)
 			error_cnt++;
 		assert(!err);
 
+		/* Insert a magic value to the map */
+		map_fds[i] = bpf_find_map(__func__, objs[i], "test_map_id");
+		assert(map_fds[i] >= 0);
+		err = bpf_map_update_elem(map_fds[i], &array_key,
+					  &array_magic_value, 0);
+		assert(!err);
+
+		/* Check getting map info */
+		info_len = sizeof(struct bpf_map_info) * 2;
+		bzero(&map_infos[i], info_len);
+		err = bpf_obj_get_info_by_fd(map_fds[i], &map_infos[i],
+					     &info_len);
+		if (CHECK(err ||
+			  map_infos[i].type != BPF_MAP_TYPE_ARRAY ||
+			  map_infos[i].key_size != sizeof(__u32) ||
+			  map_infos[i].value_size != sizeof(__u64) ||
+			  map_infos[i].max_entries != 1 ||
+			  map_infos[i].map_flags != 0 ||
+			  info_len != sizeof(struct bpf_map_info),
+			  "get-map-info(fd)",
+			  "err %d errno %d type %d(%d) info_len %u(%lu) key_size %u value_size %u max_entries %u map_flags %X\n",
+			  err, errno,
+			  map_infos[i].type, BPF_MAP_TYPE_ARRAY,
+			  info_len, sizeof(struct bpf_map_info),
+			  map_infos[i].key_size,
+			  map_infos[i].value_size,
+			  map_infos[i].max_entries,
+			  map_infos[i].map_flags))
+			goto done;
+
 		/* Check getting prog info */
 		info_len = sizeof(struct bpf_prog_info) * 2;
 		bzero(&prog_infos[i], info_len);
@@ -347,34 +377,6 @@ static void test_bpf_obj_id(void)
 			  !!memcmp(xlated_insns, zeros, sizeof(zeros))))
 			goto done;
 
-		map_fds[i] = bpf_find_map(__func__, objs[i], "test_map_id");
-		assert(map_fds[i] >= 0);
-		err = bpf_map_update_elem(map_fds[i], &array_key,
-					  &array_magic_value, 0);
-		assert(!err);
-
-		/* Check getting map info */
-		info_len = sizeof(struct bpf_map_info) * 2;
-		bzero(&map_infos[i], info_len);
-		err = bpf_obj_get_info_by_fd(map_fds[i], &map_infos[i],
-					     &info_len);
-		if (CHECK(err ||
-			  map_infos[i].type != BPF_MAP_TYPE_ARRAY ||
-			  map_infos[i].key_size != sizeof(__u32) ||
-			  map_infos[i].value_size != sizeof(__u64) ||
-			  map_infos[i].max_entries != 1 ||
-			  map_infos[i].map_flags != 0 ||
-			  info_len != sizeof(struct bpf_map_info),
-			  "get-map-info(fd)",
-			  "err %d errno %d type %d(%d) info_len %u(%lu) key_size %u value_size %u max_entries %u map_flags %X\n",
-			  err, errno,
-			  map_infos[i].type, BPF_MAP_TYPE_ARRAY,
-			  info_len, sizeof(struct bpf_map_info),
-			  map_infos[i].key_size,
-			  map_infos[i].value_size,
-			  map_infos[i].max_entries,
-			  map_infos[i].map_flags))
-			goto done;
 	}
 
 	/* Check bpf_prog_get_next_id() */
-- 
2.9.5
