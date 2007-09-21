From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH 1/2] bnx2: factor out gzip unpacker
Date: Fri, 21 Sep 2007 12:01:24 +0100
Message-ID: <200709211201.24475.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_ES68G0lBf5NaxOL"
Cc: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756876AbXIULBu@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_ES68G0lBf5NaxOL
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Jeff,

This patch modifies gzip unpacking code in bnx2 driver so that
it does not depend on bnx2 internals. I will move this code
out of the driver and into zlib in follow-on patch.

It can be useful in other drivers which need to store firmwares
or any other relatively big binary blobs - fonts, cursor bitmaps,
whatever.

Patch is run tested by Michael Chan (driver author).

Michael, can you add your ACK?

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda

--Boundary-00=_ES68G0lBf5NaxOL
Content-Type: text/x-diff;
  charset="us-ascii";
  name="linux-2.6.23-rc6.bnx2-1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.23-rc6.bnx2-1.patch"

diff -urpN linux-2.6.23-rc6/drivers/net/bnx2.c linux-2.6.23-rc6.bnx2/drivers/net/bnx2.c
--- linux-2.6.23-rc6/drivers/net/bnx2.c	2007-09-14 00:08:11.000000000 +0100
+++ linux-2.6.23-rc6.bnx2/drivers/net/bnx2.c	2007-09-21 11:44:03.000000000 +0100
@@ -52,6 +52,8 @@
 #include "bnx2_fw.h"
 #include "bnx2_fw2.h"
 
+#define FW_BUF_SIZE		0x8000
+
 #define DRV_MODULE_NAME		"bnx2"
 #define PFX DRV_MODULE_NAME	": "
 #define DRV_MODULE_VERSION	"1.6.4"
@@ -2767,89 +2769,45 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-#define FW_BUF_SIZE	0x8000
-
+/* To be moved to generic lib/ */
 static int
-bnx2_gunzip_init(struct bnx2 *bp)
+bnx2_gunzip(void *gunzip_buf, unsigned sz, u8 *zbuf, int len)
 {
-	if ((bp->gunzip_buf = vmalloc(FW_BUF_SIZE)) == NULL)
-		goto gunzip_nomem1;
+	struct z_stream_s *strm;
+	int rc;
 
-	if ((bp->strm = kmalloc(sizeof(*bp->strm), GFP_KERNEL)) == NULL)
-		goto gunzip_nomem2;
+	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
+	 * is stripped */
 
-	bp->strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
-	if (bp->strm->workspace == NULL)
+	rc = -ENOMEM;
+	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
+	if (strm == NULL)
+		goto gunzip_nomem2;
+	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	if (strm->workspace == NULL)
 		goto gunzip_nomem3;
 
-	return 0;
+	strm->next_in = zbuf;
+	strm->avail_in = len;
+	strm->next_out = gunzip_buf;
+	strm->avail_out = sz;
+
+	rc = zlib_inflateInit2(strm, -MAX_WBITS);
+	if (rc == Z_OK) {
+		rc = zlib_inflate(strm, Z_FINISH);
+		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
+		if (rc == Z_STREAM_END)
+			rc = sz - strm->avail_out;
+		else
+			rc = -EINVAL;
+		zlib_inflateEnd(strm);
+	} else
+		rc = -EINVAL;
 
+	kfree(strm->workspace);
 gunzip_nomem3:
-	kfree(bp->strm);
-	bp->strm = NULL;
-
+	kfree(strm);
 gunzip_nomem2:
-	vfree(bp->gunzip_buf);
-	bp->gunzip_buf = NULL;
-
-gunzip_nomem1:
-	printk(KERN_ERR PFX "%s: Cannot allocate firmware buffer for "
-			    "uncompression.\n", bp->dev->name);
-	return -ENOMEM;
-}
-
-static void
-bnx2_gunzip_end(struct bnx2 *bp)
-{
-	kfree(bp->strm->workspace);
-
-	kfree(bp->strm);
-	bp->strm = NULL;
-
-	if (bp->gunzip_buf) {
-		vfree(bp->gunzip_buf);
-		bp->gunzip_buf = NULL;
-	}
-}
-
-static int
-bnx2_gunzip(struct bnx2 *bp, u8 *zbuf, int len, void **outbuf, int *outlen)
-{
-	int n, rc;
-
-	/* check gzip header */
-	if ((zbuf[0] != 0x1f) || (zbuf[1] != 0x8b) || (zbuf[2] != Z_DEFLATED))
-		return -EINVAL;
-
-	n = 10;
-
-#define FNAME	0x8
-	if (zbuf[3] & FNAME)
-		while ((zbuf[n++] != 0) && (n < len));
-
-	bp->strm->next_in = zbuf + n;
-	bp->strm->avail_in = len - n;
-	bp->strm->next_out = bp->gunzip_buf;
-	bp->strm->avail_out = FW_BUF_SIZE;
-
-	rc = zlib_inflateInit2(bp->strm, -MAX_WBITS);
-	if (rc != Z_OK)
-		return rc;
-
-	rc = zlib_inflate(bp->strm, Z_FINISH);
-
-	*outlen = FW_BUF_SIZE - bp->strm->avail_out;
-	*outbuf = bp->gunzip_buf;
-
-	if ((rc != Z_OK) && (rc != Z_STREAM_END))
-		printk(KERN_ERR PFX "%s: Firmware decompression error: %s\n",
-		       bp->dev->name, bp->strm->msg);
-
-	zlib_inflateEnd(bp->strm);
-
-	if (rc == Z_STREAM_END)
-		return 0;
-
 	return rc;
 }
 
