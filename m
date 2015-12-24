From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [net-next PATCH 05/10] be2net: log digital signature errors while flashing FW image
Date: Thu, 24 Dec 2015 04:26:27 -0500
Message-ID: <1450949192-4574-6-git-send-email-sathya.perla@avagotech.com>
References: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:64903 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753434AbbLXJno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 04:43:44 -0500
In-Reply-To: <1450949192-4574-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <suresh.reddy@avagotech.com>

>From FW version 11.0 onwards, the FW supports a new "secure mode" feature
(based on a jumper setting on the adapter.) In this mode, the FW image when
flashed is authenticated with a digital signature. This patch logs
appropriate error messages and return a status to ethtool when errors
relating to FW image authentication occur.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 11 +++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |  4 +++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index da3b398..6fb7873 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -2959,6 +2959,17 @@ flash:
 		} else if (status) {
 			dev_err(dev, "Flashing section type 0x%x failed\n",
 				img_type);
+			if (addl_status(status) ==
+			    MCC_ADDL_STATUS_MISSING_SIGNATURE) {
+				dev_err(dev,
+					"Digital signature missing in FW\n");
+				return -EINVAL;
+			} else if (addl_status(status) ==
+				   MCC_ADDL_STATUS_INVALID_SIGNATURE) {
+				dev_err(dev,
+					"Invalid digital signature in FW\n");
+				return -EINVAL;
+			}
 			return -EFAULT;
 		}
 	}
diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.h b/drivers/net/ethernet/emulex/benet/be_cmds.h
index 4b0ca99..16415ca 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.h
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.h
@@ -66,7 +66,9 @@ enum mcc_addl_status {
 	MCC_ADDL_STATUS_INSUFFICIENT_RESOURCES = 0x16,
 	MCC_ADDL_STATUS_FLASH_IMAGE_CRC_MISMATCH = 0x4d,
 	MCC_ADDL_STATUS_TOO_MANY_INTERFACES = 0x4a,
-	MCC_ADDL_STATUS_INSUFFICIENT_VLANS = 0xab
+	MCC_ADDL_STATUS_INSUFFICIENT_VLANS = 0xab,
+	MCC_ADDL_STATUS_INVALID_SIGNATURE = 0x56,
+	MCC_ADDL_STATUS_MISSING_SIGNATURE = 0x57
 };
 
 #define CQE_BASE_STATUS_MASK		0xFFFF
-- 
2.4.1
