From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 8/9][BNX2]: Print management firmware version.
Date: Fri, 06 Jul 2007 20:30:31 -0700
Message-ID: <1183779031.5182.25.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4272 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753953AbXGGCiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:38:15 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Print management firmware version.

Add management firmware version for ethtool -i.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 3163868..a3ae3b0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5546,11 +5546,7 @@ bnx2_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 	strcpy(info->driver, DRV_MODULE_NAME);
 	strcpy(info->version, DRV_MODULE_VERSION);
 	strcpy(info->bus_info, pci_name(bp->pdev));
-	info->fw_version[0] = ((bp->fw_ver & 0xff000000) >> 24) + '0';
-	info->fw_version[2] = ((bp->fw_ver & 0xff0000) >> 16) + '0';
-	info->fw_version[4] = ((bp->fw_ver & 0xff00) >> 8) + '0';
-	info->fw_version[1] = info->fw_version[3] = '.';
-	info->fw_version[5] = 0;
+	strcpy(info->fw_version, bp->fw_version);
 }
 
 #define BNX2_REGDUMP_LEN		(32 * 1024)
@@ -6462,7 +6458,7 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
 	struct bnx2 *bp;
 	unsigned long mem_len;
-	int rc;
+	int rc, i, j;
 	u32 reg;
 	u64 dma_mask, persist_dma_mask;
 
@@ -6619,7 +6615,35 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_unmap;
 	}
 
-	bp->fw_ver = REG_RD_IND(bp, bp->shmem_base + BNX2_DEV_INFO_BC_REV);
+	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_DEV_INFO_BC_REV);
+	for (i = 0, j = 0; i < 3; i++) {
+		u8 num, k, skip0;
+
+		num = (u8) (reg >> (24 - (i * 8)));
+		for (k = 100, skip0 = 1; k >= 1; num %= k, k /= 10) {
+			if (num >= k || !skip0 || k == 1) {
+				bp->fw_version[j++] = (num / k) + '0';
+				skip0 = 0;
+			}
+		}
+		if (i != 2)
+			bp->fw_version[j++] = '.';
+	}
+	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_BC_STATE_CONDITION);
+	reg &= BNX2_CONDITION_MFW_RUN_MASK;
+	if (reg != BNX2_CONDITION_MFW_RUN_UNKNOWN &&
+	    reg != BNX2_CONDITION_MFW_RUN_NONE) {
+		int i;
+		u32 addr = REG_RD_IND(bp, bp->shmem_base + BNX2_MFW_VER_PTR);
+
+		bp->fw_version[j++] = ' ';
+		for (i = 0; i < 3; i++) {
+			reg = REG_RD_IND(bp, addr + i * 4);
+			reg = swab32(reg);
+			memcpy(&bp->fw_version[j], &reg, 4);
+			j += 4;
+		}
+	}
 
 	reg = REG_RD_IND(bp, bp->shmem_base + BNX2_PORT_HW_CFG_MAC_UPPER);
 	bp->mac_addr[0] = (u8) (reg >> 8);
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 6dca333..d8cd1af 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6660,7 +6660,7 @@ struct bnx2 {
 
 	u32			shmem_base;
 
-	u32			fw_ver;
+	char			fw_version[32];
 
 	int			pm_cap;
 	int			pcix_cap;
@@ -7036,6 +7036,8 @@ struct fw_info {
 #define BNX2_PORT_FEATURE_MBA_VLAN_TAG_MASK	 0xffff
 #define BNX2_PORT_FEATURE_MBA_VLAN_ENABLE	 0x10000
 
+#define BNX2_MFW_VER_PTR			0x00000014c
+
 #define BNX2_BC_STATE_RESET_TYPE		0x000001c0
 #define BNX2_BC_STATE_RESET_TYPE_SIG		 0x00005254
 #define BNX2_BC_STATE_RESET_TYPE_SIG_MASK	 0x0000ffff
@@ -7089,6 +7091,14 @@ struct fw_info {
 #define BNX2_BC_STATE_ERR_NO_RXP		 (BNX2_BC_STATE_SIGN | 0x0600)
 #define BNX2_BC_STATE_ERR_TOO_MANY_RBUF		 (BNX2_BC_STATE_SIGN | 0x0700)
 
+#define BNX2_BC_STATE_CONDITION			0x000001c8
+#define BNX2_CONDITION_MFW_RUN_UNKNOWN		 0x00000000
+#define BNX2_CONDITION_MFW_RUN_IPMI		 0x00002000
+#define BNX2_CONDITION_MFW_RUN_UMP		 0x00004000
+#define BNX2_CONDITION_MFW_RUN_NCSI		 0x00006000
+#define BNX2_CONDITION_MFW_RUN_NONE		 0x0000e000
+#define BNX2_CONDITION_MFW_RUN_MASK		 0x0000e000
+
 #define BNX2_BC_STATE_DEBUG_CMD			0x1dc
 #define BNX2_BC_STATE_BC_DBG_CMD_SIGNATURE	 0x42440000
 #define BNX2_BC_STATE_BC_DBG_CMD_SIGNATURE_MASK	 0xffff0000


