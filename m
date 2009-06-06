From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 5/7] initdev:kernel:USB and SCSI block init device
	notification, v4
Date: Fri, 5 Jun 2009 19:34:11 -0700
Message-ID: <20090606023411.GA5746@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62814 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbZFFDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 23:00:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Stern <stern@rowland.harvard.edu>

Add notification of device discovery for USB and SCSI block devices.

History
v4	Change BOOTDEV_* to INITDEV_*.
v3	Change bootdev_* to initdev_*
v2	Correct location of call to bootdev_found
v1	Initial version

Signed-off-by: Alan Stern <stern@rowland.harvard.edu
Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 drivers/scsi/scsi_scan.c  |    2 ++
 drivers/usb/storage/usb.c |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/scsi_scan.c b/drivers/scsi/scsi_scan.c
index 6f51ca4..cb7b450 100644
--- a/drivers/scsi/scsi_scan.c
+++ b/drivers/scsi/scsi_scan.c
@@ -1834,6 +1834,7 @@ static int do_scan_async(void *_data)
 	struct async_scan_data *data = _data;
 	do_scsi_scan_host(data->shost);
 	scsi_finish_async_scan(data);
+	initdev_probe_done(INITDEV_BLOCK_MASK);
 	return 0;
 }
 
@@ -1855,6 +1856,7 @@ void scsi_scan_host(struct Scsi_Host *shost)
 		return;
 	}
 
+	initdev_found(INITDEV_BLOCK_MASK);
 	p = kthread_run(do_scan_async, data, "scsi_scan_%d", shost->host_no);
 	if (IS_ERR(p))
 		do_scan_async(data);
diff --git a/drivers/usb/storage/usb.c b/drivers/usb/storage/usb.c
index 8060b85..6a78278 100644
--- a/drivers/usb/storage/usb.c
+++ b/drivers/usb/storage/usb.c
@@ -837,6 +837,7 @@ static int usb_stor_scan_thread(void * __us)
 		/* Should we unbind if no devices were detected? */
 	}
 
+	initdev_probe_done(INITDEV_BLOCK_MASK);
 	complete_and_exit(&us->scanning_done, 0);
 }
 
@@ -937,10 +938,12 @@ int usb_stor_probe2(struct us_data *us)
 	}
 
 	/* Start up the thread for delayed SCSI-device scanning */
+	initdev_found(INITDEV_BLOCK_MASK);
 	th = kthread_create(usb_stor_scan_thread, us, "usb-stor-scan");
 	if (IS_ERR(th)) {
 		printk(KERN_WARNING USB_STORAGE 
 		       "Unable to start the device-scanning thread\n");
+		initdev_probe_done(INITDEV_BLOCK_MASK);
 		complete(&us->scanning_done);
 		quiesce_and_remove_host(us);
 		result = PTR_ERR(th);
