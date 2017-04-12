From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch] nsfs: mark dentry with DCACHE_RCUACCESS
Date: Wed, 12 Apr 2017 13:55:28 -0700
Message-ID: <1492030528-3919-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:32963 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755716AbdDLUzh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 16:55:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id c198so7119983pfc.0
        for <netdev@vger.kernel.org>; Wed, 12 Apr 2017 13:55:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey reported a use-after-free in __ns_get_path():

 spin_lock include/linux/spinlock.h:299 [inline]
 lockref_get_not_dead+0x19/0x80 lib/lockref.c:179
 __ns_get_path+0x197/0x860 fs/nsfs.c:66
 open_related_ns+0xda/0x200 fs/nsfs.c:143
 sock_ioctl+0x39d/0x440 net/socket.c:1001
 vfs_ioctl fs/ioctl.c:45 [inline]
 do_vfs_ioctl+0x1bf/0x1780 fs/ioctl.c:685
 SYSC_ioctl fs/ioctl.c:700 [inline]
 SyS_ioctl+0x8f/0xc0 fs/ioctl.c:691

We are under rcu read lock protection at that point:

        rcu_read_lock();
        d = atomic_long_read(&ns->stashed);
        if (!d)
                goto slow;
        dentry = (struct dentry *)d;
        if (!lockref_get_not_dead(&dentry->d_lockref))
                goto slow;
        rcu_read_unlock();

but don't use a proper RCU API on the free path, therefore
a parallel __d_free() could free it at the same time.
We need to mark the stashed dentry with DCACHE_RCUACCESS so
that __d_free() will be called after all readers leave RCU.

Fixes: e149ed2b805f ("take the targets of /proc/*/ns/* symlinks to separate fs")
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Reported-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 fs/nsfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nsfs.c b/fs/nsfs.c
index 1656843..323f492 100644
--- a/fs/nsfs.c
+++ b/fs/nsfs.c
@@ -91,6 +91,7 @@ static void *__ns_get_path(struct path *path, struct ns_common *ns)
 		return ERR_PTR(-ENOMEM);
 	}
 	d_instantiate(dentry, inode);
+	dentry->d_flags |= DCACHE_RCUACCESS;
 	dentry->d_fsdata = (void *)ns->ops;
 	d = atomic_long_cmpxchg(&ns->stashed, 0, (unsigned long)dentry);
 	if (d) {
-- 
2.5.5
