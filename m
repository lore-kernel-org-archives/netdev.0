From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] i40evf: quoth the VF driver, Nevermore
Date: Wed,  2 Dec 2015 00:25:30 -0800
Message-ID: <1449044735-68599-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:5698 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753762AbbLBIZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2015 03:25:42 -0500
In-Reply-To: <1449044735-68599-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

If, upon a midnight dreary, the PF returns ERR_PARAM when the VF is
requesting resources, that's fatal. Either the firmware or NVM is badly,
badly misconfigured, or this VF has been disabled due to a previous VF
driver sending a bunch of bogus messages.

Either way, there is no recovery from this. Don't ponder weak and weary,
just quit.

Change-ID: I09d9f16cc4ee7fec3b57646a289d33838c1c5bf5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1cd5d5d..8476fc5 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2435,6 +2435,14 @@ static void i40evf_init_task(struct work_struct *work)
 		if (err == I40E_ERR_ADMIN_QUEUE_NO_WORK) {
 			err = i40evf_send_vf_config_msg(adapter);
 			goto err;
+		} else if (err == I40E_ERR_PARAM) {
+			/* We only get ERR_PARAM if the device is in a very bad
+			 * state or if we've been disabled for previous bad
+			 * behavior. Either way, we're done now.
+			 */
+			i40evf_shutdown_adminq(hw);
+			dev_err(&pdev->dev, "Unable to get VF config due to PF error condition, not retrying\n");
+			return;
 		}
 		if (err) {
 			dev_err(&pdev->dev, "Unable to get VF config (%d)\n",
-- 
2.5.0
