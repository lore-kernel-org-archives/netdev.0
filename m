From: divy@chelsio.com
Subject: [PATCH 2.6.21 2/2] cxgb3 - PHY interrupts and GPIO pins.
Date: Tue, 17 Apr 2007 11:06:36 -0700
Message-ID: <20070417180636.17068.90012.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31492 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161301AbXDQSGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 14:06:39 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove assumption that PHY interrupts use GPIOs 3 and 5.
Deal with PHY interrupts connected to any GPIO pins.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |   18 ++++++++++++------
 1 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index d83f075..fb485d0 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1523,19 +1523,25 @@ static int mac_intr_handler(struct adapt
  */
 int t3_phy_intr_handler(struct adapter *adapter)
 {
-	static const int intr_gpio_bits[] = { 8, 0x20 };
-
+	u32 mask, gpi = adapter_info(adapter)->gpio_intr;
 	u32 i, cause = t3_read_reg(adapter, A_T3DBG_INT_CAUSE);
 
 	for_each_port(adapter, i) {
-		if (cause & intr_gpio_bits[i]) {
-			struct cphy *phy = &adap2pinfo(adapter, i)->phy;
-			int phy_cause = phy->ops->intr_handler(phy);
+		struct port_info *p = adap2pinfo(adapter, i);
+
+		mask = gpi - (gpi & (gpi - 1));
+		gpi -= mask;
+
+		if (!(p->port_type->caps & SUPPORTED_IRQ))
+			continue;
+
+		if (cause & mask) {
+			int phy_cause = p->phy.ops->intr_handler(&p->phy);
 
 			if (phy_cause & cphy_cause_link_change)
 				t3_link_changed(adapter, i);
 			if (phy_cause & cphy_cause_fifo_error)
-				phy->fifo_errors++;
+				p->phy.fifo_errors++;
 		}
 	}
 
