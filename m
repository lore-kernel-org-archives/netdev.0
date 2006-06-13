From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.18 4/6] bnx2: Add firmware decompression
Date: Mon, 12 Jun 2006 17:17:18 -0700
Message-ID: <1150157838.26173.9.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:51210 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932679AbWFMAXd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 20:23:33 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add functions to decompress firmware before loading to the internal
CPUs. Compressing the firmware reduces the driver size significantly.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index bdaaad8..1fb0a19 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2163,6 +2163,8 @@ config TIGON3
 config BNX2
 	tristate "Broadcom NetXtremeII support"
 	depends on PCI
+	select CRC32
+	select ZLIB_INFLATE
 	help
 	  This driver supports Broadcom NetXtremeII gigabit Ethernet cards.
 
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7a3d888..3b1fe1e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -50,6 +50,7 @@
 #include <linux/crc32.h>
 #include <linux/prefetch.h>
 #include <linux/cache.h>
+#include <linux/zlib.h>
 
 #include "bnx2.h"
 #include "bnx2_fw.h"
@@ -2084,6 +2085,92 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
+#define FW_BUF_SIZE	0x8000
+
+static int
+bnx2_gunzip_init(struct bnx2 *bp)
+{
+	if ((bp->gunzip_buf = vmalloc(FW_BUF_SIZE)) == NULL)
+		goto gunzip_nomem1;
+
+	if ((bp->strm = kmalloc(sizeof(*bp->strm), GFP_KERNEL)) == NULL)
+		goto gunzip_nomem2;
+
+	bp->strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	if (bp->strm->workspace == NULL)
+		goto gunzip_nomem3;
+
+	return 0;
+
+gunzip_nomem3:
+	kfree(bp->strm);
+	bp->strm = NULL;
+
+gunzip_nomem2:
+	vfree(bp->gunzip_buf);
+	bp->gunzip_buf = NULL;
+
+gunzip_nomem1:
+	printk(KERN_ERR PFX "%s: Cannot allocate firmware buffer for "
+			    "uncompression.\n", bp->dev->name);
+	return -ENOMEM;
+}
+
+static void
+bnx2_gunzip_end(struct bnx2 *bp)
+{
+	kfree(bp->strm->workspace);
+
+	kfree(bp->strm);
+	bp->strm = NULL;
+
+	if (bp->gunzip_buf) {
+		vfree(bp->gunzip_buf);
+		bp->gunzip_buf = NULL;
+	}
+}
+
+static int
+bnx2_gunzip(struct bnx2 *bp, u8 *zbuf, int len, void **outbuf, int *outlen)
+{
+	int n, rc;
+
+	/* check gzip header */
+	if ((zbuf[0] != 0x1f) || (zbuf[1] != 0x8b) || (zbuf[2] != Z_DEFLATED))
+		return -EINVAL;
+
+	n = 10;
+
+#define FNAME	0x8
+	if (zbuf[3] & FNAME)
+		while (zbuf[n++] != 0);
+
+	bp->strm->next_in = zbuf + n;
+	bp->strm->avail_in = len - n;
+	bp->strm->next_out = bp->gunzip_buf;
+	bp->strm->avail_out = FW_BUF_SIZE;
+
+	rc = zlib_inflateInit2(bp->strm, -MAX_WBITS);
+	if (rc != Z_OK)
+		return rc;
+
+	rc = zlib_inflate(bp->strm, Z_FINISH);
+
+	*outlen = FW_BUF_SIZE - bp->strm->avail_out;
+	*outbuf = bp->gunzip_buf;
+
+	if ((rc != Z_OK) && (rc != Z_STREAM_END))
+		printk(KERN_ERR PFX "%s: Firmware decompression error: %s\n",
+		       bp->dev->name, bp->strm->msg);
+
+	zlib_inflateEnd(bp->strm);
+
+	if (rc == Z_STREAM_END)
+		return 0;
+
+	return rc;
+}
+
 static void
 load_rv2p_fw(struct bnx2 *bp, u32 *rv2p_code, u32 rv2p_code_len,
 	u32 rv2p_proc)
@@ -2093,9 +2180,9 @@ load_rv2p_fw(struct bnx2 *bp, u32 *rv2p_
 
 
 	for (i = 0; i < rv2p_code_len; i += 8) {
-		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, *rv2p_code);
+		REG_WR(bp, BNX2_RV2P_INSTR_HIGH, cpu_to_le32(*rv2p_code));
 		rv2p_code++;
-		REG_WR(bp, BNX2_RV2P_INSTR_LOW, *rv2p_code);
+		REG_WR(bp, BNX2_RV2P_INSTR_LOW, cpu_to_le32(*rv2p_code));
 		rv2p_code++;
 
 		if (rv2p_proc == RV2P_PROC1) {
@@ -2135,7 +2222,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 		int j;
 
 		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, fw->text[j]);
+			REG_WR_IND(bp, offset, cpu_to_le32(fw->text[j]));
 	        }
 	}
 
@@ -2191,15 +2278,32 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 	REG_WR_IND(bp, cpu_reg->mode, val);
 }
 
