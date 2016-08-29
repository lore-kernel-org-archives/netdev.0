From: Sargun Dhillon <sargun@sargun.me>
Subject: [net-next RFC v2 2/9] cgroups: move helper cgroup_parent to cgroup.h
Date: Mon, 29 Aug 2016 04:46:09 -0700
Message-ID: <20160829114608.GA20848@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cgroups@vger.kernel.org, linux-security-module@vger.kernel.org,
        daniel@iogearbox.net, ast@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36468 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932642AbcH2LqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 07:46:12 -0400
Received: by mail-it0-f46.google.com with SMTP id e63so97695692ith.1
        for <netdev@vger.kernel.org>; Mon, 29 Aug 2016 04:46:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch moves cgroup_parent into cgroup.h as a static inline helper
function so that others can use it. Although this pattern is easy
to implement, having it in one place simplifies the creation
of new cgroup controllers.

Signed-off-by: Sargun Dhillon <sargun@sargun.me>
---
 include/linux/cgroup.h | 16 ++++++++++++++++
 kernel/cgroup.c        |  9 ---------
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index a4414a1..b84eb6e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -571,6 +571,22 @@ static inline void pr_cont_cgroup_path(struct cgroup *cgrp)
 	pr_cont_kernfs_path(cgrp->kn);
 }
 
+/**
+ * cgroup_parent - Get the parent of a specific cgroup
+ * @cgrp: target cgroup
+ *
+ * If the cgroup does not have a parent (top level), then this function
+ * returns NULL. Otherwise, it'll return a pointer to te the parent cgroup.
+ */
+static inline struct cgroup *cgroup_parent(struct cgroup *cgrp)
+{
+	struct cgroup_subsys_state *parent_css = cgrp->self.parent;
+
+	if (parent_css)
+		return container_of(parent_css, struct cgroup, self);
+	return NULL;
+}
+
 #else /* !CONFIG_CGROUPS */
 
 struct cgroup_subsys_state;
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index d1c51b7..1ec1a4e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -358,15 +358,6 @@ static void cgroup_idr_remove(struct idr *idr, int id)
 	spin_unlock_bh(&cgroup_idr_lock);
 }
 
-static struct cgroup *cgroup_parent(struct cgroup *cgrp)
-{
-	struct cgroup_subsys_state *parent_css = cgrp->self.parent;
-
-	if (parent_css)
-		return container_of(parent_css, struct cgroup, self);
-	return NULL;
-}
-
 /* subsystems visibly enabled on a cgroup */
 static u16 cgroup_control(struct cgroup *cgrp)
 {
-- 
2.7.4
