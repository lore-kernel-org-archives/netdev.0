From: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH -next 1/4] cgroup: Add cgroup_get_from_fd
Date: Tue, 21 Jun 2016 17:23:19 -0700
Message-ID: <1466555002-1316296-2-git-send-email-kafai@fb.com>
References: <1466555002-1316296-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <kernel-team-b10kYP2dOMg@public.gmane.org>
To: <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466555002-1316296-1-git-send-email-kafai-b10kYP2dOMg@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a helper function to get a cgroup2 from a fd.  It will be
stored in a bpf array (BPF_MAP_TYPE_CGROUP_ARRAY) which will
be introduced in the later patch.

Signed-off-by: Martin KaFai Lau <kafai-b10kYP2dOMg@public.gmane.org>
Cc: Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>
Cc: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 include/linux/cgroup.h |  1 +
 kernel/cgroup.c        | 26 ++++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a20320c..984f73b 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -87,6 +87,7 @@ struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 						       struct cgroup_subsys *ss);
 
 struct cgroup *cgroup_get_from_path(const char *path);
+struct cgroup *cgroup_get_from_fd(int fd);
 
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 86cb5c6..616c751 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -62,6 +62,7 @@
 #include <linux/proc_ns.h>
 #include <linux/nsproxy.h>
 #include <linux/proc_ns.h>
+#include <linux/file.h>
 #include <net/sock.h>
 
 /*
@@ -6205,6 +6206,31 @@ struct cgroup *cgroup_get_from_path(const char *path)
 }
 EXPORT_SYMBOL_GPL(cgroup_get_from_path);
 
+struct cgroup *cgroup_get_from_fd(int fd)
+{
+	struct cgroup_subsys_state *css;
+	struct cgroup *cgrp;
+	struct file *f;
+
+	f = fget_raw(fd);
+	if (!f)
+		return NULL;
+
+	css = css_tryget_online_from_dir(f->f_path.dentry, NULL);
+	fput(f);
+	if (IS_ERR(css))
+		return ERR_CAST(css);
+
+	cgrp = css->cgroup;
+	if (!cgroup_on_dfl(cgrp)) {
+		cgroup_put(cgrp);
+		return ERR_PTR(-EINVAL);
+	}
+
+	return cgrp;
+}
+EXPORT_SYMBOL_GPL(cgroup_get_from_fd);
+
 /*
  * sock->sk_cgrp_data handling.  For more info, see sock_cgroup_data
  * definition in cgroup-defs.h.
-- 
2.5.1
