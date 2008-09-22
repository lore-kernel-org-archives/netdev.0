From: akpm@linux-foundation.org
Subject: [patch 4/4] mISDN: misc timerdev fixes
Date: Mon, 22 Sep 2008 14:51:03 -0700
Message-ID: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	andi@firstfloor.org, ak@linux.intel.com
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44110 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753504AbYIVVvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 17:51:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>

- Remove noop VFS stubs. The VFS does that on a NULL pointer anyways.
- Fix timer handler prototype to be correct
- Comment ugly SMP race I didn't fix.

Signed-off-by: Andi Kleen <ak@linux.intel.com>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/timerdev.c |   22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff -puN drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes drivers/isdn/mISDN/timerdev.c
--- a/drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes
+++ a/drivers/isdn/mISDN/timerdev.c
@@ -124,18 +124,6 @@ mISDN_read(struct file *filep, char *buf
 	return ret;
 }
 
-static loff_t
-mISDN_llseek(struct file *filep, loff_t offset, int orig)
-{
-	return -ESPIPE;
-}
-
-static ssize_t
-mISDN_write(struct file *filep, const char *buf, size_t count, loff_t *off)
-{
-	return -EOPNOTSUPP;
-}
-
 static unsigned int
 mISDN_poll(struct file *filep, poll_table *wait)
 {
@@ -157,8 +145,9 @@ mISDN_poll(struct file *filep, poll_tabl
 }
 
 static void
-dev_expire_timer(struct mISDNtimer *timer)
+dev_expire_timer(unsigned long data)
 {
+	struct mISDNtimer *timer = (void *)data;
 	u_long			flags;
 
 	spin_lock_irqsave(&timer->dev->lock, flags);
@@ -191,7 +180,7 @@ misdn_add_timer(struct mISDNtimerdev *de
 		spin_unlock_irqrestore(&dev->lock, flags);
 		timer->dev = dev;
 		timer->tl.data = (long)timer;
-		timer->tl.function = (void *) dev_expire_timer;
+		timer->tl.function = dev_expire_timer;
 		init_timer(&timer->tl);
 		timer->tl.expires = jiffies + ((HZ * (u_long)timeout) / 1000);
 		add_timer(&timer->tl);
@@ -211,6 +200,9 @@ misdn_del_timer(struct mISDNtimerdev *de
 	list_for_each_entry(timer, &dev->pending, list) {
 		if (timer->id == id) {
 			list_del_init(&timer->list);
+			/* RED-PEN AK: race -- timer can be still running on
+			 * other CPU. Needs reference count I think
+ 		 	 */
 			del_timer(&timer->tl);
 			ret = timer->id;
 			kfree(timer);
@@ -268,9 +260,7 @@ mISDN_ioctl(struct inode *inode, struct 
 }
 
 static struct file_operations mISDN_fops = {
-	.llseek		= mISDN_llseek,
 	.read		= mISDN_read,
-	.write		= mISDN_write,
 	.poll		= mISDN_poll,
 	.ioctl		= mISDN_ioctl,
 	.open		= mISDN_open,
_
