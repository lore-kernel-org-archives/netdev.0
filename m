From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/18] i40evf: Add additional check for reset
Date: Tue,  5 Apr 2016 13:17:33 -0700
Message-ID: <1459887455-146634-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28348 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933446AbcDEURm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:17:42 -0400
In-Reply-To: <1459887455-146634-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If the driver happens to read a register during the time in which the
device is undergoing reset, it will receive a value of 0xdeadbeef
instead of a valid value. Unfortunately, the driver may misinterpret
this as a valid value, especially if it's just looking for individual
bits.

Add an explicit check for this value when we are looking for admin queue
errors, and trigger reset recovery if we find it.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 820ad94..d783c1b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1994,6 +1994,8 @@ static void i40evf_adminq_task(struct work_struct *work)
 
 	/* check for error indications */
 	val = rd32(hw, hw->aq.arq.len);
+	if (val == 0xdeadbeef) /* indicates device in reset */
+		goto freedom;
 	oldval = val;
 	if (val & I40E_VF_ARQLEN1_ARQVFE_MASK) {
 		dev_info(&adapter->pdev->dev, "ARQ VF Error detected\n");
-- 
2.5.5
