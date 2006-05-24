From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 2/4] b44: wol setup for older 4401
Date: Wed, 24 May 2006 07:40:47 -0700
Message-ID: <1148481647.2976.52.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:50706 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932770AbWEXVnR
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 17:43:17 -0400
To: "Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds wol support for the older 4401 revs.

Signed-off-by: Gary Zambrano <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index b9e2462..6f4d1d4 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1448,6 +1448,93 @@ static void b44_poll_controller(struct n
 }
 #endif

+static inline void bwfilter_table(struct b44 *bp,
+					u32 *pattern,
+					u32 bytes,
+					u32 table_offset)
+{
+	u32 i;
+
+	for (i = 0; i < bytes; i += sizeof(u32)) {
+		bw32(bp, B44_FILT_ADDR, table_offset + i);
+		bw32(bp, B44_FILT_DATA, pattern[i / sizeof(u32)]);
+	}
+}
+
+/* Setup two common magic packet patterns in the b44 WOL
+ * pattern matching filter.
+ */
+static void b44_setup_pseudo_magicp(struct b44 *bp)
+{
+
+	u32 val;
+	int plen0, plen1, max, i, j;
+	u8 *pwol_pattern;
+	u8 *pwol_mask;
+
+	pwol_pattern = kmalloc(B44_WOL_PATTERN_SIZE, GFP_KERNEL);
+	pwol_mask = kmalloc(B44_WOL_MASK_SIZE, GFP_KERNEL);
+
+	/* UDP magic packet pattern */
+	memset(pwol_pattern, 0, B44_WOL_PATTERN_SIZE);
+	memset(pwol_pattern + 42, 0xff, 6);	/* sync pattern */
+	max = ETH_ALEN;
+	for (i = 0; i < 14; ++i) {
+		if (i == 13)
+			max = 2;
+		for (j = 0; j < max; ++j) {
+			pwol_pattern[42 + 6 +
+			(i * ETH_ALEN) + j] =
+			bp->dev->dev_addr[j];
+		}
+	}
+
+	memset(pwol_mask, 0, B44_WOL_MASK_SIZE);
+	pwol_mask[5] = 0xfc;
+	memset(pwol_mask + 6, 0xff, 10);
+	plen0 = B44_WOL_PATTERN_SIZE - 1;
+
+   	bwfilter_table(bp, (u32 *)pwol_pattern,
+		B44_WOL_PATTERN_SIZE, B44_WOL_PATTERN_BASE);
+
+   	bwfilter_table(bp, (u32 *)pwol_mask,
+		B44_WOL_MASK_SIZE, B44_WOL_MASK_BASE);
+
+	/* raw ethernet II magic packet pattern */
+	memset(pwol_pattern, 0, B44_WOL_PATTERN_SIZE);
+	memset(pwol_pattern + 14, 0xff, 6);	/* sync pattern */
+	max = ETH_ALEN;
+	for (i = 0; i < 16; ++i) {
+		for (j = 0; j < max; ++j) {
+			pwol_pattern[14 + 6 +
+			(i * ETH_ALEN) + j] =
+			bp->dev->dev_addr[j];
+		}
+	}
+
+	memset(pwol_mask, 0, B44_WOL_MASK_SIZE);
+	pwol_mask[2] = 0xf0;
+	memset(pwol_mask + 3, 0xff, 11);
+	pwol_mask[14] = 0xf;
+	plen1 = 14 + 6 + 96 - 1;
+
+   	bwfilter_table(bp, (u32 *)pwol_pattern, B44_WOL_PATTERN_SIZE,
+				B44_WOL_PATTERN_BASE + B44_WOL_PATTERN_SIZE);
+  	bwfilter_table(bp, (u32 *)pwol_mask, B44_WOL_MASK_SIZE,
+				B44_WOL_MASK_BASE + B44_WOL_MASK_SIZE);
+
+	/* set this pattern's length: one less than the real length */
+	val = plen0 | (plen1 << 8) | WKUP_LEN_ENABLE_TWO;
+	bw32(bp, B44_WKUP_LEN, val);
+
+	/* enable chip wakeup pattern matching */
+	val = br32(bp, B44_DEVCTRL);
+	bw32(bp, B44_DEVCTRL, val | DEVCTRL_PFE);
+
+	kfree(pwol_mask);
+	kfree(pwol_pattern);
+
+}

 static void b44_setup_wol(struct b44 *bp)
 {


