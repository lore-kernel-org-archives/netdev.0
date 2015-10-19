From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 10/17] i40e: Fix for Tools loopback test failing after driver load
Date: Mon, 19 Oct 2015 15:49:24 -0700
Message-ID: <1445294971-44714-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12471 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbbJSWtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Oct 2015 18:49:36 -0400
In-Reply-To: <1445294971-44714-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
index e0142de..5157be5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10630,6 +10630,7 @@ err_dma:
 static void i40e_remove(struct pci_dev *pdev)
 {
 	struct i40e_pf *pf = pci_get_drvdata(pdev);
+	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret_code;
 	int i;
 
@@ -10637,6 +10638,10 @@ static void i40e_remove(struct pci_dev *pdev)
 
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
