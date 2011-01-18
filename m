From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 2/8] bnx2x: Common init will be executed only
 once after POR
Date: Tue, 18 Jan 2011 16:33:24 +0200
Message-ID: <1295361204.5281.85.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3540 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab1AROcw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Common init used to be called by the driver when the first port comes up, mainly to reset and reload external PHY microcode. 
However, in case management driver is active on the other port, traffic would halted. So limit the common init to be done only once after POR.


Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 77f9eb1..bdf3c67 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7958,6 +7958,7 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
 			 u32 shmem2_base_path[], u32 chip_id)
 {
 	u8 rc = 0;
+	u32 phy_ver;
 	u8 phy_index;
 	u32 ext_phy_type, ext_phy_config;
 	DP(NETIF_MSG_LINK, "Begin common phy init\n");
@@ -7965,6 +7966,16 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base_path[],
 	if (CHIP_REV_IS_EMUL(bp))
 		return 0;
 
+	/* Check if common init was already done */
+	phy_ver = REG_RD(bp, shmem_base_path[0] +
+			 offsetof(struct shmem_region,
+				  port_mb[PORT_0].ext_phy_fw_version));
+	if (phy_ver) {
+		DP(NETIF_MSG_LINK, "Not doing common init; phy ver is 0x%x\n",
+			       phy_ver);
+		return 0;
+	}
+
 	/* Read the ext_phy_type for arbitrary port(0) */
 	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
 	      phy_index++) {
-- 
1.7.1








