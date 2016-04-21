From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/17] fm10k: correctly handle LPORT_MAP error
Date: Wed, 20 Apr 2016 23:09:20 -0700
Message-ID: <1461218969-68578-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55438 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751324AbcDUGJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:34 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Currently, any error responses from the switch manager after an
LPORT_MAP request are silently ignored. At most the mailbox message will
be reported as an error. This can result in unexpected behavior when the
switch manager has configured a port with zero bandwidth. Add support
for reading the fm10k_swapi_error structure from LPORT_MAP responses.

If the message contains the necessary TLV and has a non-zero error code,
report link down, clear the dglort_map, and delay the next
get_host_state call by a reasonable delay. Also log an error message
indicating that the LPORT_MAP request failed.

The delay ensures preventing an interrupt storm on the switch manager,
and reduces the number of mailbox messages we send in this scenario
drastically.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 31 +++++++++++++++++++++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_pf.c  |  2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_pf.h  |  2 ++
 4 files changed, 35 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index c21fa86..5efae40 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -330,6 +330,7 @@ struct fm10k_intfc {
 	unsigned long last_reset;
 	unsigned long link_down_event;
 	bool host_ready;
+	bool lport_map_failed;
 
 	u32 reta[FM10K_RETA_SIZE];
 	u32 rssrk[FM10K_RSSRK_SIZE];
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 29e9402..9055681 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1263,11 +1263,40 @@ static s32 fm10k_lport_map(struct fm10k_hw *hw, u32 **results,
 	u32 dglort_map = hw->mac.dglort_map;
 	s32 err;
 
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	err = fm10k_msg_err_pf(hw, results, mbx);
+	if (!err && hw->swapi.status) {
+		/* force link down for a reasonable delay */
+		interface->link_down_event = jiffies + (2 * HZ);
+		set_bit(__FM10K_LINK_DOWN, &interface->state);
+
+		/* reset dglort_map back to no config */
+		hw->mac.dglort_map = FM10K_DGLORTMAP_NONE;
+
+		fm10k_service_event_schedule(interface);
+
+		/* prevent overloading kernel message buffer */
+		if (interface->lport_map_failed)
+			return 0;
+
+		interface->lport_map_failed = true;
+
+		if (hw->swapi.status == FM10K_MSG_ERR_PEP_NOT_SCHEDULED)
+			dev_warn(&interface->pdev->dev,
+				 "cannot obtain link because the host interface is configured for a PCIe host interface bandwidth of zero\n");
+		dev_warn(&interface->pdev->dev,
+			 "request logical port map failed: %d\n",
+			 hw->swapi.status);
+
+		return 0;
+	}
+
 	err = fm10k_msg_lport_map_pf(hw, results, mbx);
 	if (err)
 		return err;
 
-	interface = container_of(hw, struct fm10k_intfc, hw);
+	interface->lport_map_failed = false;
 
 	/* we need to reset if port count was just updated */
 	if (dglort_map != hw->mac.dglort_map)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
index c8e8ce5..865f5c2 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.c
@@ -1620,6 +1620,8 @@ out:
 
 /* This structure defines the attibutes to be parsed below */
 const struct fm10k_tlv_attr fm10k_lport_map_msg_attr[] = {
+	FM10K_TLV_ATTR_LE_STRUCT(FM10K_PF_ATTR_ID_ERR,
+				 sizeof(struct fm10k_swapi_error)),
 	FM10K_TLV_ATTR_U32(FM10K_PF_ATTR_ID_LPORT_MAP),
 	FM10K_TLV_ATTR_LAST
 };
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
index b78210d..d4a3465 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pf.h
@@ -71,6 +71,8 @@ enum fm10k_pf_tlv_attr_id_v1 {
 #define FM10K_MSG_UPDATE_PVID_PVID_SHIFT	16
 #define FM10K_MSG_UPDATE_PVID_PVID_SIZE		16
 
+#define FM10K_MSG_ERR_PEP_NOT_SCHEDULED	280
+
 /* The following data structures are overlayed directly onto TLV mailbox
  * messages, and must not break 4 byte alignment. Ensure the structures line
  * up correctly as per their TLV definition.
-- 
2.5.5
