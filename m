From: Roman Gushchin <guro@fb.com>
Subject: [PATCH net-next 1/4] device_cgroup: prepare code for bpf-based device controller
Date: Wed, 1 Nov 2017 11:20:34 -0400
Message-ID: <20171101152037.3288-2-guro@fb.com>
References: <20171101152037.3288-1-guro@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tejun Heo <tj@kernel.org>, Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        <linux-kernel@vger.kernel.org>, Roman Gushchin <guro@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171101152037.3288-1-guro@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is non-functional change to prepare the device cgroup code
for adding eBPF-based controller for cgroups v2.

The patch performs the following changes:
1) __devcgroup_inode_permission() and devcgroup_inode_mknod()
   are moving to the device-cgroup.h and converting into static inline.
2) __devcgroup_check_permission() is exported.
3) devcgroup_check_permission() wrapper is introduced to be used
   by both existing and new bpf-based implementations.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Tejun Heo <tj@kernel.org>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/device_cgroup.h | 61 ++++++++++++++++++++++++++++++++++++++++---
 security/device_cgroup.c      | 47 ++-------------------------------
 2 files changed, 59 insertions(+), 49 deletions(-)

diff --git a/include/linux/device_cgroup.h b/include/linux/device_cgroup.h
index 8b64221b432b..25f1dc7673db 100644
--- a/include/linux/device_cgroup.h
+++ b/include/linux/device_cgroup.h
@@ -1,16 +1,69 @@
 #include <linux/fs.h>
 
+#define ACC_MKNOD 1
+#define ACC_READ  2
+#define ACC_WRITE 4
+#define ACC_MASK (ACC_MKNOD | ACC_READ | ACC_WRITE)
+
+#define DEV_BLOCK 1
+#define DEV_CHAR  2
+#define DEV_ALL   4  /* this represents all devices */
+
+#ifdef CONFIG_CGROUP_DEVICE
+extern int __devcgroup_check_permission(short type, u32 major, u32 minor,
+					short access);
+#else
+static inline int __devcgroup_check_permission(short type, u32 major, u32 minor,
+					       short access)
+{ return 0; }
+#endif
+
 #ifdef CONFIG_CGROUP_DEVICE
-extern int __devcgroup_inode_permission(struct inode *inode, int mask);
-extern int devcgroup_inode_mknod(int mode, dev_t dev);
+static inline int devcgroup_check_permission(short type, u32 major, u32 minor,
+					     short access)
+{
+	return __devcgroup_check_permission(type, major, minor, access);
+}
+
 static inline int devcgroup_inode_permission(struct inode *inode, int mask)
 {
+	short type, access = 0;
+
 	if (likely(!inode->i_rdev))
 		return 0;
-	if (!S_ISBLK(inode->i_mode) && !S_ISCHR(inode->i_mode))
+
+	if (S_ISBLK(inode->i_mode))
+		type = DEV_BLOCK;
+	else if (S_ISCHR(inode->i_mode))
+		type = DEV_CHAR;
+	else
 		return 0;
-	return __devcgroup_inode_permission(inode, mask);
+
+	if (mask & MAY_WRITE)
+		access |= ACC_WRITE;
+	if (mask & MAY_READ)
+		access |= ACC_READ;
+
+	return devcgroup_check_permission(type, imajor(inode), iminor(inode),
+					  access);
 }
+
+static inline int devcgroup_inode_mknod(int mode, dev_t dev)
+{
+	short type;
+
+	if (!S_ISBLK(mode) && !S_ISCHR(mode))
+		return 0;
+
+	if (S_ISBLK(mode))
+		type = DEV_BLOCK;
+	else
+		type = DEV_CHAR;
+
+	return devcgroup_check_permission(type, MAJOR(dev), MINOR(dev),
+					  ACC_MKNOD);
+}
+
 #else
 static inline int devcgroup_inode_permission(struct inode *inode, int mask)
 { return 0; }
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 03c1652c9a1f..d6fb42274ed4 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -14,15 +14,6 @@
 #include <linux/rcupdate.h>
 #include <linux/mutex.h>
 
-#define ACC_MKNOD 1
-#define ACC_READ  2
-#define ACC_WRITE 4
-#define ACC_MASK (ACC_MKNOD | ACC_READ | ACC_WRITE)
-
-#define DEV_BLOCK 1
-#define DEV_CHAR  2
-#define DEV_ALL   4  /* this represents all devices */
-
 static DEFINE_MUTEX(devcgroup_mutex);
 
 enum devcg_behavior {
@@ -809,8 +800,8 @@ struct cgroup_subsys devices_cgrp_subsys = {
  *
  * returns 0 on success, -EPERM case the operation is not permitted
  */
-static int __devcgroup_check_permission(short type, u32 major, u32 minor,
-				        short access)
+int __devcgroup_check_permission(short type, u32 major, u32 minor,
+				 short access)
 {
 	struct dev_cgroup *dev_cgroup;
 	bool rc;
@@ -832,37 +823,3 @@ static int __devcgroup_check_permission(short type, u32 major, u32 minor,
 
 	return 0;
 }
-
-int __devcgroup_inode_permission(struct inode *inode, int mask)
-{
-	short type, access = 0;
-
-	if (S_ISBLK(inode->i_mode))
-		type = DEV_BLOCK;
-	if (S_ISCHR(inode->i_mode))
-		type = DEV_CHAR;
-	if (mask & MAY_WRITE)
-		access |= ACC_WRITE;
-	if (mask & MAY_READ)
-		access |= ACC_READ;
-
-	return __devcgroup_check_permission(type, imajor(inode), iminor(inode),
-			access);
-}
-
-int devcgroup_inode_mknod(int mode, dev_t dev)
-{
-	short type;
-
-	if (!S_ISBLK(mode) && !S_ISCHR(mode))
-		return 0;
-
-	if (S_ISBLK(mode))
-		type = DEV_BLOCK;
-	else
-		type = DEV_CHAR;
-
-	return __devcgroup_check_permission(type, MAJOR(dev), MINOR(dev),
-			ACC_MKNOD);
-
-}
-- 
2.13.6
