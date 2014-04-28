From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e/i40evf: add driver version string to driver version command
Date: Mon, 28 Apr 2014 06:52:28 -0700
Message-ID: <1398693158-2815-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60866 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753026AbaD1Nwo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 09:52:44 -0400
In-Reply-To: <1398693158-2815-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

The driver version string was added to this struct to be passed
down through the firmware to low-level NC-SI functions. We tell
the firmware about the length of the ASCII string not counting
any terminating null.

Change-ID: I09ac98ff9b869e8661c55fc6a5c98808fc280c91
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Anjali Singhai <anjali.singhai@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 10 +++++++++-
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  1 +
 drivers/net/ethernet/intel/i40e/i40e_type.h   |  1 +
 drivers/net/ethernet/intel/i40evf/i40e_type.h |  1 +
 4 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index f8dfb4b..fde5aef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -1300,6 +1300,7 @@ i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
 	struct i40e_aqc_driver_version *cmd =
 		(struct i40e_aqc_driver_version *)&desc.params.raw;
 	i40e_status status;
+	int len;
 
 	if (dv == NULL)
 		return I40E_ERR_PARAM;
@@ -1311,7 +1312,14 @@ i40e_status i40e_aq_send_driver_version(struct i40e_hw *hw,
 	cmd->driver_minor_ver = dv->minor_version;
 	cmd->driver_build_ver = dv->build_version;
 	cmd->driver_subbuild_ver = dv->subbuild_version;
-	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
+
+	len = 0;
+	while (len < sizeof(dv->driver_string) &&
+	       (dv->driver_string[len] < 0x80) &&
+	       dv->driver_string[len])
+		len++;
+	status = i40e_asq_send_command(hw, &desc, dv->driver_string,
+				       len, cmd_details);
 
 	return status;
 }
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 4fe15d5..6f00de4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8394,6 +8394,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dv.minor_version = DRV_VERSION_MINOR;
 	dv.build_version = DRV_VERSION_BUILD;
 	dv.subbuild_version = 0;
+	strncpy(dv.driver_string, DRV_VERSION, sizeof(dv.driver_string));
 	i40e_aq_send_driver_version(&pf->hw, &dv, NULL);
 
 	/* since everything's happy, start the service_task timer */
diff --git a/drivers/net/ethernet/intel/i40e/i40e_type.h b/drivers/net/ethernet/intel/i40e/i40e_type.h
index 71a968f..668acc7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_type.h
@@ -409,6 +409,7 @@ struct i40e_driver_version {
 	u8 minor_version;
 	u8 build_version;
 	u8 subbuild_version;
+	u8 driver_string[32];
 };
 
 /* RX Descriptors */
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_type.h b/drivers/net/ethernet/intel/i40evf/i40e_type.h
index 4673b33..449a3be 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_type.h
+++ b/drivers/net/ethernet/intel/i40evf/i40e_type.h
@@ -415,6 +415,7 @@ struct i40e_driver_version {
 	u8 minor_version;
 	u8 build_version;
 	u8 subbuild_version;
+	u8 driver_string[32];
 };
 
 /* RX Descriptors */
-- 
1.9.0
