From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 06/50] USB: iowarrior: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:29 +0800
Message-ID: <1373533573-12272-7-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/misc/iowarrior.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/usb/misc/iowarrior.c b/drivers/usb/misc/iowarrior.c
index d36f34e..010ed6d 100644
--- a/drivers/usb/misc/iowarrior.c
+++ b/drivers/usb/misc/iowarrior.c
@@ -162,6 +162,7 @@ static void iowarrior_callback(struct urb *urb)
 	int offset;
 	int status = urb->status;
 	int retval;
+	unsigned long flags;
 
 	switch (status) {
 	case 0:
@@ -175,7 +176,7 @@ static void iowarrior_callback(struct urb *urb)
 		goto exit;
 	}
 
-	spin_lock(&dev->intr_idx_lock);
+	spin_lock_irqsave(&dev->intr_idx_lock, flags);
 	intr_idx = atomic_read(&dev->intr_idx);
 	/* aux_idx become previous intr_idx */
 	aux_idx = (intr_idx == 0) ? (MAX_INTERRUPT_BUFFER - 1) : (intr_idx - 1);
@@ -211,7 +212,7 @@ static void iowarrior_callback(struct urb *urb)
 	*(dev->read_queue + offset + (dev->report_size)) = dev->serial_number++;
 
 	atomic_set(&dev->intr_idx, aux_idx);
-	spin_unlock(&dev->intr_idx_lock);
+	spin_unlock_irqrestore(&dev->intr_idx_lock, flags);
 	/* tell the blocking read about the new data */
 	wake_up_interruptible(&dev->read_wait);
 
-- 
1.7.9.5
