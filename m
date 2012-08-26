From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [REVIEW][PATCH 12/15] userns: Convert drm to use kuid and kgid and struct pid where appropriate
Date: Sat, 25 Aug 2012 17:05:01 -0700
Message-ID: <87mx1iecwi.fsf@xmission.com>
References: <87lih2h6i4.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Cc: David Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
In-Reply-To: <87lih2h6i4.fsf@xmission.com> (Eric W. Biederman's message of
	"Sat, 25 Aug 2012 16:54:59 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Blink Blink this had not been converted to use struct pid ages ago?

- On drm open capture the openers kuid and struct pid.
- On drm close release the kuid and struct pid
- When reporting the uid and pid convert the kuid and struct pid
  into values in the appropriate namespace.

Cc: David Airlie <airlied@linux.ie>
Cc: dri-devel@lists.freedesktop.org
Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 drivers/gpu/drm/drm_fops.c  |    3 ++-
 drivers/gpu/drm/drm_info.c  |    5 +++--
 drivers/gpu/drm/drm_ioctl.c |    4 ++--
 include/drm/drmP.h          |    4 ++--
 init/Kconfig                |    1 -
 5 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/gpu/drm/drm_fops.c b/drivers/gpu/drm/drm_fops.c
index 5062eec..433d2fa 100644
--- a/drivers/gpu/drm/drm_fops.c
+++ b/drivers/gpu/drm/drm_fops.c
@@ -251,7 +251,7 @@ static int drm_open_helper(struct inode *inode, struct file *filp,
 	filp->private_data = priv;
 	priv->filp = filp;
 	priv->uid = current_euid();
-	priv->pid = task_pid_nr(current);
+	priv->pid = get_pid(task_pid(current));
 	priv->minor = idr_find(&drm_minors_idr, minor_id);
 	priv->ioctl_count = 0;
 	/* for compatibility root is always authenticated */
@@ -524,6 +524,7 @@ int drm_release(struct inode *inode, struct file *filp)
 	if (drm_core_check_feature(dev, DRIVER_PRIME))
 		drm_prime_destroy_file_private(&file_priv->prime);
 
+	put_pid(file_priv->pid);
 	kfree(file_priv);
 
 	/* ========================================================
diff --git a/drivers/gpu/drm/drm_info.c b/drivers/gpu/drm/drm_info.c
index 8928edb..eb0af39 100644
--- a/drivers/gpu/drm/drm_info.c
+++ b/drivers/gpu/drm/drm_info.c
@@ -191,8 +191,9 @@ int drm_clients_info(struct seq_file *m, void *data)
 		seq_printf(m, "%c %3d %5d %5d %10u %10lu\n",
 			   priv->authenticated ? 'y' : 'n',
 			   priv->minor->index,
-			   priv->pid,
-			   priv->uid, priv->magic, priv->ioctl_count);
+			   pid_vnr(priv->pid),
+			   from_kuid_munged(seq_user_ns(m), priv->uid),
+			   priv->magic, priv->ioctl_count);
 	}
 	mutex_unlock(&dev->struct_mutex);
 	return 0;
diff --git a/drivers/gpu/drm/drm_ioctl.c b/drivers/gpu/drm/drm_ioctl.c
index 64a62c6..39a4383 100644
--- a/drivers/gpu/drm/drm_ioctl.c
+++ b/drivers/gpu/drm/drm_ioctl.c
@@ -215,8 +215,8 @@ int drm_getclient(struct drm_device *dev, void *data,
 	list_for_each_entry(pt, &dev->filelist, lhead) {
 		if (i++ >= idx) {
 			client->auth = pt->authenticated;
-			client->pid = pt->pid;
-			client->uid = pt->uid;
+			client->pid = pid_vnr(pt->pid);
+			client->uid = from_kuid_munged(current_user_ns(), pt->uid);
 			client->magic = pt->magic;
 			client->iocs = pt->ioctl_count;
 			mutex_unlock(&dev->struct_mutex);
diff --git a/include/drm/drmP.h b/include/drm/drmP.h
index d6b67bb..9bc5c6a 100644
--- a/include/drm/drmP.h
+++ b/include/drm/drmP.h
@@ -426,8 +426,8 @@ struct drm_prime_file_private {
 /** File private data */
 struct drm_file {
 	int authenticated;
-	pid_t pid;
-	uid_t uid;
+	struct pid *pid;
+	kuid_t uid;
 	drm_magic_t magic;
 	unsigned long ioctl_count;
 	struct list_head lhead;
diff --git a/init/Kconfig b/init/Kconfig
index d849ba2..2a388e5 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -930,7 +930,6 @@ config UIDGID_CONVERTED
 	depends on FS_POSIX_ACL = n
 	depends on QUOTA = n
 	depends on QUOTACTL = n
-	depends on DRM = n
 
 	# Networking
 	depends on NET_9P = n
-- 
1.7.5.4
