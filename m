From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH net-next 3/8] bpf: Add BPF_(PROG|MAP)_GET_NEXT_ID command
Date: Tue, 30 May 2017 17:08:32 -0700
Message-ID: <ddb98852e108acfef4743f698812bc6faaa6a765.1496189155.git.kafai@fb.com>
References: <cover.1496189155.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46032 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750913AbdEaAIk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 20:08:40 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4V04xS7024700
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:08:39 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2asgt2gd6g-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 30 May 2017 17:08:39 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 4bc6ab6a459511e7b5020002c992ebde-9398f0 for <netdev@vger.kernel.org>;  Tue, 30
 May 2017 17:08:38 -0700
In-Reply-To: <cover.1496189155.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds BPF_PROG_GET_NEXT_ID and BPF_MAP_GET_NEXT_ID
to allow userspace to iterate all bpf_prog IDs and bpf_map IDs.

The API is trying to be consistent with the existing
BPF_MAP_GET_NEXT_KEY.

It is currently limited to CAP_SYS_ADMIN which we can
consider to lift it in followup patches.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h |  7 +++++++
 kernel/bpf/syscall.c     | 38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 94dfa9def355..e5c88f39bdc3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -82,6 +82,8 @@ enum bpf_cmd {
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
 	BPF_PROG_TEST_RUN,
+	BPF_PROG_GET_NEXT_ID,
+	BPF_MAP_GET_NEXT_ID,
 };
 
 enum bpf_map_type {
@@ -209,6 +211,11 @@ union bpf_attr {
 		__u32		repeat;
 		__u32		duration;
 	} test;
+
+	struct { /* anonymous struct used by BPF_*_GET_NEXT_ID */
+		__u32		start_id;
+		__u32		next_id;
+	};
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index a6fe034dbc09..34dc92b3c349 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -166,6 +166,7 @@ static void bpf_map_put_uref(struct bpf_map *map)
 void bpf_map_put(struct bpf_map *map)
 {
 	if (atomic_dec_and_test(&map->refcnt)) {
+		/* bpf_map_free_id() must be called first */
 		bpf_map_free_id(map);
 		INIT_WORK(&map->work, bpf_map_free_deferred);
 		schedule_work(&map->work);
@@ -726,6 +727,7 @@ void bpf_prog_put(struct bpf_prog *prog)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
 		trace_bpf_prog_put_rcu(prog);
+		/* bpf_prog_free_id() must be called first */
 		bpf_prog_free_id(prog);
 		bpf_prog_kallsyms_del(prog);
 		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
@@ -1067,6 +1069,34 @@ static int bpf_prog_test_run(const union bpf_attr *attr,
 	return ret;
 }
 
+#define BPF_OBJ_GET_NEXT_ID_LAST_FIELD next_id
+
+static int bpf_obj_get_next_id(const union bpf_attr *attr,
+			       union bpf_attr __user *uattr,
+			       struct idr *idr,
+			       spinlock_t *lock)
+{
+	u32 next_id = attr->start_id;
+	int err = 0;
+
+	if (CHECK_ATTR(BPF_OBJ_GET_NEXT_ID) || next_id >= INT_MAX)
+		return -EINVAL;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	next_id++;
+	spin_lock_bh(lock);
+	if (!idr_get_next(idr, &next_id))
+		err = -ENOENT;
+	spin_unlock_bh(lock);
+
+	if (!err)
+		err = put_user(next_id, &uattr->next_id);
+
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -1144,6 +1174,14 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_TEST_RUN:
 		err = bpf_prog_test_run(&attr, uattr);
 		break;
+	case BPF_PROG_GET_NEXT_ID:
+		err = bpf_obj_get_next_id(&attr, uattr,
+					  &prog_idr, &prog_idr_lock);
+		break;
+	case BPF_MAP_GET_NEXT_ID:
+		err = bpf_obj_get_next_id(&attr, uattr,
+					  &map_idr, &map_idr_lock);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.9.3
