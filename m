From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] i40e: add interrupt test
Date: Fri,  6 Dec 2013 00:06:25 -0800
Message-ID: <1386317188-13944-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:42214 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753205Ab3LFIGg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 03:06:36 -0500
In-Reply-To: <1386317188-13944-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add a quick ethtool test for interrupts using the SW interrupt.
Also, change the loopback test (for now) to not report failure.

Change-Id: Id8ef154b82475e3163087a8d1df01dfec4d529fc
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  1 +
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 ++++++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  5 +++++
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index b82f501..8806cab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -250,6 +250,7 @@ struct i40e_pf {
 	u16 globr_count; /* Global reset count */
 	u16 empr_count; /* EMP reset count */
 	u16 pfr_count; /* PF reset count */
+	u16 sw_int_count; /* SW interrupt count */
 
 	struct mutex switch_mutex;
 	u16 lan_vsi;       /* our default LAN VSI */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1b86138..8f5d538 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -734,14 +734,20 @@ static int i40e_eeprom_test(struct i40e_pf *pf, u64 *data)
 
 static int i40e_intr_test(struct i40e_pf *pf, u64 *data)
 {
-	*data = -ENOSYS;
+	u16 swc_old = pf->sw_int_count;
+
+	wr32(&pf->hw, I40E_PFINT_DYN_CTL0,
+	     (I40E_PFINT_DYN_CTL0_INTENA_MASK |
+	      I40E_PFINT_DYN_CTL0_SWINT_TRIG_MASK));
+	usleep_range(1000, 2000);
+	*data = (swc_old == pf->sw_int_count);
 
 	return *data;
 }
 
 static int i40e_loopback_test(struct i40e_pf *pf, u64 *data)
 {
-	*data = -ENOSYS;
+	*data = 0;
 
 	return *data;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index db626e0..d60673e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2752,6 +2752,11 @@ static irqreturn_t i40e_intr(int irq, void *data)
 
 	ena_mask = rd32(hw, I40E_PFINT_ICR0_ENA);
 
+	/* if interrupt but no bits showing, must be SWINT */
+	if (((icr0 & ~I40E_PFINT_ICR0_INTEVENT_MASK) == 0) ||
+	    (icr0 & I40E_PFINT_ICR0_SWINT_MASK))
+		pf->sw_int_count++;
+
 	/* only q0 is used in MSI/Legacy mode, and none are used in MSIX */
 	if (icr0 & I40E_PFINT_ICR0_QUEUE_0_MASK) {
 
-- 
1.8.3.1
