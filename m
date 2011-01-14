From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 1/3] e1000: Avoid unhandled IRQ
Date: Fri, 14 Jan 2011 03:42:28 -0800
Message-ID: <1295005350-28124-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1295005350-28124-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	stable@kernel.org, Tushar Dave <tushar.n.dave@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:8193 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751691Ab1ANLmc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 06:42:32 -0500
To: davem@davemloft.net
In-Reply-To: <1295005350-28124-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

If hardware asserted an interrupt and driver is down,
then there is nothing to do so return IRQ_HANDLED
instead of IRQ_NONE. Returning IRQ_NONE in above
situation causes screaming IRQ on virtual machines.

CC: Andy Gospodarek <gospo@redhat.com>
CC: stable@kernel.org
Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/e1000/e1000_main.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4ff88a6..e332aee 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3478,9 +3478,17 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 icr = er32(ICR);
 
-	if (unlikely((!icr) || test_bit(__E1000_DOWN, &adapter->flags)))
+	if (unlikely((!icr)))
 		return IRQ_NONE;  /* Not our interrupt */
 
+	/*
+	 * we might have caused the interrupt, but the above
+	 * read cleared it, and just in case the driver is
+	 * down there is nothing to do so return handled
+	 */
+	if (unlikely(test_bit(__E1000_DOWN, &adapter->flags)))
+		return IRQ_HANDLED;
+
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
 		/* guard against interrupt when we're going down */
-- 
1.7.3.4

