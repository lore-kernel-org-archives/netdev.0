From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 1/8] bpf: Add support for recursively running cgroup sock filters
Date: Fri, 25 Aug 2017 12:05:34 -0700
Message-ID: <1503687941-626-2-git-send-email-dsahern@gmail.com>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35620 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756602AbdHYTFu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 15:05:50 -0400
Received: by mail-pg0-f67.google.com with SMTP id r133so904422pgr.2
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 12:05:50 -0700 (PDT)
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for recursively applying sock filters attached to a cgroup.
For now, start with the inner cgroup attached to the socket and work back
to the root or first cgroup without the recursive flag set. Once the
recursive flag is set for a cgroup all descendant group's must have the
flag as well.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/linux/bpf-cgroup.h | 10 ++++++----
 include/uapi/linux/bpf.h   |  9 +++++++++
 kernel/bpf/cgroup.c        | 29 ++++++++++++++++++++++-------
 kernel/bpf/syscall.c       |  6 +++---
 kernel/cgroup/cgroup.c     | 25 +++++++++++++++++++++++--
 5 files changed, 63 insertions(+), 16 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index d41d40ac3efd..2d02187f242f 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -23,6 +23,7 @@ struct cgroup_bpf {
 	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
 	struct bpf_prog __rcu *effective[MAX_BPF_ATTACH_TYPE];
 	bool disallow_override[MAX_BPF_ATTACH_TYPE];
+	bool is_recursive[MAX_BPF_ATTACH_TYPE];
 };
 
 void cgroup_bpf_put(struct cgroup *cgrp);
@@ -30,18 +31,19 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent);
 
 int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
 			struct bpf_prog *prog, enum bpf_attach_type type,
-			bool overridable);
+			u32 flags);
 
 /* Wrapper for __cgroup_bpf_update() protected by cgroup_mutex */
 int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
-		      enum bpf_attach_type type, bool overridable);
+		      enum bpf_attach_type type, u32 flags);
 
 int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
 				enum bpf_attach_type type);
 