-static void
+static int
 bnx2_init_cpus(struct bnx2 *bp)
 {
 	struct cpu_reg cpu_reg;
 	struct fw_info fw;
+	int rc = 0;
+	void *text;
+	u32 text_len;
+
+	if ((rc = bnx2_gunzip_init(bp)) != 0)
+		return rc;
 
 	/* Initialize the RV2P processor. */
-	load_rv2p_fw(bp, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1), RV2P_PROC1);
-	load_rv2p_fw(bp, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2), RV2P_PROC2);
+	rc = bnx2_gunzip(bp, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1), &text,
+			 &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	load_rv2p_fw(bp, text, text_len, RV2P_PROC1);
+
+	rc = bnx2_gunzip(bp, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2), &text,
+			 &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	load_rv2p_fw(bp, text, text_len, RV2P_PROC2);
 
 	/* Initialize the RX Processor. */
 	cpu_reg.mode = BNX2_RXP_CPU_MODE;
@@ -2223,7 +2327,13 @@ bnx2_init_cpus(struct bnx2 *bp)
 	fw.text_addr = bnx2_RXP_b06FwTextAddr;
 	fw.text_len = bnx2_RXP_b06FwTextLen;
 	fw.text_index = 0;
-	fw.text = bnx2_RXP_b06FwText;
+
+	rc = bnx2_gunzip(bp, bnx2_RXP_b06FwText, sizeof(bnx2_RXP_b06FwText),
+			 &text, &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	fw.text = text;
 
 	fw.data_addr = bnx2_RXP_b06FwDataAddr;
 	fw.data_len = bnx2_RXP_b06FwDataLen;
@@ -2269,7 +2379,13 @@ bnx2_init_cpus(struct bnx2 *bp)
 	fw.text_addr = bnx2_TXP_b06FwTextAddr;
 	fw.text_len = bnx2_TXP_b06FwTextLen;
 	fw.text_index = 0;
-	fw.text = bnx2_TXP_b06FwText;
+
+	rc = bnx2_gunzip(bp, bnx2_TXP_b06FwText, sizeof(bnx2_TXP_b06FwText),
+			 &text, &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	fw.text = text;
 
 	fw.data_addr = bnx2_TXP_b06FwDataAddr;
 	fw.data_len = bnx2_TXP_b06FwDataLen;
@@ -2315,7 +2431,13 @@ bnx2_init_cpus(struct bnx2 *bp)
 	fw.text_addr = bnx2_TPAT_b06FwTextAddr;
 	fw.text_len = bnx2_TPAT_b06FwTextLen;
 	fw.text_index = 0;
-	fw.text = bnx2_TPAT_b06FwText;
+
+	rc = bnx2_gunzip(bp, bnx2_TPAT_b06FwText, sizeof(bnx2_TPAT_b06FwText),
+			 &text, &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	fw.text = text;
 
 	fw.data_addr = bnx2_TPAT_b06FwDataAddr;
 	fw.data_len = bnx2_TPAT_b06FwDataLen;
@@ -2361,7 +2483,13 @@ bnx2_init_cpus(struct bnx2 *bp)
 	fw.text_addr = bnx2_COM_b06FwTextAddr;
 	fw.text_len = bnx2_COM_b06FwTextLen;
 	fw.text_index = 0;
-	fw.text = bnx2_COM_b06FwText;
+
+	rc = bnx2_gunzip(bp, bnx2_COM_b06FwText, sizeof(bnx2_COM_b06FwText),
+			 &text, &text_len);
+	if (rc)
+		goto init_cpu_err;
+
+	fw.text = text;
 
 	fw.data_addr = bnx2_COM_b06FwDataAddr;
 	fw.data_len = bnx2_COM_b06FwDataLen;
@@ -2385,6 +2513,9 @@ bnx2_init_cpus(struct bnx2 *bp)
 
 	load_cpu_fw(bp, &cpu_reg, &fw);
 
+init_cpu_err:
+	bnx2_gunzip_end(bp);
+	return rc;
 }
 
 static int
@@ -3257,7 +3388,9 @@ bnx2_init_chip(struct bnx2 *bp)
 	 * context block must have already been enabled. */
 	bnx2_init_context(bp);
 
-	bnx2_init_cpus(bp);
+	if ((rc = bnx2_init_cpus(bp)) != 0)
+		return rc;
+
 	bnx2_init_nvram(bp);
 
 	bnx2_set_mac_addr(bp);
@@ -3557,7 +3690,9 @@ bnx2_reset_nic(struct bnx2 *bp, u32 rese
 	if (rc)
 		return rc;
 
-	bnx2_init_chip(bp);
+	if ((rc = bnx2_init_chip(bp)) != 0)
+		return rc;
+
 	bnx2_init_tx_ring(bp);
 	bnx2_init_rx_ring(bp);
 	return 0;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index de2b58c..768abca 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -4048,6 +4048,9 @@ struct bnx2 {
 	u32			flash_size;
 
 	int			status_stats_size;
+
+	struct z_stream_s	*strm;
+	void			*gunzip_buf;
 };
 
 static u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset);


