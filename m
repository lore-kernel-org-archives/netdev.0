From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC PATCH net-next 2/2] bpf: Add support to retrieve program attached to a cgroup
Date: Fri,  3 Feb 2017 12:38:23 -0800
Message-ID: <1486154303-32278-3-git-send-email-dsa@cumulusnetworks.com>
References: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36284 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdBCUib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 15:38:31 -0500
Received: by mail-pg0-f49.google.com with SMTP id v184so9316876pgv.3
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 12:38:31 -0800 (PST)
In-Reply-To: <1486154303-32278-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to ebpf to retrieve a program attached to a cgroup.
This is done using a new bpf_cmd, BPF_PROG_GET_ATTACH, and
associated struct in bpf_attr.

This allows a program to verify a bpf filter attached to a
cgroup as well as verify the lack of a filter - which can be
just as relevant when debugging a problem.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/linux/bpf-cgroup.h |  7 ++++++
 include/uapi/linux/bpf.h   |  9 +++++++
 kernel/bpf/cgroup.c        | 31 +++++++++++++++++++++++
 kernel/bpf/syscall.c       | 61 ++++++++++++++++++++++++++++++++++++++++++++++
 kernel/cgroup.c            | 12 +++++++++
 5 files changed, 120 insertions(+)

diff --git a/include/linux/bpf-cgroup.h b/include/linux/bpf-cgroup.h
index 92bc89ae7e20..5a9fde760332 100644
--- a/include/linux/bpf-cgroup.h
+++ b/include/linux/bpf-cgroup.h
@@ -36,6 +36,13 @@ void cgroup_bpf_update(struct cgroup *cgrp,
 		       struct bpf_prog *prog,
 		       enum bpf_attach_type type);
 
+struct bpf_prog *__cgroup_bpf_get(struct cgroup *cgrp,
+				  enum bpf_attach_type type);
+
+/* Wrapper for __cgroup_bpf_get() protected by cgroup_mutex */
+struct bpf_prog *cgroup_bpf_get(struct cgroup *cgrp,
+				enum bpf_attach_type type);
+
 int __cgroup_bpf_run_filter_skb(struct sock *sk,
 				struct sk_buff *skb,
 				enum bpf_attach_type type);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e07fd5a324e6..f321b96459e2 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -81,6 +81,7 @@ enum bpf_cmd {
 	BPF_OBJ_GET,
 	BPF_PROG_ATTACH,
 	BPF_PROG_DETACH,
+	BPF_PROG_GET_ATTACH,
 };
 
 enum bpf_map_type {
@@ -179,6 +180,14 @@ union bpf_attr {
 		__u32		attach_bpf_fd;	/* eBPF program to attach */
 		__u32		attach_type;
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_ATTACH_GET command */
+		__u32		target_get_fd;	/* container object attached to */
+		__u32		attach_type_get;
+		__u32		prog_type_get;	/* one of enum bpf_prog_type */
+		__u32		insn_cnt_get;
+		__aligned_u64	insns_get;
+	};
 } __attribute__((aligned(8)));
 
 /* BPF helper function descriptions:
diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
index a515f7b007c6..7d9f12606939 100644
--- a/kernel/bpf/cgroup.c
+++ b/kernel/bpf/cgroup.c
@@ -117,6 +117,37 @@ void __cgroup_bpf_update(struct cgroup *cgrp,
 	}
 }
 
+struct bpf_prog *__cgroup_bpf_get(struct cgroup *cgrp,
+				  enum bpf_attach_type type)
+{
+	struct bpf_prog *cgrp_prog, *prog;
+	struct bpf_insn *insns;
+	u32 len;
+
+	cgrp_prog = rcu_dereference_protected(cgrp->bpf.effective[type],
+					      lockdep_is_held(&cgroup_mutex));
+	if (!cgrp_prog)
+		return NULL;
+
+	if (cgrp_prog->orig_prog) {
+		len = cgrp_prog->orig_prog->len;
+		insns = cgrp_prog->orig_prog->insn;
+	} else {
+		len = cgrp_prog->len;
+		insns = cgrp_prog->insnsi;
+	}
+
+	prog = bpf_prog_alloc(bpf_prog_size(len), GFP_USER);
+	if (!prog)
+		return ERR_PTR(-ENOMEM);
+
+	prog->len = len;
+	memcpy(prog->insns, insns, bpf_prog_insn_size(prog));
+	prog->type = cgrp_prog->type;
+
+	return prog;
+}
+
 /**
  * __cgroup_bpf_run_filter_skb() - Run a program for packet filtering
  * @sk: The socken sending or receiving traffic
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 95e640a3ed99..ad211e5ccaae 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1043,6 +1043,64 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 
 	return 0;
 }
+
+#define BPF_PROG_GET_ATTACH_LAST_FIELD insns_get
+
+static int bpf_prog_get_attach(union bpf_attr *attr,
+			       union bpf_attr __user *uattr)
+{
+	struct bpf_prog *prog;
+	struct cgroup *cgrp;
+	u32 ptype;
+	int err;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (CHECK_ATTR(BPF_PROG_GET_ATTACH))
+		return -EINVAL;
+
+	if (attr->attach_type_get >= MAX_BPF_ATTACH_TYPE)
+		return -EINVAL;
+
+	cgrp = cgroup_get_from_fd(attr->target_get_fd);
+	if (IS_ERR(cgrp))
+		return PTR_ERR(cgrp);
+
+	prog = cgroup_bpf_get(cgrp, attr->attach_type_get);
+	cgroup_put(cgrp);
+
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	/* no program means nothing to copy */
+	if (!prog) {
+		u32 zero = 0;
+
+		if (copy_to_user(&uattr->insn_cnt_get, &zero, sizeof(u32)) ||
+		    copy_to_user(&uattr->prog_type_get, &zero, sizeof(u32)))
+			return -EFAULT;
+
+		return 0;
+	}
+
+	err = -E2BIG;
+	if (attr->insn_cnt_get < prog->len)
+		goto out;
+
+	err = 0;
+	ptype = prog->type;
+	if (copy_to_user(&uattr->insn_cnt_get, &prog->len, sizeof(u32)) ||
+	    copy_to_user(&uattr->prog_type_get, &ptype, sizeof(u32))    ||
+	    copy_to_user(u64_to_user_ptr(attr->insns_get), prog->insns,
+			 bpf_prog_insn_size(prog))) {
+		err = -EFAULT;
+	}
+out:
+	bpf_prog_free(prog);
+	return err;
+}
+
 #endif /* CONFIG_CGROUP_BPF */
 
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
@@ -1119,6 +1177,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_DETACH:
 		err = bpf_prog_detach(&attr);
 		break;
+	case BPF_PROG_GET_ATTACH:
+		err = bpf_prog_get_attach(&attr, uattr);
+		break;
 #endif
 
 	default:
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2ee9ec3051b2..860f639a405e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6511,6 +6511,18 @@ void cgroup_bpf_update(struct cgroup *cgrp,
 	__cgroup_bpf_update(cgrp, parent, prog, type);
 	mutex_unlock(&cgroup_mutex);
 }
+
+struct bpf_prog *cgroup_bpf_get(struct cgroup *cgrp,
+				enum bpf_attach_type type)
+{
+	struct bpf_prog *prog;
+
+	mutex_lock(&cgroup_mutex);
+	prog = __cgroup_bpf_get(cgrp, type);
+	mutex_unlock(&cgroup_mutex);
+
+	return prog;
+}
 #endif /* CONFIG_CGROUP_BPF */
 
 #ifdef CONFIG_CGROUP_DEBUG
-- 
2.1.4
