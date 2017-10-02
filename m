From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 2/8] bpf: introduce BPF_PROG_QUERY command
Date: Mon, 2 Oct 2017 16:48:51 -0700
Message-ID: <20171002234857.3707580-3-ast@fb.com>
References: <20171002234857.3707580-1-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>, Tejun Heo <tj@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:45868 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751102AbdJBXtC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 19:49:02 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.21/8.16.0.21) with SMTP id v92NmqGk027855
        for <netdev@vger.kernel.org>; Mon, 2 Oct 2017 16:49:01 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 2dbwbg8jdg-5
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 16:49:01 -0700
In-Reply-To: <20171002234857.3707580-1-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce BPF_PROG_QUERY command to retrieve a set of either
attached programs to given cgroup or a set of effective programs
that will execute for events within a cgroup

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
for cgroup bits
Acked-by: Tejun Heo <tj@kernel.org>
---
 include/linux/bpf-cgroup.h |  4 ++++
 include/linux/bpf.h        |  3 +++
 include/uapi/linux/bpf.h   | 13 +++++++++++++
 kernel/bpf/cgroup.c        | 43 +++++++++++++++++++++++++++++++++++++++++++
 kernel/bpf/core.c          | 33 +++++++++++++++++++++++++++++++++
 kernel/bpf/syscall.c       | 34 ++++++++++++++++++++++++++++++++++
 kernel/cgroup/cgroup.c     | 10 ++++++++++
 7 files changed, 140 insertions(+)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 102e56fbb6de..359b6f5d3d90 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -44,12 +44,16 @@ int __cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
 			enum bpf_attach_type type, u32 flags);
 int __cgroup_bpf_detach(struct cgroup *cgrp, struct bpf_prog *prog,
 			enum bpf_attach_type type, u32 flags);
+int __cgroup_bpf_query(struct cgroup *cgrp, const union bpf_attr *attr,
+		       union bpf_attr __user *uattr);
 
 /* Wrapper for __cgroup_bpf_*() protected by cgroup_mutex */
 int cgroup_bpf_attach(struct cgroup *cgrp, struct bpf_prog *prog,
 		      enum bpf_attach_type type, u32 flags);
 int cgroup_bpf_detach(struct cgroup *cgrp, struct bpf_prog *prog,
 		      enum bpf_attach_type type, u32 flags);
