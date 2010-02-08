From: Jan Kiszka <jan.kiszka@web.de>
Subject: [PATCH v2 17/41] CAPI: Fix racy capi_read
Date: Mon,  8 Feb 2010 21:12:21 +0100
Message-ID: <342ae07a02d368f2d76821f980c0118b55518f04.1265659935.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Cc: linux-kernel@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	isdn4linux@listserv.isdn4linux.de, netdev@vger.kernel.org,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Marcel Holtmann <marcel@holtmann.org>
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
In-Reply-To: <cover.1265659933.git.jan.kiszka@web.de>
References: <cover.1265659933.git.jan.kiszka@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

capi_read still used interruptible_sleep_on, risking to miss a wakeup
this way. Convert it to wait_event_interruptible.

Signed-off-by: Jan Kiszka <jan.kiszka@web.de>
---
 drivers/isdn/capi/capi.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index f8f8660..8abec96 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -657,24 +657,19 @@ capi_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
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
