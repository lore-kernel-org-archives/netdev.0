From: Ed Schouten <ed@nuxi.nl>
Subject: [PATCH 2/3] Let open() on a UNIX socket return EOPNOTSUPP.
Date: Thu,  3 Mar 2016 12:23:01 +0100
Message-ID: <1457004183-24933-2-git-send-email-ed@nuxi.nl>
References: <1457004183-24933-1-git-send-email-ed@nuxi.nl>
Cc: Ed Schouten <ed@nuxi.nl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37823 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756502AbcCCLXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 06:23:12 -0500
Received: by mail-wm0-f51.google.com with SMTP id p65so27257793wmp.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 03:23:11 -0800 (PST)
In-Reply-To: <1457004183-24933-1-git-send-email-ed@nuxi.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The POSIX article on open() is slightly confusing that it states which
error code needs to be returned when opened on a stale FIFO, character
device or block device (ENXIO), but fails to explicitly mention which
code should be returned when trying to open a UNIX socket. This is only
mentioned in a different chapter of the standard (EOPNOTSUPP).

While discussing this matter with the Austin Group, it turns out most
other systems (BSDs, HP-UX, Solaris) do return EOPNOTSUPP. The open()
article has since been extended to require this. Let's go ahead and stay
in sync with the rest.

References:
http://pubs.opengroup.org/onlinepubs/9699919799/functions/open.html
http://austingroupbugs.net/view.php?id=943

Signed-off-by: Ed Schouten <ed@nuxi.nl>
---
 fs/inode.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/fs/inode.c b/fs/inode.c
index 69b8b52..6e63ca7 100644
--- a/fs/inode.c
+++ b/fs/inode.c
@@ -1911,8 +1911,15 @@ void __init inode_init(void)
 		INIT_HLIST_HEAD(&inode_hashtable[loop]);
 }
 
+static int no_open_sock(struct inode *inode, struct file *file)
+{
+	return -EOPNOTSUPP;
+}
+
 void init_special_inode(struct inode *inode, umode_t mode, dev_t rdev)
 {
+	static const struct file_operations sock_fops = {.open = no_open_sock};
+
 	inode->i_mode = mode;
 	if (S_ISCHR(mode)) {
 		inode->i_fop = &def_chr_fops;
@@ -1923,7 +1930,11 @@ void init_special_inode(struct inode *inode, umode_t mode, dev_t rdev)
 	} else if (S_ISFIFO(mode))
 		inode->i_fop = &pipefifo_fops;
 	else if (S_ISSOCK(mode))
-		;	/* leave it no_open_fops */
+		/*
+		 * open() on a socket needs to return EOPNOTSUPP,
+		 * whereas the default inode operations return ENXIO.
+		 */
+		inode->i_fop = &sock_fops;
 	else
 		printk(KERN_DEBUG "init_special_inode: bogus i_mode (%o) for"
 				  " inode %s:%lu\n", mode, inode->i_sb->s_id,
-- 
2.5.0
