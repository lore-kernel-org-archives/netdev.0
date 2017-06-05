From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 4/8] bpf: Add BPF_PROG_GET_FD_BY_ID
Date: Mon, 5 Jun 2017 12:15:49 -0700
Message-ID: <10217e6017bc1427503dbab7e1a6f32712842e51.1496686606.git.kafai@fb.com>
References: <cover.1496686606.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:58025 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751181AbdFETP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 15:15:58 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v55JFllr023581
        for <netdev@vger.kernel.org>; Mon, 5 Jun 2017 12:15:57 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 2awc0s08sx-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 12:15:57 -0700
Received: from facebook.com (2401:db00:11:d09a:face:0:41:0)     by
 mx-out.facebook.com (10.212.236.87) with ESMTP id
 6636ada04a2311e7a4470002c9521c9e-fbb338f0 for <netdev@vger.kernel.org>;        Mon,
 05 Jun 2017 12:15:55 -0700
In-Reply-To: <cover.1496686606.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add BPF_PROG_GET_FD_BY_ID command to allow user to get a fd
from a bpf_prog's ID.

bpf_prog_inc_not_zero() is added and is called with prog_idr_lock
held.

__bpf_prog_put() is also added which has the 'bool do_idr_lock'
param to decide if the prog_idr_lock should be acquired when
freeing the prog->id.

In the error path of bpf_prog_inc_not_zero(), it may have to
call __bpf_prog_put(map, false) which does not need
to take the prog_idr_lock when freeing the prog->id.

It is currently limited to CAP_SYS_ADMIN which we can
consider to lift it in followup patches.

Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Acked-by: Alexei Starovoitov <ast@fb.com>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/uapi/linux/bpf.h |  8 +++--
 kernel/bpf/syscall.c     | 91 ++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 87 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 629747a3f273..d70cfed19d5e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -84,6 +84,7 @@ enum bpf_cmd {
 	BPF_PROG_TEST_RUN,
 	BPF_PROG_GET_NEXT_ID,
 	BPF_MAP_GET_NEXT_ID,
+	BPF_PROG_GET_FD_BY_ID,
 };
 
 enum bpf_map_type {
@@ -212,8 +213,11 @@ union bpf_attr {
 		__u32		duration;
 	} test;
 
-	struct { /* anonymous struct used by BPF_*_GET_NEXT_ID */
-		__u32		start_id;
+	struct { /* anonymous struct used by BPF_*_GET_*_ID */
+		union {
+			__u32		start_id;
+			__u32		prog_id;
+		};
 		__u32		next_id;
 	};
 } __attribute__((aligned(8)));
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 2405feedb8c1..dc6253bb8ebb 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -703,15 +703,23 @@ static int bpf_prog_alloc_id(struct bpf_prog *prog)
 	return id > 0 ? 0 : id;
 }
 
-static void bpf_prog_free_id(struct bpf_prog *prog)
+static void bpf_prog_free_id(struct bpf_prog *prog, bool do_idr_lock)
 {
 	/* cBPF to eBPF migrations are currently not in the idr store. */
 	if (!prog->aux->id)
 		return;
 
-	spin_lock_bh(&prog_idr_lock);
+	if (do_idr_lock)
+		spin_lock_bh(&prog_idr_lock);
+	else
+		__acquire(&prog_idr_lock);
+
 	idr_remove(&prog_idr, prog->aux->id);
-	spin_unlock_bh(&prog_idr_lock);
+
+	if (do_idr_lock)
+		spin_unlock_bh(&prog_idr_lock);
+	else
+		__release(&prog_idr_lock);
 }
 
 static void __bpf_prog_put_rcu(struct rcu_head *rcu)
@@ -723,16 +731,21 @@ static void __bpf_prog_put_rcu(struct rcu_head *rcu)
 	bpf_prog_free(aux->prog);
 }
 
-void bpf_prog_put(struct bpf_prog *prog)
+static void __bpf_prog_put(struct bpf_prog *prog, bool do_idr_lock)
 {
 	if (atomic_dec_and_test(&prog->aux->refcnt)) {
 		trace_bpf_prog_put_rcu(prog);
 		/* bpf_prog_free_id() must be called first */
-		bpf_prog_free_id(prog);
+		bpf_prog_free_id(prog, do_idr_lock);
 		bpf_prog_kallsyms_del(prog);
 		call_rcu(&prog->aux->rcu, __bpf_prog_put_rcu);
 	}
 }
+
+void bpf_prog_put(struct bpf_prog *prog)
+{
+	__bpf_prog_put(prog, true);
+}
 EXPORT_SYMBOL_GPL(bpf_prog_put);
 
 static int bpf_prog_release(struct inode *inode, struct file *filp)
@@ -814,6 +827,24 @@ struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 }
 EXPORT_SYMBOL_GPL(bpf_prog_inc);
 
+/* prog_idr_lock should have been held */
+static struct bpf_prog *bpf_prog_inc_not_zero(struct bpf_prog *prog)
+{
+	int refold;
+
+	refold = __atomic_add_unless(&prog->aux->refcnt, 1, 0);
+
+	if (refold >= BPF_MAX_REFCNT) {
+		__bpf_prog_put(prog, false);
+		return ERR_PTR(-EBUSY);
+	}
+
+	if (!refold)
+		return ERR_PTR(-ENOENT);
+
+	return prog;
+}
+
 static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
 	struct fd f = fdget(ufd);
@@ -928,16 +959,21 @@ static int bpf_prog_load(union bpf_attr *attr)
 		goto free_used_maps;
 
 	err = bpf_prog_new_fd(prog);
-	if (err < 0)
-		/* failed to allocate fd */
-		goto free_id;
+	if (err < 0) {
+		/* failed to allocate fd.
+		 * bpf_prog_put() is needed because the above
+		 * bpf_prog_alloc_id() has published the prog
+		 * to the userspace and the userspace may
+		 * have refcnt-ed it through BPF_PROG_GET_FD_BY_ID.
+		 */
+		bpf_prog_put(prog);
+		return err;
+	}
 
 	bpf_prog_kallsyms_add(prog);
 	trace_bpf_prog_load(prog, err);
 	return err;
 
-free_id:
-	bpf_prog_free_id(prog);
 free_used_maps:
 	free_used_maps(prog->aux);
 free_prog:
@@ -1099,6 +1135,38 @@ static int bpf_obj_get_next_id(const union bpf_attr *attr,
 	return err;
 }
 
+#define BPF_PROG_GET_FD_BY_ID_LAST_FIELD prog_id
+
+static int bpf_prog_get_fd_by_id(const union bpf_attr *attr)
+{
+	struct bpf_prog *prog;
+	u32 id = attr->prog_id;
+	int fd;
+
+	if (CHECK_ATTR(BPF_PROG_GET_FD_BY_ID))
+		return -EINVAL;
+
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
+
+	spin_lock_bh(&prog_idr_lock);
+	prog = idr_find(&prog_idr, id);
+	if (prog)
+		prog = bpf_prog_inc_not_zero(prog);
+	else
+		prog = ERR_PTR(-ENOENT);
+	spin_unlock_bh(&prog_idr_lock);
+
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	fd = bpf_prog_new_fd(prog);
+	if (fd < 0)
+		bpf_prog_put(prog);
+
+	return fd;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -1184,6 +1252,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 		err = bpf_obj_get_next_id(&attr, uattr,
 					  &map_idr, &map_idr_lock);
 		break;
+	case BPF_PROG_GET_FD_BY_ID:
+		err = bpf_prog_get_fd_by_id(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.9.3
