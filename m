From: Benedikt Spranger <b.spranger@linutronix.de>
Subject: [PATCH 1/7] uio: add module owner to prevent inappropriate module unloading
Date: Tue, 13 Aug 2013 11:08:36 +0200
Message-ID: <1376384922-8519-3-git-send-email-b.spranger@linutronix.de>
References: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Cc: Alexander Frank <Alexander.Frank@eberspaecher.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Benedikt Spranger <b.spranger@linutronix.de>,
	"Hans J. Koch" <hjk@hansjkoch.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Holger Dengler <dengler@linutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:48271 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754506Ab3HMJIv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 05:08:51 -0400
In-Reply-To: <1376384922-8519-1-git-send-email-b.spranger@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If an UIO device is created by another driver (MFD for instance) it has to be
ensured that the MFD driver isn't removed while the UIO is still in use.
This patch adds a reference to the parent driver which does module refcounting
in order to avoid an too early removal.

Cc: "Hans J. Koch" <hjk@hansjkoch.de>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Signed-off-by: Benedikt Spranger <b.spranger@linutronix.de>
Signed-off-by: Holger Dengler <dengler@linutronix.de>
---
 drivers/uio/uio.c          | 9 +++++++++
 include/linux/uio_driver.h | 2 ++
 2 files changed, 11 insertions(+)

diff --git a/drivers/uio/uio.c b/drivers/uio/uio.c
index 3b96f18..9a95220 100644
--- a/drivers/uio/uio.c
+++ b/drivers/uio/uio.c
@@ -444,6 +444,11 @@ static int uio_open(struct inode *inode, struct file *filep)
 		goto out;
 	}
 
+	if (!try_module_get(idev->info->owner)) {
+		ret = -ENODEV;
+		goto err_get_module;
+	}
+
 	listener = kmalloc(sizeof(*listener), GFP_KERNEL);
 	if (!listener) {
 		ret = -ENOMEM;
@@ -465,6 +470,9 @@ err_infoopen:
 	kfree(listener);
 
 err_alloc_listener:
+	module_put(idev->info->owner);
+
+err_get_module:
 	module_put(idev->owner);
 
 out:
@@ -488,6 +496,7 @@ static int uio_release(struct inode *inode, struct file *filep)
 	if (idev->info->release)
 		ret = idev->info->release(idev->info, inode);
 
+	module_put(idev->info->owner);
 	module_put(idev->owner);
 	kfree(listener);
 	return ret;
diff --git a/include/linux/uio_driver.h b/include/linux/uio_driver.h
index 1ad4724..99f1696 100644
--- a/include/linux/uio_driver.h
+++ b/include/linux/uio_driver.h
@@ -80,6 +80,7 @@ struct uio_device;
  * @open:		open operation for this uio device
  * @release:		release operation for this uio device
  * @irqcontrol:		disable/enable irqs when 0/1 is written to /dev/uioX
+ * @owner:		module which created the uio device incase
  */
 struct uio_info {
 	struct uio_device	*uio_dev;
@@ -95,6 +96,7 @@ struct uio_info {
 	int (*open)(struct uio_info *info, struct inode *inode);
 	int (*release)(struct uio_info *info, struct inode *inode);
 	int (*irqcontrol)(struct uio_info *info, s32 irq_on);
+	struct module			*owner;
 };
 
 extern int __must_check
-- 
1.8.4.rc2
