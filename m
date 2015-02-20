From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH] i40e: Fix memory leak at failure path in i40e_dbg_command_write()
Date: Sat, 21 Feb 2015 01:24:18 +0300
Message-ID: <1424471058-19933-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch fixes a leak of 'cmd_buf' when copy_from_user() failed
in i40e_dbg_command_write().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 61236f983971..c17ee77100d3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -989,8 +989,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	if (!cmd_buf)
 		return count;
 	bytes_not_copied = copy_from_user(cmd_buf, buffer, count);
-	if (bytes_not_copied < 0)
+	if (bytes_not_copied < 0) {
+		kfree(cmd_buf);
 		return bytes_not_copied;
+	}
 	if (bytes_not_copied > 0)
 		count -= bytes_not_copied;
 	cmd_buf[count] = '\0';
-- 
1.9.1
