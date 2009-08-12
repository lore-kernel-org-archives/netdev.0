From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 09/36] bnx2x: BCM8727 FW load
Date: Wed, 12 Aug 2009 21:23:01 +0300
Message-ID: <1250101381.27379.161.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1479 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585AbZHLSXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:23:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The BCM8727 is a dual port PHY. The FW must be loaded in a given order on all
designs - including those which swapped the ports (calling port number zero the
second port)

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index aee9fff..db4f3c0 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -6430,7 +6430,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 {
 	u8 ext_phy_addr[PORT_MAX];
-	s8 port;
+	s8 port, first_port, i;
 	u32 swap_val, swap_override;
 	DP(NETIF_MSG_LINK, "Executing BCM8727 common init\n");
 	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
@@ -6439,8 +6439,13 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	bnx2x_hw_reset(bp, 1 ^ (swap_val && swap_override));
 	msleep(5);
 
+	if (swap_val && swap_override)
+		first_port = PORT_0;
+	else
+		first_port = PORT_1;
+
 	/* PART1 - Reset both phys */
-	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
+	for (i = 0, port = first_port; i < PORT_MAX; i++, port = !port) {
 		/* Extract the ext phy address for the port */
 		u32 ext_phy_config = REG_RD(bp, shmem_base +
 					offsetof(struct shmem_region,
@@ -6470,7 +6475,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	msleep(150);
 
 	/* PART2 - Download firmware to both phys */
-	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
+	for (i = 0, port = first_port; i < PORT_MAX; i++, port = !port) {
 		u16 fw_ver1;
 
 		bnx2x_bcm8727_external_rom_boot(bp, port,
@@ -6482,16 +6487,13 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      MDIO_PMA_REG_ROM_VER1, &fw_ver1);
 		if (fw_ver1 == 0 || fw_ver1 == 0x4321) {
 			DP(NETIF_MSG_LINK,
-				 "bnx2x_8073_common_init_phy port %x:"
+				 "bnx2x_8727_common_init_phy port %x:"
 				 "Download failed. fw version = 0x%x\n",
 				 port, fw_ver1);
 			return -EINVAL;
 		}
-
 	}
 
-
-
 	return 0;
 }
 
-- 
1.5.4.3