+int cgroup_bpf_query(struct cgroup *cgrp, const union bpf_attr *attr,
+		     union bpf_attr __user *uattr);
 
 int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index a6964b75f070..fc2317f8ea89 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -260,6 +260,9 @@ struct bpf_prog_array {
 
 struct bpf_prog_array __rcu *bpf_prog_array_alloc(u32 prog_cnt, gfp_t flags);
 void bpf_prog_array_free(struct bpf_prog_array __rcu *progs);
+int bpf_prog_array_length(struct bpf_prog_array __rcu *progs);
+int bpf_prog_array_copy_to_user(struct bpf_prog_array __rcu *progs,
+				__u32 __user *prog_ids);
 
 #define BPF_PROG_RUN_ARRAY(array, ctx, func)		\
 	({						\
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 762f74bc6c47..cb2b9f95160a 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -92,6 +92,7 @@ enum bpf_cmd {
 	BPF_PROG_GET_FD_BY_ID,
 	BPF_MAP_GET_FD_BY_ID,
 	BPF_OBJ_GET_INFO_BY_FD,
+	BPF_PROG_QUERY,
 };
 
 enum bpf_map_type {
@@ -211,6 +212,9 @@ enum bpf_attach_type {
 /* Specify numa node during map creation */
 #define BPF_F_NUMA_NODE		(1U << 2)
 
+/* flags for BPF_PROG_QUERY */
+#define BPF_F_QUERY_EFFECTIVE	(1U << 0)
+
 #define BPF_OBJ_NAME_LEN 16U
 
 union bpf_attr {
@@ -289,6 +293,15 @@ union bpf_attr {
 		__u32		info_len;
 		__aligned_u64	info;
 	} info;
+
+	struct { /* anonymous struct used by BPF_PROG_QUERY command */
+		__u32		target_fd;	/* container object to query */
+		__u32		attach_type;
+		__u32		query_flags;
+		__u32		attach_flags;
+		__aligned_u64	prog_ids;
+		__u32		prog_cnt;
+	} query;
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 70f679a94804..3dd36faa1a99 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -384,6 +384,49 @@ int __cgroup_bpf_detach(struct cgroup *cgrp, struct bpf_prog *prog,
 	return err;
 }
 
+/* Must be called with cgroup_mutex held to avoid races. */
+int __cgroup_bpf_query(struct cgroup *cgrp, const union bpf_attr *attr,
+		       union bpf_attr __user *uattr)
+{
+	__u32 __user *prog_ids = u64_to_user_ptr(attr->query.prog_ids);
+	enum bpf_attach_type type = attr->query.attach_type;
+	struct list_head *progs = &cgrp->bpf.progs[type];
+	u32 flags = cgrp->bpf.flags[type];
+	int cnt;
+
+	if (attr->query.query_flags & BPF_F_QUERY_EFFECTIVE)
+		cnt = bpf_prog_array_length(cgrp->bpf.effective[type]);
+	else
+		cnt = prog_list_length(progs);
+
+	if (copy_to_user(&uattr->query.attach_flags, &flags, sizeof(flags)))
+		return -EFAULT;
+	if (copy_to_user(&uattr->query.prog_cnt, &cnt, sizeof(cnt)))
+		return -EFAULT;
+	if (attr->query.prog_cnt == 0 || !prog_ids)
+		/* return early if user requested only program count + flags */
+		return 0;
+	if (attr->query.prog_cnt < cnt)
+		return -ENOSPC;
+
+	if (attr->query.query_flags & BPF_F_QUERY_EFFECTIVE) {
+		return bpf_prog_array_copy_to_user(cgrp->bpf.effective[type],
+						   prog_ids);
+	} else {
+		struct bpf_prog_list *pl;
+		u32 id;
+
+		cnt = 0;
+		list_for_each_entry(pl, progs, node) {
+			id = pl->prog->aux->id;
+			if (copy_to_user(prog_ids + cnt, &id, sizeof(id)))
+				return -EFAULT;
+			cnt++;
+		}
+	}
+	return 0;
+}
+
 /**
  * __cgroup_bpf_run_filter_skb() - Run a program for packet filtering
  * @sk: The socket sending or receiving traffic
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 6b49e1991ae7..6083f15c311a 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1412,6 +1412,39 @@ void bpf_prog_array_free(struct bpf_prog_array __rcu *progs)
 	kfree_rcu(progs, rcu);
 }
 
+int bpf_prog_array_length(struct bpf_prog_array __rcu *progs)
+{
+	struct bpf_prog **prog;
+	u32 cnt = 0;
+
+	rcu_read_lock();
+	prog = rcu_dereference(progs)->progs;
+	for (; *prog; prog++)
+		cnt++;
+	rcu_read_unlock();
+	return cnt;
+}
+
+int bpf_prog_array_copy_to_user(struct bpf_prog_array __rcu *progs,
+				__u32 __user *prog_ids)
+{
+	struct bpf_prog **prog;
+	u32 cnt = 0, id;
+
+	rcu_read_lock();
+	prog = rcu_dereference(progs)->progs;
+	for (; *prog; prog++) {
+		id = (*prog)->aux->id;
+		if (copy_to_user(prog_ids + cnt, &id, sizeof(id))) {
+			rcu_read_unlock();
+			return -EFAULT;
+		}
+		cnt++;
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
 static void bpf_prog_free_deferred(struct work_struct *work)
 {
 	struct bpf_prog_aux *aux;
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 51bee695d32c..0048cb24ba7b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1272,6 +1272,37 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 	return ret;
 }
 
+#define BPF_PROG_QUERY_LAST_FIELD query.prog_cnt
+
+static int bpf_prog_query(const union bpf_attr *attr,
+			  union bpf_attr __user *uattr)
+{
+	struct cgroup *cgrp;
+	int ret;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+	if (CHECK_ATTR(BPF_PROG_QUERY))
+		return -EINVAL;
+	if (attr->query.query_flags & ~BPF_F_QUERY_EFFECTIVE)
+		return -EINVAL;
+
+	switch (attr->query.attach_type) {
+	case BPF_CGROUP_INET_INGRESS:
+	case BPF_CGROUP_INET_EGRESS:
+	case BPF_CGROUP_INET_SOCK_CREATE:
+	case BPF_CGROUP_SOCK_OPS:
+		break;
+	default:
+		return -EINVAL;
+	}
+	cgrp = cgroup_get_from_fd(attr->query.target_fd);
+	if (IS_ERR(cgrp))
+		return PTR_ERR(cgrp);
+	ret = cgroup_bpf_query(cgrp, attr, uattr);
+	cgroup_put(cgrp);
+	return ret;
+}
 #endif /* CONFIG_CGROUP_BPF */
 
 #define BPF_PROG_TEST_RUN_LAST_FIELD test.duration
@@ -1568,6 +1599,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_DETACH:
 		err = bpf_prog_detach(&attr);
 		break;
+	case BPF_PROG_QUERY:
+		err = bpf_prog_query(&attr, uattr);
+		break;
 #endif
 	case BPF_PROG_TEST_RUN:
 		err = bpf_prog_test_run(&attr, uattr);
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index 57eb866ae78d..269512b94a94 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -5761,4 +5761,14 @@ int cgroup_bpf_detach(struct cgroup *cgrp, struct bpf_prog *prog,
 	mutex_unlock(&cgroup_mutex);
 	return ret;
 }
+int cgroup_bpf_query(struct cgroup *cgrp, const union bpf_attr *attr,
+		     union bpf_attr __user *uattr)
+{
+	int ret;
+
+	mutex_lock(&cgroup_mutex);
+	ret = __cgroup_bpf_query(cgrp, attr, uattr);
+	mutex_unlock(&cgroup_mutex);
+	return ret;
+}
 #endif /* CONFIG_CGROUP_BPF */
-- 
2.9.5
