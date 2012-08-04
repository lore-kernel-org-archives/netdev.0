From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [net 1/3] igb: Fix for failure to init on some 82576 devices.
Date: Sat,  4 Aug 2012 03:25:50 -0700
Message-ID: <1344075952-4198-2-git-send-email-peter.p.waskiewicz.jr@intel.com>
References: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:44124 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767Ab2HDK0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Aug 2012 06:26:31 -0400
In-Reply-To: <1344075952-4198-1-git-send-email-peter.p.waskiewicz.jr@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

Move nvm invalid size check to before size assigned by mac_type for
82575 and later parts in get_invariants function.  This fixes a problem
found on some 82576 devices where the part will not initialize because
the nvm_read function pointer ends up getting assigned to the incorrect
function.

Reported By: Stefan Assmann <sassmann@redhat.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 5e84eaa..ba994fb 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -254,6 +254,14 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	 */
 	size += NVM_WORD_SIZE_BASE_SHIFT;
 
+	/*
+	 * Check for invalid size
+	 */
+	if ((hw->mac.type == e1000_82576) && (size > 15)) {
+		pr_notice("The NVM size is not valid, defaulting to 32K\n");
+		size = 15;
+	}
+
 	nvm->word_size = 1 << size;
 	if (hw->mac.type < e1000_i210) {
 		nvm->opcode_bits        = 8;
@@ -281,14 +289,6 @@ static s32 igb_get_invariants_82575(struct e1000_hw *hw)
 	} else
 		nvm->type = e1000_nvm_flash_hw;
 
-	/*
-	 * Check for invalid size
-	 */
-	if ((hw->mac.type == e1000_82576) && (size > 15)) {
-		pr_notice("The NVM size is not valid, defaulting to 32K\n");
-		size = 15;
-	}
-
 	/* NVM Function Pointers */
 	switch (hw->mac.type) {
 	case e1000_82580:
-- 
1.7.10.4
