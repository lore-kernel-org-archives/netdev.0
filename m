From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v3 17/22] cgroup: Add access check for cgroup_get_from_fd()
Date: Wed, 14 Sep 2016 09:24:10 +0200
Message-ID: <20160914072415.26021-18-mic@digikod.net>
References: <20160914072415.26021-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh.infomaniak.ch ([128.65.195.4]:41893 "EHLO
        smtp-sh.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759721AbcINH0J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 03:26:09 -0400
In-Reply-To: <20160914072415.26021-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add security access check for cgroup backed FD. The "cgroup.procs" file
of the corresponding cgroup must be readable to identify the cgroup, and
writable to prove that the current process can manage this cgroup (e.g.
through delegation). This is similar to the check done by
cgroup_procs_write_permission().

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Daniel Mack <daniel@zonque.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/cgroup.h |  2 +-
 kernel/bpf/arraymap.c  |  2 +-
 kernel/bpf/syscall.c   |  6 +++---
 kernel/cgroup.c        | 16 +++++++++++++++-
 4 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index c4688742ddc4..5767d471e292 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -87,7 +87,7 @@ struct cgroup_subsys_state *css_tryget_online_from_dir(struct dentry *dentry,
 						       struct cgroup_subsys *ss);
 
 struct cgroup *cgroup_get_from_path(const char *path);
-struct cgroup *cgroup_get_from_fd(int fd);
+struct cgroup *cgroup_get_from_fd(int fd, int access_mask);
 
 int cgroup_attach_task_all(struct task_struct *from, struct task_struct *);
 int cgroup_transfer_tasks(struct cgroup *to, struct cgroup *from);
diff --git a/kernel/bpf/arraymap.c b/kernel/bpf/arraymap.c
index edaab4c87292..1d4de8e0ab13 100644
--- a/kernel/bpf/arraymap.c
+++ b/kernel/bpf/arraymap.c
@@ -552,7 +552,7 @@ static void *cgroup_fd_array_get_ptr(struct bpf_map *map,
 				     struct file *map_file /* not used */,
 				     int fd)
 {
-	return cgroup_get_from_fd(fd);
+	return cgroup_get_from_fd(fd, MAY_READ);
 }
 
 static void cgroup_fd_array_put_ptr(void *ptr)
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index e9c5add327e6..f90225dbbb59 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -17,6 +17,7 @@
 #include <linux/license.h>
 #include <linux/filter.h>
 #include <linux/version.h>
+#include <linux/fs.h>
 
 DEFINE_PER_CPU(int, bpf_prog_active);
 
@@ -863,7 +864,7 @@ static int bpf_prog_attach(const union bpf_attr *attr)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	cgrp = cgroup_get_from_fd(attr->target_fd);
+	cgrp = cgroup_get_from_fd(attr->target_fd, MAY_WRITE);
 	if (IS_ERR(cgrp)) {
 		bpf_prog_put(prog);
 		return PTR_ERR(cgrp);
@@ -891,10 +892,9 @@ static int bpf_prog_detach(const union bpf_attr *attr)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		cgrp = cgroup_get_from_fd(attr->target_fd);
+		cgrp = cgroup_get_from_fd(attr->target_fd, MAY_WRITE);
 		if (IS_ERR(cgrp))
 			return PTR_ERR(cgrp);
-
 		result = cgroup_bpf_update(cgrp, NULL, attr->attach_type);
 		cgroup_put(cgrp);
 		break;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 48b650a640a9..3bbaf3f02ed2 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -6241,17 +6241,20 @@ EXPORT_SYMBOL_GPL(cgroup_get_from_path);
 /**
  * cgroup_get_from_fd - get a cgroup pointer from a fd
  * @fd: fd obtained by open(cgroup2_dir)
+ * @access_mask: contains the permission mask
  *
  * Find the cgroup from a fd which should be obtained
  * by opening a cgroup directory.  Returns a pointer to the
  * cgroup on success. ERR_PTR is returned if the cgroup
  * cannot be found.
  */
-struct cgroup *cgroup_get_from_fd(int fd)
+struct cgroup *cgroup_get_from_fd(int fd, int access_mask)
 {
 	struct cgroup_subsys_state *css;
 	struct cgroup *cgrp;
 	struct file *f;
+	struct inode *inode;
+	int ret;
 
 	f = fget_raw(fd);
 	if (!f)
@@ -6268,6 +6271,17 @@ struct cgroup *cgroup_get_from_fd(int fd)
 		return ERR_PTR(-EBADF);
 	}
 
+	ret = -ENOMEM;
+	inode = kernfs_get_inode(f->f_path.dentry->d_sb, cgrp->procs_file.kn);
+	if (inode) {
+		ret = inode_permission(inode, access_mask);
+		iput(inode);
+	}
+	if (ret) {
+		cgroup_put(cgrp);
+		return ERR_PTR(ret);
+	}
+
 	return cgrp;
 }
 EXPORT_SYMBOL_GPL(cgroup_get_from_fd);
-- 
2.9.3
