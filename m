From: <gregkh@suse.de>
Subject: patch driver-core-implement-ns-directory-support-for-device-classes.patch added to gregkh-2.6 tree
Date: Thu, 29 Apr 2010 13:29:00 -0700
Message-ID: <12725729403493@kroah.org>
References: <1269973889-25260-6-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: 8bit
To: ebiederm@xmission.com, bcrl@lhnet.ca, benjamin.thery@bull.net,
	cornelia.huck@de.ibm.com, eric.dumazet@gmail.com, gregkh@suse.de,
	kay.sievers@vrfy.org, netdev@vger.kernel.org, serue@us.
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:58702 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932711Ab0D3RIi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Apr 2010 13:08:38 -0400
In-Reply-To: <1269973889-25260-6-git-send-email-ebiederm@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a note to let you know that I've just added the patch titled

    Subject: driver core: Implement ns directory support for device classes.

to my gregkh-2.6 tree.  Its filename is

    driver-core-implement-ns-directory-support-for-device-classes.patch

This tree can be found at 
    http://www.kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/patches/


>From ebiederm@xmission.com  Thu Apr 29 12:47:44 2010
From: "Eric W. Biederman" <ebiederm@xmission.com>
Date: Tue, 30 Mar 2010 11:31:29 -0700
Subject: driver core: Implement ns directory support for device classes.
To: Greg Kroah-Hartman <gregkh@suse.de>
Cc: Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Cornelia Huck <cornelia.huck@de.ibm.com>, linux-fsdevel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Benjamin LaHaise <bcrl@lhnet.ca>, Serge Hallyn <serue@us.ibm.com>, <netdev@vger.kernel.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Benjamin Thery <benjamin.thery@bull.net>
Message-ID: <1269973889-25260-6-git-send-email-ebiederm@xmission.com>


From: Eric W. Biederman <ebiederm@xmission.com>

device_del and device_rename were modified to use
sysfs_delete_link and sysfs_rename_link respectively to ensure
when these operations happen on devices whose classes
are in namespace directories they work properly.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/base/core.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

--- a/drivers/base/core.c
+++ b/drivers/base/core.c
@@ -786,7 +786,7 @@ out_device:
 out_busid:
 	if (dev->kobj.parent != &dev->class->p->class_subsys.kobj &&
 	    device_is_not_partition(dev))
-		sysfs_remove_link(&dev->class->p->class_subsys.kobj,
+		sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj,
 				  dev_name(dev));
 #else
 	/* link in the class directory pointing to the device */
@@ -804,7 +804,7 @@ out_busid:
 	return 0;
 
 out_busid:
-	sysfs_remove_link(&dev->class->p->class_subsys.kobj, dev_name(dev));
+	sysfs_delete_link(&dev->class->p->class_subsys.kobj, &dev->kobj, dev_name(dev));
 #endif
 
 out_subsys:
@@ -832,13 +832,13 @@ static void device_remove_class_symlinks
 
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
@@ -1624,6 +1624,14 @@ int device_rename(struct device *dev, ch
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
@@ -1638,11 +1646,6 @@ int device_rename(struct device *dev, ch
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

