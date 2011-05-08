From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 075/115] sysctl: move removal from list out of start_unregistering
Date: Mon,  9 May 2011 00:39:27 +0200
Message-ID: <1304894407-32201-76-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Later on we'll switch form a global list protected by the sysctl_lock
spin lock to rwsem protected per-header lists.

At that point we'll need to hold the parent header's rwlock to remove
the header from the list, not the sysctl_lock spin lock.

As start_unregistering is called under the sysctl_lock, we move the
list removal out.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 kernel/sysctl.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 8dde087..a863b56 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1552,11 +1552,6 @@ static void start_unregistering(struct ctl_table_header *p)
 		/* anything non-NULL; we'll never dereference it */
 		p->unregistering = ERR_PTR(-EINVAL);
 	}
-	/*
-	 * do not remove from the list until nobody holds it; walking the
-	 * list in do_sysctl() relies on that.
-	 */
-	list_del_init(&p->ctl_entry);
 }
 
 void sysctl_proc_inode_get(struct ctl_table_header *head)
@@ -1949,6 +1944,13 @@ void unregister_sysctl_table(struct ctl_table_header * header)
 
 	spin_lock(&sysctl_lock);
 	start_unregistering(header);
+
+	/* after start_unregistering has finished no one holds a
+	 * ctl_use_refs or is able to acquire one => no one is going
+	 * to access internal fields of this object, so we can remove
+	 * it from the list and schedule it for deletion. */
+	list_del_init(&p->ctl_entry);
+
 	if (!--header->parent->ctl_header_refs) {
 		WARN_ON(1);
 		if (!header->parent->ctl_procfs_refs)
-- 
1.7.5.134.g1c08b
