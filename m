From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] drivers/net/usb/catc.c: Fix potential deadlock in catc_ctrl_run()
Date: Mon, 30 May 2011 21:06:24 +0400
Message-ID: <1306775184-5520-1-git-send-email-khoroshilov@ispras.ru>
References: <1306774878-5471-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306774878-5471-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sorry, I missed a description in the previous mail.


catc_ctrl_run() calls usb_submit_urb() with GFP_KERNEL, while it is called from
catc_ctrl_async() and catc_ctrl_done() with catc->ctrl_lock spinlock held.

The patch replaces GFP_KERNEL with GFP_ATOMIC.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/usb/catc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/catc.c b/drivers/net/usb/catc.c
index d7221c4..8056f8a 100644
--- a/drivers/net/usb/catc.c
+++ b/drivers/net/usb/catc.c
@@ -495,7 +495,7 @@ static void catc_ctrl_run(struct catc *catc)
 	if (!q->dir && q->buf && q->len)
 		memcpy(catc->ctrl_buf, q->buf, q->len);
 
-	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_KERNEL)))
+	if ((status = usb_submit_urb(catc->ctrl_urb, GFP_ATOMIC)))
 		err("submit(ctrl_urb) status %d", status);
 }
 
-- 
1.7.4.1
