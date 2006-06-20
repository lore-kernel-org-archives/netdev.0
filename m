From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: [PATCH 4/6 resend] b44: add wol for old nic
Date: Tue, 20 Jun 2006 15:34:36 -0700
Message-ID: <1150842876.21197.56.camel@dhcp-10-7-81-7.broadcom.com>
References: <1150485566.8716.53.camel@dhcp-10-7-81-7.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:62726 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1751402AbWFTWfS
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 18:35:18 -0400
To: "Jeff Garzik" <jeff@garzik.org>
In-Reply-To: <1150485566.8716.53.camel@dhcp-10-7-81-7.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds wol support for the older 440x nics that use pattern matching.
This patch is a redo thanks to feedback from Michael Chan and Francois Romieu.

Signed-off-by: Gary Zambrano  <zambrano@broadcom.com>

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 12fc67a..98c0675 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -75,6 +75,15 @@
 /* minimum number of free TX descriptors required to wake up TX process */
 #define B44_TX_WAKEUP_THRESH		(B44_TX_RING_SIZE / 4)
 
+/* b44 internal pattern match filter info */
+#define B44_PATTERN_BASE	0x400
+#define B44_PATTERN_SIZE	0x80
+#define B44_PMASK_BASE		0x600
+#define B44_PMASK_SIZE		0x10
+#define B44_MAX_PATTERNS	16
+#define B44_ETHIPV6UDP_HLEN	62
+#define B44_ETHIPV4UDP_HLEN	42
+
 static char version[] __devinitdata =
 	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
 
@@ -1457,6 +1466,103 @@ static void b44_poll_controller(struct n
 }
 #endif
 
+static void bwfilter_table(struct b44 *bp, u8 *pp, u32 bytes, u32 table_offset)
+{
+	u32 i;
+	u32 *pattern = (u32 *) pp;
+
+	for (i = 0; i < bytes; i += sizeof(u32)) {
+		bw32(bp, B44_FILT_ADDR, table_offset + i);
+		bw32(bp, B44_FILT_DATA, pattern[i / sizeof(u32)]);
+	}
+}
+
+static int b44_magic_pattern(u8 *macaddr, u8 *ppattern, u8 *pmask, int offset)
+{
+	int magicsync = 6;
+	int k, j, len = offset;
+	int ethaddr_bytes = ETH_ALEN;
+
+	memset(ppattern + offset, 0xff, magicsync);
+	for (j = 0; j < magicsync; j++)
+		set_bit(len++, (unsigned long *) pmask);
+
+	for (j = 0; j < B44_MAX_PATTERNS; j++) {
+		if ((B44_PATTERN_SIZE - len) >= ETH_ALEN)
+			ethaddr_bytes = ETH_ALEN;
+		else
+			ethaddr_bytes = B44_PATTERN_SIZE - len;
+		if (ethaddr_bytes <=0)
+			break;
+		for (k = 0; k< ethaddr_bytes; k++) {
+			ppattern[offset + magicsync +
+				(j * ETH_ALEN) + k] = macaddr[k];
+			len++;
+			set_bit(len, (unsigned long *) pmask);
+		}
+	}
+	return len - 1;
+}
+
+/* Setup magic packet patterns in the b44 WOL
+ * pattern matching filter.
+ */
+static void b44_setup_pseudo_magicp(struct b44 *bp)
+{
+
+	u32 val;
+	int plen0, plen1, plen2;
+	u8 *pwol_pattern;
+	u8 pwol_mask[B44_PMASK_SIZE];
+
+	pwol_pattern = kmalloc(B44_PATTERN_SIZE, GFP_KERNEL);
+	if (!pwol_pattern) {
+		printk(KERN_ERR PFX "Memory not available for WOL\n");
+		return;
+	}
+
+	/* Ipv4 magic packet pattern - pattern 0.*/
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen0 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  B44_ETHIPV4UDP_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE, B44_PATTERN_BASE);
+   	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE, B44_PMASK_BASE);
+
+	/* Raw ethernet II magic packet pattern - pattern 1 */
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen1 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  ETH_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE,
+		       B44_PATTERN_BASE + B44_PATTERN_SIZE);
+  	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE,
+		       B44_PMASK_BASE + B44_PMASK_SIZE);
+
+	/* Ipv6 magic packet pattern - pattern 2 */
+	memset(pwol_pattern, 0, B44_PATTERN_SIZE);
+	memset(pwol_mask, 0, B44_PMASK_SIZE);
+	plen2 = b44_magic_pattern(bp->dev->dev_addr, pwol_pattern, pwol_mask,
+				  B44_ETHIPV6UDP_HLEN);
+
+   	bwfilter_table(bp, pwol_pattern, B44_PATTERN_SIZE,
+		       B44_PATTERN_BASE + B44_PATTERN_SIZE + B44_PATTERN_SIZE);
+  	bwfilter_table(bp, pwol_mask, B44_PMASK_SIZE,
+		       B44_PMASK_BASE + B44_PMASK_SIZE + B44_PMASK_SIZE);
+
+	kfree(pwol_pattern);
+
+	/* set these pattern's lengths: one less than each real length */
+	val = plen0 | (plen1 << 8) | (plen2 << 16) | WKUP_LEN_ENABLE_THREE;
+	bw32(bp, B44_WKUP_LEN, val);
+
+	/* enable wakeup pattern matching */
+	val = br32(bp, B44_DEVCTRL);
+	bw32(bp, B44_DEVCTRL, val | DEVCTRL_PFE);
+
+}
 
 static void b44_setup_wol(struct b44 *bp)
 {
@@ -1482,7 +1588,9 @@ static void b44_setup_wol(struct b44 *bp
 		val = br32(bp, B44_DEVCTRL);
 		bw32(bp, B44_DEVCTRL, val | DEVCTRL_MPM | DEVCTRL_PFE);
 
-	}
+ 	} else {
+ 		b44_setup_pseudo_magicp(bp);
+ 	}
 
 	val = br32(bp, B44_SBTMSLOW);
 	bw32(bp, B44_SBTMSLOW, val | SBTMSLOW_PE);
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index 1f47777..4944507 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -24,6 +24,9 @@
 #define  WKUP_LEN_P3_MASK	0x7f000000 /* Pattern 3 */
 #define  WKUP_LEN_P3_SHIFT	24
 #define  WKUP_LEN_D3		0x80000000
+#define  WKUP_LEN_DISABLE	0x80808080
+#define  WKUP_LEN_ENABLE_TWO	0x80800000
+#define  WKUP_LEN_ENABLE_THREE	0x80000000
 #define B44_ISTAT	0x0020UL /* Interrupt Status */
 #define  ISTAT_LS		0x00000020 /* Link Change (B0 only) */
 #define  ISTAT_PME		0x00000040 /* Power Management Event */


