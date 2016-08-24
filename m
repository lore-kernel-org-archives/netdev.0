From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v2 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
Date: Wed, 24 Aug 2016 22:24:20 +0200
Message-ID: <1472070263-29988-4-git-send-email-daniel@zonque.org>
References: <1472070263-29988-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:48472 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755376AbcHXUZI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 24 Aug 2016 16:25:08 -0400
In-Reply-To: <1472070263-29988-1-git-send-email-daniel@zonque.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend the bpf(2) syscall by two new commands, BPF_PROG_ATTACH and
BPF_PROG_DETACH which allow attaching and detaching eBPF programs
to a target.

On the API level, the target could be anything that has an fd in
userspace, hence the name of the field in union bpf_attr is called
'target_fd'.

When called with BPF_ATTACH_TYPE_CGROUP_INET_{E,IN}GRESS, the target is
expected to be a valid file descriptor of a cgroup v2 directory which
has the bpf controller enabled. These are the only use-cases
implemented by this patch at this point, but more can be added.

If a program of the given type already exists in the given cgroup,
the program is swapped automically, so userspace does not have to drop
an existing program first before installing a new one, which would
otherwise leave a gap in which no program is attached.

For more information on the propagation logic to subcgroups, please
refer to the bpf cgroup controller implementation.

The API is guarded by CAP_NET_ADMIN.

Signed-off-by: Daniel Mack <daniel@zonque.org>
syscall
---
 include/uapi/linux/bpf.h |  9 ++++++
 kernel/bpf/syscall.c     | 79 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 88 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1d5db42..4cc2dcf 100644
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
@@ -147,6 +149,13 @@ union bpf_attr {
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
index 228f962..208cba2 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -822,6 +822,75 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
 }
 
+#ifdef CONFIG_CGROUP_BPF
+static int bpf_prog_attach(const union bpf_attr *attr)
+{
+	struct bpf_prog *prog;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	/* Flags are unused for now */
+	if (attr->attach_flags != 0)
+		return -EINVAL;
+
+	switch (attr->attach_type) {
+	case BPF_ATTACH_TYPE_CGROUP_INET_INGRESS:
+	case BPF_ATTACH_TYPE_CGROUP_INET_EGRESS: {
+		struct cgroup *cgrp;
+
+		prog = bpf_prog_get_type(attr->attach_bpf_fd,
+					 BPF_PROG_TYPE_CGROUP_SOCKET_FILTER);
+		if (IS_ERR(prog))
+			return PTR_ERR(prog);
+
+		cgrp = cgroup_get_from_fd(attr->target_fd);
+		if (IS_ERR(cgrp)) {
+			bpf_prog_put(prog);
+			return PTR_ERR(cgrp);
+		}
+
+		cgroup_bpf_update(cgrp, prog, attr->attach_type);
+		cgroup_put(cgrp);
+
+		break;
+	}
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int bpf_prog_detach(const union bpf_attr *attr)
+{
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	switch (attr->attach_type) {
+	case BPF_ATTACH_TYPE_CGROUP_INET_INGRESS:
+	case BPF_ATTACH_TYPE_CGROUP_INET_EGRESS: {
+		struct cgroup *cgrp;
+
+		cgrp = cgroup_get_from_fd(attr->target_fd);
+		if (IS_ERR(cgrp))
+			return PTR_ERR(cgrp);
+
+		cgroup_bpf_update(cgrp, NULL, attr->attach_type);
+		cgroup_put(cgrp);
+
+		break;
+	}
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+#endif /* CONFIG_CGROUP_BPF */
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -888,6 +957,16 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_OBJ_GET:
 		err = bpf_obj_get(&attr);
 		break;
+
+#ifdef CONFIG_CGROUP_BPF
+	case BPF_PROG_ATTACH:
+		err = bpf_prog_attach(&attr);
+		break;
+	case BPF_PROG_DETACH:
+		err = bpf_prog_detach(&attr);
+		break;
+#endif
+
 	default:
 		err = -EINVAL;
 		break;
-- 
2.5.5
