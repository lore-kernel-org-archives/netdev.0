From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 03/14] e1000e: 82571 check for link fix on 82571
	serdes
Date: Fri, 21 Nov 2008 10:59:39 -0800
Message-ID: <20081121185939.32313.20366.stgit@gitlost.lost>
References: <20081121185859.32313.42332.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:41881 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751761AbYKUTAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 14:00:01 -0500
In-Reply-To: <20081121185859.32313.42332.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Check for link test does not work properly for 82571 parts in a blade
environment with an unterminated serdes link partner.  Make the test more
robust by checking the invalid bit.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/lib.c |   34 ++++++++++++++++++++++++++++------
 1 files changed, 28 insertions(+), 6 deletions(-)

diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 089578f..37753d1 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -575,20 +575,42 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 		 */
 		/* SYNCH bit and IV bit are sticky. */
 		udelay(10);
-		if (E1000_RXCW_SYNCH & er32(RXCW)) {
+		rxcw = er32(RXCW);
+		if (rxcw & E1000_RXCW_SYNCH) {
 			if (!(rxcw & E1000_RXCW_IV)) {
-				mac->serdes_has_link = 1;
-				hw_dbg(hw, "SERDES: Link is up.\n");
+				mac->serdes_has_link = true;
+				hw_dbg(hw, "SERDES: Link up - forced.\n");
 			}
 		} else {
-			mac->serdes_has_link = 0;
-			hw_dbg(hw, "SERDES: Link is down.\n");
+			mac->serdes_has_link = false;
+			hw_dbg(hw, "SERDES: Link down - force failed.\n");
 		}
 	}
 
 	if (E1000_TXCW_ANE & er32(TXCW)) {
 		status = er32(STATUS);
-		mac->serdes_has_link = (status & E1000_STATUS_LU);
+		if (status & E1000_STATUS_LU) {
+			/* SYNCH bit and IV bit are sticky, so reread rxcw.  */
+			udelay(10);
+			rxcw = er32(RXCW);
+			if (rxcw & E1000_RXCW_SYNCH) {
+				if (!(rxcw & E1000_RXCW_IV)) {
+					mac->serdes_has_link = true;
+					hw_dbg(hw, "SERDES: Link up - autoneg "
+					   "completed sucessfully.\n");
+				} else {
+					mac->serdes_has_link = false;
+					hw_dbg(hw, "SERDES: Link down - invalid"
+					   "codewords detected in autoneg.\n");
+				}
+			} else {
+				mac->serdes_has_link = false;
+				hw_dbg(hw, "SERDES: Link down - no sync.\n");
+			}
+		} else {
+			mac->serdes_has_link = false;
+			hw_dbg(hw, "SERDES: Link down - autoneg failed\n");
+		}
 	}
 
 	return 0;

