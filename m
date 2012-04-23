From: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: [PATCH v2 2/5] blkcg: protect blkcg->policy_list
Date: Mon, 23 Apr 2012 16:37:44 -0300
Message-ID: <1335209867-1831-3-git-send-email-glommer@parallels.com>
References: <1335209867-1831-1-git-send-email-glommer@parallels.com>
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>,
	Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1335209867-1831-1-git-send-email-glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

policy_list walks are protected with blkcg->lock everywhere else in the code.
In destroy(), they are not. Because destroy is usually protected with the
cgroup_mutex(), this is usually not a problem. But it would be a lot better
not to assume this.

Signed-off-by: Glauber Costa <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
---
 block/blk-cgroup.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/block/blk-cgroup.c b/block/blk-cgroup.c
index 126c341..35fd701 100644
--- a/block/blk-cgroup.c
+++ b/block/blk-cgroup.c
@@ -1557,10 +1557,12 @@ static void blkiocg_destroy(struct cgroup *cgroup)
 		spin_unlock(&blkio_list_lock);
 	} while (1);
 
+	spin_lock_irqsave(&blkcg->lock, flags);
 	list_for_each_entry_safe(pn, pntmp, &blkcg->policy_list, node) {
 		blkio_policy_delete_node(pn);
 		kfree(pn);
 	}
+	spin_unlock_irqrestore(&blkcg->lock, flags);
 
 	free_css_id(&blkio_subsys, &blkcg->css);
 	rcu_read_unlock();
-- 
1.7.7.6
