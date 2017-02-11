From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Fri, 10 Feb 2017 20:28:24 -0800
Message-ID: <1486787304-2805663-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:46884 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752083AbdBKE22 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 23:28:28 -0500
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1B4PO2L013357
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 20:28:27 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28hk6dsc0x-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 20:28:27 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.212.232.63) with ESMTP id
 8743320ef01211e693e90002c992ebde-25ad9a00 for <netdev@vger.kernel.org>;        Fri,
 10 Feb 2017 20:28:25 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
to the given cgroup the descendent cgroup will be able to override
effective bpf program that was inherited from this cgroup.
By default it's not passed, therefore override is disallowed.

Examples:
1.
prog X attached to /A with default
prog Y fails to attach to /A/B and /A/B/C
Everything under /A runs prog X

2.
prog X attached to /A with allow_override.
prog Y fails to attach to /A/B with default (non-override)
prog M attached to /A/B with allow_override.
Everything under /A/B runs prog M only.

3.
prog X attached to /A with allow_override.
prog Y fails to attach to /A with default.
The user has to detach first to switch the mode.

In the future this behavior may be extended with a chain of
non-overridable programs.

Also fix the bug where detach from cgroup where nothing is attached
was not throwing error. Return ENOENT in such case.

Add several testcases and adjust libbpf.

Fixes: 3007098494be ("cgroup: add support for eBPF programs")
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
v1->v2: disallowed overridable->non_override transition as suggested by Andy
added tests and fixed double detach bug

Andy, Daniel,
please review and ack quickly, so it can land into 4.10.
---
 include/linux/bpf-cgroup.h       | 13 ++++----
 include/uapi/linux/bpf.h         |  7 +++++
 kernel/bpf/cgroup.c              | 59 +++++++++++++++++++++++++++-------
 kernel/bpf/syscall.c             | 20 ++++++++----
 kernel/cgroup.c                  |  9 +++---
 samples/bpf/test_cgrp2_attach.c  |  2 +-
 samples/bpf/test_cgrp2_attach2.c | 68 +++++++++++++++++++++++++++++++++++++---
 samples/bpf/test_cgrp2_sock.c    |  2 +-
 samples/bpf/test_cgrp2_sock2.c   |  2 +-
 tools/lib/bpf/bpf.c              |  4 ++-
 tools/lib/bpf/bpf.h              |  3 +-
 11 files changed, 151 insertions(+), 38 deletions(-)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 92bc89ae7e20..c970a25d2a49 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -21,20 +21,19 @@ struct cgroup_bpf {
 	 */
 	struct bpf_prog *prog[MAX_BPF_ATTACH_TYPE];
 	struct bpf_prog __rcu *effective[MAX_BPF_ATTACH_TYPE];
+	bool disallow_override[MAX_BPF_ATTACH_TYPE];
 };
 
 void cgroup_bpf_put(struct cgroup *cgrp);
 void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent);
 
-void __cgroup_bpf_update(struct cgroup *cgrp,
-			 struct cgroup *parent,
-			 struct bpf_prog *prog,
-			 enum bpf_attach_type type);
+int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
+			struct bpf_prog *prog, enum bpf_attach_type type,
+			bool overridable);
 
 /* Wrapper for __cgroup_bpf_update() protected by cgroup_mutex */
-void cgroup_bpf_update(struct cgroup *cgrp,
-		       struct bpf_prog *prog,
-		       enum bpf_attach_type type);
+int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
+		      enum bpf_attach_type type, bool overridable);
 
 int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e5b8cf16cbaf..69f65b710b10 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -116,6 +116,12 @@ enum bpf_attach_type {
 
 #define MAX_BPF_ATTACH_TYPE __MAX_BPF_ATTACH_TYPE
 
+/* If BPF_F_ALLOW_OVERRIDE flag is used in BPF_PROG_ATTACH command
+ * to the given target_fd cgroup the descendent cgroup will be able to
+ * override effective bpf program that was inherited from this cgroup
+ */
+#define BPF_F_ALLOW_OVERRIDE	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -171,6 +177,7 @@ union bpf_attr {
 		__u32		target_fd;	/* container object to attach to */
 		__u32		attach_bpf_fd;	/* eBPF program to attach */
 		__u32		attach_type;
+		__u32		attach_flags;
 	};
 } __attribute__((aligned(8)));
 
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a515f7b007c6..da0f53690295 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -52,6 +52,7 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 		e = rcu_dereference_protected(parent->bpf.effective[type],
 					      lockdep_is_held(&cgroup_mutex));
 		rcu_assign_pointer(cgrp->bpf.effective[type], e);
