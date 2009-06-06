From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 7/7] initdev:kernel:Await block device discovery
Date: Fri, 5 Jun 2009 19:34:16 -0700
Message-ID: <20090606023416.GA5798@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62860 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753130AbZFFDAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 23:00:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the initdev infrastructure to wait for a root device to become available.
This should make most uses of the kernel rootwait parameter unnecessary. The
only time it should be necessary is when the root device might not be attached
at boot time.

Signed-off-by: David VomLehn <dvomlehn@cisco>
---
 init/do_mounts.c |   29 +++++++++++++++++++++++++----
 1 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/init/do_mounts.c b/init/do_mounts.c
index dd7ee5f..36a92ae 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -358,6 +358,18 @@ void __init mount_root(void)
 #endif
 }
 
+/**
+ * root_present - determine whether the root device is available yet
+ *
+ * Returns true if the root device is available, false if not. The check to
+ * see if the root device is available is done by check to see whether it
+ * has been assigned a major/minor device number.
+ */
+static bool root_present(void)
+{
+	return name_to_dev_t(saved_root_name) != 0;
+}
+
 /*
  * Prepare the namespace - decide what/where to mount, load ramdisks, etc.
  */
@@ -398,12 +410,21 @@ void __init prepare_namespace(void)
 		goto out;
 
 	/* wait for any asynchronous scanning to complete */
-	if ((ROOT_DEV == 0) && root_wait) {
+	if (ROOT_DEV == 0) {
 		printk(KERN_INFO "Waiting for root device %s...\n",
 			saved_root_name);
-		while (driver_probe_done() != 0 ||
-			(ROOT_DEV = name_to_dev_t(saved_root_name)) == 0)
-			msleep(100);
+		if (root_wait) {
+			while (driver_probe_done() != 0 ||
+				(ROOT_DEV = name_to_dev_t(saved_root_name)) ==
+					0)
+				msleep(100);
+		}
+
+		else {
+			initdev_wait(INITDEV_BLOCK_TYPE, root_present);
+			ROOT_DEV = name_to_dev_t(saved_root_name);
+		}
+
 		async_synchronize_full();
 	}
 
