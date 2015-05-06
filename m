From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH v2 net-next 4/9] be2net: check for INSUFFICIENT_VLANS error
Date: Wed,  6 May 2015 05:30:35 -0400
Message-ID: <1430904640-31918-5-git-send-email-sathya.perla@avagotech.com>
References: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:51843 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752399AbbEFJmn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 05:42:43 -0400
In-Reply-To: <1430904640-31918-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

When the FW runs out of vlan filters it can either return an
INSUFFICIENT_RESOURCES error or an INSUFFICIENT_VLANS error.
The driver currently checks only for the former error value.
This patch adds a check for the latter value too.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 1 +
 drivers/net/ethernet/emulex/benet/be_cmds.h | 3 ++-
 drivers/net/ethernet/emulex/benet/be_main.c | 3 ++-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index e630fe0..095b1dc 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -140,6 +140,7 @@ static bool be_skip_err_log(u8 opcode, u16 base_status, u16 addl_status)
 	if (base_status == MCC_STATUS_NOT_SUPPORTED ||
 	    base_status == MCC_STATUS_ILLEGAL_REQUEST ||
 	    addl_status == MCC_ADDL_STATUS_TOO_MANY_INTERFACES ||
+	    addl_status == MCC_ADDL_STATUS_INSUFFICIENT_VLANS ||
 	    (opcode == OPCODE_COMMON_WRITE_FLASHROM &&
 	    (base_status == MCC_STATUS_ILLEGAL_FIELD ||
 	     addl_status == MCC_ADDL_STATUS_FLASH_IMAGE_CRC_MISMATCH)))
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index cf5f855..5eccf87 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -65,7 +65,8 @@ enum mcc_base_status {
 enum mcc_addl_status {
 	MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES = 0x16,
 	MCC_ADDL_STATUS_FLASH_IMAGE_CRC_MISMATCH = 0x4d,
-	MCC_ADDL_STATUS_TOO_MANY_INTERFACES = 0x4a
+	MCC_ADDL_STATUS_TOO_MANY_INTERFACES = 0x4a,
+	MCC_ADDL_STATUS_INSUFFICIENT_VLANS = 0xab
 };
 
 #define CQE_BASE_STATUS_MASK		0xFFFF
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f426a15..b25c509 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1267,7 +1267,8 @@ static int be_vid_config(struct be_adapter *adapter)
 	if (status) {
 		dev_err(dev, "Setting HW VLAN filtering failed\n");
 		/* Set to VLAN promisc mode as setting VLAN filter failed */
-		if (addl_status(status) ==
+		if (addl_status(status) == MCC_ADDL_STATUS_INSUFFICIENT_VLANS ||
+		    addl_status(status) ==
 				MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES)
 			return be_set_vlan_promisc(adapter);
 	} else if (adapter->if_flags & BE_IF_FLAGS_VLAN_PROMISCUOUS) {
-- 
2.2.0
