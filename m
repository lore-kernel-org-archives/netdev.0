From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 01/13] i40e: Fix memory leak at failure path in i40e_dbg_command_write()
Date: Thu, 26 Feb 2015 07:03:37 -0800
Message-ID: <1424963029-4612-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53299 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753983AbbBZPD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:59 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Khoroshilov <khoroshilov@ispras.ru>

The patch fixes a leak of 'cmd_buf' when copy_from_user() failed
in i40e_dbg_command_write().

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 61236f9..c17ee77 100644
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
1.9.3
