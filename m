From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 03/50] USB: usblp: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:05:26 +0800
Message-ID: <1373533573-12272-4-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>,
	Pete Zaitcev <zaitcev@redhat.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Pete Zaitcev <zaitcev@redhat.com>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/usb/class/usblp.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/usb/class/usblp.c b/drivers/usb/class/usblp.c
index d4c47d5..04163d8 100644
--- a/drivers/usb/class/usblp.c
+++ b/drivers/usb/class/usblp.c
@@ -297,6 +297,7 @@ static void usblp_bulk_read(struct urb *urb)
 {
 	struct usblp *usblp = urb->context;
 	int status = urb->status;
+	unsigned long flags;
 
 	if (usblp->present && usblp->used) {
 		if (status)
@@ -304,14 +305,14 @@ static void usblp_bulk_read(struct urb *urb)
 			    "nonzero read bulk status received: %d\n",
 			    usblp->minor, status);
 	}
-	spin_lock(&usblp->lock);
+	spin_lock_irqsave(&usblp->lock, flags);
 	if (status < 0)
 		usblp->rstatus = status;
 	else
 		usblp->rstatus = urb->actual_length;
 	usblp->rcomplete = 1;
 	wake_up(&usblp->rwait);
-	spin_unlock(&usblp->lock);
+	spin_unlock_irqrestore(&usblp->lock, flags);
 
 	usb_free_urb(urb);
 }
@@ -320,6 +321,7 @@ static void usblp_bulk_write(struct urb *urb)
 {
 	struct usblp *usblp = urb->context;
 	int status = urb->status;
+	unsigned long flags;
 
 	if (usblp->present && usblp->used) {
 		if (status)
@@ -327,7 +329,7 @@ static void usblp_bulk_write(struct urb *urb)
 			    "nonzero write bulk status received: %d\n",
 			    usblp->minor, status);
 	}
-	spin_lock(&usblp->lock);
+	spin_lock_irqsave(&usblp->lock, flags);
 	if (status < 0)
 		usblp->wstatus = status;
 	else
@@ -335,7 +337,7 @@ static void usblp_bulk_write(struct urb *urb)
 	usblp->no_paper = 0;
 	usblp->wcomplete = 1;
 	wake_up(&usblp->wwait);
-	spin_unlock(&usblp->lock);
+	spin_unlock_irqrestore(&usblp->lock, flags);
 
 	usb_free_urb(urb);
 }
-- 
1.7.9.5