+		cgrp->bpf.disallow_override[type] = parent->bpf.disallow_override[type];
 	}
 }
 
@@ -82,30 +83,63 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
  *
  * Must be called with cgroup_mutex held.
  */
-void __cgroup_bpf_update(struct cgroup *cgrp,
-			 struct cgroup *parent,
-			 struct bpf_prog *prog,
-			 enum bpf_attach_type type)
+int __cgroup_bpf_update(struct cgroup *cgrp, struct cgroup *parent,
+			struct bpf_prog *prog, enum bpf_attach_type type,
+			bool new_overridable)
 {
-	struct bpf_prog *old_prog, *effective;
+	struct bpf_prog *old_prog, *effective = NULL;
 	struct cgroup_subsys_state *pos;
+	bool overridable = true;
 
-	old_prog = xchg(cgrp->bpf.prog + type, prog);
+	if (parent) {
+		overridable = !parent->bpf.disallow_override[type];
+		effective = rcu_dereference_protected(parent->bpf.effective[type],
+						      lockdep_is_held(&cgroup_mutex));
+	}
+
+	if (prog && effective && !overridable)
+		/* if parent has non-overridable prog attached, disallow
+		 * attaching new programs to descendent cgroup
+		 */
+		return -EPERM;
+
+	if (prog && effective && overridable != new_overridable)
+		/* if parent has overridable prog attached, only
+		 * allow overridable programs in descendent cgroup
+		 */
+		return -EPERM;
 
-	effective = (!prog && parent) ?
-		rcu_dereference_protected(parent->bpf.effective[type],
-					  lockdep_is_held(&cgroup_mutex)) :
-		prog;
+	old_prog = cgrp->bpf.prog[type];
+
+	if (prog) {
+		overridable = new_overridable;
+		effective = prog;
+		if (old_prog &&
+		    cgrp->bpf.disallow_override[type] == new_overridable)
+			/* disallow attaching non-overridable on top
+			 * of existing overridable in this cgroup
+			 * and vice versa
+			 */
+			return -EPERM;
+	}
+
+	if (!prog && !old_prog)
+		/* report error when trying to detach and nothing is attached */
+		return -ENOENT;
+
+	cgrp->bpf.prog[type] = prog;
 
 	css_for_each_descendant_pre(pos, &cgrp->self) {
 		struct cgroup *desc = container_of(pos, struct cgroup, self);
 
 		/* skip the subtree if the descendant has its own program */
-		if (desc->bpf.prog[type] && desc != cgrp)
+		if (desc->bpf.prog[type] && desc != cgrp) {
 			pos = css_rightmost_descendant(pos);
-		else
+		} else {
 			rcu_assign_pointer(desc->bpf.effective[type],
 					   effective);
+			desc->bpf.disallow_override[type] = !overridable;
+		}
 	}
 
 	if (prog)
@@ -115,6 +149,7 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 		bpf_prog_put(old_prog);
 		static_branch_dec(&cgroup_bpf_enabled_key);
 	}
