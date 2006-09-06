From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 18/21] scsi: propagate the swapdev hook into the scsi stack
Date: Wed, 06 Sep 2006 15:16:48 +0200
Message-ID: <20060906133956.068570000@chello.nl>
References: <20060906131630.793619000@chello.nl>>
Cc: Daniel Phillips <phillips@google.com>,
	Rik van Riel <riel@redhat.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"James E.J. Bottomley" <James.Bottomley@SteelEye.com>,
	Mike Christie <michaelc@cs.wisc.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750942AbWIFNk7@vger.kernel.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Content-Disposition: inline; filename=scsi_swapdev.patch
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow scsi devices to receive the swapdev notification.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
CC: James E.J. Bottomley <James.Bottomley@SteelEye.com>
CC: Mike Christie <michaelc@cs.wisc.edu>
---
 drivers/scsi/sd.c        |   13 +++++++++++++
 include/scsi/scsi_host.h |    7 +++++++
 2 files changed, 20 insertions(+)

Index: linux-2.6/drivers/scsi/sd.c
===================================================================
--- linux-2.6.orig/drivers/scsi/sd.c
+++ linux-2.6/drivers/scsi/sd.c
@@ -892,6 +892,18 @@ static long sd_compat_ioctl(struct file 
 }
 #endif
 
+static int sd_swapdev(struct gendisk *disk, int enable)
+{
+	int error = 0;
+	struct scsi_disk *sdkp = scsi_disk(disk);
+	struct scsi_device *sdp = sdkp->device;
+
+	if (sdp->host->hostt->swapdev)
+		error = sdp->host->hostt->swapdev(sdp, enable);
+
+	return error;
+}
+
 static struct block_device_operations sd_fops = {
 	.owner			= THIS_MODULE,
 	.open			= sd_open,
@@ -903,6 +915,7 @@ static struct block_device_operations sd
 #endif
 	.media_changed		= sd_media_changed,
 	.revalidate_disk	= sd_revalidate_disk,
+	.swapdev		= sd_swapdev,
 };
 
 /**
Index: linux-2.6/include/scsi/scsi_host.h
===================================================================
--- linux-2.6.orig/include/scsi/scsi_host.h
+++ linux-2.6/include/scsi/scsi_host.h
@@ -288,6 +288,13 @@ struct scsi_host_template {
 	int (*suspend)(struct scsi_device *, pm_message_t state);
 
 	/*
+	 * Notify that this device is used for swapping.
+	 *
+	 * Status: OPTIONAL
+	 */
+	int (*swapdev)(struct scsi_device *, int enable);
+
+	/*
 	 * Name of proc directory
 	 */
 	char *proc_name;

--
