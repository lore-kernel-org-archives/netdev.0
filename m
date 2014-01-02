From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, RFC 22/30] isdn: fix multiple sleep_on races
Date: Thu,  2 Jan 2014 13:07:46 +0100
Message-ID: <1388664474-1710039-23-git-send-email-arnd@arndb.de>
References: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The isdn core code uses a couple of wait queues with
interruptible_sleep_on, which is racy and about to get
removed from the kernel. Fortunately, we know for each case
what we are waiting for, so they can all be converted to
the better wait_event_interruptible interface.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/i4l/isdn_common.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_common.c
index 9bb12ba..130f216 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -777,7 +777,8 @@ isdn_readbchan(int di, int channel, u_char *buf, u_char *fp, int len, wait_queue
 		return 0;
 	if (skb_queue_empty(&dev->drv[di]->rpqueue[channel])) {
 		if (sleep)
-			interruptible_sleep_on(sleep);
+			wait_event_interruptible(*sleep,
+				!skb_queue_empty(&dev->drv[di]->rpqueue[channel]));
 		else
 			return 0;
 	}
@@ -1072,7 +1073,8 @@ isdn_read(struct file *file, char __user *buf, size_t count, loff_t *off)
 				retval = -EAGAIN;
 				goto out;
 			}
-			interruptible_sleep_on(&(dev->info_waitq));
+			wait_event_interruptible(dev->info_waitq,
+						 file->private_data);
 		}
 		p = isdn_statstr();
 		file->private_data = NULL;
@@ -1128,7 +1130,8 @@ isdn_read(struct file *file, char __user *buf, size_t count, loff_t *off)
 				retval = -EAGAIN;
 				goto out;
 			}
-			interruptible_sleep_on(&(dev->drv[drvidx]->st_waitq));
+			wait_event_interruptible(dev->drv[drvidx]->st_waitq,
+						 dev->drv[drvidx]->stavail);
 		}
 		if (dev->drv[drvidx]->interface->readstat) {
 			if (count > dev->drv[drvidx]->stavail)
@@ -1188,8 +1191,8 @@ isdn_write(struct file *file, const char __user *buf, size_t count, loff_t *off)
 			goto out;
 		}
 		chidx = isdn_minor2chan(minor);
-		while ((retval = isdn_writebuf_stub(drvidx, chidx, buf, count)) == 0)
-			interruptible_sleep_on(&dev->drv[drvidx]->snd_waitq[chidx]);
+		wait_event_interruptible(dev->drv[drvidx]->snd_waitq[chidx],
+			(retval = isdn_writebuf_stub(drvidx, chidx, buf, count)));
 		goto out;
 	}
 	if (minor <= ISDN_MINOR_CTRLMAX) {
-- 
1.8.3.2
