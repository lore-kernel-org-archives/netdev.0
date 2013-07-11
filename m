From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 37/50] media: usb: sn9x102: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:00 +0800
Message-ID: <1373533573-12272-38-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Mauro Carvalho Chehab <mchehab@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:45652 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932451Ab3GKJLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 05:11:34 -0400
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Mauro Carvalho Chehab <mchehab@redhat.com>
Cc: linux-media@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/media/usb/sn9c102/sn9c102_core.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/media/usb/sn9c102/sn9c102_core.c b/drivers/media/usb/sn9c102/sn9c102_core.c
index 2cb44de..33dc595 100644
--- a/drivers/media/usb/sn9c102/sn9c102_core.c
+++ b/drivers/media/usb/sn9c102/sn9c102_core.c
@@ -784,12 +784,14 @@ end_of_frame:
 				      cam->sensor.pix_format.pixelformat ==
 				      V4L2_PIX_FMT_JPEG) && eof)) {
 					u32 b;
+					unsigned long flags;
 
 					b = (*f)->buf.bytesused;
 					(*f)->state = F_DONE;
 					(*f)->buf.sequence= ++cam->frame_count;
 
-					spin_lock(&cam->queue_lock);
+					spin_lock_irqsave(&cam->queue_lock,
+							  flags);
 					list_move_tail(&(*f)->frame,
 						       &cam->outqueue);
 					if (!list_empty(&cam->inqueue))
@@ -799,7 +801,8 @@ end_of_frame:
 							frame );
 					else
 						(*f) = NULL;
-					spin_unlock(&cam->queue_lock);
+					spin_unlock_irqrestore(&cam->queue_lock,
+							       flags);
 
 					memcpy(cam->sysfs.frame_header,
 					       cam->sof.header, soflen);
-- 
1.7.9.5
