From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/12] e1000e: Release mutex lock only if it has been initially acquired
Date: Tue, 21 May 2013 15:03:11 -0700
Message-ID: <1369173800-20326-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30025 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640Ab3EUWD1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 May 2013 18:03:27 -0400
In-Reply-To: <1369173800-20326-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Akeem G. Abodunrin" <akeem.g.abodunrin@intel.com>

This patch fixes the issue of unlocking swflag_mutex for 82574 and 82583
devices regardless of if the hw semaphore has been successfully acquired via
e1000_get_hw_semaphore_82574(). With this patch, unlocking mutex now depends
on if the hw semaphore was successfully acquired before. And 82574/82583
devices are reset regardless of whether e1000_get_hw_semaphore_82574()
returns success or failure.

Reported-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index bef2f10..4c303e2 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1003,8 +1003,6 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	default:
 		break;
 	}
-	if (ret_val)
-		e_dbg("Cannot acquire MDIO ownership\n");
 
 	ctrl = er32(CTRL);
 
@@ -1015,7 +1013,9 @@ static s32 e1000_reset_hw_82571(struct e1000_hw *hw)
 	switch (hw->mac.type) {
 	case e1000_82574:
 	case e1000_82583:
-		e1000_put_hw_semaphore_82574(hw);
+		/* Release mutex only if the hw semaphore is acquired */
+		if (!ret_val)
+			e1000_put_hw_semaphore_82574(hw);
 		break;
 	default:
 		break;
-- 
1.7.11.7
