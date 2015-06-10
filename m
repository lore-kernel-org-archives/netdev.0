From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 14/19] bna: use memdup_user to copy userspace buffers
Date: Wed, 10 Jun 2015 18:43:20 +0200
Message-ID: <1433954605-22813-15-git-send-email-ivecera@redhat.com>
References: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50671 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965524AbbFJQnO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:43:14 -0400
In-Reply-To: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch converts kzalloc->copy_from_user sequence to memdup_user. There
is also one useless assignment of NULL to bnad->regdata as it is followed
by assignment of kzalloc output.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c | 27 ++++++++-----------------
 1 file changed, 8 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
index 72c8955..ad7af5c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_debugfs.c
@@ -321,15 +321,10 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 	unsigned long flags;
 	void *kern_buf;
 
-	/* Allocate memory to store the user space buf */
-	kern_buf = kzalloc(nbytes, GFP_KERNEL);
-	if (!kern_buf)
-		return -ENOMEM;
-
-	if (copy_from_user(kern_buf, (void  __user *)buf, nbytes)) {
-		kfree(kern_buf);
-		return -ENOMEM;
-	}
+	/* Copy the user space buf */
+	kern_buf = memdup_user(buf, nbytes);
+	if (IS_ERR(kern_buf))
+		return PTR_ERR(kern_buf);
 
 	rc = sscanf(kern_buf, "%x:%x", &addr, &len);
 	if (rc < 2) {
@@ -341,7 +336,6 @@ bnad_debugfs_write_regrd(struct file *file, const char __user *buf,
 
 	kfree(kern_buf);
 	kfree(bnad->regdata);
-	bnad->regdata = NULL;
 	bnad->reglen = 0;
 
 	bnad->regdata = kzalloc(len << 2, GFP_KERNEL);
@@ -388,15 +382,10 @@ bnad_debugfs_write_regwr(struct file *file, const char __user *buf,
 	unsigned long flags;
 	void *kern_buf;
 
-	/* Allocate memory to store the user space buf */
-	kern_buf = kzalloc(nbytes, GFP_KERNEL);
-	if (!kern_buf)
-		return -ENOMEM;
-
-	if (copy_from_user(kern_buf, (void  __user *)buf, nbytes)) {
-		kfree(kern_buf);
-		return -ENOMEM;
-	}
+	/* Copy the user space buf */
+	kern_buf = memdup_user(buf, nbytes);
+	if (IS_ERR(kern_buf))
+		return PTR_ERR(kern_buf);
 
 	rc = sscanf(kern_buf, "%x:%x", &addr, &val);
 	if (rc < 2) {
-- 
2.3.6
