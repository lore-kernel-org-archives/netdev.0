From: Daniel Mack <daniel@zonque.org>
Subject: [PATCH v9 3/6] bpf: add BPF_PROG_ATTACH and BPF_PROG_DETACH commands
Date: Wed, 23 Nov 2016 16:52:27 +0100
Message-ID: <1479916350-28462-4-git-send-email-daniel@zonque.org>
References: <1479916350-28462-1-git-send-email-daniel@zonque.org>
Cc: davem@davemloft.net, kafai@fb.com, fw@strlen.de,
        pablo@netfilter.org, harald@redhat.com, netdev@vger.kernel.org,
        sargun@sargun.me, cgroups@vger.kernel.org,
        Daniel Mack <daniel@zonque.org>
To: htejun@fb.com, daniel@iogearbox.net, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:49640 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935769AbcKWPwl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 23 Nov 2016 10:52:41 -0500
In-Reply-To: <1479916350-28462-1-git-send-email-daniel@zonque.org>
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
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/uapi/linux/bpf.h |  8 +++++
 kernel/bpf/syscall.c     | 81 ++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 1f3e6f1..f31b655 100644
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
@@ -150,6 +152,12 @@ union bpf_attr {
 		__aligned_u64	pathname;
 		__u32		bpf_fd;
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_ATTACH/DETACH commands */
+		__u32		target_fd;	/* container object to attach to */
+		__u32		attach_bpf_fd;	/* eBPF program to attach */
+		__u32		attach_type;
+	};
 } __attribute__((aligned(8)));
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 228f962..1814c01 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -822,6 +822,77 @@ static int bpf_obj_get(const union bpf_attr *attr)
 	return bpf_obj_get_user(u64_to_ptr(attr->pathname));
 }
 
+#ifdef CONFIG_CGROUP_BPF
+
+#define BPF_PROG_ATTACH_LAST_FIELD attach_type
+
+static int bpf_prog_attach(const union bpf_attr *attr)
+{
+	struct bpf_prog *prog;
+	struct cgroup *cgrp;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (CHECK_ATTR(BPF_PROG_ATTACH))
+		return -EINVAL;
+
+	switch (attr->attach_type) {
+	case BPF_CGROUP_INET_INGRESS:
+	case BPF_CGROUP_INET_EGRESS:
+		prog = bpf_prog_get_type(attr->attach_bpf_fd,
+					 BPF_PROG_TYPE_CGROUP_SKB);
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
+		break;
+
+	default:
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+#define BPF_PROG_DETACH_LAST_FIELD attach_type
+
+static int bpf_prog_detach(const union bpf_attr *attr)
+{
+	struct cgroup *cgrp;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	if (CHECK_ATTR(BPF_PROG_DETACH))
+		return -EINVAL;
+
+	switch (attr->attach_type) {
+	case BPF_CGROUP_INET_INGRESS:
+	case BPF_CGROUP_INET_EGRESS:
+		cgrp = cgroup_get_from_fd(attr->target_fd);
+		if (IS_ERR(cgrp))
+			return PTR_ERR(cgrp);
+
+		cgroup_bpf_update(cgrp, NULL, attr->attach_type);
+		cgroup_put(cgrp);
+		break;
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
@@ -888,6 +959,16 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
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
2.7.4
