From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 7/8] bpf: Add BPF_OBJ_GET_INFO_BY_FD
Date: Wed, 31 May 2017 11:59:01 -0700
Message-ID: <13c2c5f14deac12c466da45f78b151a5e855844a.1496256722.git.kafai@fb.com>
References: <cover.1496256722.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:52551 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751009AbdEaS7F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:59:05 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.20/8.16.0.20) with SMTP id v4VIwNFw007200
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:59:04 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2asydh8xb3-3
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 11:59:04 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 36b87282463311e78d710002c9931860-da1328f0 for <netdev@vger.kernel.org>;        Wed,
 31 May 2017 11:59:03 -0700
In-Reply-To: <cover.1496256722.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A single BPF_OBJ_GET_INFO_BY_FD cmd is used to obtain the info
for both bpf_prog and bpf_map.  The kernel can figure out the
fd is associated with a bpf_prog or bpf_map.

The suggested struct bpf_prog_info and struct bpf_map_info are
not meant to be a complete list and it is not the goal of this patch.
New fields can be added in the future patch.

The focus of this patch is to create the interface,
BPF_OBJ_GET_INFO_BY_FD cmd for exposing the bpf_prog's and
bpf_map's info.

The obj's info, which will be extended (and get bigger) over time, is
separated from the bpf_attr to avoid bloating the bpf_attr.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h   |   2 -
 include/uapi/linux/bpf.h |  28 ++++++++
 kernel/bpf/syscall.c     | 163 ++++++++++++++++++++++++++++++++++++++++++-----
 3 files changed, 174 insertions(+), 19 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index a322a41f394b..46274f23f127 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -66,8 +66,6 @@ struct bpf_prog_aux;
 /* BPF program can access up to 512 bytes of stack space. */
 #define MAX_BPF_STACK	512
 
-#define BPF_TAG_SIZE	8
-
 /* Helper macros for filter block array initializers. */
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index cf704e8b6e65..677b570da8ec 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -86,6 +86,7 @@ enum bpf_cmd {
 	BPF_MAP_GET_NEXT_ID,
 	BPF_PROG_GET_FD_BY_ID,
 	BPF_MAP_GET_FD_BY_ID,
+	BPF_OBJ_GET_INFO_BY_FD,
 };
 
 enum bpf_map_type {
@@ -222,6 +223,12 @@ union bpf_attr {
 		};
 		__u32		next_id;
 	};
+
+	struct { /* anonymous struct used by BPF_OBJ_GET_INFO_BY_FD */
+		__u32		bpf_fd;
+		__u32		info_len;
+		__aligned_u64	info;
+	} info;
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
@@ -683,4 +690,25 @@ struct xdp_md {
 	__u32 data_end;
 };
 
+#define BPF_TAG_SIZE	8
+
+struct bpf_prog_info {
+	__u32 type;
+	__u32 id;
+	__u8  tag[BPF_TAG_SIZE];
+	__u32 jited_prog_len;
+	__u32 xlated_prog_len;
+	__aligned_u64 jited_prog_insns;
+	__aligned_u64 xlated_prog_insns;
+} __attribute__((aligned(8)));
+
+struct bpf_map_info {
+	__u32 type;
+	__u32 id;
+	__u32 key_size;
+	__u32 value_size;
+	__u32 max_entries;
+	__u32 map_flags;
+} __attribute__((aligned(8)));
+
 #endif /* _UAPI__LINUX_BPF_H__ */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index de8fe04a6539..aeca61a84ed1 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1237,6 +1237,145 @@ static int bpf_map_get_fd_by_id(const union bpf_attr *attr)
 	return fd;
 }
 
