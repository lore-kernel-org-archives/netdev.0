From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] intel: i40e: fix confused code
Date: Mon, 23 Nov 2015 11:36:16 -0800
Message-ID: <1448307376-20063-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41717 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906AbbKWTg0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 14:36:26 -0500
In-Reply-To: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>

This code is pretty confused. The variable name 'bytes_not_copied'
clearly indicates that the programmer knew the semantics of
copy_{to,from}_user, but then the return value is checked for being
negative and used as a -Exxx return value.

I'm not sure this is the proper fix, but at least we get rid of the
dead code which pretended to check for access faults.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d4b7af9..d1a91c8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -103,8 +103,8 @@ static ssize_t i40e_dbg_dump_read(struct file *filp, char __user *buffer,
 	len = min_t(int, count, (i40e_dbg_dump_data_len - *ppos));
 
 	bytes_not_copied = copy_to_user(buffer, &i40e_dbg_dump_buf[*ppos], len);
-	if (bytes_not_copied < 0)
-		return bytes_not_copied;
+	if (bytes_not_copied)
+		return -EFAULT;
 
 	*ppos += len;
 	return len;
@@ -353,8 +353,8 @@ static ssize_t i40e_dbg_command_read(struct file *filp, char __user *buffer,
 	bytes_not_copied = copy_to_user(buffer, buf, len);
 	kfree(buf);
 
-	if (bytes_not_copied < 0)
-		return bytes_not_copied;
+	if (bytes_not_copied)
+		return -EFAULT;
 
 	*ppos = len;
 	return len;
@@ -981,12 +981,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	if (!cmd_buf)
 		return count;
 	bytes_not_copied = copy_from_user(cmd_buf, buffer, count);
-	if (bytes_not_copied < 0) {
+	if (bytes_not_copied) {
 		kfree(cmd_buf);
-		return bytes_not_copied;
+		return -EFAULT;
 	}
-	if (bytes_not_copied > 0)
-		count -= bytes_not_copied;
 	cmd_buf[count] = '\0';
 
 	cmd_buf_tmp = strchr(cmd_buf, '\n');
@@ -2034,8 +2032,8 @@ static ssize_t i40e_dbg_netdev_ops_read(struct file *filp, char __user *buffer,
 	bytes_not_copied = copy_to_user(buffer, buf, len);
 	kfree(buf);
 
-	if (bytes_not_copied < 0)
-		return bytes_not_copied;
+	if (bytes_not_copied)
+		return -EFAULT;
 
 	*ppos = len;
 	return len;
@@ -2068,10 +2066,8 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 	memset(i40e_dbg_netdev_ops_buf, 0, sizeof(i40e_dbg_netdev_ops_buf));
 	bytes_not_copied = copy_from_user(i40e_dbg_netdev_ops_buf,
 					  buffer, count);
-	if (bytes_not_copied < 0)
-		return bytes_not_copied;
-	else if (bytes_not_copied > 0)
-		count -= bytes_not_copied;
+	if (bytes_not_copied)
+		return -EFAULT;
 	i40e_dbg_netdev_ops_buf[count] = '\0';
 
 	buf_tmp = strchr(i40e_dbg_netdev_ops_buf, '\n');
-- 
2.5.0