@@ -2902,22 +2860,21 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 	/* Load the Text area. */
 	offset = cpu_reg->spad_base + (fw->text_addr - cpu_reg->mips_view_base);
 	if (fw->gz_text) {
-		u32 text_len;
-		void *text;
-
-		rc = bnx2_gunzip(bp, fw->gz_text, fw->gz_text_len, &text,
-				 &text_len);
-		if (rc)
-			return rc;
-
-		fw->text = text;
-	}
-	if (fw->gz_text) {
+		u32 *text;
 		int j;
 
+		text = vmalloc(FW_BUF_SIZE);
+		if (!text)
+			return -ENOMEM;
+		rc = bnx2_gunzip(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
+		if (rc < 0) {
+			vfree(text);
+			return rc;
+		}
 		for (j = 0; j < (fw->text_len / 4); j++, offset += 4) {
-			REG_WR_IND(bp, offset, cpu_to_le32(fw->text[j]));
+			REG_WR_IND(bp, offset, cpu_to_le32(text[j]));
 	        }
+		vfree(text);
 	}
 
 	/* Load the Data area. */
@@ -2979,27 +2936,27 @@ bnx2_init_cpus(struct bnx2 *bp)
 {
 	struct cpu_reg cpu_reg;
 	struct fw_info *fw;
-	int rc = 0;
+	int rc;
 	void *text;
-	u32 text_len;
-
-	if ((rc = bnx2_gunzip_init(bp)) != 0)
-		return rc;
 
 	/* Initialize the RV2P processor. */
-	rc = bnx2_gunzip(bp, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1), &text,
-			 &text_len);
-	if (rc)
+	text = vmalloc(FW_BUF_SIZE);
+	if (!text)
+		return -ENOMEM;
+	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
+	if (rc < 0) {
+		vfree(text);
 		goto init_cpu_err;
+	}
+	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC1);
 
-	load_rv2p_fw(bp, text, text_len, RV2P_PROC1);
-
-	rc = bnx2_gunzip(bp, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2), &text,
-			 &text_len);
-	if (rc)
+	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
+	if (rc < 0) {
+		vfree(text);
 		goto init_cpu_err;
-
-	load_rv2p_fw(bp, text, text_len, RV2P_PROC2);
+	}
+	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC2);
+	vfree(text);
 
 	/* Initialize the RX Processor. */
 	cpu_reg.mode = BNX2_RXP_CPU_MODE;
