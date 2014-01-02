From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH, RFC 21/30] isdn: divert, hysdn: fix interruptible_sleep_on race
Date: Thu,  2 Jan 2014 13:07:45 +0100
Message-ID: <1388664474-1710039-22-git-send-email-arnd@arndb.de>
References: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388664474-1710039-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These two drivers use identical code for their procfs status
file handling, which contains a small race against status
data becoming available while reading the file.

This uses wait_event_interruptible instead to fix this
particular race and eventually get rid of all sleep_on
instances. There seems to be another race involving
multiple concurrent readers of the same procfs file, which
I don't try to fix here.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/divert/divert_procfs.c | 7 ++++---
 drivers/isdn/hysdn/hysdn_proclog.c  | 7 ++++---
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/isdn/divert/divert_procfs.c b/drivers/isdn/divert/divert_procfs.c
index fb4f1ba..1c5dc34 100644
--- a/drivers/isdn/divert/divert_procfs.c
+++ b/drivers/isdn/divert/divert_procfs.c
@@ -86,12 +86,13 @@ isdn_divert_read(struct file *file, char __user *buf, size_t count, loff_t *off)
 	struct divert_info *inf;
 	int len;
 
-	if (!*((struct divert_info **) file->private_data)) {
+	if (!(inf = *((struct divert_info **) file->private_data))) {
 		if (file->f_flags & O_NONBLOCK)
 			return -EAGAIN;
-		interruptible_sleep_on(&(rd_queue));
+		wait_event_interruptible(rd_queue, (inf =
+			*((struct divert_info **) file->private_data)));
 	}
-	if (!(inf = *((struct divert_info **) file->private_data)))
+	if (!inf)
 		return (0);
 
 	inf->usage_cnt--;	/* new usage count */
diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index b61e8d5..7b5fd8f 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -175,14 +175,15 @@ hysdn_log_read(struct file *file, char __user *buf, size_t count, loff_t *off)
 	int len;
 	hysdn_card *card = PDE_DATA(file_inode(file));
 
-	if (!*((struct log_data **) file->private_data)) {
+	if (!(inf = *((struct log_data **) file->private_data))) {
 		struct procdata *pd = card->proclog;
 		if (file->f_flags & O_NONBLOCK)
 			return (-EAGAIN);
 
-		interruptible_sleep_on(&(pd->rd_queue));
+		wait_event_interruptible(pd->rd_queue, (inf =
+				*((struct log_data **) file->private_data)));
 	}
-	if (!(inf = *((struct log_data **) file->private_data)))
+	if (!inf)
 		return (0);
 
 	inf->usage_cnt--;	/* new usage count */
-- 
1.8.3.2
