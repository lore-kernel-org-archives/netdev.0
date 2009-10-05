From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 13/15] igb: add code to retry a phy read in the
	event of failure on link check
Date: Mon, 05 Oct 2009 09:35:23 -0700
Message-ID: <20091005163522.32487.5411.stgit@localhost.localdomain>
References: <20091005163058.32487.10125.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:36946
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754031AbZJEQhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 12:37:33 -0400
In-Reply-To: <20091005163058.32487.10125.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds a retry to phy reads in the event of failure.  The original
code broke out of the loop on failure and this is a mistake as we should be
trying to do the read twice.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_phy.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_phy.c b/drivers/net/igb/e1000_phy.c
index b27275d..5fe03e1 100644
--- a/drivers/net/igb/e1000_phy.c
+++ b/drivers/net/igb/e1000_phy.c
@@ -1444,8 +1444,14 @@ s32 igb_phy_has_link(struct e1000_hw *hw, u32 iterations,
 		 * it across the board.
 		 */
 		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
-		if (ret_val)
-			break;
+		if (ret_val) {
+			/*
+			 * If the first read fails, another entity may have
+			 * ownership of the resources, wait and try again to
+			 * see if they have relinquished the resources yet.
+			 */
+			udelay(usec_interval);
+		}
 		ret_val = hw->phy.ops.read_reg(hw, PHY_STATUS, &phy_status);
 		if (ret_val)
 			break;

