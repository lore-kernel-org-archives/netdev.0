From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  06/14] i40e: clamp debugfs nvm read command
Date: Fri, 18 Oct 2013 06:23:10 -0700
Message-ID: <1382102598-11343-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41785 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496Ab3JRNXl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:41 -0400
In-Reply-To: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

This issue was identified by the coverity checker where we were
not checking the upper limit on reads, reported by Hannes
Frederic Sowa.

Implement more specific limits on reads (min 1k, max 4k)

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 304f39d..c80fcb4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1742,11 +1742,13 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			goto command_write_done;
 		}
 
-		/* Read at least 512 words */
-		if (buffer_len == 0)
-			buffer_len = 512;
+		/* set the max length */
+		buffer_len = min_t(u16, buffer_len, I40E_MAX_AQ_BUF_SIZE/2);
 
 		bytes = 2 * buffer_len;
+
+		/* read at least 1k bytes, no more than 4kB */
+		bytes = clamp(bytes, (u16)1024, (u16)I40E_MAX_AQ_BUF_SIZE);
 		buff = kzalloc(bytes, GFP_KERNEL);
 		if (!buff)
 			goto command_write_done;
-- 
1.8.3.1
