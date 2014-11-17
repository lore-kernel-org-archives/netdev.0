From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 2/4] igb: do not clobber the TSAUXC bits on reset.
Date: Tue, 18 Nov 2014 00:06:23 +0100
Message-ID: <5c892a6a13d120193fdbd2dd62e9604ae0d5d404.1416265321.git.richardcochran@gmail.com>
References: <cover.1416265321.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>, <bruce.w.allan@intel.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:64749 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbaKQXGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 18:06:35 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so10853853wid.0
        for <netdev@vger.kernel.org>; Mon, 17 Nov 2014 15:06:33 -0800 (PST)
In-Reply-To: <cover.1416265321.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TSAUXC register has a number of different bits, one of which disables
the main clock function. Previously, the clock was re-enabled by clearing
the entire register. This patch changes the code to preserve the values
of the other bits in that register.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 794c139..ce57128 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -905,6 +905,8 @@ void igb_ptp_stop(struct igb_adapter *adapter)
 void igb_ptp_reset(struct igb_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
+	unsigned long flags;
+	u32 tsauxc;
 
 	if (!(adapter->flags & IGB_FLAG_PTP))
 		return;
@@ -923,7 +925,11 @@ void igb_ptp_reset(struct igb_adapter *adapter)
 	case e1000_i210:
 	case e1000_i211:
 		/* Enable the timer functions and interrupts. */
-		wr32(E1000_TSAUXC, 0x0);
+		spin_lock_irqsave(&adapter->tmreg_lock, flags);
+		tsauxc = rd32(E1000_TSAUXC);
+		tsauxc &= ~TSAUXC_DISABLE;
+		wr32(E1000_TSAUXC, tsauxc);
+		spin_unlock_irqrestore(&adapter->tmreg_lock, flags);
 		wr32(E1000_TSIM, TSYNC_INTERRUPTS);
 		wr32(E1000_IMS, E1000_IMS_TS);
 		break;
-- 
1.7.10.4