@@ -3115,7 +3072,6 @@ bnx2_init_cpus(struct bnx2 *bp)
 			goto init_cpu_err;
 	}
 init_cpu_err:
-	bnx2_gunzip_end(bp);
 	return rc;
 }
 
diff -urpN linux-2.6.23-rc6/drivers/net/bnx2.h linux-2.6.23-rc6.bnx2/drivers/net/bnx2.h
--- linux-2.6.23-rc6/drivers/net/bnx2.h	2007-09-14 00:08:11.000000000 +0100
+++ linux-2.6.23-rc6.bnx2/drivers/net/bnx2.h	2007-09-19 10:15:54.000000000 +0100
@@ -6679,9 +6679,6 @@ struct bnx2 {
 	u32			flash_size;
 
 	int			status_stats_size;
-
-	struct z_stream_s	*strm;
-	void			*gunzip_buf;
 };
 
 static u32 bnx2_reg_rd_ind(struct bnx2 *bp, u32 offset);
@@ -6739,7 +6736,7 @@ struct fw_info {
 	const u32 text_addr;
 	const u32 text_len;
 	const u32 text_index;
-	u32 *text;
+/*	u32 *text;*/
 	u8 *gz_text;
 	const u32 gz_text_len;
 
diff -urpN linux-2.6.23-rc6/drivers/net/bnx2_fw.h linux-2.6.23-rc6.bnx2/drivers/net/bnx2_fw.h
--- linux-2.6.23-rc6/drivers/net/bnx2_fw.h	2007-07-09 00:32:17.000000000 +0100
+++ linux-2.6.23-rc6.bnx2/drivers/net/bnx2_fw.h	2007-09-20 15:38:52.000000000 +0100
@@ -15,7 +15,8 @@
  */
 
 static u8 bnx2_COM_b06FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x45, 0x30, 0xe7, 0x45, 0x00, 0x03, 0xdc, 0x5a,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x45, 0x30, 0xe7, 0x45, 0x00, 0x03, */
+								    0xdc, 0x5a,
 	0x6b, 0x6c, 0x1c, 0xd7, 0x75, 0x3e, 0x33, 0x3b, 0x4b, 0xae, 0xc8, 0x15,
 	0x35, 0xa2, 0xc6, 0xf4, 0x5a, 0xa2, 0xed, 0x5d, 0x72, 0x28, 0x12, 0x96,
 	0xec, 0x6e, 0x68, 0xda, 0x62, 0x8c, 0x8d, 0xb4, 0xd9, 0xa5, 0x0c, 0xa1,
@@ -1085,8 +1086,9 @@ static struct fw_info bnx2_com_fw_06 = {
 };
 
 static u8 bnx2_RXP_b06FwText[] = {
-	0x1f, 0x8b, 0x08, 0x08, 0xcb, 0xa3, 0x46, 0x45, 0x00, 0x03, 0x74, 0x65,
-	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xec, 0x5c, 0x6f, 0x6c,
+/*	0x1f, 0x8b, 0x08, 0x08, 0xcb, 0xa3, 0x46, 0x45, 0x00, 0x03, 0x74, 0x65,
+	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, */
+							0xec, 0x5c, 0x6f, 0x6c,
 	0x1c, 0xc7, 0x75, 0x7f, 0x3b, 0xbb, 0xa4, 0x4e, 0xd4, 0x91, 0x5c, 0x1e,
 	0x4f, 0xf4, 0x49, 0x66, 0x94, 0x5d, 0x71, 0x25, 0x5e, 0x2d, 0xc6, 0x5d,
 	0x31, 0x57, 0x9b, 0x08, 0xce, 0xf1, 0x79, 0xef, 0x64, 0xb1, 0x86, 0x0a,
@@ -1798,8 +1800,9 @@ static struct fw_info bnx2_rxp_fw_06 = {
 };
 
 static u8 bnx2_rv2p_proc1[] = {
-	0x1f, 0x8b, 0x08, 0x08, 0x5e, 0xd0, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
-	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xc5, 0x56, 0xcf, 0x6b,
+/*	0x1f, 0x8b, 0x08, 0x08, 0x5e, 0xd0, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
+	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, */
+							0xc5, 0x56, 0xcf, 0x6b,
 	0x13, 0x51, 0x10, 0x9e, 0xec, 0x6e, 0xb2, 0xdb, 0x74, 0xbb, 0x1b, 0x2b,
 	0xda, 0xa0, 0xb1, 0x8d, 0x51, 0x6a, 0x7f, 0xa4, 0xb4, 0x11, 0x0f, 0x82,
 	0x42, 0x25, 0x3d, 0x04, 0x54, 0x44, 0x7a, 0x28, 0x22, 0x82, 0x36, 0x8a,
@@ -1877,8 +1880,9 @@ static u8 bnx2_rv2p_proc1[] = {
 	0x12, 0x3d, 0x80, 0x0b, 0x00, 0x00, 0x00 };
 
 static u8 bnx2_rv2p_proc2[] = {
-	0x1f, 0x8b, 0x08, 0x08, 0x7e, 0xd1, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
-	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xcd, 0x58, 0x5b, 0x6c,
+/*	0x1f, 0x8b, 0x08, 0x08, 0x7e, 0xd1, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
+	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, */
+							0xcd, 0x58, 0x5b, 0x6c,
 	0x54, 0x55, 0x14, 0x3d, 0xf3, 0xe8, 0xcc, 0x9d, 0xe9, 0xed, 0x9d, 0xf2,
 	0xb2, 0x03, 0xad, 0x08, 0xe5, 0xd1, 0x56, 0x29, 0xe8, 0x54, 0xab, 0x18,
 	0x15, 0x2c, 0x5a, 0x8c, 0x26, 0x68, 0xf0, 0xf9, 0x63, 0x14, 0x04, 0xda,
@@ -2057,8 +2061,9 @@ static u8 bnx2_rv2p_proc2[] = {
 	0x17, 0x00, 0x00, 0x00 };
 
 static u8 bnx2_TPAT_b06FwText[] = {
-	0x1f, 0x8b, 0x08, 0x08, 0x47, 0xd2, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
-	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xc5, 0x57, 0x4d, 0x68,
+/*	0x1f, 0x8b, 0x08, 0x08, 0x47, 0xd2, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
+	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, */
+							0xc5, 0x57, 0x4d, 0x68,
 	0x1c, 0xe7, 0x19, 0x7e, 0xe7, 0x77, 0x47, 0x62, 0x25, 0x8d, 0x93, 0x3d,
 	0xac, 0x5d, 0xa5, 0x99, 0x91, 0x46, 0x3f, 0x54, 0x26, 0x9e, 0x84, 0xa5,
 	0x56, 0x61, 0x20, 0xe3, 0x99, 0x95, 0x2c, 0x0c, 0x05, 0x07, 0x42, 0x08,
@@ -2290,8 +2295,9 @@ static struct fw_info bnx2_tpat_fw_06 = 
 };
 
 static u8 bnx2_TXP_b06FwText[] = {
-	0x1f, 0x8b, 0x08, 0x08, 0x21, 0xd3, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
-	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, 0xed, 0x5c, 0x6d, 0x6c,
+/*	0x1f, 0x8b, 0x08, 0x08, 0x21, 0xd3, 0x41, 0x44, 0x00, 0x03, 0x74, 0x65,
+	0x73, 0x74, 0x31, 0x2e, 0x62, 0x69, 0x6e, 0x00, */
+							0xed, 0x5c, 0x6d, 0x6c,
 	0x1b, 0xf7, 0x79, 0x7f, 0xee, 0x85, 0xd2, 0x51, 0x96, 0xe9, 0x93, 0xc2,
 	0x78, 0x6c, 0xc0, 0xa6, 0x77, 0xd6, 0x51, 0x66, 0x20, 0xb5, 0xa0, 0x05,
 	0x36, 0x55, 0x87, 0x43, 0x73, 0x3e, 0x52, 0x2f, 0x4e, 0x5c, 0x57, 0x71,
diff -urpN linux-2.6.23-rc6/drivers/net/bnx2_fw2.h linux-2.6.23-rc6.bnx2/drivers/net/bnx2_fw2.h
--- linux-2.6.23-rc6/drivers/net/bnx2_fw2.h	2007-07-09 00:32:17.000000000 +0100
+++ linux-2.6.23-rc6.bnx2/drivers/net/bnx2_fw2.h	2007-09-20 15:39:08.000000000 +0100
@@ -15,7 +15,8 @@
  */
 
 static u8 bnx2_COM_b09FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, 0xdc, 0x5b,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, */
+								    0xdc, 0x5b,
 	0x6d, 0x70, 0x5c, 0xd5, 0x79, 0x7e, 0xef, 0xd9, 0xbb, 0xf2, 0x5a, 0x92,
 	0xe5, 0x6b, 0x79, 0x23, 0x16, 0x4b, 0xc0, 0xae, 0x75, 0x6d, 0x69, 0xb0,
 	0x43, 0x16, 0xa1, 0x80, 0x9a, 0xd9, 0xc0, 0xb2, 0x2b, 0x33, 0x9e, 0x0c,
@@ -1083,7 +1084,8 @@ static struct fw_info bnx2_com_fw_09 = {
 };
 
 static u8 bnx2_CP_b09FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x0f, 0x34, 0xe7, 0x45, 0x00, 0x03, 0xbd, 0x7d,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x0f, 0x34, 0xe7, 0x45, 0x00, 0x03, */
+								    0xbd, 0x7d,
 	0x0d, 0x74, 0x5c, 0x57, 0x7d, 0xe7, 0xff, 0xdd, 0x19, 0x49, 0x63, 0x59,
 	0x96, 0x9f, 0xe5, 0x89, 0x32, 0x51, 0x84, 0x3d, 0x23, 0x3d, 0xd9, 0x22,
 	0x12, 0xe1, 0xc5, 0x11, 0xac, 0xda, 0x2a, 0xe9, 0x30, 0x92, 0x3f, 0x12,
@@ -2279,7 +2281,8 @@ static struct fw_info bnx2_cp_fw_09 = {
 };
 
 static u8 bnx2_RXP_b09FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, 0xec, 0x5c,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, */
+								    0xec, 0x5c,
 	0x5d, 0x6c, 0x1c, 0xd7, 0x75, 0x3e, 0xf3, 0x43, 0x6a, 0x49, 0xf1, 0x67,
 	0xb8, 0x5c, 0xb1, 0x2b, 0x99, 0x96, 0x77, 0xc9, 0x91, 0xc8, 0x58, 0x8a,
 	0x31, 0xa2, 0x09, 0x5b, 0x48, 0x17, 0xf6, 0x76, 0x76, 0x25, 0xb1, 0xb1,
@@ -2988,7 +2991,8 @@ static struct fw_info bnx2_rxp_fw_09 = {
 };
 
 static u8 bnx2_TPAT_b09FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, 0xcd, 0x58,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, */
+								    0xcd, 0x58,
 	0x5d, 0x68, 0x1c, 0xd7, 0x15, 0x3e, 0xf3, 0xb7, 0x3b, 0x52, 0x24, 0xeb,
 	0x5a, 0xd9, 0xa6, 0xeb, 0xa0, 0x34, 0x33, 0xda, 0x91, 0xac, 0x22, 0x13,
 	0x4f, 0x9d, 0x25, 0x16, 0x65, 0x21, 0x93, 0xd9, 0x91, 0xac, 0x98, 0x3c,
@@ -3279,7 +3283,8 @@ static struct fw_info bnx2_tpat_fw_09 = 
 };
 
 static u8 bnx2_TXP_b09FwText[] = {
-	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, 0xcd, 0x7c,
+/*	0x1f, 0x8b, 0x08, 0x00, 0x0e, 0x34, 0xe7, 0x45, 0x00, 0x03, */
+								    0xcd, 0x7c,
 	0x6f, 0x70, 0x5b, 0xd7, 0x95, 0xdf, 0x79, 0xef, 0x81, 0x24, 0x48, 0xd1,
 	0xd4, 0x13, 0x17, 0x56, 0x60, 0x87, 0x71, 0x00, 0xf1, 0x81, 0x66, 0x42,
 	0xae, 0x04, 0x2b, 0x4c, 0xc2, 0x6d, 0xd1, 0xf8, 0x05, 0x00, 0x29, 0x48,

--Boundary-00=_ES68G0lBf5NaxOL
Content-Type: text/x-diff;
  charset="us-ascii";
  name="linux-2.6.23-rc6.bnx2-2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="linux-2.6.23-rc6.bnx2-2.patch"

diff -urp linux-2.6.23-rc6.bnx2/drivers/net/bnx2.c linux-2.6.23-rc6.bnx2_2/drivers/net/bnx2.c
--- linux-2.6.23-rc6.bnx2/drivers/net/bnx2.c	2007-09-21 11:44:03.000000000 +0100
+++ linux-2.6.23-rc6.bnx2_2/drivers/net/bnx2.c	2007-09-20 15:35:58.000000000 +0100
@@ -2769,48 +2769,6 @@ bnx2_set_rx_mode(struct net_device *dev)
 	spin_unlock_bh(&bp->phy_lock);
 }
 
-/* To be moved to generic lib/ */
-static int
-bnx2_gunzip(void *gunzip_buf, unsigned sz, u8 *zbuf, int len)
-{
-	struct z_stream_s *strm;
-	int rc;
-
-	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
-	 * is stripped */
-
-	rc = -ENOMEM;
-	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
-	if (strm == NULL)
-		goto gunzip_nomem2;
-	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
-	if (strm->workspace == NULL)
-		goto gunzip_nomem3;
-
-	strm->next_in = zbuf;
-	strm->avail_in = len;
-	strm->next_out = gunzip_buf;
-	strm->avail_out = sz;
-
-	rc = zlib_inflateInit2(strm, -MAX_WBITS);
-	if (rc == Z_OK) {
-		rc = zlib_inflate(strm, Z_FINISH);
-		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
-		if (rc == Z_STREAM_END)
-			rc = sz - strm->avail_out;
-		else
-			rc = -EINVAL;
-		zlib_inflateEnd(strm);
-	} else
-		rc = -EINVAL;
-
-	kfree(strm->workspace);
-gunzip_nomem3:
-	kfree(strm);
-gunzip_nomem2:
-	return rc;
-}
-
 static void
 load_rv2p_fw(struct bnx2 *bp, u32 *rv2p_code, u32 rv2p_code_len,
 	u32 rv2p_proc)
@@ -2866,7 +2824,7 @@ load_cpu_fw(struct bnx2 *bp, struct cpu_
 		text = vmalloc(FW_BUF_SIZE);
 		if (!text)
 			return -ENOMEM;
-		rc = bnx2_gunzip(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
+		rc = zlib_inflate_blob(text, FW_BUF_SIZE, fw->gz_text, fw->gz_text_len);
 		if (rc < 0) {
 			vfree(text);
 			return rc;
@@ -2943,14 +2901,14 @@ bnx2_init_cpus(struct bnx2 *bp)
 	text = vmalloc(FW_BUF_SIZE);
 	if (!text)
 		return -ENOMEM;
-	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
+	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc1, sizeof(bnx2_rv2p_proc1));
 	if (rc < 0) {
 		vfree(text);
 		goto init_cpu_err;
 	}
 	load_rv2p_fw(bp, text, rc /* == len */, RV2P_PROC1);
 
-	rc = bnx2_gunzip(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
+	rc = zlib_inflate_blob(text, FW_BUF_SIZE, bnx2_rv2p_proc2, sizeof(bnx2_rv2p_proc2));
 	if (rc < 0) {
 		vfree(text);
 		goto init_cpu_err;
diff -urp linux-2.6.23-rc6.bnx2/include/linux/zlib.h linux-2.6.23-rc6.bnx2_2/include/linux/zlib.h
--- linux-2.6.23-rc6.bnx2/include/linux/zlib.h	2007-07-09 00:32:17.000000000 +0100
+++ linux-2.6.23-rc6.bnx2_2/include/linux/zlib.h	2007-09-20 15:32:50.000000000 +0100
@@ -82,7 +82,7 @@
 struct internal_state;
 
 typedef struct z_stream_s {
-    Byte    *next_in;   /* next input byte */
+    const Byte *next_in;   /* next input byte */
     uInt     avail_in;  /* number of bytes available at next_in */
     uLong    total_in;  /* total nb of input bytes read so far */
 
@@ -699,4 +699,8 @@ extern int zlib_inflateInit2(z_streamp s
     struct internal_state {int dummy;}; /* hack for buggy compilers */
 #endif
 
+/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
+ * return len or negative error code. */
+extern int zlib_inflate_blob(void *dst, unsigned dst_sz, const void *src, unsigned src_sz);
+
 #endif /* _ZLIB_H */
diff -urp linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inffast.c linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inffast.c
--- linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inffast.c	2007-09-19 10:33:08.000000000 +0100
+++ linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inffast.c	2007-09-19 10:47:55.000000000 +0100
@@ -69,22 +69,22 @@
 void inflate_fast(z_streamp strm, unsigned start)
 {
     struct inflate_state *state;
-    unsigned char *in;      /* local strm->next_in */
-    unsigned char *last;    /* while in < last, enough input available */
-    unsigned char *out;     /* local strm->next_out */
-    unsigned char *beg;     /* inflate()'s initial strm->next_out */
-    unsigned char *end;     /* while out < end, enough space available */
+    const unsigned char *in;    /* local strm->next_in */
+    const unsigned char *last;  /* while in < last, enough input available */
+    unsigned char *out;         /* local strm->next_out */
+    unsigned char *beg;         /* inflate()'s initial strm->next_out */
+    unsigned char *end;         /* while out < end, enough space available */
 #ifdef INFLATE_STRICT
     unsigned dmax;              /* maximum distance from zlib header */
 #endif
     unsigned wsize;             /* window size or zero if not using window */
     unsigned whave;             /* valid bytes in the window */
     unsigned write;             /* window write index */
-    unsigned char *window;  /* allocated sliding window, if wsize != 0 */
+    unsigned char *window;      /* allocated sliding window, if wsize != 0 */
     unsigned long hold;         /* local strm->hold */
     unsigned bits;              /* local strm->bits */
-    code const *lcode;      /* local strm->lencode */
-    code const *dcode;      /* local strm->distcode */
+    code const *lcode;          /* local strm->lencode */
+    code const *dcode;          /* local strm->distcode */
     unsigned lmask;             /* mask for first level of length codes */
     unsigned dmask;             /* mask for first level of distance codes */
     code this;                  /* retrieved table entry */
@@ -92,7 +92,7 @@ void inflate_fast(z_streamp strm, unsign
                                 /*  window position, window bytes to copy */
     unsigned len;               /* match length, unused bytes */
     unsigned dist;              /* match distance */
-    unsigned char *from;    /* where to copy match from */
+    unsigned char *from;        /* where to copy match from */
 
     /* copy state to local variables */
     state = (struct inflate_state *)strm->state;
diff -urp linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inflate.c linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inflate.c
--- linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inflate.c	2007-09-19 10:33:08.000000000 +0100
+++ linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inflate.c	2007-09-21 11:46:27.000000000 +0100
@@ -332,14 +332,14 @@ static int zlib_inflateSyncPacket(z_stre
 int zlib_inflate(z_streamp strm, int flush)
 {
     struct inflate_state *state;
-    unsigned char *next;    /* next input */
-    unsigned char *put;     /* next output */
+    const unsigned char *next;  /* next input */
+    unsigned char *put;         /* next output */
     unsigned have, left;        /* available input and output */
     unsigned long hold;         /* bit buffer */
     unsigned bits;              /* bits in bit buffer */
     unsigned in, out;           /* save starting available input and output */
     unsigned copy;              /* number of stored or match bytes to copy */
-    unsigned char *from;    /* where to copy match bytes from */
+    unsigned char *from;        /* where to copy match bytes from */
     code this;                  /* current decoding table entry */
     code last;                  /* parent table entry */
     unsigned len;               /* length to copy for repeats, bits to drop */
@@ -897,7 +897,7 @@ int zlib_inflateIncomp(z_stream *z)
 
     /* Setup some variables to allow misuse of updateWindow */
     z->avail_out = 0;
-    z->next_out = z->next_in + z->avail_in;
+    z->next_out = (unsigned char*)z->next_in + z->avail_in;
 
     zlib_updatewindow(z, z->avail_in);
 
@@ -916,3 +916,50 @@ int zlib_inflateIncomp(z_stream *z)
 
     return Z_OK;
 }
+
+#include <linux/errno.h>
+#include <linux/slab.h>
+#include <linux/vmalloc.h>
+
+/* Utility function: initialize zlib, unpack binary blob, clean up zlib,
+ * return len or negative error code. */
+int zlib_inflate_blob(void *gunzip_buf, unsigned sz, const void *buf, unsigned len)
+{
+	const u8 *zbuf = buf;
+	struct z_stream_s *strm;
+	int rc;
+
+	rc = -ENOMEM;
+	strm = kmalloc(sizeof(*strm), GFP_KERNEL);
+	if (strm == NULL)
+		goto gunzip_nomem1;
+	strm->workspace = kmalloc(zlib_inflate_workspacesize(), GFP_KERNEL);
+	if (strm->workspace == NULL)
+		goto gunzip_nomem2;
+
+	/* gzip header (1f,8b,08... 10 bytes total + possible asciz filename)
+	 * expected to be stripped from input */
+
+	strm->next_in = zbuf;
+	strm->avail_in = len;
+	strm->next_out = gunzip_buf;
+	strm->avail_out = sz;
+
+	rc = zlib_inflateInit2(strm, -MAX_WBITS);
+	if (rc == Z_OK) {
+		rc = zlib_inflate(strm, Z_FINISH);
+		/* after Z_FINISH, only Z_STREAM_END is "we unpacked it all" */
+		if (rc == Z_STREAM_END)
+			rc = sz - strm->avail_out;
+		else
+			rc = -EINVAL;
+		zlib_inflateEnd(strm);
+	} else
+		rc = -EINVAL;
+
+	kfree(strm->workspace);
+gunzip_nomem2:
+	kfree(strm);
+gunzip_nomem1:
+	return rc; /* returns Z_OK (0) if successful */
+}
diff -urp linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inflate_syms.c linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inflate_syms.c
--- linux-2.6.23-rc6.bnx2/lib/zlib_inflate/inflate_syms.c	2007-09-19 10:33:08.000000000 +0100
+++ linux-2.6.23-rc6.bnx2_2/lib/zlib_inflate/inflate_syms.c	2007-09-19 10:34:21.000000000 +0100
@@ -16,4 +16,5 @@ EXPORT_SYMBOL(zlib_inflateInit2);
 EXPORT_SYMBOL(zlib_inflateEnd);
 EXPORT_SYMBOL(zlib_inflateReset);
 EXPORT_SYMBOL(zlib_inflateIncomp); 
+EXPORT_SYMBOL(zlib_inflate_blob);
 MODULE_LICENSE("GPL");

--Boundary-00=_ES68G0lBf5NaxOL--
