From: Nina Schiff <ninasc-b10kYP2dOMg@public.gmane.org>
Subject: [PATCH RESEND] cgroups: Allow dynamically changing net_classid
Date: Fri, 20 Nov 2015 12:31:39 -0800
Message-ID: <1448051499-1885574-1-git-send-email-ninasc@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>,
	<cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<kernel-team-b10kYP2dOMg@public.gmane.org>, <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Nina Schiff <ninasc-b10kYP2dOMg@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	<nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The classid of a process is changed either when a process is moved to
or from a cgroup or when the net_cls.classid file is updated.
Previously net_cls only supported propogating these changes to the
cgroup's related sockets when a process was added or removed from the
cgroup. This means it was neccessary to remove and re-add all processes
to a cgroup in order to update its classid. This change introduces
support for doing this dynamically - i.e. when the value is changed in
the net_cls_classid file, this will also trigger an update to the
classid associated with all sockets controlled by the cgroup.
This mimics the behaviour of other cgroup subsystems.
net_prio circumvents this issue by storing an index into a table with
each socket (and so any updates to the table, don't require updating
the value associated with the socket). net_cls, however, passes the
socket the classid directly, and so this additional step is needed.

Signed-off-by: Nina Schiff <ninasc-b10kYP2dOMg@public.gmane.org>
---
Concatented two email addresses by mistake, so resending

 net/core/netclassid_cgroup.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/core/netclassid_cgroup.c b/net/core/netclassid_cgroup.c
index 6441f47..2e4df84 100644
--- a/net/core/netclassid_cgroup.c
+++ b/net/core/netclassid_cgroup.c
@@ -56,7 +56,7 @@ static void cgrp_css_free(struct cgroup_subsys_state *css)
 	kfree(css_cls_state(css));
 }
 
-static int update_classid(const void *v, struct file *file, unsigned n)
+static int update_classid_sock(const void *v, struct file *file, unsigned n)
 {
 	int err;
 	struct socket *sock = sock_from_file(file, &err);
@@ -67,18 +67,25 @@ static int update_classid(const void *v, struct file *file, unsigned n)
 	return 0;
 }
 
-static void cgrp_attach(struct cgroup_subsys_state *css,
-			struct cgroup_taskset *tset)
+static void update_classid(struct cgroup_subsys_state *css, void *v)
 {
-	struct cgroup_cls_state *cs = css_cls_state(css);
-	void *v = (void *)(unsigned long)cs->classid;
+	struct css_task_iter it;
 	struct task_struct *p;
 
-	cgroup_taskset_for_each(p, tset) {
+	css_task_iter_start(css, &it);
+	while ((p = css_task_iter_next(&it))) {
 		task_lock(p);
-		iterate_fd(p->files, 0, update_classid, v);
+		iterate_fd(p->files, 0, update_classid_sock, v);
 		task_unlock(p);
 	}
+	css_task_iter_end(&it);
+}
+
+static void cgrp_attach(struct cgroup_subsys_state *css,
+			struct cgroup_taskset *tset)
+{
+	update_classid(css,
+		       (void *)(unsigned long)css_cls_state(css)->classid);
 }
 
 static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
@@ -89,8 +96,11 @@ static u64 read_classid(struct cgroup_subsys_state *css, struct cftype *cft)
 static int write_classid(struct cgroup_subsys_state *css, struct cftype *cft,
 			 u64 value)
 {
-	css_cls_state(css)->classid = (u32) value;
+	struct cgroup_cls_state *cs = css_cls_state(css);
+
+	cs->classid = (u32)value;
 
+	update_classid(css, (void *)(unsigned long)cs->classid);
 	return 0;
 }
 
-- 
2.4.6
