From: Michal Nazarewicz <mpn@google.com>
Subject: [PATCH] net: wireless: iwlwifi: remove minor dead code
Date: Sun, 10 Nov 2013 20:06:37 +0100
Message-ID: <1384110397-24386-1-git-send-email-mpn@google.com>
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michal Nazarewicz <mina86@mina86.com>
To: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f170.google.com ([209.85.215.170]:41845 "EHLO
	mail-ea0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab3KJTGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 14:06:43 -0500
Received: by mail-ea0-f170.google.com with SMTP id q10so1827929eaj.15
        for <netdev@vger.kernel.org>; Sun, 10 Nov 2013 11:06:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Nazarewicz <mina86@mina86.com>

inta is checked to be zero in a IRQ_NONE branch so afterwards it
cannot be zero as it is never modified.

Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
---
 drivers/net/wireless/iwlwifi/pcie/rx.c | 23 ++++++++---------------
 1 file changed, 8 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/iwlwifi/pcie/rx.c
index 3f237b4..c32122a 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -1121,7 +1121,6 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 	struct iwl_trans *trans = data;
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
 	u32 inta, inta_mask;
-	irqreturn_t ret = IRQ_NONE;
 
 	lockdep_assert_held(&trans_pcie->irq_lock);
 
@@ -1150,7 +1149,13 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 	 * or due to sporadic interrupts thrown from our NIC. */
 	if (!inta) {
 		IWL_DEBUG_ISR(trans, "Ignore interrupt, inta == 0\n");
-		goto none;
+		/* re-enable interrupts here since we don't have anything to
+		 * service.  only Re-enable if disabled by irq and no
+		 * schedules tasklet. */
+		if (test_bit(STATUS_INT_ENABLED, &trans_pcie->status) &&
+		    !trans_pcie->inta)
+			iwl_enable_interrupts(trans);
+		return IRQ_NONE;
 	}
 
 	if ((inta == 0xFFFFFFFF) || ((inta & 0xFFFFFFF0) == 0xa5a5a5a0)) {
@@ -1168,19 +1173,7 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 
 	trans_pcie->inta |= inta;
 	/* the thread will service interrupts and re-enable them */
-	if (likely(inta))
-		return IRQ_WAKE_THREAD;
-
-	ret = IRQ_HANDLED;
-
-none:
-	/* re-enable interrupts here since we don't have anything to service. */
-	/* only Re-enable if disabled by irq  and no schedules tasklet. */
-	if (test_bit(STATUS_INT_ENABLED, &trans_pcie->status) &&
-	    !trans_pcie->inta)
-		iwl_enable_interrupts(trans);
-
-	return ret;
+	return IRQ_WAKE_THREAD;
 }
 
 /* interrupt handler using ict table, with this interrupt driver will
-- 
1.8.3.2
