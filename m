From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH] wil6210: Fix potential memory leaks on error paths
Date: Fri, 28 Nov 2014 02:47:19 +0100
Message-ID: <1417139239-32602-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: netdev@vger.kernel.org, ahmedtamrawi@gmail.com,
	davem@davemloft.net, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: qca_vkondrat@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:53089 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751199AbaK1Bsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Nov 2014 20:48:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix missing memory deallocation on error paths in wil_write_file_wmi()
and wil_write_file_txmgmt().

Reported-by: Ahmed Tamrawi <ahmedtamrawi@gmail.com>
Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/wireless/ath/wil6210/debugfs.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/wil6210/debugfs.c b/drivers/net/wireless/ath/wil6210/debugfs.c
index 54a6ddc..4e6e145 100644
--- a/drivers/net/wireless/ath/wil6210/debugfs.c
+++ b/drivers/net/wireless/ath/wil6210/debugfs.c
@@ -573,8 +573,10 @@ static ssize_t wil_write_file_txmgmt(struct file *file, const char __user *buf,
 	if (!frame)
 		return -ENOMEM;
 
-	if (copy_from_user(frame, buf, len))
+	if (copy_from_user(frame, buf, len)) {
+		kfree(frame);
 		return -EIO;
+	}
 
 	params.buf = frame;
 	params.len = len;
@@ -614,8 +616,10 @@ static ssize_t wil_write_file_wmi(struct file *file, const char __user *buf,
 		return -ENOMEM;
 
 	rc = simple_write_to_buffer(wmi, len, ppos, buf, len);
-	if (rc < 0)
+	if (rc < 0) {
+		kfree(wmi);
 		return rc;
+	}
 
 	cmd = &wmi[1];
 	cmdid = le16_to_cpu(wmi->id);
-- 
1.9.1
