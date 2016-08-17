From: Daniel Mack <daniel@zonque.org>
Subject: [RFC PATCH 3/5] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
Date: Wed, 17 Aug 2016 16:00:46 +0200
Message-ID: <1471442448-1248-4-git-send-email-daniel@zonque.org>
References: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
	pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
	Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47316 "EHLO mail.zonque.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752569AbcHQOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Aug 2016 10:11:15 -0400
In-Reply-To: <1471442448-1248-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the bpf(2) syscall by two new commands, BPF_PROG_ATTACH and
BPF_PROG_DETACH which allow attaching eBPF programs to a target.

On the API level, the target could be anything that has an fd in
userspace, hence the name of the field in union bpf_attr is called
'target_fd'.

When called with BPF_ATTACH_TYPE_CGROUP_{E,IN}GRESS, the target is
expected to be a valid file descriptor of a cgroup v2 directory. These
are the only use-cases implemented by this patch at this point, but
more can be added.

If a program of the given type already exists in the given cgroup,
the program is swapped atomically, so userspace does not have to drop
an existing program first before installing a new one, leaving a gap
in which no program is installed at all.

The current implementation walks the tree from the passed cgroup up
to the root. If there is any program of the given type installed in
any of the ancestors, the installation is rejected. This is because
programs subject to restrictions should have no way of escaping if
a higher-level cgroup has installed a program already. This restriction
can be revisited at some later point in time.

The API is guarded by CAP_NET_ADMIN right now, which is also something
that can be relaxed in the future.

The new bpf commands will return -EINVAL for !CONFIG_CGROUP_BPF.

Signed-off-by: Daniel Mack <daniel@zonque.org>
---
 include/uapi/linux/bpf.h |  14 +++++
 kernel/bpf/syscall.c     | 132 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 913b147..b8b8925 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -73,6 +73,8 @@ enum bpf_cmd {
 	BPF_PROG_LOAD,
 	BPF_OBJ_PIN,
 	BPF_OBJ_GET,
+	BPF_PROG_ATTACH,
+	BPF_PROG_DETACH,
 };
 
 enum bpf_map_type {
@@ -98,6 +100,11 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_CGROUP_SOCKET_FILTER,
 };
 
+enum bpf_attach_type {
+	BPF_ATTACH_TYPE_CGROUP_INGRESS,
+	BPF_ATTACH_TYPE_CGROUP_EGRESS,
+};
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -141,6 +148,13 @@ union bpf_attr {
 		__aligned_u64	pathname;
 		__u32		bpf_fd;
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
+		__u32		target_fd;	/* container object to attach to */
+		__u32		attach_bpf_fd;	/* eBPF program to attach */
+		__u32		attach_type;	/* BPF_ATTACH_TYPE_* */
+		__u64		attach_flags;
+	};
 } __attribute__((aligned(8)));
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..036465d 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -822,6 +822,132 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
 }
 
+static int bpf_prog_attach(const union bpf_attr *attr)
+{
+	bool is_ingress = false;
+	int err = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	/* Flags are unused for now */
+	if (attr->attach_flags != 0)
+		return -EINVAL;
+
+	switch (attr->attach_type) {
+
+#ifdef CONFIG_CGROUP_BPF
+	case BPF_ATTACH_TYPE_CGROUP_INGRESS:
+		is_ingress = true;
+		/* fall through */
+
+	case BPF_ATTACH_TYPE_CGROUP_EGRESS: {
+		struct bpf_prog *prog, *old_prog, **progp;
+		struct cgroup_subsys_state *pos;
+		struct cgroup *cgrp;
+
+		prog = bpf_prog_get_type(attr->attach_bpf_fd,
+					 BPF_PROG_TYPE_CGROUP_SOCKET_FILTER);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+
+		cgrp = cgroup_get_from_fd(attr->target_fd);
+		if (IS_ERR(cgrp)) {
+			err = PTR_ERR(cgrp);
+			bpf_prog_put(prog);
+			return err;
+		}
+
+		/* Reject installation of a program if any ancestor has one. */
+		for (pos = cgrp->self.parent; pos; pos = pos->parent) {
+			struct cgroup *parent;
+
+			css_get(pos);
+			parent = container_of(pos, struct cgroup, self);
+
+			if ((is_ingress  && parent->bpf_ingress) ||
+			    (!is_ingress && parent->bpf_egress))
+				err = -EEXIST;
+
+			css_put(pos);
+		}
+
+		if (err < 0) {
+			bpf_prog_put(prog);
+			return err;
+		}
+
+		progp = is_ingress ? &cgrp->bpf_ingress : &cgrp->bpf_egress;
+
+		rcu_read_lock();
+		old_prog = rcu_dereference(*progp);
+		rcu_assign_pointer(*progp, prog);
+
+		if (old_prog)
+			bpf_prog_put(old_prog);
+
+		rcu_read_unlock();
+		cgroup_put(cgrp);
+
+		break;
+	}
+#endif /* CONFIG_CGROUP_BPF */
+
+	default:
+		return -EINVAL;
+	}
+
+	return err;
+}
+
+static int bpf_prog_detach(const union bpf_attr *attr)
+{
+	int err = 0;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch (attr->attach_type) {
+
+#ifdef CONFIG_CGROUP_BPF
+	case BPF_ATTACH_TYPE_CGROUP_INGRESS:
+	case BPF_ATTACH_TYPE_CGROUP_EGRESS: {
+		struct bpf_prog *prog, **progp;
+		struct cgroup *cgrp;
+
+		cgrp = cgroup_get_from_fd(attr->target_fd);
+		if (IS_ERR(cgrp))
+			return PTR_ERR(cgrp);
+
+		progp = attr->attach_type == BPF_ATTACH_TYPE_CGROUP_INGRESS ?
+			&cgrp->bpf_ingress :
+			&cgrp->bpf_egress;
+
+		rcu_read_lock();
+		prog = rcu_dereference(*progp);
+
+		if (prog) {
+			rcu_assign_pointer(*progp, NULL);
+			bpf_prog_put(prog);
+		} else {
+			err = -ENOENT;
+		}
+
+		rcu_read_unlock();
+		cgroup_put(cgrp);
+
+		break;
+	}
+#endif /* CONFIG_CGROUP_BPF */
+
+	default:
+		err = -EINVAL;
+		break;
+	}
+
+	return err;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -888,6 +1014,12 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_OBJ_GET:
 		err = bpf_obj_get(&attr);
 		break;
+	case BPF_PROG_ATTACH:
+		err = bpf_prog_attach(&attr);
+		break;
+	case BPF_PROG_DETACH:
+		err = bpf_prog_detach(&attr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.5.5
