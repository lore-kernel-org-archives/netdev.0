From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [net-next PATCH 3/5] be2net: Fix broadcast echoes from EVB in BE3
Date: Wed, 22 Jun 2016 08:54:55 -0400
Message-ID: <1466600097-1641-4-git-send-email-sathya.perla@broadcom.com>
References: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [192.19.245.250] ([192.19.245.250]:62538 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751244AbcFVMzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 08:55:20 -0400
In-Reply-To: <1466600097-1641-1-git-send-email-sathya.perla@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Somnath Kotur <somnath.kotur@emulex.com>

On SR-IOV profiles, when the user connects a Linux Bridge or OVS to a BE3
vport, they suffer the "broadcast/multicast echo" problem. BE3 EVB echoes
broadcast and multicast packets back to PF's vport confusing the
Linux bridge.  BE3 relies on the src-mac addr being programmed on the
interface to avoid sending back an echo of a broadcast or multicast packet
on a vPort. When a Linux bridge is connected to a BE3, the mac-addr of the
VM behind the bridge doesn't get configured on the vPort and so echo
cancellation doesn't work.
This patch worksaround this problem by disabling the EVB initially
and re-enabling it *only* when SR-IOV is enabled by the user. For the
driver fix to work, the BE3 FW version must be >= 11.1.84.0.

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 11 ++++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c | 23 +++++++++++++++++++++++
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 29aeb91..a98b6ab 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -87,6 +87,11 @@ static struct be_cmd_priv_map cmd_priv_map[] = {
 		CMD_SUBSYSTEM_LOWLEVEL,
 		BE_PRIV_DEVCFG | BE_PRIV_DEVSEC
 	},
+	{
+		OPCODE_COMMON_SET_HSW_CONFIG,
+		CMD_SUBSYSTEM_COMMON,
+		BE_PRIV_DEVCFG | BE_PRIV_VHADM
+	},
 };
 
 static bool be_cmd_allowed(struct be_adapter *adapter, u8 opcode, u8 subsystem)
@@ -3850,6 +3855,10 @@ int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 	void *ctxt;
 	int status;
 
+	if (!be_cmd_allowed(adapter, OPCODE_COMMON_SET_HSW_CONFIG,
+			    CMD_SUBSYSTEM_COMMON))
+		return -EPERM;
+
 	spin_lock_bh(&adapter->mcc_lock);
 
 	wrb = wrb_from_mccq(adapter);
@@ -3871,7 +3880,7 @@ int be_cmd_set_hsw_config(struct be_adapter *adapter, u16 pvid,
 		AMAP_SET_BITS(struct amap_set_hsw_context, pvid_valid, ctxt, 1);
 		AMAP_SET_BITS(struct amap_set_hsw_context, pvid, ctxt, pvid);
 	}
-	if (!BEx_chip(adapter) && hsw_mode) {
+	if (hsw_mode) {
 		AMAP_SET_BITS(struct amap_set_hsw_context, interface_id,
 			      ctxt, adapter->hba_port_num);
 		AMAP_SET_BITS(struct amap_set_hsw_context, pport, ctxt, 1);
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a654c12..f11a19b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -3729,6 +3729,11 @@ static void be_vf_clear(struct be_adapter *adapter)
 
 		be_cmd_if_destroy(adapter, vf_cfg->if_handle, vf + 1);
 	}
+
+	if (BE3_chip(adapter))
+		be_cmd_set_hsw_config(adapter, 0, 0,
+				      adapter->if_handle,
+				      PORT_FWD_TYPE_PASSTHRU, 0);
 done:
 	kfree(adapter->vf_cfg);
 	adapter->num_vfs = 0;
@@ -4019,6 +4024,15 @@ static int be_vf_setup(struct be_adapter *adapter)
 		}
 	}
 
+	if (BE3_chip(adapter)) {
+		/* On BE3, enable VEB only when SRIOV is enabled */
+		status = be_cmd_set_hsw_config(adapter, 0, 0,
+					       adapter->if_handle,
+					       PORT_FWD_TYPE_VEB, 0);
+		if (status)
+			goto err;
+	}
+
 	adapter->flags |= BE_FLAGS_SRIOV_ENABLED;
 	return 0;
 err:
@@ -4564,6 +4578,15 @@ static int be_setup(struct be_adapter *adapter)
 		be_cmd_set_logical_link_config(adapter,
 					       IFLA_VF_LINK_STATE_AUTO, 0);
 
+	/* BE3 EVB echoes broadcast/multicast packets back to PF's vport
+	 * confusing a linux bridge or OVS that it might be connected to.
+	 * Set the EVB to PASSTHRU mode which effectively disables the EVB
+	 * when SRIOV is not enabled.
+	 */
+	if (BE3_chip(adapter))
+		be_cmd_set_hsw_config(adapter, 0, 0, adapter->if_handle,
+				      PORT_FWD_TYPE_PASSTHRU, 0);
+
 	if (adapter->num_vfs)
 		be_vf_setup(adapter);
 
-- 
2.4.1
