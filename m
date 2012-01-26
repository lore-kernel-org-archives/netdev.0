From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next 05/10] bnx2x: Loaded Firmware Version
 Validation
Date: Thu, 26 Jan 2012 18:01:49 +0200
Message-ID: <1327593714-18358-6-git-send-email-ariele@broadcom.com>
References: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4709 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752694Ab2AZQB7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jan 2012 11:01:59 -0500
In-Reply-To: <1327593714-18358-1-git-send-email-ariele@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In a virtualized environment it is possible for a loading driver to discover
that Firmware is already loaded to the device, and that this FW does not match
its own. This can happen for example if different Physical Functions are
Assigned to different VMs in which different driver versions are loaded. The
code in this patch ensures that only drivers with matching FW are loaded over
the device, and that in the case described above where the Firmware version
doesn't match the driver load is aborted.

Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 03f3935..b75c8ea 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1783,6 +1783,29 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 			rc = -EBUSY; /* other port in diagnostic mode */
 			LOAD_ERROR_EXIT(bp, load_error1);
 		}
+		if (load_code != FW_MSG_CODE_DRV_LOAD_COMMON_CHIP &&
+		    load_code != FW_MSG_CODE_DRV_LOAD_COMMON) {
+			/* build FW version dword */
+			u32 my_fw = (BCM_5710_FW_MAJOR_VERSION) +
+					(BCM_5710_FW_MINOR_VERSION << 8) +
+					(BCM_5710_FW_REVISION_VERSION << 16) +
+					(BCM_5710_FW_ENGINEERING_VERSION << 24);
+
+			/* read loaded FW from chip */
+			u32 loaded_fw = REG_RD(bp, XSEM_REG_PRAM);
+
+			DP(BNX2X_MSG_SP, "loaded fw %x, my fw %x",
+			   loaded_fw, my_fw);
+
+			/* abort nic load if version mismatch */
+			if (my_fw != loaded_fw) {
+				BNX2X_ERR("bnx2x with FW %x already loaded, "
+					  "which mismatches my %x FW. aborting",
+					  loaded_fw, my_fw);
+				rc = -EBUSY;
+				LOAD_ERROR_EXIT(bp, load_error2);
+			}
+		}
 
 	} else {
 		int path = BP_PATH(bp);
-- 
1.7.1
