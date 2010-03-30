From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 6/6] driver core: Implement ns directory support for device classes.
Date: Tue, 30 Mar 2010 11:31:29 -0700
Message-ID: <1269973889-25260-6-git-send-email-ebiederm@xmission.com>
References: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	linux-fsdevel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Benjamin LaHaise <bcrl@lhnet.ca>,
	Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1fx3hk6gw.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com>

device_del and device_rename were modified to use
sysfs_delete_link and sysfs_rename_link respectively to ensure
when these operations happen on devices whose classes
are in namespace directories they work properly.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 drivers/base/core.c |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/base/core.c b/drivers/base/core.c
index 6b32f6e..73c352d 100644
--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -787,7 +787,7 @@ out_device:
 out_busid:
 	if (dev->kobj.parent != &dev->class->p->class_subsys.kobj &&
 	    device_is_not_partition(dev))
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
+		sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj,
 				  dev_name(dev));
 #else
 	/* link in the class directory pointing to the device */
@@ -805,7 +805,7 @@ out_busid:
 	return 0;
 
 out_busid:
-	sysfs_remove_link(&dev->class->p->class_subsys.kobj, dev_name(dev));
+	sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj, dev_name(dev));
 #endif
 
 out_subsys:
@@ -833,13 +833,13 @@ static void device_remove_class_symlinks(struct device *dev)
 
 	if (dev->kobj.parent != &dev->class->p->class_subsys.kobj &&
 	    device_is_not_partition(dev))
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
+		sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj,
 				  dev_name(dev));
 #else
 	if (dev->parent && device_is_not_partition(dev))
 		sysfs_remove_link(&dev->kobj, "device");
 
-	sysfs_remove_link(&dev->class->p->class_subsys.kobj, dev_name(dev));
+	sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj, dev_name(dev));
 #endif
 
 	sysfs_remove_link(&dev->kobj, "subsystem");
@@ -1619,6 +1619,14 @@ int device_rename(struct device *dev, char *new_name)
 		goto out;
 	}
 
+#ifndef CONFIG_SYSFS_DEPRECATED
+	if (dev->class) {
+		error = sysfs_rename_link(&dev->class->p->class_subsys.kobj,
+			&dev->kobj, old_device_name, new_name);
+		if (error)
+			goto out;
+	}
+#endif
 	error = kobject_rename(&dev->kobj, new_name);
 	if (error)
 		goto out;
@@ -1633,11 +1641,6 @@ int device_rename(struct device *dev, char *new_name)
 						  new_class_name);
 		}
 	}
-#else
-	if (dev->class) {
-		error = sysfs_rename_link(&dev->class->p->class_subsys.kobj,
-					  &dev->kobj, old_device_name, new_name);
-	}
 #endif
 
 out:
-- 
1.6.5.2.143.g8cc62
