From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] net/hippi/rrunner: use memdup_user
Date: Sat,  6 May 2017 23:42:16 +0800
Message-ID: <58733b05cfe6248e30471a59ad1faee7f2f71280.1493780932.git.geliangtang@gmail.com>
References: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-hippi@sunsite.dk,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jes Sorensen <jes@trained-monkey.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34158 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbdEFPmf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 11:42:35 -0400
In-Reply-To: <df8091d4c64a0d5a7ab0a5989f34552a5eebd15e.1493778999.git.geliangtang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use memdup_user() helper instead of open-coding to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/net/hippi/rrunner.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index 9b0d614..1ce6239 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -1616,17 +1616,14 @@ static int rr_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 			return -EPERM;
 		}
 
-		image = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
-		oldimage = kmalloc(EEPROM_WORDS * sizeof(u32), GFP_KERNEL);
-		if (!image || !oldimage) {
-			error = -ENOMEM;
-			goto wf_out;
-		}
+		image = memdup_user(rq->ifr_data, EEPROM_BYTES);
+		if (IS_ERR(image))
+			return PTR_ERR(image);
 
-		error = copy_from_user(image, rq->ifr_data, EEPROM_BYTES);
-		if (error) {
-			error = -EFAULT;
-			goto wf_out;
+		oldimage = kmalloc(EEPROM_BYTES, GFP_KERNEL);
+		if (!oldimage) {
+			kfree(image);
+			return -ENOMEM;
 		}
 
 		if (rrpriv->fw_running){
-- 
2.9.3