-int __cgroup_bpf_run_filter_sk(struct sock *sk,
+int __cgroup_bpf_run_filter_sk(struct cgroup *cgrp, struct sock *sk,
 			       enum bpf_attach_type type);
+int cgroup_bpf_run_filter_sk(struct sock *sk, enum bpf_attach_type type);
 
 int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 				     struct bpf_sock_ops_kern *sock_ops,
@@ -74,7 +76,7 @@ int __cgroup_bpf_run_filter_sock_ops(struct sock *sk,
 ({									       \
 	int __ret = 0;							       \
 	if (cgroup_bpf_enabled && sk) {					       \
-		__ret = __cgroup_bpf_run_filter_sk(sk,			       \
+		__ret = cgroup_bpf_run_filter_sk(sk,			       \
 						 BPF_CGROUP_INET_SOCK_CREATE); \
 	}								       \
 	__ret;								       \
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index f71f5e07d82d..595e31b30f23 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -151,6 +151,15 @@ enum bpf_attach_type {
  */
 #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
 
+/* If BPF_F_RECURSIVE flag is used in BPF_PROG_ATTACH command
+ * cgroups are walked recursively back to the root cgroup or the
+ * first cgroup without the flag set running any program attached.
+ * Once the flag is set, it MUST be set for all descendant cgroups.
+ */
+#define BPF_F_RECURSIVE		(1U << 1)
+
+#define BPF_F_ALL_ATTACH_FLAGS  (BPF_F_ALLOW_OVERRIDE | BPF_F_RECURSIVE)
+
 /* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
  * verifier will perform strict alignment checking as if the kernel
  * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index 546113430049..eb1f436c18fb 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -47,10 +47,16 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 	unsigned int type;
 
 	for (type = 0; type < ARRAY_SIZE(cgrp->bpf.effective); type++) {
-		struct bpf_prog *e;
+		struct bpf_prog *e = NULL;
+
+		/* do not need to set effective program if cgroups are
+		 * walked recursively
+		 */
+		cgrp->bpf.is_recursive[type] = parent->bpf.is_recursive[type];
+		if (!cgrp->bpf.is_recursive[type])
+			e = rcu_dereference_protected(parent->bpf.effective[type],
+						      lockdep_is_held(&cgroup_mutex));
 
-		e = rcu_dereference_protected(parent->bpf.effective[type],
-					      lockdep_is_held(&cgroup_mutex));
 		rcu_assign_pointer(cgrp->bpf.effective[type], e);
 		cgrp->bpf.disallow_override[type] = parent->bpf.disallow_override[type];
 	}
@@ -85,8 +91,12 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
  */
 int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
 			struct bpf_prog *prog, enum bpf_attach_type type,
-			bool new_overridable)
+			u32 flags)
 {
+	bool new_overridable = flags & BPF_F_ALLOW_OVERRIDE;
+	/* initial state inherited from parent */
+	bool curr_recursive = cgrp->bpf.is_recursive[type];
+	bool new_recursive = flags & BPF_F_RECURSIVE;
 	struct bpf_prog *old_prog, *effective = NULL;
 	struct cgroup_subsys_state *pos;
 	bool overridable = true;
@@ -109,6 +119,12 @@ int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
 		 */
 		return -EPERM;
 
+	if (prog && curr_recursive && !new_recursive)
+		/* if a parent has recursive prog attached, only
+		 * allow recursive programs in descendent cgroup
+		 */
+		return -EINVAL;
+
 	old_prog = cgrp->bpf.prog[type];
 
 	if (prog) {
@@ -139,6 +155,7 @@ int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
 			rcu_assign_pointer(desc->bpf.effective[type],
 					   effective);
 			desc->bpf.disallow_override[type] = !overridable;
+			desc->bpf.is_recursive[type] = new_recursive;
 		}
 	}
 
@@ -217,14 +234,12 @@ EXPORT_SYMBOL(__cgroup_bpf_run_filter_skb);
  * This function will return %-EPERM if any if an attached program was found
  * and if it returned != 1 during execution. In all other cases, 0 is returned.
  */
-int __cgroup_bpf_run_filter_sk(struct sock *sk,
+int __cgroup_bpf_run_filter_sk(struct cgroup *cgrp, struct sock *sk,
 			       enum bpf_attach_type type)
 {
-	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
 	struct bpf_prog *prog;
 	int ret = 0;
 
-
 	rcu_read_lock();
 
 	prog = rcu_dereference(cgrp->bpf.effective[type]);
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index d5774a6851f1..a1ab5dbaae89 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1187,7 +1187,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_PROG_ATTACH))
 		return -EINVAL;
 
-	if (attr->attach_flags & ~BPF_F_ALLOW_OVERRIDE)
+	if (attr->attach_flags & ~BPF_F_ALL_ATTACH_FLAGS)
 		return -EINVAL;
 
 	switch (attr->attach_type) {
@@ -1222,7 +1222,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	}
 
 	ret = cgroup_bpf_update(cgrp, prog, attr->attach_type,
-				attr->attach_flags & BPF_F_ALLOW_OVERRIDE);
+				attr->attach_flags);
 	if (ret)
 		bpf_prog_put(prog);
 	cgroup_put(cgrp);
@@ -1252,7 +1252,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
 
-		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, false);
+		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, 0);
 		cgroup_put(cgrp);
 		break;
 
diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
index df2e0f14a95d..27a4f14435a3 100644
--- a/kernel/cgroup/cgroup.c
+++ b/kernel/cgroup/cgroup.c
@@ -5176,14 +5176,35 @@ void cgroup_sk_free(struct sock_cgroup_data *skcd)
 
 #ifdef CONFIG_CGROUP_BPF
 int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
-		      enum bpf_attach_type type, bool overridable)
+		      enum bpf_attach_type type, u32 flags)
 {
 	struct cgroup *parent = cgroup_parent(cgrp);
 	int ret;
 
 	mutex_lock(&cgroup_mutex);
-	ret = __cgroup_bpf_update(cgrp, parent, prog, type, overridable);
+	ret = __cgroup_bpf_update(cgrp, parent, prog, type, flags);
 	mutex_unlock(&cgroup_mutex);
 	return ret;
 }
+
+int cgroup_bpf_run_filter_sk(struct sock *sk,
+			     enum bpf_attach_type type)
+{
+	struct cgroup *cgrp = sock_cgroup_ptr(&sk->sk_cgrp_data);
+	int ret = 0;
+
+	while (cgrp) {
+		ret = __cgroup_bpf_run_filter_sk(cgrp, sk, type);
+		if (ret)
+			break;
+
+		if (!cgrp->bpf.is_recursive[type])
+			break;
+
+		cgrp = cgroup_parent(cgrp);
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(cgroup_bpf_run_filter_sk);
 #endif /* CONFIG_CGROUP_BPF */
-- 
2.1.4
