From: Michal Nazarewicz <mina86@mina86.com>
Subject: [PATCHv2] net: wireless: iwlwifi: remove minor dead code
Date: Sun, 10 Nov 2013 21:17:56 +0100
Message-ID: <87iow080zv.fsf@mina86.com>
References: <1384110397-24386-1-git-send-email-mpn@google.com> <527FDB50.1050902@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f50.google.com ([74.125.83.50]:42452 "EHLO
	mail-ee0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab3KJUSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Nov 2013 15:18:01 -0500
In-Reply-To: <527FDB50.1050902@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


inta is checked to be zero in a IRQ_NONE branch so afterwards it
cannot be zero as it is never modified.
---
 drivers/net/wireless/iwlwifi/pcie/rx.c | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

On Sun, Nov 10 2013, Sergei Shtylyov wrote:
> The preferred way of formatting the multi-line comments in the
> networking code is this:
>
> /* bla
>   * bla
>   */

Works for me.  I used /* bla \n * bla */ because this is what the rest
of this function was using.

diff --git a/drivers/net/wireless/iwlwifi/pcie/rx.c b/drivers/net/wireless/iwlwifi/pcie/rx.c
index 3f237b4..7d0fdc0 100644
--- a/drivers/net/wireless/iwlwifi/pcie/rx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/rx.c
@@ -1121,7 +1121,6 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 	struct iwl_trans *trans = data;
 	struct iwl_trans_pcie *trans_pcie = IWL_TRANS_GET_PCIE_TRANS(trans);
 	u32 inta, inta_mask;
-	irqreturn_t ret = IRQ_NONE;
 
 	lockdep_assert_held(&trans_pcie->irq_lock);
 
@@ -1150,7 +1149,14 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 	 * or due to sporadic interrupts thrown from our NIC. */
 	if (!inta) {
 		IWL_DEBUG_ISR(trans, "Ignore interrupt, inta == 0\n");
-		goto none;
+		/* re-enable interrupts here since we don't have anything to
+		 * service.  only Re-enable if disabled by irq and no
+		 * schedules tasklet.
+		 */
+		if (test_bit(STATUS_INT_ENABLED, &trans_pcie->status) &&
+		    !trans_pcie->inta)
+			iwl_enable_interrupts(trans);
+		return IRQ_NONE;
 	}
 
 	if ((inta == 0xFFFFFFFF) || ((inta & 0xFFFFFFF0) == 0xa5a5a5a0)) {
@@ -1168,19 +1174,7 @@ static irqreturn_t iwl_pcie_isr(int irq, void *data)
 
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
