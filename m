From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] intel: i40e: fix confused code
Date: Sat, 17 Oct 2015 22:58:19 +0200
Message-ID: <1445115499-28728-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This code is pretty confused. The variable name 'bytes_not_copied'
clearly indicates that the programmer knew the semantics of
copy_{to,from}_user, but then the return value is checked for being
negative and used as a -Exxx return value.

I'm not sure this is the proper fix, but at least we get rid of the
dead code which pretended to check for access faults.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
There are other things worth looking at. i40e_dbg_netdev_ops_buf is a
static buffer of size 256, which can be filled from user space (in
i40e_dbg_netdev_ops_write). That function correctly checks that the
input is at most 255 bytes. However, in i40e_dbg_netdev_ops_read we
snprintf() it along a device name (and some white space) into
kmalloc'ed buffer, also of size 256. Hence the snprintf output can be
truncated, but snprintf() returns the total size that would be
generated - so when we then proceed to using that in copy_to_user(),
we may actually copy from beyond the allocated buffer, hence leaking a
little kernel data.

In i40e_dbg_command_write, we allocate a buffer based on count which
is user-supplied. While kmalloc() refuses completely insane sizes, we
may still allocate a few MB. Moreover, if allocation fails, returning
'count' is rather odd; -ENOMEM would make more sense.

 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index d7c15d17faa6..e9ecd3f9cafe 100644
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
@@ -995,12 +995,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
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
2.6.1
