From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [PATCH] e1000e: Intel 82571EB: Don't wait for MNG cycle on unmanaged chips
Date: Fri, 27 Aug 2010 15:10:06 -0400
Message-ID: <1282936206-17288-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Kyle Moffett <kyle@moffetthome.net>,
	Kyle Moffett <Kyle.D.Moffett@boeing.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Intel 82571EB chipset can be used in an unmanaged configuration as a
fast dual-port Gig-E controller.  Unfortunately a board constructed that
way would fail to correctly come up because the driver polls for the
completion of a management cycle that will never occur.

To resolve this problem, we disable the poll and error return on chips
whose EEPROMs indicate no management.  As a protection against
misconfigured chipsets, we still delay for the entire management poll
timeout.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/e1000e/82571.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index f654db9..36d736f 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -756,6 +756,13 @@ static s32 e1000_get_cfg_done_82571(struct e1000_hw *hw)
 {
 	s32 timeout = PHY_CFG_TIMEOUT;
 
+	/* Don't bother polling the management registers if unmanaged */
+	if (!e1000e_check_mng_mode(hw)) {
+		hw_dbg(hw, "Unmanaged chip... skipping MNG polling cycle\n");
+		mdelay(timeout);
+		return 0;
+	}
+
 	while (timeout) {
 		if (er32(EEMNGCTL) &
 		    E1000_NVM_CFG_DONE_PORT_0)
-- 
1.7.1
