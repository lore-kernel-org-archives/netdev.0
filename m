From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/7] netcls_cgroup: move config inheritance to ->css_online()
	and remove .broken_hierarchy marking
Date: Tue, 20 Nov 2012 00:30:05 -0800
Message-ID: <1353400211-5182-2-git-send-email-tj@kernel.org>
References: <1353400211-5182-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353400211-5182-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

It turns out that we'll have to live with attributes which are
inherited at cgroup creation time but not affected by further updates
to the parent afterwards - such attributes are already in wide use
e.g. for cpuset.

So, there's nothing to do for netcls_cgroup for hierarchy support.
Its current behavior - inherit only during creation - is good enough.

Move config inheriting from ->css_alloc() to ->css_online() for
consistency, which doesn't change behavior at all, and remove
.broken_hierarchy marking.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/sched/cls_cgroup.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 8cdc18e..31f06b6 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -41,11 +41,15 @@ static struct cgroup_subsys_state *cgrp_css_alloc(struct cgroup *cgrp)
 	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
 	if (!cs)
 		return ERR_PTR(-ENOMEM);
+	return &cs->css;
+}
 
+static int cgrp_css_online(struct cgroup *cgrp)
+{
 	if (cgrp->parent)
-		cs->classid = cgrp_cls_state(cgrp->parent)->classid;
-
-	return &cs->css;
+		cgrp_cls_state(cgrp)->classid =
+			cgrp_cls_state(cgrp->parent)->classid;
+	return 0;
 }
 
 static void cgrp_css_free(struct cgroup *cgrp)
@@ -76,19 +80,11 @@ static struct cftype ss_files[] = {
 struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.css_alloc	= cgrp_css_alloc,
+	.css_online	= cgrp_css_online,
 	.css_free	= cgrp_css_free,
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
-
-	/*
-	 * While net_cls cgroup has the rudimentary hierarchy support of
-	 * inheriting the parent's classid on cgroup creation, it doesn't
-	 * properly propagates config changes in ancestors to their
-	 * descendents.  A child should follow the parent's configuration
-	 * but be allowed to override it.  Fix it and remove the following.
-	 */
-	.broken_hierarchy = true,
 };
 
 struct cls_cgroup_head {
-- 
1.7.11.7
