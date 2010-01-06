From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 01/31] CAPI: Fix leaks in capifs_new_ncci
Date: Wed, 6 Jan 2010 11:43:20 +0100
Message-ID: <af79852df9c14a613e2d60879406909d2a50860f.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:58876 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab0AVXTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:19:19 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When something went wrong during capifs_new_ncci, the looked up dentry
was not properly released. Neither was the allocated inode. Refactor the
function to avoid leaks.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capifs.c |   25 ++++++++++++++++++-------
 1 files changed, 18 insertions(+), 7 deletions(-)

diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index 9f8f67b..dc68fcb 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -152,22 +152,33 @@ static struct dentry *get_node(int num)
 void capifs_new_ncci(unsigned int number, dev_t device)
 {
 	struct dentry *dentry;
-	struct inode *inode = new_inode(capifs_mnt->mnt_sb);
-	if (!inode)
-		return;
-	inode->i_ino = number+2;
+	struct inode *inode;
 
 	dentry = get_node(number);
+	if (IS_ERR(dentry))
+		goto unlock_out;
+
+	if (dentry->d_inode) {
+		dput(dentry);
+		goto unlock_out;
+	}
+
+	inode = new_inode(capifs_mnt->mnt_sb);
+	if (!inode) {
+		dput(dentry);
+		goto unlock_out;
+	}
 
 	/* config contents is protected by root's i_mutex */
 	inode->i_uid = config.setuid ? config.uid : current_fsuid();
 	inode->i_gid = config.setgid ? config.gid : current_fsgid();
 	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+	inode->i_ino = number + 2;
 	init_special_inode(inode, S_IFCHR|config.mode, device);
-	//inode->i_op = &capifs_file_inode_operations;
 
-	if (!IS_ERR(dentry) && !dentry->d_inode)
-		d_instantiate(dentry, inode);
+	d_instantiate(dentry, inode);
+
+unlock_out:
 	mutex_unlock(&capifs_root->d_inode->i_mutex);
 }
 
-- 
1.6.0.2

