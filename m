From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH 17/31] CAPI: Fix racy capi_read
Date: Thu, 7 Jan 2010 20:38:28 +0100
Message-ID: <3be6c33ad163b72ee4e6821eae582a6fb50003e9.1264201407.git.jan.kiszka@web.de>
References: <cover.1264201406.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate03.web.de ([217.72.192.234]:60623 "EHLO
	fmmailgate03.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755240Ab0AVXYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 18:24:04 -0500
In-Reply-To: <cover.1264201406.git.jan.kiszka@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

capi_read still used interruptible_sleep_on, risking to miss a wakeup
this way. Convert it to wait_event_interruptible.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index b71b8b1..90a20fa 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -656,24 +656,19 @@ capi_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 	struct capidev *cdev = (struct capidev *)file->private_data;
 	struct sk_buff *skb;
 	size_t copied;
+	int err;
 
 	if (!cdev->ap.applid)
 		return -ENODEV;
 
-	if ((skb = skb_dequeue(&cdev->recvqueue)) == NULL) {
-
+	skb = skb_dequeue(&cdev->recvqueue);
+	if (!skb) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
-
-		for (;;) {
-			interruptible_sleep_on(&cdev->recvwait);
-			if ((skb = skb_dequeue(&cdev->recvqueue)) != NULL)
-				break;
-			if (signal_pending(current))
-				break;
-		}
-		if (skb == NULL)
-			return -ERESTARTNOHAND;
+		err = wait_event_interruptible(cdev->recvwait,
+				(skb = skb_dequeue(&cdev->recvqueue)));
+		if (err)
+			return err;
 	}
 	if (skb->len > count) {
 		skb_queue_head(&cdev->recvqueue, skb);
-- 
1.6.0.2

