From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5] bnx2: Read firmware version from VPD.
Date: Thu, 3 Dec 2009 11:46:34 -0800
Message-ID: <1259869595-6450-4-git-send-email-mchan@broadcom.com>
References: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4591 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686AbZLCTjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 14:39:23 -0500
In-Reply-To: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And display it through ethtool -i.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |  102 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 99 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index dba3840..b7bc74b 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7722,6 +7722,93 @@ bnx2_get_pci_speed(struct bnx2 *bp)
 
 }
 
+static void __devinit
+bnx2_read_vpd_fw_ver(struct bnx2 *bp)
+{
+	int rc, i, v0_len = 0;
+	u8 *data;
+	u8 *v0_str = NULL;
+	bool mn_match = false;
+
+#define BNX2_MAX_VER_SLEN	30
+
+	data = kmalloc(256, GFP_KERNEL);
+	if (!data)
+		return;
+
+	rc = bnx2_nvram_read(bp, 0x300, data + 128, 128);
+	if (rc)
+		goto vpd_done;
+
+	for (i = 0; i < 128; i += 4) {
+		data[i] = data[i + 131];
+		data[i + 1] = data[i + 130];
+		data[i + 2] = data[i + 129];
+		data[i + 3] = data[i + 128];
+	}
+
+	for (i = 0; i < 128; ) {
+		unsigned char val = data[i];
+		unsigned int block_end;
+
+		if (val == 0x82 || val == 0x91) {
+			i = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
+			continue;
+		}
+
+		if (val != 0x90)
+			goto vpd_done;
+
+		block_end = (i + 3 + (data[i + 1] + (data[i + 2] << 8)));
+		i += 3;
+
+		if (block_end > 128)
+			goto vpd_done;
+
+		while (i < (block_end - 2)) {
+			if (data[i] == 'M' && data[i + 1] == 'N') {
+				int mn_len = data[i + 2];
+
+				if (mn_len != 4)
+					goto vpd_done;
+
+				i += 3;
+				if (memcmp(&data[i], "1028", 4))
+					goto vpd_done;
+				mn_match = true;
+				i += 4;
+
+			} else if (data[i] == 'V' && data[i + 1] == '0') {
+				v0_len = data[i + 2];
+
+				i += 3;
+				if (v0_len > BNX2_MAX_VER_SLEN ||
+				    (v0_len + i) > 128)
+					goto vpd_done;
+
+				if (v0_len > BNX2_MAX_VER_SLEN)
+					v0_len = BNX2_MAX_VER_SLEN;
+
+				v0_str = &data[i];
+				i += data[i + 2];
+
+			} else {
+				i += 3 + data[i + 2];
+			}
+
+			if (mn_match && v0_str) {
+				memcpy(bp->fw_version, v0_str, v0_len);
+				bp->fw_version[v0_len] = ' ';
+				goto vpd_done;
+			}
+		}
+		goto vpd_done;
+	}
+
+vpd_done:
+	kfree(data);
+}
+
 static int __devinit
 bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 {
@@ -7895,10 +7982,18 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 		goto err_out_unmap;
 	}
 
+	bnx2_read_vpd_fw_ver(bp);
+
+	j = strlen(bp->fw_version);
 	reg = bnx2_shmem_rd(bp, BNX2_DEV_INFO_BC_REV);
-	for (i = 0, j = 0; i < 3; i++) {
+	for (i = 0; i < 3 && j < 24; i++) {
 		u8 num, k, skip0;
 
+		if (i == 0) {
+			bp->fw_version[j++] = 'b';
+			bp->fw_version[j++] = 'c';
+			bp->fw_version[j++] = ' ';
+		}
 		num = (u8) (reg >> (24 - (i * 8)));
 		for (k = 100, skip0 = 1; k >= 1; num %= k, k /= 10) {
 			if (num >= k || !skip0 || k == 1) {
@@ -7929,8 +8024,9 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	    reg != BNX2_CONDITION_MFW_RUN_NONE) {
 		u32 addr = bnx2_shmem_rd(bp, BNX2_MFW_VER_PTR);
 
-		bp->fw_version[j++] = ' ';
-		for (i = 0; i < 3; i++) {
+		if (j < 32)
+			bp->fw_version[j++] = ' ';
+		for (i = 0; i < 3 && j < 28; i++) {
 			reg = bnx2_reg_rd_ind(bp, addr + i * 4);
 			reg = swab32(reg);
 			memcpy(&bp->fw_version[j], &reg, 4);
-- 
1.6.4.GIT


