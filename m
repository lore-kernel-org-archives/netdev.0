From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] wlcore: use memdup_user
Date: Sat,  6 May 2017 23:42:20 +0800
Message-ID: <69124563157776eb4187fa35b0161dc8675ebeaf.1493781907.git.geliangtang@gmail.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
        Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33202 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754820AbdEFPm6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 11:42:58 -0400
In-Reply-To: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/wireless/ti/wlcore/debugfs.c | 13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/debugfs.c b/drivers/net/wireless/ti/wlcore/debugfs.c
index de7e2a5..a2cb408 100644
--- a/drivers/net/wireless/ti/wlcore/debugfs.c
+++ b/drivers/net/wireless/ti/wlcore/debugfs.c
@@ -1149,15 +1149,9 @@ static ssize_t dev_mem_write(struct file *file, const char __user *user_buf,
 	part.mem.start = *ppos;
 	part.mem.size = bytes;
 
-	buf = kmalloc(bytes, GFP_KERNEL);
-	if (!buf)
-		return -ENOMEM;
-
-	ret = copy_from_user(buf, user_buf, bytes);
-	if (ret) {
-		ret = -EFAULT;
-		goto err_out;
-	}
+	buf = memdup_user(user_buf, bytes);
+	if (IS_ERR(buf))
+		return PTR_ERR(buf);
 
 	mutex_lock(&wl->mutex);
 
@@ -1197,7 +1191,6 @@ static ssize_t dev_mem_write(struct file *file, const char __user *user_buf,
 	if (ret == 0)
 		*ppos += bytes;
 
-err_out:
 	kfree(buf);
 
 	return ((ret == 0) ? bytes : ret);
-- 
2.9.3
