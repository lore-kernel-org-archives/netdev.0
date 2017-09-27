From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 1/5] bpf: Add name, load_time, uid and map_ids to bpf_prog_info
Date: Wed, 27 Sep 2017 14:37:52 -0700
Message-ID: <20170927213756.1254938-2-kafai@fb.com>
References: <20170927213756.1254938-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:60038 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751958AbdI0Vh6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:37:58 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8RLYShh015871
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2d8jaggmau-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:37:57 -0700
In-Reply-To: <20170927213756.1254938-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds name and load_time to struct bpf_prog_aux.  They
are also exported to bpf_prog_info.

The bpf_prog's name is passed by userspace during BPF_PROG_LOAD.
The kernel only stores the first (BPF_PROG_NAME_LEN - 1) bytes
and the name stored in the kernel is always \0 terminated.

The kernel will reject name that contains characters other than
isalnum() and '_'.  It will also reject name that is not null
terminated.

The existing 'user->uid' of the bpf_prog_aux is also exported to
the bpf_prog_info as created_by_uid.

The existing 'used_maps' of the bpf_prog_aux is exported to
the newly added members 'nr_map_ids' and 'map_ids' of
the bpf_prog_info.  On the input, nr_map_ids tells how
big the userspace's map_ids buffer is.  On the output,
nr_map_ids tells the exact user_map_cnt and it will only
copy up to the userspace's map_ids buffer is allowed.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |  2 ++
 include/uapi/linux/bpf.h |  8 ++++++++
 kernel/bpf/syscall.c     | 51 +++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 2b672c50f160..33ccc474fb04 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -187,6 +187,8 @@ struct bpf_prog_aux {
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
 	struct user_struct *user;
+	u64 load_time; /* ns since boottime */
+	u8 name[BPF_OBJ_NAME_LEN];
 	union {
 		struct work_struct work;
 		struct rcu_head	rcu;
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e43491ac4823..bd6348269bf5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -175,6 +175,8 @@ enum bpf_attach_type {
 /* Specify numa node during map creation */
 #define BPF_F_NUMA_NODE		(1U << 2)
 
+#define BPF_OBJ_NAME_LEN 16U
+
 union bpf_attr {
 	struct { /* anonymous struct used by BPF_MAP_CREATE command */
 		__u32	map_type;	/* one of enum bpf_map_type */
@@ -210,6 +212,7 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 		__u32		prog_flags;
+		__u8		prog_name[BPF_OBJ_NAME_LEN];
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -812,6 +815,11 @@ struct bpf_prog_info {
 	__u32 xlated_prog_len;
 	__aligned_u64 jited_prog_insns;
 	__aligned_u64 xlated_prog_insns;
+	__u64 load_time;	/* ns since boottime */
+	__u32 created_by_uid;
+	__u32 nr_map_ids;
+	__aligned_u64 map_ids;
+	__u8  name[BPF_OBJ_NAME_LEN];
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 25d074920a00..45970df3f820 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -23,6 +23,9 @@
 #include <linux/version.h>
 #include <linux/kernel.h>
 #include <linux/idr.h>
+#include <linux/cred.h>
+#include <linux/timekeeping.h>
+#include <linux/ctype.h>
 
 #define IS_FD_ARRAY(map) ((map)->map_type == BPF_MAP_TYPE_PROG_ARRAY || \
 			   (map)->map_type == BPF_MAP_TYPE_PERF_EVENT_ARRAY || \
@@ -312,6 +315,30 @@ int bpf_map_new_fd(struct bpf_map *map)
 		   offsetof(union bpf_attr, CMD##_LAST_FIELD) - \
 		   sizeof(attr->CMD##_LAST_FIELD)) != NULL
 
+/* dst and src must have at least BPF_OBJ_NAME_LEN number of bytes.
+ * Return 0 on success and < 0 on error.
+ */
+static int bpf_obj_name_cpy(char *dst, const char *src)
+{
+	const char *end = src + BPF_OBJ_NAME_LEN;
+
+	/* Copy all isalnum() and '_' char */
+	while (src < end && *src) {
+		if (!isalnum(*src) && *src != '_')
+			return -EINVAL;
+		*dst++ = *src++;
+	}
+
+	/* No '\0' found in BPF_OBJ_NAME_LEN number of bytes */
+	if (src == end)
+		return -EINVAL;
+
+	/* '\0' terminates dst */
+	*dst = 0;
+
+	return 0;
+}
+
 #define BPF_MAP_CREATE_LAST_FIELD numa_node
 /* called via syscall */
 static int map_create(union bpf_attr *attr)
@@ -973,7 +1000,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD prog_flags
+#define	BPF_PROG_LOAD_LAST_FIELD prog_name
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -1037,6 +1064,11 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_prog;
 
+	prog->aux->load_time = ktime_get_boot_ns();
+	err = bpf_obj_name_cpy(prog->aux->name, attr->prog_name);
+	if (err)
+		goto free_prog;
+
 	/* run eBPF verifier */
 	err = bpf_check(&prog, attr);
 	if (err < 0)
@@ -1358,8 +1390,25 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 
 	info.type = prog->type;
 	info.id = prog->aux->id;
+	info.load_time = prog->aux->load_time;
+	info.created_by_uid = from_kuid_munged(current_user_ns(),
+					       prog->aux->user->uid);
 
 	memcpy(info.tag, prog->tag, sizeof(prog->tag));
+	memcpy(info.name, prog->aux->name, sizeof(prog->aux->name));
+
+	ulen = info.nr_map_ids;
+	info.nr_map_ids = prog->aux->used_map_cnt;
+	ulen = min_t(u32, info.nr_map_ids, ulen);
+	if (ulen) {
+		u32 *user_map_ids = (u32 *)info.map_ids;
+		u32 i;
+
+		for (i = 0; i < ulen; i++)
+			if (put_user(prog->aux->used_maps[i]->id,
+				     &user_map_ids[i]))
+				return -EFAULT;
+	}
 
 	if (!capable(CAP_SYS_ADMIN)) {
 		info.jited_prog_len = 0;
-- 
2.9.5
