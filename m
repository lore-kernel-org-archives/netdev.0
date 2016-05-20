From: Muhammad Falak R Wani <falakreyaz@gmail.com>
Subject: [PATCH] wan: cosa: use memdup_user().
Date: Fri, 20 May 2016 17:50:06 +0530
Message-ID: <1463746806-23739-1-git-send-email-falakreyaz@gmail.com>
Cc: netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: <kas@fi.muni.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use memdup_user to duplicate a memory region from user-space to
kernel-space, instead of open coding using kmalloc & copy_from_user.

Signed-off-by: Muhammad Falak R Wani <falakreyaz@gmail.com>
---
 drivers/net/wan/cosa.c | 11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index b87fe0a..fb37439 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -876,15 +876,10 @@ static ssize_t cosa_write(struct file *file,
 		count = COSA_MTU;
 	
 	/* Allocate the buffer */
-	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
-	if (kbuf == NULL) {
+	kbuf = memdup_user(buf, count);
+	if (IS_ERR(kbuf)) {
 		up(&chan->wsem);
-		return -ENOMEM;
-	}
-	if (copy_from_user(kbuf, buf, count)) {
-		up(&chan->wsem);
-		kfree(kbuf);
-		return -EFAULT;
+		return PTR_ERR(kbuf);
 	}
 	chan->tx_status=0;
 	cosa_start_tx(chan, kbuf, count);
-- 
1.9.1
