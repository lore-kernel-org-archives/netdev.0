From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 2/5] bpf: Add map_name to bpf_map_info
Date: Wed, 27 Sep 2017 14:37:53 -0700
Message-ID: <20170927213756.1254938-3-kafai@fb.com>
References: <20170927213756.1254938-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:50532 "EHLO
        mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751969AbdI0Vh7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:37:59 -0400
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RLbmLA029142
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:58 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d8fsu9hbp-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:58 -0700
In-Reply-To: <20170927213756.1254938-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows userspace to specify a name for a map
during BPF_MAP_CREATE.

The map's name can later be exported to user space
via BPF_OBJ_GET_INFO_BY_FD.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      | 1 +
 include/uapi/linux/bpf.h | 2 ++
 kernel/bpf/syscall.c     | 7 ++++++-
 3 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 33ccc474fb04..252f4bc9eb25 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -56,6 +56,7 @@ struct bpf_map {
 	struct work_struct work;
 	atomic_t usercnt;
 	struct bpf_map *inner_map_meta;
+	u8 name[BPF_OBJ_NAME_LEN];
 };
 
 /* function argument constraints */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index bd6348269bf5..6d2137b4cf38 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -190,6 +190,7 @@ union bpf_attr {
 		__u32	numa_node;	/* numa node (effective only if
 					 * BPF_F_NUMA_NODE is set).
 					 */
+		__u8	map_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_MAP_*_ELEM commands */
@@ -829,6 +830,7 @@ struct bpf_map_info {
 	__u32 value_size;
 	__u32 max_entries;
 	__u32 map_flags;
+	__u8  name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 /* User bpf_sock_ops struct to access socket values and specify request ops
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 45970df3f820..11a7f82a55d1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -339,7 +339,7 @@ static int bpf_obj_name_cpy(char *dst, const char *src)
 	return 0;
 }
 
-#define BPF_MAP_CREATE_LAST_FIELD numa_node
+#define BPF_MAP_CREATE_LAST_FIELD map_name
 /* called via syscall */
 static int map_create(union bpf_attr *attr)
 {
@@ -361,6 +361,10 @@ static int map_create(union bpf_attr *attr)
 	if (IS_ERR(map))
 		return PTR_ERR(map);
 
+	err = bpf_obj_name_cpy(map->name, attr->map_name);
+	if (err)
+		goto free_map_nouncharge;
+
 	atomic_set(&map->refcnt, 1);
 	atomic_set(&map->usercnt, 1);
 
@@ -1462,6 +1466,7 @@ static int bpf_map_get_info_by_fd(struct bpf_map *map,
 	info.value_size = map->value_size;
 	info.max_entries = map->max_entries;
 	info.map_flags = map->map_flags;
+	memcpy(info.name, map->name, sizeof(map->name));
 
 	if (copy_to_user(uinfo, &info, info_len) ||
 	    put_user(info_len, &uattr->info.info_len))
-- 
2.9.5