+	return 0;
 }
 
 /**
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 19b6129eab23..bbb016adbaeb 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -920,13 +920,14 @@ static int bpf_obj_get(const union bpf_attr *attr)
 
 #ifdef CONFIG_CGROUP_BPF
 
-#define BPF_PROG_ATTACH_LAST_FIELD attach_type
+#define BPF_PROG_ATTACH_LAST_FIELD attach_flags
 
 static int bpf_prog_attach(const union bpf_attr *attr)
 {
+	enum bpf_prog_type ptype;
 	struct bpf_prog *prog;
 	struct cgroup *cgrp;
-	enum bpf_prog_type ptype;
+	int ret;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -934,6 +935,9 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_PROG_ATTACH))
 		return -EINVAL;
 
+	if (attr->attach_flags & ~BPF_F_ALLOW_OVERRIDE)
+		return -EINVAL;
+
 	switch (attr->attach_type) {
 	case BPF_CGROUP_INET_INGRESS:
 	case BPF_CGROUP_INET_EGRESS:
@@ -956,10 +960,13 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 		return PTR_ERR(cgrp);
 	}
 
-	cgroup_bpf_update(cgrp, prog, attr->attach_type);
+	ret = cgroup_bpf_update(cgrp, prog, attr->attach_type,
+				attr->attach_flags & BPF_F_ALLOW_OVERRIDE);
+	if (ret)
+		bpf_prog_put(prog);
 	cgroup_put(cgrp);
 
-	return 0;
+	return ret;
 }
 
 #define BPF_PROG_DETACH_LAST_FIELD attach_type
@@ -967,6 +974,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 static int bpf_prog_detach(const union bpf_attr *attr)
 {
 	struct cgroup *cgrp;
+	int ret;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -982,7 +990,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
 
-		cgroup_bpf_update(cgrp, NULL, attr->attach_type);
+		ret = cgroup_bpf_update(cgrp, NULL, attr->attach_type, false);
 		cgroup_put(cgrp);
 		break;
 
@@ -990,7 +998,7 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		return -EINVAL;
 	}
 
-	return 0;
+	return ret;
 }
 #endif /* CONFIG_CGROUP_BPF */
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 688dd02af985..53bbca7c4859 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6498,15 +6498,16 @@ static __init int cgroup_namespaces_init(void)
 subsys_initcall(cgroup_namespaces_init);
 
 #ifdef CONFIG_CGROUP_BPF
-void cgroup_bpf_update(struct cgroup *cgrp,
-		       struct bpf_prog *prog,
-		       enum bpf_attach_type type)
+int cgroup_bpf_update(struct cgroup *cgrp, struct bpf_prog *prog,
+		      enum bpf_attach_type type, bool overridable)
 {
 	struct cgroup *parent = cgroup_parent(cgrp);
+	int ret;
 
 	mutex_lock(&cgroup_mutex);
-	__cgroup_bpf_update(cgrp, parent, prog, type);
+	ret = __cgroup_bpf_update(cgrp, parent, prog, type, overridable);
 	mutex_unlock(&cgroup_mutex);
+	return ret;
 }
 #endif /* CONFIG_CGROUP_BPF */
 
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 504058631ffc..4bfcaf93fcf3 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -104,7 +104,7 @@ static int attach_filter(int cg_fd, int type, int verdict)
 		return EXIT_FAILURE;
 	}
 
-	ret = bpf_prog_attach(prog_fd, cg_fd, type);
+	ret = bpf_prog_attach(prog_fd, cg_fd, type, 0);
 	if (ret < 0) {
 		printf("Failed to attach prog to cgroup: '%s'\n",
 		       strerror(errno));
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index 6e69be37f87f..3049b1f26267 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -79,11 +79,12 @@ int main(int argc, char **argv)
 	if (join_cgroup(FOO))
 		goto err;
 
-	if (bpf_prog_attach(drop_prog, foo, BPF_CGROUP_INET_EGRESS)) {
+	if (bpf_prog_attach(drop_prog, foo, BPF_CGROUP_INET_EGRESS, 1)) {
 		log_err("Attaching prog to /foo");
 		goto err;
 	}
 
+	printf("Attached DROP prog. This ping in cgroup /foo should fail...\n");
 	assert(system(PING_CMD) != 0);
 
 	/* Create cgroup /foo/bar, get fd, and join it */
@@ -94,24 +95,27 @@ int main(int argc, char **argv)
 	if (join_cgroup(BAR))
 		goto err;
 
+	printf("Attached DROP prog. This ping in cgroup /foo/bar should fail...\n");
 	assert(system(PING_CMD) != 0);
 
-	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS)) {
+	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 1)) {
 		log_err("Attaching prog to /foo/bar");
 		goto err;
 	}
 
+	printf("Attached PASS prog. This ping in cgroup /foo/bar should pass...\n");
 	assert(system(PING_CMD) == 0);
 
-
 	if (bpf_prog_detach(bar, BPF_CGROUP_INET_EGRESS)) {
 		log_err("Detaching program from /foo/bar");
 		goto err;
 	}
 
+	printf("Detached PASS from /foo/bar while DROP is attached to /foo.\n"
+	       "This ping in cgroup /foo/bar should fail...\n");
 	assert(system(PING_CMD) != 0);
 
-	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS)) {
+	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 1)) {
 		log_err("Attaching prog to /foo/bar");
 		goto err;
 	}
@@ -121,8 +125,60 @@ int main(int argc, char **argv)
 		goto err;
 	}
 
