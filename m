From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] i40e: Fix for Tools loopback test failing after driver load
Date: Fri, 16 Oct 2015 22:28:24 -0700
Message-ID: <1445059711-45992-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27590 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751252AbbJQF2m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:42 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem where our Tools MAC Loopback test, after
driver unbind would fail.  This was because the hw was configured
for multiqueue and unbind operation did not clear this configuration.
The problem is fixed by resetting this configuration in i40e_remove.

Change-ID: I130c05138319182ed1476d3a0b5222d6a6320af9
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b105da1..9b4fa3e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10650,6 +10650,7 @@ err_dma:
 static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
+	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret_code;
 	int i;
 
@@ -10657,6 +10658,10 @@ static void i40e_remove(struct pci_dev *pdev)
 
 	i40e_ptp_stop(pf);
 
+	/* Disable RSS in hw */
+	wr32(hw, I40E_PFQF_HENA(0), 0);
+	wr32(hw, I40E_PFQF_HENA(1), 0);
+
 	/* no more scheduling of any task */
 	set_bit(__I40E_DOWN, &pf->state);
 	del_timer_sync(&pf->service_timer);
-- 
2.4.3
