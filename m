From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 02/31] CAPI: Sanitize capifs API
Date: Wed, 6 Jan 2010 14:38:52 +0100
Message-ID: <ebbdbacd9d3ddbbd7c11ce9b3b064668a876a8f4.1264201406.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755739Ab0AVXUm@vger.kernel.org>
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Instead of looking up the dentry of an NCCI node again in
capifs_free_ncci pass the pointer via the capifs user.

This patch also reduces the #ifdef mess in capi.c a bit as far as capifs
was causing it.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c   |   14 +++++-------
 drivers/isdn/capi/capifs.c |   50 +++++++++++++++++++++++++------------------
 drivers/isdn/capi/capifs.h |   21 ++++++++++++++++-
 3 files changed, 54 insertions(+), 31 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 65bf91e..58504ef 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -41,9 +41,8 @@
 #include <linux/moduleparam.h>
 #include <linux/isdn/capiutil.h>
 #include <linux/isdn/capicmd.h>
-#if defined(CONFIG_ISDN_CAPI_CAPIFS) || defined(CONFIG_ISDN_CAPI_CAPIFS_MODULE)
+
 #include "capifs.h"
-#endif
 
 static char *revision = "$Revision: 1.1.2.7 $";
 
@@ -95,6 +94,7 @@ struct capiminor {
 	struct list_head list;
 	struct capincci  *nccip;
 	unsigned int      minor;
+	struct dentry *capifs_dentry;
 
 	struct capi20_appl *ap;
 	u32		 ncci;
@@ -327,9 +327,9 @@ static struct capincci *capincci_alloc(struct capidev *cdev, u32 ncci)
 #ifdef _DEBUG_REFCOUNT
 		printk(KERN_DEBUG "set mp->nccipn");
 #endif
-#if defined(CONFIG_ISDN_CAPI_CAPIFS) || defined(CONFIG_ISDN_CAPI_CAPIFS_MODULE)
-		capifs_new_ncci(mp->minor, MKDEV(capi_ttymajor, mp->minor));
-#endif
+		mp->capifs_dentry =
+			capifs_new_ncci(mp->minor,
+					MKDEV(capi_ttymajor, mp->minor));
 	}
 #endif /* CONFIG_ISDN_CAPI_MIDDLEWARE */
 	for (pp=&cdev->nccis; *pp; pp = &(*pp)->next)
@@ -352,9 +352,7 @@ static void capincci_free(struct capidev *cdev, u32 ncci)
 			*pp = (*pp)->next;
 #ifdef CONFIG_ISDN_CAPI_MIDDLEWARE
 			if ((mp = np->minorp) != NULL) {
-#if defined(CONFIG_ISDN_CAPI_CAPIFS) || defined(CONFIG_ISDN_CAPI_CAPIFS_MODULE)
-				capifs_free_ncci(mp->minor);
-#endif
+				capifs_free_ncci(mp->capifs_dentry);
 				if (mp->tty) {
 					mp->nccip = NULL;
 #ifdef _DEBUG_REFCOUNT
diff --git a/drivers/isdn/capi/capifs.c b/drivers/isdn/capi/capifs.c
index dc68fcb..91aafad 100644
--- a/drivers/isdn/capi/capifs.c
+++ b/drivers/isdn/capi/capifs.c
@@ -141,31 +141,32 @@ static struct file_system_type capifs_fs_type = {
 	.kill_sb	= kill_anon_super,
 };
 
-static struct dentry *get_node(int num)
-{
-	char s[10];
-	struct dentry *root = capifs_root;
-	mutex_lock(&root->d_inode->i_mutex);
-	return lookup_one_len(s, root, sprintf(s, "%d", num));
-}
-
-void capifs_new_ncci(unsigned int number, dev_t device)
+struct dentry *capifs_new_ncci(unsigned int number, dev_t device)
 {
 	struct dentry *dentry;
 	struct inode *inode;
+	char name[10];
+	int namelen;
 
-	dentry = get_node(number);
-	if (IS_ERR(dentry))
+	mutex_lock(&capifs_root->d_inode->i_mutex);
+
+	namelen = sprintf(name, "%d", number);
+	dentry = lookup_one_len(name, capifs_root, namelen);
+	if (IS_ERR(dentry)) {
+		dentry = NULL;
 		goto unlock_out;
+	}
 
 	if (dentry->d_inode) {
 		dput(dentry);
+		dentry = NULL;
 		goto unlock_out;
 	}
 
 	inode = new_inode(capifs_mnt->mnt_sb);
 	if (!inode) {
 		dput(dentry);
+		dentry = NULL;
 		goto unlock_out;
 	}
 
@@ -177,24 +178,31 @@ void capifs_new_ncci(unsigned int number, dev_t device)
 	init_special_inode(inode, S_IFCHR|config.mode, device);
 
 	d_instantiate(dentry, inode);
+	dget(dentry);
 
 unlock_out:
 	mutex_unlock(&capifs_root->d_inode->i_mutex);
+
+	return dentry;
 }
 
-void capifs_free_ncci(unsigned int number)
+void capifs_free_ncci(struct dentry *dentry)
 {
-	struct dentry *dentry = get_node(number);
-
-	if (!IS_ERR(dentry)) {
-		struct inode *inode = dentry->d_inode;
-		if (inode) {
-			inode->i_nlink--;
-			d_delete(dentry);
-			dput(dentry);
-		}
+	struct inode *inode;
+
+	if (!dentry)
+		return;
+
+	mutex_lock(&capifs_root->d_inode->i_mutex);
+
+	inode = dentry->d_inode;
+	if (inode) {
+		drop_nlink(inode);
+		d_delete(dentry);
 		dput(dentry);
 	}
+	dput(dentry);
+
 	mutex_unlock(&capifs_root->d_inode->i_mutex);
 }
 
diff --git a/drivers/isdn/capi/capifs.h b/drivers/isdn/capi/capifs.h
index d0bd4c3..e193d11 100644
--- a/drivers/isdn/capi/capifs.h
+++ b/drivers/isdn/capi/capifs.h
@@ -7,5 +7,22 @@
  *
  */
 
-void capifs_new_ncci(unsigned int num, dev_t device);
-void capifs_free_ncci(unsigned int num);
+#include <linux/dcache.h>
+
+#if defined(CONFIG_ISDN_CAPI_CAPIFS) || defined(CONFIG_ISDN_CAPI_CAPIFS_MODULE)
+
+struct dentry *capifs_new_ncci(unsigned int num, dev_t device);
+void capifs_free_ncci(struct dentry *dentry);
+
+#else
+
+static inline struct dentry *capifs_new_ncci(unsigned int num, dev_t device)
+{
+	return NULL;
+}
+
+static inline void capifs_free_ncci(struct dentry *dentry)
+{
+}
+
+#endif
-- 
1.6.0.2
