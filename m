From: Alexei Starovoitov <ast@fb.com>
Subject: [RFC PATCH net] bpf: introduce BPF_F_ALLOW_OVERRIDE flag
Date: Thu, 9 Feb 2017 10:59:23 -0800
Message-ID: <1486666763-2698065-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Ahern <dsa@cumulusnetworks.com>,
        Daniel Mack <daniel@zonque.org>, Tejun Heo <tj@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41543 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751988AbdBITAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 14:00:23 -0500
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v19IrxW9017066
        for <netdev@vger.kernel.org>; Thu, 9 Feb 2017 10:59:24 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28gwu9g3xh-2
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 10:59:24 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 deb027beeef911e6b11c0002c9dfb610-65f5a00 for <netdev@vger.kernel.org>; Thu,
 09 Feb 2017 10:59:23 -0800
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
prog X attached to /A with ALLOW_OVERRIDE
prog Y attached to /A/B with default. Everything under /A/B runs prog Y
prog M attached to /A/C with default. Everything under /A/C runs prog M
prog N fails to attach to /A/C/foo.
prog L attached to /A/D with ALLOW_OVERRIDE.
  Events under /A/D run prog L and can be overridden in /A/D/foo

/A still runs prog X
prog K attached to /A with ALLOW_OVERRIDE.
  /A now runs prog K while /A/B runs prog Y and /A/C runs prog M
prog J attached to /A with default.
  /A now runs prog J while /A/B runs prog Y.
  /A/B cannot be changed anymore (since parent disallows override),
  but can be cleared. After detach /A/B will run prog J.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---

Below are few proposals for future extensions and not definitive:
1.
we can extend the behavior with a chain of non-overridable like:
prog X attached to /A with default
prog Y attached to /A/B with default
The events scoped by /A/B will run program Y first and if it returns 1
the prog X will be run. For control app there will be an illusion
that it owns cgroup /A/B with single prog and detach from /A/B will delete
prog Y unambiguously.
While another control app that attached to /A also see its prog X running,
unless prog Y filtered it out, which means (from X point of view)
that event didn't happen.
Attaching two programs to /A is not allowed.
We would need to combine prog X and Y into array to avoid link list
traversal for performance reasons, but that's an implementation detail.

2.
we can add another flag to reverse this call order too.
Instead of calling the progs from child to parent, do parent to child.

3.
we can extend the api further by adding 'attach_priority' flag as:
prog X attach /A prio=20
prog Y attach /A prio=10
prog N attach /A/B prio=20
prog M attach /A/B prio=10
in /A/B the sequence of progs will be M -> N -> Y -> X

prog X attach /A prio=10 and prog Y attach /A prio=10 will be disallowed,
but attach with the same prio to different cgroups is ok.
If attached with prio, detach must specify prio as well.
Attach transitions:
allow_override -> disable_override/single_prog = ok
allow_override -> prio (multi prog at the same cgroup) = ok
disable_override/single_prog -> prio = ok (with respect to child/parent order)
prio -> allow_override = fail
prio -> disable_override/single_prog = fail

***
To summarize the key to not breaking abi is to preserve user space
expectations. Right now (without this patch) we have progs
overridable by any descendent. Which means that control plane
application has to expect that something may overwrite the program.
Hence any new flag will not break this expectation
(overridable == control plane cannot assume that its attached
programs will run in the hostile environment)
and that's the main reason why I don't think we need to change anything now
and hence this patch is an RFC.

Adding 'allow_override' flag and changing the default to
override disallowed is also fine from api extensibility point of view.
Since for 'override disallowed' case the control plane app will
be expecting that any processes will not override its program
in the descendent cgroups and it will run. This would have to be preserved.
That's why the future api extensions (like #1 above) would have to do
the program chaining to preserve 'disallow override' flag expectations.
So imo it's safer to keep overridable as it is today, since this flag
adds a bit more restrictions to the future extensions
comparing to everything overridable.

Andy,
does it all make sense?
Do you still insist on submitting this patch officially?
or you're ok keeping it overridable for now.
Note that in the future it will not be possible to change the default,
but 'disallow_override' flag can added at any time:
Change the default in this patch and it can be appied for 4.12 or later.
---
 include/linux/bpf-cgroup.h | 13 ++++++-------
 include/uapi/linux/bpf.h   |  7 +++++++
 kernel/bpf/cgroup.c        | 25 +++++++++++++++++++------
 kernel/bpf/syscall.c       | 20 ++++++++++++++------
 kernel/cgroup.c            |  9 +++++----
 5 files changed, 51 insertions(+), 23 deletions(-)

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
index a515f7b007c6..27cf8a3bc191 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -52,6 +52,7 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
 		e = rcu_dereference_protected(parent->bpf.effective[type],
 					      lockdep_is_held(&cgroup_mutex));
 		rcu_assign_pointer(cgrp->bpf.effective[type], e);
+		cgrp->bpf.disallow_override[type] = parent->bpf.disallow_override[type];
 	}
 }
 
@@ -82,13 +83,22 @@ void cgroup_bpf_inherit(struct cgroup *cgrp, struct cgroup *parent)
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
 	struct bpf_prog *old_prog, *effective;
 	struct cgroup_subsys_state *pos;
+	bool overridable = true;
+
+	if (parent)
+		overridable = !parent->bpf.disallow_override[type];
+
+	if (!overridable && prog)
+		return -EPERM;
+
+	if (prog)
+		overridable = new_overridable;
 
 	old_prog = xchg(cgrp->bpf.prog + type, prog);
 
@@ -101,11 +111,13 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
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
@@ -115,6 +127,7 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
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
 
-- 
2.8.0
