From: David VomLehn <dvomlehn@cisco.com>
Subject: [PATCH 6/7] initdev:kernel:SCSI asynchronous block init device
	notification
Date: Fri, 5 Jun 2009 19:34:13 -0700
Message-ID: <20090606023413.GA5772@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-usb@vger.kernel.org,
	greg@kroah.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org,
	arjan@infradead.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:62847 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753903AbZFFDAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 23:00:48 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In addition to the bus initdev synchronization, SCSI also starts asynchronous
threads with which we must synchronize.

Signed-off-by: David VomLehn <dvomlehn@cisco.com>
---
 drivers/scsi/sd.c     |    3 +++
 fs/partitions/check.c |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
index 8404423..1104892 100644
--- a/drivers/scsi/sd.c
+++ b/drivers/scsi/sd.c
@@ -1955,10 +1955,12 @@ static void sd_probe_async(void *data, async_cookie_t cookie)
 	sd_printk(KERN_NOTICE, sdkp, "Attached SCSI %sdisk\n",
 		  sdp->removable ? "removable " : "");
 
+	initdev_probe_done(INITDEV_BLOCK_MASK);
 	return;
 
  out_free_index:
 	ida_remove(&sd_index_ida, index);
+	initdev_probe_done(INITDEV_BLOCK_MASK);
 }
 
 /**
@@ -2026,6 +2028,7 @@ static int sd_probe(struct device *dev)
 	sdkp->openers = 0;
 	sdkp->previous_state = 1;
 
+	initdev_found(INITDEV_BLOCK_MASK);
 	async_schedule(sd_probe_async, sdkp);
 
 	return 0;
diff --git a/fs/partitions/check.c b/fs/partitions/check.c
index 99e33ef..fbc6cd5 100644
--- a/fs/partitions/check.c
+++ b/fs/partitions/check.c
@@ -502,6 +502,7 @@ exit:
 	while ((part = disk_part_iter_next(&piter)))
 		kobject_uevent(&part_to_dev(part)->kobj, KOBJ_ADD);
 	disk_part_iter_exit(&piter);
+	initdev_registered(INITDEV_BLOCK_TYPE);
 }
 
 int rescan_partitions(struct gendisk *disk, struct block_device *bdev)