+static int check_uarg_tail_zero(void __user *uaddr,
+				size_t expected_size,
+				size_t actual_size)
+{
+	unsigned char __user *addr;
+	unsigned char __user *end;
+	unsigned char val;
+	int err;
+
+	if (actual_size <= expected_size)
+		return 0;
+
+	addr = uaddr + expected_size;
+	end  = uaddr + actual_size;
+
+	for (; addr < end; addr++) {
+		err = get_user(val, addr);
+		if (err)
+			return err;
+		if (val)
+			return -E2BIG;
+	}
+
+	return 0;
+}
+
+static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
+				   const union bpf_attr *attr,
+				   union bpf_attr __user *uattr)
+{
+	struct bpf_prog_info __user *uinfo = u64_to_user_ptr(attr->info.info);
+	struct bpf_prog_info info = {};
+	u32 info_len = attr->info.info_len;
+	char __user *uinsns;
+	u32 ulen;
+	int err;
+
+	err = check_uarg_tail_zero(uinfo, sizeof(info), info_len);
+	if (err)
+		return err;
+	info_len = min_t(u32, sizeof(info), info_len);
+
+	if (copy_from_user(&info, uinfo, info_len))
+		return err;
+
+	info.type = prog->type;
+	info.id = prog->aux->id;
+
+	memcpy(info.tag, prog->tag, sizeof(prog->tag));
+
+	if (!capable(CAP_SYS_ADMIN)) {
+		info.jited_prog_len = 0;
+		info.xlated_prog_len = 0;
+		goto done;
+	}
+
+	ulen = info.jited_prog_len;
+	info.jited_prog_len = prog->jited_len;
+	if (info.jited_prog_len && ulen) {
+		uinsns = u64_to_user_ptr(info.jited_prog_insns);
+		ulen = min_t(u32, info.jited_prog_len, ulen);
+		if (copy_to_user(uinsns, prog->bpf_func, ulen))
+			return -EFAULT;
+	}
+
+	ulen = info.xlated_prog_len;
+	info.xlated_prog_len = bpf_prog_size(prog->len);
+	if (info.xlated_prog_len && ulen) {
+		uinsns = u64_to_user_ptr(info.xlated_prog_insns);
+		ulen = min_t(u32, info.xlated_prog_len, ulen);
+		if (copy_to_user(uinsns, prog->insnsi, ulen))
+			return -EFAULT;
+	}
+
+done:
+	if (copy_to_user(uinfo, &info, info_len) ||
+	    put_user(info_len, &uattr->info.info_len))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int bpf_map_get_info_by_fd(struct bpf_map *map,
+				  const union bpf_attr *attr,
+				  union bpf_attr __user *uattr)
+{
+	struct bpf_map_info __user *uinfo = u64_to_user_ptr(attr->info.info);
+	struct bpf_map_info info = {};
+	u32 info_len = attr->info.info_len;
+	int err;
+
+	err = check_uarg_tail_zero(uinfo, sizeof(info), info_len);
+	if (err)
+		return err;
+	info_len = min_t(u32, sizeof(info), info_len);
+
+	info.type = map->map_type;
+	info.id = map->id;
+	info.key_size = map->key_size;
+	info.value_size = map->value_size;
+	info.max_entries = map->max_entries;
+	info.map_flags = map->map_flags;
+
+	if (copy_to_user(uinfo, &info, info_len) ||
+	    put_user(info_len, &uattr->info.info_len))
+		return -EFAULT;
+
+	return 0;
+}
+
+#define BPF_OBJ_GET_INFO_BY_FD_LAST_FIELD info.info
+
+static int bpf_obj_get_info_by_fd(const union bpf_attr *attr,
+				  union bpf_attr __user *uattr)
+{
+	int ufd = attr->info.bpf_fd;
+	struct fd f;
+	int err;
+
+	if (CHECK_ATTR(BPF_OBJ_GET_INFO_BY_FD))
+		return -EINVAL;
+
+	f = fdget(ufd);
+	if (!f.file)
+		return -EBADFD;
+
+	if (f.file->f_op == &bpf_prog_fops)
+		err = bpf_prog_get_info_by_fd(f.file->private_data, attr,
+					      uattr);
+	else if (f.file->f_op == &bpf_map_fops)
+		err = bpf_map_get_info_by_fd(f.file->private_data, attr,
+					     uattr);
+	else
+		err = -EINVAL;
+
+	fdput(f);
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -1256,23 +1395,10 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	 * user-space does not rely on any kernel feature
 	 * extensions we dont know about yet.
 	 */
-	if (size > sizeof(attr)) {
-		unsigned char __user *addr;
-		unsigned char __user *end;
-		unsigned char val;
-
-		addr = (void __user *)uattr + sizeof(attr);
-		end  = (void __user *)uattr + size;
-
-		for (; addr < end; addr++) {
-			err = get_user(val, addr);
-			if (err)
-				return err;
-			if (val)
-				return -E2BIG;
-		}
-		size = sizeof(attr);
-	}
+	err = check_uarg_tail_zero(uattr, sizeof(attr), size);
+	if (err)
+		return err;
+	size = min_t(u32, size, sizeof(attr));
 
 	/* copy attributes from user space, may be less than sizeof(bpf_attr) */
 	if (copy_from_user(&attr, uattr, size) != 0)
@@ -1328,6 +1454,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_MAP_GET_FD_BY_ID:
 		err = bpf_map_get_fd_by_id(&attr);
 		break;
+	case BPF_OBJ_GET_INFO_BY_FD:
+		err = bpf_obj_get_info_by_fd(&attr, uattr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.9.3