+	printf("Attached PASS from /foo/bar and detached DROP from /foo.\n"
+	       "This ping in cgroup /foo/bar should pass...\n");
 	assert(system(PING_CMD) == 0);
 
+	if (bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 1)) {
+		log_err("Attaching prog to /foo/bar");
+		goto err;
+	}
+
+	if (!bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 0)) {
+		errno = 0;
+		log_err("Unexpected success attaching prog to /foo/bar");
+		goto err;
+	}
+
+	if (bpf_prog_detach(bar, BPF_CGROUP_INET_EGRESS)) {
+		log_err("Detaching program from /foo/bar");
+		goto err;
+	}
+
+	if (!bpf_prog_detach(foo, BPF_CGROUP_INET_EGRESS)) {
+		errno = 0;
+		log_err("Unexpected success in double detach from /foo");
+		goto err;
+	}
+
+	if (bpf_prog_attach(allow_prog, foo, BPF_CGROUP_INET_EGRESS, 0)) {
+		log_err("Attaching non-overridable prog to /foo");
+		goto err;
+	}
+
+	if (!bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 0)) {
+		errno = 0;
+		log_err("Unexpected success attaching non-overridable prog to /foo/bar");
+		goto err;
+	}
+
+	if (!bpf_prog_attach(allow_prog, bar, BPF_CGROUP_INET_EGRESS, 1)) {
+		errno = 0;
+		log_err("Unexpected success attaching overridable prog to /foo/bar");
+		goto err;
+	}
+
+	if (!bpf_prog_attach(allow_prog, foo, BPF_CGROUP_INET_EGRESS, 1)) {
+		errno = 0;
+		log_err("Unexpected success attaching overridable prog to /foo");
+		goto err;
+	}
+
+	if (bpf_prog_attach(drop_prog, foo, BPF_CGROUP_INET_EGRESS, 0)) {
+		log_err("Attaching different non-overridable prog to /foo");
+		goto err;
+	}
+
 	goto out;
 
 err:
@@ -132,5 +188,9 @@ int main(int argc, char **argv)
 	close(foo);
 	close(bar);
 	cleanup_cgroup_environment();
+	if (!rc)
+		printf("PASS\n");
+	else
+		printf("FAIL\n");
 	return rc;
 }
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index 0791b949cbe4..c3cfb23e23b5 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -75,7 +75,7 @@ int main(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 
-	ret = bpf_prog_attach(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE);
+	ret = bpf_prog_attach(prog_fd, cg_fd, BPF_CGROUP_INET_SOCK_CREATE, 0);
 	if (ret < 0) {
 		printf("Failed to attach prog to cgroup: '%s'\n",
 		       strerror(errno));
diff --git a/samples/bpf/test_cgrp2_sock2.c b/samples/bpf/test_cgrp2_sock2.c
index 455ef0d06e93..db036077b644 100644
--- a/samples/bpf/test_cgrp2_sock2.c
+++ b/samples/bpf/test_cgrp2_sock2.c
@@ -55,7 +55,7 @@ int main(int argc, char **argv)
 	}
 
 	ret = bpf_prog_attach(prog_fd[filter_id], cg_fd,
-			      BPF_CGROUP_INET_SOCK_CREATE);
+			      BPF_CGROUP_INET_SOCK_CREATE, 0);
 	if (ret < 0) {
 		printf("Failed to attach prog to cgroup: '%s'\n",
 		       strerror(errno));
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 3ddb58a36d3c..ae752fa4eaa7 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -168,7 +168,8 @@ int bpf_obj_get(const char *pathname)
 	return sys_bpf(BPF_OBJ_GET, &attr, sizeof(attr));
 }
 
-int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
+int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type,
+		    unsigned int flags)
 {
 	union bpf_attr attr;
 
@@ -176,6 +177,7 @@ int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
 	attr.target_fd	   = target_fd;
 	attr.attach_bpf_fd = prog_fd;
 	attr.attach_type   = type;
+	attr.attach_flags  = flags;
 
 	return sys_bpf(BPF_PROG_ATTACH, &attr, sizeof(attr));
 }
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index a2f9853dd882..4ac6c4b84100 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -41,7 +41,8 @@ int bpf_map_delete_elem(int fd, void *key);
 int bpf_map_get_next_key(int fd, void *key, void *next_key);
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
-int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
+int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type,
+		    unsigned int flags);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 
 
-- 
2.8.0
