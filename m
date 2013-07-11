From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH 50/50] staging: vt6656: spin_lock in complete() cleanup
Date: Thu, 11 Jul 2013 17:06:13 +0800
Message-ID: <1373533573-12272-51-git-send-email-ming.lei@canonical.com>
References: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	linux-input@vger.kernel.org, linux-bluetooth@vger.kernel.org,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@alsa-project.org,
	Ming Lei <ming.lei@canonical.com>, devel@driverdev.osuosl.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1373533573-12272-1-git-send-email-ming.lei@canonical.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: devel@driverdev.osuosl.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/staging/vt6656/usbpipe.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/staging/vt6656/usbpipe.c b/drivers/staging/vt6656/usbpipe.c
index 098be60..0282f2e 100644
--- a/drivers/staging/vt6656/usbpipe.c
+++ b/drivers/staging/vt6656/usbpipe.c
@@ -485,6 +485,7 @@ static void s_nsBulkInUsbIoCompleteRead(struct urb *urb)
 	int bIndicateReceive = false;
 	int bReAllocSkb = false;
 	int status;
+	unsigned long flags;
 
     DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"---->s_nsBulkInUsbIoCompleteRead\n");
     status = urb->status;
@@ -515,18 +516,18 @@ static void s_nsBulkInUsbIoCompleteRead(struct urb *urb)
     STAvUpdateUSBCounter(&pDevice->scStatistic.USB_BulkInStat, status);
 
     if (bIndicateReceive) {
-        spin_lock(&pDevice->lock);
+        spin_lock_irqsave(&pDevice->lock, flags);
         if (RXbBulkInProcessData(pDevice, pRCB, bytesRead) == true)
             bReAllocSkb = true;
-        spin_unlock(&pDevice->lock);
+        spin_unlock_irqrestore(&pDevice->lock, flags);
     }
     pRCB->Ref--;
     if (pRCB->Ref == 0)
     {
         DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO"RxvFreeNormal %d \n",pDevice->NumRecvFreeList);
-        spin_lock(&pDevice->lock);
+        spin_lock_irqsave(&pDevice->lock, flags);
         RXvFreeRCB(pRCB, bReAllocSkb);
-        spin_unlock(&pDevice->lock);
+        spin_unlock_irqrestore(&pDevice->lock, flags);
     }
 
     return;
-- 
1.7.9.5

