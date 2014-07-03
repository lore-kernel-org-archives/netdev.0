From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/14] i40evf: invite vector 0 to the interrupt party
Date: Wed,  2 Jul 2014 19:40:24 -0700
Message-ID: <1404355233-30123-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56274 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754180AbaGCClN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Jul 2014 22:41:13 -0400
In-Reply-To: <1404355233-30123-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The i40evf_irq_enable and i40evf_fire_sw_interrupt functions were
unfairly discriminating against MSI-X vector 0, just because it doesn't
handle traffic. That doesn't mean it's not essential to the operation of
the driver. This change allows the watchdog to fire vector 0 via
software, which makes the driver tolerant of dropped interrupts on that
vector.

Buck up, vector 0! You can be part of our gang!

Change-ID: I37131d955018a6b3e711e1732d21428acd0d767e
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5f29e58..6186149 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -260,6 +260,12 @@ static void i40evf_fire_sw_int(struct i40evf_adapter *adapter,
 	int i;
 	uint32_t dyn_ctl;
 
+	if (mask & 1) {
+		dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTL01);
+		dyn_ctl |= I40E_VFINT_DYN_CTLN_SWINT_TRIG_MASK |
+			   I40E_VFINT_DYN_CTLN_CLEARPBA_MASK;
+		wr32(hw, I40E_VFINT_DYN_CTL01, dyn_ctl);
+	}
 	for (i = 1; i < adapter->num_msix_vectors; i++) {
 		if (mask & (1 << i)) {
 			dyn_ctl = rd32(hw, I40E_VFINT_DYN_CTLN1(i - 1));
@@ -278,6 +284,7 @@ void i40evf_irq_enable(struct i40evf_adapter *adapter, bool flush)
 {
 	struct i40e_hw *hw = &adapter->hw;
 
+	i40evf_misc_irq_enable(adapter);
 	i40evf_irq_enable_queues(adapter, ~0);
 
 	if (flush)
-- 
1.9.3
