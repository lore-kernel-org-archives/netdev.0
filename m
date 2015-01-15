From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] i40e: use same check for Rx hang as for Rx timestamps
Date: Thu, 15 Jan 2015 04:19:25 -0800
Message-ID: <1421324368-6860-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64854 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751581AbbAOMTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2015 07:19:38 -0500
In-Reply-To: <1421324368-6860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It's possible that the user configured only Tx hardware timestamping,
and thus we might be receiving PTP traffic which we timestamp but which
software never reads. In this case we don't want to check for Rx
timestamp hang, because we already know that software won't be handling
them. Thus, we add the same check against pf->ptp_rx as we have in the
Rx timestamp code path.

Change-ID: I66486c8dba307facbff8eace4e52e2f083789d1b
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ptp.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ptp.c b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
index 4f69a84..a55d47e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ptp.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
@@ -247,7 +247,12 @@ void i40e_ptp_rx_hang(struct i40e_vsi *vsi)
 	u32 prttsyn_stat;
 	int n;
 
-	if (!(pf->flags & I40E_FLAG_PTP))
+	/* Since we cannot turn off the Rx timestamp logic if the device is
+	 * configured for Tx timestamping, we check if Rx timestamping is
+	 * configured. We don't want to spuriously warn about Rx timestamp
+	 * hangs if we don't care about the timestamps.
+	 */
+	if (!(pf->flags & I40E_FLAG_PTP) || !pf->ptp_rx)
 		return;
 
 	prttsyn_stat = rd32(hw, I40E_PRTTSYN_STAT_1);
-- 
1.9.3
